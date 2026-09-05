"""MUNDO VIVO FASE 6.7 — BRASA, the fire dungeon (ember family + BOSS 4).

  python tools/build_brasa.py

Three floors spliced into authoring/pilot.ldtk (+ sidecars), the MOUTH cut
into ZONE 7's south meadow, every stairs both ways, arrivals one tile from
their doors (ping-pong law), BFS-proven. Geometry = the PEER-APPROVED moss
candidates re-themed (Junior approved C "veias" and B "labirinto" as
geometry on 2026-08-31; A "salão" became floor -3), plus the tower's
"santuário" hall (colonnades + raised dais) as the forge heart:

  ember_1  DUNGEON 5  veins   56x36  lava veins through basalt; heart chamber east
  ember_2  DUNGEON 6  maze    62x28  the old-school maze; the boss ROOM holds the guardian (ember_d)
  ember_3  DUNGEON 7  hall    56x32  colonnade nave -> murado presbitério: BOSS 4 on the dais

Family (FASE 4): ember_a charge · ember_b aura · ember_d beam · ember_boss
(charge8/beam10, 3 phases). Tier rule: floor n uses tier <= n+1. Clears
monotonic (L6) and above the tower's bottom (2434): 2745 < 3040 < 3455.
Rungs: 13 / 15 / 17 (after the tower's 8/10/12). Cap 18 -> 21 (plan §6).
Registry-driven, deterministic, idempotent (levels rebuilt from the
patterns every run).
"""
from __future__ import annotations

import copy
import json
import sys
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "drafts" / "_moss-candidates"))
sys.path.insert(0, str(ROOT / "drafts" / "_medusa-tower"))
import build_moss_candidates as MOSS  # noqa: E402
import build_tower_candidates as TOWER  # noqa: E402

LDTK = ROOT / "authoring" / "pilot.ldtk"
REG = json.loads((ROOT / "data" / "tiles.json").read_text(encoding="utf-8"))["types"]
CHAR2INT = {t["char"]: t["int_grid"] for t in REG.values()}
WALLS = {"#", "%"}

MOUTH_Z7 = (6, 24)          # ZONE 7 south meadow: the hole down into BRASA
MOUTH_RETURN = (6, 23)      # where the rope from ember_1 lands (one tile north of the hole)
RUNGS = {1: 13, 2: 15, 3: 17}
FAUNA = {   # xp: ember_a 45 · ember_b 70 · ember_d 110 · ember_boss 320 (+ the maze guardian ember_d)
    1: {"ember_a": 30, "ember_b": 20},                 # 1350 + 1400 = 2750 > 2434 (tower bottom)
    2: {"ember_a": 14, "ember_b": 24, "ember_d": 5},   # 630 + 1680 + 550 + guardian 110 = 2970
    3: {"ember_a": 8, "ember_b": 20, "ember_d": 10},   # 360 + 1400 + 1100 + BOSS 4 320 = 3180
}
# The clears must beat the tower's bottom (2434) and climb: computed below and asserted.


def refuse(msg):
    print("REFUSED:", msg)
    sys.exit(1)


def bfs_dist(grid, start):
    h, w = len(grid), len(grid[0])
    dist = {start: 0}
    q = deque([start])
    while q:
        x, y = q.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy)
            if 0 <= n[0] < w and 0 <= n[1] < h and grid[n[1]][n[0]] not in WALLS and n not in dist:
                dist[n] = dist[(x, y)] + 1
                q.append(n)
    return dist


def free_neighbor(grid, t, dist, away_from=None):
    cands = []
    for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 1)):
        n = (t[0] + dx, t[1] + dy)
        if n in dist:
            cands.append(n)
    if not cands:
        refuse(f"no free neighbor for door {t}")
    if away_from:
        return max(cands, key=lambda n: (abs(n[0] - away_from[0]) + abs(n[1] - away_from[1]), n))
    return max(cands, key=lambda n: (dist[n], n))


# --- LDtk helpers ------------------------------------------------------------------------
raw = LDTK.read_bytes()
doc = json.loads(raw)
if (json.dumps(doc, indent=2, ensure_ascii=False) + "\n").replace("\n", "\r\n").encode("utf-8") != raw:
    refuse("pilot.ldtk byte-format drifted — STOP")
SERIAL = [0]


def iid():
    SERIAL[0] += 1
    return f"00000000-d157-0067-0000-{SERIAL[0]:012d}"


def fi(ident, ftype, value, def_uid):
    if value is None:
        real = []
    elif ftype == "Point":
        real = [{"id": "V_String", "params": [f"{value['cx']},{value['cy']}"]}]
    else:
        real = [{"id": f"V_{ftype}", "params": [value]}]
    return {"__identifier": ident, "__type": ftype, "__value": value, "__tile": None, "defUid": def_uid, "realEditorValues": real}


def entity(kind, def_uid, color, gx, gy, fields):
    return {"__identifier": kind, "__grid": [gx, gy], "__pivot": [0, 0], "__tags": [], "__tile": None,
            "__smartColor": color, "iid": iid(), "width": 32, "height": 32, "defUid": def_uid,
            "px": [gx * 32, gy * 32], "fieldInstances": fields}


def transition(gx, gy, to, spawn, ttype=None, requires_level=None, requires_defeats=None):
    return entity("Transition", 11, "#5AC8EB", gx, gy, [
        fi("to", "String", to, 110), fi("spawn", "Point", {"cx": spawn[0], "cy": spawn[1]}, 111),
        fi("sealed", "Bool", False, 112), fi("type", "String", ttype, 113),
        fi("stairs_unlocked_by", "String", None, 114), fi("requires_defeats", "Int", requires_defeats, 115),
        fi("requires_level", "Int", requires_level, 116)])


def enemy(kind, gx, gy):
    return entity("EnemySpawn", 13, "#EB5A5A", gx, gy, [fi("kind", "String", kind, 130)])


def level(name):
    return next((l for l in doc["levels"] if l["identifier"] == name), None)


def layer(lvl, ident):
    return next(li for li in lvl["layerInstances"] if li["__identifier"] == ident)


def splice(name, display, floor, W, H, csv, ents):
    lvl = level(name)
    if lvl is None:
        lvl = copy.deepcopy(level("dungeon_1"))
        lvl["identifier"] = name
        lvl["iid"] = iid()
        lvl["uid"] = doc["nextUid"]
        doc["nextUid"] += 1
        for li in lvl["layerInstances"]:
            li["iid"] = iid()
            li["levelId"] = lvl["uid"]
        doc["levels"].append(lvl)
    lvl["pxWid"], lvl["pxHei"] = W * 32, H * 32
    for f in lvl["fieldInstances"]:
        v = {"display_name": display, "floor": floor, "hub": False, "safe": False}[f["__identifier"]]
        f["__value"] = v
        f["realEditorValues"] = [{"id": f"V_{f['__type']}", "params": [v]}]
    for li in lvl["layerInstances"]:
        li["__cWid"], li["__cHei"] = W, H
        if li["__identifier"] == "Terrain":
            li["intGridCsv"] = csv
            li["entityInstances"] = []
        else:
            li["entityInstances"] = ents
            li["intGridCsv"] = li.get("intGridCsv", [])


# --- the three geometries -------------------------------------------------------------------
def floor_geometry(n):
    if n == 1:
        c = MOSS.cand_c()          # veias: entry west (1,18), exit7 (26,34), heart (48,18)
        g, (W, H) = c["g"], c["size"]
        for t in (c["entry"], c["exit7"], c["boss"]):
            g[t[1]][t[0]] = "."
        return g, W, H, tuple(c["entry"]), tuple(c["boss"]), None
    if n == 2:
        c = MOSS.cand_b()          # labirinto: entry (1,13), boss room, exit behind the boss (60,13)
        g, (W, H) = c["g"], c["size"]
        for t in (c["entry"], c["exit7"], c["boss"]):
            g[t[1]][t[0]] = "."
        return g, W, H, tuple(c["entry"]), tuple(c["exit7"]), tuple(c["boss"])
    c = TOWER.f4_santuario()       # hall: entry (1,15), dais/boss (49,15)
    g, (W, H) = c["g"], c["size"]
    for t in (c["entry"], c["boss"]):
        g[t[1]][t[0]] = "."
    return g, W, H, tuple(c["entry"]), None, tuple(c["boss"])


def lava_dress(grid, W, H, dist, seed):
    # decorative lava pools (L, passable) on floor tiles far from doors —
    # deterministic hash sprinkle; rubble (r) near walls. SAFE class.
    out = [row[:] for row in grid]
    for y in range(H):
        for x in range(W):
            if out[y][x] != ".":
                continue
            h = (x * 7 + y * 13 + seed) % 23
            near_wall = any(grid[y + dy][x + dx] in WALLS for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)) if 0 <= x + dx < W and 0 <= y + dy < H)
            if h == 0 and dist.get((x, y), 0) > 6:
                out[y][x] = "L"
            elif h in (5, 11) and near_wall:
                out[y][x] = "r"
    return out


def build_floor(n, above, above_exit, below):
    g, W, H, entry, exit_tile, boss_tile = floor_geometry(n)
    grid = [["#" if g[y][x] == "#" else "." for x in range(W)] for y in range(H)]
    dist = bfs_dist(grid, entry)
    if exit_tile and exit_tile not in dist:
        refuse(f"ember_{n}: exit {exit_tile} unreachable")
    if boss_tile and boss_tile not in dist:
        refuse(f"ember_{n}: boss {boss_tile} unreachable")
    arrival = free_neighbor(grid, entry, dist)
    # the pack needs 3 distinct tiles: walk the arrival inward along the BFS
    # frontier until a tile with 2 free non-door neighbors exists (narrow
    # corridors — the hall's 1-wide mouth — otherwise refuse)
    def pack_at(a):
        return [a] + [t for t in ((a[0], a[1] - 1), (a[0], a[1] + 1), (a[0] + 1, a[1]), (a[0] - 1, a[1])) if t in dist and t != entry][:2]
    pack = pack_at(arrival)
    tries = 0
    while len(pack) < 3 and tries < 6:
        nxt = [t for t in ((arrival[0] + 1, arrival[1]), (arrival[0], arrival[1] + 1), (arrival[0], arrival[1] - 1), (arrival[0] - 1, arrival[1])) if t in dist and dist[t] > dist[arrival]]
        if not nxt:
            break
        arrival = nxt[0]
        pack = pack_at(arrival)
        tries += 1
    if len(pack) < 3:
        refuse(f"ember_{n}: no room for the pack near the door {entry}")
    forbidden = {entry, arrival, *pack}
    if exit_tile:
        forbidden.add(exit_tile)
    if boss_tile:
        forbidden.add(boss_tile)
    dressed = lava_dress(grid, W, H, dist, seed=n * 17)
    # fauna: distance bands from the arrival, weak -> strong, Chebyshev >= 2 apart
    walk = [t for t, d in sorted(dist.items(), key=lambda kv: (kv[1], kv[0])) if t not in forbidden and d >= 4 and dressed[t[1]][t[0]] == "."]
    order = ["ember_a", "ember_b", "ember_d"]
    total = sum(FAUNA[n].values())
    # even spread: pick every k-th eligible tile (Chebyshev >= 2 from the
    # last pick) so the weak kinds fill the near bands and the strong the far
    eligible = []
    for t in walk:
        if all(max(abs(t[0] - e[0]), abs(t[1] - e[1])) >= 2 for e in eligible):
            eligible.append(t)
    if len(eligible) < total:
        refuse(f"ember_{n}: only {len(eligible)} spaced tiles for {total} spawns")
    step = len(eligible) / total
    picks = [eligible[int(i * step)] for i in range(total)]
    spawns = []
    i = 0
    for kind in order:
        for _ in range(FAUNA[n].get(kind, 0)):
            spawns.append((picks[i], kind))
            i += 1
    csv = [CHAR2INT[dressed[y][x]] for y in range(H) for x in range(W)]
    ents = [entity("PackSpawn", 12, "#6BEB5A", gx, gy, [fi("order", "Int", i, 120)]) for i, (gx, gy) in enumerate(pack)]
    # stairs up (free): to the floor above, landing beside ITS stairs-down
    # placeholder landing (relinked by main() once the floor above is built)
    ents.append(transition(*entry, above, above_exit or (0, 0), ttype="rope_spot" if n == 1 else "stairs_up"))
    if below:
        bname, barrival = below
        ents.append(transition(*exit_tile, bname, barrival, ttype="stairs_down", requires_level=RUNGS[n + 1]))
    for (gx, gy), kind in spawns:
        ents.append(enemy(kind, gx, gy))
    if n == 2:
        ents.append(enemy("ember_d", *boss_tile))        # the maze's boss room: the GUARDIAN (elite beam caster)
    if n == 3:
        ents.append(enemy("ember_boss", *boss_tile))     # BOSS 4 on the dais
    splice(f"ember_{n}", f"DUNGEON {4 + n}", -n, W, H, csv, ents)
    census = {}
    for _, k in spawns:
        census[k] = census.get(k, 0) + 1
    if n == 2:
        census["ember_d"] = census.get("ember_d", 0) + 1
    if n == 3:
        census["ember_boss"] = 1
    return dict(W=W, H=H, entry=entry, arrival=arrival, exit=exit_tile, boss=boss_tile, census=census, grid=dressed, dist=dist)


def main():
    z7 = level("zone_7")
    ter = layer(z7, "Terrain")
    W7 = ter["__cWid"]
    # the mouth must be grass in the south meadow (passable) — read the emission
    z7json = json.loads((ROOT / "data" / "zones" / "zone_7.json").read_text(encoding="utf-8"))
    for t in (MOUTH_Z7, MOUTH_RETURN):
        if z7json["tiles"][t[1]][t[0]] in WALLS:
            refuse(f"zone_7 {t} is wall")
    # floors bottom-up so each knows its arrival tile
    f3 = build_floor(3, "ember_2", None, None)
    f2 = build_floor(2, "ember_1", None, ("ember_3", f3["arrival"]))
    f1 = build_floor(1, "zone_7", MOUTH_RETURN, ("ember_2", f2["arrival"]))
    # fix the stairs_up landings now that arrivals/exits are known
    def relink_up(name, above, land):
        li = layer(level(name), "Entities")
        for e in li["entityInstances"]:
            if e["__identifier"] == "Transition" and any(f["__identifier"] == "to" and f["__value"] == above for f in e["fieldInstances"]):
                sp = next(f for f in e["fieldInstances"] if f["__identifier"] == "spawn")
                sp["__value"] = {"cx": land[0], "cy": land[1]}
                sp["realEditorValues"] = [{"id": "V_String", "params": [f"{land[0]},{land[1]}"]}]
    # landing beside the floor-above's stairs-down (never on it)
    up2 = free_neighbor(f1["grid"], f1["exit"], f1["dist"], away_from=f1["entry"])
    up3 = free_neighbor(f2["grid"], f2["exit"], f2["dist"], away_from=f2["entry"])
    relink_up("ember_2", "ember_1", up2)
    relink_up("ember_3", "ember_2", up3)
    # ZONE 7: the mouth (hole, auto-fire, rung 13) — idempotent
    li7 = layer(z7, "Entities")
    li7["entityInstances"] = [e for e in li7["entityInstances"] if not (e["__identifier"] == "Transition" and any(f["__identifier"] == "to" and f["__value"] == "ember_1" for f in e["fieldInstances"]))]
    li7["entityInstances"].append(transition(*MOUTH_Z7, "ember_1", f1["arrival"], ttype="hole", requires_level=RUNGS[1]))
    LDTK.write_bytes((json.dumps(doc, indent=2, ensure_ascii=False) + "\n").replace("\n", "\r\n").encode("utf-8"))

    # sidecars: basalt + ember
    for n, f in ((1, f1), (2, f2), (3, f3)):
        depth = {1: 1.0, 2: 0.9, 3: 0.8}[n]
        def dim(c):
            return [max(0, min(255, round(v * depth))) for v in c]
        W, H = f["W"], f["H"]
        walls_by_floor = [t for t in ((x, y) for y in range(2, H - 2) for x in range(2, W - 2))
                          if f["grid"][t[1]][t[0]] == "#" and any(f["grid"][t[1] + dy][t[0] + dx] == "." for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))]
        torches = sorted(walls_by_floor, key=lambda t: (t[1], t[0]))[::max(1, len(walls_by_floor) // 10)][:10]
        far = f["dist"][f["boss"]] if f["boss"] else max(f["dist"].values())
        sidecar = {
            "palette": {
                "floor": dim([28, 22, 22]), "grid": dim([40, 32, 30]), "wall": dim([70, 46, 40]),
                "wall_inner": dim([24, 16, 14]), "transition": [235, 190, 90],
                "station": [190, 140, 60], "station_seal": [190, 140, 60],
                "dirt": dim([48, 36, 30]), "sand": dim([84, 62, 44]), "grass": dim([46, 50, 34]), "grass_b": dim([40, 44, 30]), "grass_c": dim([52, 56, 38]),
                "wood": dim([70, 50, 36]), "water": dim([30, 30, 44]),
                "lava_deco": dim([235, 110, 30]), "rubble": dim([54, 42, 40]),
                "motif": "chip", "motif_rgb": dim([44, 34, 32]), "ambient_rgba": [255, 120, 40, 10 + 3 * n]
            },
            "tile_size": 32,
            "gradient_anchor": [f["arrival"][0], f["arrival"][1]],
            "drop_gradient": [[0, 4.0 + 0.5 * (n - 1)], [far // 3, 4.5 + 0.5 * (n - 1)], [(2 * far) // 3, 5.0 + 0.5 * (n - 1)]],
            "decor": [{"kind": "ambience", "at": [x, y], "preset": "torch_flicker"} for (x, y) in torches],
            "ambience_regions": [
                {"id": f"brasa{n}_sparks", "rect": [0, 0, W, H], "intent": "dungeon", "ambience": "ember_sparks", "ambience_density": 0.07, "ambience_tiles": ["."]},
                {"id": f"brasa{n}_haze", "rect": [0, 0, W, H], "intent": "dungeon", "ambience": "fog_bank", "ambience_density": 0.04, "ambience_tiles": ["."]}
            ]
        }
        (ROOT / "authoring" / f"ember_{n}.sidecar.json").write_text(json.dumps(sidecar, indent=2) + "\n", encoding="utf-8", newline="\n")
    xp = json.loads((ROOT / "data" / "balance" / "progression.json").read_text(encoding="utf-8"))["kill_xp"]
    clears = [sum(xp[k] * v for k, v in f["census"].items()) for f in (f1, f2, f3)]
    for n, f, cl in ((1, f1, clears[0]), (2, f2, clears[1]), (3, f3, clears[2])):
        print(f"ember_{n} DUNGEON {4 + n} {f['W']}x{f['H']}: arrival {f['arrival']} (door {f['entry']}) exit {f['exit']} boss {f['boss']} fauna {f['census']} clear={cl}")
    if not (2434 < clears[0] < clears[1] < clears[2]):
        refuse(f"BRASA clears must climb above the tower's bottom (2434): {clears}")
    print(f"zone_7 mouth {MOUTH_Z7} (hole, requires_level {RUNGS[1]}) -> ember_1 @ {f1['arrival']}; return rope lands {MOUTH_RETURN}")
    print("next: ruby tools/import_ldtk.rb authoring/pilot.ldtk --sidecars authoring --out tmp/ldtk_out && cp tmp/ldtk_out/{ember_*,zone_7}.json data/zones/")


if __name__ == "__main__":
    main()

"""MUNDO VIVO FASE 6.3-6.5 — the MEDUSA TOWER floors (dungeon_2 / _3 / _4).

  python tools/build_tower_floor.py <n> [--down]

Splices level `dungeon_<n>` (52x52, Junior-approved Tibia pattern from
drafts/_medusa-tower-concepts-20260831.md: 2 = A divisória · 3 = B espiral
· 4 = C portão-pedágio) into authoring/pilot.ldtk + its sidecar, and wires
the floor above (dungeon_<n-1>) with a `stairs_down` on ITS exit tile
(dungeon_1 = the medusa's center hole [33,25]). `--down` also writes this
floor's own `stairs_down` to dungeon_<n+1> (only once that level exists —
the importer refuses unknown targets). Re-running is IDEMPOTENT: the level
is rebuilt from the pattern every time (deterministic geometry + fauna).

Geometry law (Junior, 2026-08-31): everything walkable is INSIDE the ring;
outside = rock (wall_inner, the second wall class); the ring = wall; the
arrival sits ONE tile from every door (ping-pong law, FASE 6.1). BFS proves
arrival -> stairs, and the "volta forçada" ratio (real path / Manhattan) is
printed and test-pinned per floor.

Fauna (serpent family, FASE 4/5; tier <= n+1 rule, L6 clear > floor above):
  2: stinger x8, serpent_a x10, warden x4, serpent_b x5              = 2055 > 2010 (D1)
  3: stinger x6, serpent_a x8, warden x4, serpent_b x8, serpent_c x4 = 2402 > 2055
  4: serpent_a x6, warden x4, serpent_b x8, serpent_c x8 + serpent_boss (BOSS 2) = 2494+240 > 2402
Gates: stairs into floor n require level 8 / 10 / 12 (recorded proposal; the
frontier rope is 8). Cap steps ride the floors: 16 / 17 / 18 (plan §6).
"""
from __future__ import annotations

import copy
import json
import sys
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "drafts" / "_medusa-tower"))
sys.path.insert(0, str(ROOT / "drafts" / "_moss-candidates"))
import build_tower_candidates as TOWER  # noqa: E402  (module-level render is guarded below)

LDTK = ROOT / "authoring" / "pilot.ldtk"
REG = json.loads((ROOT / "data" / "tiles.json").read_text(encoding="utf-8"))["types"]
CHAR2INT = {t["char"]: t["int_grid"] for t in REG.values()}
WALLS = {"#", "%"}

PATTERN = {2: TOWER.f2_replica, 3: TOWER.f2_ruina, 4: TOWER.f2_complexo}
LABEL = {2: "A divisoria", 3: "B espiral", 4: "C portao-pedagio"}
REQ_LEVEL = {2: 8, 3: 10, 4: 12}
FAUNA = {
    2: {"stinger": 8, "serpent_a": 10, "warden": 4, "serpent_b": 5},
    3: {"stinger": 6, "serpent_a": 8, "warden": 4, "serpent_b": 8, "serpent_c": 4},
    4: {"serpent_a": 6, "warden": 4, "serpent_b": 8, "serpent_c": 8},
}
ABOVE_EXIT = {1: (33, 25)}  # dungeon_1 (medusa): the center hole = the stairs down


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


def neighbors_free(grid, t, dist):
    x, y = t
    for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 1)):
        n = (x + dx, y + dy)
        if n in dist:
            yield n


# --- LDtk helpers (byte-format law) ---------------------------------------------
raw = LDTK.read_bytes()
doc = json.loads(raw)
formatted = (json.dumps(doc, indent=2, ensure_ascii=False) + "\n").replace("\n", "\r\n").encode("utf-8")
if formatted != raw:
    refuse("pilot.ldtk byte-format drifted from json.dumps(indent=2)+CRLF — STOP")

SERIAL = [0]


def iid(n):
    SERIAL[0] += 1
    return f"00000000-d157-00{n:02d}-0000-{SERIAL[0]:012d}"


def fi(ident, ftype, value, def_uid):
    if value is None:
        real = []
    elif ftype == "Point":
        real = [{"id": "V_String", "params": [f"{value['cx']},{value['cy']}"]}]
    else:
        real = [{"id": f"V_{ftype}", "params": [value]}]
    return {"__identifier": ident, "__type": ftype, "__value": value,
            "__tile": None, "defUid": def_uid, "realEditorValues": real}


def entity(n, kind, def_uid, color, gx, gy, fields):
    return {"__identifier": kind, "__grid": [gx, gy], "__pivot": [0, 0],
            "__tags": [], "__tile": None, "__smartColor": color, "iid": iid(n),
            "width": 32, "height": 32, "defUid": def_uid, "px": [gx * 32, gy * 32],
            "fieldInstances": fields}


def transition(n, gx, gy, to, spawn, ttype=None, requires_level=None, requires_defeats=None):
    return entity(n, "Transition", 11, "#5AC8EB", gx, gy, [
        fi("to", "String", to, 110),
        fi("spawn", "Point", {"cx": spawn[0], "cy": spawn[1]}, 111),
        fi("sealed", "Bool", False, 112),
        fi("type", "String", ttype, 113),
        fi("stairs_unlocked_by", "String", None, 114),
        fi("requires_defeats", "Int", requires_defeats, 115),
        fi("requires_level", "Int", requires_level, 116),
    ])


def level(name):
    return next((l for l in doc["levels"] if l["identifier"] == name), None)


def layer(lvl, ident):
    return next(li for li in lvl["layerInstances"] if li["__identifier"] == ident)


def main():
    if len(sys.argv) < 2 or sys.argv[1] not in ("2", "3", "4"):
        refuse("usage: build_tower_floor.py <2|3|4> [--down]")
    n = int(sys.argv[1])
    link_down = "--down" in sys.argv
    name = f"dungeon_{n}"
    above = f"dungeon_{n - 1}"
    below = f"dungeon_{n + 1}"
    if level(above) is None:
        refuse(f"{above} must exist before {name}")
    if link_down and level(below) is None:
        refuse(f"--down asked but {below} does not exist yet")

    pat = PATTERN[n]()
    g = pat["g"]
    W, H = pat["size"]
    ring = pat["ring"]
    entry = tuple(pat["entry"])   # the door UP (stairs_up -> floor above)
    out = tuple(pat["out"])       # the door DOWN (stairs_down -> floor below)
    for t in (entry, out):
        g[t[1]][t[0]] = "."
    grid = [["." if g[y][x] == "." else ("#" if (x, y) in ring else "%") for x in range(W)] for y in range(H)]
    dist = bfs_dist(grid, entry)
    if out not in dist:
        refuse(f"{name}: stairs-down {out} unreachable from the arrival door {entry}")
    # arrivals one tile INSIDE each door (ping-pong law): pick the free
    # neighbor with the LARGER distance to the other door (deterministic order)
    arr_up = max(neighbors_free(grid, entry, dist), key=lambda t: (dist[t], t))
    dist_out = bfs_dist(grid, out)
    arr_down = max(neighbors_free(grid, out, dist_out), key=lambda t: (dist_out[t], t))
    manhattan = abs(out[0] - entry[0]) + abs(out[1] - entry[1])
    volta = dist[out]
    ratio = volta / max(manhattan, 1)
    print(f"{name} [{LABEL[n]}] {W}x{H}: arrival {arr_up} (door {entry}) -> stairs {out}: "
          f"real={volta} manhattan={manhattan} ratio={ratio:.2f} (the forced loop)")
    if ratio < 1.8:
        refuse(f"{name}: forced-loop ratio {ratio:.2f} < 1.8 — the pattern lost its volta")

    # fauna: deterministic placement over the walkable disc, spread by distance
    # bands from the arrival (near -> far = weak -> strong), never on doors/arrivals/
    # pack tiles, min Chebyshev 2 between spawns.
    forbidden = {entry, out, arr_up, arr_down}
    pack = [arr_up]
    for c in ((arr_up[0] - 1, arr_up[1]), (arr_up[0] + 1, arr_up[1]), (arr_up[0], arr_up[1] - 1), (arr_up[0], arr_up[1] + 1)):
        if c in dist and c not in forbidden and len(pack) < 3:
            pack.append(c)
    if len(pack) < 3:
        refuse(f"{name}: no room for 3 pack tiles at the arrival")
    forbidden |= set(pack)
    walk = sorted(dist.items(), key=lambda kv: (kv[1], kv[0]))
    walk = [t for t, d in walk if t not in forbidden and d >= 4]
    order = ["stinger", "warden", "serpent_a", "serpent_b", "serpent_c"]  # weak -> strong by depth
    total = sum(FAUNA[n].values())
    spawns = []
    taken = set()
    stride = max(1, len(walk) // (total + 1))
    idx = 0
    for kind in order:
        for _ in range(FAUNA[n].get(kind, 0)):
            while idx < len(walk):
                t = walk[idx]
                idx += stride
                if all(max(abs(t[0] - s[0]), abs(t[1] - s[1])) >= 2 for s, _ in spawns) and t not in taken:
                    spawns.append((t, kind))
                    taken.add(t)
                    break
            else:
                refuse(f"{name}: ran out of walkable tiles placing {kind}")
    boss = None
    if n == 4:
        # BOSS 2 at the tile FARTHEST from the arrival (the vault the volta protects)
        far = max((t for t in dist if t not in forbidden and t not in taken), key=lambda t: (dist[t], t))
        boss = far
    csv = [CHAR2INT[grid[y][x]] for y in range(H) for x in range(W)]

    ents = []
    for i, (gx, gy) in enumerate(pack):
        ents.append(entity(n, "PackSpawn", 12, "#6BEB5A", gx, gy, [fi("order", "Int", i, 120)]))
    # stairs UP: back to the floor above, landing one tile beside ITS stairs-down
    above_exit = ABOVE_EXIT.get(n - 1)
    if above_exit is None:
        pa = PATTERN[n - 1]()
        above_exit = tuple(pa["out"])
    ents.append(transition(n, *entry, above, above_exit_landing(above_exit, n - 1), ttype="stairs_up"))
    if link_down:
        pb = PATTERN[n + 1]()
        gb = pb["g"]
        eb = tuple(pb["entry"])
        gb[eb[1]][eb[0]] = "."
        gridb = [["." if gb[y][x] == "." else "#" for x in range(pb["size"][0])] for y in range(pb["size"][1])]
        db = bfs_dist(gridb, eb)
        arr_b = max(neighbors_free(gridb, eb, db), key=lambda t: (db[t], t))
        ents.append(transition(n, *out, below, arr_b, ttype="stairs_down", requires_level=REQ_LEVEL[n + 1]))
    for (gx, gy), kind in spawns:
        ents.append(entity(n, "EnemySpawn", 13, "#EB5A5A", gx, gy, [fi("kind", "String", kind, 130)]))
    if boss:
        ents.append(entity(n, "EnemySpawn", 13, "#EB5A5A", *boss, [fi("kind", "String", "serpent_boss", 130)]))

    # --- level splice (rebuild if present) ---
    lvl = level(name)
    if lvl is None:
        tmpl = level("dungeon_1")
        lvl = copy.deepcopy(tmpl)
        lvl["identifier"] = name
        lvl["iid"] = iid(n)
        lvl["uid"] = doc["nextUid"]
        doc["nextUid"] += 1
        for li in lvl["layerInstances"]:
            li["iid"] = iid(n)
            li["levelId"] = lvl["uid"]
        doc["levels"].append(lvl)
    lvl["pxWid"], lvl["pxHei"] = W * 32, H * 32
    for f in lvl["fieldInstances"]:
        v = {"display_name": f"DUNGEON {n}", "floor": -n, "hub": False, "safe": False}[f["__identifier"]]
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

    # --- the floor ABOVE gets its stairs_down to this floor (idempotent) ---
    up = level(above)
    ul = layer(up, "Entities")
    ul["entityInstances"] = [e for e in ul["entityInstances"]
                             if not (e["__identifier"] == "Transition" and
                                     any(f["__identifier"] == "to" and f["__value"] == name for f in e["fieldInstances"]))]
    ul["entityInstances"].append(transition(n, *above_exit, name, arr_up, ttype="stairs_down", requires_level=REQ_LEVEL[n]))

    LDTK.write_bytes((json.dumps(doc, indent=2, ensure_ascii=False) + "\n").replace("\n", "\r\n").encode("utf-8"))

    # --- sidecar: buried tower look (dark rock, rust wall, grey stone floor) ---
    depth = {2: 0.92, 3: 0.84, 4: 0.76}[n]
    def dim(c):
        return [max(0, min(255, round(v * depth))) for v in c]
    torches = [t for t in [(x, y) for (x, y) in ring if 3 <= x <= W - 4 and 3 <= y <= H - 4]
               if grid[t[1]][t[0]] == "#" and any(grid[ny][nx] == "." for nx, ny in ((t[0], t[1] + 1), (t[0], t[1] - 1), (t[0] + 1, t[1]), (t[0] - 1, t[1])))]
    torches = sorted(torches, key=lambda t: (t[1], t[0]))[::max(1, len(torches) // 8)][:8]
    sidecar = {
        "palette": {
            "floor": dim([124, 124, 128]), "grid": dim([104, 104, 110]), "wall": dim([176, 58, 36]),
            "wall_inner": dim([34, 26, 20]), "transition": [235, 190, 90],
            "station": [190, 140, 60], "station_seal": [190, 140, 60],
            "dirt": dim([60, 46, 36]), "sand": dim([90, 78, 56]), "grass": dim([46, 70, 46]),
            "grass_b": dim([40, 62, 40]), "grass_c": dim([52, 78, 52]), "wood": dim([98, 72, 42]),
            "water": dim([18, 42, 52]), "moss": dim([40, 76, 44]),
            "motif": "chip", "motif_rgb": dim([112, 112, 118]), "ambient_rgba": [120, 90, 160, 10 + 2 * (n - 2)]
        },
        "tile_size": 32,
        "gradient_anchor": [arr_up[0], arr_up[1]],
        "drop_gradient": [[0, 3.5 + 0.5 * (n - 2)], [volta // 3, 4.0 + 0.5 * (n - 2)], [(2 * volta) // 3, 4.5 + 0.5 * (n - 2)]],
        "decor": [{"kind": "ambience", "at": [x, y], "preset": "torch_flicker"} for (x, y) in torches],
        "ambience_regions": [
            {"id": f"tower{n}_dust", "rect": [0, 0, W, H], "intent": "dungeon",
             "ambience": "dust_motes", "ambience_density": 0.05, "ambience_tiles": ["."]}
        ]
    }
    (ROOT / "authoring" / f"{name}.sidecar.json").write_text(json.dumps(sidecar, indent=2) + "\n", encoding="utf-8", newline="\n")
    census = {}
    for _, k in spawns:
        census[k] = census.get(k, 0) + 1
    print(f"{name}: pack {pack} · stairs_up {entry}->{above}@{above_exit_landing(above_exit, n - 1)} · "
          f"{above} stairs_down {above_exit}->{name}@{arr_up} (requires_level {REQ_LEVEL[n]}) · "
          f"fauna {census}{' · BOSS 2 @ ' + str(boss) if boss else ''} · torches {len(torches)}"
          f"{' · stairs_down -> ' + below if link_down else ' · stairs_down: INERT until ' + below}")
    print("next: ruby tools/import_ldtk.rb authoring/pilot.ldtk --sidecars authoring --out tmp/ldtk_out && cp tmp/ldtk_out/{dungeon_*}.json data/zones/")


def above_exit_landing(above_exit, m):
    # land ONE tile beside the floor-above's stairs-down (never on it): the
    # medusa's hole [33,25] -> [33,24]; a pattern floor's `out` -> its computed
    # neighbor (recomputed from the pattern so both files agree).
    if m == 1:
        return (above_exit[0], above_exit[1] - 1)
    pa = PATTERN[m]()
    ga = pa["g"]
    ea, oa = tuple(pa["entry"]), tuple(pa["out"])
    for t in (ea, oa):
        ga[t[1]][t[0]] = "."
    grida = [["." if ga[y][x] == "." else "#" for x in range(pa["size"][0])] for y in range(pa["size"][1])]
    da = bfs_dist(grida, oa)
    return max(neighbors_free(grida, oa, da), key=lambda t: (da[t], t))


if __name__ == "__main__":
    main()

"""MUNDO VIVO FASE 6.1 — the SWAP (spec: drafts/_swap-spec-medusa-to-dungeon1-20260831.md).

  dungeon_1  <- MEDUSA LOWER geometry (52x52, from the current low_quay level),
                re-wired: zone_7 hole arrives at the serpent head; rope back to
                zone_7 beside it; rope to ZONE 8 moved to the head's north rim
                ([29,4] is wall in this geometry -> [29,7], nearest walkable);
                the old internal seal DIES; the center hole stays INERT (the
                stairs to tower floor 2 land with dungeon_2); fauna = stinger x24
                + warden x5 migrate WITH the geometry; NO challenger (BOSS 1 is
                not duplicated — the tower gets its own final, FASE 5).
  low_quay   <- MUSGO "A — salão selado" (52x36, Junior-approved candidate;
                drafts/_moss-floor3-candidates-20260831.md): entry west
                (slow_door), exit south (zone_7, requires_defeats 1), BOSS 1 in
                the vault; fauna = spore_a x14 + spore_b x9 (FASE 4.5) — the
                floor -3 clear pays 1955 > floor -2's 1780 (L6).

LDtk owns spatial truth: this tool edits authoring/pilot.ldtk + the two
sidecars; data/zones/* is then re-emitted by tools/import_ldtk.rb (the only
door). Registry-driven: char <-> int_grid from data/tiles.json. Deterministic,
idempotent (refuses to run twice: the low_quay level must still be 52x52).

Run from repo root:  python tools/swap_medusa_to_dungeon1.py
Then:  ruby tools/import_ldtk.rb authoring/pilot.ldtk --sidecars authoring --out tmp/ldtk_out
       cp tmp/ldtk_out/{dungeon_1,low_quay,zone_7}.json data/zones/
"""
from __future__ import annotations

import copy
import json
import sys
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "drafts" / "_moss-candidates"))
import build_moss_candidates as MOSS  # noqa: E402  (main() guarded)

LDTK = ROOT / "authoring" / "pilot.ldtk"
REG = json.loads((ROOT / "data" / "tiles.json").read_text(encoding="utf-8"))["types"]
CHAR2INT = {t["char"]: t["int_grid"] for t in REG.values()}
INT2CHAR = {t["int_grid"]: t["char"] for t in REG.values()}
WALLS = {"#", "%"}

# --- endpoints (spec §1) --------------------------------------------------------
MED_W = MED_H = 52
MED_HEAD_ARRIVAL = (10, 8)       # zone_7 hole spawn (the slow_door used to land here)
MED_ROPE_BACK = (9, 8)           # rope_spot -> zone_7 [33,16] (old slow_door edge tile)
MED_ROPE_Z8 = (29, 7)            # rope_spot -> zone_8 [62,18] requires_level 8 (was [29,4]: wall here)
MED_PACK_SPAWN = [(10, 8), (11, 8), (10, 7)]
Z7_RETURN_TO_D1 = (10, 8)        # zone_7's transition to dungeon_1: spawn
Z8_RETURN_TO_D1 = MED_ROPE_Z8    # zone_8's transition to dungeon_1: spawn (pin moves consciously)

MOSS_ENTRY = (1, 18)             # the west DOOR (-> slow_door)
MOSS_ARRIVAL_W = (2, 18)         # slow_door arrives ONE tile inside (a door that is also the
                                 # arrival ping-pongs the pack back on the same tick — caught live)
MOSS_EXIT7 = (24, 34)            # the south DOOR (-> zone_7 [2,14] requires_defeats 1)
MOSS_ARRIVAL_S = (24, 33)        # zone_7 arrives one tile north of it
MOSS_BOSS = (41, 18)
MOSS_PACK_SPAWN = [(3, 18), (3, 17), (3, 19)]
# fauna placed on the REAL moss-A geometry (entry hall x2-13 y13-23 · spine
# x19-29 y6-30 · north corridor y3-5 x23-39 + x37-39 y6-9 · south corridor
# y31-33 x23-39 + x37-39 y27-30 · vault x34-48 y10-26 with pillars):
SPORE_A = [(4, 15), (10, 15), (4, 21), (10, 21), (7, 18),          # entry hall (5): first bites
           (21, 8), (27, 8), (21, 13), (27, 17), (21, 22), (27, 27),  # spine (6): the long walk
           (30, 4), (30, 32), (38, 8)]                                # corridors (3): ambush
SPORE_B = [(36, 4), (38, 32), (38, 28),                              # corridor mouths (3): gate the vault doors
           (36, 12), (46, 12), (36, 24), (46, 24), (41, 13), (41, 23)]  # vault (6): the guard

DEV = []


def dev(msg):
    DEV.append(msg)
    print("DEVIATION:", msg)


def refuse(msg):
    print("REFUSED:", msg)
    sys.exit(1)


# --- LDtk helpers (byte-format law from build_low_quay_v3.py) ---------------------
raw = LDTK.read_bytes()
doc = json.loads(raw)
formatted = (json.dumps(doc, indent=2, ensure_ascii=False) + "\n").replace("\n", "\r\n").encode("utf-8")
if formatted != raw:
    refuse("pilot.ldtk byte-format drifted from json.dumps(indent=2)+CRLF — STOP")

SERIAL = [0]


def iid():
    SERIAL[0] += 1
    return f"00000000-d157-0006-0000-{SERIAL[0]:012d}"


def fi(ident, ftype, value, def_uid):
    if value is None:
        real = []
    elif ftype == "Point":
        real = [{"id": "V_String", "params": [f"{value['cx']},{value['cy']}"]}]
    else:
        real = [{"id": f"V_{ftype}", "params": [value]}]
    return {"__identifier": ident, "__type": ftype, "__value": value,
            "__tile": None, "defUid": def_uid, "realEditorValues": real}


def entity(kind, def_uid, color, gx, gy, fields):
    return {"__identifier": kind, "__grid": [gx, gy], "__pivot": [0, 0],
            "__tags": [], "__tile": None, "__smartColor": color, "iid": iid(),
            "width": 32, "height": 32, "defUid": def_uid, "px": [gx * 32, gy * 32],
            "fieldInstances": fields}


def transition(gx, gy, to, spawn, sealed=False, ttype=None, requires_defeats=None, requires_level=None):
    return entity("Transition", 11, "#5AC8EB", gx, gy, [
        fi("to", "String", to, 110),
        fi("spawn", "Point", {"cx": spawn[0], "cy": spawn[1]}, 111),
        fi("sealed", "Bool", sealed, 112),
        fi("type", "String", ttype, 113),
        fi("stairs_unlocked_by", "String", None, 114),
        fi("requires_defeats", "Int", requires_defeats, 115),
        fi("requires_level", "Int", requires_level, 116),
    ])


def enemy(kind, gx, gy):
    return entity("EnemySpawn", 13, "#EB5A5A", gx, gy, [fi("kind", "String", kind, 130)])


def pack(i, gx, gy):
    return entity("PackSpawn", 12, "#6BEB5A", gx, gy, [fi("order", "Int", i, 120)])


def level(name):
    return next(l for l in doc["levels"] if l["identifier"] == name)


def layer(lvl, ident):
    return next(li for li in lvl["layerInstances"] if li["__identifier"] == ident)


def set_level_geometry(lvl, w, h, csv, ents, display_name, floor):
    lvl["pxWid"], lvl["pxHei"] = w * 32, h * 32
    for f in lvl["fieldInstances"]:
        v = {"display_name": display_name, "floor": floor, "hub": False, "safe": False}[f["__identifier"]]
        f["__value"] = v
        f["realEditorValues"] = [{"id": f"V_{f['__type']}", "params": [v]}]
    for li in lvl["layerInstances"]:
        li["__cWid"], li["__cHei"] = w, h
        if li["__identifier"] == "Terrain":
            li["intGridCsv"] = csv
            li["entityInstances"] = []
        else:
            li["entityInstances"] = ents
            li["intGridCsv"] = li.get("intGridCsv", [])


def grid_from_csv(csv, w, h):
    return [[INT2CHAR[csv[y * w + x]] for x in range(w)] for y in range(h)]


def bfs(grid, start):
    h, w = len(grid), len(grid[0])
    seen = {start}
    q = deque([start])
    while q:
        x, y = q.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy)
            if 0 <= n[0] < w and 0 <= n[1] < h and grid[n[1]][n[0]] not in WALLS and n not in seen:
                seen.add(n)
                q.append(n)
    return seen


# --- 1) take MEDUSA LOWER out of the low_quay level --------------------------------
lq = level("low_quay")
ter = layer(lq, "Terrain")
if (ter["__cWid"], ter["__cHei"]) != (MED_W, MED_H):
    refuse(f"low_quay level is {ter['__cWid']}x{ter['__cHei']}, expected 52x52 (swap already applied?)")
med_csv = list(ter["intGridCsv"])
med_grid = grid_from_csv(med_csv, MED_W, MED_H)
old_ents = layer(lq, "Entities")["entityInstances"]
med_spawns = {}
for ei in old_ents:
    if ei["__identifier"] == "EnemySpawn":
        kind = next(f["__value"] for f in ei["fieldInstances"] if f["__identifier"] == "kind")
        med_spawns.setdefault(kind, []).append(tuple(ei["__grid"]))
print("medusa fauna carried:", {k: len(v) for k, v in med_spawns.items()})
if "challenger" in med_spawns:
    dev("BOSS 1 (challenger) NOT carried into DUNGEON 1 — no boss duplication (spec §1 M2); its post moves to the MUSGO vault")
    del med_spawns["challenger"]

reach = bfs(med_grid, MED_HEAD_ARRIVAL)
for tag, t in (("head arrival", MED_HEAD_ARRIVAL), ("rope back", MED_ROPE_BACK), ("rope ZONE 8", MED_ROPE_Z8)):
    if med_grid[t[1]][t[0]] in WALLS:
        refuse(f"{tag} {t} is a wall in the medusa geometry")
    if t not in reach:
        refuse(f"{tag} {t} unreachable from the head arrival")
for p in MED_PACK_SPAWN:
    if med_grid[p[1]][p[0]] in WALLS or p not in reach:
        refuse(f"pack spawn {p} not walkable/reachable in medusa")
for kind, pts in med_spawns.items():
    bad = [p for p in pts if p not in reach]
    if bad:
        refuse(f"{kind} spawns unreachable in medusa: {bad}")
dev("rope to ZONE 8 re-addressed [29,4] -> [29,7] ([29,4] is wall in the serpent geometry; [29,7] = nearest walkable on the head's north rim)")

med_ents = []
for i, (gx, gy) in enumerate(MED_PACK_SPAWN):
    med_ents.append(pack(i, gx, gy))
med_ents.append(transition(*MED_ROPE_BACK, "zone_7", (33, 16), ttype="rope_spot"))
med_ents.append(transition(*MED_ROPE_Z8, "zone_8", (62, 18), ttype="rope_spot", requires_level=8))
for kind in ("stinger", "warden"):
    for gx, gy in med_spawns.get(kind, []):
        med_ents.append(enemy(kind, gx, gy))
dev("dungeon_1's internal seal station [17,2] -> [18,2] DIES with the old geometry (save migration L9: the breach tuple (dungeon_1,[18,2]) is dropped on load, named)")

d1 = level("dungeon_1")
set_level_geometry(d1, MED_W, MED_H, med_csv, med_ents, "DUNGEON 1", -1)
print(f"dungeon_1 <- medusa 52x52: {len(med_ents)} entities")

# --- 2) MUSGO A into the low_quay level ---------------------------------------------
moss = MOSS.cand_a()
g = moss["g"]
MW, MH = moss["size"]
for tag in ("entry", "exit7", "boss"):
    x, y = moss[tag]
    g[y][x] = "."
if (moss["entry"], moss["exit7"], moss["boss"]) != (MOSS_ENTRY, MOSS_EXIT7, MOSS_BOSS):
    refuse(f"moss A endpoints drifted from the approved candidate: {moss['entry']} {moss['exit7']} {moss['boss']}")
# floor tiles are MOSS ('m', FASE 3 decorative type: passable, moss_sway ambience);
# walls stay '#'. A few pockets of plain floor ('.') keep the moss from reading flat.
moss_grid = []
for y in range(MH):
    row = []
    for x in range(MW):
        c = g[y][x]
        if c == "#":
            row.append("#")
        elif (x * 7 + y * 13) % 9 == 0:
            row.append(".")
        else:
            row.append("m")
    moss_grid.append(row)
reach_m = bfs(moss_grid, MOSS_ENTRY)
for tag, t in (("entry", MOSS_ENTRY), ("arrival W", MOSS_ARRIVAL_W), ("exit7", MOSS_EXIT7),
               ("arrival S", MOSS_ARRIVAL_S), ("boss", MOSS_BOSS)):
    if t not in reach_m:
        refuse(f"moss {tag} {t} unreachable")
for p in MOSS_PACK_SPAWN + SPORE_A + SPORE_B:
    if moss_grid[p[1]][p[0]] in WALLS or p not in reach_m:
        refuse(f"moss spawn {p} not walkable/reachable")
moss_csv = [CHAR2INT[moss_grid[y][x]] for y in range(MH) for x in range(MW)]
moss_ents = []
for i, (gx, gy) in enumerate(MOSS_PACK_SPAWN):
    moss_ents.append(pack(i, gx, gy))
moss_ents.append(transition(*MOSS_ENTRY, "slow_door", (7, 2)))
moss_ents.append(transition(*MOSS_EXIT7, "zone_7", (2, 14), requires_defeats=1))
for gx, gy in SPORE_A:
    moss_ents.append(enemy("spore_a", gx, gy))
for gx, gy in SPORE_B:
    moss_ents.append(enemy("spore_b", gx, gy))
moss_ents.append(enemy("challenger", *MOSS_BOSS))
set_level_geometry(lq, MW, MH, moss_csv, moss_ents, "ZONE 5", -3)
n_walk = sum(1 for y in range(MH) for x in range(MW) if moss_grid[y][x] not in WALLS)
print(f"low_quay <- MUSGO A {MW}x{MH}: walkable={n_walk} entities={len(moss_ents)} (spore_a {len(SPORE_A)}, spore_b {len(SPORE_B)}, challenger 1)")

# --- 3) zone_7 return rows ---------------------------------------------------------------
z7 = level("zone_7")
for ei in layer(z7, "Entities")["entityInstances"]:
    if ei["__identifier"] != "Transition":
        continue
    fis = {f["__identifier"]: f for f in ei["fieldInstances"]}
    to = fis["to"]["__value"]
    new = {"dungeon_1": Z7_RETURN_TO_D1, "low_quay": MOSS_ARRIVAL_S}.get(to)
    if new is None:
        continue
    old = fis["spawn"]["__value"]
    fis["spawn"]["__value"] = {"cx": new[0], "cy": new[1]}
    fis["spawn"]["realEditorValues"] = [{"id": "V_String", "params": [f"{new[0]},{new[1]}"]}]
    dev(f"zone_7 -> {to} spawn {[old['cx'], old['cy']]} -> {list(new)} (emission moves in exactly this row)")

out = (json.dumps(doc, indent=2, ensure_ascii=False) + "\n").replace("\n", "\r\n").encode("utf-8")
LDTK.write_bytes(out)

# --- 4) sidecars ----------------------------------------------------------------------------
sc_lq_path = ROOT / "authoring" / "low_quay.sidecar.json"
sc_d1_path = ROOT / "authoring" / "dungeon_1.sidecar.json"
sc_lq = json.loads(sc_lq_path.read_text(encoding="utf-8"))
sc_d1 = json.loads(sc_d1_path.read_text(encoding="utf-8"))
# dungeon_1 takes the medusa's look (palette incl. wall_inner void + decor landmarks + ambient)
new_d1 = copy.deepcopy(sc_lq)
new_d1.pop("ambience_regions", None)
new_d1["palette"]["ambient_rgba"] = [40, 160, 120, 14]
# low_quay takes the MUSGO look: dark loam floor, stone-grey walls, moss brighter than floor
new_lq = {
    "palette": {
        "floor": [12, 18, 12], "grid": [18, 26, 18], "wall": [98, 108, 92],
        "transition": [235, 190, 90], "station": [190, 140, 60], "station_seal": [190, 140, 60],
        "moss": [30, 66, 34], "dirt": [40, 34, 24], "sand": [70, 62, 44],
        "grass": [34, 72, 38], "grass_b": [28, 62, 34], "grass_c": [40, 80, 46],
        "wood": [62, 54, 44], "water": [16, 40, 60], "wall_inner": [120, 130, 112],
        "motif": "ripple", "motif_rgb": [20, 34, 22], "ambient_rgba": [60, 160, 80, 12]
    },
    "tile_size": 32,
    "gradient_anchor": [MOSS_ENTRY[0], MOSS_ENTRY[1]],
    # v11 depth rider, the medusa's bands carried (3.0 / 3.5 / 4.0): entry hall
    # -> spine -> the vault pays max (walk distance from the west door).
    "drop_gradient": [[0, 3.0], [20, 3.5], [40, 4.0]],
    "decor": [
        {"kind": "stain", "at": [22, 12], "w": 4, "h": 2, "rgb": [22, 48, 26], "alpha": 90},
        {"kind": "stain", "at": [36, 14], "w": 6, "h": 2, "rgb": [22, 48, 26], "alpha": 90},
        {"kind": "stain", "at": [40, 22], "w": 4, "h": 3, "rgb": [22, 48, 26], "alpha": 90},
        {"kind": "edge", "at": [35, 10], "w": 13, "rgb": [140, 150, 130], "alpha": 90},
        {"kind": "ambience", "at": [36, 10], "preset": "torch_flicker"},
        {"kind": "ambience", "at": [46, 10], "preset": "torch_flicker"},
        {"kind": "ambience", "at": [36, 26], "preset": "torch_flicker"},
        {"kind": "ambience", "at": [46, 26], "preset": "torch_flicker"}
    ],
    "ambience_regions": [
        {"id": "spore_haze", "rect": [0, 0, MW, MH], "intent": "dungeon",
         "ambience": "spore_drift", "ambience_density": 0.06, "ambience_tiles": ["m", "."]},
        {"id": "vault_shafts", "rect": [34, 10, 15, 17], "intent": "dungeon",
         "ambience": "light_shafts", "ambience_density": 0.10, "ambience_tiles": ["m", "."]}
    ]
}
sc_d1_path.write_text(json.dumps(new_d1, indent=2) + "\n", encoding="utf-8", newline="\n")
sc_lq_path.write_text(json.dumps(new_lq, indent=2) + "\n", encoding="utf-8", newline="\n")
print("sidecars rewritten: dungeon_1 <- medusa look; low_quay <- MUSGO look (+torches in the vault, spore haze, light shafts)")
print("\nDEVIATIONS (for the ticket record):")
for d in DEV:
    print(" -", d)

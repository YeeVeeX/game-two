# v20 T7 — transcription builder: Junior's v3 concept (52x52, drawn for
# ZONE 2, BANKED FOR THE DEEPEST FLOOR by foundation L3) -> low_quay
# level spliced into authoring/pilot.ldtk + sidecar.
#
# Unlike T6b (which ported a generator), no generator exists for this
# drawing: the GRID is transcribed from the banked reference PNG itself,
# cell-per-10px-block (provenance asserted below by md5), then the CORE
# region is re-cut parametrically (same center/valence as drawn) so the
# four-door cross grammar and the boss stagings hold mechanically.
# Engine-forced deviations are applied HERE, asserted HERE, and printed
# for the ticket record (T1/T6b precedent).
#
# Registry-driven law (T5 review advisory 2): char + int_grid per type
# come from data/tiles.json at run time — no hardcoded tile maps.
#
# Run once from repo root:  py -3.12 tools/build_low_quay_v3.py
# Then import via tools/import_ldtk.rb (the only door to data/zones).
import copy
import hashlib
import json
from collections import deque

from PIL import Image

LDTK = "authoring/pilot.ldtk"
SIDECAR = "authoring/low_quay.sidecar.json"
REF = "drafts/_refs/junior-zone2-v3-medusa-lower.png"
REF_MD5 = "124155a71359c8b23c37c0dbbe183e3b"
W, H = 52, 52
CX, CY = 33, 25  # the core center: his hole = BOSS 1's post (D-HOLE)

# --- provenance ---------------------------------------------------------------
raw_png = open(REF, "rb").read()
digest = hashlib.md5(raw_png).hexdigest()
assert digest == REF_MD5, f"reference PNG drifted: {digest} != banked {REF_MD5} — STOP"

# --- transcription (his exact 10px cells; header strip is 26px tall) ----------
# drawing classes: void/bounds, roots, sand speckle, cement, cross-frame,
# hole marker, medusas, minion dots, pale dots, blue way-markers.
VOID, ROOTS, SPECK, CEMENT, XFRAME, HOLE = '%', '.', 's', 'w', 'X', 'Y'
COLOR_TO_CLASS = {
    (14, 10, 10): VOID,      # void
    (26, 14, 12): VOID,      # near-black boundary (his bounds = the abyss, D-VOID)
    (118, 78, 48): ROOTS,
    (204, 160, 92): SPECK,
    (124, 124, 130): CEMENT,
    (30, 20, 16): XFRAME,
    (246, 214, 110): HOLE,
    (255, 40, 80): 'M',      # medusa marker (entity; terrain resolves below)
    (230, 90, 60): 'm',      # minion dot
    (180, 170, 140): 'p',    # pale minion dot
    (40, 90, 160): 'T',      # blue way-marker (decor hint; terrain resolves below)
}

im = Image.open(REF).convert("RGB")
assert im.size == (520, 546), f"unexpected reference size {im.size}"
grid = [[None] * W for _ in range(H)]
marks = {'M': [], 'm': [], 'p': [], 'T': [], 'Y': []}
for gy in range(H):
    for gx in range(W):
        px = im.getpixel((gx * 10 + 5, 26 + gy * 10 + 5))
        cls = COLOR_TO_CLASS.get(px)
        assert cls is not None, f"unmapped reference color {px} at cell ({gx},{gy})"
        if cls in marks:
            marks[cls].append((gx, gy))
            cls = ROOTS  # markers sit ON walkable ground; core repaint below
        grid[gy][gx] = cls

DEVIATIONS = []


def dev(msg):
    DEVIATIONS.append(msg)


dev("D-VOID: void + near-black bounds -> wall_inner (the second wall class is the "
    "abyss itself; zero water tiles, no ring transform needed)")

# --- the core, re-cut parametrically (D-CORE) ----------------------------------
# His grammar: cement annulus (muralha now a real WALL ring) + internal
# cross (dark walkway lanes) + center hole (the boss post plinth) + four
# ways through. Cell-exact ring liberties are taken so every staging
# below is assertable; quadrant galleries keep his medusa posts.
def e(x, y, rx, ry):
    return ((x - CX) / rx) ** 2 + ((y - CY) / ry) ** 2


for y in range(H):
    for x in range(W):
        if e(x, y, 11.0, 10.0) <= 1:      # moat belt: clear his cement spill
            grid[y][x] = VOID
for y in range(H):
    for x in range(W):
        if e(x, y, 9.5, 8.5) <= 1:
            grid[y][x] = '#' if e(x, y, 8.3, 7.3) > 1 else CEMENT
# cross arms: dark stone walkways (D-ARMS — readable bridges, never
# void-black: walkable-vs-not stays legible)
for x in range(CX - 8, CX + 9):
    if e(x, CY, 8.3, 7.3) <= 1:
        grid[CY][x] = ','
for y in range(CY - 7, CY + 8):
    if e(CX, y, 8.3, 7.3) <= 1:
        grid[y][CX] = ','
grid[CY][CX] = CEMENT  # the hole plinth: BOSS 1's post (D-HOLE)
dev("D-CORE: annulus re-cut rx/ry 9.5/8.5 (wall band to 8.3/7.3), cross arms as "
    "dirt walkways, center plinth cement")
dev(f"D-HOLE: his center hole ({CX},{CY}) = BOSS 1's post (no floor -4 exists; "
    "the abyss bottom IS the boss)")

# four doors through the muralha + their moat bridges (per-feature exits)
CARVES = {
    "W-door": [(24, 25)],
    "E-door": [(42, 25)],
    "N-door": [(33, 17)],
    "S-door": [(33, 33)],
    "N-bridge": [(33, 15), (33, 16)],           # his blue N pair marks this approach
    "E-bridge": [(43, 25), (44, 25)],
    "S-bridge": [(33, 34), (33, 35), (33, 36)],
    # D-CAUSEWAY: the west processional — his serpent<->gallery west touch
    # formalized as a row-25 walkway (the challenger approach row + the
    # seize-walk theater).
    "causeway": [(x, 25) for x in range(10, 24)],
}
for name, tiles in CARVES.items():
    for x, y in tiles:
        if grid[y][x] not in (ROOTS, SPECK, CEMENT, ','):
            grid[y][x] = ','
dev("D-CAUSEWAY: row-25 walkway carved x10-23 (west limb -> W door); N/E/S "
    "bridges carved at the arm axes (his 4-ways grammar)")

# serpent texture: root tangles (grass class, brown family) on a stable
# hash of his sand-speckle neighborhoods — deterministic, no RNG.
for y in range(H):
    for x in range(W):
        if grid[y][x] == ROOTS and (x * 7 + y * 13) % 11 == 0:
            grid[y][x] = 'g'

WALK = {ROOTS, SPECK, CEMENT, ',', 'g'}


def walkable(x, y):
    return 0 <= x < W and 0 <= y < H and grid[y][x] in WALK


# --- endpoints + entities -------------------------------------------------------
HEAD_DOOR = (9, 8)        # his entry marker at the serpent head -> slow_door
TAIL_DOOR = (23, 50)      # his drawn south exit at the tail -> zone_7 (requires_defeats 1)
ARRIVAL_HEAD = (10, 8)    # slow_door return spawn (one-line hand edit there)
ARRIVAL_TAIL = (24, 50)   # zone_7 return spawn (pilot.ldtk entity edit + re-import)
PACK_SPAWN = [(10, 8), (10, 7), (10, 9)]
BOSS = (CX, CY)
for x, y in [HEAD_DOOR, TAIL_DOOR, ARRIVAL_HEAD, ARRIVAL_TAIL] + PACK_SPAWN:
    if not walkable(x, y):
        dev(f"D-POCKET carve [{x},{y}] {grid[y][x]!r}->roots (endpoint pocket)")
        grid[y][x] = ROOTS

# the 5 medusas -> WARDENS (his posts, quadrant galleries + the N gate)
WARDENS = [(29, 21), (37, 21), (29, 29), (37, 29), (33, 19)]
# the abyss minions -> STINGERS: his 15 dots (nudged where the law bites)
# + 9 added along the coils (his doc says 20; the L6 clear-pay gradient
# prices 24 — D-FAUNA, defended in the record).
STINGER_NUDGES = {
    (22, 44): (14, 41),   # calm-entry at the tail arrival (d 6 -> 10)
    (44, 25): (45, 27),   # his dot lands on the E-bridge lane
    (24, 20): (22, 18),   # moat repaint swallowed the tile
    (30, 15): (30, 14),   # moat repaint swallowed the tile
    (40, 17): (41, 16),   # moat repaint swallowed the tile
    (29, 32): (29, 31),   # moat repaint swallowed the tile
}
STINGERS = []
for t in marks['m'] + marks['p']:
    t = STINGER_NUDGES.get(t, t)
    STINGERS.append(t)
STINGERS += [(26, 9), (41, 8), (46, 19), (46, 30), (40, 37), (33, 40),
             (24, 41), (12, 33), (8, 25)]
for old, new in STINGER_NUDGES.items():
    dev(f"D-CALM/D-FAUNA: stinger {old} -> {new}")

occupied = set()
for t in STINGERS + WARDENS + [BOSS]:
    assert walkable(*t), f"enemy tile {t} not walkable"
    assert t not in occupied, f"enemy tile {t} collides"
    occupied.add(t)

# --- law asserts ----------------------------------------------------------------
def bfs(starts):
    seen = {s for s in starts if walkable(*s)}
    q = deque(seen)
    while q:
        x, y = q.popleft()
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                if (dx, dy) == (0, 0):
                    continue
                t = (x + dx, y + dy)
                if t not in seen and walkable(*t):
                    seen.add(t)
                    q.append(t)
    return seen


reach = bfs([ARRIVAL_HEAD])
for t in STINGERS + WARDENS + [BOSS, HEAD_DOOR, TAIL_DOOR, ARRIVAL_TAIL] + PACK_SPAWN:
    assert t in reach, f"unreachable from the head arrival: {t}"

# per-feature exit law (T6b's F2 lesson, project memory): every door,
# bridge and the causeway must reach open ground on BOTH sides.
FEATURE_EXITS = {
    "W-door": [(23, 25), (25, 25)],
    "E-door": [(41, 25), (43, 25)],
    "N-door": [(33, 16), (33, 18)],
    "S-door": [(33, 32), (33, 34)],
    "N-bridge-far": [(33, 14)],
    "E-bridge-far": [(45, 25), (45, 26)],
    "S-bridge-far": [(33, 37)],
    "causeway-west": [(9, 25), (14, 25)],
    "tail-pocket": [(23, 49), (24, 49)],
}
for name, tiles in FEATURE_EXITS.items():
    for t in tiles:
        assert walkable(*t) and t in reach, f"feature exit {name} {t} not open/reachable"

# staging battery: every test-staged coordinate is part of the zone's
# contract (record section 5) — geometry reshapes before a test weakens.
STAGING = {
    "return-up gate": [HEAD_DOOR],
    "slow_door arrival": [ARRIVAL_HEAD],
    "boss post + adjacency": [BOSS, (32, 25), (34, 25), (33, 24), (33, 26)],
    "approach row (dist 1..13)": [(CX - d, CY) for d in range(1, 14)],
    "dread possessed (30,25)": [(30, 25)],
    "chant-pin park (20,25)": [(20, 25)],
    "far teleport (23,49)": [(23, 49)],
    "parked allies (5,20..22)": [(5, 20), (5, 21), (5, 22)],
    "seats trio (26/28/12/11,25)": [(26, 25), (28, 25), (12, 25), (11, 25)],
    "provocation +2 (12,8)": [(12, 8)],
    "gradient probes": [(12, 8), (33, 25), (24, 50)],
}
for name, tiles in STAGING.items():
    for t in tiles:
        assert walkable(*t) and t in reach, f"staging {name}: {t} not walkable/reachable"

# calm-entry law at both arrivals (minions; the BOSS is the exempted,
# intended exception — challenge machinery asserted at d>=10 instead).
def cheb(a, b):
    return max(abs(a[0] - b[0]), abs(a[1] - b[1]))


STINGER_AGGRO, WARDEN_AGGRO = 8, 7
for door in (ARRIVAL_HEAD, ARRIVAL_TAIL):
    for t in STINGERS:
        assert cheb(t, door) >= STINGER_AGGRO + 1, f"stinger {t} hot at {door} (d={cheb(t, door)})"
    for t in WARDENS:
        assert cheb(t, door) >= WARDEN_AGGRO + 1, f"warden {t} hot at {door} (d={cheb(t, door)})"
    assert cheb(BOSS, door) >= 10, f"arrival {door} inside the challenge theater"

# zero water; the abyss is wall-class (D-VOID)
assert not any(grid[y][x] == '~' for y in range(H) for x in range(W)), "water leaked in"

# entity/tile overlap (arrivals may share pockets; entities may not)
ents_at = PACK_SPAWN + STINGERS + WARDENS + [BOSS]
assert len(set(ents_at)) == len(ents_at), "entity tile overlap"
assert BOSS not in PACK_SPAWN

# --- registry-driven char/int maps (T5 review advisory 2) -----------------------
TILES = json.load(open("data/tiles.json"))["types"]
CLASS_TO_TYPE = {
    VOID: "wall_inner",
    '#': "wall",
    ROOTS: "floor",
    SPECK: "sand",
    'g': "grass",
    ',': "dirt",
    CEMENT: "wood",
}
missing = {t for t in CLASS_TO_TYPE.values() if t not in TILES}
assert not missing, f"data/tiles.json lacks types {missing} — registry-driven law"
char_grid = [[TILES[CLASS_TO_TYPE[grid[y][x]]]["char"] for x in range(W)] for y in range(H)]
csv = [TILES[CLASS_TO_TYPE[grid[y][x]]]["int_grid"] for y in range(H) for x in range(W)]

# --- palette (sidecar) + luma law table ------------------------------------------
def luma(c):
    return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]


PALETTE = {
    "floor": [30, 24, 20],          # roots: darkest floor of the trilogy
    "grid": [40, 33, 28],
    "wall": [128, 134, 148],        # the muralha: pale cold stone
    "wall_inner": [10, 12, 22],     # THE ABYSS: near-black blue (D-VOID/D-PALETTE)
    "transition": [235, 190, 90],
    "dirt": [46, 50, 66],           # cross arms + causeway: dark cold walkways
    "sand": [78, 64, 42],           # his tan speckles, abyss-dimmed
    "grass": [44, 34, 26],          # root tangles (no green at -3)
    "grass_b": [38, 29, 22],
    "grass_c": [50, 40, 30],
    "wood": [88, 90, 100],          # cement gallery + plinth
    "motif": "ripple",
    "motif_rgb": [40, 34, 32],
    "ambient_rgba": [56, 90, 190, 16],
}
spread = luma(PALETTE["wall"]) - luma(PALETTE["floor"])
assert spread >= 40, f"wall/floor luma spread {spread:.1f} < 40"
m = luma(PALETTE["motif_rgb"])
assert luma(PALETTE["floor"]) < m < (luma(PALETTE["floor"]) + luma(PALETTE["wall"])) / 2, "motif law"
assert 0 < PALETTE["ambient_rgba"][3] <= 24, "ambient law"
assert luma(PALETTE["floor"]) < 30.4, "deeper=darker: -3 floor must undercut -2's 30.4 luma"
dev("D-PALETTE: his near-black lands on the VOID (wall_inner, no luma law); "
    f"palette.wall obeys the >=40 spread instead (spread {spread:.1f})")

SIDECAR_BODY = {
    "palette": PALETTE,
    "tile_size": 32,
    "drop_gradient": [[0, 3.0], [17, 3.5], [34, 4.0]],
    "gradient_anchor": list(ARRIVAL_HEAD),
    "decor": [
        {"kind": "edge", "at": [10, 24], "w": 14, "rgb": [70, 110, 190], "alpha": 70},
        {"kind": "edge", "at": [10, 26], "w": 14, "rgb": [70, 110, 190], "alpha": 70},
        {"kind": "edge", "at": [27, 16], "w": 13, "rgb": [150, 155, 170], "alpha": 60},
        {"kind": "stain", "at": [31, 13], "w": 4, "h": 2, "rgb": [40, 90, 160], "alpha": 80},
        {"kind": "stain", "at": [40, 33], "w": 3, "h": 3, "rgb": [40, 90, 160], "alpha": 80},
        {"kind": "stain", "at": [28, 20], "w": 3, "h": 2, "rgb": [16, 18, 30], "alpha": 80},
        {"kind": "stain", "at": [35, 28], "w": 3, "h": 2, "rgb": [16, 18, 30], "alpha": 80},
        {"kind": "stain", "at": [7, 6], "w": 3, "h": 2, "rgb": [20, 26, 40], "alpha": 80},
    ],
}
for d in SIDECAR_BODY["decor"]:
    tx, ty = d["at"]
    assert 0 <= tx and 0 <= ty and tx + d.get("w", 1) <= W and ty + d.get("h", 1) <= H, \
        f"decor {d} spans off-map"

# --- LDtk splice -----------------------------------------------------------------
raw = open(LDTK, "rb").read()
doc = json.loads(raw)
formatted = (json.dumps(doc, indent=2, ensure_ascii=False) + "\n").replace("\n", "\r\n").encode("utf-8")
assert formatted == raw, "pilot.ldtk byte-format drifted from json.dumps(indent=2)+CRLF — STOP"

SERIAL = [0]


def iid():
    SERIAL[0] += 1
    return f"00000000-d157-0003-0000-{SERIAL[0]:012d}"


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


def transition(gx, gy, to, spawn, requires_defeats=None):
    return entity("Transition", 11, "#5AC8EB", gx, gy, [
        fi("to", "String", to, 110),
        fi("spawn", "Point", {"cx": spawn[0], "cy": spawn[1]}, 111),
        fi("sealed", "Bool", False, 112),
        fi("type", "String", None, 113),
        fi("stairs_unlocked_by", "String", None, 114),
        fi("requires_defeats", "Int", requires_defeats, 115),
        fi("requires_level", "Int", None, 116),
    ])


ents = []
for i, (gx, gy) in enumerate(PACK_SPAWN):
    ents.append(entity("PackSpawn", 12, "#6BEB5A", gx, gy, [fi("order", "Int", i, 120)]))
ents.append(transition(*HEAD_DOOR, "slow_door", (7, 2)))
ents.append(transition(*TAIL_DOOR, "zone_7", (2, 14), requires_defeats=1))
for gx, gy in STINGERS:
    ents.append(entity("EnemySpawn", 13, "#EB5A5A", gx, gy, [fi("kind", "String", "stinger", 130)]))
for gx, gy in WARDENS:
    ents.append(entity("EnemySpawn", 13, "#EB5A5A", gx, gy, [fi("kind", "String", "warden", 130)]))
ents.append(entity("EnemySpawn", 13, "#EB5A5A", *BOSS, [fi("kind", "String", "challenger", 130)]))

assert all(l["identifier"] != "low_quay" for l in doc["levels"]), "low_quay already in pilot.ldtk"
tmpl = next(l for l in doc["levels"] if l["identifier"] == "district")
level = copy.deepcopy(tmpl)
level["identifier"] = "low_quay"
level["iid"] = iid()
level["uid"] = doc["nextUid"]
doc["nextUid"] += 1
level["pxWid"], level["pxHei"] = W * 32, H * 32
for f in level["fieldInstances"]:
    v = {"display_name": "ZONE 5", "floor": -3, "hub": False, "safe": False}[f["__identifier"]]
    f["__value"] = v
    f["realEditorValues"] = [{"id": f"V_{f['__type']}", "params": [v]}]
for li in level["layerInstances"]:
    li["__cWid"], li["__cHei"] = W, H
    li["iid"] = iid()
    li["levelId"] = level["uid"]
    if li["__identifier"] == "Terrain":
        li["intGridCsv"] = csv
        li["entityInstances"] = []
    else:
        li["entityInstances"] = ents
        li["intGridCsv"] = li.get("intGridCsv", [])
doc["levels"].append(level)

# zone_7's return row into low_quay re-lands at the tail arrival (the
# pilot emission moves in exactly this row — T6b district-hole precedent)
zone_7 = next(l for l in doc["levels"] if l["identifier"] == "zone_7")
for li in zone_7["layerInstances"]:
    for ei in li.get("entityInstances", []):
        if ei["__identifier"] != "Transition":
            continue
        fis = {f["__identifier"]: f for f in ei["fieldInstances"]}
        if fis["to"]["__value"] == "low_quay":
            fis["spawn"]["__value"] = {"cx": ARRIVAL_TAIL[0], "cy": ARRIVAL_TAIL[1]}
            fis["spawn"]["realEditorValues"] = [{"id": "V_String",
                                                 "params": [f"{ARRIVAL_TAIL[0]},{ARRIVAL_TAIL[1]}"]}]
            dev(f"zone_7 return spawn [43,19] -> {list(ARRIVAL_TAIL)} (pilot emission moves in exactly this row)")

out = (json.dumps(doc, indent=2, ensure_ascii=False) + "\n").replace("\n", "\r\n").encode("utf-8")
open(LDTK, "wb").write(out)
open(SIDECAR, "w", newline="\n").write(json.dumps(SIDECAR_BODY, indent=2) + "\n")

# --- report ----------------------------------------------------------------------
counts = {}
for y in range(H):
    for x in range(W):
        counts[CLASS_TO_TYPE[grid[y][x]]] = counts.get(CLASS_TO_TYPE[grid[y][x]], 0) + 1
n_walk = sum(1 for y in range(H) for x in range(W) if walkable(x, y))
print(f"grid {W}x{H} walkable={n_walk} " + " ".join(f"{k}={v}" for k, v in sorted(counts.items())))
print(f"BFS OK: boss post + both doors + all {len(STINGERS) + len(WARDENS) + 1} enemies + "
      f"every staging tile reachable from {ARRIVAL_HEAD}")
print("zero water tiles: OK (the abyss is wall_inner)")
print(f"per-feature exits OK: {', '.join(FEATURE_EXITS)}")
print(f"enemies={len(STINGERS) + len(WARDENS) + 1} (stinger {len(STINGERS)} / warden {len(WARDENS)} "
      f"/ challenger 1) pack_spawn={len(PACK_SPAWN)}")
print(f"calm-entry: minions >= aggro+1 from arrivals {ARRIVAL_HEAD} and {ARRIVAL_TAIL}; "
      f"boss d>=10 from both")
print(f"luma: floor {luma(PALETTE['floor']):.1f} wall {luma(PALETTE['wall']):.1f} "
      f"(spread {spread:.1f}) void {luma(PALETTE['wall_inner']):.1f} "
      f"gallery {luma(PALETTE['wood']):.1f}")
print("DEVIATIONS:")
for d in DEVIATIONS:
    print(" -", d)

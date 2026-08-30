# v20 T6b — transcription builder: Junior's FLOOR -2 v3 "FIEHONJA" concept ->
# district_two level spliced into authoring/pilot.ldtk + sidecar.
# Transcription, not invention: the GRID is reproduced by porting Junior's own
# deterministic generator (drafts/_refs/junior-floor2-v3-fiehonja-gen.py,
# seed 7734, PNG md5 9e3d6da20e41801dd0b507fad37f6bb3) verbatim through the
# content constants, then mapping his classes onto engine tile types.
# Engine-forced deviations are applied HERE, asserted HERE, and printed for
# the ticket record (T1 build_district_v2b.py precedent).
#
# Registry-driven law (T5 review advisory 2): char + int_grid per type come
# from data/tiles.json at run time — this script hardcodes NO tile maps.
#
# Run once from repo root:  py -3.12 tools/build_district_two_v3.py
# Then import via tools/import_ldtk.rb (the only door to data/zones).
import copy
import json
import math
import random
from collections import deque

random.seed(7734)

LDTK = "authoring/pilot.ldtk"
SIDECAR = "authoring/district_two.sidecar.json"
W, H = 88, 44

# --- Junior's generator, verbatim (grid construction only) -------------------
ROCK, SEABED, SAND, BANK, CHANNEL, ALGAE, REEF, RFLOOR, RWALL = \
    '#', ',', '.', 'g', '~', 'a', 'R', 'f', 'X'
WALK = {SEABED, SAND, BANK, ALGAE, RFLOOR}

grid = [[None] * W for _ in range(H)]

def carve_blob(cx, cy, r, theme='plain'):
    wob = [random.uniform(0.72, 1.26) for _ in range(14)]
    pts = []
    for y in range(max(2, cy - r - 2), min(H - 2, cy + r + 3)):
        for x in range(max(2, cx - r - 3), min(W - 2, cx + r + 4)):
            a = math.atan2(y - cy, x - cx)
            k = int(((a + math.pi) / (2 * math.pi)) * 14) % 14
            if math.hypot((x - cx) * 0.82, (y - cy) * 1.18) <= r * wob[k] * random.uniform(0.95, 1.05):
                if grid[y][x] is None:
                    grid[y][x] = SEABED
                pts.append((x, y))
    random.shuffle(pts)
    if theme == 'banks':
        for x, y in pts[: len(pts) // 6]:
            if grid[y][x] == SEABED:
                grid[y][x] = BANK
    for x, y in pts[int(len(pts) * 0.8):]:
        if grid[y][x] == SEABED:
            grid[y][x] = SAND
    return pts

PLATEAU = [
    (10, 22, 8, 'plain'),
    (12, 7,  7, 'plain'),
    (20, 14, 11, 'plain'),
    (36, 22, 9, 'plain'),
    (46, 12, 10, 'plain'),
    (30, 30, 10, 'banks'),
    (46, 32, 9, 'banks'),
    (62, 14, 10, 'plain'),
    (66, 32, 11, 'plain'),
    (76, 22, 9, 'plain'),
]
for b in PLATEAU:
    carve_blob(*b)

def algae_field(cx, cy, r):
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r - 1, cx + r + 2):
            if 2 <= x < W - 2 and 2 <= y < H - 2 and grid[y][x] in (SEABED, SAND):
                if math.hypot((x - cx) * 0.8, (y - cy) * 1.15) <= r * random.uniform(0.75, 1.1):
                    grid[y][x] = ALGAE

for f in ((24, 10, 5), (52, 12, 4), (26, 30, 4), (72, 14, 4), (40, 27, 3)):
    algae_field(*f)

RX0, RY0, RX1, RY1 = 5, 4, 17, 11
for y in range(RY0, RY1 + 1):
    for x in range(RX0, RX1 + 1):
        border = x in (RX0, RX1) or y in (RY0, RY1)
        grid[y][x] = RWALL if border else RFLOOR
for x in (10, 11, 12):
    grid[RY1][x] = RFLOOR

def carve_path(ax, ay, bx, by, width=3, tile=SAND, over=(None,)):
    x, y = ax, ay
    while (x, y) != (bx, by):
        if x != bx and (y == by or random.random() < 0.6):
            x += 1 if bx > x else -1
        elif y != by:
            y += 1 if by > y else -1
        for d in range(-(width // 2), width - width // 2):
            for px, py in ((x, y + d), (x + d, y)):
                if 2 <= px < W - 2 and 2 <= py < H - 2 and grid[py][px] in over:
                    grid[py][px] = tile

carve_path(11, RY1 + 1, 13, 16, 2)

RCX, RCY = 67, 33
for y in range(RCY - 8, RCY + 8):
    for x in range(RCX - 11, RCX + 12):
        if not (2 <= x < W - 2 and 2 <= y < H - 2):
            continue
        dx, dy = x - RCX, y - RCY
        e_out = (dx / 9.5) ** 2 + (dy / 6.5) ** 2
        e_in  = (dx / 6.0) ** 2 + (dy / 3.8) ** 2
        ang = math.degrees(math.atan2(-dy, dx)) % 360
        if e_out <= 1 and e_in > 1:
            if 115 <= ang <= 160:
                continue
            grid[y][x] = REEF
        elif e_in <= 1:
            grid[y][x] = ALGAE if (x + y) % 3 else SAND

def channel_line(pts, rad=1):
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        steps = max(abs(bx - ax), abs(by - ay)) * 3
        for i in range(steps + 1):
            t = i / steps
            x = ax + (bx - ax) * t + math.sin(t * 9) * 0.8
            y = ay + (by - ay) * t
            for dy in range(-rad, rad + 1):
                for dx in range(-rad, rad + 1):
                    px, py = int(x) + dx, int(y) + dy
                    if 2 <= px < W - 2 and 1 <= py < H - 2 and abs(dx) + abs(dy) <= rad + 1:
                        if grid[py][px] not in (REEF, RWALL, RFLOOR):
                            grid[py][px] = CHANNEL

channel_line([(44, 1), (43, 8), (46, 14), (43, 20), (45, 26)])
channel_line([(45, 26), (38, 31), (28, 35), (18, 39)])
channel_line([(45, 26), (52, 30), (59, 30)])

ENTRY = (2, 22)
# (fords + exit path move BELOW the engine transforms — deviations D-RING/D-SEAL;
# Junior's own random stream is exhausted before this point except carve_path
# calls, which we keep in his original ORDER so the stream stays identical.)
def ford(x0, x1, y0, y1):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if grid[y][x] == CHANNEL:
                grid[y][x] = SAND

# --- engine transforms (deviations, named) -----------------------------------
DEVIATIONS = []

def dev(msg):
    DEVIATIONS.append(msg)

# D-RING 1/3: dilate the channel by 1 (4-adjacency) into walkable so a >=1-tile
# water core survives the coral ring (the blue channel IS the signature).
dilate = []
for y in range(H):
    for x in range(W):
        if grid[y][x] in WALK and any(
                0 <= x + dx < W and 0 <= y + dy < H and grid[y + dy][x + dx] == CHANNEL
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
            dilate.append((x, y))
for x, y in dilate:
    grid[y][x] = CHANNEL
dev(f"D-RING: channel dilated +1 into {len(dilate)} walkable tiles (water core survives the ring)")

# D-RING 2/3: fords re-cut on the dilated channel — crossing-axis span expanded
# by 1 so each lane fully crosses the wider barrier; lane width kept EXACT.
ford(40, 48, 10, 12)      # F1 north (x-crossing, x-expanded; y10-12 — clears the y13 seal-door row, D-SEAL)
ford(40, 49, 21, 23)      # F2 main route + guardian (x-crossing, x-expanded)
ford(26, 28, 32, 37)      # F3 SW arm (y-crossing, y-expanded)
ford(55, 57, 27, 32)      # F4 reef gap (y-crossing, y-expanded; risky by design)
dev("D-RING: fords re-cut with crossing-axis +1 spans (F1 x40-48/y10-12, F2 x40-49/y21-23, F3 x26-28/y32-37, F4 x55-57/y27-32)")

# Junior's entry/exit approach paths (his order, after fords in his gen).
EXIT_ = (85, 24)
carve_path(*ENTRY, 10, 22, 3)
carve_path(76, 22, *EXIT_, 3)

# D-ROAD: F2's east mouth dead-ends into the inter-plateau rock neck (a gen
# artifact — Junior's BFS proved GLOBAL reachability, never per-ford exits;
# his coral-route waypoints (48,22)→(56,21) draw the main road straight
# east). Carve the road 3-wide through the neck to the east plateau.
for y in (21, 22, 23):
    for x in range(47, 57):
        if grid[y][x] not in WALK and grid[y][x] != CHANNEL:
            grid[y][x] = SAND
dev("D-ROAD: main-route neck carved 3-wide (x47-56, y21-23) — F2's east mouth joins the east plateau")

# D-FORD3: F3's lane bottom (26,37) abuts the arm-tail rim — join it to the
# south strip so the crossing LOOPS (2 tiles; Junior's "4 travessias").
for x, y in [(27, 38), (28, 38)]:
    grid[y][x] = SAND
dev("D-FORD3: south mouth joined to the coral-alley strip ([27,38],[28,38])")

# rim + solid fill (his pass, verbatim)
for y in range(H):
    for x in range(W):
        if grid[y][x] is None:
            near = any(0 <= y + dy < H and 0 <= x + dx < W and grid[y + dy][x + dx] in WALK
                       for dy in (-1, 0, 1) for dx in (-1, 0, 1))
            grid[y][x] = ROCK if near else 'SOLID'

# D-SEAL: the live shared chain carries breached ["district_two",[42,13]] —
# the strict decoder pins the seal station [41,13] + sealed door [42,13]
# byte-identical (T1 save-law precedent). Junior's east exit (85,24) yields
# to the pinned door: a door row carved at y13, x37-42, opening west, one
# row SOUTH of ford F1's lane (y10-12) so the crossing never pinches; the
# coral-ring pass below walls the door's east side ((43,13) stays channel
# until the ring converts it). slow_door's return spawn [40,13] keeps
# working with ZERO slow_door.json edit.
POCKET_WALK = [(37, 13), (38, 13), (39, 13), (40, 13), (41, 13), (42, 13)]
for x, y in POCKET_WALK:
    if grid[y][x] not in WALK:
        dev(f"D-SEAL carve [{x},{y}] {grid[y][x]!r}->seabed (door row)")
        grid[y][x] = SEABED

# D-ENTRY: west mouth — transition tile [0,22] + arrival pocket (the camp edge
# arrival AND the -1 hole landing both land [1,22]; 3-body pack room).
for x, y in [(0, 22)]:
    dev(f"D-ENTRY carve [{x},{y}] {grid[y][x]!r}->seabed (west door tile)")
    grid[y][x] = SEABED
for x, y in [(1, 21), (1, 22), (1, 23), (2, 21), (2, 22), (2, 23), (3, 21), (3, 22), (3, 23)]:
    if grid[y][x] not in WALK:
        dev(f"D-ENTRY carve [{x},{y}] {grid[y][x]!r}->seabed (entry pocket)")
        grid[y][x] = SEABED

# D-RING 3/3: coral ring — every channel tile 8-adjacent to a walkable tile
# becomes REEF (wall_inner): "coral VERMELHO nas margens do canal (a
# assinatura de Fiehonja)" made mechanical. Water stays passability-floor
# engine-wide; the ring makes every water tile unreachable (8-adjacency,
# diagonal steps included).
ring = []
for y in range(H):
    for x in range(W):
        if grid[y][x] == CHANNEL and any(
                0 <= x + dx < W and 0 <= y + dy < H and grid[y + dy][x + dx] in WALK
                for dx in (-1, 0, 1) for dy in (-1, 0, 1) if (dx, dy) != (0, 0)):
            ring.append((x, y))
for x, y in ring:
    grid[y][x] = REEF
dev(f"D-RING: coral ring on {len(ring)} channel-margin tiles (wall_inner)")

# --- content (Junior's constants; calm-entry nudges named) --------------------
# D-CALM: pack (36,17) sits Chebyshev 4 from the slow_door return spawn
# [40,13] — lurker aggro 6 demands d>=7 for every member (spread +-1), so the
# pack center moves to (32,20) (T1 SPAWN_NUDGES precedent).
PACKS = [(18, 12, 4), (28, 8, 3), (32, 20, 4), (24, 26, 3), (30, 28, 4),
         (52, 8, 3), (58, 18, 4), (70, 12, 3), (76, 28, 3)]
dev("D-CALM: pack center (36,17)->(32,20) (calm-entry law at [40,13], lurker aggro 6)")
GUARD_FORD = (44, 22)
MEDUSAS = [(64, 31), (69, 30), (66, 35), (71, 34), (67, 32)]

def walkable(x, y):
    return 0 <= x < W and 0 <= y < H and grid[y][x] in WALK

OFFS = [(0, 0), (1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (-1, -1), (1, -1), (-1, 1),
        (2, 0), (0, 2), (-2, 0), (0, -2), (2, 1), (1, 2), (-2, -1), (-1, -2)]
occupied = set()
lurkers = []
for cx, cy, n in PACKS:
    placed = 0
    for dx, dy in OFFS:
        if placed == n:
            break
        t = (cx + dx, cy + dy)
        if walkable(*t) and t not in occupied:
            lurkers.append(t)
            occupied.add(t)
            placed += 1
    assert placed == n, f"pack at ({cx},{cy}) could not place {n} members"
wardens = []
for t in MEDUSAS + [GUARD_FORD]:
    assert walkable(*t), f"warden tile {t} not walkable"
    assert t not in occupied, f"warden tile {t} collides"
    wardens.append(t)
    occupied.add(t)

PACK_SPAWN = [(2, 22), (2, 21), (2, 23)]
SEAL_AT, SEAL_OPENS = (41, 13), (42, 13)
WEST_DOOR = (0, 22)
ARRIVAL_WEST = (1, 22)      # camp edge arrival + the -1 hole landing
ARRIVAL_EAST = (40, 13)     # slow_door return spawn (byte-identical row)
HEART = (RCX, RCY)
RUIN = (11, 8)

for t in PACK_SPAWN + [SEAL_AT, SEAL_OPENS, WEST_DOOR, ARRIVAL_WEST, ARRIVAL_EAST]:
    assert walkable(*t), f"required tile not walkable: {t}"
    assert t not in occupied, f"required tile occupied by a spawn: {t}"

# --- law asserts --------------------------------------------------------------
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

reach = bfs([ARRIVAL_WEST])
for t in lurkers + wardens + PACK_SPAWN + [SEAL_AT, SEAL_OPENS, WEST_DOOR, ARRIVAL_EAST, HEART, RUIN]:
    assert t in reach, f"unreachable from the west arrival: {t}"

# per-ford exit law (the F2 dead-end lesson): each ford's far mouth must
# reach open ground, not a pocket.
FORD_EXITS = {"F1-east": (50, 11), "F2-east": (52, 22), "F3-south": (29, 38), "F4-south": (56, 33)}
for name, t in FORD_EXITS.items():
    assert walkable(*t) and t in reach, f"ford exit {name} {t} not open/reachable"

# water unreachable under 8-adjacency (diagonal steps exist in the engine)
for y in range(H):
    for x in range(W):
        if grid[y][x] == CHANNEL:
            assert not any(0 <= x + dx < W and 0 <= y + dy < H and (x + dx, y + dy) in reach
                           for dx in (-1, 0, 1) for dy in (-1, 0, 1)), \
                f"water reachable at ({x},{y}) — ring broken"

# calm-entry law: nearest hostile outside aggro+1 of every arrival
def cheb(a, b):
    return max(abs(a[0] - b[0]), abs(a[1] - b[1]))

LURKER_AGGRO, WARDEN_AGGRO = 6, 7
for door in (ARRIVAL_WEST, ARRIVAL_EAST):
    for t in lurkers:
        assert cheb(t, door) >= LURKER_AGGRO + 1, f"lurker {t} hot at {door} (d={cheb(t, door)})"
    for t in wardens:
        assert cheb(t, door) >= WARDEN_AGGRO + 1, f"warden {t} hot at {door} (d={cheb(t, door)})"

# ford lane widths (walkable cross-section at the crossing line)
def lane_width(tiles):
    return sum(1 for t in tiles if walkable(*t))

F1 = lane_width([(44, y) for y in (10, 11, 12)])
F2 = lane_width([(44, y) for y in (21, 22, 23)])
F3 = lane_width([(x, 34) for x in (26, 27, 28)])
F4 = lane_width([(x, 29) for x in (55, 56, 57)])
assert F1 >= 2 and F2 >= 3 and F3 >= 2 and F4 >= 2, (F1, F2, F3, F4)

# entity tile overlap (arrivals may share the pocket; entities may not)
ents_at = PACK_SPAWN + lurkers + wardens + [SEAL_AT, SEAL_OPENS, WEST_DOOR]
assert len(set(ents_at)) == len(ents_at), "entity tile overlap"

# --- registry-driven char/int maps (T5 review advisory 2) ----------------------
TILES = json.load(open("data/tiles.json"))["types"]
def t_char(tid):
    return TILES[tid]["char"]
def t_int(tid):
    return TILES[tid]["int_grid"]

CLASS_TO_TYPE = {
    ROCK: "wall", 'SOLID': "wall", RWALL: "wall",
    REEF: "wall_inner",
    CHANNEL: "water",
    SEABED: "floor",
    SAND: "dirt",
    BANK: "sand",
    ALGAE: "grass",
    RFLOOR: "wood",
}
missing = {t for t in CLASS_TO_TYPE.values() if t not in TILES}
assert not missing, f"data/tiles.json lacks types {missing} — add them first (registry-driven law)"

char_grid = [[t_char(CLASS_TO_TYPE[grid[y][x]]) for x in range(W)] for y in range(H)]
csv = [t_int(CLASS_TO_TYPE[grid[y][x]]) for y in range(H) for x in range(W)]

# D-RUIN honesty line (mapping, not a carve)
dev("D-RUIN: ruin masonry (RWALL) maps to boundary wall '#' — one inner-wall color per zone and the reef owns it")
dev(f"D-SEAL: east exit (85,24) has NO transition; seal pinned at {SEAL_AT}/{SEAL_OPENS} (save law)")

# --- LDtk splice ---------------------------------------------------------------
raw = open(LDTK, "rb").read()
doc = json.loads(raw)
formatted = (json.dumps(doc, indent=2, ensure_ascii=False) + "\n").replace("\n", "\r\n").encode("utf-8")
assert formatted == raw, "pilot.ldtk byte-format drifted from json.dumps(indent=2)+CRLF — STOP"

# defs.intGridValues gains every tiles.json int_grid the defs lack (editor
# sanity; the importer reads the registry, not the defs). Colors mirror the
# sidecar palette.
DEF_COLORS = {"wall_inner": "#96481C", "sand": "#564C34"}
iv = next(l for l in doc["defs"]["layers"] if l["__type"] == "IntGrid")["intGridValues"]
have = {v["value"] for v in iv}
for tid, spec in sorted(TILES.items(), key=lambda kv: kv[1]["int_grid"]):
    if spec["int_grid"] not in have:
        iv.append({"value": spec["int_grid"], "identifier": tid,
                   "color": DEF_COLORS.get(tid, "#888888"), "tile": None, "groupUid": 0})
        dev(f"defs: intGridValue {spec['int_grid']} ({tid}) added")

SERIAL = [0]
def iid():
    SERIAL[0] += 1
    return f"00000000-d157-0002-0000-{SERIAL[0]:012d}"

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

def transition(gx, gy, to, spawn, sealed=False, ttype=None):
    return entity("Transition", 11, "#5AC8EB", gx, gy, [
        fi("to", "String", to, 110),
        fi("spawn", "Point", {"cx": spawn[0], "cy": spawn[1]}, 111),
        fi("sealed", "Bool", sealed, 112),
        fi("type", "String", ttype, 113),
        fi("stairs_unlocked_by", "String", None, 114),
        fi("requires_defeats", "Int", None, 115),
        fi("requires_level", "Int", None, 116),
    ])

station_color = "#EB8ADF"
for lvl in doc["levels"]:
    for li in lvl["layerInstances"]:
        for ei in li.get("entityInstances", []):
            if ei["__identifier"] == "Station":
                station_color = ei["__smartColor"]

ents = []
for i, (gx, gy) in enumerate(PACK_SPAWN):
    ents.append(entity("PackSpawn", 12, "#6BEB5A", gx, gy, [fi("order", "Int", i, 120)]))
ents.append(transition(*WEST_DOOR, "camp", (18, 5)))
ents.append(transition(*SEAL_OPENS, "slow_door", (7, 6), sealed=True))
ents.append(entity("Station", 10, station_color, *SEAL_AT, [
    fi("type", "String", "seal", 100),
    fi("price", "String", "breach_cost_2", 101),
    fi("opens", "Point", {"cx": SEAL_OPENS[0], "cy": SEAL_OPENS[1]}, 102),
    fi("line", "String", "TOLL PAID", 103),
]))
for gx, gy in lurkers:
    ents.append(entity("EnemySpawn", 13, "#EB5A5A", gx, gy, [fi("kind", "String", "lurker", 130)]))
for gx, gy in wardens:
    ents.append(entity("EnemySpawn", 13, "#EB5A5A", gx, gy, [fi("kind", "String", "warden", 130)]))

assert all(l["identifier"] != "district_two" for l in doc["levels"]), "district_two already in pilot.ldtk"
tmpl = next(l for l in doc["levels"] if l["identifier"] == "district")
level = copy.deepcopy(tmpl)
level["identifier"] = "district_two"
level["iid"] = iid()
level["uid"] = doc["nextUid"]
doc["nextUid"] += 1
level["pxWid"], level["pxHei"] = W * 32, H * 32
for f in level["fieldInstances"]:
    v = {"display_name": "ZONE 3", "floor": -2, "hub": False, "safe": False}[f["__identifier"]]
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

# the -1 -> -2 hole in the DISTRICT level re-lands at the new west arrival
district = next(l for l in doc["levels"] if l["identifier"] == "district")
for li in district["layerInstances"]:
    for ei in li.get("entityInstances", []):
        if ei["__identifier"] != "Transition":
            continue
        fis = {f["__identifier"]: f for f in ei["fieldInstances"]}
        if fis["to"]["__value"] == "district_two":
            fis["spawn"]["__value"] = {"cx": ARRIVAL_WEST[0], "cy": ARRIVAL_WEST[1]}
            fis["spawn"]["realEditorValues"] = [{"id": "V_String",
                                                 "params": [f"{ARRIVAL_WEST[0]},{ARRIVAL_WEST[1]}"]}]
            dev(f"district hole spawn [1,13] -> {list(ARRIVAL_WEST)} (pilot emission moves in exactly this row)")

out = (json.dumps(doc, indent=2, ensure_ascii=False) + "\n").replace("\n", "\r\n").encode("utf-8")
open(LDTK, "wb").write(out)

# D-PALETTE: Junior's raw seabed/rock values read FLAT under the ratified
# value-structure law (wall-floor luma spread >= 40; his PNG pair scored
# 18.4) — hues kept, values widened: floor darkened (26,30,44) (also wins
# deeper-= -darker vs floor -1's 31.3 luma), rim lightened (118,66,38).
sidecar = {
    "palette": {
        "floor": [26, 30, 44], "grid": [32, 37, 52], "wall": [118, 66, 38],
        "wall_inner": [150, 74, 28],
        "transition": [235, 190, 90], "station_seal": [190, 140, 60],
        "station": [190, 140, 60],
        "dirt": [50, 58, 74], "sand": [86, 76, 52],
        "grass": [34, 72, 48], "grass_b": [28, 64, 42], "grass_c": [40, 80, 54],
        "wood": [66, 58, 50], "water": [14, 34, 78],
        "motif": "ripple", "motif_rgb": [44, 50, 64],
        "ambient_rgba": [50, 90, 200, 18]
    },
    "tile_size": 32,
    "drop_gradient": [[0, 2.0], [29, 2.5], [58, 3.0]],
    "gradient_anchor": [1, 22]
}
open(SIDECAR, "w", newline="\n").write(json.dumps(sidecar, indent=2) + "\n")

# --- report --------------------------------------------------------------------
n_water = sum(1 for y in range(H) for x in range(W) if grid[y][x] == CHANNEL)
n_reef = sum(1 for y in range(H) for x in range(W) if grid[y][x] == REEF)
n_walk = sum(1 for y in range(H) for x in range(W) if grid[y][x] in WALK)
n_bank = sum(1 for y in range(H) for x in range(W) if grid[y][x] == BANK)
print(f"grid {W}x{H} walkable={n_walk} water={n_water} coral(wall_inner)={n_reef} bank(sand)={n_bank}")
print(f"BFS OK: seal pocket + arena heart + ruin + all spawns reachable from {ARRIVAL_WEST}")
print("water unreachable under 8-adjacency: OK")
print(f"ford lane widths: F1={F1} F2={F2} F3={F3} F4={F4} (F2 main >=3; F4 risky by design)")
print(f"enemies={len(lurkers) + len(wardens)} (lurker {len(lurkers)} / warden {len(wardens)}) pack_spawn={len(PACK_SPAWN)}")
print(f"calm-entry: all spawns >= aggro+1 from arrivals {ARRIVAL_WEST} and {ARRIVAL_EAST}")
print("DEVIATIONS:")
for d in DEVIATIONS:
    print(" -", d)

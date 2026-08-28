# v20 T1 — one-shot transcription builder: Junior's v2b reference PNG ->
# district level spliced into authoring/pilot.ldtk + district sidecar.
# Transcription, not invention: terrain/markers extracted from the ratified
# reference (git blob md5 0ba972e094bf4ed065a1470e618dd03f) at 8px/tile with
# the 26px annotation header skipped. Engine-forced deviations are applied
# HERE, asserted HERE, and printed for the ticket record.
#
# Run once from repo root:  py -3.12 tools/build_district_v2b.py
# Then import via tools/import_ldtk.rb (the only door to data/zones).
import copy
import json
import sys
from collections import Counter, deque
from PIL import Image

REF = "drafts/_refs/junior-zone2-v2b-dois-espacos-4-pontes.png"
LDTK = "authoring/pilot.ldtk"
SIDECAR = "authoring/district.sidecar.json"
COLS, ROWS, OFF, PX = 52, 88, 26, 8

TERRAIN = {
    (126, 96, 58): "#",   # tan canyon rock -> wall
    (38, 30, 20): ".",    # dark camp/grove ground -> floor
    (66, 52, 33): ",",    # trail -> dirt
    (52, 76, 40): "g",    # moss -> grass
    (168, 126, 70): "w",  # bridge -> wood
    (13, 17, 30): "~",    # chasm/pool -> water (unreachable by wall ring)
    (8, 8, 10): "~",      # chasm inner shading -> water
}
MARKERS = {(200, 80, 60): "RED", (160, 150, 120): "GREY",
           (220, 60, 90): "PINK", (235, 190, 90): "YEL",
           (140, 255, 170): "HI"}

im = Image.open(REF).convert("RGB")
assert im.size == (416, 730), im.size
px = im.load()

grid = []
marks = []
for ty in range(ROWS):
    row = []
    for tx in range(COLS):
        votes, mvotes = Counter(), Counter()
        for dy in range(PX):
            for dx in range(PX):
                p = px[tx * PX + dx, OFF + ty * PX + dy]
                if p in TERRAIN:
                    votes[TERRAIN[p]] += 1
                elif p in MARKERS:
                    mvotes[MARKERS[p]] += 1
        row.append(votes.most_common(1)[0][0] if votes else "#")
        for m, n in mvotes.items():
            if n >= 8 and m != "HI":
                marks.append((tx, ty, m))
    grid.append(row)

reds = sorted([(x, y) for x, y, m in marks if m == "RED"], key=lambda t: (t[1], t[0]))
greys = sorted([(x, y) for x, y, m in marks if m == "GREY"], key=lambda t: (t[1], t[0]))
pinks = sorted([(x, y) for x, y, m in marks if m == "PINK"], key=lambda t: (t[1], t[0]))
yels = sorted([(x, y) for x, y, m in marks if m == "YEL"], key=lambda t: (t[1], t[0]))
assert len(reds) == 16 and len(greys) == 8 and len(pinks) == 3, (len(reds), len(greys), len(pinks))
assert yels == [(40, 0), (11, 87)], yels

# Calm-entry law (old-map parity: nearest spawn sits at Chebyshev 11 from
# every door; rusher aggro_tiles = 10): two spawns sat inside aggro of the
# west door pocket — nudged within their own arena/trail (named deviations).
SPAWN_NUDGES = {(8, 12): (12, 12), (11, 20): (12, 22)}
reds = [SPAWN_NUDGES.get(t, t) for t in reds]
greys = [SPAWN_NUDGES.get(t, t) for t in greys]

DEVIATIONS = []

def carve(x, y, ch, why):
    if grid[y][x] != ch:
        DEVIATIONS.append(f"[{x},{y}] {grid[y][x]!r}->{ch!r}: {why}")
        grid[y][x] = ch

# D1: north yellow marker = the -1 -> -2 hole tile (kept faithful).
carve(40, 0, ".", "NE exit door tile (hole to district_two)")
# D2: the south yellow marker IS the descent-mouth LANDING — carved into a
# 3x2 pocket (the PNG walls it off with border rock; the engine needs the
# landing walkable + calm at Chebyshev 11 from the nearest spawn). The
# sealed camp RETURN keeps its byte-identical save-law tiles at
# [41,13]/[42,13] (the live chain's breach fact must keep matching).
for yy in (86, 87):
    for xx in (10, 11, 12):
        carve(xx, yy, ".", "south mouth-landing pocket (Junior's entry marker)")
# D3: west nest-door pocket — keeps nest/grass_fixture inbound spawn [1,13]
# passable and the legacy [1..3,12..14] staging neighborhood walkable.
carve(0, 13, ".", "nest door tile (endpoint law, row byte-identical)")
for yy in (12, 13, 14):
    for xx in (1, 2, 3):
        carve(xx, yy, "." if grid[yy][xx] == "#" else grid[yy][xx],
              "west entry pocket (nest-door approach)")

WALK = set(".,gw")

def passable(x, y):
    return 0 <= x < COLS and 0 <= y < ROWS and grid[y][x] != "#"

def walkish(x, y):
    return 0 <= x < COLS and 0 <= y < ROWS and grid[y][x] in WALK

def bfs(starts, allow):
    seen = set(s for s in starts if allow(*s))
    q = deque(seen)
    while q:
        x, y = q.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if (nx, ny) not in seen and allow(nx, ny):
                seen.add((nx, ny))
                q.append((nx, ny))
    return seen

# 3-wide corridor standard (L3, v1 mining): widen any walkable tile whose
# horizontal AND vertical free runs are both < 3 by opening floor around it.
def runlen(x, y, dx, dy):
    n = 0
    while walkish(x + dx * (n + 1), y + dy * (n + 1)):
        n += 1
    return n

def pinches():
    out = []
    for y in range(ROWS):
        for x in range(COLS):
            if not walkish(x, y):
                continue
            h = 1 + runlen(x, y, 1, 0) + runlen(x, y, -1, 0)
            v = 1 + runlen(x, y, 0, 1) + runlen(x, y, 0, -1)
            if h < 3 and v < 3:
                out.append((x, y, h, v))
    return out

for x, y, h, v in pinches():
    # widen along the longer axis by carving the rock neighbor(s) to floor
    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        nx, ny = x + dx, y + dy
        if 0 <= nx < COLS and 0 <= ny < ROWS and grid[ny][nx] == "#" and not (ny in (0, ROWS - 1) or nx in (0, COLS - 1)):
            carve(nx, ny, ".", f"3-wide corridor standard (pinch at [{x},{y}] h={h} v={v})")
            break
rest = pinches()
assert not rest, f"unresolved pinches: {rest}"

# --- law asserts -----------------------------------------------------------
pack = [(11, 87), (11, 86), (12, 87)]
seal_at, seal_opens = (41, 13), (42, 13)
hole_at = (40, 0)
nest_door = (0, 13)
landing = (11, 87)
enemies = reds + greys + pinks
for t in enemies + pack + [seal_at, seal_opens, hole_at, nest_door, landing, (1, 13), (2, 13)]:
    assert passable(*t), f"required tile impassable: {t}"

reach = bfs([landing], passable)
for t in enemies + pack + [seal_at, seal_opens, hole_at, nest_door, (1, 13)]:
    assert t in reach, f"unreachable from the mouth landing: {t}"

water = {(x, y) for y in range(ROWS) for x in range(COLS) if grid[y][x] == "~"}
assert not (water & reach), f"water reachable (wall ring broken): {sorted(water & reach)[:5]}"

# calm-entry assert: every enemy spawn sits outside aggro (10) of both doors
for door in (landing, (1, 13)):
    for t in enemies:
        d = max(abs(t[0] - door[0]), abs(t[1] - door[1]))
        assert d >= 11, f"spawn {t} hot at door {door} (d={d})"

# halves connect ONLY via bridges: remove wood, west must lose the east side
no_bridge = bfs([nest_door], lambda x, y: passable(x, y) and grid[y][x] != "w")
assert hole_at not in no_bridge and seal_opens not in no_bridge, \
    "east half reachable without bridges — chasm broken"
bridges = {(x, y) for y in range(ROWS) for x in range(COLS) if grid[y][x] == "w"}
bridge_rows = sorted({y for _, y in bridges})
assert bridge_rows == [14, 15, 34, 35, 54, 55, 74, 75], bridge_rows

# arrival geometry: landing + hole spawn-side neighbors for a 3-body pack
assert sum(passable(landing[0] + dx, landing[1] + dy)
           for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))) >= 2

occupied = pack + enemies + [seal_at, nest_door, seal_opens, hole_at]
assert len(set(occupied)) == len(occupied), "entity tile overlap"

# --- LDtk splice ------------------------------------------------------------
raw = open(LDTK, "rb").read()
doc = json.loads(raw)
formatted = (json.dumps(doc, indent=2, ensure_ascii=False) + "\n").replace("\n", "\r\n").encode("utf-8")
assert formatted == raw, "pilot.ldtk byte-format drifted from json.dumps(indent=2)+CRLF — STOP"

tmpl = next(l for l in doc["levels"] if l["identifier"] == "basement_1")
station_color = "#EB8ADF"
for lvl in doc["levels"]:
    for li in lvl["layerInstances"]:
        for ei in li.get("entityInstances", []):
            if ei["__identifier"] == "Station":
                station_color = ei["__smartColor"]

SERIAL = [0]
def iid():
    SERIAL[0] += 1
    return f"00000000-d157-0001-0000-{SERIAL[0]:012d}"

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

ents = []
for i, (gx, gy) in enumerate(pack):
    ents.append(entity("PackSpawn", 12, "#6BEB5A", gx, gy, [fi("order", "Int", i, 120)]))
ents.append(transition(*nest_door, "nest", (28, 8)))
ents.append(transition(*seal_opens, "camp", (1, 5), sealed=True, ttype="stairs_up"))
ents.append(transition(*hole_at, "district_two", (1, 13), ttype="hole"))
ents.append(entity("Station", 10, station_color, *seal_at, [
    fi("type", "String", "seal", 100),
    fi("price", "String", "breach_cost", 101),
    fi("opens", "Point", {"cx": seal_opens[0], "cy": seal_opens[1]}, 102),
    fi("line", "String", "TOLL PAID", 103),
]))
for gx, gy in reds + greys:
    ents.append(entity("EnemySpawn", 13, "#EB5A5A", gx, gy, [fi("kind", "String", "rusher", 130)]))
for gx, gy in pinks:
    ents.append(entity("EnemySpawn", 13, "#EB5A5A", gx, gy, [fi("kind", "String", "rusher_hater", 130)]))

INT = {"#": 1, ".": 2, ",": 3, "g": 4, "w": 5, "~": 6}
csv = [INT[grid[y][x]] for y in range(ROWS) for x in range(COLS)]

level = copy.deepcopy(tmpl)
level["identifier"] = "district"
level["iid"] = iid()
level["uid"] = doc["nextUid"]
doc["nextUid"] += 1
level["pxWid"], level["pxHei"] = COLS * 32, ROWS * 32
for f in level["fieldInstances"]:
    v = {"display_name": "ZONE 2", "floor": -1, "hub": False, "safe": False}[f["__identifier"]]
    f["__value"] = v
    f["realEditorValues"] = [{"id": f"V_{f['__type']}", "params": [v]}]
for li in level["layerInstances"]:
    li["__cWid"], li["__cHei"] = COLS, ROWS
    li["iid"] = iid()
    li["levelId"] = level["uid"]
    if li["__identifier"] == "Terrain":
        li["intGridCsv"] = csv
    else:
        li["entityInstances"] = ents
doc["levels"].append(level)

out = (json.dumps(doc, indent=2, ensure_ascii=False) + "\n").replace("\n", "\r\n").encode("utf-8")
open(LDTK, "wb").write(out)

sidecar = {
    "palette": {
        "floor": [38, 30, 20], "grid": [48, 40, 28], "wall": [126, 96, 58],
        "transition": [235, 190, 90], "station_seal": [190, 140, 60],
        "dirt": [66, 52, 33], "grass": [52, 76, 40], "grass_b": [46, 68, 35],
        "grass_c": [58, 84, 46], "wood": [168, 126, 70], "water": [13, 17, 30],
        "motif": "chip", "motif_rgb": [46, 38, 26],
        "ambient_rgba": [100, 120, 180, 8]
    },
    "tile_size": 32,
    "drop_gradient": [[0, 1.0], [35, 1.5], [70, 2.0]],
    "gradient_anchor": [11, 87]
}
open(SIDECAR, "w", newline="\n").write(json.dumps(sidecar, indent=2) + "\n")

print(f"OK grid {COLS}x{ROWS} walkable={sum(r != '#' for row in grid for r in row)} "
      f"water={len(water)} bridges={len(bridges)} enemies={len(enemies)} "
      f"(rusher {len(reds) + len(greys)} / hater {len(pinks)})")
print(f"reachable={len(reach)} tiles from landing {landing}")
print("DEVIATIONS:")
for d in DEVIATIONS:
    print(" -", d)

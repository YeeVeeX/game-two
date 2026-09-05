#!/usr/bin/env python3
"""PREMIUM v22 tileset generator - DUAL-GRID (marching squares) material pieces.

The map stops being rectangles. The renderer draws a visual grid offset by
half a tile; each visual cell looks at the FOUR logic cells at its corners
and layers, per material present, a piece whose shape is the rounded blob
of "where this material is" (16 corner masks x 4 variants). Boundaries
between materials become curves; single tiles become rounded stones; inner
corners get fillets. Every piece is NEUTRAL GREY texture + alpha, tinted at
draw time by the zone palette (each zone keeps its identity), so one PNG
per material serves every zone.

Materials = render refs of data/tiles.json. Textures are 32-periodic
functions of GLOBAL pixel position sampled with the half-tile phase, so
adjacent pieces are seamless by construction; per-variant features (pebbles,
tufts, cracks, edge wobble) are windowed to the piece interior.

Baked per piece (all from the mask shape):
  * 1px darker outline just inside the boundary (selective outline)
  * 1.5px translucent halo just outside (soft blend into the lower material)
  * WALLS: cliff face (8px, brick lines) where the boundary faces SOUTH,
    light rim on the north lip, 6px cast shadow below onto the floor
  * LIQUIDS: light shallow rim inside the boundary (foam / wet edge)

Deterministic (no RNG, no time). Output: data/art/tiles/<material>.png
(512x128 = 16 masks x 4 variants of 32x32) + data/art/tiles.json (md5s,
priorities, texture keys) — test-pinned.

Run: python tools/gen_tileset.py [--preview]  (preview -> tmp/tileset/)
"""
from __future__ import annotations

import hashlib
import json
import math
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "data" / "art" / "tiles"
MANIFEST = ROOT / "data" / "art" / "tiles.json"
T = 32           # piece size = tile size
V = 4            # variants per mask
PHASE = 16       # half tile: visual cell (i,j) starts at logic (i-0.5, j-0.5)

# material: (texture kind, priority, threshold class)  low priority = drawn under
MATERIALS = {
    "lava_deco": ("lava", 0, "liquid"),
    "water": ("water", 1, "liquid"),
    "puddle": ("water", 2, "liquid"),
    "floor": ("floor", 10, "ground"),
    "sand": ("sand", 12, "ground"),
    "dirt": ("dirt", 14, "ground"),
    "grass": ("grass", 16, "ground"),
    "grass_b": ("grass", 16, "ground"),
    "grass_c": ("grass", 16, "ground"),
    "moss": ("moss", 18, "ground"),
    "wood": ("wood", 20, "ground"),
    "rubble": ("rubble", 22, "ground"),
    "bones": ("bones", 24, "ground"),
    "roots": ("roots", 26, "ground"),
    "wall_inner": ("rock", 40, "wall"),
    "wall": ("rock", 42, "wall"),
}
TEXTURES = sorted({v[0] for v in MATERIALS.values()})
THRESH = {"liquid": 0.5, "ground": 0.5, "wall": 0.42}   # walls connect diagonally


# --------------------------------------------------------------------------
# deterministic hashing / noise (period 32 in global coords)
# --------------------------------------------------------------------------
def h2(x, y, seed):
    n = (x * 374761393 + y * 668265263 + seed * 1442695041) & 0xFFFFFFFF
    n = ((n ^ (n >> 13)) * 1274126177) & 0xFFFFFFFF
    return ((n ^ (n >> 16)) & 0xFFFF) / 65535.0


def smooth(t):
    return t * t * (3 - 2 * t)


def vnoise(x, y, seed, cell=8, period=T):
    """Tileable value noise: lattice of `period/cell` points, smooth interp."""
    n = period // cell
    fx, fy = x / cell, y / cell
    ix, iy = int(math.floor(fx)), int(math.floor(fy))
    tx, ty = smooth(fx - ix), smooth(fy - iy)
    def lat(i, j):
        return h2(i % n, j % n, seed)
    a = lat(ix, iy) * (1 - tx) + lat(ix + 1, iy) * tx
    b = lat(ix, iy + 1) * (1 - tx) + lat(ix + 1, iy + 1) * tx
    return a * (1 - ty) + b * ty


def worley(x, y, seed, pts=5, period=T):
    """Distance to nearest jittered point (tileable) -> 0..1."""
    best = 9e9
    for k in range(pts):
        px = h2(k, 0, seed) * period
        py = h2(k, 1, seed) * period
        for ox in (-period, 0, period):
            for oy in (-period, 0, period):
                d = (x - px - ox) ** 2 + (y - py - oy) ** 2
                if d < best:
                    best = d
    return min(1.0, math.sqrt(best) / (period * 0.45))


# --------------------------------------------------------------------------
# textures: luminance 0..1 at GLOBAL pixel (gx, gy), variant var
# --------------------------------------------------------------------------
def tex_floor(gx, gy, var):
    # flagstones 16x16, 1px mortar, per-slab tone, fine grain, rare chip
    sx, sy = gx // 16, gy // 16
    if gx % 16 == 0 or gy % 16 == 0:
        return 0.70
    tone = 0.86 + 0.12 * h2(sx, sy, 7)
    grain = (vnoise(gx, gy, 11 + var, 4) - 0.5) * 0.10
    # worn slab: a lighter wear patch off-center + a dark chip
    wear = vnoise(gx, gy, 12, 16)
    if wear > 0.62:
        tone += 0.05
    if h2(gx, gy, 90 + var) > 0.985:
        return tone - 0.18
    return tone + grain


def tex_rock(gx, gy, var):
    # cell-shaded rock: worley cells with dark seams
    d = worley(gx, gy, 3)
    lum = 0.78 + 0.22 * (1 - d) ** 2
    if d > 0.90:
        lum = 0.52
    lum += (vnoise(gx, gy, 21, 4) - 0.5) * 0.12
    return lum


def tex_dirt(gx, gy, var):
    lum = 0.84 + (vnoise(gx, gy, 31, 8) - 0.5) * 0.18 + (vnoise(gx, gy, 32, 4) - 0.5) * 0.08
    # pebbles: sparse 2px ovals
    if h2(gx // 3, gy // 2, 40 + var) > 0.965:
        return 0.72 if (gx + gy) % 2 else 0.98
    return lum


def tex_grass(gx, gy, var):
    n = vnoise(gx, gy, 51, 8) + (vnoise(gx, gy, 52, 4) - 0.5) * 0.5
    lum = 0.80 if n < 0.42 else (0.90 if n < 0.62 else 1.0)
    # blades: 1x2 lighter dashes
    if h2(gx, gy // 2, 60 + var) > 0.955:
        return 1.0
    if h2(gx + 7, gy // 2, 61 + var) > 0.975:
        return 0.72
    return lum


def tex_sand(gx, gy, var):
    lum = 0.90 + (vnoise(gx, gy, 71, 4) - 0.5) * 0.10
    ripple = math.sin((gy + 3 * math.sin(gx / 5.1)) / 3.2 * math.pi)
    if ripple > 0.85:
        lum += 0.08
    if h2(gx, gy, 80 + var) > 0.985:
        lum -= 0.14
    return lum


def tex_water(gx, gy, var):
    lum = 0.86 + (vnoise(gx, gy, 91, 8) - 0.5) * 0.06
    # still highlights (the shimmer layer animates over this)
    if (gy % 8 == 2) and h2(gx // 4, gy, 100 + var) > 0.7 and gx % 4 < 3:
        lum = 1.0
    return lum


def tex_moss(gx, gy, var):
    # soft carpet: two tones + light sprigs (so the patch reads as MOSS, not a hole)
    n = vnoise(gx, gy, 111, 8)
    lum = 0.86 if n < 0.45 else 0.98
    if vnoise(gx, gy, 112, 4) > 0.70:
        lum += 0.10
    if h2(gx // 2, gy // 2, 113 + var) > 0.955:
        return 1.0
    return lum


def tex_wood(gx, gy, var):
    if gy % 8 == 0:
        return 0.62
    plank = gy // 8
    grain = math.sin((gx + plank * 11) / 2.7 + math.sin(gy / 1.7)) * 0.5 + 0.5
    lum = 0.84 + grain * 0.12 + (h2(plank, 0, 120) - 0.5) * 0.06
    if (gx + plank * 9) % 16 == 0 and gy % 8 in (3, 4):
        lum -= 0.18   # nail / knot
    return lum


def tex_rubble(gx, gy, var):
    lum = tex_dirt(gx, gy, var)
    if h2(gx // 4, gy // 3, 130 + var) > 0.86:
        return 0.70 if (gx // 2 + gy) % 3 else 1.0
    return lum


def tex_bones(gx, gy, var):
    lum = tex_dirt(gx, gy, var) - 0.04
    # a few bone shafts (pale) per 32x32, positioned per variant
    for k in range(3):
        bx, by = h2(k, 5, 140 + var) * 26 + 3, h2(k, 6, 140 + var) * 26 + 3
        L = 7 + k * 2
        ang = h2(k, 7, 140 + var) * math.pi
        for s in range(L):
            px, py = bx + math.cos(ang) * (s - L / 2), by + math.sin(ang) * (s - L / 2)
            if abs(gx - px) < 1 and abs(gy - py) < 1:
                return 1.0 if s in (0, L - 1) else 0.97
    return lum


def tex_lava(gx, gy, var):
    n = vnoise(gx, gy, 151, 8) + (vnoise(gx, gy, 152, 4) - 0.5) * 0.6
    # crust cracks dark; molten bright
    if 0.47 < n < 0.55:
        return 0.42
    return 1.0 if n >= 0.55 else 0.80


def tex_roots(gx, gy, var):
    lum = tex_floor(gx, gy, var)
    for k in range(2):
        yy = 6 + k * 14 + 4 * math.sin(gx / 4.0 + k)
        if abs(gy - yy) < 1.2:
            return 0.55
        if abs(gy - yy) < 2.2:
            return 0.68
    return lum


RAW_TEX = {"floor": tex_floor, "rock": tex_rock, "dirt": tex_dirt, "grass": tex_grass, "sand": tex_sand,
       "water": tex_water, "moss": tex_moss, "wood": tex_wood, "rubble": tex_rubble, "bones": tex_bones,
       "lava": tex_lava, "roots": tex_roots}
TARGET_MEAN = 0.92


def _normalized(fn):
    tot = 0.0
    for gy in range(T):
        for gx in range(T):
            tot += fn(gx, gy, 0)
    mean = tot / (T * T)
    k = TARGET_MEAN / max(mean, 1e-6)
    return lambda gx, gy, var: max(0.0, min(1.0, fn(gx, gy, var) * k))


TEX = {k: _normalized(v) for k, v in RAW_TEX.items()}


# --------------------------------------------------------------------------
# mask field: rounded blobs from the corners that hold the material
# --------------------------------------------------------------------------
CORNERS = [(0, 0), (1, 0), (0, 1), (1, 1)]   # TL=1, TR=2, BL=4, BR=8 (cell units)
R = 0.8


def field(mask, u, v):
    x, y = (u + 0.5) / T, (v + 0.5) / T
    s = 0.0
    for b, (cx, cy) in enumerate(CORNERS):
        if mask & (1 << b):
            d2 = (x - cx) ** 2 + (y - cy) ** 2
            s += max(0.0, 1.0 - d2 / (R * R))
    return s


def window(u, v):
    """0 at the piece edges, 1 inside — keeps edge wobble seamless across pieces."""
    wu = min(u, T - 1 - u) / 6.0
    wv = min(v, T - 1 - v) / 6.0
    return smooth(min(1.0, wu)) * smooth(min(1.0, wv))


def inside_grid(mask, var, thresh):
    g = [[False] * T for _ in range(T)]
    if mask == 15:
        return [[True] * T for _ in range(T)]
    for v in range(T):
        for u in range(T):
            f = field(mask, u, v)
            wob = (vnoise(u, v, 500 + var, 8, period=T) - 0.5) * 0.09 * window(u, v)
            g[v][u] = (f + wob) >= thresh
    return g


def chamfer(g, target):
    """Distance (px, chamfer 3-4 /3) from each pixel to the nearest pixel whose
    class == target. Border = replicate (no boundary at piece edges)."""
    INF = 99.0
    d = [[0.0 if g[v][u] == target else INF for u in range(T)] for v in range(T)]
    for v in range(T):
        for u in range(T):
            m = d[v][u]
            if u > 0:
                m = min(m, d[v][u - 1] + 1)
            if v > 0:
                m = min(m, d[v - 1][u] + 1)
                if u > 0:
                    m = min(m, d[v - 1][u - 1] + 1.4142)
                if u < T - 1:
                    m = min(m, d[v - 1][u + 1] + 1.4142)
            d[v][u] = m
    for v in range(T - 1, -1, -1):
        for u in range(T - 1, -1, -1):
            m = d[v][u]
            if u < T - 1:
                m = min(m, d[v][u + 1] + 1)
            if v < T - 1:
                m = min(m, d[v + 1][u] + 1)
                if u < T - 1:
                    m = min(m, d[v + 1][u + 1] + 1.4142)
                if u > 0:
                    m = min(m, d[v + 1][u - 1] + 1.4142)
            d[v][u] = m
    return d


def march(g, u, v, du, dv, limit):
    """Steps until the class changes (clamped at the piece edge) or limit."""
    here = g[v][u]
    for s in range(1, limit + 1):
        uu, vv = u + du * s, v + dv * s
        if not (0 <= uu < T and 0 <= vv < T):
            return limit + 1
        if g[vv][uu] != here:
            return s
    return limit + 1


def piece(material, mask, var):
    kind, _prio, cls = MATERIALS[material]
    tex = TEX[kind]
    g = inside_grid(mask, var, THRESH[cls])
    d_out = chamfer(g, False)   # for inside pixels: distance to outside
    d_in = chamfer(g, True)     # for outside pixels: distance to inside
    img = Image.new("RGBA", (T, T), (0, 0, 0, 0))
    px = img.load()
    for v in range(T):
        for u in range(T):
            gx, gy = (u + PHASE) % T, (v + PHASE) % T
            if g[v][u]:
                lum = tex(gx, gy, var)
                if mask != 15:
                    db = d_out[v][u]
                    if cls == "wall":
                        down = march(g, u, v, 0, 1, 11)
                        up = march(g, u, v, 0, -1, 2)
                        if down <= 11:
                            # cliff face: darker, horizontal brick seams, vertical joints
                            lum = 0.50 + 0.06 * ((down + 1) % 2) - 0.02 * down / 11
                            if (v % 4) == 3:
                                lum = 0.36
                            if ((u + (v // 4) * 5) % 9) == 0:
                                lum = 0.40
                        elif up <= 2:
                            lum = 1.0
                        elif db < 1.5:
                            lum = min(lum, 0.72)
                    else:
                        if db < 1.5:
                            lum *= 0.66
                        elif cls == "liquid" and db < 4.5:
                            lum = min(1.0, lum + 0.10)
                c = max(0, min(255, int(round(lum * 255))))
                px[u, v] = (c, c, c, 255)
            else:
                if mask == 15:
                    continue
                if cls == "wall":
                    up = march(g, u, v, 0, -1, 8)
                    if up <= 8:
                        px[u, v] = (0, 0, 0, max(0, 120 - 14 * up))
                        continue
                di = d_in[v][u]
                if di < 1.8:
                    px[u, v] = (255, 255, 255, 84)
    return img


def detail_sheet():
    """8 ground details, 32x32 each, grey + alpha; tinted by the FLOOR palette
    at draw time (dark ones read as cracks/pebbles, light ones as tufts)."""
    img = Image.new("RGBA", (8 * T, T), (0, 0, 0, 0))
    px = img.load()

    def put(i, x, y, lum, a=255):
        if 0 <= x < T and 0 <= y < T:
            c = int(lum * 255)
            px[i * T + x, y] = (c, c, c, a)
    # 0,1: pebble clusters
    for i, pts in enumerate((((10, 18, 3, 2), (17, 21, 2, 2), (14, 15, 2, 1)),
                             ((12, 14, 2, 2), (19, 17, 3, 2), (15, 20, 2, 2), (22, 13, 1, 1)))):
        for (cx, cy, rx, ry) in pts:
            for y in range(cy - ry, cy + ry + 1):
                for x in range(cx - rx, cx + rx + 1):
                    if ((x - cx) / (rx + 0.5)) ** 2 + ((y - cy) / (ry + 0.5)) ** 2 <= 1:
                        put(i, x, y, 0.62 if y < cy else 0.42)
            for x in range(cx - rx, cx + rx + 1):
                put(i, x, cy + ry + 1, 0.30, 140)
            put(i, cx - 1, cy - ry, 1.0)
    # 2,3: cracks (dark polylines)
    for i, pts in ((2, [(6, 20), (11, 17), (14, 18), (19, 13), (25, 12)]),
                   (3, [(8, 10), (12, 15), (13, 21), (18, 24)])):
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = max(abs(x1 - x0), abs(y1 - y0))
            for k in range(n + 1):
                x = round(x0 + (x1 - x0) * k / n)
                y = round(y0 + (y1 - y0) * k / n)
                put(i, x, y, 0.40)
                put(i, x + 1, y, 0.70, 160)
    # 4,5: tufts (light blades)
    for i, base in ((4, (13, 22)), (5, (17, 19))):
        bx, by = base
        for k, (dx, h) in enumerate(((-3, 4), (-1, 6), (1, 5), (3, 3), (0, 7))):
            for yy in range(h):
                put(i, bx + dx + (1 if (k % 2 and yy > h // 2) else 0), by - yy, 1.0 if yy > h - 3 else 0.88)
    # 6: flower  7: shells
    for (dx, dy) in ((0, -2), (0, 2), (-2, 0), (2, 0), (-1, -1), (1, 1), (-1, 1), (1, -1)):
        put(6, 16 + dx, 17 + dy, 1.0)
    put(6, 16, 17, 0.35)
    put(6, 16, 20, 0.80)
    put(6, 16, 21, 0.80)
    for (cx, cy) in ((11, 19), (20, 15)):
        for a in range(0, 181, 15):
            x = round(cx + 3 * math.cos(math.radians(a)))
            y = round(cy - 2 * math.sin(math.radians(a)))
            put(7, x, y, 0.95)
        put(7, cx, cy, 0.60)
    return img


def strip(material):
    img = Image.new("RGBA", (16 * T, V * T), (0, 0, 0, 0))
    for var in range(V):
        for mask in range(16):
            if mask == 0:
                continue
            p = piece(material, mask, var)
            img.paste(p, (mask * T, var * T))
    return img


def png_bytes(img):
    from io import BytesIO
    b = BytesIO()
    img.save(b, format="PNG", optimize=False)
    return b.getvalue()


def build(preview=False):
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest = {"tile": T, "masks": 16, "variants": V, "phase": PHASE,
                "corner_bits": {"tl": 1, "tr": 2, "bl": 4, "br": 8}, "materials": {}}
    done = {}
    for mat, (kind, prio, cls) in MATERIALS.items():
        # one PNG per texture kind (grass_b/grass_c share "grass"); the manifest maps refs -> png
        key = f"{kind}_{cls}"
        if key not in done:
            img = strip(mat)
            data = png_bytes(img)
            path = OUT_DIR / f"{key}.png"
            path.write_bytes(data)
            done[key] = {"png": f"art/tiles/{key}.png", "md5": hashlib.md5(data).hexdigest()}
            print(f"  {key:16s} {len(data):7d} bytes")
        manifest["materials"][mat] = {"texture": key, "priority": prio, "class": cls, **done[key]}
    det = png_bytes(detail_sheet())
    (OUT_DIR / "details_ground.png").write_bytes(det)
    manifest["details"] = {"png": "art/tiles/details_ground.png", "count": 8,
                           "md5": hashlib.md5(det).hexdigest(), "density": 0.09}
    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"manifest: {MANIFEST.relative_to(ROOT)}  materials={len(MATERIALS)} textures={len(done)}")
    if preview:
        preview_sheet()


def preview_sheet():
    """A fake 12x8 map rendered the dual-grid way, tinted like ZONE 7 / low_quay."""
    out = ROOT / "tmp" / "tileset"
    out.mkdir(parents=True, exist_ok=True)
    rows = ["############",
            "#..gggg..~~#",
            "#..gg,,..~~#",
            "#.##,,,ss~~#",
            "#.##..,sss.#",
            "#....mm....#",
            "#..wwmm..#.#",
            "############"]
    pal = {"wall": (110, 128, 74), "floor": (46, 40, 30), "grass": (44, 58, 34), "dirt": (58, 48, 32),
           "water": (38, 66, 92), "sand": (86, 76, 52), "moss": (30, 66, 34), "wood": (98, 72, 42)}
    ch2mat = {"#": "wall", ".": "floor", "g": "grass", ",": "dirt", "~": "water", "s": "sand", "m": "moss", "w": "wood"}
    strips = {}
    def img_for(mat):
        key = f"{MATERIALS[mat][0]}_{MATERIALS[mat][2]}"
        if key not in strips:
            strips[key] = Image.open(OUT_DIR / f"{key}.png").convert("RGBA")
        return strips[key]
    H, W = len(rows), len(rows[0])
    canvas = Image.new("RGBA", ((W + 1) * T, (H + 1) * T), (20, 18, 16, 255))
    def mat_at(x, y):
        if 0 <= y < H and 0 <= x < W:
            return ch2mat[rows[y][x]]
        return "wall"
    gain = 1.12
    for j in range(H + 1):
        for i in range(W + 1):
            corners = [mat_at(i - 1, j - 1), mat_at(i, j - 1), mat_at(i - 1, j), mat_at(i, j)]
            mats = sorted(set(corners), key=lambda m: MATERIALS[m][1])
            var = (i * 7 + j * 13) % V
            for k, m in enumerate(mats):
                mask = 15 if k == 0 else sum(1 << b for b, c in enumerate(corners) if c == m)
                src = img_for(m).crop((mask * T, var * T, (mask + 1) * T, (var + 1) * T))
                r, g, b = pal[m]
                tint = Image.new("RGBA", (T, T), (min(255, int(r * gain)), min(255, int(g * gain)), min(255, int(b * gain)), 255))
                tinted = Image.composite(src, src, src)
                # multiply modulation like Gosu
                tp = tinted.load(); sp = src.load()
                for v in range(T):
                    for u in range(T):
                        pr, pg, pb, pa = sp[u, v]
                        tp[u, v] = (pr * tint.getpixel((0, 0))[0] // 255, pg * tint.getpixel((0, 0))[1] // 255, pb * tint.getpixel((0, 0))[2] // 255, pa)
                canvas.alpha_composite(tinted, (i * T, j * T))
    canvas = canvas.resize((canvas.width * 3, canvas.height * 3), Image.NEAREST)
    canvas.save(out / "preview_zone7.png")
    print(f"preview: {out.relative_to(ROOT)}/preview_zone7.png")


if __name__ == "__main__":
    build(preview="--preview" in sys.argv)

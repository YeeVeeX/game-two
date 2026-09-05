"""Placeholder art generator (MUNDO VIVO FASE 1) - DETERMINISTIC.

Emits data/art/atlas/<kit>.png + data/art/manifest.json. Every atlas is a
grid: ROWS = facings (down, up, left, right), COLS = frames (12):
  idle 2 | walk 4 | windup 2 | active 2 | hurt 1 | dead 1
Frame = 32x32, the 28x28 body sits at anchor (2,2) - weapons may overhang
into the 2px margin. Silhouettes are DISTINCT per kit (the pack: blade /
shield / sling; hostiles: one trait per family). Palette starts from the
renderer's KIT_BODY colors so the existing legibility grammar (actors_
distinct, kits_distinct, hurt_flash_not_white...) keeps its color truth.

ART IS REPLACEABLE: same grid, new PNG, zero code. This file is the
pipeline proof, not the art. No diffusion here (frame consistency law).

Run:  python tools/gen_placeholder_art.py   (idempotent; md5s land in
the manifest and are test-pinned by test/app/art_registry_test.rb).
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "data" / "art" / "atlas"
MANIFEST = ROOT / "data" / "art" / "manifest.json"

FW = FH = 32          # frame size
BODY = 28             # Game::Creature::SIZE
AX = AY = 2           # anchor: body origin inside the frame
FACINGS = ["down", "up", "left", "right"]
FRAMES = [("idle", 0), ("idle", 1), ("walk", 0), ("walk", 1), ("walk", 2), ("walk", 3),
          ("windup", 0), ("windup", 1), ("active", 0), ("active", 1), ("hurt", 0), ("dead", 0)]
ANIMS = {"idle": {"frames": [0, 1], "frames_per_step": 18},
         "walk": {"frames": [2, 3, 4, 5], "frames_per_step": 5},
         "windup": {"frames": [6, 7], "frames_per_step": 4},
         "active": {"frames": [8, 9], "frames_per_step": 2},
         "hurt": {"frames": [10], "frames_per_step": 1},
         "dead": {"frames": [11], "frames_per_step": 1}}

# KIT_BODY from src/app/renderer.rb (the color truth the gate already judges)
HUMAN_BODY = (205, 198, 180)
KITS = {
    "striker": (235, 120, 40), "blocker": (190, 80, 35), "lobber": (225, 170, 90),
    "rusher": HUMAN_BODY, "rusher_hater": HUMAN_BODY, "husk": HUMAN_BODY,
    "challenger": HUMAN_BODY, "lurker": (168, 205, 140), "warden": (235, 150, 210),
    "stinger": (150, 215, 230),
    # FASE 4 serpent family (the tower): violet-grey scale — no other body owns violet
    "serpent_a": (170, 140, 210),
    "serpent_b": (200, 190, 175),   # stone-grey: the petrifier reads as statue
    "serpent_c": (120, 90, 170),    # deep violet: the blinker, darkest of the family
    # FASE 4 ember family (BRASA): hot red-orange, darker/redder than the pack ember
    "ember_a": (210, 60, 30),
    "ember_b": (225, 110, 40),
    "ember_d": (240, 90, 20),
    # FASE 5 bosses: the family color, saturated, with a crown accent (BOSS N = crown)
    "serpent_boss": (150, 100, 220),
    "ember_boss": (255, 70, 20),
    # FASE 4.5 spore family (MUSGO): saturated fungus green (lurker is pale algae)
    "spore_a": (150, 200, 70),
    "spore_b": (110, 170, 60),
}
OUTLINE = (20, 14, 12)
CORPSE_HUMAN, CORPSE_PACK = (175, 165, 145), (150, 80, 40)


def clamp(v):
    return max(0, min(255, int(round(v))))


def scale(rgb, k):
    return tuple(clamp(c * k) for c in rgb)


def rect(x0, y0, x1, y1):
    return {(x, y) for x in range(x0, x1 + 1) for y in range(y0, y1 + 1)}


def line(x0, y0, x1, y1, thick=1):
    pts, n = set(), max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in range(n + 1):
        x, y = round(x0 + (x1 - x0) * i / n), round(y0 + (y1 - y0) * i / n)
        for dx in range(thick):
            for dy in range(thick):
                pts.add((x + dx, y + dy))
    return pts


def ellipse(cx, cy, rx, ry):
    return {(x, y) for x in range(28) for y in range(28)
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0}


def wedge(w, h, cx=14, base_y=22):
    """isosceles wedge pointing UP with apex at (cx, base_y-h)."""
    pts = set()
    for i in range(h + 1):
        half = round(w / 2 * i / h)
        for x in range(cx - half, cx + half + 1):
            pts.add((x, base_y - h + i))
    return pts


# --- silhouettes: (body, accent) in 28x28 body space, facing DOWN/UP/RIGHT --
def shape(kit, facing):
    """facing in down|up|right (left = mirrored right)."""
    if kit == "striker":                       # lean blade-carrier
        body = rect(9, 3, 18, 25)
        if facing == "down":
            acc = line(19, 8, 25, 20, 2)       # blade angled down-right
        elif facing == "up":
            acc = line(25, 3, 19, 15, 2)       # blade angled up-right
        else:
            acc = line(19, 12, 28, 12, 2) | line(19, 11, 21, 13, 2)
    elif kit == "blocker":                     # squat wide + shield
        body = rect(3, 8, 24, 25)
        if facing == "down":
            acc = rect(6, 22, 21, 27)
        elif facing == "up":
            acc = rect(6, 6, 21, 11)
        else:
            acc = rect(22, 9, 27, 24)
    elif kit == "lobber":                      # round pouch + sling arc
        body = ellipse(14, 15, 9.5, 10.5)
        if facing == "down":
            acc = line(6, 24, 22, 27, 1) | line(22, 27, 26, 24, 1)
        elif facing == "up":
            acc = line(6, 4, 22, 1, 1) | line(22, 1, 26, 4, 1)
        else:
            acc = line(22, 6, 27, 14, 1) | line(27, 14, 22, 22, 1)
    elif kit in ("rusher", "rusher_hater"):    # jagged wedge toward facing
        if facing == "down":
            body = {(x, 27 - y) for (x, y) in wedge(20, 20, 14, 24)} | rect(8, 3, 19, 8)
        elif facing == "up":
            body = wedge(20, 20, 14, 24) | rect(8, 19, 19, 24)
        else:
            body = {(y, x) for (x, y) in wedge(20, 20, 14, 24)} | rect(3, 8, 8, 19)
        acc = set()
        if kit == "rusher_hater":              # hater: two carved hate-stripes
            body -= rect(10, 12, 17, 13) | rect(10, 16, 17, 17)
            acc = rect(11, 12, 16, 13) | rect(11, 16, 16, 17)
    elif kit == "husk":                        # hunched, hollow core
        body = ellipse(14, 16, 10, 11) - ellipse(14, 17, 4, 5)
        acc = {(13, 6), (14, 6), (13, 7), (14, 7)} if facing != "up" else {(13, 26), (14, 26)}
    elif kit == "challenger":                  # BOSS 1: big block + crown
        body = rect(2, 6, 25, 27)
        acc = {(x, y) for x in range(4, 24, 4) for y in (2, 3, 4, 5)} | rect(2, 5, 25, 5)
    elif kit == "lurker":                      # low algae blob
        body = ellipse(14, 19, 12.5, 7.5)
        acc = {(6, 17), (10, 15), (14, 14), (18, 15), (22, 17)}
    elif kit == "warden":                      # jellyfish bell + tendrils
        body = ellipse(14, 10, 11, 8.5) | rect(4, 10, 23, 13)
        acc = {(x, y) for x in (5, 9, 13, 17, 21) for y in range(14, 27) if (y // 2 + x // 4) % 2 == 0}
    elif kit == "stinger":                     # small bell + spike toward facing
        body = ellipse(14, 12, 8, 7) | rect(7, 12, 20, 14)
        tend = {(x, y) for x in (8, 12, 16, 20) for y in range(15, 24) if (y + x // 4) % 2 == 0}
        if facing == "down":
            acc = tend | line(14, 24, 14, 27, 2)
        elif facing == "up":
            acc = tend | line(14, 1, 14, 5, 2)
        else:
            acc = tend | line(21, 12, 27, 12, 2)
    elif kit == "serpent_a":                   # coiled S + fanned hood (the spread caster)
        body = line(6, 22, 12, 16, 3) | line(12, 16, 16, 20, 3) | line(16, 20, 22, 10, 3) | ellipse(21, 8, 4.5, 4)
        if facing == "down":
            acc = {(17, 12), (21, 13), (25, 12)}
        elif facing == "up":
            acc = {(17, 3), (21, 2), (25, 3)}
        else:
            acc = {(26, 6), (27, 8), (26, 10)}
    elif kit == "serpent_b":                   # squat coil + wide staring hood (the petrifier)
        body = ellipse(14, 20, 11, 6) | ellipse(14, 10, 9, 7)
        eyes = {(10, 9), (11, 9), (17, 9), (18, 9)}
        if facing == "down":
            acc = eyes | {(13, 15), (14, 15), (15, 15)}
        elif facing == "up":
            acc = {(10, 5), (11, 5), (17, 5), (18, 5)}
        else:
            acc = {(20, 8), (21, 8), (20, 11), (21, 11), (24, 9), (25, 9)}
    elif kit == "serpent_c":                   # thin whip-coil + forked tail (the blinker)
        body = line(4, 24, 10, 14, 2) | line(10, 14, 18, 20, 2) | line(18, 20, 24, 6, 2) | ellipse(23, 5, 3.5, 3)
        if facing == "down":
            acc = {(21, 9), (25, 9), (14, 26), (16, 26)}
        elif facing == "up":
            acc = {(21, 1), (25, 1), (2, 24), (3, 22)}
        else:
            acc = {(26, 4), (27, 6), (2, 25), (3, 27)}
    elif kit == "ember_a":                     # the charger: forward-leaning bull wedge + horns
        if facing == "down":
            body = {(x, 27 - y) for (x, y) in wedge(18, 14, 14, 26)} | rect(8, 2, 19, 13)
            acc = {(7, 24), (8, 25), (20, 24), (19, 25)}
        elif facing == "up":
            body = wedge(18, 14, 14, 26) | rect(8, 14, 19, 25)
            acc = {(7, 3), (8, 2), (20, 3), (19, 2)}
        else:
            body = {(y, x) for (x, y) in wedge(18, 14, 14, 26)} | rect(2, 8, 13, 19)
            acc = {(24, 7), (25, 8), (24, 20), (25, 19)}
    elif kit == "ember_b":                     # the aura bearer: round brazier body + heat crown
        body = ellipse(14, 16, 10, 9) | rect(9, 4, 18, 8)
        acc = {(9, 3), (12, 2), (15, 2), (18, 3), (11, 6), (16, 6)}
    elif kit == "ember_d":                     # the beam caster: tall pillar + single burning eye
        body = rect(10, 2, 17, 26) | rect(7, 22, 20, 26)
        eye = {(13, 6), (14, 6), (13, 7), (14, 7)}
        if facing == "down":
            acc = eye | {(13, 27)}
        elif facing == "up":
            acc = {(13, 3), (14, 3), (13, 4), (14, 4)} | {(13, 0)}
        else:
            acc = {(16, 6), (17, 6), (16, 7), (17, 7)} | {(20, 6), (21, 6), (22, 6)}
    elif kit == "serpent_boss":                # the tower's floor-4 hood: wide bell + coil + crown
        body = ellipse(14, 12, 12, 9) | line(4, 26, 24, 22, 3) | rect(3, 19, 25, 27)
        crown = {(x, y) for x in range(5, 24, 4) for y in (2, 3)} | rect(4, 3, 24, 3)
        acc = crown | ({(10, 11), (18, 11), (14, 14)} if facing != "up" else set())
    elif kit == "ember_boss":                  # the forge heart: massive block, twin horns, crown of embers
        body = rect(2, 7, 25, 27)
        crown = {(x, y) for x in range(3, 25, 3) for y in (2, 3, 4)} | rect(2, 5, 25, 6)
        if facing == "down":
            acc = crown | {(8, 14), (9, 15), (19, 14), (18, 15)}
        elif facing == "up":
            acc = crown
        else:
            acc = crown | {(24, 12), (25, 13), (24, 21), (25, 20)}
    elif kit == "spore_a":                     # small cap mushroom on a thin stem
        body = ellipse(14, 10, 9, 6) | rect(12, 12, 15, 24)
        acc = {(9, 8), (13, 6), (18, 9)} | ({(11, 26), (16, 26)} if facing != "up" else set())
    elif kit == "spore_b":                     # broad heavy cap, squat stem, spore-dust ring
        body = ellipse(14, 11, 12, 7) | rect(9, 14, 18, 25)
        acc = {(6, 9), (10, 6), (14, 5), (18, 6), (22, 9)} | {(5, 26), (22, 26)}
    else:
        body, acc = rect(0, 0, 27, 27), set()
    acc = {p for p in acc if 0 <= p[0] < 28 and 0 <= p[1] < 28}
    if kit != "rusher_hater":
        acc -= body
    return body, acc


def mirror(pts):
    return {(27 - x, y) for (x, y) in pts}


def shift(pts, dx, dy):
    return {(x + dx, y + dy) for (x, y) in pts}


def facing_vec(facing):
    return {"down": (0, 1), "up": (0, -1), "left": (-1, 0), "right": (1, 0)}[facing]


def transform(body, acc, anim, i, facing):
    fx, fy = facing_vec(facing)
    if anim == "idle":
        return (shift(body, 0, -1), shift(acc, 0, -1)) if i == 1 else (body, acc)
    if anim == "walk":
        legs_dx, bob = [(-2, -1), (0, 0), (2, -1), (0, 0)][i]
        legs = {p for p in body if p[1] >= 22}
        top = body - legs
        return shift(top, 0, bob) | shift(legs, legs_dx, 0), shift(acc, 0, bob)
    if anim == "windup":                       # pull back from facing + squash
        k = 2 + i
        b = shift(body, -fx * k, -fy * k)
        b = {(x, y) for (x, y) in b if not (fy and y < 3 + k) and not (fx and x < 1 + k)}
        return b, shift(acc, -fx * k, -fy * k)
    if anim == "active":                       # lunge into facing
        k = 3 + 2 * i
        return shift(body, fx * k, fy * k), shift(acc, fx * k, fy * k)
    if anim == "hurt":
        return body, acc
    if anim == "dead":                         # fallen: wide low slab, bottom band
        xs = [p[0] for p in body]
        cx = (min(xs) + max(xs)) / 2
        return ellipse(cx, 23, 11.5, 4.5), set()
    return body, acc


def shade(base, pts, dead=False):
    if not pts:
        return {}
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    w, h = max(x1 - x0, 1), max(y1 - y0, 1)
    out = {}
    for (x, y) in pts:
        u, v = (x - x0) / w, (y - y0) / h
        # shade range 0.82..1.12 (was 0.70..1.15): a deeper bottom-right
        # pushed a dimmed striker into the blocker's rust band — critic
        # aoe_specials 2026-09-05 'kit color swaps with possession'.
        k = 1.12 - 0.30 * (0.55 * v + 0.45 * u)
        if dead:
            k *= 0.8
        k += 0.03 * ((x * 7 + y * 13) % 3 - 1)  # deterministic grain
        out[(x, y)] = scale(base, k)
    return out


def outline_for(pts):
    edge = set()
    for (x, y) in pts:
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy)
            if n not in pts:
                edge.add(n)
    return edge


def render_frame(kit, facing, anim, i):
    src = "right" if facing == "left" else facing
    body, acc = shape(kit, src)
    if facing == "left":
        body, acc = mirror(body), mirror(acc)
    body, acc = transform(body, acc, anim, i, facing)
    base = KITS[kit]
    if kit == "lobber":                        # critic (world_loop, FASE 1): 'muddy
        base = scale(base, 1.10)               # not pale amber' — lift the amber
    dead = anim == "dead"
    if dead:
        base = CORPSE_HUMAN if base == HUMAN_BODY else CORPSE_PACK
    px = {}
    for p, c in shade(base, body, dead).items():
        px[p] = c
    if not dead:
        acc_col = scale(base, 1.45) if base != HUMAN_BODY else (255, 250, 235)
        for p in acc:
            px[p] = acc_col
    if anim == "hurt":
        px = {p: tuple(clamp(c + (255 - c) * 0.55) for c in col) for p, col in px.items()}
    for p in outline_for(set(px)):
        px.setdefault(p, OUTLINE)
    img = Image.new("RGBA", (FW, FH), (0, 0, 0, 0))
    for (x, y), c in px.items():
        X, Y = x + AX, y + AY
        if 0 <= X < FW and 0 <= Y < FH:
            img.putpixel((X, Y), (*c, 255 if not dead else 200))
    return img


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest = {"frame_w": FW, "frame_h": FH, "anchor": [AX, AY], "facings": FACINGS,
                "generator": "tools/gen_placeholder_art.py", "kits": {}}
    for kit in KITS:
        atlas = Image.new("RGBA", (FW * len(FRAMES), FH * len(FACINGS)), (0, 0, 0, 0))
        for r, facing in enumerate(FACINGS):
            for c, (anim, i) in enumerate(FRAMES):
                atlas.paste(render_frame(kit, facing, anim, i), (c * FW, r * FH))
        path = OUT_DIR / f"{kit}.png"
        atlas.save(path, optimize=True)
        md5 = hashlib.md5(path.read_bytes()).hexdigest()
        manifest["kits"][kit] = {"atlas": f"art/atlas/{kit}.png", "cols": len(FRAMES),
                                 "rows": len(FACINGS), "anims": ANIMS, "md5": md5}
        print(f"{kit:13s} {atlas.size[0]}x{atlas.size[1]} md5={md5}")
    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print("manifest:", MANIFEST.relative_to(ROOT))


if __name__ == "__main__":
    main()

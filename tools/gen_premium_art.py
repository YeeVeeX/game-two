#!/usr/bin/env python3
"""PREMIUM v22 art generator (2026-09-05) - DETERMINISTIC drawn characters.

Replaces the FASE 1 placeholder shapes. Same contract (data/art/manifest.json
+ data/art/atlas/<kit>.png; the renderer picks a frame as a pure function of
state/frame; nothing enters the sim or the digest), new grid:

  frame 32x48, anchor (2,14): the 28x28 body box sits at rows 14..41; heads,
  hoods, crowns and raised weapons live above, the ground shadow below.
  COLS = 16: idle 4 | walk 6 | windup 2 | active 2 | hurt 1 | dead 1
  ROWS = facings down, up, left, right ('left' = mirror of 'right').

Craft (tools/premium_art/): 5-tone hue-shifted ramps, one light (upper-
left), selective 1px outline in the material's darkest tone, silhouette-
first designs, anticipation -> snap -> recoil timing, secondary motion.
Color truth for the gate rows is kept: each kit's DOMINANT material is its
family color (pack ember/rust/amber, humans bone, warden pink, stinger
cyan, lurker pale green, serpent violet, ember red-orange, spore green).

Deterministic + idempotent: no RNG, no time. md5s land in the manifest and
are test-pinned by test/app/art_registry_test.rb.

Run:  python tools/gen_premium_art.py              # data/art/*
      python tools/gen_premium_art.py --preview    # + tmp/premium_art/sheet_*.png
"""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

from PIL import Image, ImageOps

sys.path.insert(0, str(Path(__file__).resolve().parent))
from premium_art.core import (ANIMS, AX, AY, COLS, FACINGS, FH, FRAMES, FW, Canvas,  # noqa: E402
                              ramp, shared_palette)
from premium_art import humanoid, monsters  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "data" / "art" / "atlas"
MANIFEST = ROOT / "data" / "art" / "manifest.json"

# renderer KIT_BODY truths (the colors the gate learned) -> dominant materials
KITS = {
    # --- the pack (Fio / Aro / Pomo): ember orange / deep rust / pale amber
    "striker": ("humanoid", humanoid.PACK_SKINS["striker"],
                {"cloth": ramp((235, 120, 40)), "jacket_mat": ramp((70, 52, 60)),
                 "cloth2": ramp((235, 120, 40)), "pants": ramp((58, 44, 52)), "hair": ramp((60, 40, 30))}),
    "blocker": ("humanoid", humanoid.PACK_SKINS["blocker"],
                {"armor": ramp((190, 80, 35)), "cloth": ramp((120, 60, 40)), "accent": ramp((240, 200, 80)),
                 "pants": ramp((70, 50, 45)), "hair": ramp((60, 40, 30))}),
    "lobber": ("humanoid", humanoid.PACK_SKINS["lobber"],
               {"cloth": ramp((225, 170, 90)), "hair": ramp((72, 44, 30)), "pants": ramp((120, 90, 60))}),
    # --- husks (bone + root) and the singer
    "husk": ("humanoid", humanoid.HUMAN_SKINS["husk"],
             {"cloth": ramp((205, 198, 180), dark_hue=0.02), "pants": ramp((160, 152, 138)), "hair": ramp((150, 140, 125))}),
    "rusher": ("humanoid", humanoid.HUMAN_SKINS["rusher"],
               {"cloth": ramp((205, 198, 180), dark_hue=0.02), "pants": ramp((150, 142, 128)), "hair": ramp((150, 140, 125))}),
    "rusher_hater": ("humanoid", humanoid.HUMAN_SKINS["rusher_hater"],
                     {"cloth": ramp((200, 190, 172), dark_hue=0.02), "pants": ramp((140, 130, 118)), "hair": ramp((150, 140, 125))}),
    "challenger": ("humanoid", humanoid.HUMAN_SKINS["challenger"],
                   {"cloth": ramp((205, 198, 180), dark_hue=0.02), "cloak": ramp((70, 62, 72)), "pants": ramp((150, 142, 128)),
                    "hair": ramp((150, 140, 125))}),
    # --- tide: medusa (pink), dart (cyan), lurker (pale green)
    "warden": ("jelly", {"dart": False},
               {"body": ramp((235, 150, 210), dark_hue=-0.03), "tent": ramp((215, 120, 190)), "glow": ramp((255, 210, 240))}),
    "stinger": ("jelly", {"dart": True},
                {"body": ramp((150, 215, 230), dark_hue=0.04), "tent": ramp((120, 190, 215)), "glow": ramp((220, 250, 255))}),
    "lurker": ("lurker", {},
               {"body": ramp((168, 205, 140)), "water": ramp((120, 170, 150)), "glow": ramp((230, 250, 170))}),
    # --- serpents (violet family)
    "serpent_a": ("serpent", {"kind": "a"},
                  {"body": ramp((170, 140, 210)), "shard": ramp((200, 160, 255)), "glow": ramp((230, 200, 255))}),
    "serpent_b": ("serpent", {"kind": "b"},
                  {"body": ramp((200, 190, 175)), "crack": ramp((90, 80, 90)), "shard": ramp((190, 170, 210)), "glow": ramp((240, 235, 230))}),
    "serpent_c": ("serpent", {"kind": "c"},
                  {"body": ramp((120, 90, 170)), "shard": ramp((170, 130, 240)), "glow": ramp((220, 190, 255))}),
    "serpent_boss": ("serpent", {"kind": "a", "big": True},
                     {"body": ramp((150, 100, 220)), "shard": ramp((210, 170, 255)), "glow": ramp((240, 220, 255))}),
    # --- ember (red-orange family)
    "ember_a": ("ram", {},
                {"body": ramp((210, 60, 30)), "seam": ramp((255, 170, 60)), "glow": ramp((255, 220, 120)), "horn": ramp((230, 200, 150))}),
    "ember_b": ("brazier", {},
                {"body": ramp((225, 110, 40)), "coal": ramp((255, 150, 40))}),
    "ember_d": ("beacon", {},
                {"body": ramp((240, 90, 20)), "glow": ramp((255, 200, 80)), "crack": ramp((90, 30, 20))}),
    "ember_boss": ("brazier", {"big": True},
                   {"body": ramp((255, 70, 20)), "coal": ramp((255, 180, 60))}),
    # --- spore (green family)
    "spore_a": ("mushroom", {},
                {"cap": ramp((150, 200, 70)), "stem": ramp((225, 220, 190)), "spot": ramp((240, 250, 200)), "puddle": ramp((120, 190, 80))}),
    "spore_b": ("mushroom", {"broad": True},
                {"cap": ramp((110, 170, 60)), "stem": ramp((200, 195, 170)), "spot": ramp((230, 245, 190)), "puddle": ramp((120, 190, 80))}),
}

RIGS = {"humanoid": humanoid.draw, "jelly": monsters.jelly, "lurker": monsters.lurker,
        "serpent": monsters.serpent, "ram": monsters.ram, "brazier": monsters.brazier,
        "beacon": monsters.beacon, "mushroom": monsters.mushroom}


def frame(kit, facing, anim, i):
    rig, T, pal_extra = KITS[kit]
    pal = dict(shared_palette())
    pal.update(pal_extra)
    cv = Canvas()
    RIGS[rig](cv, facing, anim, i, T)
    cv.outline()
    return cv.render(pal)


def atlas(kit):
    img = Image.new("RGBA", (COLS * FW, len(FACINGS) * FH), (0, 0, 0, 0))
    right = {}
    for col, (anim, i) in enumerate(FRAMES):
        right[col] = frame(kit, "right", anim, i)
    for row, facing in enumerate(FACINGS):
        for col, (anim, i) in enumerate(FRAMES):
            if facing == "left":
                f = ImageOps.mirror(right[col])
            elif facing == "right":
                f = right[col]
            else:
                f = frame(kit, facing, anim, i)
            img.paste(f, (col * FW, row * FH), f)
    return img


def png_bytes(img):
    from io import BytesIO
    b = BytesIO()
    img.save(b, format="PNG", optimize=False)
    return b.getvalue()


def build(preview=False):
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest = {"frame_w": FW, "frame_h": FH, "anchor": [AX, AY], "facings": FACINGS, "kits": {}}
    atlases = {}
    for kit in KITS:
        img = atlas(kit)
        data = png_bytes(img)
        (OUT_DIR / f"{kit}.png").write_bytes(data)
        manifest["kits"][kit] = {"atlas": f"art/atlas/{kit}.png", "cols": COLS, "rows": len(FACINGS),
                                 "anims": ANIMS, "md5": hashlib.md5(data).hexdigest()}
        atlases[kit] = img
    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"manifest: {MANIFEST.relative_to(ROOT)}  kits={len(KITS)}  frame={FW}x{FH} anchor=({AX},{AY})")
    if preview:
        sheets(atlases)


def sheets(atlases, scale=4):
    out = ROOT / "tmp" / "premium_art"
    out.mkdir(parents=True, exist_ok=True)
    groups = [["striker", "blocker", "lobber", "husk", "challenger"],
              ["rusher", "rusher_hater", "warden", "stinger", "lurker"],
              ["serpent_a", "serpent_b", "serpent_c", "serpent_boss", "spore_a"],
              ["ember_a", "ember_b", "ember_d", "ember_boss", "spore_b"]]
    cols = [0, 2, 4, 6, 8, 10, 11, 12, 13, 14, 15, 16, 17]   # idle0 idle2 walk0 walk2 walk4 windup0 windup1 active0 active1 hurt dead
    for gi, group in enumerate(groups):
        w = len(cols) * FW * scale + 20
        h = len(group) * 2 * FH * scale + 20
        sheet = Image.new("RGBA", (w, h), (46, 40, 36, 255))
        # floor band so the outline reads against a mid-dark ground like the game's
        for r in range(len(group) * 2):
            y = 10 + r * FH * scale
            sheet.paste((62, 54, 44, 255), (10, y, w - 10, y + FH * scale))
        for r, kit in enumerate(group):
            a = atlases[kit]
            for fi, facing_row in enumerate((0, 3)):  # down, right
                for ci, col in enumerate(cols):
                    f = a.crop((col * FW, facing_row * FH, (col + 1) * FW, (facing_row + 1) * FH))
                    f = f.resize((FW * scale, FH * scale), Image.NEAREST)
                    sheet.paste(f, (10 + ci * FW * scale, 10 + (r * 2 + fi) * FH * scale), f)
        sheet.save(out / f"sheet_{gi}.png")
    print(f"sheets: {out.relative_to(ROOT)}/sheet_0..{len(groups) - 1}.png")


if __name__ == "__main__":
    build(preview="--preview" in sys.argv)

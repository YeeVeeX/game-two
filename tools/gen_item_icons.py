#!/usr/bin/env python3
"""S1 item icons - DETERMINISTIC 16x16 pixel icons, one per catalog item.

Same craft laws as the sprites (tools/premium_art): 5-tone hue-shifted ramps,
light upper-left, 1px selective outline in the material's darkest tone, one
readable silhouette per icon. Drawn at 16x16 (2 world px per icon px at the
game's 32-px tile) so a bag cell / drop / HUD chip reads at a glance.

Output: data/art/items.png (N x 16 strip, order = data/items.json keys) +
data/art/items.json {icon: index} with the md5 - test-pinned.

Run: python tools/gen_item_icons.py [--preview]  (preview -> tmp/item_icons.png 6x)
"""
from __future__ import annotations

import hashlib
import json
import sys
from io import BytesIO
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from premium_art.core import ramp  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
S = 16

PAL = {
    "glass": ramp((190, 215, 230), dark_hue=0.03),
    "pink": ramp((230, 90, 140)),
    "green": ramp((110, 220, 90)),
    "orange": ramp((235, 130, 40)),
    "clay": ramp((150, 96, 70)),
    "iron": ramp((196, 204, 214), dark_hue=0.03, light_hue=-0.02),
    "steel": ramp((150, 160, 175), dark_hue=0.03),
    "violet": ramp((170, 140, 220)),
    "rust": ramp((158, 52, 30)),
    "leather": ramp((110, 72, 50)),
    "stone": ramp((140, 138, 130)),
    "root": ramp((95, 60, 35)),
    "basalt": ramp((70, 66, 74), dark_hue=0.03),
    "ember": ramp((255, 150, 40)),
    "moss": ramp((60, 140, 70)),
    "cyan": ramp((120, 210, 225), dark_hue=0.04),
    "marble": ramp((200, 190, 175)),
    "coal": ramp((40, 34, 38)),
    "cap": ramp((150, 200, 70)),
    "bell": ramp((235, 150, 210), dark_hue=-0.03),
    "gold": ramp((240, 200, 80)),
    "bone": ramp((205, 198, 180), dark_hue=0.02),
}


class Icon:
    def __init__(self):
        self.p = {}

    def put(self, x, y, m, t=2):
        if 0 <= x < S and 0 <= y < S:
            self.p[(int(x), int(y))] = (m, max(0, min(4, t)))

    def box(self, x, y, w, h, m, t=2, shade=True):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                tt = t
                if shade:
                    if yy == y and h >= 3: tt = t + 1
                    if xx == x + w - 1 and w >= 3: tt = t - 1
                    if yy == y + h - 1 and h >= 3: tt = t - 1
                self.put(xx, yy, m, tt)

    def ellipse(self, cx, cy, rx, ry, m, t=2, shade=True):
        for yy in range(S):
            for xx in range(S):
                nx = (xx + 0.5 - cx) / (rx + 0.5)
                ny = (yy + 0.5 - cy) / (ry + 0.5)
                if nx * nx + ny * ny <= 1:
                    tt = t
                    if shade:
                        n = (nx + ny) / 2
                        tt = t + 1 if n < -0.4 else (t - 1 if n > 0.5 else t)
                    self.put(xx, yy, m, tt)

    def line(self, x0, y0, x1, y1, m, t=2):
        n = max(abs(x1 - x0), abs(y1 - y0), 1)
        for k in range(n + 1):
            self.put(round(x0 + (x1 - x0) * k / n), round(y0 + (y1 - y0) * k / n), m, t)

    def render(self):
        img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
        add = {}
        for (x, y), (m, t) in self.p.items():
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                q = (x + dx, y + dy)
                if q not in self.p and 0 <= q[0] < S and 0 <= q[1] < S:
                    add[q] = (m, -1)
        allp = dict(self.p)
        allp.update(add)
        for (x, y), (m, t) in allp.items():
            r, g, b = PAL[m][0] if t == -1 else PAL[m][t]
            if t == -1:
                r, g, b = int(r * 0.7), int(g * 0.7), int(b * 0.7)
            img.putpixel((x, y), (r, g, b, 255))
        return img


def flask(ic, liquid):
    ic.box(6, 1, 4, 2, "glass", 3)            # cork/neck
    ic.box(5, 3, 6, 2, "glass", 2)
    ic.ellipse(8, 10, 4.5, 4.5, "glass", 2)   # bulb
    ic.ellipse(8, 11, 3.2, 3, liquid, 2)      # liquid
    ic.put(6, 8, "glass", 4); ic.put(6, 9, "glass", 4)


def vial(ic, liquid):
    ic.box(7, 1, 3, 2, "glass", 3)
    ic.box(6, 3, 5, 11, "glass", 2)
    ic.box(7, 7, 3, 6, liquid, 2)
    ic.put(7, 4, "glass", 4); ic.put(7, 5, "glass", 4)


def jar(ic):
    ic.box(4, 3, 8, 2, "orange", 3)           # lid
    ic.box(3, 5, 10, 9, "clay", 2)
    ic.box(4, 7, 8, 2, "bone", 3)             # label
    ic.put(4, 6, "clay", 4)


def blade(ic, edge, hilt="leather"):
    for k in range(10):                        # diagonal blade, 2px wide
        ic.put(12 - k, 2 + k, edge, 3)
        ic.put(13 - k, 2 + k, edge, 2)
    ic.put(12, 2, edge, 4)
    ic.line(2, 12, 5, 9, "gold", 3)           # guard
    ic.line(1, 13, 3, 15, hilt, 2)            # grip
    ic.put(3, 15, hilt, 1)


def shield(ic):
    ic.ellipse(8, 8, 6.5, 7, "rust", 2)
    ic.ellipse(8, 8, 4.2, 4.6, "iron", 2)
    ic.ellipse(8, 8, 2, 2.2, "rust", 2)
    ic.put(6, 5, "iron", 4)


def sling(ic):
    ic.line(4, 14, 8, 6, "leather", 2)         # Y
    ic.line(12, 14, 8, 6, "leather", 2)
    ic.line(8, 6, 8, 3, "leather", 1)
    ic.ellipse(8, 3, 1.6, 1.6, "stone", 2)    # stone in the pouch
    ic.put(7, 2, "stone", 4)


def jerkin(ic, m):
    ic.box(3, 3, 10, 11, m, 2)
    ic.box(6, 3, 4, 3, "bone", 1)             # neck hole (dark)
    ic.box(3, 3, 2, 4, m, 3); ic.box(11, 3, 2, 4, m, 1)
    ic.line(8, 6, 8, 13, m, 1)                # lacing
    ic.put(7, 8, "gold", 3); ic.put(7, 11, "gold", 3)


def plate(ic):
    ic.box(3, 2, 10, 12, "basalt", 2)
    ic.box(5, 2, 6, 2, "basalt", 3)
    ic.line(8, 4, 8, 12, "ember", 3)          # seam glow
    ic.line(5, 8, 11, 8, "ember", 2)
    ic.box(3, 2, 2, 12, "basalt", 3); ic.box(11, 2, 2, 12, "basalt", 1)


def charm(ic, gem):
    ic.ellipse(8, 3, 2.2, 2.2, "gold", 2)     # ring
    ic.put(8, 3, "gold", 0)
    ic.line(8, 5, 8, 7, "gold", 1)            # chain
    for k in range(4):                         # diamond gem
        w = k + 1 if k < 2 else 4 - k
        ic.box(8 - w, 8 + k, 2 * w + 1, 1, gem, 3 if k < 2 else 2, shade=False)
    ic.put(7, 8, gem, 4)


def shard(ic):
    for k in range(11):                        # tall crystal
        w = 1 if k < 2 else (2 if k < 8 else 1)
        ic.box(8 - w, 2 + k, 2 * w + 1, 1, "violet", 3 if k < 5 else 2, shade=False)
    ic.line(7, 3, 7, 8, "violet", 4)
    ic.box(5, 12, 7, 2, "stone", 1)          # rock base


def scale(ic):
    ic.ellipse(8, 9, 5.5, 6, "marble", 2)
    ic.box(3, 3, 11, 3, "marble", 1)          # flat top (overlap edge)
    ic.line(5, 6, 5, 12, "stone", 1); ic.line(8, 5, 8, 14, "stone", 1); ic.line(11, 6, 11, 12, "stone", 1)
    ic.put(6, 6, "marble", 4)


def coal(ic):
    ic.ellipse(8, 9, 6, 5, "coal", 2)
    ic.line(4, 9, 8, 7, "ember", 3); ic.line(8, 7, 12, 10, "ember", 3); ic.line(7, 11, 10, 12, "ember", 2)
    ic.put(5, 6, "coal", 4)


def cap(ic):
    ic.ellipse(8, 6, 6.5, 4, "cap", 2)        # cap
    ic.box(6, 9, 4, 5, "bone", 2)             # stem
    ic.put(5, 5, "bone", 4); ic.put(10, 4, "bone", 4); ic.put(8, 7, "bone", 3)
    ic.put(4, 10, "green", 3); ic.put(11, 10, "green", 3)   # drips


def bell(ic):
    ic.ellipse(8, 6, 6, 4.5, "bell", 2)       # medusa bell
    for k, x in enumerate((3, 6, 9, 12)):
        ic.line(x, 10, x + (1 if k % 2 else -1), 14, "bell", 1)
    ic.put(5, 4, "bell", 4)


ICONS = {
    "flask_sap": lambda ic: flask(ic, "pink"),
    "antidote": lambda ic: vial(ic, "green"),
    "ember_salve": jar,
    "blade_iron": lambda ic: blade(ic, "iron"),
    "blade_shard": lambda ic: blade(ic, "violet", "leather"),
    "shield_ring": shield,
    "sling_sinew": sling,
    "jerkin_root": lambda ic: jerkin(ic, "root"),
    "plate_basalt": plate,
    "charm_moss": lambda ic: charm(ic, "moss"),
    "charm_tide": lambda ic: charm(ic, "cyan"),
    "shard_amethyst": shard,
    "scale_marble": scale,
    "coal_living": coal,
    "cap_spore": cap,
    "bell_pink": bell,
}


def build(preview=False):
    catalog = json.loads((ROOT / "data" / "items.json").read_text(encoding="utf-8"))
    ids = list(catalog["items"].keys())
    missing = [i for i in ids if catalog["items"][i]["icon"] not in ICONS]
    if missing:
        raise SystemExit(f"icons missing for: {missing}")
    sheet = Image.new("RGBA", (S * len(ids), S), (0, 0, 0, 0))
    index = {}
    for k, item_id in enumerate(ids):
        name = catalog["items"][item_id]["icon"]
        ic = Icon()
        ICONS[name](ic)
        sheet.paste(ic.render(), (k * S, 0))
        index[name] = k
    b = BytesIO()
    sheet.save(b, format="PNG", optimize=False)
    data = b.getvalue()
    out = ROOT / "data" / "art"
    (out / "items.png").write_bytes(data)
    manifest = {"png": "art/items.png", "size": S, "count": len(ids), "icons": index,
                "md5": hashlib.md5(data).hexdigest()}
    (out / "items.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"items.png: {len(ids)} icons x {S}px  md5 {manifest['md5'][:8]}")
    if preview:
        big = sheet.resize((sheet.width * 6, S * 6), Image.NEAREST)
        bg = Image.new("RGBA", big.size, (46, 40, 36, 255))
        bg.alpha_composite(big)
        (ROOT / "tmp").mkdir(exist_ok=True)
        bg.save(ROOT / "tmp" / "item_icons.png")
        print("preview: tmp/item_icons.png")


if __name__ == "__main__":
    build(preview="--preview" in sys.argv)

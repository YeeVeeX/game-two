#!/usr/bin/env python3
"""Title card for harness/make_tour.sh: a 960x540 PNG with a zone label
and one functional sub-line (placeholder names only - no-lore law).

usage: python harness/tour_card.py <out.png> "<title>" "<subtitle>"
"""
import sys
from PIL import Image, ImageDraw, ImageFont

out, title, sub = sys.argv[1], sys.argv[2], sys.argv[3]
W, H = 960, 540
img = Image.new("RGB", (W, H), (14, 12, 10))
d = ImageDraw.Draw(img)


def font(size):
    for name in ("C:/Windows/Fonts/consolab.ttf", "C:/Windows/Fonts/consola.ttf",
                 "DejaVuSansMono-Bold.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


big, small = font(56), font(26)
tw = d.textlength(title, font=big)
sw = d.textlength(sub, font=small)
d.text(((W - tw) / 2, H / 2 - 96), title, fill=(232, 168, 60), font=big)
d.text(((W - sw) / 2, H / 2 + 6), sub, fill=(200, 196, 188), font=small)
d.rectangle([W / 2 - 120, H / 2 - 14, W / 2 + 120, H / 2 - 12], fill=(232, 168, 60))
img.save(out)

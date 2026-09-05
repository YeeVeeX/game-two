"""PREMIUM v22 art core: 5-tone hue-shifted ramps + a (material, tone) canvas
with shaded primitives, selective outline and ground shadows. Deterministic
(no RNG, no time). Frame 32x48, anchor (2,14): body box rows 14..41."""
from __future__ import annotations

import colorsys
import math

from PIL import Image

FW, FH = 32, 48
AX, AY = 2, 14
BODY = 28
FEET = AY + BODY - 1   # 41 = sole row
CX = 16
FACINGS = ["down", "up", "left", "right"]
COLS = 22
FRAMES = [("idle", 0), ("idle", 1), ("idle", 2), ("idle", 3),
          ("walk", 0), ("walk", 1), ("walk", 2), ("walk", 3), ("walk", 4), ("walk", 5),
          ("windup", 0), ("windup", 1), ("active", 0), ("active", 1),
          ("hurt", 0), ("dead", 0), ("dodge", 0), ("dodge", 1),
          ("glance", 0), ("glance", 1), ("special", 0), ("special", 1)]
# idle = 20 steps x 12 frames = 240 frames (4 s): four breaths, then the
# secondary idle (cols 18/19: look aside, fidget the weapon) for 0.8 s
ANIMS = {"idle": {"frames": [0, 1, 2, 3] * 4 + [18, 18, 19, 19], "frames_per_step": 12},
         "walk": {"frames": [4, 5, 6, 7, 8, 9], "frames_per_step": 4},
         "windup": {"frames": [10, 11], "frames_per_step": 4},
         "active": {"frames": [12, 13], "frames_per_step": 2},
         "hurt": {"frames": [14], "frames_per_step": 1},
         "dead": {"frames": [15], "frames_per_step": 1},
         # pass 5: the DODGE (i-frames from a dodge/dash, not a hit): a tuck
         # that rolls toward the facing — 2 frames, 3 world frames each
         "dodge": {"frames": [16, 17], "frames_per_step": 3},
         # pass 5b: the SPECIAL has its own silhouette (dash crouch+lunge,
         # shield raised+ring slam, sling whirl+triple release)
         "special_windup": {"frames": [20], "frames_per_step": 1},
         "special_active": {"frames": [21], "frames_per_step": 1}}


def ramp(rgb, dark_hue=-0.045, light_hue=0.03):
    """5 tones around rgb: shadows cooler + more saturated, lights warmer +
    desaturated (the hue-shift law; never plain darker/lighter)."""
    r, g, b = [c / 255 for c in rgb]
    h, s, v = colorsys.rgb_to_hsv(r, g, b)

    def mk(dh, sm, vm):
        hh = (h + dh) % 1.0
        ss = min(1.0, max(0.0, s * sm))
        vv = min(1.0, max(0.0, v * vm))
        rr, gg, bb = colorsys.hsv_to_rgb(hh, ss, vv)
        return (round(rr * 255), round(gg * 255), round(bb * 255))

    return [mk(2 * dark_hue, 1.15, 0.42), mk(dark_hue, 1.08, 0.68), tuple(rgb),
            mk(light_hue, 0.85, 1.18), mk(2 * light_hue, 0.62, 1.38)]


def shared_palette():
    return {
        "skin": ramp((222, 178, 140)),
        "leather": ramp((88, 62, 52)),
        "boot": ramp((60, 44, 40)),
        "metal": ramp((196, 204, 214), dark_hue=0.03, light_hue=-0.02),
        "stone": ramp((150, 150, 145)),
        "bone": ramp((205, 198, 180), dark_hue=0.02),
        "root": ramp((95, 60, 35)),
        "eye": ramp((28, 20, 26)),
        "gold": ramp((240, 200, 80)),
        "crown": ramp((52, 36, 62)),
        "tongue": ramp((220, 60, 70)),
        "white": ramp((250, 245, 235)),
        "blueglow": ramp((70, 110, 230), dark_hue=0.02),
        "redglow": ramp((230, 50, 40)),
        "streak": ramp((240, 250, 255)),
    }


def sgn(v):
    return (v > 0) - (v < 0)


class Canvas:
    def __init__(self):
        self.p = {}
        self.shadows = []

    def put(self, x, y, mat, tone):
        x = int(round(x))
        y = int(round(y))
        if 0 <= x < FW and 0 <= y < FH:
            self.p[(x, y)] = (mat, max(0, min(4, tone)))

    def erase(self, x, y):
        self.p.pop((int(round(x)), int(round(y))), None)

    def box(self, x0, y0, w, h, mat, tone=2, shade=True):
        x0, y0, w, h = int(x0), int(y0), int(w), int(h)
        for y in range(y0, y0 + h):
            for x in range(x0, x0 + w):
                t = tone
                if shade:
                    if h >= 3 and y == y0 + h - 1:
                        t = tone - 1
                    if w >= 3 and x == x0 + w - 1:
                        t = tone - 1
                    if h >= 4 and y == y0 and x != x0 + w - 1:
                        t = tone + 1
                    if w >= 4 and x == x0 and y != y0 + h - 1:
                        t = tone + 1
                self.put(x, y, mat, t)

    def ellipse(self, cx, cy, rx, ry, mat, tone=2, shade=True):
        rx = max(rx, 0.5)
        ry = max(ry, 0.5)
        for y in range(int(math.floor(cy - ry)) - 1, int(math.ceil(cy + ry)) + 2):
            for x in range(int(math.floor(cx - rx)) - 1, int(math.ceil(cx + rx)) + 2):
                nx = (x + 0.5 - cx) / (rx + 0.5)
                ny = (y + 0.5 - cy) / (ry + 0.5)
                if nx * nx + ny * ny <= 1.0:
                    t = tone
                    if shade:
                        n = (nx + ny) / 2
                        if n < -0.45:
                            t = tone + 1
                        if n < -0.8:
                            t = tone + 2
                        if n > 0.48:
                            t = tone - 1
                    self.put(x, y, mat, t)

    def ring(self, cx, cy, rx, ry, mat, tone=2, inner=0.62):
        for y in range(int(math.floor(cy - ry)) - 1, int(math.ceil(cy + ry)) + 2):
            for x in range(int(math.floor(cx - rx)) - 1, int(math.ceil(cx + rx)) + 2):
                nx = (x + 0.5 - cx) / (rx + 0.5)
                ny = (y + 0.5 - cy) / (ry + 0.5)
                d = nx * nx + ny * ny
                if inner <= d <= 1.0:
                    self.put(x, y, mat, tone)

    def line(self, x0, y0, x1, y1, mat, tone=2, width=1):
        x0, y0, x1, y1 = int(round(x0)), int(round(y0)), int(round(x1)), int(round(y1))
        dx, dy = abs(x1 - x0), abs(y1 - y0)
        sx = 1 if x0 < x1 else -1
        sy = 1 if y0 < y1 else -1
        err = dx - dy
        x, y = x0, y0
        while True:
            if width <= 1:
                self.put(x, y, mat, tone)
            else:
                r = width / 2.0
                self.ellipse(x + 0.5, y + 0.5, r, r, mat, tone, shade=False)
            if x == x1 and y == y1:
                break
            e2 = 2 * err
            if e2 > -dy:
                err -= dy
                x += sx
            if e2 < dx:
                err += dx
                y += sy

    def path(self, pts, mat, tone=2, width=3):
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            self.line(x0, y0, x1, y1, mat, tone, width)

    def arc(self, cx, cy, r, a0, a1, mat, tone, step=5):
        a = a0
        while a <= a1:
            self.put(cx + r * math.cos(math.radians(a)), cy + r * math.sin(math.radians(a)), mat, tone)
            a += step

    def edge_shade(self, mats):
        """Rim light upper-left, shadow lower-right (tubes: tentacles, coils)."""
        snap = dict(self.p)
        for (x, y), (m, t) in snap.items():
            if m not in mats:
                continue
            ul = snap.get((x - 1, y - 1))
            lr = snap.get((x + 1, y + 1))
            if ul is None or ul[0] != m:
                self.p[(x, y)] = (m, min(4, t + 1))
            elif lr is None or lr[0] != m:
                self.p[(x, y)] = (m, max(0, t - 1))

    def shadow(self, cx, cy, rx, ry, alpha=84, rgb=(0, 0, 0)):
        self.shadows.append((cx, cy, rx, ry, alpha, rgb))

    def outline(self):
        add = {}
        for (x, y), (m, t) in self.p.items():
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                q = (x + dx, y + dy)
                if q not in self.p and 0 <= q[0] < FW and 0 <= q[1] < FH:
                    add[q] = (m, -1)
        self.p.update(add)

    def render(self, pal):
        img = Image.new("RGBA", (FW, FH), (0, 0, 0, 0))
        for (cx, cy, rx, ry, alpha, rgb) in self.shadows:
            for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
                for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
                    nx = (x + 0.5 - cx) / (rx + 0.5)
                    ny = (y + 0.5 - cy) / (ry + 0.5)
                    d = nx * nx + ny * ny
                    if d <= 1.0 and 0 <= x < FW and 0 <= y < FH:
                        a = min(255, int(alpha * 1.5)) if d < 0.55 else int(alpha * 0.9)
                        img.putpixel((x, y), (*rgb, a))
        for (x, y), (m, t) in self.p.items():
            rp = pal.get(m) or pal["stone"]
            if t == -1:
                r, g, b = rp[0]
                img.putpixel((x, y), (int(r * 0.70), int(g * 0.70), int(b * 0.70), 255))
            else:
                img.putpixel((x, y), (*rp[t], 255))
        return img

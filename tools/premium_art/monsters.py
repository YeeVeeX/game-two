"""PREMIUM v22 monster rigs: jelly (warden medusa / stinger dart), lurker,
coil serpents (a/b/c/boss), ember ram / brazier / beacon (+boss), spore
mushrooms (a/b). Each rig: silhouette first, family color dominant, one
readable idle motion, a crouch-then-snap attack, a recoil hurt, a fallen
dead. Facings down / up / right (left = mirror)."""
from __future__ import annotations

import math

from .core import CX, FEET


def fdir(facing):
    """Unit vector the body faces (screen coords)."""
    return {"down": (0, 1), "up": (0, -1), "right": (1, 0)}[facing]


# --------------------------------------------------------------------------
# JELLY: warden (pink medusa) and stinger (cyan dart)
# --------------------------------------------------------------------------
def jelly(cv, facing, anim, i, T):
    if anim == "dodge":
        anim, i = "idle", (0, 2)[i]
    dart = T.get("dart", False)
    m = "body"
    fx, fy = fdir(facing)
    rx, ry = (5.5, 4.5) if dart else (7.5, 5.5)
    cy = FEET - 13 if not dart else FEET - 12
    lean = 0
    tent_bend = 0
    glow = 2
    if anim == "idle":
        rx += (0, 0.5, 1, 0.5)[i]
        ry -= (0, 0.5, 0.5, 0)[i]
        cy += (0, 0, -1, 0)[i]
        tent_bend = (0, 1, 0, -1)[i]
    elif anim == "walk":
        lean = fx * (1, 2, 1, 0, 1, 2)[i]
        cy += (0, -1, 0, 0, -1, 0)[i]
        tent_bend = -fx * (1, 2, 2, 1, 2, 2)[i] or (1, 2, 1, -1, -2, -1)[i]
    elif anim == "windup":
        rx += (1, 2)[i]
        ry -= (1, 1.5)[i]
        cy += (2, 3)[i]
        glow = 3
    elif anim == "active":
        rx -= (1.5, 1)[i]
        ry += (2, 1)[i]
        cy += fy * (3, 2)[i] - 2
        lean = fx * (3, 2)[i]
        glow = 4
    elif anim == "hurt":
        ry -= 1.5
        rx += 1
        cy += 1
        glow = 1
    elif anim == "dead":
        cv.ellipse(CX, FEET - 3, 9, 2.5, m, 1)
        cv.ellipse(CX - 2, FEET - 4, 4, 1.5, m, 2)
        for k in range(-3, 4):
            cv.line(CX + k * 3, FEET - 2, CX + k * 3 + 2, FEET + 1, m, 0)
        cv.shadow(CX, FEET + 1, 10, 2, alpha=60)
        return
    cx = CX + lean
    # tentacles (behind the bell): 6 for the medusa, 4 for the dart
    n = 4 if dart else 6
    length = 9 if not dart else 6
    for k in range(n):
        t = (k - (n - 1) / 2) / max(1, (n - 1) / 2)
        x0 = cx + t * (rx - 1.5)
        y0 = cy + ry - 1
        wave = tent_bend + (1 if k % 2 else -1)
        pts = [(x0, y0), (x0 + wave * 0.6, y0 + length * 0.45), (x0 + wave * 1.4, y0 + length)]
        cv.path(pts, "tent", 2 if k % 2 else 1, width=1)
    # bell
    cv.ellipse(cx, cy, rx, ry, m, 2)
    cv.ellipse(cx - rx * 0.3, cy - ry * 0.35, rx * 0.45, ry * 0.4, m, 3, shade=False)
    cv.put(cx - rx * 0.45, cy - ry * 0.55, m, 4)
    if not dart:
        # medusa frills: a darker scalloped rim
        for k in range(int(-rx), int(rx) + 1, 2):
            cv.put(cx + k, cy + ry - 1, m, 1)
    if dart:
        # the dart: a long pointed cone in the facing direction, bright tip
        L = 8
        if facing == "down":
            for k in range(L):
                w = 7 - k
                cv.box(cx - w // 2, cy + ry + k - 2, max(1, w), 1, m, 3 if k < 3 else 2, shade=False)
            cv.put(cx, cy + ry + L - 2, "glow", 4)
        elif facing == "up":
            for k in range(L):
                w = 7 - k
                cv.box(cx - w // 2, cy - ry - k + 1, max(1, w), 1, m, 3 if k < 3 else 2, shade=False)
            cv.put(cx, cy - ry - L + 1, "glow", 4)
        else:
            for k in range(L + 1):
                w = 7 - k * 0.8
                cv.box(cx + rx + k - 2, cy - w / 2, 1, max(1, int(w)), m, 3 if k < 3 else 2, shade=False)
            cv.put(cx + rx + L - 1, cy, "glow", 4)
    # eyes on the bell's facing side
    ey = cy + (ry * 0.35 if facing == "down" else -ry * 0.1)
    if facing == "down":
        cv.put(cx - 2, ey, "eye", 0)
        cv.put(cx + 2, ey, "eye", 0)
        if anim in ("windup", "active"):
            cv.put(cx - 2, ey - 1, "glow", glow)
            cv.put(cx + 2, ey - 1, "glow", glow)
    elif facing == "right":
        cv.put(cx + rx - 3, ey, "eye", 0)
        cv.put(cx + rx - 1, ey + 1, "eye", 0)
    if anim == "active" and dart:
        # the shot: a streak leaving the dart tip
        if facing == "down":
            cv.line(cx, cy + ry + 6, cx, cy + ry + 11, "glow", 4)
        elif facing == "up":
            cv.line(cx, cy - ry - 7, cx, cy - ry - 12, "glow", 4)
        else:
            cv.line(cx + rx + 7, cy, cx + rx + 12, cy, "glow", 4)
    cv.edge_shade(["tent"])
    cv.shadow(cx, FEET + 1, rx * 0.8, 1.8, alpha=50)


# --------------------------------------------------------------------------
# LURKER: pale-green water memory - low, wide, ripples, two glowing eyes
# --------------------------------------------------------------------------
def lurker(cv, facing, anim, i, T):
    if anim == "dodge":
        anim, i = "idle", (0, 2)[i]
    m = "body"
    fx, fy = fdir(facing)
    cx, cy = CX, FEET - 6
    rx, ry = 9, 4
    eye = 3
    mouth = False
    if anim == "idle":
        r = (10, 12, 14, 12)[i]
        cv.ring(cx, cy + 1, r, r * 0.45, "water", 1 if i % 2 else 2, inner=0.85)
        eye = (3, 3, 4, 3)[i]
    elif anim == "walk":
        cx += fx * (0, 1, 2, 1, 0, -1)[i]
        cy += fy * (0, 1, 1, 0, 0, -1)[i]
        ry += (0, 0.5, 0, 0, 0.5, 0)[i]
        cv.ring(cx - fx * 4, cy + 1 - fy * 2, 11, 5, "water", 1, inner=0.85)
    elif anim == "windup":
        rx -= (1, 2)[i]
        ry -= (0.5, 1)[i]
        cy += (1, 1)[i]
        eye = 4
    elif anim == "active":
        rx += 1
        ry += (3, 2)[i]
        cy -= (3, 2)[i]
        cx += fx * 3
        cy += fy * 3
        mouth = True
        eye = 4
    elif anim == "hurt":
        ry -= 1
        cy += 1
        eye = 1
    elif anim == "dead":
        cv.ellipse(cx, FEET - 2, 10, 2.5, m, 1)
        cv.ring(cx, FEET - 1, 12, 4, "water", 1, inner=0.85)
        cv.shadow(cx, FEET + 1, 10, 2, alpha=50)
        return
    cv.ellipse(cx, cy, rx, ry, m, 2)
    cv.ellipse(cx - 2, cy - 1, rx * 0.5, ry * 0.45, m, 3, shade=False)
    # slick back line
    cv.line(cx - rx + 2, cy, cx + rx - 2, cy, m, 1)
    if facing == "down":
        cv.put(cx - 3, cy + 1, "glow", eye)
        cv.put(cx + 3, cy + 1, "glow", eye)
        if mouth:
            cv.box(cx - 3, cy + 3, 7, 2, "eye", 0)
            for k in (-2, 0, 2):
                cv.put(cx + k, cy + 3, "white", 4)
    elif facing == "right":
        cv.put(cx + rx - 3, cy, "glow", eye)
        cv.put(cx + rx - 5, cy - 1, "glow", eye)
        if mouth:
            cv.box(cx + rx - 3, cy + 2, 4, 2, "eye", 0)
            cv.put(cx + rx - 2, cy + 2, "white", 4)
    else:
        cv.put(cx - 3, cy - 1, "glow", max(1, eye - 2))
        cv.put(cx + 3, cy - 1, "glow", max(1, eye - 2))
    cv.shadow(cx, cy + ry + 1, rx, 1.5, alpha=40)


# --------------------------------------------------------------------------
# COIL: the serpent family
# --------------------------------------------------------------------------
def serpent_geo(facing, phase, big=False):
    """Rearing cobra. Returns (tail_pts, neck_pts, head, hood_dir_deg).
    Tail = a low loop on the ground; neck = an S rising to the head, which
    faces the camera side. Screen coords, frame space."""
    s = 1.2 if big else 1.0
    w = math.sin(phase) * 1.0
    if facing == "down":
        tail = [(CX + 9, FEET - 17), (CX + 6, FEET - 21), (CX, FEET - 22), (CX - 5, FEET - 19)]
        neck = [(CX - 5, FEET - 19), (CX - 6 + w, FEET - 15), (CX - 2 + w, FEET - 12), (CX + 1, FEET - 10), (CX, FEET - 8)]
        head = (CX, FEET - 7)
        hood = 90
    elif facing == "up":
        tail = [(CX - 9, FEET - 4), (CX - 6, FEET - 1), (CX, FEET - 2), (CX + 5, FEET - 5)]
        neck = [(CX + 5, FEET - 5), (CX + 6 + w, FEET - 9), (CX + 2 + w, FEET - 13), (CX - 1, FEET - 16), (CX, FEET - 19)]
        head = (CX, FEET - 22)
        hood = 270
    else:
        tail = [(CX - 4, FEET - 3), (CX - 10, FEET - 5), (CX - 11, FEET - 9), (CX - 6, FEET - 10)]
        neck = [(CX - 6, FEET - 10), (CX - 1, FEET - 8 + w), (CX + 3, FEET - 12 + w), (CX + 3, FEET - 17), (CX + 5, FEET - 20)]
        head = (CX + 8, FEET - 21)
        hood = 0

    def sc(pts):
        return [((x - CX) * s + CX, (y - FEET) * s + FEET) for x, y in pts]

    hx, hy = head
    return sc(tail), sc(neck), ((hx - CX) * s + CX, (hy - FEET) * s + FEET), hood


def serpent(cv, facing, anim, i, T):
    if anim == "dodge":
        anim, i = "idle", (0, 2)[i]
    kind = T.get("kind", "a")
    big = T.get("big", False)
    m = "body"
    fx, fy = fdir(facing)
    phase = 0.0
    head_dx, head_dy = 0, 0
    hood = 1           # 1 closed, 2 half, 3 open
    tongue = False
    eye = 3
    width = 4 if big else 3
    if kind == "b":
        width += 1
    if kind == "c":
        width -= 1
    if anim == "idle":
        phase = (0, 0.8, 1.6, 0.8)[i]
        head_dy = (0, -1, -1, 0)[i]
        tongue = i in (1, 2)
        hood = 1 if kind != "a" else 2
    elif anim == "walk":
        phase = i * (math.pi / 3)
        head_dx, head_dy = fx * (0, 1, 1, 0, -1, -1)[i], fy * (0, 1, 1, 0, -1, -1)[i]
    elif anim == "windup":
        head_dx, head_dy = -fx * (2, 3)[i], -fy * (2, 3)[i] - (1, 2)[i]
        hood = (2, 3)[i]
        eye = 4
    elif anim == "active":
        head_dx, head_dy = fx * (6, 5)[i], fy * (6, 5)[i] + (2, 1)[i]
        hood = 3
        tongue = True
        eye = 4
    elif anim == "hurt":
        head_dy = 3
        head_dx = -fx * 2
        eye = 1
    elif anim == "dead":
        pts = [(CX - 12, FEET - 3), (CX - 6, FEET - 5), (CX, FEET - 3), (CX + 6, FEET - 5), (CX + 10, FEET - 3)]
        cv.path(pts, m, 1, width=width)
        cv.ellipse(CX + 12, FEET - 4, 3 if not big else 3.5, 2, m, 1)
        cv.put(CX + 13, FEET - 4, "gold", 1)
        if kind == "b":
            cv.line(CX - 4, FEET - 5, CX - 2, FEET - 2, "crack", 0)
        cv.edge_shade([m])
        cv.shadow(CX, FEET + 1, 13, 2, alpha=60)
        return
    tail, neck, (hx, hy), hood_deg = serpent_geo(facing, phase, big)
    hx += head_dx
    hy += head_dy
    # tail loop (thin -> full), then the neck (full)
    cv.path(tail[:2], m, 1, width=max(1, width - 2))
    cv.path(tail[1:], m, 2, width=max(2, width - 1))
    neck2 = neck[:-1] + [(hx - fx * 2, hy - fy * 2)]
    cv.path(neck2, m, 2, width=width)
    if kind == "b":
        for k in range(0, len(neck2) - 1):
            x, y = neck2[k]
            cv.line(x - 1, y, x + 1, y + 1, "crack", 0)
        x, y = tail[2]
        cv.line(x, y - 1, x + 1, y + 1, "crack", 0)
    if kind == "c":
        for k in range(1, len(neck2)):
            x, y = neck2[k]
            cv.put(x - 1, y - 1, "glow", 4)
    cv.edge_shade([m])
    # HOOD: a flared shape behind the head (cobra), shards on a / boss
    hr = 3 if not big else 4
    shard_mat = "shard" if kind == "a" or big else m
    if hood >= 2 or kind == "a" or big:
        n = 3 if hood < 3 else 5
        spread = 70 if hood < 3 else 120
        base = hood_deg + 180  # the fan opens AWAY from the facing
        L = hr + (2 if hood < 3 else 4) + (1 if big else 0)
        if hood >= 2:
            cv.ellipse(hx - fx * 1.5, hy - fy * 1.5, hr + 1.5, hr + 1.0, m, 1, shade=False)
        for k in range(n):
            ang = base - spread / 2 + spread * (k / max(1, n - 1))
            ex, ey = hx + L * math.cos(math.radians(ang)), hy + L * math.sin(math.radians(ang))
            cv.line(hx, hy, ex, ey, shard_mat, 3 if k % 2 else 2, width=1)
            cv.put(ex, ey, shard_mat, 4)
    # wedge head: an ellipse + snout pixels toward the facing
    cv.ellipse(hx, hy, hr, hr * 0.8, m, 3)
    cv.put(hx + fx * (hr + 0.5), hy + fy * (hr * 0.8 + 0.5), m, 2)
    cv.put(hx + fx * (hr + 0.5) + fy, hy + fy * (hr * 0.8 + 0.5) + fx, m, 2)
    # eyes (gold glints) on the camera side
    if facing == "down":
        cv.put(hx - 1, hy + 1, "gold", eye)
        cv.put(hx + 1, hy + 1, "gold", eye)
    elif facing == "right":
        cv.put(hx + 1, hy - 1, "gold", eye)
        cv.put(hx + 2, hy, "gold", eye)
    if tongue:
        tx, ty = hx + fx * (hr + 1), hy + fy * (hr + 1)
        cv.line(tx, ty, tx + fx * 3, ty + fy * 3, "tongue", 3)
        cv.put(tx + fx * 3 + fy, ty + fy * 3 + fx, "tongue", 2)
        cv.put(tx + fx * 3 - fy, ty + fy * 3 - fx, "tongue", 2)
    if big:
        cv.box(hx - 3, hy - hr - 3, 7, 2, "crown", 2, shade=False)
        for k in (-3, 0, 3):
            cv.put(hx + k, hy - hr - 4, "gold", 4)
    cv.shadow(CX - 2, FEET + 1, 10 if not big else 12, 2.2, alpha=60)


# --------------------------------------------------------------------------
# EMBER RAM (ember_a): low armored quadruped, lava seams, wedge head
# --------------------------------------------------------------------------
def ram(cv, facing, anim, i, T):
    if anim == "dodge":
        anim, i = "idle", (0, 2)[i]
    m = "body"
    fx, fy = fdir(facing)
    cx, cy = CX, FEET - 8
    seam = 3
    stretch = 0
    crouch = 0
    legph = 0
    if anim == "idle":
        seam = (2, 3, 4, 3)[i]
        cy += (0, 0, 1, 0)[i]
    elif anim == "walk":
        legph = (0, 1, 2, 3, 2, 1)[i]
        cy += (0, -1, 0, 0, -1, 0)[i]
    elif anim == "windup":
        crouch = (1, 2)[i]
        cx -= fx * (1, 2)[i]
        cy -= fy * (1, 2)[i]
        seam = (2, 4)[i]
    elif anim == "active":
        stretch = (4, 3)[i]
        cx += fx * (3, 2)[i]
        cy += fy * (3, 2)[i]
        seam = 4
    elif anim == "hurt":
        crouch = 1
        seam = 1
    elif anim == "dead":
        cv.ellipse(CX, FEET - 4, 10, 3.5, m, 1)
        cv.ellipse(CX + 11, FEET - 5, 3.5, 2.5, m, 1)
        cv.line(CX + 12, FEET - 7, CX + 15, FEET - 9, "horn", 2)
        cv.line(CX - 7, FEET - 4, CX + 7, FEET - 4, "seam", 1)
        for k in (-8, -3, 3):
            cv.box(CX + k, FEET - 1, 3, 2, m, 0)
        cv.shadow(CX, FEET + 1, 13, 2, alpha=60)
        return
    if facing in ("down", "up"):
        bh = 12 - crouch
        top = cy - bh // 2
        cv.ellipse(cx, cy, 5.5, bh / 2, m, 2)
        sh_y = cy + bh // 2 - 3 if facing == "down" else top + 3
        cv.ellipse(cx, sh_y, 6.5, 3.5, m, 2)
        cv.line(cx, top + 1, cx, cy + bh // 2 - 1, "seam", seam)
        cv.line(cx - 3, cy - 1, cx + 3, cy - 1, "seam", seam - 1)
        cv.line(cx - 4, cy + 2, cx + 4, cy + 2, "seam", seam - 1)
        cv.ellipse(cx - 2, top + 3, 2, 1.5, m, 3, shade=False)
        for k, (lx, ly) in enumerate(((cx - 7, cy + 2), (cx + 5, cy + 2), (cx - 7, top + 1), (cx + 5, top + 1))):
            ph = (0, 1, 0, -1)[(legph + k) % 4]
            cv.box(lx, ly + ph, 3, 3, m, 1)
            cv.box(lx, ly + ph + 2, 3, 1, "horn", 1)
        if facing == "down":
            hy = cy + bh // 2 + 1 + stretch
            cv.ellipse(cx, hy + 1, 3.5, 2.5, m, 2)
            cv.box(cx - 1, hy + 3, 3, 2, m, 1)
            cv.put(cx - 2, hy, "glow", 4)
            cv.put(cx + 2, hy, "glow", 4)
            cv.line(cx - 4, hy - 1, cx - 6, hy - 4, "horn", 3)
            cv.line(cx + 4, hy - 1, cx + 6, hy - 4, "horn", 3)
            cv.put(cx - 6, hy - 5, "horn", 4)
            cv.put(cx + 6, hy - 5, "horn", 4)
            if stretch:
                for k in (-5, 0, 5):
                    cv.line(cx + k, top - 3 - stretch, cx + k, top - 1, "streak", 2)
        else:
            hy = top - 1 - stretch
            cv.ellipse(cx, hy - 1, 3.5, 2.5, m, 1)
            cv.line(cx - 4, hy, cx - 6, hy + 3, "horn", 2)
            cv.line(cx + 4, hy, cx + 6, hy + 3, "horn", 2)
            if stretch:
                for k in (-5, 0, 5):
                    cv.line(cx + k, cy + bh // 2 + 2, cx + k, cy + bh // 2 + 4 + stretch, "streak", 2)
    else:
        bw = 14 + stretch
        x0 = cx - bw // 2 - 1
        bh = 8 - crouch
        cv.ellipse(x0 + 4, cy, 4.5, bh / 2, m, 2)
        cv.box(x0 + 4, cy - bh // 2, bw - 7, bh, m, 2)
        cv.ellipse(x0 + bw - 3, cy - 1, 4, bh / 2 + 0.5, m, 2)
        cv.line(x0 + 2, cy - bh // 2 + 1, x0 + bw - 2, cy - bh // 2 + 1, "seam", seam)
        cv.line(x0 + bw // 2, cy - bh // 2 + 1, x0 + bw // 2, cy + bh // 2 - 1, "seam", seam - 1)
        cv.ellipse(x0 + 6, cy - 2, 2.5, 1.2, m, 3, shade=False)
        nx, ny = x0 + bw, cy - 3 + (2 if stretch else 0)
        cv.box(nx - 1, ny - 1, 3, 4, m, 2)
        cv.ellipse(nx + 3, ny, 3.5, 2.5, m, 2)
        cv.box(nx + 5, ny, 3, 2, m, 1)
        cv.put(nx + 3, ny - 1, "glow", 4)
        cv.line(nx + 1, ny - 3, nx - 3, ny - 6, "horn", 3)
        cv.line(nx + 2, ny - 3, nx - 1, ny - 7, "horn", 2)
        cv.put(nx - 3, ny - 7, "horn", 4)
        for k, lx in enumerate((x0 + 2, x0 + 5, x0 + bw - 7, x0 + bw - 4)):
            ph = (0, 1, 0, -1)[(legph + k) % 4]
            cv.box(lx + ph, cy + bh // 2 - 1, 2, 4 - abs(ph), m, 1)
            cv.box(lx + ph, cy + bh // 2 + 2 - abs(ph), 2, 1, "horn", 1)
        if stretch:
            for k in (-2, 1, 4):
                cv.line(x0 - 3 - stretch, cy + k, x0 - 1, cy + k, "streak", 2)
    cv.shadow(cx, FEET + 1.5, 9, 2, alpha=64)


# --------------------------------------------------------------------------
# BRAZIER (ember_b, ember_boss): a walking cauldron of coals
# --------------------------------------------------------------------------
def brazier(cv, facing, anim, i, T):
    if anim == "dodge":
        anim, i = "idle", (0, 2)[i]
    boss = T.get("big", False)
    m = "body"
    fx, fy = fdir(facing)
    cx, cy = CX, FEET - 7
    rx, ry = (7, 6) if not boss else (9, 7)
    coal = 3
    tilt = 0
    halo = 0
    flare = 0
    if anim == "idle":
        coal = (2, 3, 4, 3)[i]
    elif anim == "walk":
        tilt = (0, 1, 0, -1, 0, 1)[i] * (fx if fx else 1)
        cy += (0, -1, 0, 0, -1, 0)[i]
    elif anim == "windup":
        coal = (1, 1)[i]
        ry -= (1, 2)[i]
        cy += (1, 2)[i]
    elif anim == "active":
        coal = 4
        flare = (3, 2)[i]
        halo = (3, 2)[i]
        ry += (1, 0)[i]
    elif anim == "hurt":
        tilt = 2
        coal = 1
    elif anim == "dead":
        cv.ellipse(CX + 3, FEET - 3, rx, 3, m, 1)
        cv.ring(CX + 3, FEET - 3, rx - 1, 2, m, 0, inner=0.6)
        for k in ((-9, -1), (-6, 1), (-3, 0), (-8, 2)):
            cv.put(CX + k[0], FEET + k[1], "coal", 2)
        cv.shadow(CX, FEET + 1, 12, 2, alpha=60)
        return
    # legs
    for lx in (cx - rx + 2, cx, cx + rx - 3):
        cv.box(lx, FEET - 1, 2, 2, m, 0)
    # halo (active): a hot ring at the aura's inner edge
    if halo:
        cv.ring(cx, cy, rx + 4 + halo, ry + 3 + halo, "coal", 2, inner=0.8)
    # pot
    cv.ellipse(cx + tilt, cy, rx, ry, m, 2)
    cv.box(cx - rx + tilt, cy - ry, rx * 2, 2, m, 1)              # rim
    cv.ellipse(cx + tilt, cy - ry + 1, rx - 1.5, 1.5, "coal", coal)  # coals seen from above
    if flare:
        for k in range(-2, 3):
            cv.line(cx + tilt + k * 2, cy - ry - 1, cx + tilt + k * 3, cy - ry - 3 - flare + abs(k), "coal", 3 + (k % 2))
    else:
        # embers: 2-3 floating sparks, positions shift with i (deterministic)
        for k in range(2 + (1 if boss else 0)):
            ex = cx + tilt + (-3, 2, 0)[k] + (i % 2)
            ey = cy - ry - 2 - ((i + k) % 3)
            cv.put(ex, ey, "coal", 3 + (k % 2))
    # face: two eye slits glow on the facing side
    if facing == "down":
        cv.box(cx + tilt - 3, cy + 1, 2, 1, "coal", coal + 1)
        cv.box(cx + tilt + 2, cy + 1, 2, 1, "coal", coal + 1)
    elif facing == "right":
        cv.box(cx + tilt + rx - 4, cy, 2, 1, "coal", coal + 1)
    if boss:
        # crown of flame: dark band + gold tips over the rim
        cv.box(cx + tilt - 4, cy - ry - 4, 9, 2, "crown", 2, shade=False)
        for k in (-4, 0, 4):
            cv.put(cx + tilt + k, cy - ry - 5, "gold", 4)
    cv.shadow(cx, FEET + 1.5, rx + 1, 2, alpha=64)


# --------------------------------------------------------------------------
# BEACON (ember_d): a tall stone pillar with one great eye
# --------------------------------------------------------------------------
def beacon(cv, facing, anim, i, T):
    if anim == "dodge":
        anim, i = "idle", (0, 2)[i]
    m = "body"
    fx, fy = fdir(facing)
    cx = CX
    top = FEET - 25
    w = 8
    eye_open = 2
    eye_glow = 3
    sway = 0
    cracked = False
    beam = 0
    if anim == "idle":
        eye_glow = (2, 3, 4, 3)[i]
        sway = (0, 0, 1, 0)[i]
    elif anim == "walk":
        sway = (0, 1, 1, 0, -1, -1)[i]
        top += (0, -1, 0, 0, -1, 0)[i]
    elif anim == "windup":
        eye_open = (1, 1)[i]
        eye_glow = 4
    elif anim == "active":
        eye_open = 3
        eye_glow = 4
        beam = (10, 7)[i]
    elif anim == "hurt":
        cracked = True
        eye_glow = 1
    elif anim == "dead":
        cv.box(CX - 12, FEET - 5, 24, 4, m, 1)
        cv.box(CX - 12, FEET - 5, 6, 4, m, 2)
        cv.ellipse(CX + 6, FEET - 3, 2.5, 1.5, "glow", 1)
        cv.line(CX - 4, FEET - 5, CX - 2, FEET - 2, "crack", 0)
        cv.shadow(CX, FEET + 1, 13, 2, alpha=60)
        return
    x0 = cx - w // 2 + sway
    h = FEET - 1 - top
    cv.box(x0, top, w, h, m, 2)
    cv.box(x0 + 1, top, 2, h, m, 3, shade=False)
    cv.box(x0 + w - 2, top, 1, h, m, 1, shade=False)
    # base flare
    cv.box(x0 - 1, FEET - 3, w + 2, 3, m, 1)
    # cap
    cv.box(x0 - 1, top - 1, w + 2, 2, m, 3)
    cv.put(x0 + w // 2, top - 2, "glow", 3)
    if cracked:
        cv.line(x0 + 2, top + 5, x0 + 5, top + 12, "crack", 0)
        cv.line(x0 + 5, top + 12, x0 + 3, top + 17, "crack", 0)
    # the eye (facing side)
    ey = top + 8
    if facing == "down":
        cv.ellipse(cx + sway, ey, 3, eye_open, "glow", eye_glow)
        cv.put(cx + sway, ey, "white", 4 if eye_glow >= 3 else 2)
    elif facing == "right":
        cv.ellipse(cx + sway + 2, ey, 2, eye_open, "glow", eye_glow)
        cv.put(cx + sway + 2, ey, "white", 4 if eye_glow >= 3 else 2)
    else:
        cv.box(cx + sway - 2, ey, 5, 1, "glow", max(1, eye_glow - 1))
    if beam:
        if facing == "down":
            cv.line(cx + sway, ey + 3, cx + sway, ey + 3 + beam, "glow", 4)
            cv.line(cx + sway - 1, ey + 3, cx + sway - 1, ey + beam, "glow", 2)
        elif facing == "up":
            cv.line(cx + sway, top - 3, cx + sway, top - 3 - beam // 2, "glow", 4)
        else:
            cv.line(cx + sway + 4, ey, cx + sway + 4 + beam, ey, "glow", 4)
            cv.line(cx + sway + 4, ey + 1, cx + sway + beam, ey + 1, "glow", 2)
    cv.shadow(cx, FEET + 1.5, 6, 1.8, alpha=64)


# --------------------------------------------------------------------------
# MUSHROOM (spore_a thin dripping cap / spore_b broad colony)
# --------------------------------------------------------------------------
def mushroom(cv, facing, anim, i, T):
    if anim == "dodge":
        anim, i = "idle", (0, 2)[i]
    broad = T.get("broad", False)
    m = "cap"
    fx, fy = fdir(facing)
    cx = CX
    stem_w = 3 if not broad else 6
    cap_rx, cap_ry = (7, 4) if not broad else (10, 4.5)
    cap_cy = FEET - 14 if not broad else FEET - 11
    tilt = 0
    squash = 0
    puff = 0
    lean = 0
    if anim == "idle":
        tilt = (0, 1, 0, -1)[i]
    elif anim == "walk":
        tilt = (0, 1, 1, 0, -1, -1)[i]
        lean = fx * (0, 1, 1, 0, 0, 0)[i]
        cap_cy += (0, -1, 0, 0, -1, 0)[i]
    elif anim == "windup":
        squash = (1, 2)[i]
        cap_cy += (1, 2)[i]
    elif anim == "active":
        cap_cy -= (1, 0)[i]
        cap_rx += 1
        puff = (4, 6)[i]
    elif anim == "hurt":
        tilt = 2
        squash = 1
    elif anim == "dead":
        cv.ellipse(CX + 2, FEET - 4, cap_rx, 2.5, m, 1)
        cv.box(CX - 9, FEET - 4, 7, stem_w, "stem", 1)
        cv.ellipse(CX, FEET, 12, 2, "puddle", 2, shade=False)
        cv.shadow(CX, FEET + 1, 12, 2, alpha=50)
        return
    # puddle (spore_b leaves a sick-green puddle)
    if broad:
        cv.ellipse(cx, FEET, 11, 2, "puddle", 2, shade=False)
        cv.ellipse(cx - 3, FEET - 0.5, 4, 1, "puddle", 3, shade=False)
    # stem
    stem_top = cap_cy + cap_ry - 1
    cv.box(cx - stem_w // 2 + lean, stem_top, stem_w, FEET - stem_top, "stem", 2)
    if broad:
        cv.box(cx - 1 + lean, stem_top + 2, 1, FEET - stem_top - 3, "stem", 3, shade=False)
    # feet (two nubs)
    cv.box(cx - stem_w // 2 - 1 + lean, FEET, 2, 2, "stem", 1)
    cv.box(cx + stem_w // 2 - 1 + lean, FEET, 2, 2, "stem", 1)
    # cap
    ccx = cx + tilt + lean
    cv.ellipse(ccx, cap_cy, cap_rx, cap_ry - squash, m, 2)
    cv.box(ccx - cap_rx + 1, cap_cy + cap_ry - squash - 1, cap_rx * 2 - 2, 1, m, 1, shade=False)  # underside
    cv.ellipse(ccx - cap_rx * 0.35, cap_cy - cap_ry * 0.4, cap_rx * 0.4, 1.2, m, 3, shade=False)
    # spots
    for k, (sx, sy) in enumerate(((-3, -1), (2, -2), (4, 0), (-1, 1))):
        if k >= (3 if not broad else 4):
            break
        cv.put(ccx + sx, cap_cy + sy, "spot", 3 if k % 2 else 4)
    if broad:
        # little caps on the back
        for k, (sx, sy) in enumerate(((-6, -3), (4, -4), (0, -5))):
            cv.ellipse(ccx + sx, cap_cy + sy, 2, 1.2, m, 3 - (k % 2))
    else:
        # drips under the thin cap
        for sx in (-4, 1, 5):
            cv.put(ccx + sx, cap_cy + cap_ry - squash, "puddle", 3)
            cv.put(ccx + sx, cap_cy + cap_ry - squash + 1 + (i % 2), "puddle", 2)
    # eyes on the stem (facing side)
    ey = stem_top + 2
    if facing == "down":
        cv.put(cx - 1 + lean, ey, "eye", 0)
        cv.put(cx + 1 + lean, ey, "eye", 0)
        if broad:
            cv.put(cx - 2 + lean, ey, "eye", 0)
            cv.put(cx + 2 + lean, ey, "eye", 0)
    elif facing == "right":
        cv.put(cx + stem_w // 2 - 1 + lean, ey, "eye", 0)
    if puff:
        # spore puff: pale specks bursting out from under the cap
        for k in range(6):
            a = math.radians(k * 60 + 30)
            cv.put(ccx + puff * math.cos(a), cap_cy + 1 + puff * 0.6 * math.sin(a), "spot", 4)
    cv.shadow(cx + lean, FEET + 1.5, cap_rx * 0.7, 1.8, alpha=56)

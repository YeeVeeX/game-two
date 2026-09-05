"""PREMIUM v22 humanoid rig: one body, many skins. Drawn for facings down /
up / right (left = mirror). Proportions (frame rows): head 12..19, torso
20..29, legs 30..39, boots 40..41, shadow 42..44. Head ~9px wide, body 11.
Pose parameters come from (anim, i); the skin (T) says hood/helmet/hair/
mask, wraps/plate/jacket, weapon, roots, eyes."""
from __future__ import annotations

from .core import CX, FEET, sgn


def pose(anim, i, T):
    tall = T.get("tall", 0)
    slouch = T.get("slouch", 0)
    p = dict(body_dy=0, leg=None, swing=0, wstate="rest", squash=0, blink=False,
             scarf=(0, 0, 1, 1)[i] if anim == "idle" else 0)
    if anim == "idle":
        p["body_dy"] = (0, 0, 1, 1)[i]
        p["blink"] = i == 3
    elif anim == "walk":
        p["leg"] = i
        p["body_dy"] = (0, -1, 0, 0, -1, 0)[i]
        p["swing"] = (1, 2, 1, -1, -2, -1)[i]
        p["scarf"] = (1, 2, 1, 1, 2, 1)[i]
    elif anim == "windup":
        p["body_dy"] = (1, 2)[i]
        p["wstate"] = ("back", "back2")[i]
    elif anim == "active":
        p["body_dy"] = (-1, 0)[i]
        p["wstate"] = ("strike", "strike2")[i]
        p["scarf"] = 2
    elif anim == "hurt":
        p["body_dy"], p["squash"], p["blink"] = 1, 1, True
    elif anim == "dodge":
        # tuck: body drops 3px, torso compresses 2, head ducks; frame 1 leans
        # further into the roll (legs together, arms in) — a ball, not a stance
        p["body_dy"] = (3, 4)[i]
        p["squash"] = (2, 2)[i]
        p["blink"] = True
        p["swing"] = 0
        p["scarf"] = 2
        p["tuck"] = (1, 2)[i]
    elif anim == "glance":
        # secondary idle: head turns (eyes further), then the weapon hand fidgets
        p["body_dy"] = 1
        p["glance"] = 1
        p["wstate"] = ("rest", "adjust")[i]
        p["scarf"] = 1
    elif anim == "special":
        # the SPECIAL: deep crouch (anticipation) -> lunge with its own fx
        p["body_dy"] = (2, -1)[i]
        p["squash"] = (1, 0)[i]
        p["wstate"] = ("sp_back", "sp_strike")[i]
        p["scarf"] = 2
    p["head_cy"] = 16 + p["body_dy"] - tall + slouch
    p["torso_top"] = p["head_cy"] + 5 + p["squash"]
    p["torso_h"] = 9 - p["squash"] + tall - slouch
    p["legs_top"] = p["torso_top"] + p["torso_h"]
    return p


# ---- parts -----------------------------------------------------------------
def legs(cv, facing, P, T):
    top = P["legs_top"]
    leg = P["leg"]
    boot_h = 2
    h = max(3, FEET - boot_h - top + 1)
    tuck = P.get("tuck", 0)
    if facing in ("down", "up"):
        for side, x0 in ((-1, CX - 5 + tuck), (1, CX + 1 - tuck)):  # tuck: legs together
            dy = 0
            dx = 0
            if leg is not None:
                ph = (0, 1, 1, 0, -1, -1)[leg] * side
                dy = -max(0, ph)          # the swinging leg lifts
                dx = (0, 0, 1, 0, 0, -1)[leg] * side  # and splays a px
            cv.box(x0 + dx, top + dy, 4, h - dy, "pants", 2 if side < 0 else 1)
            cv.box(x0 + dx - (1 if side < 0 else 0), FEET - boot_h + 1 + dy, 5, boot_h, "boot", 2 if dy == 0 else 3)
        if T.get("roots"):
            cv.line(CX + 2, top + 1, CX + 3, FEET - 3, "root", 1)
    else:  # right profile: legs scissor horizontally
        stride = 0
        if leg is not None:
            stride = (0, 2, 3, 0, -2, -3)[leg]
        back_x = CX - 2 - stride + tuck
        front_x = CX - 1 + stride - tuck
        cv.box(back_x, top, 4, h, "pants", 1)
        cv.box(back_x - 1, FEET - boot_h + 1, 5, boot_h, "boot", 1)
        cv.box(front_x, top, 4, h, "pants", 2)
        cv.box(front_x, FEET - boot_h + 1, 5, boot_h, "boot", 2)
        if T.get("roots"):
            cv.line(front_x + 2, top + 1, front_x + 1, FEET - 3, "root", 1)


def torso(cv, facing, P, T):
    top, h = P["torso_top"], P["torso_h"]
    mat = T.get("torso", "cloth")
    if facing in ("down", "up"):
        w = 11 + (2 if T.get("plate") else 0)
        x0 = CX - w // 2
        cv.box(x0, top, w, h, mat, 2)
        if T.get("plate"):
            cv.box(x0 - 1, top, 3, 3, "armor", 3)
            cv.box(x0 + w - 2, top, 3, 3, "armor", 2)
            cv.box(x0 + 2, top + 2, w - 4, 1, "armor", 1)
            cv.box(CX - 1, top + 3, 2, h - 4, "armor", 3)
        elif T.get("wraps"):
            if T.get("torn"):
                # husk: torn strips, one hanging rag, bone showing through
                cv.box(x0 + 1, top + 2, w - 5, 1, mat, 1)
                cv.box(x0 + 4, top + 4, w - 5, 1, mat, 1)
                cv.box(x0 + 1, top + 6, w - 3, 1, mat, 1)
                cv.box(x0 + 2, top + 3, 2, 1, "bone", 3)
                cv.box(x0 + w - 3, top + h, 2, 2, mat, 1, shade=False)  # rag
            else:
                for yy in range(top + 1, top + h - 1, 2):
                    cv.box(x0 + 1, yy, w - 2, 1, mat, 1)
                cv.box(x0 + 3, top + 1, w - 6, 1, mat, 3)
        elif T.get("jacket"):
            cv.box(CX, top + 1, 1, h - 2, mat, 0)
            cv.box(x0 + 1, top, w - 2, 1, "cloth2", 3)
        if facing == "down" and T.get("satchel"):
            cv.box(x0 + w - 3, top + 3, 4, 4, "leather", 2)
            cv.put(x0 + w - 1, top + 4, "gold", 3)
        cv.box(x0 + 1, top + h - 1, w - 2, 1, "leather", 1)  # belt
        cv.put(CX, top + h - 1, "gold", 3)
        if T.get("roots") and facing == "down":
            cv.line(x0 + 2, top + 1, x0 + 4, top + h - 2, "root", 1)
            cv.line(x0 + w - 3, top + 2, x0 + w - 4, top + h - 3, "root", 1)
    else:
        w = 8 + (1 if T.get("plate") else 0)
        x0 = CX - w // 2
        cv.box(x0, top, w, h, mat, 2)
        if T.get("plate"):
            cv.box(x0 + 1, top, 4, 3, "armor", 3)
            cv.box(x0 + 1, top + 3, w - 2, 1, "armor", 1)
        elif T.get("wraps"):
            for yy in range(top + 1, top + h - 1, 2):
                cv.box(x0 + 1, yy, w - 2, 1, mat, 1)
        elif T.get("jacket"):
            cv.box(x0 + w - 3, top + 1, 1, h - 2, mat, 0)
        if T.get("satchel"):
            cv.box(x0 - 1, top + 3, 3, 4, "leather", 2)
        cv.box(x0, top + h - 1, w, 1, "leather", 1)
        if T.get("roots"):
            cv.line(x0 + 2, top + 1, x0 + 3, top + h - 2, "root", 1)


def cloak(cv, facing, P, T):
    """Tattered cloak (challenger): falls behind the torso to the boots,
    ragged hem. Drawn BEFORE torso/legs when facing down, after when up."""
    top = P["torso_top"] - 1
    w = 15
    x0 = CX - w // 2
    bottom = FEET - 2
    for y in range(top, bottom + 1):
        ww = w if y < bottom - 2 else w - 2 * (y - (bottom - 3))
        xx = CX - ww // 2
        cv.box(xx, y, ww, 1, "cloak", 2 if (y - top) % 3 else 1, shade=False)
    for k, x in enumerate(range(x0, x0 + w, 2)):
        if k % 2:
            cv.erase(x, bottom)
            cv.erase(x, bottom - 1)
    cv.box(x0, top, 2, bottom - top - 2, "cloak", 3, shade=False)


def arms(cv, facing, P, T):
    top = P["torso_top"]
    mat = T.get("sleeve", T.get("torso", "cloth"))
    swing = P["swing"]
    h = P["torso_h"] - 1 - P.get("tuck", 0)
    hand = "skin" if not T.get("gloves") else "leather"
    if facing in ("down", "up"):
        w = 11 + (2 if T.get("plate") else 0)
        x0 = CX - w // 2
        for side, ax in ((-1, x0 - 3), (1, x0 + w)):
            dy = swing * side
            dy = max(-2, min(2, dy))
            cv.box(ax, top + 1 + dy, 3, h - 2, mat, 2 if side < 0 else 1)
            cv.box(ax, top + h - 1 + dy, 3, 2, hand, 2)
            if T.get("roots") and side > 0:
                cv.line(ax + 1, top + 2, ax + 1, top + h - 2, "root", 1)
    else:
        w = 8 + (1 if T.get("plate") else 0)
        x0 = CX - w // 2
        # back arm (peeks behind), front arm swings opposite the front leg
        dx = max(-2, min(2, swing))
        cv.box(x0 - 1 - dx, top + 2, 2, h - 3, mat, 1)
        cv.box(x0 + w - 3 + dx, top + 1, 3, h - 2, mat, 2)
        cv.box(x0 + w - 3 + dx, top + h - 1, 3, 2, hand, 2)
        if T.get("roots"):
            cv.line(x0 + w - 2 + dx, top + 2, x0 + w - 2 + dx, top + h - 2, "root", 1)


def head(cv, facing, P, T):
    cy = P["head_cy"]
    cx = CX if facing != "right" else CX + 1
    if T.get("lean"):
        cx += {"down": 0, "up": 0, "right": 2}[facing]
    g = P.get("glance", 0)
    if g:
        if facing == "down":
            cx += g          # the head turns a px...
        elif facing == "right":
            cy -= g          # ...or nods
    r = 4.5
    skin = T.get("skin", "skin")
    cv.ellipse(cx, cy, r, r, skin, 2)
    style = T.get("head", "hair")
    if style == "hood":
        m = T.get("hood_mat", "cloth")
        if facing == "down":
            cv.ellipse(cx, cy - 0.5, r + 0.5, r, m, 2)
            cv.box(cx - 2, cy - 1, 5, 4, skin, 2)      # face window
            cv.box(cx - 2, cy - 1, 5, 1, skin, 1)      # brim shadow
            cv.put(cx, cy - 6, m, 3)                   # peak
            cv.put(cx, cy - 5, m, 3)
        elif facing == "up":
            cv.ellipse(cx, cy - 0.5, r + 0.5, r, m, 2)
            cv.put(cx, cy - 6, m, 3)
            cv.put(cx, cy - 5, m, 3)
        else:
            cv.ellipse(cx - 1, cy - 0.5, r, r, m, 2)
            cv.box(cx + 1, cy - 1, 3, 4, skin, 2)
            cv.put(cx - 1, cy - 6, m, 3)
            cv.put(cx - 1, cy - 5, m, 3)
    elif style == "helmet":
        m = "armor"
        cv.ellipse(cx, cy - 0.5, r + 0.5, r, m, 2)
        if facing == "down":
            cv.box(cx - 3, cy - 1, 7, 2, "eye", 0)           # visor slit
            cv.box(cx, cy - 1, 1, 4, m, 3)                   # nose guard
            cv.box(cx - 2, cy + 2, 5, 2, skin, 2)            # chin
        elif facing == "right":
            cv.box(cx + 1, cy - 1, 4, 2, "eye", 0)
            cv.box(cx + 1, cy + 2, 3, 2, skin, 2)
        cv.line(cx, cy - 7, cx, cy - 5, "accent", 3)         # crest
        cv.put(cx, cy - 8, "accent", 4)
    elif style == "hair":
        m = "hair"
        if facing == "down":
            cv.ellipse(cx, cy - 1.5, r + 0.5, r - 1.5, m, 2)
            cv.box(cx - 5, cy - 1, 1, 3, m, 1)
            cv.box(cx + 4, cy - 1, 1, 3, m, 1)
            cv.put(cx - 2, cy - 6, m, 3)
        elif facing == "up":
            cv.ellipse(cx, cy - 0.5, r + 0.5, r, m, 2)
            cv.put(cx - 2, cy - 6, m, 3)
        else:
            cv.ellipse(cx - 1, cy - 1.5, r, r - 1.5, m, 2)
            cv.box(cx - 5, cy - 1, 2, 4, m, 1)
            cv.put(cx - 3, cy - 6, m, 3)
    elif style == "mask":
        # challenger: cream bone mask, dark tatters above, two slits
        cv.ellipse(cx, cy - 2, r + 0.5, r - 1, "cloak", 1)
        cv.ellipse(cx, cy + 0.5, r - 0.5, r - 1, "bone", 3)
        if facing == "down":
            cv.box(cx - 3, cy, 2, 1, "eye", 0)
            cv.box(cx + 2, cy, 2, 1, "eye", 0)
            cv.put(cx, cy + 2, "bone", 1)
        elif facing == "right":
            cv.box(cx + 1, cy, 3, 1, "eye", 0)
        cv.put(cx - 1, cy - 7, "cloak", 1)
        cv.put(cx + 1, cy - 7, "cloak", 1)
        cv.put(cx, cy - 6, "cloak", 2)
    elif style == "skull":
        # husk: bone head, hollow sockets, root threads
        cv.ellipse(cx, cy, r, r, "bone", 2)
        cv.line(cx - 3, cy - 4, cx + 1, cy - 1, "root", 1)
        if facing == "up":
            cv.line(cx - 1, cy - 3, cx + 3, cy + 2, "root", 1)
    # eyes
    if style not in ("helmet", "mask", "skull") or style == "skull":
        eye_mat = T.get("eye", "eye")
        eye_tone = 0 if eye_mat == "eye" else 3
        if facing == "down":
            if P["blink"]:
                cv.put(cx - 2, cy, skin if style != "skull" else "bone", 1)
                cv.put(cx + 2, cy, skin if style != "skull" else "bone", 1)
            elif style == "skull":
                cv.box(cx - 3, cy - 1, 2, 2, eye_mat, eye_tone)
                cv.box(cx + 2, cy - 1, 2, 2, eye_mat, eye_tone)
            else:
                cv.put(cx - 2 + g, cy, eye_mat, eye_tone)   # ...and the eyes go further
                cv.put(cx + 2 + g, cy, eye_mat, eye_tone)
        elif facing == "right":
            if P["blink"]:
                cv.put(cx + 2, cy, skin if style != "skull" else "bone", 1)
            elif style == "skull":
                cv.box(cx + 2, cy - 1, 2, 2, eye_mat, eye_tone)
            else:
                cv.put(cx + 2, cy, eye_mat, eye_tone)
    # neck
    cv.box(CX - 1, cy + 4, 2, 1, skin, 1)


def scarf(cv, facing, P, T):
    if not T.get("scarf"):
        return
    m = T.get("scarf_mat", "cloth")
    top = P["torso_top"]
    k = P["scarf"]
    if facing == "down":
        cv.box(CX - 5, top, 10, 2, m, 3)
        cv.line(CX - 6, top + 1, CX - 8 - k, top + 5 + k, m, 2)
        cv.line(CX - 7 - k, top + 5 + k, CX - 7 - k, top + 8 + k, m, 1)
    elif facing == "up":
        cv.box(CX - 5, top, 10, 2, m, 3)
        cv.line(CX + 1, top + 2, CX + 3 + k, top + 9 + k, m, 2)
        cv.line(CX + 2, top + 2, CX + 4 + k, top + 9 + k, m, 1)
    else:
        cv.box(CX - 4, top, 8, 2, m, 3)
        cv.line(CX - 4, top + 1, CX - 8 - k, top + 4 + k, m, 2)
        cv.line(CX - 5, top + 2, CX - 9 - k, top + 5 + k, m, 1)


# ---- weapons -----------------------------------------------------------------
def hand_xy(facing, P, T, side):
    top = P["torso_top"]
    h = P["torso_h"] - 1
    w = 11 + (2 if T.get("plate") else 0)
    x0 = CX - w // 2
    if facing in ("down", "up"):
        ax = x0 - 3 if side < 0 else x0 + w
        return ax + 1, top + h
    return CX + 3 + max(-2, min(2, P["swing"])), top + h


def blade(cv, facing, P, T, st):
    hx, hy = hand_xy(facing, P, T, 1)
    if facing == "right":
        if st == "rest":
            cv.line(hx + 1, hy, hx + 3, hy + 6, "metal", 3)
            cv.put(hx + 1, hy, "gold", 3)
        elif st.startswith("back"):
            cv.line(hx - 2, hy - 2, hx - 7, hy - 8, "metal", 3)
            cv.put(hx - 2, hy - 2, "gold", 3)
        else:
            cv.line(hx + 2, hy - 2, hx + 11, hy - 2, "metal", 4)
            cv.box(hx + 2, hy - 1, 10, 1, "metal", 2)
            cv.put(hx + 2, hy - 2, "gold", 3)
            if st == "strike":
                cv.arc(hx + 2, hy - 2, 11, -70, 60, "streak", 4)
                cv.arc(hx + 2, hy - 2, 9, -50, 40, "streak", 3)
            else:
                cv.arc(hx + 2, hy - 2, 11, 10, 70, "streak", 2)
    elif facing == "down":
        if st == "rest":
            cv.line(hx, hy, hx, hy + 7, "metal", 3)
            cv.box(hx - 1, hy, 3, 1, "gold", 3)
        elif st.startswith("back"):
            cv.line(hx + 1, hy - 3, hx + 6, hy - 12, "metal", 3)
            cv.box(hx, hy - 3, 3, 1, "gold", 3)
        else:
            cv.line(hx - 2, hy + 1, hx - 2, hy + 10, "metal", 4)
            cv.box(hx - 3, hy + 1, 3, 1, "gold", 3)
            if st == "strike":
                cv.arc(CX, hy + 1, 12, 20, 160, "streak", 4)
                cv.arc(CX, hy + 1, 10, 40, 140, "streak", 3)
            else:
                cv.arc(CX, hy + 1, 12, 90, 165, "streak", 2)
    else:  # up: weapon behind the body (drawn before)
        if st == "rest":
            cv.line(hx, hy - 2, hx, hy + 5, "metal", 2)
        elif st.startswith("back"):
            cv.line(hx, hy, hx + 4, hy + 8, "metal", 2)
        else:
            cv.line(hx - 2, hy - 14, hx - 2, hy - 4, "metal", 4)
            if st == "strike":
                cv.arc(CX, P["head_cy"] - 3, 12, 200, 340, "streak", 4)
                cv.arc(CX, P["head_cy"] - 3, 10, 220, 320, "streak", 3)
            else:
                cv.arc(CX, P["head_cy"] - 3, 12, 195, 260, "streak", 2)


def shield(cv, facing, P, T, st, before):
    """Aro's round shield: rust rim, iron boss, engraved ring. Left arm.
    before=True draws the part that sits behind the body (up facing)."""
    top = P["torso_top"]
    if facing == "down":
        if before:
            return
        sx, sy = CX - 9, top + 4
        if st.startswith("back"):
            sx += 1
            sy -= 1
        if st.startswith("strike"):
            sx += 3
            sy -= 2
        cv.ellipse(sx, sy, 4.5, 5, "armor", 2)
        cv.ring(sx, sy, 3, 3.5, "metal", 2, inner=0.55)
        cv.ellipse(sx, sy, 1.2, 1.2, "metal", 3)
    elif facing == "up":
        if not before:
            return
        sx, sy = CX + 7, top + 4
        cv.ellipse(sx, sy, 4.5, 5, "armor", 1)
        cv.ring(sx, sy, 3, 3.5, "metal", 1, inner=0.55)
    else:
        if before:
            return
        sx, sy = CX + 6, top + 4
        if st.startswith("back"):
            sx -= 2
        if st.startswith("strike"):
            sx += 3
        cv.ellipse(sx, sy, 2.5, 5.5, "armor", 2)
        cv.ring(sx, sy, 1.5, 3.8, "metal", 2, inner=0.4)
    if st.startswith("strike"):
        # shield bash: a short streak where the rim lands
        if facing == "down":
            cv.arc(CX - 6, top + 2, 8, 40, 130, "streak", 3)
        elif facing == "right":
            cv.arc(CX + 9, top + 4, 6, -60, 60, "streak", 3)


def sling(cv, facing, P, T, st):
    hx, hy = hand_xy(facing, P, T, 1)
    if facing == "up":
        # behind the body
        if st == "rest":
            cv.line(hx, hy - 3, hx, hy + 2, "leather", 2)
            cv.put(hx, hy + 3, "stone", 2)
        elif st.startswith("back"):
            cv.arc(CX, P["head_cy"] - 6, 6, 180, 360, "leather", 2)
            cv.put(CX + 6, P["head_cy"] - 6, "stone", 3)
        else:
            cv.line(CX, P["head_cy"] - 4, CX, P["head_cy"] - 12, "streak", 3)
            cv.put(CX, P["head_cy"] - 13, "stone", 3)
        return
    if st == "rest":
        cv.line(hx, hy, hx + 1, hy + 5, "leather", 2)
        cv.ellipse(hx + 1, hy + 6, 1, 1, "stone", 2)
    elif st.startswith("back"):
        # whirl overhead: an arc above the head with the stone at its end
        cy = P["head_cy"] - 5
        a = 200 if st == "back" else 260
        cv.arc(CX, cy, 7, a - 120, a, "leather", 2)
        cv.put(CX + 7 * __import__("math").cos(__import__("math").radians(a)),
               cy + 7 * __import__("math").sin(__import__("math").radians(a)), "stone", 3)
    else:
        # release: sling snaps forward, stone flies with a streak
        if facing == "down":
            cv.line(hx, hy, hx + 1, hy + 6, "leather", 2)
            cv.line(CX + 3, hy + 4, CX + 3, hy + 11, "streak", 3)
            cv.ellipse(CX + 3, hy + 12, 1, 1, "stone", 3)
        else:
            cv.line(hx, hy, hx + 5, hy - 1, "leather", 2)
            cv.line(hx + 6, hy - 2, hx + 12, hy - 2, "streak", 3)
            cv.ellipse(hx + 12, hy - 2, 1, 1, "stone", 3)


def staff(cv, facing, P, T, st, before):
    """The singer's bone staff with a skull knob; the chant is a blue
    throat-glow that swells on windup."""
    top = P["torso_top"]
    if facing == "up":
        if not before:
            return
        cv.line(CX + 6, top - 6, CX + 6, FEET - 3, "bone", 2)
        cv.ellipse(CX + 6, top - 7, 1.5, 1.5, "bone", 3)
        return
    if before:
        return
    if facing == "down":
        x = CX + 8
        if st == "rest" or st == "hurt":
            cv.line(x, top - 6, x, FEET - 3, "bone", 2)
            cv.ellipse(x, top - 7, 1.5, 1.5, "bone", 3)
            cv.put(x, top - 7, "eye", 0)
        elif st.startswith("back"):
            cv.line(CX - 7, top - 5, CX + 8, top - 5, "bone", 2)
            cv.ellipse(CX + 9, top - 5, 1.5, 1.5, "bone", 3)
            g = 2 if st == "back" else 3
            cv.ring(CX, top + 1, g + 1, g, "blueglow", 3, inner=0.5)
            cv.put(CX, top + 1, "blueglow", 4)
        else:
            cv.line(x - 2, top - 2, x - 2, FEET + 1, "bone", 2)
            cv.ellipse(x - 2, FEET + 1, 1.5, 1.5, "bone", 3)
            cv.arc(CX, top + 8, 9, 30, 150, "blueglow", 3)
    else:
        x = CX + 5
        if st == "rest" or st == "hurt":
            cv.line(x, top - 6, x, FEET - 3, "bone", 2)
            cv.ellipse(x, top - 7, 1.5, 1.5, "bone", 3)
        elif st.startswith("back"):
            cv.line(CX - 6, top - 4, CX + 6, top - 4, "bone", 2)
            cv.ellipse(CX - 7, top - 4, 1.5, 1.5, "bone", 3)
            g = 2 if st == "back" else 3
            cv.ring(CX + 1, top + 1, g, g, "blueglow", 3, inner=0.5)
        else:
            cv.line(x, top - 2, x + 9, top + 6, "bone", 2)
            cv.ellipse(x + 10, top + 7, 1.5, 1.5, "bone", 3)
            cv.arc(CX + 4, top + 4, 8, -50, 60, "blueglow", 3)


FDIR = {"down": (0, 1), "up": (0, -1), "right": (1, 0)}


def weapon(cv, facing, P, T, before):
    w = T.get("weapon")
    st = P["wstate"]
    if P.get("tuck"):
        return  # the roll: no weapon out (arms in)
    big = False
    if st == "adjust":
        # idle fidget: the weapon hand lifts 2px (rest pose, raised)
        P = dict(P, torso_top=P["torso_top"] - 2)
        st = "rest"
    elif st == "sp_back":
        st = "back2"
    elif st == "sp_strike":
        st = "strike"
        big = True
    if w == "blade":
        if (facing == "up") == before:
            blade(cv, facing, P, T, st)
    elif w == "shield":
        shield(cv, facing, P, T, st, before)
    elif w == "sling":
        if (facing == "up") == before:
            sling(cv, facing, P, T, st)
    elif w == "staff":
        staff(cv, facing, P, T, st, before)
    if big and not before:
        special_fx(cv, facing, P, T)


def special_fx(cv, facing, P, T):
    """The special's own read: dash = speed lines behind + long streak ahead;
    ring = a full streak ring around the body; volley = three stones fanning
    out on streaks; chant = the blue throat ring."""
    w = T.get("weapon")
    top = P["torso_top"]
    fx, fy = FDIR[facing]
    if w == "blade":
        for k in (-4, 0, 4):
            cv.line(CX - fx * 9 + fy * k, top + 4 - fy * 9 + fx * k,
                    CX - fx * 14 + fy * k, top + 4 - fy * 14 + fx * k, "streak", 2)
        cv.line(CX + fx * 9, top + 3 + fy * 9, CX + fx * 15, top + 3 + fy * 15, "streak", 4)
    elif w == "shield":
        cv.ring(CX, top + 5, 13, 10, "streak", 3, inner=0.82)
        cv.ring(CX, top + 5, 10, 7.5, "streak", 2, inner=0.78)
    elif w == "sling":
        for k in (-1, 0, 1):
            ex = CX + fx * 11 + fy * k * 5
            ey = top + 2 + fy * 11 + fx * k * 5
            cv.line(CX + fx * 4, top + 2 + fy * 4, ex, ey, "streak", 3)
            cv.ellipse(ex + fx, ey + fy, 1, 1, "stone", 3)
    elif w == "staff":
        cv.ring(CX, top + 1, 5, 4, "blueglow", 3, inner=0.5)


# ---- dead -----------------------------------------------------------------
def dead(cv, facing, T):
    """Fallen on the side: head to the left (hood/helmet/hair still on),
    torso, legs, boots to the right, one arm flung out. Same materials as
    the standing body so the corpse reads as THAT kit."""
    y = FEET - 6
    mat = T.get("torso", "cloth")
    skin = T.get("skin", "skin")
    hm = {"hood": T.get("hood_mat", "cloth"), "helmet": "armor", "hair": "hair",
          "mask": "bone", "skull": "bone"}.get(T.get("head", "hair"), "cloth")
    # head (lying, seen from above): hood/hair mass + face
    cv.ellipse(CX - 9, y + 1, 4, 4, hm, 2)
    cv.ellipse(CX - 8, y + 2, 2.5, 2.5, skin, 2)
    cv.put(CX - 7, y + 2, "eye", 0)
    # torso + belt
    cv.box(CX - 5, y - 2, 10, 7, mat, 2)
    if T.get("plate"):
        cv.box(CX - 5, y - 2, 10, 2, "armor", 3)
    cv.box(CX + 4, y - 2, 1, 7, "leather", 1)
    # legs + boots
    cv.box(CX + 5, y - 1, 6, 2, "pants", 2)
    cv.box(CX + 5, y + 2, 6, 2, "pants", 1)
    cv.box(CX + 11, y - 2, 2, 3, "boot", 2)
    cv.box(CX + 11, y + 2, 2, 3, "boot", 1)
    # arm flung up-left
    cv.box(CX - 4, y - 5, 2, 3, T.get("sleeve", mat), 2)
    cv.box(CX - 4, y - 7, 2, 2, skin if not T.get("gloves") else "leather", 2)
    if T.get("weapon") == "blade":
        cv.line(CX - 1, y - 7, CX + 8, y - 7, "metal", 3)
        cv.put(CX - 1, y - 7, "gold", 3)
    elif T.get("weapon") == "shield":
        cv.ellipse(CX + 3, y + 8, 4.5, 2.5, "armor", 2)
        cv.ring(CX + 3, y + 8, 3, 1.5, "metal", 2, inner=0.5)
    elif T.get("weapon") == "sling":
        cv.line(CX - 3, y - 8, CX + 4, y - 9, "leather", 2)
    elif T.get("weapon") == "staff":
        cv.line(CX - 6, y + 8, CX + 10, y + 8, "bone", 2)
        cv.ellipse(CX + 11, y + 8, 1.5, 1.5, "bone", 3)
    if T.get("roots"):
        cv.line(CX - 3, y - 1, CX + 3, y + 3, "root", 1)
        cv.line(CX + 6, y, CX + 9, y + 3, "root", 1)
    if T.get("cloak"):
        cv.box(CX - 6, y + 5, 14, 3, "cloak", 1, shade=False)


# ---- assembly ----------------------------------------------------------------
def draw(cv, facing, anim, i, T):
    if anim == "dead":
        dead(cv, facing, T)
        cv.shadow(CX + 1, FEET + 1, 12, 2.5, alpha=70)
        return
    P = pose(anim, i, T)
    if T.get("lean"):
        # runner's tilt: head one px toward the facing, one px lower
        P["head_cy"] += 1
    cv.shadow(CX, FEET + 1.5, 7 + (1 if T.get("plate") else 0), 2.2)
    if facing == "down" and T.get("cloak"):
        cloak(cv, facing, P, T)
    weapon(cv, facing, P, T, before=True)
    if facing == "up":
        arms(cv, facing, P, T)
    legs(cv, facing, P, T)
    torso(cv, facing, P, T)
    if facing == "up" and T.get("cloak"):
        cloak(cv, facing, P, T)
        torso(cv, facing, P, T)
    if facing != "up":
        arms(cv, facing, P, T)
    scarf(cv, facing, P, T)
    head(cv, facing, P, T)
    weapon(cv, facing, P, T, before=False)


# ---- skins -------------------------------------------------------------------
PACK_SKINS = {
    # Fio - the blade: lean hooded runner, ember-orange hood + scarf, dark jacket
    "striker": dict(head="hood", hood_mat="cloth", torso="jacket_mat", jacket=True,
                    sleeve="jacket_mat", scarf=True, scarf_mat="cloth", weapon="blade",
                    gloves=True),
    # Aro - the ring: broad, rust plate, helmet with crest, round shield
    "blocker": dict(head="helmet", torso="armor", plate=True, sleeve="cloth", weapon="shield"),
    # Pomo - the sling: small, amber wraps, dark hair, satchel, bare arms
    "lobber": dict(head="hair", torso="cloth", wraps=True, sleeve="skin", weapon="sling",
                   satchel=True),
}

HUMAN_SKINS = {
    "husk": dict(head="skull", torso="cloth", wraps=True, torn=True, sleeve="cloth", skin="bone",
                 roots=True, slouch=1),
    "rusher": dict(head="skull", torso="cloth", wraps=True, sleeve="cloth", skin="bone",
                   roots=True, slouch=1, lean=1),
    "rusher_hater": dict(head="skull", torso="cloth", wraps=True, sleeve="cloth", skin="bone",
                         roots=True, slouch=1, lean=1, eye="redglow"),
    "challenger": dict(head="mask", torso="cloth", sleeve="cloth", skin="bone", cloak=True,
                       weapon="staff", tall=2),
}

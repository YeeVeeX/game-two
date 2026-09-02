# Moss floor -3 candidates - deterministic generator (docs-only, freeze-legal).
# 3 concepts for Gabriel's approval; winner lands as the permanent floor -3
# (swap spec: drafts/_swap-spec-medusa-to-dungeon1-20260831.md, sequence step 2).
# Every candidate: BFS-validated (entry reaches exit + boss) before render.
import json
from collections import deque
from PIL import Image, ImageDraw

OUT = "drafts/_moss-candidates"

def grid(w, h, fill="#"):
    return [[fill] * w for _ in range(h)]

def border(g):
    h, w = len(g), len(g[0])
    for x in range(w):
        g[0][x] = g[h - 1][x] = "#"
    for y in range(h):
        g[y][0] = g[y][w - 1] = "#"

def bfs(g, start):
    h, w = len(g), len(g[0])
    seen = {start}
    q = deque([start])
    while q:
        x, y = q.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and g[ny][nx] != "#" and (nx, ny) not in seen:
                seen.add((nx, ny))
                q.append((nx, ny))
    return seen

# ---------- A: SALAO SELADO (boss vault - sala AMPLA, 2 acessos) ----------
# Redesign 2026-08-31 (feedback Junior: v1 jardim/clareira rejeitados por
# parecerem o mesmo conceito; pedido = sala do boss ampla com POUCOS acessos).
def cand_a():
    W, H = 52, 36
    g = grid(W, H, "#")
    def rect(x0, y0, x1, y1):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                if 1 <= x < W - 1 and 1 <= y < H - 1:
                    g[y][x] = "."
    rect(2, 13, 13, 23)                            # salao de entrada (oeste)
    carve(g, [(13, 18), (19, 18)])                 # porta entrada->espinha
    rect(19, 6, 29, 30)                            # salao-espinha (norte-sul)
    carve(g, [(24, 6), (24, 4), (38, 4), (38, 10)])    # corredor norte -> porta N do cofre
    carve(g, [(24, 30), (24, 32), (38, 32), (38, 26)]) # corredor sul -> porta S do cofre
    rect(34, 10, 48, 26)                           # O COFRE: 15x17 aberto (ampla)
    for px, py in [(37, 13), (45, 13), (37, 23), (45, 23)]:   # acentos do cofre
        g[py][px] = "#"
    for px, py in [(22, 10), (26, 14), (22, 22), (26, 26)]:   # textura da espinha
        g[py][px] = "#"
    carve(g, [(24, 30), (24, 34)], r=0)            # espora de saida -> zone_7
    return dict(name="A_salao_selado", g=g, entry=(1, 18), exit7=(24, 34),
                boss=(41, 18), size=(W, H))

# ---------- B: LABIRINTO (old-school - maze + sala classica de boss no fim) ----------
# v3 2026-08-31 (Junior: lago rejeitado; pedido = "sala de boss de videogame
# antigo: um labirinto e no final a sala do boss"). Saida pra zone_7 ATRAS
# do boss - com requires_defeats:1 a escada so destranca com ele morto.
import random

def cand_b():
    SEED = 7                       # deterministico - re-rodar = mesmo labirinto
    rng = random.Random(SEED)
    C, R, pitch = 15, 9, 3         # celulas do maze, corredor 2-wide
    W, H = C * pitch + 1 + 16, R * pitch + 1
    g = grid(W, H, "#")
    def block(i, j):
        return (1 + i * pitch, 1 + j * pitch)
    def open_cell(i, j):
        x0, y0 = block(i, j)
        for dx in range(2):
            for dy in range(2):
                g[y0 + dy][x0 + dx] = "."
    def knock(i, j, ni, nj):
        x0, y0 = block(i, j)
        x1, y1 = block(ni, nj)
        if ni != i:                # parede vertical entre blocos
            wx = max(x0, x1) - 1
            g[y0][wx] = g[y0 + 1][wx] = "."
        else:                      # parede horizontal
            wy = max(y0, y1) - 1
            g[wy][x0] = g[wy][x0 + 1] = "."
    # recursive backtracker
    links = {}                     # cell -> set(neighbors ligados)
    start = (0, 4)
    visited = {start}
    stack = [start]
    while stack:
        i, j = stack[-1]
        nbrs = [(i + di, j + dj) for di, dj in ((1, 0), (-1, 0), (0, 1), (0, -1))
                if 0 <= i + di < C and 0 <= j + dj < R and (i + di, j + dj) not in visited]
        if not nbrs:
            stack.pop()
            continue
        n = rng.choice(nbrs)
        links.setdefault((i, j), set()).add(n)
        links.setdefault(n, set()).add((i, j))
        visited.add(n)
        stack.append(n)
    for (i, j) in visited:
        open_cell(i, j)
    done = set()
    for a, ns in links.items():
        for b in ns:
            if (a, b) not in done:
                knock(*a, *b)
                done.add((a, b))
                done.add((b, a))
    # braid: 3 becos viram loop (old-school sem frustracao infinita)
    dead = sorted([c for c, ns in links.items() if len(ns) == 1])
    rng.shuffle(dead)
    braided = 0
    for (i, j) in dead:
        if braided >= 3:
            break
        opts = [(i + di, j + dj) for di, dj in ((1, 0), (-1, 0), (0, 1), (0, -1))
                if 0 <= i + di < C and 0 <= j + dj < R and (i + di, j + dj) not in links.get((i, j), set())]
        if opts:
            n = rng.choice(opts)
            knock(i, j, *n)
            links.setdefault((i, j), set()).add(n)
            links.setdefault(n, set()).add((i, j))
            braided += 1
    dead_ends = sum(1 for c, ns in links.items() if len(ns) == 1)
    # porta do maze -> antessala -> SALA DO BOSS (classica: retangular, 4 pilares)
    mx = 1 + (C - 1) * pitch + 1   # borda leste do ultimo bloco (x=44)
    for x in range(mx, mx + 5):    # corredor-porta 2-wide
        g[13][x] = g[14][x] = "."
    for y in range(7, 21):         # sala 11x14 aberta
        for x in range(49, 60):
            g[y][x] = "."
    for px, py in [(51, 10), (57, 10), (51, 17), (57, 17)]:  # 4 pilares classicos
        g[py][px] = "#"
    g[13][60] = g[14][60] = "."    # alcova ATRAS do boss - a escada
    return dict(name="B_labirinto", g=g, entry=(1, 13), exit7=(60, 13),
                boss=(54, 13), size=(W, H), dead_ends=dead_ends)

# ---------- C: VEIAS (moss veins carved through stone, heart chamber) ----------
def carve(g, pts, r=1):
    h, w = len(g), len(g[0])
    for i in range(len(pts) - 1):
        (x0, y0), (x1, y1) = pts[i], pts[i + 1]
        steps = max(abs(x1 - x0), abs(y1 - y0))
        for s in range(steps + 1):
            x = round(x0 + (x1 - x0) * s / max(steps, 1))
            y = round(y0 + (y1 - y0) * s / max(steps, 1))
            for dx in range(-r, r + 1):
                for dy in range(-r, r + 1):
                    nx, ny = x + dx, y + dy
                    if 1 <= nx < w - 1 and 1 <= ny < h - 1:
                        g[ny][nx] = "."

def cand_c():
    W, H = 56, 36
    g = grid(W, H, "#")
    main = [(1, 18), (8, 16), (14, 20), (22, 17), (30, 20), (38, 17), (44, 18)]
    carve(g, main)
    carve(g, [(12, 17), (12, 8), (22, 6), (30, 8), (30, 19)])          # north loop
    carve(g, [(20, 19), (20, 28), (26, 31), (26, 34)])                 # south branch -> zone_7
    carve(g, [(26, 30), (36, 30), (40, 26), (40, 20)])                 # south loop rejoins
    carve(g, [(36, 19), (36, 3)])                                      # north pocket spur (ligada ao canal principal - licao T6b)
    carve(g, [(34, 2), (38, 4)], r=1)                                  # the pocket
    # heart chamber (boss)
    hx, hy = 48, 18
    for x in range(W):
        for y in range(H):
            if (x - hx) ** 2 + (y - hy) ** 2 <= 25:
                if 1 <= x < W - 1 and 1 <= y < H - 1:
                    g[y][x] = "."
    return dict(name="C_veias", g=g, entry=(1, 18), exit7=(26, 34),
                boss=(hx, hy), size=(W, H))

# ---------- validate + render ----------
def moss_tint(x, y):
    return (x * 7 + y * 13) % 5 == 0  # deterministic moss sprinkle

def render(c):
    g = c["g"]
    H, W = len(g), len(g[0])
    px = 8
    lake = c.get("lake", set())
    img = Image.new("RGB", (W * px, H * px), (10, 14, 10))
    d = ImageDraw.Draw(img)
    for y in range(H):
        for x in range(W):
            if g[y][x] == "#":
                fill = (30, 58, 66) if (x, y) in lake else (96, 108, 92)
                d.rectangle([x * px, y * px, x * px + px - 1, y * px + px - 1],
                            fill=fill)
            elif moss_tint(x, y):
                d.rectangle([x * px + 1, y * px + 1, x * px + px - 2, y * px + px - 2],
                            fill=(34, 72, 38))
    ex, ey = c["entry"]
    d.rectangle([ex * px, ey * px, ex * px + px - 1, ey * px + px - 1], fill=(235, 190, 90))
    ex, ey = c["exit7"]
    d.rectangle([ex * px, ey * px, ex * px + px - 1, ey * px + px - 1], fill=(235, 190, 90))
    bx, by = c["boss"]
    d.rectangle([bx * px, by * px, bx * px + px - 1, by * px + px - 1], fill=(255, 40, 120))
    img = img.resize((W * px * 2, H * px * 2), Image.NEAREST)
    path = f"{OUT}/{c['name']}.png"
    img.save(path)
    return path

results = []
for c in (cand_a(), cand_b(), cand_c()):
    g = c["g"]
    # exits/boss must sit on floor
    for tag in ("entry", "exit7", "boss"):
        x, y = c[tag]
        g[y][x] = "."
    seen = bfs(g, c["entry"])
    ok = c["exit7"] in seen and c["boss"] in seen
    floor_tiles = sum(row.count(".") for row in g)
    path = render(c)
    results.append(dict(name=c["name"], size=c["size"], reachable=len(seen),
                        floor=floor_tiles, exits_ok=ok, png=path))
    print(f"{c['name']}: {c['size'][0]}x{c['size'][1]} floor={floor_tiles} "
          f"BFS={len(seen)} exits+boss reachable={ok} -> {path}")

orphans = [r for r in results if r["reachable"] != r["floor"]]
print("\ntiles orfaos:", {r["name"]: r["floor"] - r["reachable"] for r in orphans} if orphans else "ZERO em todos")
print("TODOS VALIDOS" if all(r["exits_ok"] for r in results) else "FALHA EM ALGUM")

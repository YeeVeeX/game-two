# Conceito FLOOR -2 v3 — "FIEHONJA" (ZONE 3 / district_two retheme)
# Referência do Junior (2026-08-29): Fiehonja (Tibia) — fundo do mar + ALGAS.
# Acessos de boss da foto DESCONSIDERADOS (ordem dele). A gramática visual:
# planalto de pedra ABERTO (cinza) · CANAL profundo em Y cortando o mapa
# (azul vivo, margens com coral vermelho) · RECIFE laranja com miolo verde
# no SE (a arena) · RUÍNA de alvenaria no NO · bancos de areia no SO.
# Contraste com v1/v2: campo aberto em vez de câmaras — a leitura é "planície
# submersa", perigo visível de longe. Estrutura do jogo mantida: 88×44,
# fluxo oeste→leste, saída selada → ZONE 4 → -3, passagens 3-wide, BFS.
# Nota de engine: RECIFE = 2ª classe de parede (o ticket T5 da first-wave —
# parede vermelha + borda escura coexistindo, exatamente o ask do MEDUSA v3).
import math, random
from collections import deque
from PIL import Image, ImageDraw, ImageFont

random.seed(7734)

W, H = 88, 44
ROCK, SEABED, SAND, BANK, CHANNEL, ALGAE, REEF, RFLOOR, RWALL = \
    '#', ',', '.', 'g', '~', 'a', 'R', 'f', 'X'
WALK = {SEABED, SAND, BANK, ALGAE, RFLOOR}

PAL = {
    ROCK:    (96, 54, 32),     # rocha ferrugem (rim)
    SEABED:  (40, 46, 58),     # planalto de pedra (o cinza de Fiehonja, afundado)
    SAND:    (50, 58, 74),     # clareiras de areia
    BANK:    (86, 76, 52),     # bancos tan (SO, como a referência)
    CHANNEL: (14, 34, 78),     # canal profundo — azul vivo, NÃO anda
    ALGAE:   (34, 72, 48),     # ALGAS — andável, emboscada
    REEF:    (150, 74, 28),    # recife coral — 2ª classe de parede (T5), NÃO anda
    RFLOOR:  (66, 58, 50),     # piso da ruína (xadrez no render)
    RWALL:   (128, 52, 44),    # alvenaria da ruína — NÃO anda
}
SOLID = (10, 8, 8)

grid = [[None] * W for _ in range(H)]

# ------------------------------------------------------- planalto aberto
def carve_blob(cx, cy, r, theme='plain'):
    wob = [random.uniform(0.72, 1.26) for _ in range(14)]
    pts = []
    for y in range(max(2, cy - r - 2), min(H - 2, cy + r + 3)):
        for x in range(max(2, cx - r - 3), min(W - 2, cx + r + 4)):
            a = math.atan2(y - cy, x - cx)
            k = int(((a + math.pi) / (2 * math.pi)) * 14) % 14
            if math.hypot((x - cx) * 0.82, (y - cy) * 1.18) <= r * wob[k] * random.uniform(0.95, 1.05):
                if grid[y][x] is None:
                    grid[y][x] = SEABED
                pts.append((x, y))
    random.shuffle(pts)
    if theme == 'banks':
        for x, y in pts[: len(pts) // 6]:
            if grid[y][x] == SEABED:
                grid[y][x] = BANK
    for x, y in pts[int(len(pts) * 0.8):]:
        if grid[y][x] == SEABED:
            grid[y][x] = SAND
    return pts

PLATEAU = [
    (10, 22, 8, 'plain'),   # plataforma da entrada
    (12, 7,  7, 'plain'),   # sob a ruína
    (20, 14, 11, 'plain'),
    (36, 22, 9, 'plain'),
    (46, 12, 10, 'plain'),
    (30, 30, 10, 'banks'),  # SO com bancos tan (referência)
    (46, 32, 9, 'banks'),
    (62, 14, 10, 'plain'),
    (66, 32, 11, 'plain'),  # base do recife
    (76, 22, 9, 'plain'),
]
for b in PLATEAU:
    carve_blob(*b)

# ------------------------------------------------------- campos de ALGAS
def algae_field(cx, cy, r):
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r - 1, cx + r + 2):
            if 2 <= x < W - 2 and 2 <= y < H - 2 and grid[y][x] in (SEABED, SAND):
                if math.hypot((x - cx) * 0.8, (y - cy) * 1.15) <= r * random.uniform(0.75, 1.1):
                    grid[y][x] = ALGAE

for f in ((24, 10, 5), (52, 12, 4), (26, 30, 4), (72, 14, 4), (40, 27, 3)):
    algae_field(*f)

# ------------------------------------------------------------ RUÍNA (NO)
RX0, RY0, RX1, RY1 = 5, 4, 17, 11
for y in range(RY0, RY1 + 1):
    for x in range(RX0, RX1 + 1):
        border = x in (RX0, RX1) or y in (RY0, RY1)
        grid[y][x] = RWALL if border else RFLOOR
for x in (10, 11, 12):                      # porta sul
    grid[RY1][x] = RFLOOR
def carve_path(ax, ay, bx, by, width=3, tile=SAND, over=(None,)):
    x, y = ax, ay
    while (x, y) != (bx, by):
        if x != bx and (y == by or random.random() < 0.6):
            x += 1 if bx > x else -1
        elif y != by:
            y += 1 if by > y else -1
        for d in range(-(width // 2), width - width // 2):
            for px, py in ((x, y + d), (x + d, y)):
                if 2 <= px < W - 2 and 2 <= py < H - 2 and grid[py][px] in over:
                    grid[py][px] = tile
carve_path(11, RY1 + 1, 13, 16, 2)          # porta → planalto

# ------------------------------------------------------------ RECIFE (SE)
RCX, RCY = 67, 33
for y in range(RCY - 8, RCY + 8):
    for x in range(RCX - 11, RCX + 12):
        if not (2 <= x < W - 2 and 2 <= y < H - 2):
            continue
        dx, dy = x - RCX, y - RCY
        e_out = (dx / 9.5) ** 2 + (dy / 6.5) ** 2
        e_in  = (dx / 6.0) ** 2 + (dy / 3.8) ** 2
        ang = math.degrees(math.atan2(-dy, dx)) % 360
        if e_out <= 1 and e_in > 1:
            if 115 <= ang <= 160:            # BRECHA NW — entrada única
                continue
            grid[y][x] = REEF
        elif e_in <= 1:                      # lagoa interna
            grid[y][x] = ALGAE if (x + y) % 3 else SAND

# ------------------------------------------------------- CANAL em Y (N→S)
def channel_line(pts, rad=1):
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        steps = max(abs(bx - ax), abs(by - ay)) * 3
        for i in range(steps + 1):
            t = i / steps
            x = ax + (bx - ax) * t + math.sin(t * 9) * 0.8
            y = ay + (by - ay) * t
            for dy in range(-rad, rad + 1):
                for dx in range(-rad, rad + 1):
                    px, py = int(x) + dx, int(y) + dy
                    if 2 <= px < W - 2 and 1 <= py < H - 2 and abs(dx) + abs(dy) <= rad + 1:
                        if grid[py][px] not in (REEF, RWALL, RFLOOR):
                            grid[py][px] = CHANNEL

channel_line([(44, 1), (43, 8), (46, 14), (43, 20), (45, 26)])          # tronco N→S
channel_line([(45, 26), (38, 31), (28, 35), (18, 39)])                  # braço SO
channel_line([(45, 26), (52, 30), (59, 30)])                            # braço SE (na brecha)

# --------------------------------------------------- 4 travessias (vaus)
def ford(x0, x1, y0, y1):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if grid[y][x] == CHANNEL:
                grid[y][x] = SAND

ford(41, 47, 11, 13)      # VAU 1 — norte
ford(41, 48, 21, 23)      # VAU 2 — rota principal (guardião)
ford(26, 28, 33, 36)      # VAU 3 — braço SO
ford(55, 57, 28, 31)      # VAU 4 — fresta do recife (2-wide, arriscada)

# --------------------------------------------------------- entrada/saída
ENTRY = (2, 22)
EXIT_ = (85, 24)
carve_path(*ENTRY, 10, 22, 3)
carve_path(76, 22, *EXIT_, 3)

# ------------------------------------------------------------- rim + BFS
for y in range(H):
    for x in range(W):
        if grid[y][x] is None:
            near = any(0 <= y + dy < H and 0 <= x + dx < W and grid[y + dy][x + dx] in WALK
                       for dy in (-1, 0, 1) for dx in (-1, 0, 1))
            grid[y][x] = ROCK if near else 'SOLID'

def bfs(src):
    seen, q = {src}, deque([src])
    while q:
        x, y = q.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < W and 0 <= ny < H and (nx, ny) not in seen and grid[ny][nx] in WALK:
                seen.add((nx, ny))
                q.append((nx, ny))
    return seen

reach = bfs(ENTRY)
for tgt, name in ((EXIT_, 'saida'), ((RCX, RCY), 'arena do recife'), ((11, 8), 'ruina')):
    assert tgt in reach, f"{name} inalcancavel!"
tot = sum(1 for y in range(H) for x in range(W) if grid[y][x] in WALK)
print(f"BFS OK: saida + arena + ruina alcancaveis | {len(reach)}/{tot} tiles andaveis")

# ---------------------------------------------------------------- conteúdo
PACKS = [(18, 12, 4), (28, 8, 3), (36, 17, 4), (24, 26, 3), (30, 28, 4),
         (52, 8, 3), (58, 18, 4), (70, 12, 3), (76, 28, 3)]                # 31
GUARD_FORD = (44, 22)
MEDUSAS = [(64, 31), (69, 30), (66, 35), (71, 34), (67, 32)]
CORAL_ROUTE = [(8, 22), (16, 20), (26, 20), (36, 21), (41, 22), (48, 22),
               (56, 21), (64, 22), (72, 23), (80, 24)]

# ------------------------------------------------------------------ render
CELL = 13
LEG_H = 156
img = Image.new('RGB', (W * CELL, H * CELL + LEG_H), (5, 5, 7))
dr = ImageDraw.Draw(img)

for y in range(H):
    for x in range(W):
        t = grid[y][x]
        c = SOLID if t == 'SOLID' else PAL[t]
        if t == RFLOOR and (x + y) % 2:
            c = (56, 48, 42)                                   # xadrez da ruína
        j = ((x * 31 + y * 17) % 7) - 3
        c = tuple(max(0, min(255, v + j)) for v in c)
        dr.rectangle([x * CELL, y * CELL, x * CELL + CELL - 1, y * CELL + CELL - 1], fill=c)
        if t == ALGAE and (x + y) % 2:                         # frondes
            dr.line([x * CELL + 4, y * CELL + CELL - 2, x * CELL + 6, y * CELL + 2],
                    fill=(48, 100, 66), width=1)
        if t == REEF:                                          # miolo verde da referência
            h = (x * 7 + y * 13) % 9
            if h < 2:
                dr.point((x * CELL + 5, y * CELL + 5), fill=(60, 110, 50))
            elif h == 3:
                dr.point((x * CELL + 8, y * CELL + 8), fill=(110, 52, 20))
        if t == SEABED and (x * 13 + y * 29) % 23 == 0:
            dr.point((x * CELL + 6, y * CELL + 6), fill=(70, 90, 120))
        if t == CHANNEL and (x + y) % 3 == 0:
            dr.point((x * CELL + 6, y * CELL + 8), fill=(30, 60, 120))

# coral VERMELHO nas margens do canal (a assinatura de Fiehonja)
for y in range(H):
    for x in range(W):
        if grid[y][x] in WALK and (x * 11 + y * 7) % 4 == 0:
            if any(0 <= y + dy < H and 0 <= x + dx < W and grid[y + dy][x + dx] == CHANNEL
                   for dy in (-1, 0, 1) for dx in (-1, 0, 1)):
                dr.ellipse([x * CELL + 4, y * CELL + 4, x * CELL + 8, y * CELL + 8],
                           fill=(200, 60, 50))

for i in range(0, W * CELL, 90):                               # caustics
    dr.line([(i, 0), (i - 130, H * CELL)], fill=(30, 48, 74), width=1)

try:
    F  = ImageFont.truetype("consola.ttf", 15)
    F2 = ImageFont.truetype("consolab.ttf", 19)
except OSError:
    F = F2 = ImageFont.load_default()

for cx_, cy_ in CORAL_ROUTE:                                   # rota ciano
    x, y = cx_ * CELL + CELL // 2, cy_ * CELL + CELL // 2
    dr.ellipse([x - 5, y - 5, x + 5, y + 5], outline=(70, 200, 220), width=1)
    dr.ellipse([x - 2, y - 2, x + 2, y + 2], fill=(140, 240, 250))

def ring(cx_, cy_, color, r=CELL + 4, w=3, label=None, ly=-8, lx=None):
    x, y = cx_ * CELL + CELL // 2, cy_ * CELL + CELL // 2
    dr.ellipse([x - r, y - r, x + r, y + r], outline=color, width=w)
    if label:
        dr.text((x + (lx if lx is not None else r + 4), y + ly), label, fill=color, font=F)

ring(*ENTRY, (90, 230, 110), label="ENTRADA")
ring(*EXIT_, (240, 210, 90))
dr.text((EXIT_[0] * CELL - 224, EXIT_[1] * CELL + 20), "SAÍDA SELADA (→ ZONE 4 → -3)",
        fill=(240, 210, 90), font=F)
ring(11, 7, (200, 205, 220), r=CELL + 10, w=2, label="RUÍNA AFUNDADA (praça segura)", ly=6)
ring(RCX, RCY, (90, 210, 230), r=CELL + 14, label="ARENA DO RECIFE (totem candidato)",
     ly=-34, lx=-220)
ring(*GUARD_FORD, (250, 170, 90), r=CELL + 6, w=2, label="GUARDIÃO DO VAU", ly=-30, lx=-50)
for fx, fy in ((44, 12), (27, 34), (56, 29)):
    ring(fx, fy, (235, 90, 90), r=CELL - 1, w=2)

for mx, my in MEDUSAS:
    x, y = mx * CELL + CELL // 2, my * CELL + CELL // 2
    dr.ellipse([x - 5, y - 5, x + 5, y + 2], outline=(250, 150, 210), width=2)
    for dx in (-3, 0, 3):
        dr.line([(x + dx, y + 2), (x + dx, y + 7)], fill=(250, 150, 210), width=1)

for ch in PACKS:
    ccx, ccy, n = ch
    for i in range(n):
        px = ccx * CELL + int(math.cos(i * 2.4) * CELL * 1.3)
        py = ccy * CELL + int(math.sin(i * 2.4) * CELL * 1.3)
        dr.ellipse([px - 3, py - 3, px + 3, py + 3], fill=(235, 120, 100))

dr.text((22 * CELL, 6 * CELL - 8), "CAMPOS DE ALGAS (emboscada)", fill=(90, 170, 130), font=F)

cpx, cpy = W * CELL - 64, 30                                   # bússola
dr.ellipse([cpx - 22, cpy - 22, cpx + 22, cpy + 22], outline=(160, 165, 185), width=2)
dr.polygon([(cpx, cpy - 18), (cpx - 5, cpy + 4), (cpx + 5, cpy + 4)], fill=(220, 224, 240))
dr.text((cpx - 5, cpy - 44), "N", fill=(220, 224, 240), font=F)
dr.line([(20, H * CELL - 16), (20 + 10 * CELL, H * CELL - 16)], fill=(200, 205, 220), width=2)
for i in (0, 5, 10):
    dr.line([(20 + i * CELL, H * CELL - 20), (20 + i * CELL, H * CELL - 12)], fill=(200, 205, 220), width=2)
dr.text((24 + 10 * CELL, H * CELL - 24), "10 tiles", fill=(200, 205, 220), font=F)

# ------------------------------------------------------------------ legenda
ly0 = H * CELL + 10
dr.text((12, ly0), "FLOOR -2 v3 — \"FIEHONJA\"  ·  ZONE 3 (district_two) retheme  ·  88×44  ·  submerso + ALGAS",
        fill=(215, 220, 235), font=F2)
sw = [("planalto de pedra", PAL[SEABED]), ("areia", PAL[SAND]), ("banco tan", PAL[BANK]),
      ("CANAL (não anda)", PAL[CHANNEL]), ("algas", PAL[ALGAE]), ("recife (não anda)", PAL[REEF]),
      ("ruína", PAL[RFLOOR])]
x0 = 12
for name, c in sw:
    dr.rectangle([x0, ly0 + 34, x0 + 18, ly0 + 52], fill=c, outline=(110, 105, 120))
    dr.text((x0 + 24, ly0 + 36), name, fill=(195, 200, 214), font=F)
    x0 += 24 + len(name) * 8 + 20
dr.text((12, ly0 + 64),
        "PLANÍCIE SUBMERSA ABERTA (contraste com v1/v2): perigo visível de longe · CANAL em Y corta o mapa · coral VERMELHO = margem do canal",
        fill=(172, 180, 198), font=F)
dr.text((12, ly0 + 88),
        "4 travessias (herança v2b): VAU norte → VAU principal (GUARDIÃO) → VAU SO → FRESTA do recife (2-wide) · campos de ALGAS = emboscada",
        fill=(172, 180, 198), font=F)
dr.text((12, ly0 + 112),
        "ARENA DO RECIFE (SE) = coração contestado: totem candidato + 5 águas-vivas, entrada ÚNICA pela brecha NW · RUÍNA NO = estação candidata",
        fill=(172, 180, 198), font=F)
dr.text((12, ly0 + 134),
        "recife = 2ª classe de parede (ticket T5) · referência: Fiehonja/Tibia, acessos de boss desconsiderados · BFS provado · determinístico seed 7734",
        fill=(140, 148, 166), font=F)

out = r"C:\Users\jr\Desktop\mapas-game-two\conceito-floor2-fiehonja-v3-88x44.png"
img.save(out)
print("salvo:", out)

# Conceito FLOOR -2 — "CALASSA" (ZONE 3 / district_two retheme)
# Referência do Junior (2026-08-29): mapa submerso estilo Calassa (Tibia) —
# você anda NO fundo do mar. AZUL = chão andável (leito), bordas FERRUGEM =
# rocha das cavernas, retalhos TAN = bancos de areia, preto = rocha maciça.
# Tema da descida: -1 areia+raízes (v2b) → -2 SUBMERSO (este) → -3 MEDUSA.
# Estrutura nossa: tiles do engine (# rocha · , leito · . areia clara ·
# g banco de areia · ~ fossa abissal INTRANSPONÍVEL), passagens 3-wide
# (achado do v1), fluxo oeste→leste (entrada [oeste,meio] vinda da cadeia,
# saída leste SELADA → ZONE 4 → floor -3). Gerador determinístico.
import math, random
from collections import deque
from PIL import Image, ImageDraw, ImageFont

random.seed(20260829)

W, H = 88, 44
ROCK, SEABED, SAND, BANK, TRENCH = '#', ',', '.', 'g', '~'

# ------------------------------------------------------------------ paleta
# Mais fundo = mais escuro e mais AZUL (estamos dentro d'água):
PAL = {
    ROCK:   (96, 54, 32),    # rocha ferrugem (as bordas laranja da referência, afundadas)
    SEABED: (26, 40, 62),    # leito andável — o AZUL dominante da referência
    SAND:   (36, 52, 78),    # areia clara (clareiras do leito)
    BANK:   (86, 76, 52),    # banco de areia tan (os retalhos da referência)
    TRENCH: (4, 8, 18),      # fossa abissal — intransponível
}
SOLID = (10, 8, 8)           # rocha maciça fora das cavernas (o preto)

# ------------------------------------------------------------------ câmaras
# Composição da referência: aglomerado OESTE alto · faixa CENTRAL larga ·
# aglomerado LESTE alto com recorte sul. (cx, cy, raio, tema)
CHAMBERS = [
    (7,  22, 5, 'plain'),    # 0 entrada oeste (vinda da cadeia do -1)
    (13, 10, 6, 'banks'),    # 1 oeste-norte
    (12, 33, 6, 'banks'),    # 2 oeste-sul
    (24, 18, 6, 'plain'),    # 3 antecâmara oeste
    (36, 9,  6, 'banks'),    # 4 faixa norte
    (52, 8,  6, 'plain'),    # 5
    (66, 10, 5, 'banks'),    # 6
    (34, 30, 6, 'banks'),    # 7 faixa sul
    (50, 34, 6, 'plain'),    # 8
    (64, 33, 5, 'banks'),    # 9 recorte sul-leste
    (46, 20, 8, 'heart'),    # 10 CORAÇÃO — câmara contestada (totem candidato)
    (72, 22, 6, 'banks'),    # 11 átrio leste
    (82, 24, 4, 'plain'),    # 12 bolso da saída selada
]
# passagens (a,b,largura): 3 = rota principal · 2 = fresta arriscada
PASSAGES = [
    (0, 1, 3), (0, 2, 3), (0, 3, 3),
    (1, 4, 3), (3, 4, 2), (3, 10, 3),
    (4, 5, 3), (5, 6, 2),
    (2, 7, 3), (7, 8, 3), (8, 9, 2),
    (7, 10, 2), (5, 10, 2), (8, 10, 2),
    (10, 11, 3), (6, 11, 2), (9, 11, 2),
    (11, 12, 3),
    (1, 3, 2), (2, 3, 2),
]

grid = [[None] * W for _ in range(H)]   # None = rocha maciça

def carve_blob(cx, cy, r, theme):
    pts = []
    wob = [random.uniform(0.66, 1.3) for _ in range(14)]
    for y in range(max(2, cy - r - 2), min(H - 2, cy + r + 3)):
        for x in range(max(2, cx - r - 2), min(W - 2, cx + r + 3)):
            a = math.atan2(y - cy, x - cx)
            k = int(((a + math.pi) / (2 * math.pi)) * 14) % 14
            if math.hypot(x - cx, (y - cy) * 1.12) <= r * wob[k] * random.uniform(0.93, 1.07):
                grid[y][x] = SEABED
                pts.append((x, y))
    random.shuffle(pts)
    if theme in ('banks', 'heart'):                      # bancos de areia tan
        for x, y in pts[: max(3, len(pts) // 7)]:
            grid[y][x] = BANK
            for dx, dy in ((1, 0), (0, 1), (1, 1)):
                if random.random() < 0.55 and grid[y + dy][x + dx] == SEABED:
                    grid[y + dy][x + dx] = BANK
    for x, y in pts[int(len(pts) * 0.72):]:              # clareiras de areia
        if grid[y][x] == SEABED:
            grid[y][x] = SAND
    return pts

chamber_tiles = [carve_blob(*c) for c in CHAMBERS]

def carve_passage(a, b, width):
    (ax, ay), (bx, by) = CHAMBERS[a][:2], CHAMBERS[b][:2]
    x, y = ax, ay
    while (x, y) != (bx, by):
        if x != bx and (y == by or random.random() < 0.62):
            x += 1 if bx > x else -1
        elif y != by:
            y += 1 if by > y else -1
        for d in range(-(width // 2), width - width // 2):
            for px, py in ((x, y + d), (x + d, y)):
                if 2 <= px < W - 2 and 2 <= py < H - 2 and grid[py][px] is None:
                    grid[py][px] = SEABED

for a, b, w in PASSAGES:
    carve_passage(a, b, w)

# ------------------------------------------------- fossas abissais (perigo)
# Rachaduras de água profunda cortando câmaras — o "abismo" deste andar
# (papel tático dos fossos do -1; cruzam-se por istmos de areia naturais).
def trench(x0, y0, x1, y1, halfw=1):
    steps = max(abs(x1 - x0), abs(y1 - y0))
    for i in range(steps + 1):
        t = i / steps
        x = int(x0 + (x1 - x0) * t + math.sin(t * 6.3) * 1.8)
        y = int(y0 + (y1 - y0) * t)
        for dy in range(-halfw, halfw + 1):
            for dx in range(-halfw, halfw + 1):
                if 2 <= x + dx < W - 2 and 2 <= y + dy < H - 2 and grid[y + dy][x + dx] is not None:
                    grid[y + dy][x + dx] = TRENCH

trench(40, 13, 42, 27)        # fossa oeste do coração
trench(52, 15, 51, 26)        # fossa leste do coração
trench(28, 6, 33, 12)         # rachadura norte
trench(56, 36, 62, 30)        # rachadura sul
# istmos de areia garantidos (2 por fossa do coração — escolha tática):
for x, y in ((41, 19), (41, 20), (51, 19), (51, 20), (30, 9), (59, 33)):
    for dx in (-1, 0, 1):
        if grid[y][x + dx] == TRENCH:
            grid[y][x + dx] = SAND
        grid[y][x] = SAND

# ------------------------------------------------------------ entrada/saída
ENTRY = (2, 22)     # oeste, meia-altura (mantém o lado do endpoint atual [0,13])
EXIT_ = (85, 24)    # leste SELADA → ZONE 4 (slow_door) → floor -3
for (ex, ey), tgt in ((ENTRY, 0), (EXIT_, 12)):
    x, y = ex, ey
    tx, ty = CHAMBERS[tgt][:2]
    while (x, y) != (tx, ty):
        for d in (0, -1, 1):
            if 0 <= y + d < H and grid[y + d][x] in (None, TRENCH):
                grid[y + d][x] = SAND
        if x != tx:
            x += 1 if tx > x else -1
        elif y != ty:
            y += 1 if ty > y else -1

# ------------------------------------------------------- borda de rocha viva
# Toda rocha maciça encostada em chão andável vira parede ferrugem (o rim
# laranja da referência); o resto fica rocha maciça escura.
WALK = {SEABED, SAND, BANK}
for y in range(H):
    for x in range(W):
        if grid[y][x] is None:
            near = any(0 <= y + dy < H and 0 <= x + dx < W and grid[y + dy][x + dx] in WALK
                       for dy in (-1, 0, 1) for dx in (-1, 0, 1))
            grid[y][x] = ROCK if near else 'SOLID'

# ---------------------------------------------------------------- prova BFS
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
assert EXIT_ in reach, "BFS: saída inalcançável!"
ok = sum(1 for tiles in chamber_tiles if any(t in reach for t in tiles))
tot = sum(1 for y in range(H) for x in range(W) if grid[y][x] in WALK)
print(f"BFS OK: entrada->saida conectadas | {ok}/{len(CHAMBERS)} camaras alcancaveis | {len(reach)}/{tot} tiles andaveis")

# ------------------------------------------------------------ spawns (conceito)
PACKS = [   # (câmara, n) — 30 minions; mais fundo paga mais (27 no -1)
    (1, 4), (2, 4), (3, 3), (4, 4), (5, 3), (6, 3), (7, 4), (8, 3), (9, 2),
]
MEDUSAS = [(43, 17), (49, 23), (44, 24), (50, 16), (46, 27)]  # 5 águas-vivas no coração

# ---------------------------------------------------------------- render
CELL = 13
LEG_H = 138
img = Image.new('RGB', (W * CELL, H * CELL + LEG_H), (5, 5, 7))
dr = ImageDraw.Draw(img)

for y in range(H):
    for x in range(W):
        t = grid[y][x]
        c = SOLID if t == 'SOLID' else PAL[t]
        j = ((x * 31 + y * 17) % 7) - 3
        c = tuple(max(0, min(255, v + j)) for v in c)
        dr.rectangle([x * CELL, y * CELL, x * CELL + CELL - 1, y * CELL + CELL - 1], fill=c)
        if t == SEABED and (x * 13 + y * 29) % 17 == 0:    # plâncton/bolhas
            dr.point((x * CELL + 6, y * CELL + 6), fill=(60, 90, 130))
        if t == TRENCH and (x + y) % 5 == 0:               # respiro do abismo
            dr.point((x * CELL + 6, y * CELL + 9), fill=(14, 22, 40))

# leve caustics de luz (estamos debaixo d'água)
for i in range(0, W * CELL, 90):
    dr.line([(i, 0), (i - 130, H * CELL)], fill=(30, 48, 74), width=1)

try:
    F  = ImageFont.truetype("consola.ttf", 15)
    F2 = ImageFont.truetype("consolab.ttf", 19)
except OSError:
    F = F2 = ImageFont.load_default()

def ring(cx, cy, color, r=CELL + 4, w=3, label=None, ly=-8):
    x, y = cx * CELL + CELL // 2, cy * CELL + CELL // 2
    dr.ellipse([x - r, y - r, x + r, y + r], outline=color, width=w)
    if label:
        dr.text((x + r + 4, y + ly), label, fill=color, font=F)

ring(*ENTRY, (90, 230, 110), label="ENTRADA (oeste, da cadeia do -1)")
ring(*EXIT_, (240, 210, 90))
dr.text((EXIT_[0] * CELL - 210, EXIT_[1] * CELL + 20), "SAÍDA SELADA (→ ZONE 4 → -3)",
        fill=(240, 210, 90), font=F)
ring(*CHAMBERS[10][:2], (90, 210, 230), r=CELL + 12, label="CORAÇÃO — totem candidato", ly=-26)

for mx, my in MEDUSAS:   # águas-vivas: rosa translúcido
    x, y = mx * CELL + CELL // 2, my * CELL + CELL // 2
    dr.ellipse([x - 5, y - 5, x + 5, y + 2], outline=(250, 150, 210), width=2)
    for dx in (-3, 0, 3):
        dr.line([(x + dx, y + 2), (x + dx, y + 7)], fill=(250, 150, 210), width=1)

for ch, n in PACKS:
    cx, cy = CHAMBERS[ch][:2]
    for i in range(n):
        px = cx * CELL + int(math.cos(i * 2.4) * CELL * 1.3)
        py = cy * CELL + int(math.sin(i * 2.4) * CELL * 1.3)
        dr.ellipse([px - 3, py - 3, px + 3, py + 3], fill=(235, 120, 100))

# ---------------------------------------------------------------- legenda
ly0 = H * CELL + 10
dr.text((12, ly0), "FLOOR -2 — conceito \"CALASSA\" (submerso)  ·  ZONE 3 (district_two) retheme  ·  88×44",
        fill=(215, 220, 235), font=F2)
sw = [("leito andável (fundo do mar)", PAL[SEABED]), ("areia clara", PAL[SAND]),
      ("banco de areia", PAL[BANK]), ("fossa abissal (NÃO anda)", PAL[TRENCH]),
      ("rocha ferrugem", PAL[ROCK]), ("rocha maciça", SOLID)]
x0 = 12
for name, c in sw:
    dr.rectangle([x0, ly0 + 34, x0 + 18, ly0 + 52], fill=c, outline=(110, 105, 120))
    dr.text((x0 + 24, ly0 + 36), name, fill=(195, 200, 214), font=F)
    x0 += 24 + len(name) * 8 + 22
dr.text((12, ly0 + 64),
        "VOCÊ ANDA NO FUNDO DO MAR: azul = chão · fossas = o abismo deste andar (istmos de areia = escolha tática, herança das 4 pontes)",
        fill=(172, 180, 198), font=F)
dr.text((12, ly0 + 88),
        "30 minions em grupos por câmara + 5 ÁGUAS-VIVAS guardando o CORAÇÃO (rosa)  ·  passagens 3-wide, frestas 2-wide",
        fill=(172, 180, 198), font=F)
dr.text((12, ly0 + 112),
        "paleta: mais fundo = mais escuro e mais AZUL  ·  tema contínuo: -1 areia+raízes → -2 submerso → -3 MEDUSA  ·  BFS provado",
        fill=(140, 148, 166), font=F)

out = r"C:\Users\jr\Desktop\mapas-game-two\conceito-floor2-calassa-88x44.png"
img.save(out)
print("salvo:", out)

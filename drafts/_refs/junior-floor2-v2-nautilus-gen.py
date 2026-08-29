# Conceito FLOOR -2 v2 — "O NAUTILUS" (ZONE 3 / district_two retheme)
# Pesquisa (padrões, não cópias): Tibia/Calassa (câmaras no leito, cúpula de
# ar) · WoW/Throne of the Tides (dungeon-nautilus em espiral, kelp, naufrágio)
# · FFXIV/Sastasha (coral luminoso = rota) · Subnautica/Lost River (RIO DE
# SALMOURA: água-mais-densa serpenteando no fundo — brine pool real) ·
# Zelda/Water Temple (marco central que organiza o mapa inteiro).
# A ideia autêntica: a caverna É uma concha de nautilus. Dois anéis de
# câmaras separados por um rio de salmoura em espiral; a rota externa orbita
# até a saída; o CORAÇÃO no centro é mergulho OPCIONAL por istmos arriscados.
# Estrutura do jogo: tiles do engine, passagens 3-wide, fluxo oeste→leste,
# saída selada → ZONE 4 → -3, grupos por câmara, BFS provado. Determinístico.
import math, random
from collections import deque
from PIL import Image, ImageDraw, ImageFont

random.seed(4479)

W, H = 88, 44
ROCK, SEABED, SAND, BANK, BRINE, KELP, WRECK = '#', ',', '.', 'g', '~', 'k', 'w'
WALK = {SEABED, SAND, BANK, KELP, WRECK}

PAL = {
    ROCK:   (96, 54, 32),     # rocha ferrugem (rim das cavernas)
    SEABED: (26, 40, 62),     # leito andável
    SAND:   (38, 54, 80),     # areia clara (clareiras/istmos)
    BANK:   (86, 76, 52),     # banco de areia tan
    BRINE:  (16, 10, 40),     # RIO DE SALMOURA — denso, roxo-abissal, NÃO anda
    KELP:   (30, 66, 52),     # floresta de kelp (andável, emboscada)
    WRECK:  (108, 82, 50),    # madeira do naufrágio (andável)
}
SOLID = (10, 8, 8)
CX, CY = 46, 23               # centro da espiral (o CORAÇÃO)

def spiral_pt(t, r):          # espiral elíptica (canvas 2:1)
    return CX + r * 1.55 * math.cos(t), CY + r * 0.78 * math.sin(t)

# ------------------------------------------------ câmaras nos dois anéis
# ângulo t cresce = espiral fecha. Anel EXTERNO (rota da passagem) e anel
# INTERNO (órbita do coração). (t, raio, raio_câmara, tema)
OUTER = [   # entrada → orbita → saída
    (math.pi * 1.00, 21, 6, 'plain'),   # 0 ENTRADA oeste
    (math.pi * 1.38, 20, 6, 'kelp'),    # 1 norte-oeste — floresta de kelp
    (math.pi * 1.72, 19, 6, 'banks'),   # 2 norte
    (math.pi * 0.62, 20, 6, 'banks'),   # 3 sul-oeste
    (math.pi * 0.25, 19, 6, 'plain'),   # 4 sul — cais do naufrágio
    (math.pi * 1.97, 18, 5, 'plain'),   # 5 nordeste — antessala da saída
    (math.pi * 0.02, 17, 5, 'banks'),   # 6 leste — átrio da SAÍDA
]
INNER = [
    (math.pi * 1.15, 10, 5, 'banks'),   # 7 noroeste interno
    (math.pi * 1.80, 9,  5, 'plain'),   # 8 norte interno
    (math.pi * 0.45, 10, 5, 'kelp'),    # 9 sul interno
    (math.pi * 0.05, 9,  4, 'banks'),   # 10 leste interno
    (0, 0, 6, 'heart'),                 # 11 CORAÇÃO (centro da espiral)
]
CHAMBERS = []
for t, r, cr, theme in OUTER + INNER:
    x, y = spiral_pt(t, r) if r else (CX, CY)
    CHAMBERS.append((int(x), int(y), cr, theme))

grid = [[None] * W for _ in range(H)]

def carve_blob(cx, cy, r, theme):
    pts = []
    wob = [random.uniform(0.7, 1.28) for _ in range(14)]
    for y in range(max(2, cy - r - 2), min(H - 2, cy + r + 3)):
        for x in range(max(2, cx - r - 3), min(W - 2, cx + r + 4)):
            a = math.atan2(y - cy, x - cx)
            k = int(((a + math.pi) / (2 * math.pi)) * 14) % 14
            if math.hypot((x - cx) * 0.82, (y - cy) * 1.18) <= r * wob[k] * random.uniform(0.94, 1.06):
                grid[y][x] = SEABED
                pts.append((x, y))
    random.shuffle(pts)
    if theme in ('banks', 'heart'):
        for x, y in pts[: max(3, len(pts) // 7)]:
            grid[y][x] = BANK
            for dx, dy in ((1, 0), (0, 1)):
                if random.random() < 0.5 and grid[y + dy][x + dx] == SEABED:
                    grid[y + dy][x + dx] = BANK
    if theme == 'kelp':
        for x, y in pts[: int(len(pts) * 0.45)]:
            grid[y][x] = KELP
    for x, y in pts[int(len(pts) * 0.75):]:
        if grid[y][x] == SEABED:
            grid[y][x] = SAND
    return pts

chamber_tiles = [carve_blob(*c) for c in CHAMBERS]

def carve_path(ax, ay, bx, by, width=3, tile=SEABED, over=(None,)):
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

def link(a, b, width=3):
    carve_path(*CHAMBERS[a][:2], *CHAMBERS[b][:2], width)

# anel externo (rota da passagem) · anel interno (órbita do coração)
for a, b in ((0, 1), (1, 2), (2, 5), (5, 6), (0, 3), (3, 4), (4, 6)):
    link(a, b, 3)
for a, b in ((7, 8), (8, 10), (7, 9), (9, 10), (8, 11), (9, 11), (10, 11)):
    link(a, b, 2)

# ------------------------------------------------ RIO DE SALMOURA (espiral)
# Serpenteia ENTRE os anéis — do braço externo oeste até afogar no coração.
# Largura 2 e ângulo registrado por célula (as travessias nascem DO rio).
brine_cells = []
t = math.pi * 0.9
while t < math.pi * 3.4:
    r = 15.5 - (t - math.pi * 0.9) * 2.0
    if r < 3.4:
        break
    x, y = spiral_pt(t % (2 * math.pi), r)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            px, py = int(x) + dx, int(y) + dy
            if 2 <= px < W - 2 and 2 <= py < H - 2 and abs(dx) + abs(dy) <= 2:
                grid[py][px] = BRINE
                brine_cells.append((px, py, t))
    t += 0.02

# ---------------------------------------- travessias do rio (4, como o v2b)
# 3 istmos de areia + 1 NAUFRÁGIO — nascem de células REAIS do rio.
def river_cell_at(t_target):
    px, py, _ = min(brine_cells, key=lambda c: abs(c[2] - t_target))
    return px, py

ISTHMUS = []
for tt in (math.pi * 1.42, math.pi * 2.05, math.pi * 2.45):
    bx, by = river_cell_at(tt)
    # cruza o rio radialmente (do centro pra fora): direção radial local
    vx, vy = bx - CX, by - CY
    L = max(1e-6, math.hypot(vx, vy))
    ux, uy = vx / L, vy / L
    for s in range(-4, 5):
        for wdt in (-1, 0, 1):
            px = int(bx + ux * s - uy * wdt)
            py = int(by + uy * s + ux * wdt)
            if 2 <= px < W - 2 and 2 <= py < H - 2 and grid[py][px] == BRINE:
                grid[py][px] = SAND
    ISTHMUS.append((bx, by))

wx, wy = river_cell_at(math.pi * 2.73)   # ÚLTIMO lap antes do coração (SW)
for dy in range(-2, 3):                             # casco 11×5 cruzado no rio
    for dx in range(-5, 6):
        px, py = wx + dx, wy + dy
        if 2 <= px < W - 2 and 2 <= py < H - 2:
            if abs(dy) <= 1 or abs(dx) <= 3:
                grid[py][px] = WRECK
WRECK_AT = (wx, wy)

# ---------------------------------------------------------- entrada/saída
ENTRY = (2, 22)
EXIT_ = (85, 24)
e0x, e0y = CHAMBERS[0][:2]
carve_path(ENTRY[0], ENTRY[1], e0x, e0y, 3, SAND, over=(None,))
e6x, e6y = CHAMBERS[6][:2]
carve_path(e6x, e6y, EXIT_[0], EXIT_[1], 3, SAND, over=(None,))

# CÚPULA DE AR — praça segura na entrada (candidata a estação/banco)
DOME = (12, 17)
for dy in range(-2, 3):
    for dx in range(-3, 4):
        if math.hypot(dx * 0.8, dy) <= 2.4:
            px, py = DOME[0] + dx, DOME[1] + dy
            if grid[py][px] in (None, SEABED, KELP, BRINE):
                grid[py][px] = SAND
carve_path(DOME[0], DOME[1], CHAMBERS[0][0], CHAMBERS[0][1], 2, SAND, over=(None, BRINE))

# ------------------------------------------------------- rocha viva + BFS
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
assert EXIT_ in reach, "saida inalcancavel"
assert (CX, CY) in reach, "coracao inalcancavel"
ok = sum(1 for tiles in chamber_tiles if any(p in reach for p in tiles))
tot = sum(1 for y in range(H) for x in range(W) if grid[y][x] in WALK)
print(f"BFS OK: entrada->saida E entrada->coracao | {ok}/{len(CHAMBERS)} camaras | {len(reach)}/{tot} tiles")

# --------------------------------------------------------------- conteúdo
PACKS = [(1, 4), (2, 4), (3, 4), (4, 3), (5, 3), (6, 3), (7, 3), (8, 3), (9, 3), (10, 2)]  # 32
MEDUSAS = [(CX - 3, CY - 2), (CX + 3, CY - 1), (CX - 1, CY + 3), (CX + 2, CY + 2), (CX, CY - 4)]
GUARD_WRECK = (wx, wy - 2)    # guardião do naufrágio (encontro-marco)

# trilha de corais luminosos = a ROTA (Sastasha): entrada→anel externo→saída
CORAL = []
for a, b in ((0, 1), (1, 2), (2, 5), (5, 6)):
    ax, ay = CHAMBERS[a][:2]; bx, by = CHAMBERS[b][:2]
    for i in (0.33, 0.66):
        CORAL.append((int(ax + (bx - ax) * i), int(ay + (by - ay) * i)))
CORAL += [(6, 22), (78, 24)]

# ---------------------------------------------------------------- render
CELL = 13
LEG_H = 156
img = Image.new('RGB', (W * CELL, H * CELL + LEG_H), (5, 5, 7))
dr = ImageDraw.Draw(img)

for y in range(H):
    for x in range(W):
        t = grid[y][x]
        c = SOLID if t == 'SOLID' else PAL[t]
        j = ((x * 31 + y * 17) % 7) - 3
        c = tuple(max(0, min(255, v + j)) for v in c)
        dr.rectangle([x * CELL, y * CELL, x * CELL + CELL - 1, y * CELL + CELL - 1], fill=c)
        if t == KELP and (x + y) % 2:                     # frondes de kelp
            dr.line([x * CELL + 4, y * CELL + CELL - 2, x * CELL + 5, y * CELL + 2],
                    fill=(44, 92, 70), width=1)
        if t == WRECK and (y % 2 == 0):                   # costelas do casco
            dr.line([x * CELL, y * CELL + 3, x * CELL + CELL, y * CELL + 3],
                    fill=(76, 56, 34), width=1)
        if t == SEABED and (x * 13 + y * 29) % 19 == 0:
            dr.point((x * CELL + 6, y * CELL + 6), fill=(60, 90, 130))
        if t == BRINE:                                    # névoa densa da salmoura
            if (x + y) % 3 == 0:
                dr.point((x * CELL + 6, y * CELL + 9), fill=(44, 30, 84))
            if (x * 7 + y * 3) % 5 == 0:
                dr.point((x * CELL + 3, y * CELL + 4), fill=(30, 20, 62))

for i in range(0, W * CELL, 90):                          # caustics
    dr.line([(i, 0), (i - 130, H * CELL)], fill=(30, 48, 74), width=1)

try:
    F  = ImageFont.truetype("consola.ttf", 15)
    F2 = ImageFont.truetype("consolab.ttf", 19)
except OSError:
    F = F2 = ImageFont.load_default()

# corais luminosos (rota) — halo ciano
for cx_, cy_ in CORAL:
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
ring(CX, CY, (90, 210, 230), r=CELL + 14, label="CORAÇÃO (totem candidato)", ly=-30, lx=-90)
ring(*DOME, (150, 220, 255), r=CELL + 8, w=2, label="CÚPULA DE AR (praça segura)", ly=-26, lx=-40)
ring(*GUARD_WRECK, (250, 170, 90), r=CELL + 6, w=2)
dr.text((wx * CELL - 150, (wy + 3) * CELL + 10), "NAUFRÁGIO (guardião + última travessia)",
        fill=(250, 170, 90), font=F)

for mx, my in MEDUSAS:
    x, y = mx * CELL + CELL // 2, my * CELL + CELL // 2
    dr.ellipse([x - 5, y - 5, x + 5, y + 2], outline=(250, 150, 210), width=2)
    for dx in (-3, 0, 3):
        dr.line([(x + dx, y + 2), (x + dx, y + 7)], fill=(250, 150, 210), width=1)

for ch, n in PACKS:
    ccx, ccy = CHAMBERS[ch][:2]
    for i in range(n):
        px = ccx * CELL + int(math.cos(i * 2.4) * CELL * 1.3)
        py = ccy * CELL + int(math.sin(i * 2.4) * CELL * 1.3)
        dr.ellipse([px - 3, py - 3, px + 3, py + 3], fill=(235, 120, 100))

kx, ky = CHAMBERS[1][:2]
dr.text((kx * CELL - 40, (ky - 8) * CELL), "FLORESTA DE KELP (emboscada)", fill=(90, 170, 130), font=F)

# istmos marcados (travessias táticas)
for bx, by in ISTHMUS:
    ring(bx, by, (235, 90, 90), r=CELL - 1, w=2)

# bússola + escala (leitura de mapa)
cpx, cpy = W * CELL - 64, 30
dr.ellipse([cpx - 22, cpy - 22, cpx + 22, cpy + 22], outline=(160, 165, 185), width=2)
dr.polygon([(cpx, cpy - 18), (cpx - 5, cpy + 4), (cpx + 5, cpy + 4)], fill=(220, 224, 240))
dr.text((cpx - 5, cpy - 44), "N", fill=(220, 224, 240), font=F)
dr.line([(20, H * CELL - 16), (20 + 10 * CELL, H * CELL - 16)], fill=(200, 205, 220), width=2)
for i in (0, 5, 10):
    dr.line([(20 + i * CELL, H * CELL - 20), (20 + i * CELL, H * CELL - 12)], fill=(200, 205, 220), width=2)
dr.text((24 + 10 * CELL, H * CELL - 24), "10 tiles", fill=(200, 205, 220), font=F)

# ---------------------------------------------------------------- legenda
ly0 = H * CELL + 10
dr.text((12, ly0), "FLOOR -2 v2 — \"O NAUTILUS\"  ·  ZONE 3 (district_two) retheme  ·  88×44  ·  submerso",
        fill=(215, 220, 235), font=F2)
sw = [("leito", PAL[SEABED]), ("areia", PAL[SAND]), ("banco tan", PAL[BANK]),
      ("SALMOURA (não anda)", PAL[BRINE]), ("kelp", PAL[KELP]), ("naufrágio", PAL[WRECK]),
      ("rocha ferrugem", PAL[ROCK])]
x0 = 12
for name, c in sw:
    dr.rectangle([x0, ly0 + 34, x0 + 18, ly0 + 52], fill=c, outline=(110, 105, 120))
    dr.text((x0 + 24, ly0 + 36), name, fill=(195, 200, 214), font=F)
    x0 += 24 + len(name) * 8 + 20
dr.text((12, ly0 + 64),
        "A CONCHA: anel externo = rota da passagem (corais luminosos guiam) · RIO DE SALMOURA espiral separa os anéis · coração = mergulho OPCIONAL",
        fill=(172, 180, 198), font=F)
dr.text((12, ly0 + 88),
        "UMA travessia por VOLTA da espiral: istmo NO → istmo NE → istmo SE → NAUFRÁGIO (guardião) — cruzar de novo = mergulhar mais fundo (4, como o v2b)",
        fill=(172, 180, 198), font=F)
dr.text((12, ly0 + 112),
        "32 minions em grupos por câmara · 5 águas-vivas no coração · cúpula de ar = praça segura (candidata a estação de banco)",
        fill=(172, 180, 198), font=F)
dr.text((12, ly0 + 134),
        "padrões: Calassa (câmaras/cúpula) · Throne of the Tides (nautilus/kelp/naufrágio) · Sastasha (coral-rota) · Lost River (salmoura) · BFS provado",
        fill=(140, 148, 166), font=F)

out = r"C:\Users\jr\Desktop\mapas-game-two\conceito-floor2-nautilus-v2-88x44.png"
img.save(out)
print("salvo:", out)

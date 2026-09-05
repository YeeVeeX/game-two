# Medusa tower - 9 concept candidates (3 floors x 3 ideas), docs-only.
# Stage 3 of Junior's order (swap spec drafts/_swap-spec-medusa-to-dungeon1-20260831.md).
# Tower floors live under DUNGEON 1 (= MEDUSA LOWER post-swap): dungeon_2/3/4.
# Entry marker = stairs from the floor above; gold exit = stairs down;
# pink = future tower-boss post (floor 4 only - no BOSS 1 duplication).
import math
import random
from collections import deque
from PIL import Image, ImageDraw, ImageFont

OUT = "drafts/_medusa-tower"

def grid(w, h, fill="#"):
    return [[fill] * w for _ in range(h)]

def carve(g, pts, r=1):
    # 4-conectado SEMPRE: passo diagonal ganha tile-ponte (lição desta sessão:
    # escada diagonal r=0 não conecta sob 4-adjacência — 522 órfãos na colmeia v1)
    h, w = len(g), len(g[0])
    prev = None
    for i in range(len(pts) - 1):
        (x0, y0), (x1, y1) = pts[i], pts[i + 1]
        steps = max(abs(x1 - x0), abs(y1 - y0))
        for s in range(steps + 1):
            x = round(x0 + (x1 - x0) * s / max(steps, 1))
            y = round(y0 + (y1 - y0) * s / max(steps, 1))
            cells = [(x, y)]
            if prev is not None and x != prev[0] and y != prev[1]:
                cells.append((x, prev[1]))   # a ponte
            for cx, cy in cells:
                for dx in range(-r, r + 1):
                    for dy in range(-r, r + 1):
                        nx, ny = cx + dx, cy + dy
                        if 1 <= nx < w - 1 and 1 <= ny < h - 1:
                            g[ny][nx] = "."
            prev = (x, y)

def disc(g, cx, cy, r):
    h, w = len(g), len(g[0])
    for y in range(h):
        for x in range(w):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r * r:
                if 1 <= x < w - 1 and 1 <= y < h - 1:
                    g[y][x] = "."

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

# ============ ANDAR 2 - TORRE DA MEDUSA estilo Tibia ============
# Referencia do Junior (2026-08-31, screenshot Tibia banked md5 4d006217...):
# torre REDONDA de muralha avermelhada, interior de pedra cinza com paredes
# internas, campo verde de selva ao redor com entulho. A chegada (queda do
# buraco da serpente) aterrissa no CAMPO; entra-se na torre pela boca sul;
# a escada pro andar 3 fica dentro da torre.

def field(W, H):
    g = grid(W, H, ".")
    for x in range(W):
        g[0][x] = g[H - 1][x] = "#"
    for y in range(H):
        g[y][0] = g[y][W - 1] = "#"
    return g

def blob(g, cx, cy, R0, amps, mouths, thick=2.2, skirt_w=1.6):
    # torre ORGANICA: raio ondula por angulo (nada de circulo perfeito);
    # mouths = janelas angulares que cortam muralha+saia (bocas/brechas)
    H, W = len(g), len(g[0])
    stone, ringw, skirt = set(), set(), set()
    for y in range(1, H - 1):
        for x in range(1, W - 1):
            dx, dy = x - cx, y - cy
            d = math.hypot(dx, dy)
            th = math.degrees(math.atan2(dy, dx)) % 360
            Rw = R0 * (1 + sum(a * math.sin(math.radians(k * th) + p) for k, a, p in amps))
            in_mouth = any(lo <= th <= hi for lo, hi in mouths)
            if d < Rw - thick:
                stone.add((x, y))
            elif d <= Rw + 0.4:
                if in_mouth:
                    stone.add((x, y))
                else:
                    g[y][x] = "#"
                    ringw.add((x, y))
            elif d <= Rw + 0.4 + skirt_w and not in_mouth:
                if g[y][x] == ".":
                    skirt.add((x, y))          # saia escura decorativa (andavel)
    return stone, ringw, skirt

def jungle(g, seed, keep_clear, n=95):
    rng = random.Random(seed)
    debris = set()
    H, W = len(g), len(g[0])
    for _ in range(n):
        x, y = rng.randrange(2, W - 2), rng.randrange(2, H - 2)
        if g[y][x] == "." and (x, y) not in keep_clear:
            g[y][x] = "#"
            debris.add((x, y))
    return debris

def wall_seg(g, ring, pts):
    h, w = len(g), len(g[0])
    prev = None
    for i in range(len(pts) - 1):
        (x0, y0), (x1, y1) = pts[i], pts[i + 1]
        steps = max(abs(x1 - x0), abs(y1 - y0))
        for s in range(steps + 1):
            x = round(x0 + (x1 - x0) * s / max(steps, 1))
            y = round(y0 + (y1 - y0) * s / max(steps, 1))
            cells = [(x, y)]
            if prev is not None and x != prev[0] and y != prev[1]:
                cells.append((x, prev[1]))
            for cx_, cy_ in cells:
                if 1 <= cx_ < w - 1 and 1 <= cy_ < h - 1:
                    g[cy_][cx_] = "#"
                    ring.add((cx_, cy_))
            prev = (x, y)

def tibia_complex(g, ring, ox, oy):
    # TRANSCRICAO TILE A TILE do 3o shot do Junior
    # (referencia_tibia_parede_divisoria.png, ampliado em _ref_divisoria_5x.png):
    # a espiral "5" (barra topo + lateral esq + barra meio + DIVISORIA descendo
    # ate a boca sul), o bolso "1" a leste (loot preso), espora norte, toco
    # solto. A divisoria sela o sul: entrada (oeste dela) e escada (bolso
    # leste) so se ligam PELA VOLTA COMPLETA oeste->topo->leste.
    segs = [
        [(26, 16), (26, 19)],   # espora norte (cola na muralha)
        [(22, 21), (27, 21)],   # barra topo do "5"
        [(22, 21), (22, 25)],   # lateral esquerda
        [(22, 25), (28, 25)],   # barra do meio
        [(28, 25), (28, 37)],   # a DIVISORIA (desce ate a boca sul)
        [(22, 29), (23, 29)],   # toco solto
        [(31, 21), (31, 29)],   # o "1" - parede do bolso leste
        [(30, 21), (31, 21)],   # serifa do "1"
        [(32, 29), (32, 29)],   # pedra solta na base do bolso
    ]
    for s in segs:
        wall_seg(g, ring, [(x + ox, y + oy) for x, y in s])

def spiral_tower(name, ruina=False, criptas=False, segs=None, dots=None,
                 items=None, entry=(26, 44), out=(34, 27)):
    # Pedido do Junior (4o shot, 2026-08-31): TODO o acessivel DENTRO do
    # circulo; fora = rocha inacessivel; a volta interna a MAIOR possivel.
    # Espiral de 3 arcos concentricos com bocas ALTERNADAS (N/S/N): da porta
    # de entrada (sul) ate a escada (centro) sao ~3 meias-voltas forcadas.
    W = H = 52
    cx = cy = 26
    R = 22.0
    g = grid(W, H, "#")                        # TUDO rocha; so a torre e escavada
    stone, ring, skirt = set(), set(), set()
    for y in range(1, H - 1):
        for x in range(1, W - 1):
            d = math.hypot(x - cx, y - cy)
            if d < R - 1.8:
                g[y][x] = "."
                stone.add((x, y))
            elif d <= R:
                ring.add((x, y))               # muralha (fica '#')
            elif d <= R + 1.6:
                skirt.add((x, y))              # saia escura na rocha
    # Padrao default = AS LINHAS DO SHOT +1 (referencia_tibia_linha_exata.png,
    # lido a 6x), transcritas por PROPORCAO do raio: espiral retangular.
    # Outros padroes (mesmo estilo Tibia) entram via segs/dots/items.
    if segs is None:
        segs = [
            [(22, 15), (22, 38)],    # vertical alta oeste
            [(22, 38), (27, 38)],    # pe (sela o sul do corredor, so x28-29 passa)
            [(22, 15), (38, 15)],    # barra do topo
            [(38, 15), (38, 21)],    # queda direita
            [(30, 21), (38, 21)],    # barra do meio (volta pra oeste)
            [(30, 21), (30, 33)],    # queda interna
            [(30, 33), (46, 33)],    # barra de baixo, SELA na muralha leste
        ]
        dots = ((13, 19), (14, 19), (13, 32))  # pontos soltos do oeste (decor)
        items = [(33, 17), (36, 28)]           # os 2 loots do shot (sala + bolso)
    for s in segs:
        wall_seg(g, ring, s)
    for dx_, dy_ in (dots or ()):
        g[dy_][dx_] = "#"
        ring.add((dx_, dy_))
    for x, y in list(ring):
        stone.discard((x, y))
    if ruina:
        rng = random.Random(21)
        for c_ang, span in ((30, 14), (150, 10), (250, 12)):   # muralha desmoronada
            for dd in range(-span, span + 1, 2):
                th = math.radians(c_ang + dd)
                for rr in (R - 0.9, R - 0.2):
                    x = round(cx + rr * math.cos(th))
                    y = round(cy + rr * math.sin(th))
                    ring.discard((x, y))       # vira rocha crua (buraco na pintura)
        for c_ang, off, span in ((40, 3.4, 16), (200, 4.2, 12), (320, 3.0, 10)):
            for dd in range(-span, span + 1, 2):   # pedacos caidos NA rocha (decor)
                th = math.radians(c_ang + dd)
                x = round(cx + (R + off) * math.cos(th))
                y = round(cy + (R + off) * math.sin(th))
                if 1 <= x < W - 1 and 1 <= y < H - 1:
                    ring.add((x, y))
    if criptas:
        # criptas = NICHOS radiais escavados na propria muralha (fundo cego:
        # a rocha atras segue '#' - zero atalho, so recompensa)
        for (nx, ny), (ix, iy) in (((47, 26), (48, 26)), ((5, 26), (4, 26)),
                                   ((26, 5), (26, 4))):
            for x, y in ((nx, ny), (ix, iy)):
                g[y][x] = "."
                stone.add((x, y))
                ring.discard((x, y))
            items.append((ix, iy))
    return dict(name=name, g=g, entry=entry, out=out, size=(W, H),
                stone=stone, skirt=skirt, items=items, ring=ring, rock=True)

def f2_replica():
    # A - o PISO -1 do Tibia (referencia_tibia_parede_divisoria.png): o "5"
    # (espora N + topo + lateral + barra meio) + a DIVISORIA colando na
    # muralha sul + bolso "1" (serifa + parede + ponto). Volta validada: 59.
    segs = [
        [(26, 8), (26, 13)],     # espora norte
        [(19, 17), (28, 17)],    # barra do topo
        [(19, 17), (19, 24)],    # lateral esquerda
        [(19, 24), (30, 24)],    # barra do meio
        [(30, 24), (30, 46)],    # a DIVISORIA (cola na muralha sul)
        [(19, 31), (21, 31)],    # toco solto
        [(32, 17), (35, 17)],    # serifa do "1"
        [(35, 17), (35, 27)],    # parede do bolso leste
        [(37, 31), (37, 31)],    # ponto solto
    ]
    return spiral_tower("F2_A_divisoria", ruina=True, segs=segs,
                        items=[(24, 22), (33, 27)], entry=(28, 44), out=(33, 22))

def f2_ruina():
    # B - o PISO +1 (escolha do Junior) - INTOCADO: espiral retangular + ruina
    return spiral_tower("F2_fiel_ruina", ruina=True)

def f2_complexo():
    # C - PORTAO-PEDAGIO (mesmo estilo de linha reta): quartinho central de
    # DUAS portas (leste/oeste) e dois selos (espora N + selo SW) que partem
    # o disco em duas metades - a UNICA ligacao e ATRAVES da sala. A volta
    # atravessa a luta: boca -> crescente leste -> porta E -> sala (pedagio)
    # -> porta W -> crescente oeste -> escada no bolso SW.
    segs = [
        [(19, 22), (33, 22)],    # sala - parede norte
        [(33, 22), (33, 30)],    # sala - leste
        [(19, 30), (33, 30)],    # sala - sul
        [(19, 22), (19, 30)],    # sala - oeste
        [(26, 7), (26, 22)],     # espora norte (sela a banda de cima)
        [(19, 30), (19, 46)],    # selo SW (sela o sul a oeste da boca)
    ]
    c = spiral_tower("F2_C_portao", ruina=True, segs=segs,
                     items=[(26, 26), (15, 35)], entry=(26, 44), out=(14, 36))
    g = c["g"]
    for dx_, dy_ in ((33, 26), (19, 26)):      # as DUAS portas da sala
        g[dy_][dx_] = "."
        c["ring"].discard((dx_, dy_))
        c["stone"].add((dx_, dy_))
    return c

# ============ ANDAR 3 - o ninho ============
def f3_ninho():
    W = H = 48
    g = grid(W, H)
    ch = [(24, 7, 4), (10, 14, 5), (38, 13, 5), (24, 22, 6), (9, 32, 5), (24, 38, 5), (39, 33, 5)]
    for cx, cy, r in ch:
        disc(g, cx, cy, r)
    pairs = [(0, 1), (0, 2), (1, 3), (2, 3), (3, 4), (3, 6), (4, 5), (6, 5)]
    for a, b in pairs:
        carve(g, [ch[a][:2], ch[b][:2]])
    return dict(name="F3_ninho", g=g, entry=(24, 7), out=(24, 38), size=(W, H))

def f3_galeria():
    W, H = 56, 36
    g = grid(W, H, ".")
    for x in range(W):
        g[0][x] = g[H - 1][x] = "#"
    for y in range(H):
        g[y][0] = g[y][W - 1] = "#"
    water = set()
    def blob(cx, cy, rx, ry):
        for y in range(H):
            for x in range(W):
                if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1:
                    if 1 <= x < W - 1 and 1 <= y < H - 1:
                        g[y][x] = "#"
                        water.add((x, y))
    blob(14, 9, 9, 5)
    blob(38, 8, 8, 4)
    blob(10, 26, 7, 5)
    blob(28, 20, 9, 6)
    blob(46, 25, 7, 6)
    for pts in ([(23, 6), (29, 6)], [(28, 13), (28, 15)], [(19, 24), (16, 26)], [(37, 22), (40, 23)]):
        carve(g, pts, r=0)                        # vaus (fords) entre as aguas
        for p in pts:
            water.discard(p)
    return dict(name="F3_galeria", g=g, entry=(2, 17), out=(53, 17), size=(W, H), void=water)

def f3_colmeia():
    W, H = 52, 44
    g = grid(W, H)
    cells = []
    for row, y in enumerate((6, 14, 22, 30, 38)):
        off = 6 if row % 2 else 0
        for x in range(8 + off, 46, 12):
            cells.append((x, y))
            disc(g, x, y, 3)
    for i, (x, y) in enumerate(cells):
        for (nx, ny) in cells:
            if (nx, ny) == (x, y):
                continue
            d2 = (nx - x) ** 2 + (ny - y) ** 2
            if d2 <= 170 and (ny > y or (ny == y and nx > x)):
                carve(g, [(x, y), (nx, ny)], r=0)
    return dict(name="F3_colmeia", g=g, entry=(8, 6), out=(44, 38), size=(W, H))

# ============ ANDAR 4 - o FUNDO (arena do futuro boss da torre) ============
def f4_arena():
    W = H = 44
    g = grid(W, H)
    disc(g, 22, 22, 17)
    for dx, dy in ((10, 0), (7, 7), (0, 10), (-7, 7), (-10, 0), (-7, -7), (0, -10), (7, -7)):
        g[22 + dy][22 + dx] = "#"                 # anel de 8 pilares
    carve(g, [(22, 5), (22, 3)], r=0)             # alcova da escada (norte)
    return dict(name="F4_arena", g=g, entry=(22, 3), out=None, boss=(22, 22), size=(W, H))

def f4_sino():
    W, H = 48, 44
    g = grid(W, H)
    for y in range(H):
        for x in range(W):
            if ((x - 24) / 19) ** 2 + ((y - 24) / 17) ** 2 <= 1:
                if 1 <= x < W - 1 and 1 <= y < H - 1:
                    g[y][x] = "."
    for arc in ([(12, 14), (14, 18), (16, 22)], [(36, 14), (34, 18), (32, 22)],
                [(14, 30), (18, 33), (22, 34)], [(34, 30), (30, 33), (26, 34)]):
        for x, y in arc:
            g[y][x] = "#"                         # colunas-tentaculo penduradas
    carve(g, [(24, 8), (24, 6)], r=0)
    return dict(name="F4_sino", g=g, entry=(24, 6), out=None, boss=(24, 22), size=(W, H))

def f4_santuario():
    W, H = 56, 32
    g = grid(W, H)
    for y in range(6, 26):
        for x in range(3, 53):
            g[y][x] = "."
    for x in range(10, 45, 6):                    # colunatas duplas
        for yy in (10, 11, 19, 20):
            g[yy][x] = g[yy][x + 1] = "#"
    for y in list(range(6, 12)) + list(range(20, 26)):
        g[y][45] = "#"                            # muros do presbiterio (portal central)
    carve(g, [(1, 15), (3, 15)], r=0)
    return dict(name="F4_santuario", g=g, entry=(1, 15), out=None, boss=(49, 15), size=(W, H))

# ============ validacao + render ============
def render(c, path):
    g = c["g"]
    H, W = len(g), len(g[0])
    px = 8
    void = c.get("void", set())
    stone = c.get("stone", set())
    debris = c.get("debris", set())
    ring = c.get("ring", set())
    tibia = bool(stone)                        # torre enterrada = modo SUBTERRANEO
    img = Image.new("RGB", (W * px, H * px), (56, 44, 34) if tibia else (12, 10, 8))
    d = ImageDraw.Draw(img)
    for y in range(H):
        for x in range(W):
            if g[y][x] == "#":
                if (x, y) in void:
                    fill = (18, 42, 52)
                elif (x, y) in debris:
                    fill = (84, 62, 44)               # rochas caidas da caverna
                elif (x, y) in ring:
                    fill = (176, 58, 36)              # muralha enterrada (ruina)
                elif (x, y) in c.get("skirt", set()):
                    fill = (54, 38, 28)               # saia escura na rocha
                elif tibia:
                    fill = (38, 30, 24) if (x * 7 + y * 13) % 9 else (46, 37, 29)
                else:
                    fill = (108, 92, 76)
                d.rectangle([x * px, y * px, x * px + px - 1, y * px + px - 1], fill=fill)
            elif (x, y) in stone:
                base = (128, 128, 132)                # pedra cinza
                if (x * 7 + y * 13) % 7 == 0:
                    base = (108, 108, 114)
                d.rectangle([x * px, y * px, x * px + px - 1, y * px + px - 1], fill=base)
            elif (x, y) in c.get("skirt", set()):     # saia escura da muralha
                d.rectangle([x * px, y * px, x * px + px - 1, y * px + px - 1],
                            fill=(70, 44, 32))
            elif tibia:
                m = (x * 7 + y * 13) % 11
                if m == 0:                            # pedrinhas do chao de terra
                    d.rectangle([x * px + 1, y * px + 1, x * px + px - 2, y * px + px - 2],
                                fill=(44, 34, 26))
                elif m == 5:                          # tufos raros de musgo (subsolo vivo)
                    d.rectangle([x * px + 2, y * px + 2, x * px + px - 3, y * px + px - 3],
                                fill=(38, 66, 38))
            elif (x * 7 + y * 13) % 5 == 0:
                d.rectangle([x * px + 1, y * px + 1, x * px + px - 2, y * px + px - 2],
                            fill=(30, 62, 70))
    for ix, iy in c.get("items", []):                 # loot amarelo (decor do shot)
        d.rectangle([ix * px + 2, iy * px + 2, ix * px + px - 3, iy * px + px - 3],
                    fill=(232, 200, 60))
    for tag, col in (("entry", (235, 190, 90)), ("out", (235, 150, 40)), ("boss", (255, 40, 120))):
        if c.get(tag):
            x, y = c[tag]
            d.rectangle([x * px, y * px, x * px + px - 1, y * px + px - 1], fill=col)
    img = img.resize((W * px * 2, H * px * 2), Image.NEAREST)
    img.save(path)


def main():
    floors = {
        "ANDAR_2": [f2_replica(), f2_ruina(), f2_complexo()],
        "ANDAR_3": [f3_ninho(), f3_galeria(), f3_colmeia()],
        "ANDAR_4": [f4_arena(), f4_sino(), f4_santuario()],
    }
    ok_all = True
    for floor, cands in floors.items():
        for c in cands:
            g = c["g"]
            for tag in ("entry", "out", "boss"):
                if c.get(tag):
                    x, y = c[tag]
                    g[y][x] = "."
            seen = bfs(g, c["entry"])
            target = c.get("out") or c.get("boss")
            reach = target in seen
            floor_tiles = sum(row.count(".") for row in g)
            orphan = floor_tiles - len(seen)
            ok = reach and orphan == 0
            ok_all &= ok
            render(c, f"{OUT}/{c['name']}.png")
            print(f"{c['name']}: {c['size'][0]}x{c['size'][1]} tiles={floor_tiles} "
                  f"alvo_alcancavel={reach} orfaos={orphan} {'OK' if ok else 'FALHA'}")
    print("TODOS VALIDOS" if ok_all else ">>> FALHA EM ALGUM <<<")

    # montagem por andar
    try:
        font = ImageFont.truetype("arial.ttf", 21)
    except OSError:
        font = ImageFont.load_default()
    labels = {
        "F2_A_divisoria": "2.1 A - piso -1 do Tibia: o 5 + bolso 1, divisoria ate a muralha sul",
        "F2_fiel_ruina": "2.2 B - piso +1 (ESCOLHA DO JUNIOR, intocada): espiral retangular",
        "F2_C_portao": "2.3 C - portao-pedagio: sala de 2 portas, unica ponte entre as metades",
        "F3_ninho": "3.1 NINHO - camaras-ovo organicas ligadas por tubos",
        "F3_galeria": "3.2 GALERIA INUNDADA - aguas profundas recortando o piso, 4 vaus",
        "F3_colmeia": "3.3 COLMEIA - celulas em treliça hexagonal, loops por toda parte",
        "F4_arena": "4.1 ARENA - circulo classico, anel de 8 pilares, posto do boss no centro",
        "F4_sino": "4.2 SINO - camara-sino de agua-viva, colunas-tentaculo, boss no foco",
        "F4_santuario": "4.3 SANTUARIO - salao com colunatas, presbiterio elevado, boss no altar",
    }
    for floor, cands in floors.items():
        imgs = [(labels[c["name"]], Image.open(f"{OUT}/{c['name']}.png")) for c in cands]
        W = max(im.width for _, im in imgs) + 40
        header = 38
        H = sum(im.height + header + 16 for _, im in imgs) + 16
        canvas = Image.new("RGB", (W, H), (16, 14, 12))
        d = ImageDraw.Draw(canvas)
        y = 16
        d.text((20, y), "", font=font)
        for t, im in imgs:
            d.text((20, y), t, fill=(225, 215, 200), font=font)
            y += header
            canvas.paste(im, ((W - im.width) // 2, y))
            y += im.height + 16
        canvas.save(f"{OUT}/{floor}.png")
        print(f"montagem {floor}.png: {canvas.size}")


if __name__ == "__main__":
    main()

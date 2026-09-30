"""Generates the animated effect sprites used by the prayer system.

Run from the repository root:  python tools/dreamvalley/gen_prayer_fx.py
Writes icons/effects/prayer_fx.dmi (32x32) and icons/effects/prayer_fx_64.dmi (64x64).
Most sprites are drawn in white/grey so the game can tint them per request;
a few carry their own colours.
"""
import math
import random
from PIL import Image, ImageDraw, ImageFilter, PngImagePlugin

FRAMES = 8


def blank(size):
    return Image.new("RGBA", (size, size), (0, 0, 0, 0))


def glow(img, radius=1.2, strength=1.0):
    """Adds a soft halo under everything drawn so far."""
    blur = img.filter(ImageFilter.GaussianBlur(radius))
    if strength != 1.0:
        a = blur.split()[3].point(lambda v: min(255, int(v * strength)))
        blur.putalpha(a)
    out = blank(img.size[0])
    out.alpha_composite(blur)
    out.alpha_composite(img)
    return out


def star(d, x, y, r, col):
    d.line([(x - r, y), (x + r, y)], fill=col)
    d.line([(x, y - r), (x, y + r)], fill=col)
    if r > 1:
        d.point([(x - 1, y - 1), (x + 1, y + 1), (x - 1, y + 1), (x + 1, y - 1)], fill=col[:3] + (col[3] // 2,))


def fade(i, n=FRAMES):
    """1 at the start, 0 at the end."""
    return 1 - i / (n - 1)


def rise(i, n=FRAMES):
    return i / (n - 1)


W = (255, 255, 255)


def A(c, a):
    return c + (max(0, min(255, int(a))),)


# ---------------------------------------------------------------- 32x32 states
def st_sparkle(i):
    rnd = random.Random(7)
    im = blank(32)
    d = ImageDraw.Draw(im)
    for k in range(7):
        x, y = rnd.randint(5, 26), rnd.randint(5, 28)
        phase = (i + k * 3) % FRAMES
        r = [0, 1, 2, 3, 2, 1, 0, 0][phase]
        if r:
            star(d, x, y, r, A(W, 230))
    return glow(im, 1.0)


def st_motes(i):
    rnd = random.Random(3)
    im = blank(32)
    d = ImageDraw.Draw(im)
    for k in range(9):
        x = rnd.randint(6, 25) + round(math.sin((i + k) * 0.8))
        y0 = rnd.randint(18, 30)
        y = y0 - (i * 3 + k * 2) % 22
        a = 255 * (y / 30)
        d.point((x, y), fill=A(W, a))
        d.point((x, y + 1), fill=A(W, a * 0.4))
    return glow(im, 0.8)


def st_halo(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    pulse = 0.6 + 0.4 * math.sin(i / FRAMES * math.tau)
    d.ellipse([8, 1, 23, 6], outline=A(W, 255 * pulse), width=1)
    d.ellipse([9, 2, 22, 5], outline=A(W, 120 * pulse), width=1)
    return glow(im, 1.2, 1.4)


def st_feathers(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    for k, (x0, y0) in enumerate([(9, 2), (20, -6), (14, -14)]):
        y = y0 + i * 3
        x = x0 + round(3 * math.sin((i + k * 2) * 0.9))
        if 0 <= y < 30:
            d.line([(x, y), (x + 3, y + 4)], fill=A(W, 240))
            d.line([(x + 1, y), (x + 3, y + 2)], fill=A((230, 230, 240), 180))
            d.line([(x - 1, y + 1), (x + 2, y + 4)], fill=A((210, 210, 225), 150))
    return glow(im, 0.7)


def heart(d, x, y, col):
    d.point([(x, y), (x + 2, y), (x - 1, y + 1), (x + 1, y + 1), (x + 3, y + 1), (x, y + 2), (x + 2, y + 2), (x + 1, y + 3)], fill=col)
    d.point([(x + 1, y + 1), (x, y + 1), (x + 2, y + 1), (x + 1, y + 2)], fill=col)


def st_hearts(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    for k, (x, y0) in enumerate([(8, 28), (18, 24), (13, 34), (22, 32)]):
        y = y0 - i * 3 - k
        if 0 <= y < 29:
            heart(d, x + round(math.sin(i + k) * 1.5), y, A((255, 150, 190), 255 * (y / 30) + 60))
    return glow(im, 1.0)


def st_leaves(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    for k in range(5):
        ang = (i / FRAMES) * math.tau + k * math.tau / 5
        r = 10 - i
        x, y = 16 + r * math.cos(ang), 18 + r * 0.5 * math.sin(ang) - i
        col = [(120, 200, 80), (160, 220, 90), (90, 170, 60)][k % 3]
        d.ellipse([x - 1.5, y - 1, x + 1.5, y + 1], fill=A(col, 255 * fade(i) + 40))
        d.point((x + 2, y), fill=A((70, 120, 40), 200 * fade(i)))
    return glow(im, 0.6)


def st_drops(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    for k, x in enumerate([9, 15, 21, 12, 19]):
        y = (i * 4 + k * 5) % 26
        d.line([(x, y), (x, y + 2)], fill=A((170, 220, 255), 230))
    r = i * 1.6
    d.ellipse([16 - r, 27 - r * 0.35, 16 + r, 27 + r * 0.35], outline=A((200, 235, 255), 200 * fade(i)))
    return glow(im, 0.8)


def st_flame_wisp(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    rnd = random.Random(i * 11 + 5)
    for k in range(4):
        x = 8 + k * 5 + rnd.randint(-1, 1)
        h = 6 + rnd.randint(0, 5)
        base = 28 - (i * 2 + k * 3) % 10
        for yy in range(h):
            w = max(0, round((h - yy) / h * 2))
            t = yy / h
            col = (255, int(230 - 150 * t), int(120 - 120 * t))
            d.line([(x - w, base - yy), (x + w, base - yy)], fill=A(col, 255 * (1 - t) + 40))
    return glow(im, 1.2, 1.3)


def st_frost(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    r = 3 + i * 1.6
    for a in range(6):
        ang = a * math.pi / 3 + i * 0.05
        x2, y2 = 16 + r * math.cos(ang), 16 + r * math.sin(ang)
        d.line([(16, 16), (x2, y2)], fill=A((210, 240, 255), 255 * fade(i) + 30))
        mx, my = 16 + r * 0.6 * math.cos(ang), 16 + r * 0.6 * math.sin(ang)
        for s in (-0.6, 0.6):
            d.line([(mx, my), (mx + 3 * math.cos(ang + s), my + 3 * math.sin(ang + s))], fill=A((230, 250, 255), 200 * fade(i)))
    return glow(im, 1.0)


def st_chains(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    close = min(1, i / 4)
    for band, y in enumerate((12, 20)):
        w = 14 * close
        for x in range(int(16 - w), int(16 + w) + 1, 4):
            d.ellipse([x - 2, y - 1, x + 1, y + 1], outline=A((200, 190, 160), 255 if i < 6 else 140))
    return glow(im, 0.6)


def st_eye(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    openness = [0, 1, 3, 5, 5, 5, 3, 1][i]
    d.arc([6, 16 - openness - 2, 26, 16 + openness + 2], 200, 340, fill=A(W, 255))
    d.arc([6, 16 - openness - 2, 26, 16 + openness + 2], 20, 160, fill=A(W, 255))
    if openness > 2:
        d.ellipse([13, 13, 19, 19], outline=A(W, 255))
        d.ellipse([15, 15, 17, 17], fill=A(W, 255))
    return glow(im, 1.3, 1.5)


def st_skull_wisp(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    y = 20 - i * 2
    a = 255 * fade(i) + 20
    d.ellipse([10, y - 6, 22, y + 5], fill=A((220, 230, 225), a * 0.9))
    d.rectangle([12, y + 3, 20, y + 7], fill=A((220, 230, 225), a * 0.9))
    d.ellipse([12, y - 2, 15, y + 1], fill=(0, 0, 0, 0))
    d.ellipse([17, y - 2, 20, y + 1], fill=(0, 0, 0, 0))
    d.point([(14, y + 6), (16, y + 6), (18, y + 6)], fill=(0, 0, 0, 0))
    for k in range(3):
        d.line([(12 + k * 4, y + 8), (12 + k * 4 + round(math.sin(i + k)), y + 12)], fill=A((200, 220, 210), a * 0.4))
    return glow(im, 1.2, 1.3)


Z_GLYPH = ["###", "..#", ".#.", "#..", "###"]


def st_zzz(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    for k in range(3):
        t = (i + k * 3) % FRAMES
        x, y = 12 + k * 4 + t, 22 - t * 2 - k * 3
        s = 1 + (k == 2)
        for yy, row in enumerate(Z_GLYPH):
            for xx, ch in enumerate(row):
                if ch == "#":
                    d.rectangle([x + xx * s, y + yy * s, x + xx * s + s - 1, y + yy * s + s - 1], fill=A(W, 255 * (1 - t / FRAMES)))
    return glow(im, 0.6)


def st_coins(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    for k, x in enumerate([9, 16, 23]):
        y = 26 - ((i * 3 + k * 4) % 20)
        wid = [3, 2, 1, 2][((i + k) % 4)]
        d.ellipse([x - wid, y - 3, x + wid, y + 3], fill=A((240, 200, 80), 255), outline=A((170, 120, 40), 255))
        if (i + k) % 3 == 0:
            star(d, x + 2, y - 3, 1, A((255, 250, 210), 255))
    return glow(im, 0.8)


def st_pages(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    for k in range(3):
        ang = i * 0.6 + k * 2
        x, y = 16 + 9 * math.cos(ang), 16 + 6 * math.sin(ang) - i
        w = 3 * abs(math.cos(ang * 1.3)) + 1
        d.rectangle([x - w, y - 3, x + w, y + 3], fill=A((245, 235, 205), 230), outline=A((150, 130, 90), 200))
        d.line([(x - w + 1, y - 1), (x + w - 1, y - 1)], fill=A((110, 90, 60), 160))
    return glow(im, 0.6)


def st_thorns(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    grow = min(1, i / 3) * (1 if i < 6 else 0.6)
    for k in range(7):
        ang = k * math.tau / 7
        x, y = 16 + 11 * math.cos(ang), 24 + 4 * math.sin(ang)
        h = 7 * grow
        d.polygon([(x - 1.5, y), (x + 1.5, y), (x + math.cos(ang) * 2, y - h)], fill=A((110, 150, 70), 255))
    return glow(im, 0.5)


def st_tendrils(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    for k, x0 in enumerate([8, 13, 19, 24]):
        pts = []
        h = min(22, i * 4 + k)
        for yy in range(h):
            pts.append((x0 + 2.5 * math.sin(yy * 0.45 + i * 0.7 + k), 30 - yy))
        if len(pts) > 1:
            d.line(pts, fill=A((40, 20, 60), 230), width=2)
            d.line(pts, fill=A((120, 60, 170), 150), width=1)
    return glow(im, 1.2, 1.2)


def st_rot_flies(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    rnd = random.Random(21)
    for k in range(8):
        cx, cy = rnd.randint(8, 24), rnd.randint(6, 22)
        ang = i * 0.9 + k
        x, y = cx + 4 * math.cos(ang), cy + 3 * math.sin(ang * 1.3)
        d.point([(x, y), (x + 1, y)], fill=A((40, 50, 20), 255))
        d.point([(x, y - 1)], fill=A((160, 170, 150), 120))
    d.ellipse([7, 26, 25, 30], fill=A((90, 110, 40), 90))
    return im


def st_crack(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    rnd = random.Random(9)
    length = min(1, i / 3)
    for k in range(5):
        ang = k * math.tau / 5 + rnd.random()
        x, y = 16.0, 26.0
        pts = [(x, y)]
        for s in range(int(5 * length)):
            ang += rnd.uniform(-0.5, 0.5)
            x += 2.2 * math.cos(ang)
            y += 1.1 * math.sin(ang)
            pts.append((x, y))
        if len(pts) > 1:
            d.line(pts, fill=A((40, 30, 20), 220 * (1 if i < 6 else 0.5)))
    for k in range(4):
        dx = rnd.randint(-8, 8)
        d.point((16 + dx, 24 - i), fill=A((120, 100, 70), 180 * fade(i)))
    return im


def st_shockwave(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    r = 2 + i * 2
    d.ellipse([16 - r, 20 - r * 0.6, 16 + r, 20 + r * 0.6], outline=A(W, 255 * fade(i) + 20), width=2)
    if r > 6:
        d.ellipse([16 - r + 3, 20 - r * 0.6 + 2, 16 + r - 3, 20 + r * 0.6 - 2], outline=A(W, 110 * fade(i)))
    return glow(im, 1.0)


def st_vortex(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    for arm in range(3):
        pts = []
        for s in range(14):
            r = 14 - s + (FRAMES - i) * 0.4
            ang = arm * math.tau / 3 + s * 0.45 + i * 0.5
            pts.append((16 + r * math.cos(ang), 18 + r * 0.6 * math.sin(ang)))
        d.line(pts, fill=A(W, 200), width=1)
    return glow(im, 1.0)


def st_sun_rays(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    for k in range(12):
        ang = k * math.tau / 12 + i * 0.08
        r1, r2 = 3 + i * 0.7, 7 + i * 1.6
        d.line([(16 + r1 * math.cos(ang), 16 + r1 * math.sin(ang)), (16 + r2 * math.cos(ang), 16 + r2 * math.sin(ang))], fill=A((255, 240, 180), 255 * fade(i) + 30))
    d.ellipse([13, 13, 19, 19], fill=A((255, 250, 220), 220 * fade(i) + 20))
    return glow(im, 1.4, 1.5)


def st_moon(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    a = 255 * math.sin(i / (FRAMES - 1) * math.pi)
    d.ellipse([10, 4, 22, 16], fill=A((230, 235, 255), a))
    d.ellipse([13, 3, 25, 15], fill=(0, 0, 0, 0))
    return glow(im, 1.5, 1.6)


def st_holy_glyph(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    a = 255 * math.sin(i / (FRAMES - 1) * math.pi) + 20
    d.line([(16, 6), (16, 26)], fill=A(W, a), width=2)
    d.line([(9, 13), (23, 13)], fill=A(W, a), width=2)
    d.ellipse([11, 8, 21, 18], outline=A(W, a * 0.6))
    return glow(im, 1.4, 1.5)


def st_blood_sigil(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    a = 255 * min(1, i / 3) * (1 if i < 6 else 0.6)
    d.polygon([(16, 8), (22, 22), (9, 13), (23, 13), (10, 22)], outline=A((180, 20, 30), a))
    for k in range(3):
        d.line([(12 + k * 4, 24), (12 + k * 4, 24 + min(5, i))], fill=A((140, 10, 20), a))
    return glow(im, 1.0)


def st_shield_dome(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    a = 200 * math.sin((i + 1) / (FRAMES + 1) * math.pi)
    d.arc([3, 4, 29, 34], 180, 360, fill=A(W, a), width=1)
    for k in range(-2, 3):
        d.line([(16 + k * 5, 8 + abs(k) * 2), (16 + k * 5, 30)], fill=A(W, a * 0.25))
    return glow(im, 1.3, 1.4)


def st_bubble_ring(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    for k in range(6):
        ang = k * math.tau / 6 + i * 0.4
        x, y = 16 + 9 * math.cos(ang), 17 + 9 * math.sin(ang) - i
        r = 1 + (k % 2)
        d.ellipse([x - r, y - r, x + r, y + r], outline=A((210, 240, 255), 230 * fade(i) + 30))
    return glow(im, 0.8)


def st_ember_rise(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    rnd = random.Random(14)
    for k in range(10):
        x = rnd.randint(6, 26) + round(math.sin(i * 0.8 + k))
        y = 30 - ((i * 3 + k * 3) % 26)
        col = (255, rnd.randint(120, 200), 40)
        d.point((x, y), fill=A(col, 255 * (y / 30) + 40))
    return glow(im, 1.0, 1.3)


def st_mind_waves(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    for k in range(3):
        r = ((i + k * 3) % FRAMES) * 1.8 + 2
        d.arc([16 - r, 8 - r * 0.6, 16 + r, 8 + r * 0.6], 180, 360, fill=A(W, 220 * (1 - r / 16)))
    return glow(im, 0.9)


def st_ghost_hands(i):
    im = blank(32)
    d = ImageDraw.Draw(im)
    h = min(12, i * 3)
    a = 220 if i < 6 else 110
    for x0 in (10, 22):
        d.rectangle([x0 - 2, 30 - h, x0 + 1, 30], fill=A((200, 210, 230), a * 0.8))
        for f in range(4):
            d.line([(x0 - 2 + f, 30 - h), (x0 - 2 + f, 30 - h - 3)], fill=A((200, 210, 230), a * 0.8))
    return glow(im, 1.0)


# ---------------------------------------------------------------- 64x64 states
def st_rune_circle(i):
    im = blank(64)
    d = ImageDraw.Draw(im)
    rot = i / FRAMES * (math.tau / 6)
    d.ellipse([6, 38, 58, 58], outline=A(W, 220), width=1)
    d.ellipse([12, 41, 52, 55], outline=A(W, 150), width=1)
    for k in range(6):
        ang = rot + k * math.tau / 6
        x, y = 32 + 23 * math.cos(ang), 48 + 9 * math.sin(ang)
        d.line([(x - 1, y - 2), (x + 1, y + 2)], fill=A(W, 255))
        d.line([(x + 1, y - 2), (x - 1, y)], fill=A(W, 255))
    for k in range(3):
        ang = -rot * 1.5 + k * math.tau / 3
        d.line([(32 + 18 * math.cos(ang), 48 + 7 * math.sin(ang)), (32 + 18 * math.cos(ang + 2.1), 48 + 7 * math.sin(ang + 2.1))], fill=A(W, 110))
    return glow(im, 1.4, 1.5)


def st_pillar(i):
    im = blank(64)
    d = ImageDraw.Draw(im)
    top = max(0, 60 - i * 12)
    a = 255 if i < 5 else 255 * (FRAMES - i) / 3
    for w, alpha in ((8, 0.25), (5, 0.5), (2, 1)):
        d.rectangle([32 - w, top, 32 + w, 60], fill=A(W, a * alpha))
    d.ellipse([20, 56, 44, 63], fill=A(W, a * 0.5))
    return glow(im, 2.0, 1.6)


def st_sunburst(i):
    im = blank(64)
    d = ImageDraw.Draw(im)
    for k in range(16):
        ang = k * math.tau / 16 + i * 0.05
        r1, r2 = 5 + i, 12 + i * 3.5
        d.line([(32 + r1 * math.cos(ang), 32 + r1 * math.sin(ang)), (32 + r2 * math.cos(ang), 32 + r2 * math.sin(ang))], fill=A((255, 244, 200), 255 * fade(i) + 20), width=2 if k % 2 == 0 else 1)
    d.ellipse([26, 26, 38, 38], fill=A((255, 252, 230), 255 * fade(i) + 20))
    return glow(im, 2.0, 1.7)


def st_dark_circle(i):
    im = blank(64)
    d = ImageDraw.Draw(im)
    rot = i / FRAMES * math.tau / 8
    d.ellipse([8, 40, 56, 58], outline=A((70, 20, 90), 255), width=2)
    for k in range(10):
        ang = rot + k * math.tau / 10
        x, y = 32 + 24 * math.cos(ang), 49 + 9 * math.sin(ang)
        d.polygon([(x - 1.5, y), (x + 1.5, y), (x, y - 6)], fill=A((110, 40, 140), 230))
    return glow(im, 1.6, 1.5)


def st_wings(i):
    im = blank(64)
    d = ImageDraw.Draw(im)
    spread = [0.3, 0.6, 0.9, 1, 1, 0.9, 0.7, 0.5][i]
    a = 220 if i < 6 else 120
    for side in (-1, 1):
        for f in range(5):
            ang = math.radians(200 if side < 0 else -20) + side * (-f * 0.22) * spread
            length = (18 - f * 2) * spread
            x0, y0 = 32 + side * 4, 30
            d.line([(x0, y0), (x0 + side * length * abs(math.cos(ang)), y0 - length * 0.5 + f * 3)], fill=A(W, a), width=2)
    return glow(im, 1.5, 1.6)


def st_leystone(i):
    """A standing stone with slowly pulsing blue runes (keeps its own colours)."""
    im = blank(32)
    d = ImageDraw.Draw(im)
    stone = [(10, 31), (9, 12), (11, 5), (16, 2), (21, 5), (23, 13), (22, 31)]
    d.polygon(stone, fill=(96, 98, 104, 255), outline=(52, 54, 60, 255))
    d.polygon([(16, 2), (21, 5), (23, 13), (22, 31), (17, 31), (17, 8)], fill=(78, 80, 88, 255))
    d.line([(12, 14), (14, 20)], fill=(64, 66, 72, 255))
    d.line([(19, 22), (20, 27)], fill=(64, 66, 72, 255))
    pulse = 0.55 + 0.45 * math.sin(i / FRAMES * math.pi * 2)
    runes = blank(32)
    r = ImageDraw.Draw(runes)
    col = A((140, 205, 255), 150 + 105 * pulse)
    r.line([(14, 9), (14, 14), (16, 12), (18, 14), (18, 9)], fill=col)
    r.line([(13, 18), (19, 18)], fill=col)
    r.line([(16, 16), (16, 21)], fill=col)
    r.line([(14, 24), (16, 27), (18, 24)], fill=col)
    runes = glow(runes, 1.3, 1.2 + pulse)
    im.alpha_composite(runes)
    return im


STATES_32 = {
    "sparkle": st_sparkle, "motes": st_motes, "halo": st_halo, "feathers": st_feathers, "hearts": st_hearts,
    "leaves": st_leaves, "drops": st_drops, "flame_wisp": st_flame_wisp, "frost": st_frost, "chains": st_chains,
    "eye": st_eye, "skull_wisp": st_skull_wisp, "zzz": st_zzz, "coins": st_coins, "pages": st_pages,
    "thorns": st_thorns, "tendrils": st_tendrils, "rot_flies": st_rot_flies, "crack": st_crack,
    "shockwave": st_shockwave, "vortex": st_vortex, "sun_rays": st_sun_rays, "moon": st_moon,
    "holy_glyph": st_holy_glyph, "blood_sigil": st_blood_sigil, "shield_dome": st_shield_dome,
    "bubble_ring": st_bubble_ring, "embers": st_ember_rise, "mind_waves": st_mind_waves, "ghost_hands": st_ghost_hands,
    "leystone": st_leystone,
}
STATES_64 = {
    "rune_circle": st_rune_circle, "pillar": st_pillar, "sunburst": st_sunburst, "dark_circle": st_dark_circle,
    "wings": st_wings,
}


def write_dmi(path, size, states):
    names = list(states)
    total = len(names) * FRAMES
    cols = FRAMES
    rows = len(names)
    sheet = blank(1).resize((cols * size, rows * size))
    meta = ["# BEGIN DMI", "version = 4.0", "\twidth = %d" % size, "\theight = %d" % size]
    for r, name in enumerate(names):
        for f in range(FRAMES):
            sheet.alpha_composite(states[name](f), (f * size, r * size))
        meta += ['state = "%s"' % name, "\tdirs = 1", "\tframes = %d" % FRAMES, "\tdelay = " + ",".join(["1"] * FRAMES)]
    meta.append("# END DMI")
    info = PngImagePlugin.PngInfo()
    info.add_text("Description", "\n".join(meta) + "\n", zip=True)
    sheet.save(path, "PNG", pnginfo=info)
    print("wrote", path, len(names), "states,", total, "frames")


if __name__ == "__main__":
    write_dmi("icons/effects/prayer_fx.dmi", 32, STATES_32)
    write_dmi("icons/effects/prayer_fx_64.dmi", 64, STATES_64)

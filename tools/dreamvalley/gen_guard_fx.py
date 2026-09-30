"""Generates the overhead guard badges: icons/effects/guards.dmi (32x32).

Run from the repository root:  python tools/dreamvalley/gen_guard_fx.py

Each state is a small outlined badge above the head, in the style of the
game's own overhead combat effects, with the weapon drawn in the guard's pose.
The badge colour tells what kind of guard it is (red offence, blue defence,
gold balance, green speed, teal evasion) and a glint runs along the weapon.
"""
import math
from PIL import Image, ImageDraw, PngImagePlugin

FRAMES = 6
OUT = (20, 16, 14, 255)
STEEL = (214, 220, 228, 255)
STEEL_D = (132, 142, 156, 255)
WOOD = (122, 82, 46, 255)
GOLD = (222, 184, 82, 255)
GLINT = (255, 255, 255, 255)

KIND = {
    "off": ((178, 54, 44), (232, 110, 90)),
    "def": ((52, 96, 170), (110, 158, 226)),
    "bal": ((168, 132, 44), (228, 196, 100)),
    "spd": ((58, 138, 72), (118, 200, 128)),
    "eva": ((40, 138, 142), (100, 204, 206)),
}

CX, CY = 16, 7  # badge centre: top of the tile, over the head


def badge(d, kind, f):
    base, rim = KIND[kind]
    pulse = 0.5 + 0.5 * math.sin(f / FRAMES * math.pi * 2)
    rimc = tuple(int(rim[i] * (0.8 + 0.2 * pulse)) for i in range(3)) + (255,)
    # a rounded diamond-ish plate, 15 wide
    pts = [(CX - 7, CY), (CX - 5, CY - 6), (CX + 5, CY - 6), (CX + 7, CY), (CX + 5, CY + 6), (CX - 5, CY + 6)]
    d.polygon(pts, fill=OUT)
    inner = [(CX - 6, CY), (CX - 4, CY - 5), (CX + 4, CY - 5), (CX + 6, CY), (CX + 4, CY + 5), (CX - 4, CY + 5)]
    d.polygon(inner, fill=base + (255,))
    d.line([(CX - 4, CY - 5), (CX + 4, CY - 5)], fill=rimc)
    d.line([(CX - 6, CY), (CX - 4, CY - 5)], fill=rimc)


def line_pts(x0, y0, x1, y1):
    n = max(int(round(max(abs(x1 - x0), abs(y1 - y0)))), 1)
    return [(round(x0 + (x1 - x0) * i / n), round(y0 + (y1 - y0) * i / n)) for i in range(n + 1)]


def weapon(d, kind, angle, length, f, reach=1.0):
    """Draws a weapon from the badge centre: angle in degrees (0 = up, 90 = right)."""
    a = math.radians(angle)
    L = length * reach
    hx, hy = CX - math.sin(a) * L * 0.35, CY + math.cos(a) * L * 0.35
    tx, ty = CX + math.sin(a) * L * 0.65, CY - math.cos(a) * L * 0.65
    shaft = line_pts(hx, hy, tx, ty)
    # outline first
    for (x, y) in shaft:
        d.rectangle([x - 1, y - 1, x + 1, y + 1], fill=OUT)
    blade_from = 0.35 if kind in ("sword", "knife") else 0.8
    head_at = shaft[-1]
    for i, p in enumerate(shaft):
        frac = i / max(1, len(shaft) - 1)
        col = STEEL if (kind in ("sword", "knife") and frac > blade_from) else (WOOD if kind in ("axe", "mace", "polearm", "staff", "flail") else STEEL_D)
        if kind in ("sword", "knife") and frac <= blade_from:
            col = WOOD
        d.point(p, fill=col)
    # guard / head details
    px, py = math.cos(a), math.sin(a)  # perpendicular
    if kind in ("sword", "knife"):
        gi = int(len(shaft) * blade_from)
        gx, gy = shaft[gi]
        for s in (-2, -1, 1, 2) if kind == "sword" else (-1, 1):
            d.point((round(gx + px * s), round(gy + py * s)), fill=GOLD)
    elif kind == "axe":
        hx2, hy2 = head_at
        for s in range(1, 4):
            for t in (-1, 0, 1):
                d.point((round(hx2 + px * s - math.sin(a) * t), round(hy2 + py * s + math.cos(a) * t)), fill=STEEL)
    elif kind == "mace":
        hx2, hy2 = head_at
        d.rectangle([hx2 - 2, hy2 - 2, hx2 + 2, hy2 + 2], fill=OUT)
        d.rectangle([hx2 - 1, hy2 - 1, hx2 + 1, hy2 + 1], fill=STEEL_D)
        d.point((hx2, hy2), fill=STEEL)
    elif kind == "polearm":
        hx2, hy2 = head_at
        for t in range(0, 3):
            d.point((round(hx2 + math.sin(a) * t), round(hy2 - math.cos(a) * t)), fill=STEEL)
        d.point((round(hx2 + px), round(hy2 + py)), fill=STEEL)
        d.point((round(hx2 - px), round(hy2 - py)), fill=STEEL)
    elif kind == "flail":
        hx2, hy2 = head_at
        d.ellipse([hx2 - 2, hy2 - 2, hx2 + 2, hy2 + 2], fill=OUT)
        d.ellipse([hx2 - 1, hy2 - 1, hx2 + 1, hy2 + 1], fill=STEEL_D)
    # glint travelling along the weapon
    gi = int((f / (FRAMES - 1)) * (len(shaft) - 1))
    d.point(shaft[gi], fill=GLINT)


def shield(d, f, pose):
    oy = {"wall": 0, "bash": 1, "high": -2}[pose]
    ox = 2 if pose == "bash" else 0
    pts = [(CX - 4 + ox, CY - 4 + oy), (CX + 4 + ox, CY - 4 + oy), (CX + 4 + ox, CY + 1 + oy), (CX + ox, CY + 5 + oy), (CX - 4 + ox, CY + 1 + oy)]
    d.polygon(pts, fill=OUT)
    inner = [(CX - 3 + ox, CY - 3 + oy), (CX + 3 + ox, CY - 3 + oy), (CX + 3 + ox, CY + 1 + oy), (CX + ox, CY + 4 + oy), (CX - 3 + ox, CY + 1 + oy)]
    d.polygon(inner, fill=STEEL_D)
    d.line([(CX + ox, CY - 3 + oy), (CX + ox, CY + 3 + oy)], fill=STEEL)
    if pose == "bash":
        d.line([(CX - 6, CY), (CX - 4, CY)], fill=GLINT if f % 2 else STEEL)
    if f in (2, 3):
        d.point((CX - 2 + ox, CY - 2 + oy), fill=GLINT)


def fist(d, f, pose):
    # a simple fist, raised or low
    oy = {"high": -2, "open": 0, "rush": 1, "low": 2, "tie": -1}[pose]
    d.rectangle([CX - 3, CY - 2 + oy, CX + 3, CY + 3 + oy], fill=OUT)
    d.rectangle([CX - 2, CY - 1 + oy, CX + 2, CY + 2 + oy], fill=(226, 180, 150, 255))
    for x in (CX - 2, CX, CX + 2):
        d.point((x, CY - 1 + oy), fill=(190, 140, 112, 255))
    if pose == "rush":
        d.line([(CX - 6, CY + oy), (CX - 4, CY + oy)], fill=GLINT if f % 2 else STEEL)
        d.line([(CX - 6, CY + 2 + oy), (CX - 4, CY + 2 + oy)], fill=STEEL)


def circle_arrows(d, f):
    for i in range(10):
        ang = (i / 10) * math.pi * 2 + f * 0.5
        x, y = CX + math.cos(ang) * 4, CY + math.sin(ang) * 4
        d.point((round(x), round(y)), fill=STEEL if i % 3 else GLINT)


def lash(d, f):
    pts = []
    for i in range(12):
        x = CX - 6 + i
        y = CY + math.sin(i * 0.9 + f) * 2
        pts.append((x, round(y)))
    for p in pts:
        d.rectangle([p[0], p[1] - 1, p[0], p[1] + 1], fill=OUT)
    for p in pts:
        d.point(p, fill=WOOD)
    d.point(pts[-1], fill=GLINT)


# state = (badge kind, drawer)
def W(kind, angle, length=12, reach=1.0):
    return lambda d, f: weapon(d, kind, angle, length, f, reach)


STATES = {
    # swords
    "sword_middle": ("bal", W("sword", 60)), "sword_high": ("off", W("sword", -20)), "sword_low": ("def", W("sword", 150)),
    "sword_hanging": ("def", W("sword", 210)), "sword_long": ("bal", W("sword", 90, 14)), "sword_back": ("off", W("sword", 225)),
    "sword_side": ("eva", W("sword", 120)), "sword_short": ("spd", W("sword", 10, 9)),
    # axes
    "axe_shoulder": ("off", W("axe", -30)), "axe_middle": ("bal", W("axe", 60)), "axe_low": ("def", W("axe", 150)),
    "axe_back": ("off", W("axe", 230)), "axe_choked": ("spd", W("axe", 20, 9)),
    # maces
    "mace_hammer": ("off", W("mace", -15)), "mace_middle": ("bal", W("mace", 60)), "mace_low": ("def", W("mace", 150)),
    "mace_back": ("off", W("mace", 230)),
    # polearms
    "polearm_middle": ("bal", W("polearm", 80, 14)), "polearm_high": ("off", W("polearm", -10, 14)),
    "polearm_low": ("def", W("polearm", 120, 14)), "polearm_long": ("bal", W("polearm", 90, 15)), "polearm_half": ("spd", W("polearm", 45, 10)),
    # staves
    "staff_middle": ("def", W("staff", 60, 14)), "staff_open": ("off", W("staff", -20, 14)), "staff_low": ("def", W("staff", 130, 14)),
    "staff_close": ("spd", W("staff", 45, 10)),
    # knives
    "knife_forward": ("spd", W("knife", 70, 8)), "knife_reverse": ("off", W("knife", 180, 8)),
    "knife_crouch": ("eva", W("knife", 110, 8)), "knife_forearm": ("def", W("knife", 250, 8)),
    # whips and flails
    "flail_overhead": ("off", W("flail", -20)), "flail_sweep": ("bal", W("flail", 130)),
    "flail_circle": ("def", lambda d, f: circle_arrows(d, f)), "flail_lash": ("bal", lambda d, f: lash(d, f)),
    # shields
    "shield_wall": ("def", lambda d, f: shield(d, f, "wall")), "shield_bash": ("off", lambda d, f: shield(d, f, "bash")),
    "shield_high": ("def", lambda d, f: shield(d, f, "high")),
    # unarmed
    "fist_boxer": ("bal", lambda d, f: fist(d, f, "high")), "fist_open": ("spd", lambda d, f: fist(d, f, "open")),
    "fist_rush": ("off", lambda d, f: fist(d, f, "rush")), "wrestle_low": ("eva", lambda d, f: fist(d, f, "low")),
    "wrestle_tie": ("off", lambda d, f: fist(d, f, "tie")),
}


def render(kind, drawer, f):
    im = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    badge(d, kind, f)
    drawer(d, f)
    return im


def write_dmi(path):
    names = list(STATES)
    sheet = Image.new("RGBA", (FRAMES * 32, len(names) * 32), (0, 0, 0, 0))
    meta = ["# BEGIN DMI", "version = 4.0", "\twidth = 32", "\theight = 32"]
    for r, name in enumerate(names):
        kind, drawer = STATES[name]
        for f in range(FRAMES):
            sheet.alpha_composite(render(kind, drawer, f), (f * 32, r * 32))
        meta += ['state = "%s"' % name, "\tdirs = 1", "\tframes = %d" % FRAMES, "\tdelay = " + ",".join(["2"] * FRAMES)]
    meta.append("# END DMI")
    info = PngImagePlugin.PngInfo()
    info.add_text("Description", "\n".join(meta) + "\n", zip=True)
    sheet.save(path, "PNG", pnginfo=info)
    print("wrote", path, len(names), "states")


if __name__ == "__main__":
    write_dmi("icons/effects/guards.dmi")

#!/usr/bin/env python3
"""Generate original VÁGÁNYMESTER Windows artwork. No external image assets."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "installer" / "assets"
APP_ASSETS = ROOT / "Vaganymester" / "Assets"
ASSETS.mkdir(parents=True, exist_ok=True)
APP_ASSETS.mkdir(parents=True, exist_ok=True)


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = (
        ["C:/Windows/Fonts/segoeuib.ttf", "C:/Windows/Fonts/arialbd.ttf",
         "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"]
        if bold else
        ["C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf",
         "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"]
    )
    for candidate in candidates:
        if Path(candidate).is_file():
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


def gradient(size, upper, lower):
    im = Image.new("RGB", size)
    d = ImageDraw.Draw(im)
    for y in range(size[1]):
        t = y / max(1, size[1] - 1)
        tone = tuple(round(upper[i] * (1 - t) + lower[i] * t) for i in range(3))
        d.line((0, y, size[0], y), fill=tone)
    return im


def locomotive(canvas, center_x, top_y, size):
    """Front-view modern EMU, headlights, windscreen, and cab stripes."""
    d = ImageDraw.Draw(canvas, "RGBA")
    sx = size / 500
    def v(x, y): return (round(center_x + (x - 250) * sx), round(top_y + y * sx))
    def shape(points, fill): d.polygon([v(x, y) for x, y in points], fill=fill)
    # Soft glow and streamlined railway cab.
    d.ellipse((*v(38, 30), *v(465, 500)), fill=(10, 204, 232, 24))
    shape([(108, 448), (120, 142), (159, 84), (335, 82), (383, 145),
           (395, 447), (359, 480), (144, 480)], (14, 54, 92, 255))
    shape([(124, 425), (131, 151), (166, 105), (332, 105), (368, 152),
           (375, 426), (347, 451), (147, 451)], (33, 145, 207, 255))
    shape([(151, 165), (171, 126), (329, 126), (346, 165),
           (339, 287), (159, 287)], (11, 45, 77, 255))
    shape([(167, 172), (184, 144), (232, 144), (195, 277),
           (165, 277)], (146, 231, 255, 115))
    shape([(249, 144), (322, 144), (335, 168), (329, 276),
           (230, 276)], (54, 146, 191, 90))
    shape([(130, 310), (370, 310), (374, 393), (125, 393)],
          (230, 247, 254, 255))
    shape([(128, 350), (373, 350), (370, 374), (129, 374)],
          (255, 190, 53, 255))
    for x in (155, 343):
        d.ellipse((*v(x - 28, 318), *v(x + 28, 345)),
                  fill=(255, 220, 115, 255))
        d.ellipse((*v(x - 14, 323), *v(x + 14, 340)),
                  fill=(255, 251, 209, 255))
    shape([(170, 449), (330, 449), (313, 475), (187, 475)],
          (8, 38, 67, 255))
    for a, b in [((145, 485), (107, 500)), ((355, 485), (393, 500))]:
        d.line((v(*a), v(*b)), fill=(160, 204, 223, 255), width=max(2, round(8*sx)))


def make_icon():
    size = 640
    im = gradient((size, size), (16, 106, 163), (8, 29, 61)).convert("RGBA")
    draw = ImageDraw.Draw(im)
    draw.rounded_rectangle((14, 14, size - 14, size - 14), radius=130,
                           outline=(255, 208, 82, 255), width=22)
    draw.rounded_rectangle((34, 34, size - 34, size - 34), radius=112,
                           outline=(149, 230, 252, 80), width=5)
    locomotive(im, 320, 100, 460)
    draw.ellipse((487, 445, 570, 527), fill=(16, 45, 73, 255),
                 outline=(238, 246, 255, 255), width=7)
    draw.ellipse((504, 462, 553, 511), fill=(60, 243, 139, 255))
    draw.text((320, 62), "VM", font=font(68, True), anchor="mm",
              fill=(255, 228, 130, 255), stroke_width=3,
              stroke_fill=(8, 38, 69, 255))
    return im


def make_wizard(icon):
    w, h = 492, 942   # Exact Inno Setup wizard artwork aspect ratio, 164:314
    im = gradient((w, h), (8, 29, 61), (13, 83, 124)).convert("RGB")
    d = ImageDraw.Draw(im, "RGBA")
    # Deep teal glow across the illustration.
    glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((-85, 280, 580, 920), fill=(18, 205, 204, 55))
    glow = glow.filter(ImageFilter.GaussianBlur(70))
    im = Image.alpha_composite(im.convert("RGBA"), glow)
    d = ImageDraw.Draw(im, "RGBA")
    for x in range(-20, w + 30, 42):
        d.line((x, 480, x - 180, 940), fill=(136, 201, 221, 15), width=2)
    d.line((42, 590, 146, 938), fill=(212, 236, 246, 95), width=13)
    d.line((450, 590, 346, 938), fill=(212, 236, 246, 95), width=13)
    for y in (690, 744, 811, 885, 934):
        t = (y - 590) / 350
        left, right = 42 + 100 * t, 450 - 100 * t
        d.line((int(left - 65), y, int(right + 65), y),
               fill=(213, 177, 103, 100), width=9)
    d.rounded_rectangle((27, 25, 465, 146), radius=25,
                        fill=(4, 20, 45, 178), outline=(255, 211, 96, 160),
                        width=3)
    d.text((246, 56), "VÁGÁNY", anchor="mt", font=font(58, True),
           fill=(246, 252, 255, 255))
    d.text((246, 114), "MESTER", anchor="mt", font=font(61, True),
           fill=(255, 211, 94, 255))
    d.text((246, 188), "VASÚTI FORGALOMIRÁNYÍTÓ JÁTÉK",
           anchor="mm", font=font(17, True), fill=(184, 227, 240, 255))
    locomotive(im, 246, 244, 450)
    d = ImageDraw.Draw(im, "RGBA")
    d.rounded_rectangle((31, 771, 461, 907), radius=24,
                        fill=(5, 28, 52, 212), outline=(92, 225, 217, 120),
                        width=3)
    for i, line in enumerate(("IRÁNYÍTSD A FORGALMAT", "ÁLLÍTSD A VÁLTÓKAT",
                              "VÉDD MEG A VONATOKAT")):
        d.text((246, 795 + i * 37), line, anchor="mt", font=font(23, True),
               fill=((255, 220, 124, 255) if i == 0 else (232, 248, 254, 255)))
    return im.convert("RGB")


def main():
    icon = make_icon()
    sizes = [(16, 16), (24, 24), (32, 32), (48, 48),
             (64, 64), (128, 128), (256, 256)]
    icon.save(ASSETS / "vaganymester.ico", format="ICO", sizes=sizes)
    icon.save(APP_ASSETS / "Vaganymester.ico", format="ICO", sizes=sizes)
    icon.resize((240, 240), Image.Resampling.LANCZOS).convert("RGB").save(
        ASSETS / "wizard-small.png", optimize=True)
    make_wizard(icon).save(ASSETS / "wizard.png", optimize=True)
    print("Windows logo + installer wizard artwork generated.")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Rasterize the Zaya logo into launcher, splash, favicon, and notification icons."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageFilter

ROOT = Path("/Volumes/Projects/freelancerprojects/panagiotis/zaya_events")
SRC_ICON = ROOT / "mobile" / "assets" / "branding" / "source-app-icon.jpg"
SRC_WORDMARK = ROOT / "mobile" / "assets" / "branding" / "source-wordmark.jpg"

NAVY = (0, 53, 128, 255)
GOLD_MIN_R, GOLD_MIN_G, GOLD_MAX_B = 160, 110, 140


def fill_navy(im: Image.Image) -> Image.Image:
    rgba = im.convert("RGBA")
    pixels = list(rgba.getdata())
    out = []
    for r, g, b, a in pixels:
        if a < 16 or (r < 40 and g < 50 and b < 80):
            out.append(NAVY)
        else:
            out.append((r, g, b, 255))
    rgba.putdata(out)
    return rgba


def resize_cover(im: Image.Image, size: int) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), NAVY)
    fitted = im.copy()
    fitted.thumbnail((size, size), Image.Resampling.LANCZOS)
    x = (size - fitted.width) // 2
    y = (size - fitted.height) // 2
    canvas.paste(fitted, (x, y), fitted)
    return canvas.convert("RGB").convert("RGBA")


def inset_on_navy(im: Image.Image, size: int, inset: float = 0.18) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), NAVY)
    inner = int(size * (1 - inset * 2))
    mark = im.copy()
    mark.thumbnail((inner, inner), Image.Resampling.LANCZOS)
    x = (size - mark.width) // 2
    y = (size - mark.height) // 2
    canvas.paste(mark, (x, y), mark)
    return canvas


def silhouette(im: Image.Image, size: int) -> Image.Image:
    src = im.convert("RGBA").resize((size * 3, size * 3), Image.Resampling.LANCZOS)
    pixels = list(src.getdata())
    out = []
    for r, g, b, a in pixels:
        gold = r >= GOLD_MIN_R and g >= GOLD_MIN_G and b <= GOLD_MAX_B
        out.append((255, 255, 255, 255 if gold else 0))
    src.putdata(out)
    src = src.filter(ImageFilter.MaxFilter(3))
    return src.resize((size, size), Image.Resampling.LANCZOS)


def save_png(im: Image.Image, path: Path, rgb: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if rgb:
        bg = Image.new("RGB", im.size, NAVY[:3])
        bg.paste(im.convert("RGB"), mask=im.split()[-1] if im.mode == "RGBA" else None)
        bg.save(path, "PNG", optimize=True)
    else:
        im.save(path, "PNG", optimize=True)


def main() -> None:
    icon = fill_navy(Image.open(SRC_ICON))
    wordmark = fill_navy(Image.open(SRC_WORDMARK))
    branding = ROOT / "mobile" / "assets" / "branding"
    save_png(resize_cover(icon, 1024), branding / "app_icon.png", rgb=True)
    save_png(icon.resize((1024, 1024), Image.Resampling.LANCZOS), branding / "mark.png", rgb=True)
    save_png(wordmark.resize((1600, 900), Image.Resampling.LANCZOS), branding / "logo.png", rgb=True)

    android = ROOT / "mobile" / "android" / "app" / "src" / "main" / "res"
    mipmaps = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, size in mipmaps.items():
        launcher = resize_cover(icon, size)
        save_png(launcher, android / folder / "ic_launcher.png", rgb=True)
        save_png(launcher, android / folder / "ic_launcher_round.png", rgb=True)
        save_png(inset_on_navy(icon, size * 4, 0.16).resize((size * 4, size * 4), Image.Resampling.LANCZOS), android / folder / "ic_launcher_foreground.png")

    save_png(inset_on_navy(icon, 432, 0.16), android / "drawable" / "ic_launcher_foreground.png")
    save_png(resize_cover(icon, 288), android / "drawable" / "launch_image.png", rgb=True)

    notif = {
        "drawable-mdpi": 24,
        "drawable-hdpi": 36,
        "drawable-xhdpi": 48,
        "drawable-xxhdpi": 72,
        "drawable-xxxhdpi": 96,
    }
    for folder, size in notif.items():
        save_png(silhouette(icon, size), android / folder / "ic_stat_zaya.png")

    ios_icons = ROOT / "mobile" / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    ios_sizes = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    for name, size in ios_sizes.items():
        save_png(resize_cover(icon, size), ios_icons / name, rgb=True)

    launch = ROOT / "mobile" / "ios" / "Runner" / "Assets.xcassets" / "LaunchImage.imageset"
    save_png(inset_on_navy(icon, 256, 0.22), launch / "LaunchImage.png", rgb=True)
    save_png(inset_on_navy(icon, 512, 0.22), launch / "LaunchImage@2x.png", rgb=True)
    save_png(inset_on_navy(icon, 768, 0.22), launch / "LaunchImage@3x.png", rgb=True)

    web = ROOT / "mobile" / "web"
    save_png(resize_cover(icon, 32), web / "favicon.png", rgb=True)
    save_png(resize_cover(icon, 192), web / "icons" / "Icon-192.png", rgb=True)
    save_png(resize_cover(icon, 512), web / "icons" / "Icon-512.png", rgb=True)
    save_png(inset_on_navy(icon, 192, 0.12), web / "icons" / "Icon-maskable-192.png", rgb=True)
    save_png(inset_on_navy(icon, 512, 0.12), web / "icons" / "Icon-maskable-512.png", rgb=True)

    for app in ("admin-web", "vendor-web"):
        public = ROOT / "apps" / app / "public"
        save_png(resize_cover(icon, 32), public / "favicon.png", rgb=True)
        save_png(resize_cover(icon, 192), public / "mark.png", rgb=True)
        save_png(wordmark.resize((640, 360), Image.Resampling.LANCZOS), public / "logo.png", rgb=True)
        save_png(resize_cover(icon, 180), public / "apple-touch-icon.png", rgb=True)

    print("Wrote Zaya brand icons")


if __name__ == "__main__":
    main()

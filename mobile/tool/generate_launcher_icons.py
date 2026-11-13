"""Generate app launcher icons from the checked-in original SVG artwork."""
from pathlib import Path
import json
import re

import cairosvg
from PIL import Image
from io import BytesIO

ROOT = Path(__file__).resolve().parents[1]
SVG = ROOT / "assets" / "launcher_icon.svg"
BASE = Image.open(BytesIO(cairosvg.svg2png(
    url=str(SVG), output_width=1024, output_height=1024
))).convert("RGBA")

ANDROID = ROOT / "android" / "app" / "src" / "main" / "res"
SIZES = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}
for density, pixels in SIZES.items():
    folder = ANDROID / f"mipmap-{density}"
    folder.mkdir(parents=True, exist_ok=True)
    BASE.resize((pixels, pixels), Image.Resampling.LANCZOS).save(
        folder / "ic_launcher.png"
    )

# Keep the native Android launcher explicitly landscape and correctly labelled.
manifest = ROOT / "android" / "app" / "src" / "main" / "AndroidManifest.xml"
if manifest.exists():
    xml = manifest.read_text(encoding="utf-8")
    if 'android:screenOrientation=' not in xml:
        xml = xml.replace('android:name=".MainActivity"',
                          'android:name=".MainActivity" '
                          'android:screenOrientation="sensorLandscape"')
    xml = re.sub(r'android:label="[^"]*"', 'android:label="VÁGÁNYMESTER"', xml)
    manifest.write_text(xml, encoding="utf-8")

# macOS / iOS generation is optional and uses the same visual identity.
appicon = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
catalog = appicon / "Contents.json"
if catalog.exists():
    data = json.loads(catalog.read_text(encoding="utf-8"))
    for entry in data.get("images", []):
        filename = entry.get("filename")
        if not filename:
            continue
        logical = float(entry["size"].split("x")[0])
        scale = int(entry.get("scale", "1x").rstrip("x"))
        pixels = round(logical * scale)
        BASE.resize((pixels, pixels), Image.Resampling.LANCZOS).convert(
            "RGB"
        ).save(appicon / filename)
    print("iOS launcher icons refreshed")
print("Android launcher icons refreshed")

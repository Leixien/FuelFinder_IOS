"""App Store frames: caption on top, raw 1320x2868 simulator screenshot below, bleeding off the bottom.
Usage: python3 frame.py RAW_DIR OUT_DIR   (RAW_DIR holds it-1-home.png ... en-5-dark.png; needs Pillow and Chrome)"""
import base64, pathlib, subprocess, sys, tempfile
from PIL import Image

CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
RAW, OUT = map(pathlib.Path, sys.argv[1:3])
W, H = 1320, 2868
LIGHT = dict(bg="#F4F5F0", ink="#16323F", sub="#4A6270", accent="#14A985")
DARK = dict(bg="#102735", ink="#FFF8E9", sub="#A9BAC4", accent="#41E6B4")

SHOTS = [  # (file stem, palette, {lang: (title, subtitle)})
    ("1-home", LIGHT, {"it": ("Il più economico vicino a te, al primo sguardo", "Niente pubblicità. Niente account."),
                       "en": ("The cheapest fuel near you, at a glance", "No ads. No account.")}),
    ("2-list", LIGHT, {"it": ("Tutti i prezzi in ordine", "Per prezzo o per distanza, self o servito"),
                       "en": ("Every price, in order", "By price or distance, self-service or attended")}),
    ("3-detail", LIGHT, {"it": ("Ogni carburante, ogni distributore", "Prezzi ufficiali MIMIT, aggiornati ogni giorno"),
                         "en": ("Every fuel, every station", "Official Italian government prices, updated daily")}),
    ("4-fuels", LIGHT, {"it": ("Benzina, gasolio, GPL, metano e altro", "Scegli il tuo: Refyl se lo ricorda"),
                        "en": ("Petrol, diesel, LPG, CNG and more", "Pick yours: Refyl remembers it")}),
    ("5-dark", DARK, {"it": ("Leggibile anche di notte", "Tema scuro, testo grande e VoiceOver"),
                      "en": ("Easy to read at night", "Dark theme, large text and VoiceOver")}),
]

for lang in ("it", "en"):
    (OUT / lang).mkdir(parents=True, exist_ok=True)
    for stem, p, text in SHOTS:
        raw = RAW / f"{lang}-{stem}.png"
        if not raw.exists():
            continue
        title, sub = text[lang]
        img = base64.b64encode(raw.read_bytes()).decode()
        html = OUT / lang / f"{stem}.html"
        html.write_text(f"""<!doctype html><meta charset="utf-8"><style>
html,body{{margin:0;width:{W}px;height:{H}px;overflow:hidden;background:{p['bg']}}}
body{{font-family:-apple-system,'SF Pro Display',system-ui,sans-serif;text-align:center}}
h1{{margin:96px 80px 0;text-wrap:balance;font-size:96px;line-height:1.08;font-weight:800;letter-spacing:-1.5px;color:{p['ink']}}}
p{{margin:30px 80px 0;text-wrap:balance;font-size:50px;line-height:1.25;font-weight:500;color:{p['sub']}}}
.bar{{width:96px;height:12px;border-radius:6px;background:{p['accent']};margin:0 auto 56px;position:relative;top:70px}}
img{{position:absolute;left:{(W - 1100) // 2}px;top:540px;width:1100px;border-radius:120px;
  box-shadow:0 0 0 14px #0b0f12,0 40px 120px rgba(0,0,0,.28)}}
</style><div class="bar"></div><h1>{title}</h1><p>{sub}</p><img src="data:image/png;base64,{img}">""")
        png = OUT / lang / f"{stem}.png"
        with tempfile.TemporaryDirectory() as profile:
            subprocess.run([CHROME, "--headless=new", "--hide-scrollbars", f"--user-data-dir={profile}",
                            f"--window-size={W},{H}", f"--screenshot={png}", html.resolve().as_uri()],
                           check=True, capture_output=True, timeout=60)
        im = Image.open(png).convert("RGB")
        assert im.size == (W, H), (png, im.size)
        im.save(png)
        html.unlink()
        print(png)

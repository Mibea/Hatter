#!/usr/bin/env python3
"""
hatter_mono.py - zet de SVG-iconen van Hatter om naar grijswaarden.

Gebruik:  ./hatter_mono.py [doelmap]

  doelmap   Map waarin "Hatter-mono" wordt aangemaakt.
            Zonder argument: de map waarin dit script staat (Building-blocks).

Uitgangspunten:
  - Bron is de map "Hatter", een directoryniveau boven dit script.
  - Echte .svg-bestanden worden omgezet; symlinks (naar bestanden en mappen)
    worden als symlink overgenomen, met dezelfde doelverwijzing.
  - index.theme wordt gekopieerd, met "Name=Hatter" vervangen door
    "Name=Hatter-Mono".
  - Kleuren (fill, stroke, stop-color, ... in attributen, style="" en
    <style>-blokken) worden omgezet naar grijs.
  - Ingebedde bitmaps (data:image/...;base64) worden naar grijswaarden omgezet
    en weer ingebed; het resultaat blijft dus een SVG.
  - De mapstructuur van Hatter blijft behouden.

Vereist: Python 3 met Pillow (Debian/Ubuntu: sudo apt install python3-pil)
"""

import argparse
import base64
import colorsys
import io
import os
import re
import sys
from multiprocessing import Pool
from pathlib import Path

try:
    from PIL import Image, ImageColor
except ImportError:
    sys.exit("Python-module Pillow ontbreekt "
             "(sudo apt install python3-pil  of  pip install pillow).")

PROPS = r"(?:fill|stroke|stop-color|flood-color|lighting-color|color)"
ATTR_RE = re.compile(r"(?<![\w:.-])(" + PROPS + r")(\s*=\s*)([\"'])(.*?)\3", re.S)
PROP_RE = re.compile(r"(?<![\w:.-])(" + PROPS + r")(\s*:\s*)([^;}\"'<]+)")
URL_RE = re.compile(r"url\([^)]*\)", re.I)
TOKEN_RE = re.compile(
    r"(rgba?|hsla?)\(([^)]*)\)"
    r"|#([0-9a-fA-F]{3,8})(?![\w-])"
    r"|(?<![\w#-])([A-Za-z]+)(?![\w(-])",
    re.I,
)
DATA_RE = re.compile(
    r"data:image/(png|jpe?g|gif|webp|bmp|tiff?);base64,"
    r"((?:[A-Za-z0-9+/=\s]|&#x?[0-9A-Fa-f]+;)+)",
    re.I,
)
EXT_RE = re.compile(
    r"href\s*=\s*[\"'](?!data:|#)[^\"']+\.(?:png|jpe?g|gif|webp|bmp)[\"']", re.I
)


# --------------------------------------------------------------------------
# Kleuren
# --------------------------------------------------------------------------
def gray(r, g, b):
    # Zelfde gewichten als Pillow's 'L'-modus: vectoren en bitmaps worden gelijk grijs
    return max(0, min(255, int(round(0.299 * r + 0.587 * g + 0.114 * b))))


def conv_func(name, args):
    parts = [p for p in re.split(r"[\s,/]+", args.strip()) if p]
    if len(parts) < 3:
        return None
    alpha = parts[3] if len(parts) > 3 else None
    try:
        if name.lower().startswith("rgb"):
            r, g, b = [float(p[:-1]) * 2.55 if p.endswith("%") else float(p)
                       for p in parts[:3]]
        else:
            h = float(re.sub(r"deg$", "", parts[0]))
            s = float(parts[1].rstrip("%")) / 100
            l = float(parts[2].rstrip("%")) / 100
            r, g, b = [v * 255 for v in colorsys.hls_to_rgb((h % 360) / 360, l, s)]
    except ValueError:
        return None
    v = gray(r, g, b)
    return f"rgba({v},{v},{v},{alpha})" if alpha else f"rgb({v},{v},{v})"


def conv_hex(h):
    if len(h) in (3, 4):
        h = "".join(c * 2 for c in h)
    if len(h) not in (6, 8):
        return None
    r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
    v = gray(r, g, b)
    return f"#{v:02x}{v:02x}{v:02x}{h[6:]}"


def repl(m):
    if m.group(1):
        return conv_func(m.group(1), m.group(2)) or m.group(0)
    if m.group(3):
        return conv_hex(m.group(3)) or m.group(0)
    name = m.group(4).lower()
    if name in ImageColor.colormap:
        try:
            r, g, b = ImageColor.getrgb(name)[:3]
        except ValueError:
            return m.group(0)
        v = gray(r, g, b)
        return f"#{v:02x}{v:02x}{v:02x}"
    return m.group(0)


def conv_value(val):
    out, pos = [], 0
    for u in URL_RE.finditer(val):  # url(#gradient) ongemoeid laten
        out.append(TOKEN_RE.sub(repl, val[pos:u.start()]))
        out.append(u.group(0))
        pos = u.end()
    out.append(TOKEN_RE.sub(repl, val[pos:]))
    return "".join(out)


def recolor(text):
    text = ATTR_RE.sub(
        lambda m: m.group(1) + m.group(2) + m.group(3)
        + conv_value(m.group(4)) + m.group(3),
        text,
    )
    return PROP_RE.sub(
        lambda m: m.group(1) + m.group(2) + conv_value(m.group(3)), text
    )


# --------------------------------------------------------------------------
# Ingebedde bitmaps
# --------------------------------------------------------------------------
def gray_bitmap(m):
    try:
        raw = re.sub(r"\s+|&#x?[0-9A-Fa-f]+;", "", m.group(2))
        img = Image.open(io.BytesIO(base64.b64decode(raw)))
        fmt = (img.format or "").upper()
        img.load()
        if img.mode in ("L", "LA", "I;16"):
            return m.group(0)  # al grijs
        has_alpha = img.mode in ("RGBA", "LA", "PA") or "transparency" in img.info
        img = img.convert("RGBA").convert("LA") if has_alpha else img.convert("L")
        buf = io.BytesIO()
        if fmt == "JPEG" and not has_alpha:
            img.save(buf, "JPEG", quality=95)
            mime = "jpeg"
        else:
            img.save(buf, "PNG", optimize=True)
            mime = "png"
        return f"data:image/{mime};base64,{base64.b64encode(buf.getvalue()).decode()}"
    except Exception:
        return m.group(0)


# --------------------------------------------------------------------------
# Bestanden
# --------------------------------------------------------------------------
def process(text):
    out, pos = [], 0
    for m in DATA_RE.finditer(text):  # base64-data buiten de kleurregexen houden
        out.append(recolor(text[pos:m.start()]))
        out.append(gray_bitmap(m))
        pos = m.end()
    out.append(recolor(text[pos:]))
    return "".join(out)


def work(job):
    src, dst = job
    try:
        text = src.read_bytes().decode("utf-8", errors="surrogateescape")
        warn = bool(EXT_RE.search(text))
        result = process(text)
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_bytes(result.encode("utf-8", errors="surrogateescape"))
        return src, None, warn
    except Exception as e:  # noqa: BLE001
        return src, str(e), False


def collect(src_root, dst_root):
    """Verzamel SVG-bestanden en symlinks (symlinks naar mappen worden niet gevolgd)."""
    jobs, links = [], []
    for d, dirs, files in os.walk(src_root, followlinks=False):
        base = Path(d)
        for n in dirs:
            p = base / n
            if p.is_symlink():
                links.append((p, dst_root / p.relative_to(src_root)))
        for n in files:
            p = base / n
            if p.is_symlink():
                links.append((p, dst_root / p.relative_to(src_root)))
            elif n.lower().endswith(".svg"):
                jobs.append((p, dst_root / p.relative_to(src_root)))
    return sorted(jobs), sorted(links)


def make_link(src, dst, src_root, dst_root):
    """Maak dezelfde symlink in Hatter-mono; absolute doelen binnen Hatter wijzen daarna naar Hatter-mono."""
    target = os.readlink(src)
    if os.path.isabs(target):
        try:
            target = str(dst_root / Path(target).relative_to(src_root))
        except ValueError:
            pass
    dst.parent.mkdir(parents=True, exist_ok=True)
    if os.path.lexists(dst):
        dst.unlink()
    dst.symlink_to(target, target_is_directory=src.is_dir())


def copy_index_theme(src_root, dst_root):
    """Kopieer index.theme en wijzig Name=Hatter in Name=Hatter-Mono. Geeft een waarschuwing of None."""
    src = src_root / "index.theme"
    if not os.path.lexists(src):
        return "index.theme niet gevonden in de bronmap."
    text = src.read_bytes().decode("utf-8", errors="surrogateescape")
    new, n = re.subn(r"^Name=Hatter(?=[ \t]*\r?$)", "Name=Hatter-Mono",
                     text, flags=re.M)
    dst = dst_root / "index.theme"
    if os.path.lexists(dst):
        dst.unlink()
    dst.write_bytes(new.encode("utf-8", errors="surrogateescape"))
    if n == 0:
        return "index.theme gekopieerd, maar de regel 'Name=Hatter' is niet gevonden."
    return None


def main():
    script_dir = Path(__file__).resolve().parent
    src_root = script_dir.parent / "Hatter"

    ap = argparse.ArgumentParser(
        description="Zet de SVG-iconen van Hatter om naar grijswaarden (map Hatter-mono)."
    )
    ap.add_argument("doelmap", nargs="?", default=str(script_dir),
                    help="map waarin Hatter-mono wordt aangemaakt "
                         "(standaard: de map van dit script)")
    args = ap.parse_args()

    if not src_root.is_dir():
        sys.exit(f"Bronmap niet gevonden: {src_root}")

    dest_parent = Path(args.doelmap).expanduser().resolve()
    dst_root = dest_parent / "Hatter-mono"
    if dst_root == src_root or src_root in dst_root.parents:
        sys.exit(f"De doelmap mag niet binnen de bronmap liggen: {dst_root}")

    print(f"Bron:  {src_root}")
    print(f"Doel:  {dst_root}")

    jobs, links = collect(src_root, dst_root)
    if not jobs:
        sys.exit("Geen SVG-bestanden gevonden.")
    dst_root.mkdir(parents=True, exist_ok=True)

    done = errors = 0
    external = []
    with Pool() as pool:
        for src, err, warn in pool.imap_unordered(work, jobs, chunksize=8):
            done += 1
            if err:
                errors += 1
                print(f"\nFOUT: {src}: {err}", file=sys.stderr)
            if warn:
                external.append(src)
            if done % 250 == 0 or done == len(jobs):
                print(f"\r{done}/{len(jobs)} iconen verwerkt",
                      end="", file=sys.stderr, flush=True)
    print(file=sys.stderr)

    svg_ok = done - errors
    links_done = 0
    for src, dst in links:
        try:
            make_link(src, dst, src_root, dst_root)
            links_done += 1
        except OSError as e:
            errors += 1
            print(f"FOUT: symlink {src}: {e}", file=sys.stderr)

    theme_warning = None
    try:
        theme_warning = copy_index_theme(src_root, dst_root)
    except OSError as e:
        errors += 1
        print(f"FOUT: index.theme: {e}", file=sys.stderr)
    if theme_warning:
        print(f"Let op: {theme_warning}", file=sys.stderr)

    print(f"Klaar: {svg_ok} SVG's omgezet, {links_done} symlinks overgenomen, "
          f"{errors} fouten.")
    if external:
        print(f"Let op: {len(external)} bestand(en) verwijzen naar externe bitmaps "
              f"(niet omgezet), bv. {external[0]}", file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())

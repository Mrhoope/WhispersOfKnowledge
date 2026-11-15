"""Memproses SEMUA gambar mentah dari AI sekaligus menjadi aset final game.

Cara pakai (dari root repo):
  1. Simpan gambar mentah di folder  art_raw/  dengan nama FINAL-nya, contoh:
        art_raw/npc_gardener.png
        art_raw/tile_grass.png
        art_raw/item_green_leaf.png
     (nama yang dikenali ada di tabel ASSETS di bawah dan di docs/ASSET_GUIDE.md)
  2. Jalankan:
        python tools/batch_prepare.py
     Opsi umum:
        --transparent "#ffffff"   warna latar yang dijadikan transparan (sprite saja)
        --tolerance 40            kemiripan warna latar (bawaan 40)
        --colors 24               jumlah warna maksimum (0 = tidak dikurangi)
        --method nearest          untuk gambar yang SUDAH pixel art 16x16 (bawaan: box)
        --only npc_gardener       proses satu aset saja
  3. Hasil masuk otomatis ke WhispersOfKnowledge/data/sprites atau /tilesets.
     Gambar pratinjau diperbesar dibuat di  art_preview/  agar mudah diperiksa.

Aturan: sprite dipotong tepinya (trim) dan dibuat transparan; tile tidak.
Bila player_idle_left tidak ada tetapi player_idle_right ada (atau sebaliknya),
arah yang kurang dibuat dengan membalik gambar (flip) secara otomatis.
"""
import argparse
import os
import sys

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow belum terpasang. Jalankan: pip install pillow")

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import prepare_asset as pa

# nama file -> (folder tujuan di data/, lebar, tinggi, apakah sprite)
ASSETS = {
    "tile_grass":         ("tilesets", 16, 16, False),
    "tile_grass_forest":  ("tilesets", 16, 16, False),
    "tile_dirt":          ("tilesets", 16, 16, False),
    "tile_water":         ("tilesets", 16, 16, False),
    "object_tree":        ("tilesets", 16, 24, True),
    "player_idle_down":   ("sprites", 16, 24, True),
    "player_idle_up":     ("sprites", 16, 24, True),
    "player_idle_left":   ("sprites", 16, 24, True),
    "player_idle_right":  ("sprites", 16, 24, True),
    "player":             ("sprites", 16, 24, True),
    "npc_gardener":       ("sprites", 16, 24, True),
    "npc_merchant":       ("sprites", 16, 24, True),
    "npc_ranger":         ("sprites", 16, 24, True),
    "item_green_leaf":      ("sprites", 16, 16, True),
    "item_sunpetal":        ("sprites", 16, 16, True),
    "item_moon_fern":       ("sprites", 16, 16, True),
    "item_water":           ("sprites", 16, 16, True),
    "item_wild_berry":      ("sprites", 16, 16, True),
    "item_forest_mushroom": ("sprites", 16, 16, True),
    "item_wild_aster":      ("sprites", 16, 16, True),
}

MIRROR = {"player_idle_left": "player_idle_right", "player_idle_right": "player_idle_left"}


def save_preview(img, name, preview_dir, scale=8):
    os.makedirs(preview_dir, exist_ok=True)
    bg = Image.new("RGBA", img.size, (255, 0, 255, 255))   # latar magenta agar transparansi terlihat
    bg.alpha_composite(img)
    bg.resize((img.width * scale, img.height * scale), Image.NEAREST).convert("RGB").save(
        os.path.join(preview_dir, name + "_x%d.png" % scale))


def main():
    ap = argparse.ArgumentParser(description="Memproses semua aset mentah sekaligus.")
    ap.add_argument("--raw", default="art_raw")
    ap.add_argument("--out", default=os.path.join("WhispersOfKnowledge", "data"))
    ap.add_argument("--preview", default="art_preview")
    ap.add_argument("--transparent")
    ap.add_argument("--tolerance", type=int, default=40)
    ap.add_argument("--colors", type=int, default=0)
    ap.add_argument("--method", choices=["box", "nearest"], default="box")
    ap.add_argument("--only")
    a = ap.parse_args()

    if not os.path.isdir(a.raw):
        sys.exit("Folder '%s' tidak ada. Buat folder itu dan isi dengan gambar mentah." % a.raw)

    transparent = pa.parse_hex(a.transparent) if a.transparent else None
    files = sorted(f for f in os.listdir(a.raw) if f.lower().endswith(".png"))
    if not files:
        sys.exit("Tidak ada file .png di '%s'." % a.raw)

    done, skipped, failed = [], [], []
    produced = {}

    for f in files:
        name = f[:-4]
        if a.only and name != a.only:
            continue
        if name not in ASSETS:
            skipped.append(name)
            continue
        folder, w, h, sprite = ASSETS[name]
        try:
            img = Image.open(os.path.join(a.raw, f))
            out = pa.process(img, (w, h), trim=sprite, transparent=transparent if sprite else None,
                             tolerance=a.tolerance, method=a.method, colors=a.colors,
                             log=lambda m, n=name: print("  [%s] %s" % (n, m)))
        except Exception as e:
            failed.append((name, str(e)))
            continue
        dest_dir = os.path.join(a.out, folder)
        os.makedirs(dest_dir, exist_ok=True)
        out.save(os.path.join(dest_dir, name + ".png"))
        save_preview(out, name, a.preview)
        produced[name] = out
        done.append(name)

    # arah kiri/kanan otomatis dari pasangannya
    for target, source in MIRROR.items():
        if a.only:
            break
        dest = os.path.join(a.out, "sprites", target + ".png")
        if target not in produced and source in produced and not os.path.exists(os.path.join(a.raw, target + ".png")):
            flipped = produced[source].transpose(Image.FLIP_LEFT_RIGHT)
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            flipped.save(dest)
            save_preview(flipped, target, a.preview)
            done.append(target + " (dibalik dari " + source + ")")

    print()
    print("Berhasil (%d):" % len(done))
    for n in done:
        print("  +", n)
    if skipped:
        print("Dilewati, nama tidak dikenal (%d):" % len(skipped))
        for n in skipped:
            print("  ?", n, "(periksa ejaan, lihat tabel ASSETS)")
    if failed:
        print("Gagal (%d):" % len(failed))
        for n, m in failed:
            print("  !", n, "-", m)
    missing = [n for n in ASSETS if n not in produced and n != "player"
               and not os.path.exists(os.path.join(a.out, ASSETS[n][0], n + ".png"))]
    if missing and not a.only:
        print("Belum ada gambarnya (tetap placeholder di game): %d aset" % len(missing))
    print("Pratinjau diperbesar ada di folder '%s'. Periksa sebelum commit." % a.preview)
    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()

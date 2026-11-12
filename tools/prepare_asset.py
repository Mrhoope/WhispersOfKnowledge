"""Menyiapkan gambar hasil AI menjadi aset game (PNG dengan ukuran tepat).

Cara pakai (dari root repo):
    python tools/prepare_asset.py masuk.png keluar.png --size 16x24
    python tools/prepare_asset.py pohon.png WhispersOfKnowledge/data/tilesets/object_tree.png --size 16x24 --trim
    python tools/prepare_asset.py npc.png npc_gardener.png --size 16x24 --trim --transparent "#ffffff" --tolerance 40

Syarat: Python 3 dan Pillow (pip install pillow).

Opsi:
  --size WxH         ukuran akhir dalam pixel (wajib), contoh 16x16 atau 16x24
  --trim             potong tepi transparan dulu, supaya objek memenuhi gambar
  --transparent HEX  jadikan warna latar ini transparan (contoh "#ffffff")
  --tolerance N      seberapa mirip warna dianggap latar (0 sampai 255, bawaan 30)

Perhatian: skrip ini memperkecil dengan metode NEAREST (tanpa menghaluskan) agar pixel tetap tajam.
Hasilnya SELALU harus dilihat dan diperiksa. Memperkecil gambar AI yang detailnya halus
sering menghasilkan gambar yang tidak terbaca. Bila begitu, buat ulang gambarnya dengan prompt
yang lebih sederhana, bukan memaksa memperkecil.
"""
import argparse
import sys

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow belum terpasang. Jalankan: pip install pillow")


def parse_size(text):
    try:
        w, h = text.lower().split("x")
        return int(w), int(h)
    except ValueError:
        sys.exit("Format --size salah. Contoh yang benar: 16x24")


def parse_hex(text):
    t = text.lstrip("#")
    if len(t) != 6:
        sys.exit('Warna harus 6 digit hex, contoh "#ffffff"')
    return tuple(int(t[i:i + 2], 16) for i in (0, 2, 4))


def make_transparent(img, color, tolerance):
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if abs(r - color[0]) <= tolerance and abs(g - color[1]) <= tolerance and abs(b - color[2]) <= tolerance:
                px[x, y] = (r, g, b, 0)


def main():
    ap = argparse.ArgumentParser(description="Menyiapkan aset game dari gambar AI.")
    ap.add_argument("masuk")
    ap.add_argument("keluar")
    ap.add_argument("--size", required=True)
    ap.add_argument("--trim", action="store_true")
    ap.add_argument("--transparent")
    ap.add_argument("--tolerance", type=int, default=30)
    a = ap.parse_args()

    w, h = parse_size(a.size)
    img = Image.open(a.masuk).convert("RGBA")
    print("Ukuran asli:", img.width, "x", img.height)

    if a.transparent:
        make_transparent(img, parse_hex(a.transparent), a.tolerance)
    if a.trim:
        box = img.getchannel("A").getbbox()
        if box is None:
            sys.exit("Gambar kosong (semua transparan). Periksa --transparent dan --tolerance.")
        img = img.crop(box)
        print("Setelah dipotong:", img.width, "x", img.height)

    if abs(img.width / img.height - w / h) > 0.15:
        print("PERINGATAN: perbandingan lebar:tinggi gambar berbeda dengan target. Hasil akan melar.")
    if img.width % w or img.height % h:
        print("PERINGATAN: ukuran asli bukan kelipatan bulat dari target. Hasil bisa terlihat tidak rata.")

    out = img.resize((w, h), Image.NEAREST)
    out.save(a.keluar)
    print("Disimpan:", a.keluar, "(", w, "x", h, ")")
    print("Langkah berikutnya: buka hasilnya, perbesar, dan pastikan masih terbaca.")


if __name__ == "__main__":
    main()

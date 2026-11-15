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
  --method M         cara memperkecil: "box" (rata-rata area, bawaan, cocok untuk gambar AI)
                     atau "nearest" (tajam, untuk gambar yang sudah pixel art)
  --colors N         kurangi jumlah warna menjadi N (contoh 24) agar tampak seperti pixel art

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


def quantize(img, colors):
    """Mengurangi warna. Transparansi dibuat tegas (penuh atau kosong) agar tidak ada tepi pudar."""
    alpha = img.getchannel("A").point(lambda v: 255 if v > 127 else 0)
    rgb = img.convert("RGB").quantize(colors=colors, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGB")
    out = rgb.convert("RGBA")
    out.putalpha(alpha)
    return out


def process(img, size, trim=False, transparent=None, tolerance=30, method="box", colors=0, log=print):
    """Mengubah gambar mentah menjadi gambar berukuran size (w, h). Mengembalikan gambar RGBA."""
    w, h = size
    img = img.convert("RGBA")
    if transparent:
        make_transparent(img, transparent, tolerance)
    if trim:
        box = img.getchannel("A").getbbox()
        if box is None:
            raise ValueError("gambar kosong (semua transparan), periksa warna latar dan toleransi")
        img = img.crop(box)
    if abs(img.width / img.height - w / h) > 0.15:
        log("PERINGATAN: perbandingan lebar:tinggi gambar berbeda dengan target. Hasil akan melar.")
    resample = Image.NEAREST if method == "nearest" else Image.BOX
    out = img.resize((w, h), resample)
    if colors:
        out = quantize(out, colors)
    return out


def main():
    ap = argparse.ArgumentParser(description="Menyiapkan aset game dari gambar AI.")
    ap.add_argument("masuk")
    ap.add_argument("keluar")
    ap.add_argument("--size", required=True)
    ap.add_argument("--trim", action="store_true")
    ap.add_argument("--transparent")
    ap.add_argument("--tolerance", type=int, default=30)
    ap.add_argument("--method", choices=["box", "nearest"], default="box")
    ap.add_argument("--colors", type=int, default=0)
    a = ap.parse_args()

    w, h = parse_size(a.size)
    img = Image.open(a.masuk)
    print("Ukuran asli:", img.width, "x", img.height)
    try:
        out = process(img, (w, h), a.trim, parse_hex(a.transparent) if a.transparent else None,
                      a.tolerance, a.method, a.colors)
    except ValueError as e:
        sys.exit("Gagal: " + str(e))
    out.save(a.keluar)
    print("Disimpan:", a.keluar, "(", w, "x", h, ")")
    print("Langkah berikutnya: buka hasilnya, perbesar, dan pastikan masih terbaca.")


if __name__ == "__main__":
    main()

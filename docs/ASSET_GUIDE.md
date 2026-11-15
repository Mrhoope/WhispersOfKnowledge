# Panduan Aset Visual

Untuk **Anggota 4** (AI Asset & World Designer) dan siapa pun yang menambah gambar. Acuan: PRD bagian 13.

## Cara kerjanya (penting)

Game **tidak butuh semua gambar sekaligus**. Setiap gambar yang ada di folder `WhispersOfKnowledge/data/` otomatis dipakai. Yang belum ada tetap tampil sebagai placeholder (kotak atau lingkaran berwarna). Jadi gambar bisa ditambah **satu per satu**, tanpa mengubah kode.

Saat game dijalankan, console Processing menampilkan daftar gambar yang terpakai:

```text
[ASET] 3 gambar dipakai:
[ASET]   sprites/npc_gardener.png
...
```

Bila gambar tidak muncul di daftar, berarti nama file atau lokasinya belum tepat. File gambar yang rusak diabaikan (tidak membuat game crash).

## Cara cepat (disarankan)

1. Buka `docs/ASSET_PROMPTS.md`: ada daftar semua aset beserta prompt siap tempel.
2. Generate gambar dengan AI (besar, latar putih polos). Simpan di folder **`art_raw/`** di root repo dengan **nama final**, contoh `art_raw/npc_gardener.png`.
3. Jalankan (butuh Python dan `pip install pillow`):
   ```text
   python tools/batch_prepare.py --transparent "#ffffff" --colors 16
   ```
   Skrip memotong, membuat latar transparan, memperkecil, mengurangi warna, menaruh file di folder `data/` yang benar, dan membuat **pratinjau diperbesar** di `art_preview/`. Arah kiri pemain dibuat otomatis dengan membalik arah kanan.
4. Buka pratinjau, lalu jalankan game dan lihat hasilnya. Ulangi untuk gambar yang kurang bagus.
5. Folder `art_raw/` dan `art_preview/` tidak ikut ke Git (sudah di `.gitignore`). Yang di-commit hanya hasil di `data/`.

Opsi: `--only npc_gardener` memproses satu aset saja, `--method nearest` untuk gambar yang sudah pixel art 16 px, `--tolerance 60` bila tepi putih masih tersisa.

Bagian di bawah menjelaskan nama file dan ukuran bila Anda mau memproses manual dengan `tools/prepare_asset.py`.

## Nama file, lokasi, dan ukuran

Semua format **PNG**. Sprite harus **transparan** di sekitar karakter. Tile tidak transparan.

| Aset | File | Ukuran |
|---|---|---|
| Rumput | `data/tilesets/tile_grass.png` | 16×16 |
| Rumput hutan (opsional, bila tidak ada dipakai rumput biasa) | `data/tilesets/tile_grass_forest.png` | 16×16 |
| Jalan | `data/tilesets/tile_dirt.png` | 16×16 |
| Air | `data/tilesets/tile_water.png` | 16×16 |
| Pohon (digambar di atas rumput, bagian bawah gambar sejajar bawah tile) | `data/tilesets/object_tree.png` | 16×16 sampai 16×32 |
| Player menghadap bawah / atas / kiri / kanan | `data/sprites/player_idle_down.png`, `player_idle_up.png`, `player_idle_left.png`, `player_idle_right.png` | 16×24 atau 16×32 |
| Frame idle kedua (opsional; untuk animasi kedip/napas) | `data/sprites/player_idle_<arah>_2.png` | Sama dengan sprite idle arah itu |
| Dua frame jalan per arah (opsional) | `data/sprites/player_walk_<arah>_1.png`, `player_walk_<arah>_2.png` | 16×24 atau 16×32 |
| Player (cadangan untuk arah yang belum punya gambar) | `data/sprites/player.png` | 16×24 atau 16×32 |
| NPC | `data/sprites/<id NPC>.png` | 16×24 atau 16×32 |
| Benda di dunia | `data/sprites/item_<id item>.png` | 16×16 |

Nama NPC mengikuti `id` di `data/game-data/npcs.json`:

| NPC | File |
|---|---|
| Penjaga Taman | `npc_gardener.png` |
| Pedagang Pasar | `npc_merchant.png` |
| Penjaga Hutan | `npc_ranger.png` |

Nama benda mengikuti `id` item di `items.json`: `item_green_leaf.png`, `item_sunpetal.png`, `item_moon_fern.png`, `item_water.png`, `item_wild_berry.png`, `item_forest_mushroom.png`, `item_wild_aster.png`.

**Titik pegangan sprite:** kaki karakter berada di tengah-bawah gambar. Sprite digambar dengan tengah-bawahnya di posisi karakter, jadi gambar yang lebih tinggi otomatis naik ke atas.

### Animasi pemain

Animasi memakai dua frame PNG terpisah untuk setiap arah (`down`, `up`, `left`, `right`). Sprite idle utama yang sudah ada menjadi frame pertama; frame `player_idle_<arah>_2.png` memberi variasi idle singkat. Saat bergerak, game mengganti dua gambar `player_walk_<arah>_1.png` dan `player_walk_<arah>_2.png`. Frame jalan berganti sekitar tujuh kali per detik; variasi idle berkedip singkat secara berkala. Jika gambar jalan tidak ada, game memakai sprite idle arah tersebut; jika gambar idle juga tidak ada, game tetap memakai fallback atau placeholder.

## Menguji satu sprite dan satu tile (tugas Fase 1 Anggota 4)

Folder `docs/asset-test/` berisi aset contoh sederhana (bukan aset final) untuk memastikan jalurnya berfungsi.

1. Salin isi `docs/asset-test/sprites/` ke `WhispersOfKnowledge/data/sprites/`, dan `docs/asset-test/tilesets/` ke `WhispersOfKnowledge/data/tilesets/`. Buat foldernya bila belum ada.
2. Jalankan game di Processing. Di console harus muncul daftar `[ASET]`, dan di layar tampil rumput, jalan, air, pohon, penjaga taman, dan daun bergambar. Pemain bergambar saat menghadap bawah dan kembali ke kotak biru saat menghadap arah lain (karena hanya satu arah yang punya gambar).
3. Ganti salah satu file contoh dengan gambar buatan sendiri (nama sama), jalankan lagi, dan periksa tampilannya.
4. **Hapus aset contoh dari `data/`** sebelum commit bila Anda tidak ingin ikut ter-commit.

## Alur membuat aset dari AI

1. Tentukan satu gaya dan simpan **template prompt** (di bawah). Pakai template yang sama untuk semua aset agar konsisten.
2. Generate beberapa kandidat, pilih yang paling jelas siluetnya.
3. Siapkan ukuran dengan skrip `tools/prepare_asset.py` (butuh Python dan `pip install pillow`):
   ```text
   python tools/prepare_asset.py hasil_ai.png WhispersOfKnowledge/data/sprites/npc_gardener.png --size 16x24 --trim --transparent "#ffffff"
   ```
4. **Buka hasilnya dan perbesar.** Bila tidak terbaca, jangan dipaksa: buat ulang gambarnya dengan prompt yang lebih sederhana (PRD 13.4).
5. Salin ke folder `data/` sesuai tabel, jalankan game, dan lihat di layar. Karakter berukuran 16 px tampil 3× lebih besar di layar.
6. Catat di `docs/ASSET_CREDITS.md` (alat AI, tanggal, prompt, lisensi).

## Template prompt (sesuaikan)

Gaya dasar (letakkan di awal setiap prompt):

```text
pixel art, top-down view, cozy fantasy, soft natural color palette, limited palette,
clean pixel edges, no anti-aliasing, no gradients, flat shading, simple readable silhouette,
plain solid white background, single object centered
```

Contoh:

- Tile: `seamless 16x16 grass tile, <gaya dasar>`
- NPC: `friendly village gardener, facing down, full body, <gaya dasar>`
- Benda: `small green leaf item icon, <gaya dasar>`

Tips: minta **latar putih polos** agar mudah dijadikan transparan. Hindari bayangan di lantai, tulisan, dan banyak benda dalam satu gambar. Untuk arah kiri dan kanan, buat satu arah lalu cerminkan (flip horizontal) bila desainnya simetris.

## Daftar periksa sebelum commit

- [ ] Format PNG, ukuran sesuai tabel, sprite transparan.
- [ ] Nama file persis sesuai tabel (huruf kecil, garis bawah).
- [ ] Terlihat jelas di layar (zoom 3×) dan tidak buram.
- [ ] Konsisten dengan aset lain (sudut pandang, palet, ketebalan garis).
- [ ] Tidak ada tulisan, watermark, atau artefak AI.
- [ ] Sudah dicatat di `docs/ASSET_CREDITS.md`.

## Belum didukung (rencana)

Ikon item di Inventory (`ui/`), ganti tile otomatis di tepi (autotile), dan dekorasi bertumpuk. Bila dibutuhkan, bicarakan dengan Anggota 1 dan 2 dulu.

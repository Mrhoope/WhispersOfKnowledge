# Daftar Aset dan Prompt Siap Tempel

Untuk membuat semua aset dengan AI secara efisien. Jalankan bersama `tools/batch_prepare.py` (lihat cara cepat di `docs/ASSET_GUIDE.md`). Satu gambar mentah = satu file di folder `art_raw/` dengan **nama final** (kolom "Nama file").

## Aturan agar hasilnya konsisten

1. Pakai **satu alat AI dan satu sesi/percakapan** untuk semua aset, dan selalu tempel **blok gaya** yang sama di awal prompt.
2. Minta gambar **besar** (misalnya 1024 px) dengan **latar putih polos**. Skrip yang memperkecilnya ke 16 px.
3. Sprite orang dan pohon: minta rasio **2:3 (potret)**. Benda dan tile: **persegi (1:1)**.
4. Satu objek per gambar, di tengah, tanpa bayangan lantai, tanpa teks.
5. Buat beberapa kandidat, pilih yang siluetnya paling jelas. Sprite 16 px kecil sekali: bentuk sederhana dan kontras warna lebih penting daripada detail.
6. Catat prompt dan alat di `docs/ASSET_CREDITS.md`, dan cek ketentuan lisensi alatnya.

## Blok gaya (tempel di awal setiap prompt)

```text
pixel art style, top-down 3/4 view, cozy fantasy, soft natural color palette,
limited palette, bold readable shapes, clean flat shading, no gradients,
no anti-aliasing, no text, no watermark, plain solid white background
```

## Urutan pengerjaan yang disarankan

**Tahap 1 (uji jalurnya dulu, 6 gambar):** `tile_grass`, `tile_dirt`, `tile_water`, `object_tree`, `player_idle_down`, `npc_gardener`. Jalankan skrip, buka game, dan lihat hasilnya di layar. Perbaiki gaya sebelum membuat sisanya.

**Tahap 2:** sisa sprite pemain, dua NPC lain, dan benda.

## Tile (persegi, tanpa transparansi)

| Nama file | Ukuran akhir | Prompt (setelah blok gaya) |
|---|---|---|
| `tile_grass` | 16×16 | `seamless tileable grass texture, fresh green, subtle darker tufts, square` |
| `tile_grass_forest` | 16×16 | `seamless tileable grass texture, darker deep forest green, subtle moss, square` (opsional) |
| `tile_dirt` | 16×16 | `seamless tileable dirt path texture, warm brown, small pebbles, square` |
| `tile_water` | 16×16 | `seamless tileable shallow pond water texture, calm blue, tiny lighter ripples, square` |

Tile harus **menyambung** (kiri-kanan dan atas-bawah). Periksa di game: garis kotak yang terlihat berarti tidak seamless.

## Pohon

| Nama file | Ukuran akhir | Prompt |
|---|---|---|
| `object_tree` | 16×24 | `single round leafy tree with brown trunk, full tree visible, portrait 2:3` |

## Pemain (rasio 2:3, seluruh badan)

| Nama file | Ukuran akhir | Prompt |
|---|---|---|
| `player_idle_down` | 16×24 | `young adventurer, blue tunic, brown hair, small satchel, standing, facing the viewer (front view), full body` |
| `player_idle_up` | 16×24 | sama, `seen from behind (back view)` |
| `player_idle_right` | 16×24 | sama, `side view facing right` |
| `player_idle_left` | 16×24 | **tidak perlu dibuat**: otomatis dibalik dari `player_idle_right` |

Pakai deskripsi pakaian yang **persis sama** di keempat arah.

## NPC (rasio 2:3, menghadap depan)

| Nama file | Ukuran akhir | Prompt |
|---|---|---|
| `npc_gardener` | 16×24 | `friendly elderly gardener, straw hat, green apron, holding a small watering can, standing, front view, full body` |
| `npc_merchant` | 16×24 | `cheerful market merchant, red apron, small cap, standing, front view, full body` |
| `npc_ranger` | 16×24 | `forest ranger, green hooded cloak, leather satchel, standing, front view, full body` |

## Benda di dunia (persegi)

| Nama file | Ukuran akhir | Prompt |
|---|---|---|
| `item_green_leaf` | 16×16 | `single fresh green leaf` |
| `item_sunpetal` | 16×16 | `single golden-yellow flower with round petals, sun-like` |
| `item_moon_fern` | 16×16 | `single pale silvery-blue fern frond, moonlit` |
| `item_water` | 16×16 | `small blue water droplet or tiny water pool` |
| `item_wild_berry` | 16×16 | `small cluster of red wild berries on a little bush` |
| `item_forest_mushroom` | 16×16 | `single brown forest mushroom with round cap` |
| `item_wild_aster` | 16×16 | `single purple aster flower with yellow center` |

## Bila hasilnya jelek setelah diperkecil

- Gambar terlalu detail: ulangi dengan `very simple`, `chunky shapes`, `few colors`.
- Warna kacau: jalankan skrip dengan `--colors 16` (kurangi warna).
- Tepi sprite bergerigi putih: naikkan `--tolerance` (misalnya 60), atau latar belum benar-benar putih.
- Sprite terpotong atau melar: gambar mentah bukan rasio 2:3. Buat ulang dengan rasio yang benar.

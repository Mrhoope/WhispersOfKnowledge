# Format Data Game (JSON)

Versi 1.0. Semua konten game (item, resep, journal, quest, dialog, NPC, benda di dunia, dan peta) ada di folder `WhispersOfKnowledge/data/` sebagai file JSON. **Menambah NPC, side quest, atau area baru cukup mengedit file ini, tanpa mengubah kode `.pde`.**

Pemuatnya adalah `DataLoader.pde` (milik Anggota 1). Bila ada file yang salah, game **tidak crash**. Masalahnya tampil di kotak merah di layar dan di console Processing dengan awalan `[DATA]`, lalu game tetap berjalan dengan data yang berhasil dimuat.

## Daftar file

| File | Isi |
|---|---|
| `data/game-data/items.json` | Definisi item |
| `data/game-data/recipes.json` | Resep crafting |
| `data/game-data/journal.json` | Katalog entry Journal |
| `data/game-data/quests.json` | Quest, objective, trigger, reward |
| `data/game-data/dialogues.json` | Kumpulan dialog |
| `data/game-data/npcs.json` | NPC, posisi, dan aturan pemilihan dialog |
| `data/game-data/pickups.json` | Benda yang bisa diambil di dunia |
| `data/maps/greenhaven.json` | Peta, zona, dan posisi awal pemain |

## Aturan penulisan JSON (penting untuk pemula)

- Semua teks memakai tanda kutip ganda `"..."`.
- Antar elemen dipisah koma, **tetapi tidak ada koma setelah elemen terakhir**.
- Setiap `{` harus punya `}` dan setiap `[` harus punya `]`.
- ID memakai huruf kecil dan garis bawah, contoh `green_leaf`. ID harus unik dalam satu file.
- Tips: tempel isi file ke https://jsonlint.com untuk mencari kesalahan sebelum menjalankan game.
- Koordinat selalu dalam **tile** (bukan pixel). Tile (0,0) adalah kiri-atas.

## items.json

```json
{ "items": [
  { "id": "green_leaf", "name": "Green Leaf", "description": "Daun hijau segar.",
    "category": "Plants", "icon": "" }
] }
```

`category`: `Materials`, `Plants`, `Crafted Items`, atau `Quest Items`. `icon` = nama file di `data/sprites/` atau `""` bila belum ada.

## recipes.json

```json
{ "recipes": [
  { "id": "herbal_tea", "name": "Herbal Tea", "unlocked": true,
    "ingredients": [ { "id": "green_leaf", "qty": 2 }, { "id": "water", "qty": 1 } ],
    "output": { "id": "herbal_tea", "qty": 1 } }
] }
```

`unlocked: false` berarti resep terkunci sampai dibuka lewat reward quest.

**Konvensi:** setelah resep berhasil dibuat, game otomatis menemukan entry Journal berID `<idResep>_recipe` (contoh `herbal_tea_recipe`). Bila ingin resep baru memunculkan entry, buat entry dengan ID itu di `journal.json`.

## journal.json

```json
{ "entries": [
  { "id": "plant_green_leaf", "title": "Daun Hijau", "category": "Biology",
    "description": "...", "learningInfo": "..." }
] }
```

`category`: `Biology`, `Alchemy`, `Mathematics`, `Logic`, `Social Interaction`, atau `Science`. Entry baru tersembunyi sampai ditemukan (lewat pickup, aksi dialog, crafting, atau reward quest).

## quests.json

```json
{ "quests": [
  { "id": "side_water", "title": "Air untuk Penjaga",
    "description": "Ambilkan air untuk penjaga gerbang.",
    "status": "AVAILABLE",
    "objectives": [
      { "text": "Berbicara dengan penjaga gerbang" },
      { "text": "Mengambil air dari kolam",
        "trigger": { "type": "have_items", "items": [ { "id": "water", "qty": 1 } ] } },
      { "text": "Kembali kepada penjaga gerbang" }
    ],
    "rewards": { "items": [ { "id": "garden_seed", "qty": 2 } ],
                 "recipes": [], "journal": [] } }
] }
```

`status` awal: `LOCKED`, `AVAILABLE`, `ACTIVE`, atau `COMPLETED`. Objective **tanpa** `trigger` bersifat manual: ditandai oleh aksi dialog (`objective:...` atau `finish_quest:...`). **Objective terakhir** sebaiknya manual ("Kembali kepada ...") karena diselesaikan lewat dialog `ready`.

### Jenis trigger (objective selesai otomatis)

| `type` | Field | Selesai ketika |
|---|---|---|
| `manual` (atau tanpa trigger) | | Ditandai lewat aksi dialog |
| `enter_zone` | `"zone": "<idZona>"` | Pemain masuk zona itu di peta (sudah pernah masuk sebelum quest pun dihitung) |
| `discover` | `"ids": ["<idEntry>", ...]` | Semua entry Journal itu sudah ditemukan |
| `have_items` | `"items": [{"id","qty"}]`, opsional `"orDiscover": "<idEntry>"` | Semua item cukup di inventory, **atau** entry `orDiscover` sudah ditemukan (dipakai agar objective tetap selesai setelah bahan terpakai crafting) |

### Reward

`rewards` diberikan **sekali saja** saat quest selesai. Semuanya opsional: `items` (`id`, `qty`), `recipes` (ID resep yang dibuka), `journal` (ID entry yang ditemukan).

## dialogues.json

```json
{ "sets": [
  { "id": "guard_intro", "lines": [
    { "text": "Bisa ambilkan aku air?",
      "choices": [ { "text": "Ya.", "next": 1 }, { "text": "Tidak.", "next": -1 } ] },
    { "text": "Terima kasih.", "next": -1,
      "action": "start_quest:side_water;objective:side_water:0" }
  ] }
] }
```

- Baris biasa: `text` dan `next` (nomor baris berikutnya, mulai dari 0; `-1` = dialog selesai).
- Baris dengan pilihan: `text` dan `choices` (tiap pilihan punya `text` dan `next`).
- `action` (opsional) dijalankan saat baris ditampilkan. Beberapa perintah dipisah `;`.

### Perintah aksi

| Perintah | Efek |
|---|---|
| `start_quest:<questId>` | Quest AVAILABLE menjadi ACTIVE |
| `objective:<questId>:<nomor>` | Menandai objective selesai (nomor mulai dari 0) |
| `give_item:<itemId>:<jumlah>` | Menambah item ke inventory |
| `discover:<entryId>` | Menemukan entry Journal |
| `finish_quest:<questId>` | Menyelesaikan quest **hanya jika semua objective lain sudah selesai**, lalu memberi reward satu kali |

## npcs.json

```json
{ "npcs": [
  { "id": "npc_guard", "name": "Penjaga Gerbang", "tileX": 8, "tileY": 6,
    "dialogue": "guard_intro",
    "rules": [
      { "quest": "side_water", "state": "completed", "dialogue": "guard_done" },
      { "quest": "side_water", "state": "ready",     "dialogue": "guard_ready" },
      { "quest": "side_water", "state": "active",    "dialogue": "guard_wait" }
    ] }
] }
```

`dialogue` adalah dialog bawaan. `rules` diperiksa **dari atas ke bawah, aturan pertama yang cocok dipakai**. Karena itu urutkan dari kondisi paling spesifik (`completed`, `ready`) ke paling umum (`active`).

| `state` | Cocok ketika |
|---|---|
| `locked` / `available` | Status quest LOCKED / AVAILABLE |
| `active` | Quest ACTIVE |
| `ready` | Quest ACTIVE dan semua objective selain yang terakhir sudah selesai |
| `completed` | Quest COMPLETED |

## pickups.json

```json
{ "pickups": [
  { "id": "pickup_water", "name": "Air Kolam", "item": "water", "qty": 1,
    "tileX": 24, "tileY": 20, "repeatable": true,
    "journal": "water_source", "color": [80, 150, 230] }
] }
```

`repeatable: true` = bisa diambil berulang. `journal` = entry yang ditemukan saat diambil (`""` bila tidak ada). `color` = warna lingkaran placeholder (R, G, B) sampai sprite tersedia. Tile pickup tidak boleh tile yang menghalangi (pohon atau air).

## maps/greenhaven.json

```json
{ "id": "greenhaven", "width": 40, "height": 30,
  "playerStart": { "tileX": 5, "tileY": 5 },
  "zones": [ { "id": "forest", "name": "Whispering Forest", "x1": 20, "y1": 0, "x2": 39, "y2": 14 } ],
  "rows": [ "TTTT...", "..." ] }
```

- `rows` berisi tepat `height` baris, masing-masing tepat `width` karakter.
- Karakter: `.` rumput, `T` pohon (menghalangi), `~` air (menghalangi), `=` jalan.
- Zona: persegi dari tile (`x1`,`y1`) sampai (`x2`,`y2`), inklusif. Zona `forest` membuat rumput lebih gelap dan memunculkan notifikasi saat dimasuki.
- Bila peta tidak valid, game memakai peta cadangan bawaan dan menampilkan pesan error.

## Cara menambah konten

**NPC dan side quest baru (tanpa kode):**
1. `quests.json`: tambah quest dengan objective dan reward.
2. `dialogues.json`: tambah set dialog (intro, menunggu, siap, selesai). Intro memakai `start_quest`, set siap memakai `finish_quest`.
3. `npcs.json`: tambah NPC dengan `rules` yang menunjuk dialog tadi.
4. Jalankan game. Bila ada kotak merah, baca pesannya dan perbaiki file yang disebut.

**Item/resep/benda baru:** tambah di `items.json`, `recipes.json`, `pickups.json`. Pastikan semua ID yang dirujuk sudah ada.

## Yang divalidasi otomatis saat game dimulai

Bahan resep dan hasil resep ada di `items.json`; pickup memakai item dan entry Journal yang ada dan berdiri di tile yang bisa dilewati; trigger memakai zona, entry, dan item yang ada; reward memakai item, resep, dan entry yang ada; NPC memakai dialog dan quest yang ada dengan `state` yang dikenal; nomor `next` dialog berada dalam rentang; perintah aksi dikenal dan merujuk ID yang ada; status quest dan jenis trigger dikenal.

## Yang masih perlu kode (belum lewat JSON)

Jenis trigger baru, perintah aksi baru, karakter tile baru, dan sprite. Bicarakan dengan Anggota 1 sebelum menambahnya.

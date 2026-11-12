# Pembagian Tugas Tim

Acuan: PRD bagian 15 (Organisasi Tim) dan bagian 19 (Roadmap). Pembagian dapat disesuaikan seiring kemampuan anggota berkembang.

> Isi nama anggota pada kolom yang tersedia.

## Ringkasan Peran

| # | Peran | Nama | Branch |
|---|---|---|---|
| 1 | Project Lead & Integration | ________ | `feature/core` |
| 2 | Player & World Programmer | ________ | `feature/player`, `feature/world` |
| 3 | Game Systems & Interaction Programmer | ________ | `feature/ui`, `feature/inventory-crafting`, `feature/npc-journal` |
| 4 | AI Asset & World Designer | ________ | `feature/ai-assets`, `feature/audio` |

Branch `feature/inventory-crafting`, `feature/npc-journal`, dan `feature/ai-assets` belum ada dan dibuat dari `develop` saat dibutuhkan.

## Anggota 1: Project Lead & Integration

**Tanggung jawab:** koordinasi, repository GitHub, arsitektur utama, game loop, quest system, save/load, integrasi, review PR.

| Fase | Tugas |
|---|---|
| 1 | Struktur repo, README, CONTRIBUTING, `TECHNICAL_SPEC.md` (kontrak class), kerangka `Game` |
| 3 | `Game`: state permainan dan `runAction()` yang menghubungkan dialog dengan quest, item, journal |
| 4 | `QuestManager` (status, objective, `claimReward`) |
| 5 | `DataLoader` (memuat dan memvalidasi JSON) dan `Game` yang tidak lagi memuat konten di kode |
| 6 | `SaveManager` (saveGame, loadGame, hasSave, getLastMessage): selesai, satu slot, F5/F9 |
| 6 | Main Menu dasar (selesai). Integrasi seluruh sistem dan bug fixing |
| 7 | Bug fixing, build final |

## Anggota 2: Player & World Programmer

**Tanggung jawab:** player, animasi, collision, camera, world rendering, tile map.

| Fase | Tugas |
|---|---|
| 2 | `Player` (gerak 4 arah, update, render) |
| 2 | `Camera` (follow, apply) |
| 2 | `World` (render tile map, `isBlocked()`), collision, batas area |
| 5 | Pemuatan peta dari `data/maps/greenhaven.json` dan zona (selesai). Memperbaiki rendering bersama Anggota 4 saat tileset siap |

## Anggota 3: Game Systems & Interaction Programmer

**Tanggung jawab:** item, inventory, recipe, crafting, NPC, dialogue, journal, UI.

| Fase | Tugas |
|---|---|
| 3 | `NPC` dan `DialogueSystem` (dialog bertahap dengan pilihan jawaban), dialogue box di `UI` |
| 4 | `Inventory` (add, remove, has, quantity tidak boleh negatif) dan `Pickup` (benda yang bisa diambil) |
| 4 | `CraftingSystem` (cek bahan sebelum mengurangi item, resep terkunci) dan layar Crafting (tombol C) di `UI` |
| 4 | `Journal` (registerEntry, discover, addEntry, hasEntry) |
| 5 | Mengisi konten MVP lewat JSON: 3 NPC, side quest, item, dan entry Journal (`data/game-data/`, panduan di `docs/DATA_FORMAT.md`) |
| 6 | Menyempurnakan tampilan `UI` setelah aset jadi (HUD, Inventory, Journal, Quest Log, Pause, Crafting, Main Menu dasar sudah ada) |

## Anggota 4: AI Asset & World Designer

**Tanggung jawab:** aset AI (karakter, NPC, environment), tileset, layout map, dokumentasi aset, QA visual.

| Fase | Tugas |
|---|---|
| 1 | Tentukan gaya visual dan template prompt, uji satu sprite dan satu tile di Processing |
| 5 | Sprite player dan 3 NPC, tileset desa dan hutan, object (pohon, tanaman, rumah) |
| 5 | Layout map Greenhaven Village dan sebagian Whispering Forest dengan mengedit `rows` di `data/maps/greenhaven.json` (legenda karakter di `docs/DATA_FORMAT.md`) |
| 5 | Ikon item dan elemen UI |
| 6 | Audio (Should Have) |
| Semua | Catat tiap aset di `docs/ASSET_CREDITS.md`, cek ketentuan lisensi tool AI |

## Ketergantungan Antar Anggota

- Anggota 2 dan 3 butuh **kontrak class** dari Anggota 1 sebelum coding paralel.
- Selama aset belum jadi, Anggota 2 dan 3 memakai **placeholder** (kotak berwarna) agar tidak menunggu.
- Anggota 4 mengirim aset sesuai standar ukuran dan penamaan di PRD bagian 13.
- Semua PR ke `develop` di-review oleh Anggota 1.

## Target Minggu Ini (Fase 1)

- [ ] Struktur folder ter-merge ke `develop`
- [ ] README dan CONTRIBUTING ter-merge
- [ ] Semua anggota berhasil clone repo dan menjalankan sketch kosong
- [ ] `TECHNICAL_SPEC.md` (kontrak class) disepakati
- [ ] Kerangka sketch berjalan di Processing 4 pada perangkat semua anggota
- [x] Verifikasi Fase 2: gerak, collision, dan kamera berfungsi
- [ ] Verifikasi alur *The Forgotten Garden* sampai selesai (langkah di `TECHNICAL_SPEC.md` bagian 9)
- [ ] Anggota 4 menguji 1 sprite dan 1 tile AI di Processing

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
| 4 | `QuestManager` (status LOCKED, AVAILABLE, ACTIVE, COMPLETED) |
| 6 | `SaveManager` (saveGame, loadGame) dan integrasi seluruh sistem |
| 7 | Bug fixing, build final |

## Anggota 2: Player & World Programmer

**Tanggung jawab:** player, animasi, collision, camera, world rendering, tile map.

| Fase | Tugas |
|---|---|
| 2 | `Player` (gerak 4 arah, update, render) |
| 2 | Camera mengikuti pemain |
| 2 | `World` (render tile map, `isBlocked()`), collision, batas area |
| 5 | Memuat map Greenhaven Village dan Whispering Forest bersama Anggota 4 |

## Anggota 3: Game Systems & Interaction Programmer

**Tanggung jawab:** item, inventory, recipe, crafting, NPC, dialogue, journal, UI.

| Fase | Tugas |
|---|---|
| 3 | `NPC` (render, `isNear()`, `interact()`) dan dialogue box |
| 4 | `Inventory` (add, remove, has, quantity tidak boleh negatif) |
| 4 | `CraftingSystem` (cek bahan sebelum mengurangi item) |
| 4 | `Journal` (addEntry, hasEntry) |
| 6 | UI: Main Menu, HUD, Inventory Screen, Journal Screen, Quest Log, Pause, Notification |

## Anggota 4: AI Asset & World Designer

**Tanggung jawab:** aset AI (karakter, NPC, environment), tileset, layout map, dokumentasi aset, QA visual.

| Fase | Tugas |
|---|---|
| 1 | Tentukan gaya visual dan template prompt, uji satu sprite dan satu tile di Processing |
| 5 | Sprite player dan 3 NPC, tileset desa dan hutan, object (pohon, tanaman, rumah) |
| 5 | Layout map Greenhaven Village dan sebagian Whispering Forest |
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
- [ ] Anggota 4 menguji 1 sprite dan 1 tile AI di Processing

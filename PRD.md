# WHISPERS OF KNOWLEDGE

## Product Requirements Document (PRD)

**Versi:** 1.5\
**Status:** Revisi --- siap menjadi acuan pengembangan\
**Genre:** Educational Adventure RPG\
**Engine:** Processing 4 (Java Mode)\
**Bahasa pemrograman:** Java\
**Platform target:** Windows PC\
**Jumlah anggota:** 4 orang (semua pemula)\
**Version control:** Git dan GitHub\
**Sumber aset visual:** AI-generated assets\
**Perspektif:** 2D Top-Down\
**Dunia:** Open-world exploration\
**Combat:** Tidak ada

------------------------------------------------------------------------

# Riwayat Revisi

**v1.5**
-   Konten game (item, resep, journal, quest, dialog, NPC, pickup) dan peta dipindahkan dari kode ke file JSON di `data/game-data/` dan `data/maps/` (14.1, 14.3). Format di `docs/DATA_FORMAT.md`.
-   Class `DataLoader` ditambahkan. File data yang salah menampilkan pesan jelas di layar tanpa membuat game crash (14.2).
-   Zona peta (misalnya Whispering Forest) didefinisikan di file peta, bukan di kode.

**v1.4**
-   Tombol `C` ditambahkan untuk membuka Crafting (5.2).
-   Crafting Interface dasar dibuat bersama fitur crafting. Main Menu tetap di Fase 6 (12).
-   Resep dapat terkunci dan dibuka sebagai reward quest (10.2).
-   Class Pickup ditambahkan untuk benda yang dapat diambil di dunia (14.2).

**v1.3**
-   Struktur proyek (14.1) disesuaikan dengan repository nyata: root repo berisi dokumentasi dan satu folder sketch Processing. Folder `src/` tidak dipakai.
-   Nama branch (16.1) disesuaikan dengan branch yang dipakai tim.
-   Tombol `Q` ditambahkan untuk Quest Log (5.2).
-   Objective *The Forgotten Garden* diperbaiki: crafting menjadi objective, "Menyelesaikan quest" bukan lagi objective (8.3).
-   Dialog dengan pilihan jawaban langsung didukung (9, 14.2).
-   Kontrak Save mencakup pesan hasil yang jelas (14.2).
-   Class pendukung ditambahkan ke daftar class (14.2): Camera, DialogueSystem, UI.
-   Format data diputuskan: JSON dengan `JSONObject` bawaan Processing (14.3).
-   Audio ditetapkan menjadi tanggung jawab Anggota 4 (15).
-   Urutan fase tetap, dengan catatan bahwa UI dasar dibuat bersama fiturnya (12, 19).

**v1.2**
-   Versi revisi sebelumnya.

------------------------------------------------------------------------

# 1. Ringkasan Proyek

## 1.1 Deskripsi

Whispers of Knowledge adalah game edukasi bergenre adventure RPG dengan
perspektif 2D top-down dan gaya visual pixel art. Pemain menjelajahi
dunia fantasi yang terdiri dari desa, hutan, taman alkimia,
perpustakaan, dan area lainnya.

Melalui eksplorasi, interaksi dengan NPC, penyelesaian quest, puzzle,
serta aktivitas crafting, pemain mempelajari berbagai bidang
pengetahuan. Pembelajaran disampaikan melalui aktivitas permainan, bukan
hanya kumpulan pertanyaan dan jawaban.

## 1.2 Visi

Menciptakan game edukasi yang terasa seperti petualangan. Pemain belajar
melalui: - Eksplorasi dan penemuan. - Interaksi sosial dan dialog. -
Pemecahan masalah. - Crafting dan alchemy fiktif. - Quest dan cerita. -
Pengamatan lingkungan.

## 1.3 Prinsip pengalaman

Pemain harus selalu memiliki alasan untuk menjelajah, berbicara dengan
NPC, mengumpulkan informasi, dan menggunakan pengetahuan yang ditemukan.

------------------------------------------------------------------------

# 2. Tujuan dan Kriteria Keberhasilan

## 2.1 Tujuan produk

1.  Membuat game 2D top-down yang dapat dimainkan di Windows PC.
2.  Menggabungkan eksplorasi, cerita, quest, dan pembelajaran.
3.  Menyediakan beberapa bidang pengetahuan dalam satu dunia.
4.  Membuat sistem permainan modular agar dapat dikembangkan oleh tim
    pemula.
5.  Menyelesaikan MVP kecil sebelum memperluas dunia.

## 2.2 Kriteria keberhasilan MVP

MVP dianggap berhasil jika: - Pemain dapat bergerak dan menjelajahi
area. - Kamera mengikuti pemain. - Collision mencegah pemain menembus
objek penghalang. - Pemain dapat berbicara dengan NPC. - Minimal satu
quest utama dapat diselesaikan. - Inventory dan crafting dasar
berfungsi. - Journal mencatat pengetahuan yang ditemukan. - Progress
dapat disimpan dan dimuat kembali. - Semua sistem berjalan dalam satu
aplikasi Processing.

------------------------------------------------------------------------

# 3. Target Pemain

Target utama: - Remaja dan dewasa. - Pemain yang menyukai cozy adventure
dan eksplorasi. - Pemain yang tertarik pada puzzle, crafting, dan
cerita. - Pemain yang ingin belajar melalui aktivitas interaktif.

Game dirancang agar mudah dipahami pemain pemula. Materi edukasi
disampaikan dengan bahasa sederhana dan contoh yang relevan dengan dunia
permainan.

------------------------------------------------------------------------

# 4. Platform dan Teknologi

  Komponen                         Pilihan
  -------------------------------- -----------------------
  Framework                        Processing 4
  Mode                             Java Mode
  Bahasa                           Java
  Editor utama                     Visual Studio Code
  IDE alternatif untuk pengujian   Processing IDE 4
  Version control                  Git
  Remote repository                GitHub
  Format gambar                    PNG
  Format data                      JSON (JSONObject bawaan Processing)
  Dokumentasi                      Markdown
  Platform target                  Windows PC

## 4.1 Batasan teknis

-   Implementasi gameplay utama menggunakan Java dan Processing 4.
-   Godot dan Unity tidak digunakan sebagai engine utama.
-   Sistem dibuat dalam class terpisah berdasarkan tanggung jawab.
-   File utama hanya mengatur inisialisasi dan alur game, bukan
    menampung seluruh logika.
-   Aset visual dibuat menggunakan AI image generation dan diproses agar
    sesuai kebutuhan game.
-   Tim menggunakan versi Processing dan struktur proyek yang sama.
    Nomor versi persisnya dicatat di `README.md`.
-   Target performa awal adalah 60 FPS, tetapi harus diuji pada
    perangkat tim.

## 4.2 Catatan penggunaan VS Code

VS Code adalah editor kode, sedangkan Processing menyediakan library dan
runtime untuk menjalankan sketch. Tim harus mengonfigurasi Java dan
Processing Core dengan benar sebelum menjalankan proyek dari VS Code.

Pada tahap awal, tim boleh menggunakan Processing IDE untuk memastikan
sketch berjalan. Setelah itu, proyek dapat dikembangkan di VS Code
dengan konfigurasi Java/Processing yang disepakati bersama.

------------------------------------------------------------------------

# 5. Gameplay Utama

## 5.1 Core gameplay loop

1.  **Explore:** pemain menjelajahi lingkungan.
2.  **Discover:** pemain menemukan objek, tempat, dan informasi.
3.  **Interact:** pemain berbicara dengan NPC atau berinteraksi dengan
    objek.
4.  **Learn:** pemain memperoleh pengetahuan.
5.  **Collect:** pemain mengumpulkan bahan atau item.
6.  **Craft:** pemain membuat item melalui resep.
7.  **Complete Quest:** pemain menyelesaikan misi.
8.  **Progress:** pemain membuka informasi, hadiah, atau area baru.

## 5.2 Kontrol

  Input             Fungsi
  ----------------- -------------------
  W / Arrow Up      Bergerak ke atas
  S / Arrow Down    Bergerak ke bawah
  A / Arrow Left    Bergerak ke kiri
  D / Arrow Right   Bergerak ke kanan
  E                 Interaksi
  J                 Membuka Journal
  I                 Membuka Inventory
  Q                 Membuka Quest Log
  C                 Membuka Crafting
  ESC               Pause

Saat dialog dengan pilihan jawaban terbuka: W/S (atau panah atas/bawah)
memilih jawaban dan E mengonfirmasi. Saat dialog atau layar penuh
terbuka, ESC menutupnya.

Kontrol dapat disesuaikan setelah prototype diuji.

------------------------------------------------------------------------

# 6. Sistem Pembelajaran

Game memiliki enam pilar pembelajaran.

## 6.1 Alchemy dan Crafting

Materi: - Pengelompokan bahan. - Penggunaan resep. - Pengukuran
sederhana. - Hubungan bahan dan hasil. - Urutan proses.

Alchemy merupakan simulasi fiktif untuk kebutuhan permainan, bukan
panduan eksperimen nyata.

## 6.2 Interaksi Sosial

Materi: - Komunikasi. - Empati. - Mendengarkan. - Kerja sama. -
Penyelesaian konflik secara damai.

## 6.3 Alam dan Biologi

Materi: - Tumbuhan dan hewan. - Ekosistem. - Fotosintesis. - Rantai
makanan. - Keanekaragaman hayati.

## 6.4 Logika dan Pemecahan Masalah

Materi: - Pola. - Urutan. - Puzzle. - Pengelompokan. - Penalaran
sederhana.

## 6.5 Ekonomi dan Matematika

Materi: - Penjumlahan dan pengurangan. - Perhitungan harga. - Pertukaran
barang. - Pengelolaan sumber daya.

## 6.6 Sains dan Engineering

Materi: - Prinsip sederhana air. - Energi. - Mekanika dasar. - Sistem
sederhana. - Pemecahan masalah teknis.

------------------------------------------------------------------------

# 7. Desain Dunia

## 7.1 Wilayah

### Greenhaven Village

Pusat aktivitas pemain. Berisi rumah NPC, toko, taman, pusat desa, dan
papan quest.

Materi utama: interaksi sosial, matematika, dan ekonomi.

### Whispering Forest

Area eksplorasi yang berisi tumbuhan, hewan, jalur, dan objek
pengetahuan.

Materi utama: biologi dan ekologi.

### Alchemist's Garden

Area pengumpulan bahan dan crafting.

Materi utama: klasifikasi, pengukuran, dan proses.

### Oldstone Library

Perpustakaan yang berisi buku, arsip, dan puzzle.

Materi utama: literasi, sejarah, dan logika.

### Riverside Town

Area sungai, jembatan, pasar, dan sistem pengairan.

Materi utama: matematika, geografi, dan engineering.

## 7.2 Cakupan dunia MVP

MVP hanya mencakup: - Greenhaven Village. - Sebagian Whispering Forest.

Wilayah lain menjadi pengembangan lanjutan setelah MVP stabil.

------------------------------------------------------------------------

# 8. Quest System

## 8.1 Jenis quest

-   Main Quest.
-   Side Quest.
-   Discovery Quest.
-   Educational Quest.

## 8.2 Status quest

-   `LOCKED`
-   `AVAILABLE`
-   `ACTIVE`
-   `COMPLETED`

Status `FAILED` tidak diperlukan untuk MVP karena game berfokus pada
eksplorasi tanpa tekanan.

## 8.3 Contoh quest utama: The Forgotten Garden

Objective: 1. Berbicara dengan penjaga taman. 2. Menjelajahi hutan. 3.
Menemukan tiga jenis tanaman. 4. Mengumpulkan bahan yang dibutuhkan. 5.
Melakukan crafting. 6. Kembali kepada penjaga taman.

Quest berstatus `COMPLETED` setelah seluruh objective selesai. Reward
diberikan satu kali saja saat quest selesai.

Reward: - Journal entry. - Resep crafting. - Item dalam game.

------------------------------------------------------------------------

# 9. NPC dan Dialogue

Setiap NPC memiliki: - ID unik. - Nama. - Posisi. - Sprite. - Dialog. -
Status interaksi. - Informasi quest jika diperlukan.

Dialogue mendukung: - Percakapan bertahap. - Pilihan jawaban
sederhana. - Informasi edukasi. - Penerimaan quest.

Sistem hubungan NPC lanjutan tidak termasuk MVP. Jika dibutuhkan, status
awal dapat berupa Stranger, Acquaintance, dan Friend.

Dialog disusun sebagai rangkaian baris yang saling menunjuk lewat
indeks. Sebuah baris dapat memiliki pilihan jawaban dan aksi (misalnya
memulai quest atau membuka entry Journal). Format lengkapnya ada di
`TECHNICAL_SPEC.md`.

------------------------------------------------------------------------

# 10. Inventory dan Crafting

## 10.1 Inventory

Kategori item: - Materials. - Plants. - Crafted Items. - Quest Items.

Setiap item memiliki: - ID. - Nama. - Deskripsi. - Ikon. - Kategori. -
Jumlah.

## 10.2 Crafting

Crafting menggunakan resep yang telah ditentukan.

Contoh resep:

**Herbal Tea** - Green Leaf × 2 - Water × 1 - Hasil: Herbal Tea × 1

Sistem harus memeriksa seluruh bahan sebelum mengurangi jumlah item.
Jika bahan tidak cukup, crafting gagal tanpa mengubah inventory.

Resep dapat berstatus terkunci dan dibuka sebagai reward quest. Crafting
dibuka dengan tombol `C`.

------------------------------------------------------------------------

# 11. Knowledge Journal

Journal adalah pusat informasi edukatif pemain.

Kategori: - Biology. - Alchemy. - Mathematics. - Logic. - Social
Interaction. - Science.

Setiap entry memiliki: - ID. - Judul. - Kategori. - Deskripsi. -
Informasi pembelajaran. - Status ditemukan atau belum ditemukan.

Pengetahuan yang sudah ditemukan harus tersimpan dan tetap tersedia
setelah permainan dimuat kembali.

------------------------------------------------------------------------

# 12. User Interface

UI yang diperlukan: 1. Main Menu. 2. HUD. 3. Dialogue Box. 4. Inventory
Screen. 5. Journal Screen. 6. Quest Log. 7. Pause Menu. 8. Notification.
9. Crafting Interface.

UI harus mudah dibaca, konsisten dengan gaya pixel art, dan tidak
menghalangi area permainan secara berlebihan.

Tampilan dasar (HUD, Dialogue Box, layar Inventory, Journal, Quest Log,
dan Pause) dibuat bersama fitur yang membutuhkannya, termasuk Crafting
Interface dasar (tombol `C`). Main Menu dikerjakan di Fase 6. Quest Log
dibuka dengan tombol `Q`.

------------------------------------------------------------------------

# 13. Art Direction dan AI-Generated Assets

## 13.1 Identitas visual

Gaya visual: - 2D top-down pixel art. - Cozy fantasy. - Palet warna
natural. - Suasana lembut dan ramah. - Siluet objek mudah dikenali. -
Tingkat detail dan pixel density konsisten.

## 13.2 Kebijakan sumber aset

Seluruh aset visual direncanakan dibuat menggunakan AI image generation.
Tim tidak diwajibkan menggambar aset secara manual atau mengambil aset
dari katalog aset gratis.

Jenis aset: - Player sprites. - NPC sprites. - Tilesets. - Environment
objects. - Backgrounds. - UI elements. - Icons. - Decorative objects.

## 13.3 Alur produksi aset AI

1.  Tentukan kebutuhan aset.
2.  Buat deskripsi visual dan prompt.
3.  Generate gambar menggunakan AI.
4.  Periksa kualitas dan konsistensi.
5.  Pilih hasil yang sesuai.
6.  Lakukan cropping dan penyesuaian ukuran.
7.  Pastikan transparansi dan format gambar sesuai.
8.  Uji aset di Processing.
9.  Simpan hasil final ke repository.

Hasil AI tidak selalu langsung siap menjadi sprite atau tileset. Tim
harus memeriksa ukuran, transparansi, keseragaman sudut pandang, dan
kemungkinan artefak visual.

## 13.4 Standar aset awal

  Aset            Target ukuran
  --------------- ------------------------------
  Tile            16 × 16 px
  Player sprite   16 × 24 atau 16 × 32 px
  NPC sprite      16 × 24 atau 16 × 32 px
  Object sprite   16 × 16 px atau kelipatannya
  UI icon         16 × 16 px
  Format          PNG
  Transparansi    Diperlukan untuk sprite

Ukuran dapat disesuaikan berdasarkan hasil uji visual. Jangan memaksa
gambar AI berukuran besar menjadi pixel art hanya dengan mengubah
resolusi; hasilnya harus diperiksa agar tetap terbaca.

## 13.5 Penamaan aset

Contoh: - `player_idle_down.png` - `player_walk_down.png` -
`npc_gardener.png` - `npc_merchant.png` - `tile_grass.png` -
`tile_dirt.png` - `tile_water.png` - `object_tree.png` -
`ui_inventory_icon.png`

## 13.6 Konsistensi dan dokumentasi

Semua aset harus memiliki: - Palet warna yang konsisten. - Sudut pandang
top-down yang sama. - Skala visual yang sebanding. - Outline dan tingkat
detail yang seragam. - Transparansi yang benar jika diperlukan.

Catat aset dalam `docs/ASSET_CREDITS.md` dengan informasi: - Nama
aset. - Kategori. - Tool AI yang digunakan. - Tanggal pembuatan. -
Prompt atau deskripsi generasi. - Status penggunaan. - Ketentuan
penggunaan tool yang relevan.

Tim wajib memeriksa ketentuan layanan AI terkait hak penggunaan dan
penggunaan komersial/nonkomersial. Jangan menganggap semua hasil AI
otomatis bebas dari pembatasan.

------------------------------------------------------------------------

# 14. Arsitektur Teknis

## 14.1 Struktur proyek

Root repository berisi dokumentasi dan satu folder sketch Processing:

``` text
WhispersOfKnowledge/                  <- root repository
├── README.md
├── PRD.md
├── AI_INSTRUCTION.md
├── TECHNICAL_SPEC.md
├── CONTRIBUTING.md
├── .gitignore
├── .github/
├── docs/
│   ├── TEAM_TASKS.md
│   ├── DEVELOPMENT_LOG.md
│   ├── ASSET_CREDITS.md
│   └── TESTING.md
└── WhispersOfKnowledge/              <- folder sketch Processing
    ├── WhispersOfKnowledge.pde       <- file utama
    ├── Game.pde   Camera.pde   Player.pde   World.pde
    ├── NPC.pde   DialogueSystem.pde   Pickup.pde   UI.pde
    ├── QuestManager.pde   Inventory.pde   CraftingSystem.pde
    ├── Journal.pde   SaveManager.pde   DataLoader.pde
    ├── data/
    │   ├── sprites/  tilesets/  maps/
    │   └── audio/    ui/        game-data/
    └── saves/                        <- file save, tidak masuk Git
```

**Catatan Processing:** Processing hanya mengenali file `.pde` di folder
sketch (satu class per tab) dan aset di folder `data/`. Folder `src/` pada
rancangan awal tidak dipakai. Nama file utama harus sama dengan nama folder
sketch. Jika tim kelak memakai VS Code dengan Java project, konfigurasi
Processing Core dan source path harus disiapkan secara eksplisit. Folder
`saves/` dibuat saat game menyimpan dan masuk `.gitignore`.

## 14.2 Class utama

### `Game`

-   `update()`
-   `render()`
-   `keyPressed()`
-   `keyReleased()`

### `Player`

-   `update()`
-   `render()`
-   `getX()`
-   `getY()`

### `World`

-   `render()`
-   `isBlocked()`

### `NPC`

-   `render()`
-   `isNear()`
-   `interact()`
-   `getDialogue()`

### `QuestManager`

-   `addQuest()`
-   `unlockQuest()`
-   `startQuest()`
-   `completeObjective()`
-   `completeQuest()`
-   `claimReward()`
-   `getQuest()`

### `Inventory`

-   `addItem()`
-   `removeItem()`
-   `hasItem()`
-   `getQuantity()`

### `CraftingSystem`

-   `craft()`
-   `canCraft()`
-   `unlockRecipe()`
-   `getUnlockedRecipes()`

### `Journal`

-   `registerEntry()`
-   `discover()`
-   `addEntry()`
-   `hasEntry()`
-   `getDiscovered()`

### `SaveManager`

-   `saveGame()`
-   `loadGame()`
-   `getLastMessage()`

### Class pendukung

-   `Camera`: `follow()`, `apply()`, `getX()`, `getY()`.
-   `DialogueSystem`: `start()`, `confirm()`, `moveSelection()`, `pollAction()`, `isOpen()`, `close()`.
-   `UI`: menggambar HUD, dialog, Inventory, Journal, Quest Log, Crafting, Pause, dan notifikasi.
-   `Pickup`: benda di dunia yang diambil dengan tombol E (tanaman, bahan, sumber air).
-   Class data: `Quest`, `ItemData`, `Recipe`, `JournalEntry`, `DialogueLine`.

Kontrak parameter dan tipe data harus ditetapkan dalam dokumen Technical
Specification sebelum coding paralel.

## 14.3 Pengelolaan data

Data quest, item, NPC, dan resep sebaiknya dipisahkan dari logika
program. Format data adalah JSON memakai `JSONObject` dan
`JSONArray` bawaan Processing, sehingga tidak diperlukan library
tambahan. Semua konten ada di `data/game-data/` (items, recipes, journal,
quests, dialogues, npcs, pickups) dan peta di `data/maps/`. `DataLoader`
memuat dan memvalidasinya saat game dimulai. Menambah NPC, side quest, atau
item cukup mengedit file JSON (lihat `docs/DATA_FORMAT.md`).

------------------------------------------------------------------------

# 15. Organisasi Tim

Tim beranggotakan empat orang dan seluruh anggota masih pemula.

## Anggota 1 --- Project Lead & Integration

Tanggung jawab: - Koordinasi proyek. - Repository GitHub. - Arsitektur
utama. - Game loop. - Quest system. - Save/load. - Integrasi kode. -
Review Pull Request.

## Anggota 2 --- Player & World Programmer

Tanggung jawab: - Player movement. - Animasi pemain. - Collision. -
Camera. - World rendering. - Tile map.

## Anggota 3 --- Game Systems & Interaction Programmer

Tanggung jawab: - Item. - Inventory. - Recipe. - Crafting. - NPC. -
Dialogue. - Journal. - UI.

## Anggota 4 --- AI Asset & World Designer

Tanggung jawab: - AI-generated character assets. - AI-generated NPC
assets. - AI-generated environment assets. - Tileset preparation. - Map
layout. - Asset documentation. - Visual quality assurance. - Audio
(Should Have).

Pembagian dapat disesuaikan setelah kemampuan anggota berkembang.

------------------------------------------------------------------------

# 16. GitHub Workflow

## 16.1 Branch strategy

``` text
main
└── develop
    ├── feature/core
    ├── feature/player
    ├── feature/world
    ├── feature/ui
    ├── feature/audio
    ├── feature/inventory-crafting   (dibuat saat dibutuhkan)
    ├── feature/npc-journal          (dibuat saat dibutuhkan)
    └── feature/ai-assets            (dibuat saat dibutuhkan)
```

## 16.2 Aturan pengembangan

1.  Jangan mengerjakan fitur langsung di `main`.
2.  Setiap anggota menggunakan branch pekerjaan.
3.  Lakukan pull sebelum mulai bekerja.
4.  Gunakan commit message yang jelas.
5.  Kirim Pull Request ke `develop`.
6.  Project Lead melakukan review.
7.  Uji hasil integrasi.
8.  Merge ke `main` hanya jika versi stabil.

## 16.3 Format commit

``` text
feat: add player movement
feat: implement inventory
feat: add NPC dialogue
art: add AI-generated village tileset
fix: resolve collision issue
docs: update project requirements
refactor: organize game architecture
test: verify crafting system
```

## 16.4 Pengelolaan aset binary

Gambar PNG dan audio adalah file binary. Git tidak dapat menggabungkan
perubahan visual seperti menggabungkan kode.

Aturan: - Satu aset memiliki satu penanggung jawab. - Hindari mengedit
file yang sama secara bersamaan. - Gunakan nama file konsisten. - Jangan
menyimpan hasil generasi yang tidak digunakan tanpa alasan. -
Pertimbangkan Git LFS jika ukuran repository membesar.

------------------------------------------------------------------------

# 17. MVP Requirements

MVP adalah versi minimum yang harus selesai sebelum memperluas dunia.

## 17.1 Fitur wajib

  Fitur                            Prioritas
  -------------------------------- -------------
  Player movement                  Must Have
  Camera                           Must Have
  Collision                        Must Have
  Greenhaven Village               Must Have
  Sebagian Whispering Forest       Must Have
  Tiga NPC                         Must Have
  Dialogue system                  Must Have
  Satu main quest                  Must Have
  Dua side quests                  Must Have
  Inventory                        Must Have
  Basic crafting                   Must Have
  Knowledge Journal                Must Have
  Save & Load                      Must Have
  Main Menu                        Must Have
  HUD                              Must Have
  AI-generated sprites dan tiles   Must Have
  Audio                            Should Have

## 17.2 Skenario MVP

**The Forgotten Garden**

1.  Pemain memulai di Greenhaven Village.
2.  Pemain bertemu penjaga taman.
3.  Pemain menerima quest.
4.  Pemain menjelajahi Whispering Forest.
5.  Pemain menemukan tiga jenis tanaman.
6.  Journal mencatat pengetahuan.
7.  Pemain mengumpulkan bahan.
8.  Pemain melakukan crafting.
9.  Pemain kembali kepada NPC.
10. Quest selesai dan reward diberikan.

------------------------------------------------------------------------

# 18. Acceptance Criteria

## Player

-   Pemain dapat bergerak empat arah.
-   Animasi sesuai arah gerak.
-   Collision berfungsi.
-   Kamera mengikuti pemain.

## World

-   Map dapat dirender.
-   Objek penghalang memiliki collision.
-   Batas area berfungsi.

## NPC

-   NPC terlihat di dunia.
-   Pemain dapat berinteraksi dalam jarak tertentu.
-   Dialogue dapat dibuka dan ditutup.
-   Pilihan jawaban dapat dipilih dan menentukan kelanjutan dialog.

## Quest

-   Quest dapat diterima.
-   Objective dapat diperbarui.
-   Quest selesai setelah objective terpenuhi.
-   Reward tidak diberikan berulang kali.

## Inventory

-   Item dapat ditambahkan dan dihapus.
-   Quantity benar.
-   Quantity tidak boleh negatif.

## Crafting

-   Bahan diperiksa sebelum crafting.
-   Crafting gagal jika bahan tidak mencukupi.
-   Output diberikan jika berhasil.

## Journal

-   Discovery tercatat.
-   Informasi dapat dibuka.
-   Entry tetap tersimpan setelah load.

## Save/Load

-   Progress tersimpan.
-   Data dapat dimuat kembali.
-   Kegagalan penyimpanan ditangani dengan pesan yang jelas.

## Art

-   Sprite PNG dapat ditampilkan.
-   Transparansi berfungsi.
-   Aset konsisten dengan arah visual.
-   Aset terdokumentasi.

------------------------------------------------------------------------

# 19. Roadmap Pengembangan

Tiap fase harus lulus pengujian sebelum fase berikutnya dianggap selesai.

## Phase 1 --- Foundation

-   Setup repository.
-   Setup Processing.
-   Struktur sketch.
-   Kontrak class.
-   Prototype rendering.

## Phase 2 --- Player & World

-   Player.
-   Movement.
-   Camera.
-   Collision.
-   Tile map.

## Phase 3 --- Interaction

-   NPC.
-   Dialogue.
-   Interaction system.

## Phase 4 --- Game Systems

-   Inventory.
-   Crafting.
-   Journal.
-   Quest.

## Phase 5 --- Content Production

-   AI-generated sprites.
-   Tileset.
-   Village map.
-   Forest map.
-   Dialogue content.

## Phase 6 --- Integration

-   Save/load.
-   UI (penyempurnaan, Main Menu, Crafting Interface).
-   Audio.
-   Integration testing.

## Phase 7 --- MVP Release

-   Bug fixing.
-   Performance testing.
-   Playtesting.
-   Documentation.
-   Final build.

------------------------------------------------------------------------

# 20. Di Luar Cakupan MVP

Fitur berikut tidak termasuk MVP: - Multiplayer. - Combat. - Procedural
world generation. - Jadwal NPC kompleks. - Simulasi hubungan lanjutan. -
Open world berskala besar. - Banyak karakter yang dapat dimainkan. - Mod
support. - Voice acting. - Simulasi cuaca kompleks. - Simulasi ekonomi
kompleks.

------------------------------------------------------------------------

# 21. Strategi Pengujian

Pengujian dilakukan melalui: 1. **Module Testing:** menguji sistem
secara individual. 2. **Integration Testing:** menguji komunikasi
antarsistem. 3. **Regression Testing:** memastikan fitur lama tidak
rusak. 4. **Playtesting:** menguji pengalaman bermain.

Setiap fitur harus diuji sebelum Pull Request digabungkan ke `develop`.

------------------------------------------------------------------------

# 22. Instruksi untuk AI Coding Agent

AI coding agent bertindak sebagai asisten pengembangan.

Aturan: 1. Gunakan Processing 4 Java Mode. 2. Gunakan Java sebagai
bahasa utama. 3. Ikuti PRD, Technical Specification, dan `AI_INSTRUCTION.md`. 4. Jangan
menggunakan Godot atau Unity. 5. Jangan menempatkan seluruh kode dalam
satu file. 6. Ikuti kontrak class yang telah disepakati. 7. Berikan kode
lengkap untuk file yang dibuat atau diubah. 8. Jelaskan lokasi file. 9.
Jelaskan cara menjalankan. 10. Jelaskan cara menguji. 11. Jangan
mengubah file modul anggota lain tanpa kebutuhan. 12. Jangan menambahkan
dependency tanpa penjelasan. 13. Jangan menganggap kode berhasil sebelum
diuji. 14. Gunakan penjelasan yang mudah dipahami pemula. 15.
Implementasikan fitur secara bertahap. 16. Jawab dalam Bahasa
Indonesia.

## Format jawaban AI saat mengimplementasikan fitur

Setiap implementasi harus mencakup: - Tujuan fitur. - Bagian PRD yang
diimplementasikan. - Penjelasan
teknis. - File yang dibuat. - File yang diubah. - Kode lengkap. -
Instruksi integrasi. - Instruksi pengujian. - Batasan yang diketahui.

------------------------------------------------------------------------

# 23. Definition of Done

Fitur dinyatakan selesai jika: - Berjalan di Processing 4. - Memenuhi
acceptance criteria. - Tidak menimbulkan error kritis. - Tidak merusak
fitur lain. - Sudah diuji. - Sudah didokumentasikan. - Pull Request
telah direview. - Sudah di-merge ke `develop`.

------------------------------------------------------------------------

# 24. Prinsip Pengembangan

**Build Small, Integrate Early, Expand Gradually.**

Jangan memprioritaskan ukuran dunia sebelum sistem dasar berhasil.

Buat satu area kecil yang dapat dimainkan. Pastikan player movement,
world, interaction, quest, journal, inventory, dan crafting terhubung.
Setelah MVP stabil, barulah perluas dunia permainan.

**END OF DOCUMENT --- WHISPERS OF KNOWLEDGE PRD v1.5**

# Technical Specification: Whispers of Knowledge

Dokumen ini menetapkan **kontrak class** (nama method, parameter, tipe data) sebelum coding paralel. Acuan: PRD v1.2 bagian 14.

> Aturan: kontrak tidak boleh diubah sepihak. Jika perlu perubahan, diskusikan dulu, update dokumen ini, baru ubah kode.

## 1. Cara Kerja Struktur Processing

- Satu folder sketch `WhispersOfKnowledge/` berisi beberapa tab `.pde`.
- Semua tab digabung Processing menjadi **satu program**. Class di tab lain bisa dipakai langsung, tanpa `import`.
- File utama `WhispersOfKnowledge.pde` hanya berisi `setup()`, `draw()`, dan input yang diteruskan ke `Game`.
- Satu class = satu tab. Nama tab sama dengan nama class.
- Aset dimuat dengan `loadImage("sprites/nama.png")` dari folder `data/`.

## 2. Konvensi

| Hal | Aturan |
|---|---|
| Ukuran tile | 16 px (`TILE_SIZE`, konstanta global) |
| Zoom tampilan | 3x (`ZOOM`, konstanta global) |
| Koordinat dunia | Pixel dunia (bukan layar). Origin kiri-atas, sumbu Y ke bawah |
| Posisi Player dan NPC | Titik di **kaki** karakter (tengah bawah) |
| ID (item, quest, NPC, entry, recipe) | `String`, huruf kecil snake_case, contoh `green_leaf`, `forgotten_garden`, `npc_gardener` |
| Method yang bisa gagal | Mengembalikan `boolean` (`true` = berhasil), tidak melempar error |
| Nama class | PascalCase. Method dan variabel camelCase |

Nilai default: ukuran window 960x540, target 60 FPS, `noSmooth()` aktif agar pixel art tajam.

## 3. Kontrak Class

### 3.1 `Game` (Anggota 1)
Pemilik semua sistem dan state permainan.

| Method | Keterangan |
|---|---|
| `Game()` | Membuat semua sistem, memuat data awal |
| `void update()` | Dipanggil tiap frame dari `draw()` |
| `void render()` | Menggambar dunia, HUD, dan overlay |
| `void keyPressed()` | Menerima input tombol ditekan |
| `void keyReleased()` | Menerima input tombol dilepas |

Field publik: `world`, `player`, `npcs`, `inventory`, `journal`, `quests`, `crafting`, `saveManager`.

### 3.2 `Player` (Anggota 2)

| Method | Keterangan |
|---|---|
| `Player(float x, float y)` | Posisi awal (pixel dunia) |
| `void update(World world, int dirX, int dirY)` | `dirX`/`dirY` bernilai -1, 0, atau 1. Menggerakkan pemain dengan cek collision |
| `void render()` | Menggambar pemain di koordinat dunia |
| `float getX()` | Posisi X (kaki) |
| `float getY()` | Posisi Y (kaki) |
| `void setPosition(float x, float y)` | Dipakai oleh load game |

### 3.3 `World` (Anggota 2)

| Method | Keterangan |
|---|---|
| `World(int tilesWide, int tilesHigh)` | Ukuran map dalam tile |
| `void render(float camX, float camY, float viewW, float viewH)` | Menggambar hanya tile yang terlihat |
| `boolean isBlocked(int tileX, int tileY)` | `true` jika tile menghalangi atau di luar map |
| `boolean isBlockedPx(float px, float py)` | Sama, tetapi dalam pixel dunia |
| `int getPixelWidth()` / `int getPixelHeight()` | Ukuran dunia dalam pixel |

### 3.4 `NPC` (Anggota 3)

| Method | Keterangan |
|---|---|
| `NPC(String id, String name, float x, float y, String[] lines)` | Data NPC dan dialog |
| `void render()` | Menggambar NPC |
| `boolean isNear(Player p)` | `true` jika pemain dalam jarak interaksi |
| `String interact()` | Mengembalikan baris dialog berikutnya. Mengembalikan `null` jika dialog selesai (lalu di-reset) |
| `String getId()` / `String getName()` | Getter |

### 3.5 `QuestManager` dan `Quest` (Anggota 1)

`QuestStatus`: `LOCKED`, `AVAILABLE`, `ACTIVE`, `COMPLETED` (tanpa `FAILED`).

| Method | Keterangan |
|---|---|
| `void addQuest(Quest q)` | Mendaftarkan quest |
| `boolean unlockQuest(String id)` | LOCKED menjadi AVAILABLE |
| `boolean startQuest(String id)` | AVAILABLE menjadi ACTIVE |
| `boolean completeObjective(String id, int index)` | Menandai objective selesai (hanya jika quest ACTIVE) |
| `boolean completeQuest(String id)` | ACTIVE menjadi COMPLETED **hanya jika semua objective selesai**. Reward hanya diberikan sekali |
| `Quest getQuest(String id)` | `null` jika tidak ada |
| `ArrayList<Quest> getAllQuests()` | Semua quest |

`Quest`: `id`, `title`, `description`, `status`, `objectives` (String[]), `done` (boolean[]), `rewardGiven`.

### 3.6 `Inventory` (Anggota 3)

| Method | Keterangan |
|---|---|
| `boolean addItem(String id, int qty)` | `false` jika `qty <= 0` |
| `boolean removeItem(String id, int qty)` | `false` dan **tidak mengubah apa pun** jika jumlah kurang |
| `boolean hasItem(String id, int qty)` | `true` jika jumlah cukup |
| `int getQuantity(String id)` | 0 jika tidak ada. Tidak pernah negatif |
| `void registerItem(ItemData d)` | Mendaftarkan definisi item |
| `ItemData getItemData(String id)` | Definisi item |
| `LinkedHashMap<String,Integer> getAll()` | Isi inventory |

`ItemData`: `id`, `name`, `description`, `category` (Materials, Plants, Crafted Items, Quest Items).

### 3.7 `CraftingSystem` dan `Recipe` (Anggota 3)

| Method | Keterangan |
|---|---|
| `void addRecipe(Recipe r)` | Mendaftarkan resep |
| `Recipe getRecipe(String id)` | `null` jika tidak ada |
| `boolean craft(String recipeId, Inventory inv)` | Cek **semua** bahan dulu, baru kurangi. Gagal jika kurang, inventory tidak berubah |

`Recipe`: `id`, `name`, `ingredientIds` (String[]), `ingredientQty` (int[]), `outputId`, `outputQty`.

### 3.8 `Journal` dan `JournalEntry` (Anggota 3)

| Method | Keterangan |
|---|---|
| `boolean addEntry(JournalEntry e)` | Mencatat penemuan. `false` jika sudah ada |
| `boolean hasEntry(String id)` | `true` jika sudah ditemukan |
| `JournalEntry getEntry(String id)` | `null` jika belum ditemukan |
| `ArrayList<JournalEntry> getAll()` | Semua entry yang ditemukan |

`JournalEntry`: `id`, `title`, `category` (Biology, Alchemy, Mathematics, Logic, Social Interaction, Science), `description`, `learningInfo`.

### 3.9 `SaveManager` (Anggota 1)

| Method | Keterangan |
|---|---|
| `boolean saveGame(Game game)` | `false` jika gagal. Pesan error ditampilkan jelas |
| `boolean loadGame(Game game)` | `false` jika file tidak ada atau rusak, state game tidak berubah |

Data yang disimpan: posisi pemain, isi inventory, entry journal, status dan objective quest. Format: JSON di folder `saves/` (masuk `.gitignore`). Diimplementasi di Fase 6, saat ini masih stub.

## 4. Kontrol

Sesuai PRD 5.2: WASD/Panah (gerak), E (interaksi, lanjut dialog), I (Inventory), J (Journal), ESC (Pause).

## 5. Kepemilikan File

| Tab | Pemilik |
|---|---|
| `WhispersOfKnowledge.pde`, `Game.pde`, `QuestManager.pde`, `SaveManager.pde` | Anggota 1 |
| `Player.pde`, `World.pde` | Anggota 2 |
| `NPC.pde`, `Inventory.pde`, `CraftingSystem.pde`, `Journal.pde` | Anggota 3 |

Mengubah file milik anggota lain hanya setelah dikoordinasikan.

## 6. Kondisi Kerangka Saat Ini (Fase 1)

Kerangka sudah bisa dijalankan dan menampilkan:

- Peta 40x30 tile dengan pohon, air, jalan (digenerate kode, tanpa aset)
- Pemain (kotak biru) bergerak 4 arah dengan collision dan kamera mengikuti
- Satu NPC penjaga taman (kotak oranye) dengan dialog bertahap
- Inventory dan Journal sebagai overlay teks sederhana
- Quest *The Forgotten Garden* berpindah AVAILABLE menjadi ACTIVE setelah bicara dengan penjaga taman

Semua visual masih **placeholder** (kotak berwarna). Diganti sprite AI di Fase 5. `SaveManager` masih stub.

## 7. Cara Menguji Kerangka

1. Buka `WhispersOfKnowledge.pde` di Processing 4, lalu Run.
2. Gerakkan pemain dengan WASD. Pastikan tidak bisa menembus pohon dan air.
3. Dekati NPC (kotak oranye), muncul prompt `[E] Bicara`. Tekan E beberapa kali sampai dialog selesai.
4. Tekan I (inventory berisi Green Leaf x2 dan Water x1), J (journal), ESC (pause).
5. Cek notifikasi quest dimulai di layar setelah dialog selesai.

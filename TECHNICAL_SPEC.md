# Technical Specification: Whispers of Knowledge

Versi 1.1. Dokumen ini menetapkan **kontrak class** (nama method, parameter, tipe data) sebelum coding paralel. Acuan: PRD v1.3 bagian 14.

> Aturan: kontrak tidak boleh diubah sepihak. Jika perlu perubahan, diskusikan dulu, update dokumen ini, baru ubah kode.

## 1. Cara Kerja Struktur Processing

- Satu folder sketch `WhispersOfKnowledge/` berisi beberapa tab `.pde`.
- Semua tab digabung Processing menjadi **satu program**. Class di tab lain bisa dipakai langsung.
- `import` (misalnya `import java.util.*;`) hanya ditulis di file utama `WhispersOfKnowledge.pde`. Import itu berlaku untuk semua tab.
- File utama hanya berisi `setup()`, `draw()`, konstanta global, dan penerusan input ke `Game`.
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

Nilai default: window 960x540, target 60 FPS, `noSmooth()` aktif agar pixel art tajam.

## 3. Kontrak Class

### 3.1 `Game` dan `GameState` (Anggota 1)

`GameState`: `PLAYING`, `DIALOGUE`, `INVENTORY`, `JOURNAL`, `QUEST_LOG`, `PAUSED`.

| Method | Keterangan |
|---|---|
| `Game()` | Membuat semua sistem, memuat data awal |
| `void update()` | Dipanggil tiap frame. Hanya menggerakkan pemain saat state `PLAYING` |
| `void render()` | Menggambar dunia lewat kamera, lalu UI sesuai state |
| `void keyPressed()` / `void keyReleased()` | Menerima input keyboard |
| `void runAction(String command)` | Menjalankan satu perintah aksi dialog (lihat bagian 4) |

Field: `world`, `camera`, `player`, `npcs`, `inventory`, `journal`, `quests`, `crafting`, `dialogue`, `saveManager`, `ui`, `state`.

### 3.2 `Camera` (Anggota 2)

| Method | Keterangan |
|---|---|
| `Camera(float viewW, float viewH)` | Ukuran area terlihat dalam pixel dunia (layar dibagi `ZOOM`) |
| `void follow(float targetX, float targetY, World world)` | Memusatkan kamera pada target, tidak keluar dari batas dunia |
| `void apply()` | `scale(ZOOM)` dan `translate`. Dipanggil di antara `pushMatrix()` dan `popMatrix()` |
| `float getX()` / `getY()` / `getViewW()` / `getViewH()` | Getter |

### 3.3 `Player` (Anggota 2)

| Method | Keterangan |
|---|---|
| `Player(float x, float y)` | Posisi awal (pixel dunia) |
| `void update(World world, int dirX, int dirY)` | `dirX`/`dirY` bernilai -1, 0, atau 1. Menggerakkan pemain dengan cek collision |
| `void render()` | Menggambar pemain di koordinat dunia |
| `float getX()` / `float getY()` | Posisi (kaki) |
| `void setPosition(float x, float y)` | Dipakai oleh load game |

### 3.4 `World` (Anggota 2)

| Method | Keterangan |
|---|---|
| `World(int tilesWide, int tilesHigh)` | Ukuran map dalam tile |
| `void render(float camX, float camY, float viewW, float viewH)` | Menggambar hanya tile yang terlihat |
| `boolean isBlocked(int tileX, int tileY)` | `true` jika tile menghalangi atau di luar map |
| `boolean isBlockedPx(float px, float py)` | Sama, dalam pixel dunia |
| `int getPixelWidth()` / `int getPixelHeight()` | Ukuran dunia dalam pixel |

### 3.5 `NPC` (Anggota 3)

| Method | Keterangan |
|---|---|
| `NPC(String id, String name, float x, float y, DialogueLine[] dialogue)` | Data NPC dan dialognya |
| `void setSprite(PImage img)` | Sprite opsional. Jika `null`, dipakai kotak placeholder |
| `void render()` | Menggambar NPC |
| `boolean isNear(Player p)` | `true` jika pemain dalam jarak interaksi |
| `void interact(DialogueSystem ds)` | Memulai dialog dengan NPC ini |
| `DialogueLine[] getDialogue()` | Data dialog |
| `void markTalked()` / `int getTimesTalked()` | Status interaksi |
| `String getId()` / `getName()` / `float getX()` / `getY()` | Getter |

### 3.6 `DialogueLine` dan `DialogueSystem` (Anggota 3)

`DialogueLine` punya dua constructor:

| Constructor | Keterangan |
|---|---|
| `DialogueLine(String text, int next, String action)` | Baris biasa. `next` = indeks baris berikutnya, `-1` = selesai. `action` boleh `""` |
| `DialogueLine(String text, String[] choices, int[] choiceNext)` | Baris dengan pilihan. `choiceNext[i]` = tujuan pilihan ke-i |

| Method `DialogueSystem` | Keterangan |
|---|---|
| `void start(NPC npc)` | Membuka dialog dari baris 0 |
| `boolean isOpen()` | `true` jika dialog sedang terbuka |
| `DialogueLine getCurrentLine()` | Baris aktif, `null` jika tertutup |
| `String getSpeakerName()` | Nama pembicara |
| `boolean hasChoices()` / `int getSelectedChoice()` | Status pilihan |
| `void moveSelection(int delta)` | -1 naik, 1 turun |
| `void confirm()` | Lanjut atau konfirmasi pilihan (tombol E) |
| `String pollAction()` | Mengambil aksi yang menunggu (sekali saja), `null` jika tidak ada |
| `void close()` | Menutup dialog |

### 3.7 `UI` (Anggota 3)

UI hanya **menggambar**. Data dan logika tetap di class masing-masing.

| Method | Keterangan |
|---|---|
| `void renderHud(QuestManager quests, boolean canInteract)` | Bar atas, quest aktif, prompt `[E] Bicara` |
| `void renderDialogue(DialogueSystem dialogue)` | Kotak dialog dan pilihan jawaban |
| `void renderInventory(Inventory inventory)` | Layar Inventory |
| `void renderJournal(Journal journal)` | Layar Journal (hanya entry yang ditemukan) |
| `void renderQuestLog(QuestManager quests)` | Layar Quest Log |
| `void renderPause()` | Layar Pause |
| `void showNotification(String message)` / `void renderNotification()` | Notifikasi 3 detik |

Belum ada: Main Menu dan Crafting Interface (Fase 6).

### 3.8 `QuestManager` dan `Quest` (Anggota 1)

`QuestStatus`: `LOCKED`, `AVAILABLE`, `ACTIVE`, `COMPLETED` (tanpa `FAILED`).

| Method | Keterangan |
|---|---|
| `void addQuest(Quest q)` | Mendaftarkan quest |
| `boolean unlockQuest(String id)` | LOCKED menjadi AVAILABLE |
| `boolean startQuest(String id)` | AVAILABLE menjadi ACTIVE |
| `boolean completeObjective(String id, int index)` | Menandai objective selesai (hanya jika quest ACTIVE) |
| `boolean completeQuest(String id)` | ACTIVE menjadi COMPLETED **hanya jika semua objective selesai** |
| `boolean claimReward(String id)` | `true` **hanya sekali** per quest yang COMPLETED. Reward diberikan hanya jika `true` |
| `Quest getQuest(String id)` | `null` jika tidak ada |
| `ArrayList<Quest> getAllQuests()` | Semua quest sesuai urutan daftar |

`Quest`: `id`, `title`, `description`, `status`, `objectives` (String[]), `done` (boolean[]), `rewardGiven`.

### 3.9 `Inventory` (Anggota 3)

| Method | Keterangan |
|---|---|
| `boolean addItem(String id, int qty)` | `false` jika `qty <= 0` |
| `boolean removeItem(String id, int qty)` | `false` dan **tidak mengubah apa pun** jika jumlah kurang |
| `boolean hasItem(String id, int qty)` | `true` jika jumlah cukup |
| `int getQuantity(String id)` | 0 jika tidak ada. Tidak pernah negatif |
| `void registerItem(ItemData d)` / `ItemData getItemData(String id)` | Definisi item |
| `LinkedHashMap<String,Integer> getAll()` | Isi inventory |

`ItemData`: `id`, `name`, `description`, `category` (Materials, Plants, Crafted Items, Quest Items), `icon` (nama file ikon, `""` jika belum ada).

### 3.10 `CraftingSystem` dan `Recipe` (Anggota 3)

| Method | Keterangan |
|---|---|
| `void addRecipe(Recipe r)` / `Recipe getRecipe(String id)` | Daftar resep |
| `boolean craft(String recipeId, Inventory inv)` | Cek **semua** bahan dulu, baru kurangi. Gagal jika kurang, inventory tidak berubah |

`Recipe`: `id`, `name`, `ingredientIds` (String[]), `ingredientQty` (int[]), `outputId`, `outputQty`.

### 3.11 `Journal` dan `JournalEntry` (Anggota 3)

Journal berisi katalog entry. Setiap entry punya status `discovered`.

| Method | Keterangan |
|---|---|
| `void registerEntry(JournalEntry e)` | Mendaftarkan entry ke katalog (belum ditemukan) |
| `boolean discover(String id)` | Menandai ditemukan. `false` jika tidak ada atau sudah ditemukan |
| `boolean addEntry(JournalEntry e)` | Mendaftarkan sekaligus menemukan |
| `boolean hasEntry(String id)` | `true` jika **sudah ditemukan** |
| `JournalEntry getEntry(String id)` | Hanya mengembalikan entry yang sudah ditemukan, selain itu `null` |
| `ArrayList<JournalEntry> getDiscovered()` / `getAll()` | Entry yang ditemukan / seluruh katalog |

`JournalEntry`: `id`, `title`, `category` (Biology, Alchemy, Mathematics, Logic, Social Interaction, Science), `description`, `learningInfo`, `discovered`.

### 3.12 `SaveManager` (Anggota 1)

| Method | Keterangan |
|---|---|
| `boolean saveGame(Game game)` | `false` jika gagal |
| `boolean loadGame(Game game)` | `false` jika file tidak ada atau rusak, state game **tidak berubah** |
| `String getLastMessage()` | Pesan hasil terakhir yang jelas, ditampilkan lewat `UI.showNotification()` |

Masih stub (Fase 6). Format penyimpanan ada di bagian 7.

## 4. Format Dialog dan Aksi

Dialog adalah array `DialogueLine`. Contoh (penjaga taman):

```java
DialogueLine[] talk = new DialogueLine[] {
  /* 0 */ new DialogueLine("Halo, pengembara!", 1, ""),
  /* 1 */ new DialogueLine("Maukah kamu membantuku?",
            new String[] {"Ya, aku akan membantu.", "Nanti dulu."},
            new int[] {2, 3}),
  /* 2 */ new DialogueLine("Terima kasih!", -1, "start_quest:forgotten_garden"),
  /* 3 */ new DialogueLine("Baiklah. Kembalilah nanti.", -1, "")
};
```

`action` dijalankan `Game.runAction()` saat baris itu ditampilkan. Beberapa perintah dipisah `;`.

| Perintah | Efek |
|---|---|
| `start_quest:<questId>` | Quest AVAILABLE menjadi ACTIVE, tampilkan notifikasi |
| `objective:<questId>:<indeks>` | Menandai objective selesai (indeks mulai dari 0) |
| `give_item:<itemId>:<jumlah>` | Menambah item ke inventory |
| `discover:<journalEntryId>` | Menandai entry Journal ditemukan |

Perintah baru ditambahkan di `Game.runAction()` dan didaftarkan di tabel ini.

## 5. Kontrol

| Tombol | Fungsi |
|---|---|
| W/A/S/D atau Panah | Bergerak |
| E | Interaksi, lanjut dialog, konfirmasi pilihan |
| W/S atau Panah atas/bawah (saat dialog) | Memilih jawaban |
| I / J / Q | Inventory / Journal / Quest Log (tekan lagi untuk menutup) |
| ESC | Pause. Saat dialog atau layar terbuka: menutupnya |

## 6. Kepemilikan File

| Tab | Pemilik |
|---|---|
| `WhispersOfKnowledge.pde`, `Game.pde`, `QuestManager.pde`, `SaveManager.pde` | Anggota 1 |
| `Player.pde`, `World.pde`, `Camera.pde` | Anggota 2 |
| `NPC.pde`, `DialogueSystem.pde`, `UI.pde`, `Inventory.pde`, `CraftingSystem.pde`, `Journal.pde` | Anggota 3 |

Mengubah file milik anggota lain hanya setelah dikoordinasikan.

## 7. Rencana Format Save

File `saves/save.json` di dalam folder sketch (masuk `.gitignore`), dibuat dengan `JSONObject`:

```json
{
  "version": 1,
  "player": { "x": 104.0, "y": 88.0 },
  "inventory": { "green_leaf": 2, "water": 1 },
  "journal": ["plants_need_light"],
  "quests": {
    "forgotten_garden": { "status": "ACTIVE", "done": [true, false, false, false, false, false], "rewardGiven": false }
  },
  "npcTalked": { "npc_gardener": 3 }
}
```

## 8. Kondisi Kerangka Saat Ini

Kerangka berisi:

- Peta 40x30 tile (pohon, air, jalan) digenerate lewat kode
- Pemain (kotak biru) bergerak 4 arah dengan collision, kamera mengikuti
- Satu NPC penjaga taman (kotak oranye) dengan dialog bercabang
- Inventory, Journal, Quest Log, dan Pause sebagai layar teks sederhana
- Quest *The Forgotten Garden* beserta 6 objective

Semua visual masih **placeholder**. Data contoh masih ditulis di `Game.setupDemoData()`.

**Status pengujian: belum dijalankan di Processing.** Verifikasi Fase 2 oleh tim masih diperlukan.

## 9. Cara Menguji

1. Buka `WhispersOfKnowledge.pde` di Processing 4, lalu Run.
2. **Gerak dan collision:** jalan dengan WASD. Pemain tidak boleh menembus pohon, air, atau batas peta. Kamera mengikuti dan berhenti di tepi peta.
3. **Dialog:** dekati kotak oranye, muncul `[E] Bicara`. Tekan E sampai muncul dua pilihan. Tekan W/S untuk berpindah pilihan.
4. **Pilih "Ya, aku akan membantu":** muncul notifikasi, quest aktif di pojok kanan atas.
5. Tekan **Q**: Quest Log menampilkan objective pertama `[x]`. Tekan **J**: Journal berisi satu entry. Tekan **I**: Inventory berisi Green Leaf x2 dan Water x1.
6. **ESC:** jeda. ESC saat dialog: dialog tertutup.
7. Coba pilih "Nanti dulu": quest tetap belum dimulai.

## 10. Batasan yang Diketahui

- Dialog selalu mulai dari baris 0, jadi setelah quest diterima percakapan yang sama diulang (tanpa efek ganda).
- Notifikasi baru menimpa yang lama bila muncul pada frame yang sama.
- Belum ada tombol atau layar untuk crafting. Logikanya ada di `CraftingSystem`.
- Teks panjang di panel tidak otomatis bergulir (scroll).

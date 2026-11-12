# Technical Specification: Whispers of Knowledge

Versi 1.5. Dokumen ini menetapkan **kontrak class** (nama method, parameter, tipe data) sebelum coding paralel. Acuan: PRD v1.7 bagian 14. Format file data JSON ada di [docs/DATA_FORMAT.md](docs/DATA_FORMAT.md).

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

`GameState`: `MENU` (state awal), `PLAYING`, `DIALOGUE`, `INVENTORY`, `JOURNAL`, `QUEST_LOG`, `CRAFTING`, `PAUSED`.

| Method | Keterangan |
|---|---|
| `Game()` | Memanggil `init()` |
| `void init()` | Membuat semua sistem dari awal, memuat semua konten lewat `DataLoader.loadAll(this)`, membuat Player di posisi awal peta, state `MENU`. Juga dipakai untuk reset penuh, sehingga tidak ada sisa progres lama |
| `void startNewGame()` | `init()` lalu state `PLAYING` |
| `void menuConfirm()` | Menjalankan pilihan Main Menu: 0 Lanjutkan (`loadGame`), 1 Permainan Baru, 2 Keluar (`exit()`) |
| `void backToMenu()` | Dari Pause kembali ke Main Menu lewat `init()` (progres yang belum disimpan hilang) |
| `void update()` | Dipanggil tiap frame. Hanya menggerakkan pemain saat state `PLAYING` |
| `void render()` | Menggambar dunia lewat kamera, lalu UI sesuai state |
| `void keyPressed()` / `void keyReleased()` | Menerima input keyboard |
| `void runAction(String command)` | Menjalankan satu perintah aksi dialog (lihat bagian 4) |
| `void checkQuestProgress()` | Memeriksa trigger objective **semua quest ACTIVE** dan menandai yang terpenuhi. Dipanggil setelah pickup, crafting, masuk zona, dan dialog |
| `void checkZoneEntry()` | Mencatat zona peta yang baru dimasuki ke `visitedZones` dan menampilkan notifikasi |
| `DialogueLine[] pickDialogueFor(NPC n)` | Memilih set dialog NPC: aturan (`DialogueRule`) pertama yang cocok dengan status quest, atau dialog bawaan |
| `boolean isTriggerMet(Trigger t)` | Menilai satu trigger objective (lihat DATA_FORMAT.md) |
| `String getInteractPrompt()` | Teks petunjuk interaksi terdekat, `null` jika tidak ada |

Field: `menuSelected` (0 sampai 2), `world`, `camera`, `player`, `npcs`, `pickups`, `inventory`, `journal`, `quests`, `crafting`, `dialogue`, `saveManager`, `ui`, `state`, `dialogueSets` (`HashMap<String, DialogueLine[]>`), `visitedZones` (`HashSet<String>`), `dataErrors` (`ArrayList<String>`).

`Game` **tidak lagi menulis konten**. Item, resep, quest, dialog, NPC, dan pickup dibaca dari `data/` oleh `DataLoader` (bagian 3.14).

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
| `World(int tilesWide, int tilesHigh)` | Ukuran map dalam tile. Membuat peta placeholder cadangan (termasuk zona `forest`) |
| `boolean loadFromJson(JSONObject o, ArrayList<String> errors)` | Memuat peta dari JSON. Memeriksa `width`, `height`, `rows`, karakter, zona, dan `playerStart`. Peta baru **dipakai hanya bila semuanya valid**; bila tidak, `false` dan peta cadangan tetap dipakai |
| `void render(float camX, float camY, float viewW, float viewH)` | Menggambar hanya tile yang terlihat |
| `boolean isBlocked(int tileX, int tileY)` | `true` jika tile menghalangi atau di luar map |
| `boolean isBlockedPx(float px, float py)` | Sama, dalam pixel dunia |
| `Zone getZone(String id)` / `ArrayList<Zone> getZones()` | Zona dari peta (`Zone`: `id`, `name`, `x1`, `y1`, `x2`, `y2`, `contains(tileX, tileY)`) |
| `boolean isInZone(String id, int tileX, int tileY)` / `isInZonePx(String id, float px, float py)` | `true` jika di dalam zona |
| `boolean isForest(int tileX, int tileY)` / `isForestPx(float px, float py)` | Singkatan untuk zona `forest`. Rumput hutan digambar sedikit lebih gelap |
| `float getStartX()` / `getStartY()` | Posisi awal pemain (pixel, kaki) dari `playerStart` |
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
| `void setDialogue(DialogueLine[] d)` | Mengganti dialog, misalnya sesuai progres quest |
| `void addRule(DialogueRule r)` / `ArrayList<DialogueRule> getRules()` | Aturan pemilihan dialog. `DialogueRule`: `questId`, `state`, `dialogueId` |
| `DialogueLine[] getDefaultDialogue()` | Dialog bawaan bila tidak ada aturan yang cocok |
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
| `void renderHud(QuestManager quests, String prompt)` | Bar atas, quest aktif, tujuan berikutnya, dan prompt interaksi (`null` = tidak ada) |
| `void renderDialogue(DialogueSystem dialogue)` | Kotak dialog dan pilihan jawaban |
| `void renderInventory(Inventory inventory)` | Layar Inventory |
| `void renderJournal(Journal journal)` | Layar Journal (hanya entry yang ditemukan) |
| `void renderQuestLog(QuestManager quests)` | Layar Quest Log |
| `void renderPause(boolean hasSave)` | Layar Pause: petunjuk `[K] Simpan`, `[L] Muat`, `[M] Menu Utama`, serta status ada tidaknya data simpanan |
| `void renderCrafting(CraftingSystem crafting, Inventory inv, int selected)` | Layar Crafting: resep terbuka, bahan (dimiliki/butuh), hasil |
| `void showNotification(String message)` / `void renderNotification()` | Notifikasi 3,5 detik. Maksimal 3 bertumpuk, yang terlama dibuang |
| `void scrollBy(int delta)` / `void resetScroll()` | Menggulir panel yang isinya panjang (Inventory, Journal, Quest Log) |
| `void renderDataErrors(ArrayList<String> errors)` | Kotak merah berisi maksimal 4 pesan masalah data (kosong = tidak digambar) |

| `void renderMenu(int selected, boolean hasSave)` | Main Menu: judul, tiga pilihan, "Lanjutkan" diredupkan bila belum ada simpanan |

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

`Quest`: `id`, `title`, `description`, `status`, `objectives` (String[]), `done` (boolean[]), `rewardGiven`, `triggers` (`Trigger[]`, satu per objective, `null` = manual), `reward` (`QuestReward`), dan `boolean readyToReturn()` (semua objective selain yang terakhir selesai).

`Trigger`: `type` (`manual`, `enter_zone`, `discover`, `have_items`), `zoneId`, `discoverIds`, `itemIds`, `itemQty`, `orDiscover`.
`QuestReward`: `itemIds`, `itemQty`, `recipeIds`, `journalIds`.

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
| `boolean unlockRecipe(String id)` | Membuka resep terkunci. `false` jika tidak ada atau sudah terbuka |
| `ArrayList<Recipe> getUnlockedRecipes()` | Resep yang sudah terbuka, urut sesuai pendaftaran |
| `boolean canCraft(String recipeId, Inventory inv)` | `true` jika resep terbuka dan semua bahan cukup. Tidak mengubah inventory |
| `boolean craft(String recipeId, Inventory inv)` | Cek **semua** bahan dulu, baru kurangi. Gagal jika kurang atau resep terkunci, inventory tidak berubah |

`Recipe`: `id`, `name`, `ingredientIds` (String[]), `ingredientQty` (int[]), `outputId`, `outputQty`, `unlocked` (boolean, default `true`).

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
| `boolean saveGame(Game game)` | `false` jika gagal. Menulis ke `saves/save.tmp` dulu, lalu menggantikan `save.json`, sehingga file lama tidak rusak bila penulisan gagal |
| `boolean loadGame(Game game)` | `false` jika file tidak ada, rusak, atau tidak cocok dengan data game. File diperiksa **seluruhnya** dulu; state game **tidak berubah** bila ada masalah |
| `boolean hasSave()` | `true` jika `saves/save.json` ada |
| `String getLastMessage()` | Pesan hasil terakhir yang jelas, ditampilkan lewat `UI.showNotification()` |

Format penyimpanan ada di bagian 7. `Game.quickSave()` dan `Game.quickLoad()` memanggilnya dan hanya bekerja saat state `PLAYING` atau `PAUSED` (dialog tidak ikut disimpan).

### 3.13 `Pickup` (Anggota 3)

Benda di dunia yang diambil dengan tombol E (tanaman, bahan, sumber air).

| Method | Keterangan |
|---|---|
| `Pickup(String id, String name, String itemId, int quantity, float x, float y, boolean repeatable, String journalId, int r, int g, int b)` | `journalId` = entry Journal yang ditemukan saat diambil (`""` jika tidak ada). `r,g,b` = warna placeholder |
| `boolean isAvailable()` | `true` jika `repeatable` atau belum diambil |
| `boolean isNear(Player p)` | `true` jika tersedia dan pemain dalam jarak 24 pixel |
| `void markCollected()` | Menandai sudah diambil (diabaikan jika `repeatable`) |
| `void render()` | Menggambar (lingkaran placeholder). Tidak menggambar apa pun jika sudah diambil |
| `getId()` / `getName()` / `getItemId()` / `getQuantity()` / `getJournalId()` / `getX()` / `getY()` | Getter |

### 3.14 `DataLoader` (Anggota 1)

Memuat semua konten dari `data/`. File yang salah **tidak membuat game crash**: tiap masalah dicatat sebagai pesan dan game jalan dengan data yang berhasil dimuat.

| Method | Keterangan |
|---|---|
| `void loadAll(Game g)` | Urutan: peta, item, resep, journal, quest, dialog, NPC, pickup, lalu validasi. Setiap langkah dibungkus try/catch. Pesan dicetak ke console dengan awalan `[DATA]` dan disimpan di `g.dataErrors` |
| `JSONObject readJson(String path)` | Membaca satu file, `null` + pesan bila hilang atau JSON rusak |
| `Trigger parseTrigger(JSONObject t, String where)` / `QuestReward parseReward(JSONObject r)` | Penerjemah bagian quest |
| `void validate(Game g)` | Memeriksa semua rujukan antar file (item, entry, quest, dialog, zona), rentang `next` dialog, perintah aksi, dan pickup di tile yang menghalangi |

## 4. Format Dialog dan Aksi

Dialog adalah array `DialogueLine`. Di game, dialog ditulis di `data/game-data/dialogues.json` (format di DATA_FORMAT.md). Berikut bentuk setara di kode (penjaga taman):

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
| `finish_quest:<questId>` | Menandai objective terakhir, menyelesaikan quest **jika semua objective selesai**, lalu memberi reward satu kali |

Perintah baru ditambahkan di `Game.runAction()`, divalidasi di `DataLoader.validateAction()`, dan didaftarkan di tabel ini.

Dialog NPC dipilih sesuai progres lewat `rules` di `npcs.json`: `Game.pickDialogueFor(NPC)` memakai aturan pertama yang cocok (`locked`, `available`, `active`, `ready`, `completed`), jika tidak ada maka dialog bawaan.

## 5. Kontrol

| Tombol | Fungsi |
|---|---|
| W/A/S/D atau Panah | Bergerak |
| E | Interaksi, lanjut dialog, konfirmasi pilihan |
| W/S atau Panah atas/bawah (saat dialog, Crafting, atau panel) | Memilih jawaban, memilih resep, atau menggulir |
| I / J / Q / C | Inventory / Journal / Quest Log / Crafting (tekan lagi untuk menutup) |
| ESC | Pause. Saat dialog atau layar terbuka: menutupnya |
| F5 / F9 | Simpan / Muat (saat bermain atau jeda). Di laptop mungkin perlu menahan Fn |
| K / L / M (hanya di layar Pause) | Simpan / Muat / Kembali ke Main Menu |
| W/S dan E (di Main Menu) | Memilih dan mengonfirmasi. ESC, I, J, Q, C, F5, dan F9 diabaikan di menu |

## 6. Kepemilikan File

| Tab | Pemilik |
|---|---|
| `WhispersOfKnowledge.pde`, `Game.pde`, `QuestManager.pde`, `SaveManager.pde`, `DataLoader.pde` | Anggota 1 |
| `data/game-data/*.json` (konten) | Anggota 3 (item, resep, journal, dialog, NPC, quest, pickup), disetujui Anggota 1 |
| `data/maps/*.json` (peta) | Anggota 2 (format) dan Anggota 4 (layout) |
| `Player.pde`, `World.pde`, `Camera.pde` | Anggota 2 |
| `NPC.pde`, `DialogueSystem.pde`, `Pickup.pde`, `UI.pde`, `Inventory.pde`, `CraftingSystem.pde`, `Journal.pde` | Anggota 3 |

Mengubah file milik anggota lain hanya setelah dikoordinasikan.

## 7. Rencana Format Save

File `saves/save.json` di dalam folder sketch (masuk `.gitignore`), dibuat dengan `JSONObject`. Daftar ditulis sebagai array (bukan objek berkunci dinamis) agar mudah dibaca ulang:

```json
{
  "version": 1,
  "player": { "x": 104.0, "y": 88.0 },
  "inventory": [ { "id": "green_leaf", "qty": 2 }, { "id": "water", "qty": 1 } ],
  "journal": ["plants_need_light", "plant_green_leaf"],
  "recipesUnlocked": ["herbal_tea"],
  "quests": [
    { "id": "forgotten_garden", "status": "ACTIVE",
      "done": [true, false, false, false, false, false], "rewardGiven": false }
  ],
  "npcTalked": [ { "id": "npc_gardener", "count": 3 } ],
  "visitedZones": ["forest"],
  "pickupsCollected": ["pickup_leaf_1"]
}
```

**Aturan muat:** file ditolak (dengan pesan jelas, tanpa mengubah game) bila JSON rusak, `version` bukan 1, ada bagian yang hilang, ada ID yang tidak dikenal oleh data game saat ini (item, entry, resep, quest, NPC, zona, benda), jumlah `done` tidak cocok dengan objective quest, atau posisi pemain di luar peta. Bila posisi jatuh di tile yang menghalangi, pemain dipindah ke titik awal peta. Karena itu **save lama bisa tidak cocok** setelah ID di file data diubah atau dihapus (hal normal selama pengembangan: hapus `saves/save.json`).

## 8. Skenario *The Forgotten Garden* (data contoh)

Skenario ini bisa dimainkan dari awal sampai akhir dengan visual placeholder. Seluruh datanya ada di `data/game-data/` dan `data/maps/greenhaven.json`.

**Objective dan pemicunya**

| # | Objective | Selesai ketika |
|---|---|---|
| 0 | Berbicara dengan penjaga taman | Menerima quest lewat dialog |
| 1 | Menjelajahi Whispering Forest | Pemain masuk zona hutan (sudah pernah masuk sebelum quest pun dihitung) |
| 2 | Menemukan tiga jenis tanaman | Journal memuat entry Daun Hijau, Sunpetal, dan Moon Fern |
| 3 | Mengumpulkan bahan | Punya Green Leaf x2 dan Water x1 (atau sudah pernah crafting) |
| 4 | Membuat Herbal Tea | Crafting Herbal Tea berhasil |
| 5 | Kembali kepada penjaga taman | Dialog "siap kembali" memanggil `finish_quest` |

**Letak benda (koordinat tile)**

| Benda | Tile | Catatan |
|---|---|---|
| Pemain mulai | (5, 5) | |
| Penjaga Taman | (12, 9) | |
| Green Leaf | (22, 6) dan (24, 10) | Di hutan, masing-masing sekali ambil |
| Sunpetal | (30, 8) | Di hutan |
| Moon Fern | (34, 12) | Di hutan |
| Air Kolam | (24, 20) | Di selatan jalan, tepi barat kolam, bisa diambil berulang |

**Resep:** Herbal Tea = Green Leaf x2 + Water x1 (terbuka dari awal). Garden Tonic = Sunpetal + Moon Fern + Water (terkunci, dibuka sebagai reward).

**Reward (sekali saja, lewat `claimReward`):** Garden Seed x1, resep Garden Tonic, entry Journal "Taman sebagai Ekosistem".

## 9. Cara Menguji

1. Buka `WhispersOfKnowledge.pde` di Processing 4, lalu Run. Di tab terlihat 15 file `.pde`. **Tidak boleh ada kotak merah** di layar (artinya semua file data valid).
2. **Sebelum quest:** jalan ke timur melewati jalan cokelat sampai rumput lebih gelap. Notifikasi "Kamu memasuki Whispering Forest" muncul. Dekati lingkaran hijau di sekitar tile (22, 6): prompt `[E] Ambil Green Leaf`. Tekan E, masuk Inventory (I) dan Journal (J).
3. Tekan **C**: layar Crafting menampilkan Herbal Tea dengan bahan `Green Leaf (1/2), Water (0/1)`. Tekan E: notifikasi "Bahan tidak cukup", inventory tidak berubah. Tekan C untuk menutup.
4. **Terima quest:** dekati kotak oranye (penjaga taman), tekan E sampai muncul pilihan, pilih "Ya, aku akan membantu" dengan W/S lalu E. Cek Quest Log (Q): objective 1 dan 2 sudah `[x]`. Di kiri atas ada kotak "Tujuan: ..." yang mengikuti objective berikutnya.
5. **Kumpulkan:** ambil Green Leaf kedua, Sunpetal, Moon Fern (objective tanaman selesai), lalu air di kolam. Air bisa diambil berulang.
6. **Bicara sebelum siap:** dialog pengingat tampil ("Hutan ada di timur jalan...").
7. **Crafting:** tekan C lalu E. Herbal Tea masuk inventory, bahan berkurang, notifikasi muncul, Journal bertambah entry resep.
8. **Selesaikan:** bicara dengan penjaga taman. Dialog "Kamu membawa Herbal Tea!" tampil, quest selesai, dan muncul tiga notifikasi reward. Resep kedua (Garden Tonic) muncul di layar Crafting.
9. **Reward tidak berulang:** bicara lagi dengan penjaga taman. Garden Seed tetap x1.
10. Buka Journal: bila isinya panjang, W/S menggulir panel. ESC menutup dialog atau layar, atau menjeda permainan.
0. **Main Menu:** saat game dibuka tampil menu. Tanpa data simpanan, pilihan awal adalah "Permainan Baru" dan "Lanjutkan" redup. Dengan data simpanan, pilihan awal adalah "Lanjutkan".
11. **Simpan dan muat:** setelah menerima quest dan mengambil beberapa benda, tekan **F5** (notifikasi "Permainan disimpan."). Ambil benda lain, lalu tekan **F9**: inventory, Journal, quest, dan posisi kembali seperti saat F5, dan benda yang tadi diambil muncul lagi. Di layar Pause (ESC), **K** menyimpan dan **L** memuat. Folder `WhispersOfKnowledge/saves/` dibuat otomatis.
12. **Muat di sesi baru:** tutup game, jalankan lagi, tekan F9 atau ESC lalu L. Progres harus kembali. Hapus `saves/save.json`, lalu F9: muncul pesan "Belum ada data simpanan."

## 10. Status Pengujian dan Batasan

**Pengujian:** 172 pemeriksaan otomatis lulus (105 untuk data dan alur, 43 untuk Save/Load, 24 untuk Main Menu) dengan harness yang memakai stub API Processing: alur lengkap Forgotten Garden dari file JSON, peta dari file identik dengan peta cadangan, 8 jenis data rusak (file hilang, JSON terpotong, referensi salah, `next` di luar rentang, aksi salah, peta salah ukuran, trigger dan status tidak dikenal) menghasilkan pesan jelas tanpa crash, dan satu side quest + NPC kedua yang ditambahkan **hanya lewat JSON**. Save/Load: simpan di tengah quest lalu muat, muat di game baru, reward tidak berulang, 11 jenis file simpanan rusak ditolak tanpa mengubah game, penulisan gagal, dan tombol F5/F9/K/L. Main Menu: navigasi berputar, Lanjutkan tanpa save, Permainan Baru mereset semua progres, kembali ke menu dari Pause lalu Lanjutkan, dan Keluar. **Belum dijalankan di Processing asli** untuk versi ini. Verifikasi manual memakai langkah di bagian 9.

**Batasan yang diketahui:**

- Satu slot simpanan dan belum ada simpan otomatis. "Permainan Baru" tidak menghapus file simpanan lama (baru tertimpa saat Anda menyimpan lagi).
- Dialog yang sedang terbuka tidak ikut disimpan (simpan/muat dinonaktifkan saat dialog).
- Satu peta (`greenhaven.json`). Perpindahan antar peta belum ada.
- Jenis trigger, perintah aksi, dan karakter tile baru masih perlu kode.
- Tidak ada pesan "inventory penuh" karena jumlah slot tidak dibatasi.
- Layar Journal belum menampilkan entry yang belum ditemukan (sengaja disembunyikan).

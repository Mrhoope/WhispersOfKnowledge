// Game.pde
// Pemilik semua sistem dan state permainan. (Anggota 1)
// Game hanya MENGATUR alur dan menghubungkan sistem. Tampilan ada di UI,
// kamera di Camera, dialog di DialogueSystem.

enum GameState {
  PLAYING, DIALOGUE, INVENTORY, JOURNAL, QUEST_LOG, CRAFTING, PAUSED
}

class Game {
  World world;
  Camera camera;
  Player player;
  ArrayList<NPC> npcs = new ArrayList<NPC>();
  ArrayList<Pickup> pickups = new ArrayList<Pickup>();
  Inventory inventory;
  Journal journal;
  QuestManager quests;
  CraftingSystem crafting;
  DialogueSystem dialogue;
  SaveManager saveManager;
  UI ui;

  GameState state = GameState.PLAYING;

  // tombol gerak yang sedang ditahan
  boolean keyUp, keyDown, keyLeft, keyRight;

  // progres yang tidak tersimpan di class lain
  boolean forestVisited = false;
  int craftSelected = 0;

  // ID dan nomor objective quest utama
  final String QUEST_ID = "forgotten_garden";
  final String GARDENER_ID = "npc_gardener";
  final int OBJ_TALK = 0;
  final int OBJ_FOREST = 1;
  final int OBJ_PLANTS = 2;
  final int OBJ_GATHER = 3;
  final int OBJ_CRAFT = 4;
  final int OBJ_RETURN = 5;

  // dialog penjaga taman sesuai progres quest
  DialogueLine[] gardenerIntro, gardenerReminder, gardenerReady, gardenerDone;

  Game() {
    world = new World(40, 30);
    camera = new Camera(width / (float) ZOOM, height / (float) ZOOM);
    player = new Player(5 * TILE_SIZE + 8, 5 * TILE_SIZE + 8);
    inventory = new Inventory();
    journal = new Journal();
    quests = new QuestManager();
    crafting = new CraftingSystem();
    dialogue = new DialogueSystem();
    saveManager = new SaveManager();
    ui = new UI();
    setupContent();
  }

  // ---------- konten permainan ----------
  // DATA CONTOH. Nanti dipindah ke data/game-data (JSON).

  float tileCenter(int tile) {
    return tile * TILE_SIZE + TILE_SIZE / 2;
  }

  void setupContent() {
    // item
    inventory.registerItem(new ItemData("green_leaf", "Green Leaf", "Daun hijau segar. Bahan dasar ramuan herbal.", "Plants", ""));
    inventory.registerItem(new ItemData("sunpetal", "Sunpetal", "Bunga kuning yang mekar saat matahari terbit.", "Plants", ""));
    inventory.registerItem(new ItemData("moon_fern", "Moon Fern", "Pakis berembun yang tumbuh di tempat teduh.", "Plants", ""));
    inventory.registerItem(new ItemData("water", "Water", "Air bersih dari kolam.", "Materials", ""));
    inventory.registerItem(new ItemData("herbal_tea", "Herbal Tea", "Teh hangat dari daun herbal.", "Crafted Items", ""));
    inventory.registerItem(new ItemData("garden_tonic", "Garden Tonic", "Ramuan untuk menyuburkan tanaman.", "Crafted Items", ""));
    inventory.registerItem(new ItemData("garden_seed", "Garden Seed", "Biji hadiah dari penjaga taman.", "Quest Items", ""));

    // resep
    crafting.addRecipe(new Recipe("herbal_tea", "Herbal Tea",
      new String[] {"green_leaf", "water"}, new int[] {2, 1}, "herbal_tea", 1));
    Recipe tonic = new Recipe("garden_tonic", "Garden Tonic",
      new String[] {"sunpetal", "moon_fern", "water"}, new int[] {1, 1, 1}, "garden_tonic", 1);
    tonic.unlocked = false;   // dibuka sebagai reward quest
    crafting.addRecipe(tonic);

    // journal
    journal.registerEntry(new JournalEntry("plants_need_light", "Tanaman Butuh Cahaya", "Biology",
      "Tumbuhan membuat makanannya sendiri dengan bantuan cahaya matahari.",
      "Proses ini disebut fotosintesis."));
    journal.registerEntry(new JournalEntry("plant_green_leaf", "Daun Hijau", "Biology",
      "Daun berwarna hijau karena mengandung klorofil.",
      "Klorofil menangkap cahaya matahari untuk fotosintesis."));
    journal.registerEntry(new JournalEntry("plant_sunpetal", "Bunga Sunpetal", "Biology",
      "Bunga kuning ini mekar saat pagi dan didatangi lebah.",
      "Serangga membantu penyerbukan, yaitu memindahkan serbuk sari agar tumbuhan dapat berbiak."));
    journal.registerEntry(new JournalEntry("plant_moon_fern", "Pakis Moon Fern", "Biology",
      "Pakis tumbuh di tempat teduh dan lembap.",
      "Pakis berkembang biak dengan spora, bukan dengan biji."));
    journal.registerEntry(new JournalEntry("water_source", "Air Kolam", "Science",
      "Air kolam bening dan bisa disaring untuk ramuan.",
      "Air dapat berwujud cair, padat (es), dan gas (uap), tergantung suhunya."));
    journal.registerEntry(new JournalEntry("herbal_tea_recipe", "Resep Herbal Tea", "Alchemy",
      "2 Green Leaf dan 1 Water menghasilkan 1 Herbal Tea.",
      "Resep menetapkan bahan dan takaran. Takaran yang kurang membuat ramuan gagal dibuat."));
    journal.registerEntry(new JournalEntry("garden_ecosystem", "Taman sebagai Ekosistem", "Biology",
      "Tanaman, serangga, jamur, dan air di taman saling membutuhkan.",
      "Ekosistem adalah hubungan saling bergantung antara makhluk hidup dan lingkungannya."));

    // quest utama (objective sesuai PRD 8.3)
    Quest q = new Quest(QUEST_ID, "The Forgotten Garden",
      "Bantu penjaga taman menghidupkan kembali tamannya.",
      new String[] {
        "Berbicara dengan penjaga taman",
        "Menjelajahi Whispering Forest (timur jalan)",
        "Menemukan tiga jenis tanaman",
        "Mengumpulkan bahan: 2 Green Leaf dan 1 Water",
        "Membuat Herbal Tea (tombol C)",
        "Kembali kepada penjaga taman"
      });
    q.status = QuestStatus.AVAILABLE;
    quests.addQuest(q);

    // benda yang bisa diambil: dua Green Leaf, Sunpetal, Moon Fern di hutan, dan air di kolam
    pickups.add(new Pickup("pickup_leaf_1", "Green Leaf", "green_leaf", 1,
      tileCenter(22), tileCenter(6), false, "plant_green_leaf", 70, 170, 70));
    pickups.add(new Pickup("pickup_leaf_2", "Green Leaf", "green_leaf", 1,
      tileCenter(24), tileCenter(10), false, "plant_green_leaf", 70, 170, 70));
    pickups.add(new Pickup("pickup_sunpetal", "Sunpetal", "sunpetal", 1,
      tileCenter(30), tileCenter(8), false, "plant_sunpetal", 250, 210, 60));
    pickups.add(new Pickup("pickup_moon_fern", "Moon Fern", "moon_fern", 1,
      tileCenter(34), tileCenter(12), false, "plant_moon_fern", 120, 200, 190));
    pickups.add(new Pickup("pickup_water", "Air Kolam", "water", 1,
      tileCenter(24), tileCenter(20), true, "water_source", 80, 150, 230));

    setupGardenerDialogues();
    npcs.add(new NPC(GARDENER_ID, "Penjaga Taman",
      tileCenter(12), tileCenter(9), gardenerIntro));
  }

  void setupGardenerDialogues() {
    // Sebelum quest diterima
    gardenerIntro = new DialogueLine[] {
      /* 0 */ new DialogueLine("Halo, pengembara! Taman ini dulu sangat indah.", 1, ""),
      /* 1 */ new DialogueLine("Sekarang taman ini terlupakan. Maukah kamu membantuku?",
                new String[] {"Ya, aku akan membantu.", "Nanti dulu."},
                new int[] {2, 5}),
      /* 2 */ new DialogueLine("Terima kasih! Pergilah ke hutan di timur jalan dan temukan tiga jenis tanaman. Tekan E untuk mengambilnya.", 3,
                "start_quest:" + QUEST_ID + ";objective:" + QUEST_ID + ":" + OBJ_TALK + ";discover:plants_need_light"),
      /* 3 */ new DialogueLine("Kamu juga butuh air bersih dari kolam. Setelah bahan lengkap, buka Crafting dengan tombol C untuk membuat Herbal Tea.", 4, ""),
      /* 4 */ new DialogueLine("Bawa Herbal Tea itu kembali kepadaku, ya.", -1, ""),
      /* 5 */ new DialogueLine("Baiklah. Kembalilah kalau kamu sudah siap.", -1, "")
    };

    // Quest aktif, tujuan belum selesai
    gardenerReminder = new DialogueLine[] {
      /* 0 */ new DialogueLine("Hutan ada di timur jalan. Cari tiga jenis tanaman dan ambil air dari kolam.", 1, ""),
      /* 1 */ new DialogueLine("Lalu buat Herbal Tea dengan tombol C, dan kembalilah kepadaku.", -1, "")
    };

    // Semua tujuan selesai, tinggal kembali
    gardenerReady = new DialogueLine[] {
      /* 0 */ new DialogueLine("Kamu membawa Herbal Tea! Harumnya seperti taman di masa lalu.", 1, ""),
      /* 1 */ new DialogueLine("Taman ini akan hidup lagi. Terima kasih! Ini hadiah untukmu.", 2,
                "finish_quest:" + QUEST_ID),
      /* 2 */ new DialogueLine("Aku menambahkan catatan di Journal-mu dan sebuah resep baru: Garden Tonic.", -1, "")
    };

    // Quest selesai
    gardenerDone = new DialogueLine[] {
      /* 0 */ new DialogueLine("Terima kasih sudah membantu. Tamannya kembali hijau!", 1, ""),
      /* 1 */ new DialogueLine("Coba buat Garden Tonic dengan tombol C untuk menyuburkan tanaman.", -1, "")
    };
  }

  // ---------- update dan render ----------

  void update() {
    if (state != GameState.PLAYING) return;

    int dx = 0;
    int dy = 0;
    if (keyLeft)  dx -= 1;
    if (keyRight) dx += 1;
    if (keyUp)    dy -= 1;
    if (keyDown)  dy += 1;
    player.update(world, dx, dy);

    if (!forestVisited && world.isForestPx(player.getX(), player.getY())) {
      forestVisited = true;
      ui.showNotification("Kamu memasuki Whispering Forest");
      checkQuestProgress();
    }
  }

  void render() {
    background(20, 28, 22);

    camera.follow(player.getX(), player.getY(), world);

    // dunia (dengan kamera dan zoom)
    pushMatrix();
    camera.apply();
    world.render(camera.getX(), camera.getY(), camera.getViewW(), camera.getViewH());
    for (Pickup p : pickups) {
      p.render();
    }
    for (NPC n : npcs) {
      n.render();
    }
    player.render();
    popMatrix();

    // antarmuka (tanpa zoom)
    ui.renderHud(quests, getInteractPrompt());

    switch (state) {
      case DIALOGUE:  ui.renderDialogue(dialogue); break;
      case INVENTORY: ui.renderInventory(inventory); break;
      case JOURNAL:   ui.renderJournal(journal); break;
      case QUEST_LOG: ui.renderQuestLog(quests); break;
      case CRAFTING:  ui.renderCrafting(crafting, inventory, craftSelected); break;
      case PAUSED:    ui.renderPause(); break;
      default: break;
    }
    ui.renderNotification();
  }

  // ---------- interaksi ----------

  float distToPlayer(float x, float y) {
    return dist(x, y, player.getX(), player.getY());
  }

  NPC findNearestNpc() {
    NPC best = null;
    float bestDist = 99999;
    for (NPC n : npcs) {
      if (n.isNear(player)) {
        float d = distToPlayer(n.getX(), n.getY());
        if (d < bestDist) {
          bestDist = d;
          best = n;
        }
      }
    }
    return best;
  }

  Pickup findNearestPickup() {
    Pickup best = null;
    float bestDist = 99999;
    for (Pickup p : pickups) {
      if (p.isNear(player)) {
        float d = distToPlayer(p.getX(), p.getY());
        if (d < bestDist) {
          bestDist = d;
          best = p;
        }
      }
    }
    return best;
  }

  // true jika NPC lebih dekat daripada pickup (atau tidak ada pickup)
  boolean npcIsNearerThan(NPC n, Pickup p) {
    return n != null && (p == null
        || distToPlayer(n.getX(), n.getY()) <= distToPlayer(p.getX(), p.getY()));
  }

  // Teks petunjuk interaksi, atau null jika tidak ada yang dekat.
  String getInteractPrompt() {
    if (state != GameState.PLAYING) return null;
    NPC n = findNearestNpc();
    Pickup p = findNearestPickup();
    if (npcIsNearerThan(n, p)) return "[E] Bicara dengan " + n.getName();
    if (p != null) return "[E] Ambil " + p.getName();
    return null;
  }

  void onInteract() {
    if (state == GameState.DIALOGUE) {
      dialogue.confirm();
      afterDialogueInput();
    } else if (state == GameState.CRAFTING) {
      craftSelectedRecipe();
    } else if (state == GameState.PLAYING) {
      NPC n = findNearestNpc();
      Pickup p = findNearestPickup();
      if (npcIsNearerThan(n, p)) {
        talkTo(n);
      } else if (p != null) {
        collect(p);
      }
    }
  }

  void talkTo(NPC n) {
    if (n.getId().equals(GARDENER_ID)) {
      n.setDialogue(pickGardenerDialogue());
    }
    n.interact(dialogue);
    if (dialogue.isOpen()) {
      state = GameState.DIALOGUE;
    }
    afterDialogueInput();
  }

  // Memilih dialog penjaga taman sesuai status quest.
  DialogueLine[] pickGardenerDialogue() {
    Quest q = quests.getQuest(QUEST_ID);
    if (q == null) return gardenerIntro;
    if (q.status == QuestStatus.COMPLETED) return gardenerDone;
    if (q.status == QuestStatus.ACTIVE) {
      return readyToReturn(q) ? gardenerReady : gardenerReminder;
    }
    return gardenerIntro;
  }

  // true jika semua objective selesai kecuali yang terakhir (kembali ke NPC).
  boolean readyToReturn(Quest q) {
    for (int i = 0; i < q.done.length - 1; i++) {
      if (!q.done[i]) return false;
    }
    return true;
  }

  void collect(Pickup p) {
    if (!inventory.addItem(p.getItemId(), p.getQuantity())) return;
    p.markCollected();
    ui.showNotification("Mengambil " + itemName(p.getItemId()) + " x" + p.getQuantity());
    if (p.getJournalId().length() > 0 && journal.discover(p.getJournalId())) {
      ui.showNotification("Journal diperbarui: " + journal.getEntry(p.getJournalId()).title);
    }
    checkQuestProgress();
  }

  String itemName(String id) {
    ItemData d = inventory.getItemData(id);
    return (d != null) ? d.name : id;
  }

  // ---------- crafting ----------

  void craftSelectedRecipe() {
    ArrayList<Recipe> list = crafting.getUnlockedRecipes();
    if (list.isEmpty()) return;
    craftSelected = constrain(craftSelected, 0, list.size() - 1);
    Recipe r = list.get(craftSelected);

    if (crafting.craft(r.id, inventory)) {
      ui.showNotification("Berhasil membuat " + itemName(r.outputId));
      afterCraft(r.id);
    } else {
      ui.showNotification("Bahan tidak cukup untuk " + r.name);
    }
  }

  void afterCraft(String recipeId) {
    if (recipeId.equals("herbal_tea") && journal.discover("herbal_tea_recipe")) {
      ui.showNotification("Journal diperbarui: Resep Herbal Tea");
    }
    checkQuestProgress();
  }

  // ---------- quest ----------

  // Memeriksa kondisi semua objective quest utama dan menandai yang terpenuhi.
  void checkQuestProgress() {
    Quest q = quests.getQuest(QUEST_ID);
    if (q == null || q.status != QuestStatus.ACTIVE) return;

    boolean crafted = journal.hasEntry("herbal_tea_recipe");
    boolean threePlants = journal.hasEntry("plant_green_leaf")
                       && journal.hasEntry("plant_sunpetal")
                       && journal.hasEntry("plant_moon_fern");
    boolean materials = inventory.hasItem("green_leaf", 2) && inventory.hasItem("water", 1);

    if (forestVisited) markObjective(q, OBJ_FOREST);
    if (threePlants)   markObjective(q, OBJ_PLANTS);
    if (materials || crafted) markObjective(q, OBJ_GATHER);
    if (crafted)       markObjective(q, OBJ_CRAFT);
  }

  void markObjective(Quest q, int index) {
    if (q.done[index]) return;
    if (quests.completeObjective(q.id, index)) {
      ui.showNotification("Tujuan selesai: " + q.objectives[index]);
    }
  }

  // Menyelesaikan quest dan memberi reward satu kali.
  void finishQuest(String id) {
    Quest q = quests.getQuest(id);
    if (q == null) return;
    markObjective(q, q.objectives.length - 1);
    if (quests.completeQuest(id)) {
      ui.showNotification("Quest selesai: " + q.title);
      if (quests.claimReward(id)) {
        giveQuestRewards(id);
      }
    }
  }

  void giveQuestRewards(String id) {
    if (id.equals(QUEST_ID)) {
      inventory.addItem("garden_seed", 1);
      ui.showNotification("Hadiah: Garden Seed x1");
      if (crafting.unlockRecipe("garden_tonic")) {
        ui.showNotification("Resep baru: Garden Tonic");
      }
      if (journal.discover("garden_ecosystem")) {
        ui.showNotification("Journal diperbarui: Taman sebagai Ekosistem");
      }
    }
  }

  // ---------- dialog ----------

  // Dipanggil setelah setiap input dialog: jalankan aksi, tutup jika selesai.
  void afterDialogueInput() {
    String actions = dialogue.pollAction();
    if (actions != null) {
      runActions(actions);
    }
    checkQuestProgress();
    if (!dialogue.isOpen()) {
      state = GameState.PLAYING;
    }
  }

  // Beberapa perintah dipisah ";"
  void runActions(String actions) {
    String[] parts = split(actions, ';');
    for (String part : parts) {
      runAction(part.trim());
    }
  }

  // Satu perintah berformat nama:argumen1:argumen2
  void runAction(String command) {
    if (command.length() == 0) return;
    String[] p = split(command, ':');

    if (p[0].equals("start_quest") && p.length >= 2) {
      if (quests.startQuest(p[1])) {
        ui.showNotification("Quest dimulai: " + quests.getQuest(p[1]).title);
      }
    } else if (p[0].equals("objective") && p.length >= 3) {
      quests.completeObjective(p[1], int(p[2]));
    } else if (p[0].equals("give_item") && p.length >= 3) {
      if (inventory.addItem(p[1], int(p[2]))) {
        ui.showNotification("Menerima " + itemName(p[1]) + " x" + p[2]);
      }
    } else if (p[0].equals("discover") && p.length >= 2) {
      if (journal.discover(p[1])) {
        ui.showNotification("Journal diperbarui: " + journal.getEntry(p[1]).title);
      }
    } else if (p[0].equals("finish_quest") && p.length >= 2) {
      finishQuest(p[1]);
    } else {
      println("Aksi tidak dikenal: " + command);
    }
  }

  // ---------- input ----------

  boolean isFullScreenPanel() {
    return state == GameState.INVENTORY || state == GameState.JOURNAL
        || state == GameState.QUEST_LOG || state == GameState.CRAFTING;
  }

  // Buka atau tutup layar penuh (Inventory, Journal, Quest Log, Crafting).
  void toggleScreen(GameState target) {
    if (state == target) {
      state = GameState.PLAYING;
    } else if (state == GameState.PLAYING || isFullScreenPanel()) {
      state = target;
    } else {
      return;
    }
    ui.resetScroll();
    craftSelected = 0;
  }

  void onEscape() {
    if (state == GameState.DIALOGUE) {
      dialogue.close();
      state = GameState.PLAYING;
    } else if (state == GameState.PLAYING) {
      state = GameState.PAUSED;
    } else {
      state = GameState.PLAYING;
    }
  }

  // delta = -1 (naik) atau 1 (turun): pilihan dialog, resep, atau gulir panel
  void onMenuMove(int delta) {
    if (state == GameState.DIALOGUE) {
      dialogue.moveSelection(delta);
    } else if (state == GameState.CRAFTING) {
      int n = crafting.getUnlockedRecipes().size();
      if (n > 0) {
        craftSelected = (craftSelected + delta + n) % n;
      }
    } else if (state == GameState.INVENTORY || state == GameState.JOURNAL
            || state == GameState.QUEST_LOG) {
      ui.scrollBy(delta);
    }
  }

  void keyPressed() {
    if (key == CODED) {
      if (keyCode == UP)    { keyUp = true;   onMenuMove(-1); }
      if (keyCode == DOWN)  { keyDown = true; onMenuMove(1); }
      if (keyCode == LEFT)  keyLeft = true;
      if (keyCode == RIGHT) keyRight = true;
      return;
    }

    if (key == ESC) {
      onEscape();
      return;
    }

    char k = Character.toLowerCase(key);
    if (k == 'w') { keyUp = true;   onMenuMove(-1); }
    if (k == 's') { keyDown = true; onMenuMove(1); }
    if (k == 'a') keyLeft = true;
    if (k == 'd') keyRight = true;
    if (k == 'e') onInteract();
    if (k == 'i') toggleScreen(GameState.INVENTORY);
    if (k == 'j') toggleScreen(GameState.JOURNAL);
    if (k == 'q') toggleScreen(GameState.QUEST_LOG);
    if (k == 'c') toggleScreen(GameState.CRAFTING);
  }

  void keyReleased() {
    if (key == CODED) {
      if (keyCode == UP)    keyUp = false;
      if (keyCode == DOWN)  keyDown = false;
      if (keyCode == LEFT)  keyLeft = false;
      if (keyCode == RIGHT) keyRight = false;
      return;
    }
    char k = Character.toLowerCase(key);
    if (k == 'w') keyUp = false;
    if (k == 's') keyDown = false;
    if (k == 'a') keyLeft = false;
    if (k == 'd') keyRight = false;
  }
}

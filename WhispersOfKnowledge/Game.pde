// Game.pde
// Pemilik semua sistem dan state permainan. (Anggota 1)
// Game hanya MENGATUR alur dan menghubungkan sistem. Tampilan ada di UI,
// kamera di Camera, dialog di DialogueSystem.

enum GameState {
  PLAYING, DIALOGUE, INVENTORY, JOURNAL, QUEST_LOG, PAUSED
}

class Game {
  World world;
  Camera camera;
  Player player;
  ArrayList<NPC> npcs = new ArrayList<NPC>();
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
    setupDemoData();
  }

  // DATA CONTOH untuk menguji integrasi. Nanti dipindah ke data/game-data.
  void setupDemoData() {
    inventory.registerItem(new ItemData("green_leaf", "Green Leaf", "Daun hijau segar.", "Plants", ""));
    inventory.registerItem(new ItemData("water", "Water", "Air bersih.", "Materials", ""));
    inventory.registerItem(new ItemData("herbal_tea", "Herbal Tea", "Teh dari daun herbal.", "Crafted Items", ""));
    inventory.addItem("green_leaf", 2);
    inventory.addItem("water", 1);

    crafting.addRecipe(new Recipe("herbal_tea", "Herbal Tea",
      new String[] {"green_leaf", "water"}, new int[] {2, 1}, "herbal_tea", 1));

    journal.registerEntry(new JournalEntry("plants_need_light", "Tanaman Butuh Cahaya", "Biology",
      "Tumbuhan membuat makanannya sendiri dengan bantuan cahaya matahari.",
      "Proses ini disebut fotosintesis."));

    Quest q = new Quest("forgotten_garden", "The Forgotten Garden",
      "Bantu penjaga taman menghidupkan kembali tamannya.",
      new String[] {
        "Berbicara dengan penjaga taman",
        "Menjelajahi hutan",
        "Menemukan tiga jenis tanaman",
        "Mengumpulkan bahan yang dibutuhkan",
        "Melakukan crafting",
        "Kembali kepada penjaga taman"
      });
    q.status = QuestStatus.AVAILABLE;
    quests.addQuest(q);

    DialogueLine[] gardenerTalk = new DialogueLine[] {
      /* 0 */ new DialogueLine("Halo, pengembara! Taman ini dulu sangat indah.", 1, ""),
      /* 1 */ new DialogueLine("Sekarang taman ini terlupakan. Maukah kamu membantuku?",
                new String[] {"Ya, aku akan membantu.", "Nanti dulu."},
                new int[] {2, 3}),
      /* 2 */ new DialogueLine("Terima kasih! Jelajahi hutan, temukan tiga jenis tanaman, lalu kembali padaku.", -1,
                "start_quest:forgotten_garden;objective:forgotten_garden:0;discover:plants_need_light"),
      /* 3 */ new DialogueLine("Baiklah. Kembalilah kalau kamu sudah siap.", -1, "")
    };
    npcs.add(new NPC("npc_gardener", "Penjaga Taman",
      12 * TILE_SIZE + 8, 9 * TILE_SIZE + 8, gardenerTalk));
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
  }

  void render() {
    background(20, 28, 22);

    camera.follow(player.getX(), player.getY(), world);

    // dunia (dengan kamera dan zoom)
    pushMatrix();
    camera.apply();
    world.render(camera.getX(), camera.getY(), camera.getViewW(), camera.getViewH());
    for (NPC n : npcs) {
      n.render();
    }
    player.render();
    popMatrix();

    // antarmuka (tanpa zoom)
    boolean canInteract = (state == GameState.PLAYING && findNearestNpc() != null);
    ui.renderHud(quests, canInteract);

    switch (state) {
      case DIALOGUE:  ui.renderDialogue(dialogue); break;
      case INVENTORY: ui.renderInventory(inventory); break;
      case JOURNAL:   ui.renderJournal(journal); break;
      case QUEST_LOG: ui.renderQuestLog(quests); break;
      case PAUSED:    ui.renderPause(); break;
      default: break;
    }
    ui.renderNotification();
  }

  // ---------- interaksi ----------

  NPC findNearestNpc() {
    NPC best = null;
    float bestDist = 99999;
    for (NPC n : npcs) {
      if (n.isNear(player)) {
        float d = dist(n.getX(), n.getY(), player.getX(), player.getY());
        if (d < bestDist) {
          bestDist = d;
          best = n;
        }
      }
    }
    return best;
  }

  void onInteract() {
    if (state == GameState.DIALOGUE) {
      dialogue.confirm();
      afterDialogueInput();
    } else if (state == GameState.PLAYING) {
      NPC n = findNearestNpc();
      if (n != null) {
        n.interact(dialogue);
        if (dialogue.isOpen()) {
          state = GameState.DIALOGUE;
        }
        afterDialogueInput();
      }
    }
  }

  // Dipanggil setelah setiap input dialog: jalankan aksi, tutup jika selesai.
  void afterDialogueInput() {
    String actions = dialogue.pollAction();
    if (actions != null) {
      runActions(actions);
    }
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
        Quest q = quests.getQuest(p[1]);
        ui.showNotification("Quest dimulai: " + q.title);
      }
    } else if (p[0].equals("objective") && p.length >= 3) {
      quests.completeObjective(p[1], int(p[2]));
    } else if (p[0].equals("give_item") && p.length >= 3) {
      if (inventory.addItem(p[1], int(p[2]))) {
        ui.showNotification("Menerima item: " + p[1] + " x" + p[2]);
      }
    } else if (p[0].equals("discover") && p.length >= 2) {
      if (journal.discover(p[1])) {
        ui.showNotification("Journal diperbarui");
      }
    } else {
      println("Aksi tidak dikenal: " + command);
    }
  }

  // ---------- input ----------

  // Buka atau tutup layar penuh (Inventory, Journal, Quest Log).
  void toggleScreen(GameState target) {
    if (state == target) {
      state = GameState.PLAYING;
    } else if (state == GameState.PLAYING || state == GameState.INVENTORY
            || state == GameState.JOURNAL || state == GameState.QUEST_LOG) {
      state = target;
    }
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

  // delta = -1 (naik) atau 1 (turun), dipakai untuk memilih jawaban dialog
  void onMenuMove(int delta) {
    if (state == GameState.DIALOGUE) {
      dialogue.moveSelection(delta);
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

// Game.pde
// Pemilik semua sistem dan state permainan. (Anggota 1)
// Game hanya MENGATUR alur dan menghubungkan sistem. Tampilan ada di UI,
// kamera di Camera, dialog di DialogueSystem, dan konten (item, quest, dialog,
// peta) dimuat dari folder data/ oleh DataLoader.

enum GameState {
  MENU, PLAYING, DIALOGUE, INVENTORY, JOURNAL, QUEST_LOG, CRAFTING, PAUSED
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
  Assets assets;
  UI ui;

  // isi data dari file
  HashMap<String, DialogueLine[]> dialogueSets = new HashMap<String, DialogueLine[]>();
  ArrayList<String> dataErrors = new ArrayList<String>();   // masalah saat memuat data

  GameState state = GameState.MENU;
  int menuSelected = 0;   // pilihan di Main Menu

  // tombol gerak yang sedang ditahan
  boolean keyUp, keyDown, keyLeft, keyRight;

  // progres yang tidak tersimpan di class lain
  HashSet<String> visitedZones = new HashSet<String>();
  int craftSelected = 0;

  Game() {
    init();
  }

  // Membuat semua sistem dari awal dan memuat data. Dipakai saat game dibuka
  // dan saat "Permainan Baru", sehingga tidak ada sisa progres lama.
  void init() {
    npcs = new ArrayList<NPC>();
    pickups = new ArrayList<Pickup>();
    dialogueSets = new HashMap<String, DialogueLine[]>();
    dataErrors = new ArrayList<String>();
    visitedZones = new HashSet<String>();
    craftSelected = 0;
    keyUp = false;
    keyDown = false;
    keyLeft = false;
    keyRight = false;

    world = new World(40, 30);
    camera = new Camera(width / (float) ZOOM, height / (float) ZOOM);
    inventory = new Inventory();
    journal = new Journal();
    quests = new QuestManager();
    crafting = new CraftingSystem();
    dialogue = new DialogueSystem();
    saveManager = new SaveManager();
    ui = new UI();

    // memuat peta dan semua konten dari data/
    DataLoader loader = new DataLoader();
    loader.loadAll(this);

    player = new Player(world.getStartX(), world.getStartY());

    assets = new Assets();
    applyAssets();

    state = GameState.MENU;
    menuSelected = saveManager.hasSave() ? 0 : 1;   // Lanjutkan bila ada simpanan

    if (!dataErrors.isEmpty()) {
      ui.showNotification("Ada " + dataErrors.size() + " masalah data. Lihat kotak merah.");
    }
  }

  // Memasang gambar bila filenya ada. Yang tidak ada tetap memakai placeholder.
  // Aturan nama file: docs/ASSET_GUIDE.md
  void applyAssets() {
    world.setTileImages(
      assets.get("tilesets/tile_grass.png"),
      assets.get("tilesets/tile_grass_forest.png"),
      assets.get("tilesets/tile_dirt.png"),
      assets.get("tilesets/tile_water.png"),
      assets.get("tilesets/object_tree.png"));

    PImage any = assets.get("sprites/player.png");
    player.setFallbackSprite(any);
    player.setSprite(0, assets.get("sprites/player_idle_down.png"));
    player.setSprite(1, assets.get("sprites/player_idle_up.png"));
    player.setSprite(2, assets.get("sprites/player_idle_left.png"));
    player.setSprite(3, assets.get("sprites/player_idle_right.png"));

    for (NPC n : npcs) {
      n.setSprite(assets.get("sprites/" + n.getId() + ".png"));
    }
    for (Pickup p : pickups) {
      p.setSprite(assets.get("sprites/item_" + p.getItemId() + ".png"));
    }
    assets.printSummary();
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

    checkZoneEntry();
  }

  // Mencatat zona yang pertama kali dimasuki pemain.
  void checkZoneEntry() {
    for (Zone z : world.getZones()) {
      if (!visitedZones.contains(z.id) && world.isInZonePx(z.id, player.getX(), player.getY())) {
        visitedZones.add(z.id);
        ui.showNotification("Kamu memasuki " + z.name);
        checkQuestProgress();
      }
    }
  }

  void render() {
    background(20, 28, 22);

    if (state == GameState.MENU) {
      ui.renderMenu(menuSelected, saveManager.hasSave());
      ui.renderNotification();
      ui.renderDataErrors(dataErrors);
      return;
    }

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
      case PAUSED:    ui.renderPause(saveManager.hasSave()); break;
      default: break;
    }
    ui.renderNotification();
    ui.renderDataErrors(dataErrors);
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

  // ---------- Main Menu ----------

  void startNewGame() {
    init();
    state = GameState.PLAYING;
  }

  void menuConfirm() {
    if (menuSelected == 0) {
      saveManager.loadGame(this);   // berhasil: state menjadi PLAYING; gagal: tetap di menu
      ui.showNotification(saveManager.getLastMessage());
    } else if (menuSelected == 1) {
      startNewGame();
    } else {
      exit();
    }
  }

  // Kembali ke Main Menu dari layar Pause (progres yang belum disimpan hilang).
  void backToMenu() {
    if (state != GameState.PAUSED) return;
    init();
  }

  void onInteract() {
    if (state == GameState.MENU) {
      menuConfirm();
      return;
    }
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
    n.setDialogue(pickDialogueFor(n));
    n.interact(dialogue);
    if (dialogue.isOpen()) {
      state = GameState.DIALOGUE;
    }
    afterDialogueInput();
  }

  // Memilih dialog NPC: aturan pertama yang cocok dengan status quest, atau dialog bawaan.
  DialogueLine[] pickDialogueFor(NPC n) {
    for (DialogueRule r : n.getRules()) {
      Quest q = quests.getQuest(r.questId);
      if (q != null && stateMatches(q, r.state)) {
        DialogueLine[] set = dialogueSets.get(r.dialogueId);
        if (set != null) return set;
      }
    }
    return n.getDefaultDialogue();
  }

  boolean stateMatches(Quest q, String state) {
    if (state.equals("locked"))    return q.status == QuestStatus.LOCKED;
    if (state.equals("available")) return q.status == QuestStatus.AVAILABLE;
    if (state.equals("active"))    return q.status == QuestStatus.ACTIVE;
    if (state.equals("ready"))     return q.status == QuestStatus.ACTIVE && q.readyToReturn();
    if (state.equals("completed")) return q.status == QuestStatus.COMPLETED;
    return false;
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
    // Mencatat resep yang sudah pernah dibuat ke Journal: entry bernama "<id resep>_recipe".
    String entryId = recipeId + "_recipe";
    if (journal.discover(entryId)) {
      ui.showNotification("Journal diperbarui: " + journal.getEntry(entryId).title);
    }
    checkQuestProgress();
  }

  // ---------- quest ----------

  // true jika syarat otomatis sebuah objective sudah terpenuhi.
  boolean isTriggerMet(Trigger t) {
    if (t == null || t.type.equals("manual")) return false;

    if (t.type.equals("enter_zone")) {
      return visitedZones.contains(t.zoneId);
    }
    if (t.type.equals("discover")) {
      for (String id : t.discoverIds) {
        if (!journal.hasEntry(id)) return false;
      }
      return true;
    }
    if (t.type.equals("have_items")) {
      if (t.orDiscover.length() > 0 && journal.hasEntry(t.orDiscover)) return true;
      for (int i = 0; i < t.itemIds.length; i++) {
        if (!inventory.hasItem(t.itemIds[i], t.itemQty[i])) return false;
      }
      return true;
    }
    return false;
  }

  // Memeriksa syarat semua objective dari semua quest aktif dan menandai yang terpenuhi.
  void checkQuestProgress() {
    for (Quest q : quests.getAllQuests()) {
      if (q.status != QuestStatus.ACTIVE) continue;
      for (int i = 0; i < q.triggers.length; i++) {
        if (isTriggerMet(q.triggers[i])) {
          markObjective(q, i);
        }
      }
    }
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
        giveQuestRewards(q);
      }
    }
  }

  void giveQuestRewards(Quest q) {
    QuestReward r = q.reward;
    for (int i = 0; i < r.itemIds.length; i++) {
      if (inventory.addItem(r.itemIds[i], r.itemQty[i])) {
        ui.showNotification("Hadiah: " + itemName(r.itemIds[i]) + " x" + r.itemQty[i]);
      }
    }
    for (String id : r.recipeIds) {
      if (crafting.unlockRecipe(id)) {
        ui.showNotification("Resep baru: " + crafting.getRecipe(id).name);
      }
    }
    for (String id : r.journalIds) {
      if (journal.discover(id)) {
        ui.showNotification("Journal diperbarui: " + journal.getEntry(id).title);
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

  // Simpan dan muat hanya saat bermain atau jeda (dialog tidak ikut disimpan).
  boolean canSaveLoad() {
    return state == GameState.PLAYING || state == GameState.PAUSED;
  }

  void quickSave() {
    if (!canSaveLoad()) return;
    saveManager.saveGame(this);
    ui.showNotification(saveManager.getLastMessage());
  }

  void quickLoad() {
    if (!canSaveLoad()) return;
    saveManager.loadGame(this);
    ui.showNotification(saveManager.getLastMessage());
  }

  void onEscape() {
    if (state == GameState.MENU) return;
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
    if (state == GameState.MENU) {
      menuSelected = (menuSelected + delta + 3) % 3;
    } else if (state == GameState.DIALOGUE) {
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
      if (keyCode == 116) quickSave();   // F5
      if (keyCode == 120) quickLoad();   // F9
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
    if (state == GameState.PAUSED) {
      if (k == 'k') quickSave();
      if (k == 'l') quickLoad();
      if (k == 'm') backToMenu();
    }
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

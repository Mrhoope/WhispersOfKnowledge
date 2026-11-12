// SaveManager.pde
// Simpan dan muat progress ke saves/save.json di folder sketch. (Anggota 1)
//
// Prinsip:
// - saveGame menulis ke file sementara dulu, baru menggantikan file lama,
//   supaya file simpanan lama tidak rusak bila penulisan gagal.
// - loadGame memeriksa SELURUH file lebih dulu. Hanya bila semuanya valid,
//   state game diubah. Bila ada masalah, state game TIDAK berubah.
// - Setiap hasil punya pesan jelas lewat getLastMessage() (PRD 18).
//
// Format file dijelaskan di TECHNICAL_SPEC.md bagian 7.

class SaveManager {
  final int SAVE_VERSION = 1;
  String lastMessage = "";

  String savePath()    { return sketchPath("saves/save.json"); }
  String tempPath()    { return sketchPath("saves/save.tmp"); }

  boolean hasSave() {
    return new java.io.File(savePath()).exists();
  }

  String getLastMessage() {
    return lastMessage;
  }

  // ---------- simpan ----------

  boolean saveGame(Game game) {
    try {
      JSONObject root = new JSONObject();
      root.setInt("version", SAVE_VERSION);

      JSONObject p = new JSONObject();
      p.setFloat("x", game.player.getX());
      p.setFloat("y", game.player.getY());
      root.setJSONObject("player", p);

      JSONArray inv = new JSONArray();
      for (String id : game.inventory.getAll().keySet()) {
        JSONObject o = new JSONObject();
        o.setString("id", id);
        o.setInt("qty", game.inventory.getQuantity(id));
        inv.append(o);
      }
      root.setJSONArray("inventory", inv);

      JSONArray jr = new JSONArray();
      for (JournalEntry e : game.journal.getDiscovered()) {
        jr.append(e.id);
      }
      root.setJSONArray("journal", jr);

      JSONArray rc = new JSONArray();
      for (Recipe r : game.crafting.getUnlockedRecipes()) {
        rc.append(r.id);
      }
      root.setJSONArray("recipesUnlocked", rc);

      JSONArray qs = new JSONArray();
      for (Quest q : game.quests.getAllQuests()) {
        JSONObject o = new JSONObject();
        o.setString("id", q.id);
        o.setString("status", q.status.toString());
        JSONArray done = new JSONArray();
        for (int i = 0; i < q.done.length; i++) {
          done.append(q.done[i]);
        }
        o.setJSONArray("done", done);
        o.setBoolean("rewardGiven", q.rewardGiven);
        qs.append(o);
      }
      root.setJSONArray("quests", qs);

      JSONArray nt = new JSONArray();
      for (NPC n : game.npcs) {
        JSONObject o = new JSONObject();
        o.setString("id", n.getId());
        o.setInt("count", n.getTimesTalked());
        nt.append(o);
      }
      root.setJSONArray("npcTalked", nt);

      JSONArray vz = new JSONArray();
      for (String z : game.visitedZones) {
        vz.append(z);
      }
      root.setJSONArray("visitedZones", vz);

      JSONArray pc = new JSONArray();
      for (Pickup pk : game.pickups) {
        if (pk.collected) pc.append(pk.getId());
      }
      root.setJSONArray("pickupsCollected", pc);

      // tulis ke file sementara, lalu gantikan file lama
      if (!saveJSONObject(root, tempPath())) {
        lastMessage = "Gagal menyimpan: file tidak bisa ditulis.";
        return false;
      }
      java.io.File tmp = new java.io.File(tempPath());
      java.io.File dest = new java.io.File(savePath());
      if (dest.exists() && !dest.delete()) {
        lastMessage = "Gagal menyimpan: file lama tidak bisa diganti.";
        return false;
      }
      if (!tmp.renameTo(dest)) {
        lastMessage = "Gagal menyimpan: file tidak bisa dipindahkan.";
        return false;
      }
      lastMessage = "Permainan disimpan.";
      return true;
    } catch (Exception e) {
      lastMessage = "Gagal menyimpan: " + e.getMessage();
      return false;
    }
  }

  // ---------- muat ----------

  boolean loadGame(Game game) {
    if (!hasSave()) {
      lastMessage = "Belum ada data simpanan.";
      return false;
    }

    JSONObject root = null;
    try {
      root = loadJSONObject(savePath());
    } catch (Exception e) {
      root = null;
    }
    if (root == null) {
      lastMessage = "Data simpanan rusak dan tidak bisa dibaca.";
      return false;
    }

    String problem;
    try {
      problem = check(root, game);
    } catch (Exception e) {
      problem = "format tidak sesuai";
    }
    if (problem != null) {
      lastMessage = "Data simpanan tidak bisa dipakai: " + problem + ".";
      return false;
    }

    apply(root, game);
    lastMessage = "Permainan dimuat.";
    return true;
  }

  JSONArray arr(JSONObject o, String key) {
    if (!o.hasKey(key)) return null;
    return o.getJSONArray(key);
  }

  QuestStatus parseStatus(String s) {
    if (s.equals("LOCKED"))    return QuestStatus.LOCKED;
    if (s.equals("AVAILABLE")) return QuestStatus.AVAILABLE;
    if (s.equals("ACTIVE"))    return QuestStatus.ACTIVE;
    if (s.equals("COMPLETED")) return QuestStatus.COMPLETED;
    return null;
  }

  NPC findNpc(Game g, String id) {
    for (NPC n : g.npcs) {
      if (n.getId().equals(id)) return n;
    }
    return null;
  }

  Pickup findPickup(Game g, String id) {
    for (Pickup p : g.pickups) {
      if (p.getId().equals(id)) return p;
    }
    return null;
  }

  // Memeriksa isi file tanpa mengubah game. Mengembalikan teks masalah, atau null bila valid.
  String check(JSONObject root, Game g) {
    if (root.getInt("version", -1) != SAVE_VERSION) {
      return "versi file simpanan tidak dikenal";
    }

    if (!root.hasKey("player")) return "bagian player hilang";
    JSONObject p = root.getJSONObject("player");
    if (!p.hasKey("x") || !p.hasKey("y")) return "posisi pemain hilang";
    float px = p.getFloat("x", -1);
    float py = p.getFloat("y", -1);
    if (px < 0 || py < 0 || px > g.world.getPixelWidth() || py > g.world.getPixelHeight()) {
      return "posisi pemain di luar peta";
    }

    JSONArray inv = arr(root, "inventory");
    if (inv == null) return "bagian inventory hilang";
    for (int i = 0; i < inv.size(); i++) {
      JSONObject o = inv.getJSONObject(i);
      String id = o.getString("id", "");
      if (g.inventory.getItemData(id) == null) return "item \"" + id + "\" tidak dikenal";
      if (o.getInt("qty", 0) <= 0) return "jumlah item \"" + id + "\" tidak valid";
    }

    JSONArray jr = arr(root, "journal");
    if (jr == null) return "bagian journal hilang";
    for (int i = 0; i < jr.size(); i++) {
      String id = jr.getString(i);
      if (!g.journal.entries.containsKey(id)) return "entry journal \"" + id + "\" tidak dikenal";
    }

    JSONArray rc = arr(root, "recipesUnlocked");
    if (rc == null) return "bagian resep hilang";
    for (int i = 0; i < rc.size(); i++) {
      String id = rc.getString(i);
      if (g.crafting.getRecipe(id) == null) return "resep \"" + id + "\" tidak dikenal";
    }

    JSONArray qs = arr(root, "quests");
    if (qs == null) return "bagian quest hilang";
    for (int i = 0; i < qs.size(); i++) {
      JSONObject o = qs.getJSONObject(i);
      String id = o.getString("id", "");
      Quest q = g.quests.getQuest(id);
      if (q == null) return "quest \"" + id + "\" tidak dikenal";
      if (parseStatus(o.getString("status", "")) == null) return "status quest \"" + id + "\" tidak dikenal";
      JSONArray done = arr(o, "done");
      if (done == null || done.size() != q.done.length) return "objective quest \"" + id + "\" tidak cocok";
      for (int k = 0; k < done.size(); k++) {
        done.getBoolean(k);
      }
    }

    JSONArray nt = arr(root, "npcTalked");
    if (nt == null) return "bagian NPC hilang";
    for (int i = 0; i < nt.size(); i++) {
      JSONObject o = nt.getJSONObject(i);
      String id = o.getString("id", "");
      if (findNpc(g, id) == null) return "NPC \"" + id + "\" tidak dikenal";
      if (o.getInt("count", -1) < 0) return "data NPC \"" + id + "\" tidak valid";
    }

    JSONArray vz = arr(root, "visitedZones");
    if (vz == null) return "bagian zona hilang";
    for (int i = 0; i < vz.size(); i++) {
      String id = vz.getString(i);
      if (g.world.getZone(id) == null) return "zona \"" + id + "\" tidak dikenal";
    }

    JSONArray pc = arr(root, "pickupsCollected");
    if (pc == null) return "bagian benda hilang";
    for (int i = 0; i < pc.size(); i++) {
      String id = pc.getString(i);
      if (findPickup(g, id) == null) return "benda \"" + id + "\" tidak dikenal";
    }

    return null;
  }

  // Menerapkan isi file yang SUDAH lolos check().
  void apply(JSONObject root, Game g) {
    // inventory
    g.inventory.items.clear();
    JSONArray inv = root.getJSONArray("inventory");
    for (int i = 0; i < inv.size(); i++) {
      JSONObject o = inv.getJSONObject(i);
      g.inventory.addItem(o.getString("id", ""), o.getInt("qty", 0));
    }

    // journal
    for (JournalEntry e : g.journal.getAll()) {
      e.discovered = false;
    }
    JSONArray jr = root.getJSONArray("journal");
    for (int i = 0; i < jr.size(); i++) {
      g.journal.discover(jr.getString(i));
    }

    // resep
    for (Recipe r : g.crafting.recipes.values()) {
      r.unlocked = false;
    }
    JSONArray rc = root.getJSONArray("recipesUnlocked");
    for (int i = 0; i < rc.size(); i++) {
      g.crafting.getRecipe(rc.getString(i)).unlocked = true;
    }

    // quest
    JSONArray qs = root.getJSONArray("quests");
    for (int i = 0; i < qs.size(); i++) {
      JSONObject o = qs.getJSONObject(i);
      Quest q = g.quests.getQuest(o.getString("id", ""));
      q.status = parseStatus(o.getString("status", ""));
      JSONArray done = o.getJSONArray("done");
      for (int k = 0; k < q.done.length; k++) {
        q.done[k] = done.getBoolean(k);
      }
      q.rewardGiven = o.getBoolean("rewardGiven", false);
    }

    // NPC
    for (NPC n : g.npcs) {
      n.timesTalked = 0;
    }
    JSONArray nt = root.getJSONArray("npcTalked");
    for (int i = 0; i < nt.size(); i++) {
      JSONObject o = nt.getJSONObject(i);
      findNpc(g, o.getString("id", "")).timesTalked = o.getInt("count", 0);
    }

    // zona yang pernah dimasuki
    g.visitedZones.clear();
    JSONArray vz = root.getJSONArray("visitedZones");
    for (int i = 0; i < vz.size(); i++) {
      g.visitedZones.add(vz.getString(i));
    }

    // benda yang sudah diambil
    for (Pickup pk : g.pickups) {
      pk.collected = false;
    }
    JSONArray pc = root.getJSONArray("pickupsCollected");
    for (int i = 0; i < pc.size(); i++) {
      findPickup(g, pc.getString(i)).collected = true;
    }

    // posisi pemain (bila tile terhalang, mulai dari titik awal peta)
    JSONObject p = root.getJSONObject("player");
    float px = p.getFloat("x", 0);
    float py = p.getFloat("y", 0);
    if (g.world.isBlockedPx(px, py)) {
      px = g.world.getStartX();
      py = g.world.getStartY();
    }
    g.player.setPosition(px, py);

    // kembali ke permainan
    g.dialogue.close();
    g.state = GameState.PLAYING;
    g.keyUp = false;
    g.keyDown = false;
    g.keyLeft = false;
    g.keyRight = false;
    g.craftSelected = 0;
    g.ui.resetScroll();
  }
}

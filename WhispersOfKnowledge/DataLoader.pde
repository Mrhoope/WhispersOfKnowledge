// DataLoader.pde
// Memuat semua konten permainan dari file JSON di folder data/. (Anggota 1)
// Format file dijelaskan di docs/DATA_FORMAT.md.
//
// Prinsip: file yang salah TIDAK membuat game crash. Setiap masalah dicatat
// sebagai pesan di daftar `errors` dan ditampilkan di layar (kotak merah),
// lalu game tetap berjalan dengan data yang berhasil dimuat.

class DataLoader {
  ArrayList<String> errors = new ArrayList<String>();

  // ---------- pembaca dasar ----------

  JSONObject readJson(String path) {
    try {
      JSONObject o = loadJSONObject(path);
      if (o == null) {
        errors.add(path + ": file tidak ditemukan atau kosong.");
      }
      return o;
    } catch (Exception e) {
      errors.add(path + ": tidak bisa dibaca (" + e.getMessage() + "). Periksa tanda koma, kurung, dan kutip.");
      return null;
    }
  }

  // Membaca file yang isinya {"kunci": [ ... ]} dan mengembalikan array itu.
  JSONArray readList(String path, String key) {
    JSONObject root = readJson(path);
    if (root == null) return null;
    if (!root.hasKey(key)) {
      errors.add(path + ": kunci \"" + key + "\" tidak ada.");
      return null;
    }
    return root.getJSONArray(key);
  }

  String[] readStringArray(JSONObject o, String key) {
    if (!o.hasKey(key)) return new String[0];
    JSONArray a = o.getJSONArray(key);
    String[] result = new String[a.size()];
    for (int i = 0; i < a.size(); i++) {
      result[i] = a.getString(i);
    }
    return result;
  }

  // ---------- pemuatan ----------

  // Memuat semuanya ke dalam Game. Urutan penting: dialog sebelum NPC, item sebelum validasi.
  void loadAll(Game g) {
    try { loadMap(g); }       catch (Exception e) { errors.add("Peta: " + e.getMessage()); }
    try { loadItems(g); }     catch (Exception e) { errors.add("items.json: " + e.getMessage()); }
    try { loadRecipes(g); }   catch (Exception e) { errors.add("recipes.json: " + e.getMessage()); }
    try { loadJournal(g); }   catch (Exception e) { errors.add("journal.json: " + e.getMessage()); }
    try { loadQuests(g); }    catch (Exception e) { errors.add("quests.json: " + e.getMessage()); }
    try { loadDialogues(g); } catch (Exception e) { errors.add("dialogues.json: " + e.getMessage()); }
    try { loadNpcs(g); }      catch (Exception e) { errors.add("npcs.json: " + e.getMessage()); }
    try { loadPickups(g); }   catch (Exception e) { errors.add("pickups.json: " + e.getMessage()); }
    try { validate(g); }      catch (Exception e) { errors.add("Validasi: " + e.getMessage()); }

    for (String msg : errors) {
      println("[DATA] " + msg);
    }
    g.dataErrors.addAll(errors);
  }

  void loadMap(Game g) {
    JSONObject json = readJson("maps/greenhaven.json");
    if (json == null) {
      errors.add("Peta cadangan (placeholder) dipakai.");
      return;
    }
    if (!g.world.loadFromJson(json, errors)) {
      errors.add("Peta cadangan (placeholder) dipakai.");
    }
  }

  void loadItems(Game g) {
    JSONArray list = readList("game-data/items.json", "items");
    if (list == null) return;
    for (int i = 0; i < list.size(); i++) {
      JSONObject o = list.getJSONObject(i);
      String id = o.getString("id", "");
      if (id.length() == 0) {
        errors.add("items.json: item ke-" + i + " tidak punya id.");
        continue;
      }
      g.inventory.registerItem(new ItemData(id, o.getString("name", id),
        o.getString("description", ""), o.getString("category", "Materials"),
        o.getString("icon", "")));
    }
  }

  void loadRecipes(Game g) {
    JSONArray list = readList("game-data/recipes.json", "recipes");
    if (list == null) return;
    for (int i = 0; i < list.size(); i++) {
      JSONObject o = list.getJSONObject(i);
      String id = o.getString("id", "");
      if (id.length() == 0) {
        errors.add("recipes.json: resep ke-" + i + " tidak punya id.");
        continue;
      }
      JSONArray ing = o.getJSONArray("ingredients");
      String[] ids = new String[ing.size()];
      int[] qty = new int[ing.size()];
      for (int k = 0; k < ing.size(); k++) {
        JSONObject c = ing.getJSONObject(k);
        ids[k] = c.getString("id", "");
        qty[k] = c.getInt("qty", 1);
      }
      JSONObject out = o.getJSONObject("output");
      Recipe r = new Recipe(id, o.getString("name", id), ids, qty,
        out.getString("id", ""), out.getInt("qty", 1));
      r.unlocked = o.getBoolean("unlocked", true);
      g.crafting.addRecipe(r);
    }
  }

  void loadJournal(Game g) {
    JSONArray list = readList("game-data/journal.json", "entries");
    if (list == null) return;
    for (int i = 0; i < list.size(); i++) {
      JSONObject o = list.getJSONObject(i);
      String id = o.getString("id", "");
      if (id.length() == 0) {
        errors.add("journal.json: entry ke-" + i + " tidak punya id.");
        continue;
      }
      g.journal.registerEntry(new JournalEntry(id, o.getString("title", id),
        o.getString("category", "Biology"), o.getString("description", ""),
        o.getString("learningInfo", "")));
    }
  }

  void loadQuests(Game g) {
    JSONArray list = readList("game-data/quests.json", "quests");
    if (list == null) return;
    for (int i = 0; i < list.size(); i++) {
      JSONObject o = list.getJSONObject(i);
      String id = o.getString("id", "");
      if (id.length() == 0) {
        errors.add("quests.json: quest ke-" + i + " tidak punya id.");
        continue;
      }

      JSONArray objs = o.getJSONArray("objectives");
      String[] texts = new String[objs.size()];
      Trigger[] triggers = new Trigger[objs.size()];
      for (int k = 0; k < objs.size(); k++) {
        JSONObject ob = objs.getJSONObject(k);
        texts[k] = ob.getString("text", "(tanpa teks)");
        if (ob.hasKey("trigger")) {
          triggers[k] = parseTrigger(ob.getJSONObject("trigger"), id + " objective " + k);
        }
      }

      Quest q = new Quest(id, o.getString("title", id), o.getString("description", ""), texts);
      q.triggers = triggers;

      String statusName = o.getString("status", "LOCKED");
      try {
        q.status = QuestStatus.valueOf(statusName);
      } catch (Exception e) {
        errors.add("quests.json: quest " + id + " punya status \"" + statusName
          + "\" yang tidak dikenal (pakai LOCKED, AVAILABLE, ACTIVE, atau COMPLETED).");
      }

      if (o.hasKey("rewards")) {
        q.reward = parseReward(o.getJSONObject("rewards"));
      }
      g.quests.addQuest(q);
    }
  }

  Trigger parseTrigger(JSONObject t, String where) {
    Trigger tr = new Trigger();
    tr.type = t.getString("type", "manual");

    if (tr.type.equals("manual")) {
      return null;
    } else if (tr.type.equals("enter_zone")) {
      tr.zoneId = t.getString("zone", "");
    } else if (tr.type.equals("discover")) {
      tr.discoverIds = readStringArray(t, "ids");
    } else if (tr.type.equals("have_items")) {
      JSONArray items = t.getJSONArray("items");
      tr.itemIds = new String[items.size()];
      tr.itemQty = new int[items.size()];
      for (int k = 0; k < items.size(); k++) {
        JSONObject c = items.getJSONObject(k);
        tr.itemIds[k] = c.getString("id", "");
        tr.itemQty[k] = c.getInt("qty", 1);
      }
      tr.orDiscover = t.getString("orDiscover", "");
    } else {
      errors.add("quests.json: " + where + " memakai trigger \"" + tr.type
        + "\" yang tidak dikenal (pakai manual, enter_zone, discover, atau have_items).");
      return null;
    }
    return tr;
  }

  QuestReward parseReward(JSONObject r) {
    QuestReward reward = new QuestReward();
    if (r.hasKey("items")) {
      JSONArray items = r.getJSONArray("items");
      reward.itemIds = new String[items.size()];
      reward.itemQty = new int[items.size()];
      for (int k = 0; k < items.size(); k++) {
        JSONObject c = items.getJSONObject(k);
        reward.itemIds[k] = c.getString("id", "");
        reward.itemQty[k] = c.getInt("qty", 1);
      }
    }
    reward.recipeIds = readStringArray(r, "recipes");
    reward.journalIds = readStringArray(r, "journal");
    return reward;
  }

  void loadDialogues(Game g) {
    JSONArray sets = readList("game-data/dialogues.json", "sets");
    if (sets == null) return;
    for (int i = 0; i < sets.size(); i++) {
      JSONObject s = sets.getJSONObject(i);
      String id = s.getString("id", "");
      if (id.length() == 0) {
        errors.add("dialogues.json: set ke-" + i + " tidak punya id.");
        continue;
      }
      JSONArray lines = s.getJSONArray("lines");
      DialogueLine[] result = new DialogueLine[lines.size()];
      for (int k = 0; k < lines.size(); k++) {
        JSONObject ln = lines.getJSONObject(k);
        String text = ln.getString("text", "");
        String action = ln.getString("action", "");
        if (ln.hasKey("choices")) {
          JSONArray ch = ln.getJSONArray("choices");
          String[] labels = new String[ch.size()];
          int[] next = new int[ch.size()];
          for (int c = 0; c < ch.size(); c++) {
            JSONObject co = ch.getJSONObject(c);
            labels[c] = co.getString("text", "...");
            next[c] = co.getInt("next", -1);
          }
          result[k] = new DialogueLine(text, labels, next);
          result[k].action = action;
        } else {
          result[k] = new DialogueLine(text, ln.getInt("next", -1), action);
        }
      }
      g.dialogueSets.put(id, result);
    }
  }

  void loadNpcs(Game g) {
    JSONArray list = readList("game-data/npcs.json", "npcs");
    if (list == null) return;
    for (int i = 0; i < list.size(); i++) {
      JSONObject o = list.getJSONObject(i);
      String id = o.getString("id", "");
      if (id.length() == 0) {
        errors.add("npcs.json: NPC ke-" + i + " tidak punya id.");
        continue;
      }
      String dialogueId = o.getString("dialogue", "");
      DialogueLine[] lines = g.dialogueSets.get(dialogueId);
      if (lines == null) {
        errors.add("npcs.json: NPC " + id + " memakai dialog \"" + dialogueId + "\" yang tidak ada di dialogues.json.");
        lines = new DialogueLine[0];
      }
      NPC n = new NPC(id, o.getString("name", id),
        o.getInt("tileX", 0) * TILE_SIZE + TILE_SIZE / 2,
        o.getInt("tileY", 0) * TILE_SIZE + TILE_SIZE / 2, lines);
      if (o.hasKey("rules")) {
        JSONArray rules = o.getJSONArray("rules");
        for (int k = 0; k < rules.size(); k++) {
          JSONObject r = rules.getJSONObject(k);
          n.addRule(new DialogueRule(r.getString("quest", ""), r.getString("state", ""),
            r.getString("dialogue", "")));
        }
      }
      g.npcs.add(n);
    }
  }

  void loadPickups(Game g) {
    JSONArray list = readList("game-data/pickups.json", "pickups");
    if (list == null) return;
    for (int i = 0; i < list.size(); i++) {
      JSONObject o = list.getJSONObject(i);
      String id = o.getString("id", "");
      if (id.length() == 0) {
        errors.add("pickups.json: pickup ke-" + i + " tidak punya id.");
        continue;
      }
      int r = 200;
      int gr = 200;
      int b = 200;
      if (o.hasKey("color")) {
        JSONArray c = o.getJSONArray("color");
        r = c.getInt(0);
        gr = c.getInt(1);
        b = c.getInt(2);
      }
      g.pickups.add(new Pickup(id, o.getString("name", id), o.getString("item", ""),
        o.getInt("qty", 1),
        o.getInt("tileX", 0) * TILE_SIZE + TILE_SIZE / 2,
        o.getInt("tileY", 0) * TILE_SIZE + TILE_SIZE / 2,
        o.getBoolean("repeatable", false), o.getString("journal", ""), r, gr, b));
    }
  }

  // ---------- validasi referensi antar file ----------

  boolean hasItem(Game g, String id)    { return g.inventory.getItemData(id) != null; }
  boolean hasJournal(Game g, String id) { return g.journal.entries.containsKey(id); }

  void validate(Game g) {
    for (Recipe r : g.crafting.recipes.values()) {
      for (String ing : r.ingredientIds) {
        if (!hasItem(g, ing)) errors.add("recipes.json: resep " + r.id + " memakai bahan \"" + ing + "\" yang tidak ada di items.json.");
      }
      if (!hasItem(g, r.outputId)) errors.add("recipes.json: resep " + r.id + " menghasilkan \"" + r.outputId + "\" yang tidak ada di items.json.");
    }

    for (Pickup p : g.pickups) {
      if (!hasItem(g, p.getItemId())) errors.add("pickups.json: " + p.getId() + " memakai item \"" + p.getItemId() + "\" yang tidak ada di items.json.");
      if (p.getJournalId().length() > 0 && !hasJournal(g, p.getJournalId())) errors.add("pickups.json: " + p.getId() + " memakai entry journal \"" + p.getJournalId() + "\" yang tidak ada di journal.json.");
      if (g.world.isBlockedPx(p.getX(), p.getY())) errors.add("pickups.json: " + p.getId() + " berada di tile yang menghalangi.");
    }

    for (Quest q : g.quests.getAllQuests()) {
      for (int k = 0; k < q.triggers.length; k++) {
        Trigger t = q.triggers[k];
        if (t == null) continue;
        String where = "quests.json: " + q.id + " objective " + k + ": ";
        if (t.type.equals("enter_zone") && g.world.getZone(t.zoneId) == null) errors.add(where + "zona \"" + t.zoneId + "\" tidak ada di peta.");
        for (String d : t.discoverIds) {
          if (!hasJournal(g, d)) errors.add(where + "entry journal \"" + d + "\" tidak ada.");
        }
        for (String it : t.itemIds) {
          if (!hasItem(g, it)) errors.add(where + "item \"" + it + "\" tidak ada.");
        }
        if (t.orDiscover.length() > 0 && !hasJournal(g, t.orDiscover)) errors.add(where + "entry journal \"" + t.orDiscover + "\" tidak ada.");
      }
      for (String it : q.reward.itemIds) {
        if (!hasItem(g, it)) errors.add("quests.json: reward " + q.id + " memakai item \"" + it + "\" yang tidak ada.");
      }
      for (String rc : q.reward.recipeIds) {
        if (g.crafting.getRecipe(rc) == null) errors.add("quests.json: reward " + q.id + " memakai resep \"" + rc + "\" yang tidak ada.");
      }
      for (String j : q.reward.journalIds) {
        if (!hasJournal(g, j)) errors.add("quests.json: reward " + q.id + " memakai entry journal \"" + j + "\" yang tidak ada.");
      }
    }

    for (NPC n : g.npcs) {
      for (DialogueRule r : n.getRules()) {
        if (g.quests.getQuest(r.questId) == null) errors.add("npcs.json: aturan NPC " + n.getId() + " memakai quest \"" + r.questId + "\" yang tidak ada.");
        if (!g.dialogueSets.containsKey(r.dialogueId)) errors.add("npcs.json: aturan NPC " + n.getId() + " memakai dialog \"" + r.dialogueId + "\" yang tidak ada.");
        if (!(r.state.equals("locked") || r.state.equals("available") || r.state.equals("active")
           || r.state.equals("ready") || r.state.equals("completed"))) {
          errors.add("npcs.json: aturan NPC " + n.getId() + " memakai state \"" + r.state + "\" yang tidak dikenal.");
        }
      }
    }

    for (String setId : g.dialogueSets.keySet()) {
      DialogueLine[] lines = g.dialogueSets.get(setId);
      for (int k = 0; k < lines.length; k++) {
        String where = "dialogues.json: " + setId + " baris " + k + ": ";
        DialogueLine ln = lines[k];
        if (ln.hasChoices()) {
          for (int c = 0; c < ln.choiceNext.length; c++) {
            checkNext(where + "pilihan " + c, ln.choiceNext[c], lines.length);
          }
        } else {
          checkNext(where, ln.next, lines.length);
        }
        if (ln.action != null && ln.action.length() > 0) {
          for (String part : split(ln.action, ';')) {
            validateAction(g, where, part.trim());
          }
        }
      }
    }
  }

  void checkNext(String where, int next, int count) {
    if (next < -1 || next >= count) {
      errors.add(where + " menunjuk baris " + next + ", padahal baris yang ada 0 sampai " + (count - 1) + " (atau -1 untuk selesai).");
    }
  }

  boolean isNumber(String s) {
    return s != null && s.matches("\\d+");
  }

  void validateAction(Game g, String where, String command) {
    if (command.length() == 0) return;
    String[] p = split(command, ':');
    String c = p[0];

    if (c.equals("start_quest") || c.equals("finish_quest")) {
      if (p.length < 2 || g.quests.getQuest(p[1]) == null) errors.add(where + "aksi \"" + command + "\": quest tidak ada.");
    } else if (c.equals("objective")) {
      Quest q = (p.length >= 3) ? g.quests.getQuest(p[1]) : null;
      if (q == null) errors.add(where + "aksi \"" + command + "\": quest tidak ada atau format salah (objective:idQuest:nomor).");
      else if (!isNumber(p[2]) || Integer.parseInt(p[2]) >= q.objectives.length) errors.add(where + "aksi \"" + command + "\": nomor objective di luar jangkauan.");
    } else if (c.equals("give_item")) {
      if (p.length < 3 || !hasItem(g, p[1])) errors.add(where + "aksi \"" + command + "\": item tidak ada atau format salah (give_item:idItem:jumlah).");
      else if (!isNumber(p[2])) errors.add(where + "aksi \"" + command + "\": jumlah harus angka.");
    } else if (c.equals("discover")) {
      if (p.length < 2 || !hasJournal(g, p[1])) errors.add(where + "aksi \"" + command + "\": entry journal tidak ada.");
    } else {
      errors.add(where + "aksi \"" + command + "\" tidak dikenal.");
    }
  }
}

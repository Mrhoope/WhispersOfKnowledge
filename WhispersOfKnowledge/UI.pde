// UI.pde
// Semua tampilan antarmuka (HUD, dialog, inventory, journal, quest log, crafting, pause). (Anggota 3)
// UI hanya MENGGAMBAR. Data dan logika tetap di class masing-masing.
// Belum ada: Main Menu (Fase 6).

class UI {
  // notifikasi bertumpuk (maksimal 3 sekaligus)
  ArrayList<String> notes = new ArrayList<String>();
  ArrayList<Integer> notesUntil = new ArrayList<Integer>();
  final int MAX_NOTES = 3;

  // gulir untuk panel yang isinya panjang
  int scroll = 0;
  final int VISIBLE_ROWS = 15;

  void showNotification(String message) {
    notes.add(message);
    notesUntil.add(millis() + 3500);
    while (notes.size() > MAX_NOTES) {
      notes.remove(0);
      notesUntil.remove(0);
    }
  }

  void resetScroll() {
    scroll = 0;
  }

  void scrollBy(int delta) {
    scroll = max(0, scroll + delta);   // batas atas dijaga saat menggambar panel
  }

  // ---------- HUD ----------

  // prompt: teks seperti "[E] Bicara dengan X", atau null jika tidak ada yang bisa diinteraksi
  void renderHud(QuestManager quests, String prompt) {
    noStroke();
    fill(0, 150);
    rect(0, 0, width, 26);
    fill(255);
    textAlign(LEFT, CENTER);
    textSize(13);
    text("WASD: gerak | E: interaksi | I: Inventory | J: Journal | Q: Quest | C: Crafting | ESC: Pause", 10, 13);

    // quest aktif pertama dan tujuan berikutnya
    for (Quest q : quests.getAllQuests()) {
      if (q.status == QuestStatus.ACTIVE) {
        fill(255, 230, 140);
        textAlign(RIGHT, CENTER);
        text(q.title, width - 10, 13);

        int next = nextObjective(q);
        if (next >= 0) {
          String line = "Tujuan: " + q.objectives[next];
          float w = textWidth(line) + 20;
          fill(0, 150);
          rect(10, 32, w, 24, 6);
          fill(255, 230, 140);
          textAlign(LEFT, CENTER);
          text(line, 20, 44);
        }
        break;
      }
    }

    // prompt interaksi
    if (prompt != null) {
      textSize(14);
      float w = textWidth(prompt) + 30;
      fill(0, 170);
      rect(width / 2 - w / 2, height - 60, w, 30, 6);
      fill(255);
      textAlign(CENTER, CENTER);
      text(prompt, width / 2, height - 45);
    }
  }

  // Indeks objective pertama yang belum selesai, atau -1 jika semua selesai.
  int nextObjective(Quest q) {
    for (int i = 0; i < q.done.length; i++) {
      if (!q.done[i]) return i;
    }
    return -1;
  }

  void renderNotification() {
    for (int i = notes.size() - 1; i >= 0; i--) {
      if (millis() >= notesUntil.get(i)) {
        notes.remove(i);
        notesUntil.remove(i);
      }
    }
    noStroke();
    textSize(13);
    textAlign(CENTER, CENTER);
    for (int i = 0; i < notes.size(); i++) {
      float y = 80 + i * 34;
      fill(0, 190);
      rect(width / 2 - 230, y, 460, 28, 6);
      fill(180, 255, 180);
      text(notes.get(i), width / 2, y + 14);
    }
  }

  // ---------- Dialog ----------

  void renderDialogue(DialogueSystem dialogue) {
    DialogueLine line = dialogue.getCurrentLine();
    if (line == null) return;

    int nChoices = line.choices.length;
    float boxH = 110 + nChoices * 24;
    float boxY = height - boxH - 30;

    fill(0, 210);
    stroke(255);
    rect(40, boxY, width - 80, boxH, 8);
    noStroke();

    textAlign(LEFT, TOP);
    textSize(15);
    fill(255, 230, 140);
    text(dialogue.getSpeakerName(), 60, boxY + 12);
    fill(255);
    text(line.text, 60, boxY + 38, width - 120, 60);

    if (nChoices > 0) {
      for (int i = 0; i < nChoices; i++) {
        float cy = boxY + 100 + i * 24;
        if (i == dialogue.getSelectedChoice()) {
          fill(255, 230, 140);
          text("> " + line.choices[i], 70, cy);
        } else {
          fill(200);
          text("   " + line.choices[i], 70, cy);
        }
      }
      fill(160);
      textAlign(RIGHT, BOTTOM);
      textSize(12);
      text("W/S pilih  |  E konfirmasi", width - 55, boxY + boxH - 10);
    } else {
      fill(160);
      textAlign(RIGHT, BOTTOM);
      textSize(12);
      text("[E] lanjut", width - 55, boxY + boxH - 10);
    }
  }

  // ---------- Layar penuh ----------

  void renderInventory(Inventory inventory) {
    textSize(14);
    float maxW = width - 290;
    ArrayList<String> rows = new ArrayList<String>();
    for (Map.Entry<String, Integer> e : inventory.getAll().entrySet()) {
      ItemData d = inventory.getItemData(e.getKey());
      if (d != null) {
        rows.add(d.name + "  x" + e.getValue() + "   (" + d.category + ")");
        addWrapped(rows, d.description, "     ", maxW);
      } else {
        rows.add(e.getKey() + "  x" + e.getValue());
      }
    }
    if (rows.isEmpty()) rows.add("(kosong)");
    drawPanel("Inventory", rows, "I: tutup");
  }

  void renderJournal(Journal journal) {
    textSize(14);
    float maxW = width - 290;
    ArrayList<String> rows = new ArrayList<String>();
    for (JournalEntry e : journal.getDiscovered()) {
      rows.add("[" + e.category + "] " + e.title);
      addWrapped(rows, e.description, "     ", maxW);
      addWrapped(rows, "Pelajaran: " + e.learningInfo, "     ", maxW);
    }
    if (rows.isEmpty()) rows.add("(belum ada pengetahuan yang ditemukan)");
    drawPanel("Journal  (" + journal.getDiscovered().size() + "/" + journal.getAll().size() + " ditemukan)",
              rows, "J: tutup");
  }

  void renderQuestLog(QuestManager quests) {
    textSize(14);
    float maxW = width - 290;
    ArrayList<String> rows = new ArrayList<String>();
    for (Quest q : quests.getAllQuests()) {
      if (q.status == QuestStatus.LOCKED) continue;
      rows.add(q.title + "  [" + q.status + "]");
      addWrapped(rows, q.description, "     ", maxW);
      if (q.status == QuestStatus.ACTIVE || q.status == QuestStatus.COMPLETED) {
        for (int i = 0; i < q.objectives.length; i++) {
          addWrapped(rows, (q.done[i] ? "[x] " : "[ ] ") + q.objectives[i], "     ", maxW);
        }
      }
    }
    if (rows.isEmpty()) rows.add("(belum ada quest)");
    drawPanel("Quest Log", rows, "Q: tutup");
  }

  // selected = indeks resep yang dipilih (dalam daftar resep terbuka)
  void renderCrafting(CraftingSystem crafting, Inventory inv, int selected) {
    ArrayList<Recipe> list = crafting.getUnlockedRecipes();
    drawFrame("Crafting");

    textAlign(LEFT, TOP);
    float y = 118;
    for (int i = 0; i < list.size(); i++) {
      Recipe r = list.get(i);
      boolean can = crafting.canCraft(r.id, inv);
      boolean sel = (i == selected);

      textSize(16);
      fill(sel ? color(255, 230, 140) : color(255));
      text((sel ? "> " : "   ") + r.name + (can ? "     [bisa dibuat]" : ""), 145, y);

      textSize(14);
      fill(can ? color(180, 255, 180) : color(200));
      String need = "Bahan: ";
      for (int k = 0; k < r.ingredientIds.length; k++) {
        need += itemName(inv, r.ingredientIds[k]) + " (" + inv.getQuantity(r.ingredientIds[k])
              + "/" + r.ingredientQty[k] + ")";
        if (k < r.ingredientIds.length - 1) need += ", ";
      }
      text(need, 170, y + 24);
      fill(200);
      text("Hasil: " + itemName(inv, r.outputId) + " x" + r.outputQty, 170, y + 46);
      y += 84;
    }
    if (list.isEmpty()) {
      fill(200);
      textSize(14);
      text("(belum ada resep)", 145, y);
    }
    drawFooter("W/S pilih  |  E buat  |  C tutup");
  }

  void renderPause() {
    ArrayList<String> rows = new ArrayList<String>();
    rows.add("Permainan dijeda.");
    rows.add("Tekan ESC untuk melanjutkan.");
    drawPanel("Pause", rows, "ESC: lanjut");
  }

  // ---------- Pembantu ----------

  String itemName(Inventory inv, String id) {
    ItemData d = inv.getItemData(id);
    return (d != null) ? d.name : id;
  }

  // Memecah teks panjang menjadi beberapa baris sesuai lebar. textSize harus sudah diatur.
  void addWrapped(ArrayList<String> rows, String s, String indent, float maxW) {
    String[] words = split(s, ' ');
    String cur = indent;
    boolean first = true;
    for (String w : words) {
      String test = first ? cur + w : cur + " " + w;
      if (!first && textWidth(test) > maxW) {
        rows.add(cur);
        cur = indent + "   " + w;
      } else {
        cur = test;
      }
      first = false;
    }
    rows.add(cur);
  }

  // Bingkai panel: latar, judul.
  void drawFrame(String title) {
    fill(0, 220);
    stroke(255);
    rect(120, 60, width - 240, height - 120, 10);
    noStroke();
    fill(255, 230, 140);
    textAlign(LEFT, TOP);
    textSize(18);
    text(title, 145, 78);
  }

  void drawFooter(String hint) {
    fill(160);
    textSize(12);
    textAlign(RIGHT, BOTTOM);
    text(hint, width - 145, height - 72);
  }

  // Panel berisi baris teks yang bisa digulir dengan W/S.
  void drawPanel(String title, ArrayList<String> rows, String hint) {
    int maxScroll = max(0, rows.size() - VISIBLE_ROWS);
    if (scroll > maxScroll) scroll = maxScroll;

    drawFrame(title);
    fill(255);
    textSize(14);
    textAlign(LEFT, TOP);
    for (int i = 0; i < VISIBLE_ROWS && scroll + i < rows.size(); i++) {
      text(rows.get(scroll + i), 145, 118 + i * 22);
    }
    drawFooter(maxScroll > 0 ? hint + "  |  W/S gulir" : hint);
  }
}

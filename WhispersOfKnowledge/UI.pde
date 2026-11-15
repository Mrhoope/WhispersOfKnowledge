// UI.pde
// Semua tampilan antarmuka (HUD, dialog, inventory, journal, quest log, crafting, pause). (Anggota 3)
// UI hanya MENGGAMBAR. Data dan logika tetap di class masing-masing.
// Palet hangat dan bentuk pixel sederhana menjaga nuansa cozy tanpa aset tambahan.

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
    fill(36, 57, 48, 235);
    rect(0, 0, width, 34);
    fill(184, 137, 78);
    rect(0, 32, width, 2);

    textSize(12);
    textAlign(LEFT, CENTER);
    fill(242, 229, 193);
    text("WASD GERAK   E INTERAKSI   I TAS   J JURNAL   Q MISI   C RAKIT   ESC JEDA", 14, 17);

    // quest aktif pertama dan tujuan berikutnya
    for (Quest q : quests.getAllQuests()) {
      if (q.status == QuestStatus.ACTIVE) {
        textAlign(RIGHT, CENTER);
        fill(247, 210, 135);
        text(q.title, width - 16, 17);

        int next = nextObjective(q);
        if (next >= 0) {
          String line = "Tujuan: " + q.objectives[next];
          float w = min(width - 28, textWidth(line) + 28);
          fill(39, 61, 48, 235);
          stroke(191, 151, 92);
          rect(12, 42, w, 28, 5);
          noStroke();
          fill(247, 225, 175);
          textAlign(LEFT, CENTER);
          text(line, 24, 56);
        }
        break;
      }
    }

    // prompt interaksi
    if (prompt != null) {
      textSize(13);
      float w = textWidth(prompt) + 42;
      fill(35, 54, 43, 235);
      stroke(218, 180, 112);
      rect(width / 2 - w / 2, height - 58, w, 32, 6);
      noStroke();
      fill(248, 231, 190);
      textAlign(CENTER, CENTER);
      text(prompt, width / 2, height - 42);
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
      float y = 82 + i * 36;
      fill(34, 54, 43, 238);
      stroke(197, 155, 91);
      rect(width / 2 - 230, y, 460, 30, 5);
      noStroke();
      fill(247, 226, 176);
      text(notes.get(i), width / 2, y + 15);
    }
  }

  // Kotak merah berisi masalah pemuatan data (maksimal 4 baris), selama masih ada masalah.
  void renderDataErrors(ArrayList<String> errors) {
    if (errors == null || errors.isEmpty()) return;
    int shown = min(4, errors.size());
    float h = 26 + shown * 18;
    noStroke();
    fill(90, 0, 0, 220);
    rect(10, height - h - 10, width - 20, h, 6);
    fill(255, 200, 200);
    textSize(12);
    textAlign(LEFT, TOP);
    text("Masalah data (" + errors.size() + "). Periksa file di folder data/:", 20, height - h - 4);
    for (int i = 0; i < shown; i++) {
      text("- " + errors.get(i), 20, height - h + 16 + i * 18);
    }
  }

  // ---------- Dialog ----------

  void renderDialogue(DialogueSystem dialogue) {
    DialogueLine line = dialogue.getCurrentLine();
    if (line == null) return;

    int nChoices = line.choices.length;
    float boxH = (nChoices == 0) ? 108 : 124 + nChoices * 25;
    float boxY = height - boxH - 24;
    float boxX = 44;
    float boxW = width - 88;

    drawOverlay();
    fill(22, 38, 32);
    noStroke();
    rect(boxX - 5, boxY - 5, boxW + 10, boxH + 10, 9);
    fill(122, 85, 51);
    rect(boxX, boxY, boxW, boxH, 7);
    fill(235, 220, 181);
    rect(boxX + 4, boxY + 4, boxW - 8, boxH - 8, 5);
    fill(54, 83, 60);
    rect(boxX + 4, boxY + 4, boxW - 8, 34, 5);

    textAlign(LEFT, TOP);
    textSize(16);
    fill(250, 229, 184);
    text(dialogue.getSpeakerName(), boxX + 22, boxY + 11);
    fill(55, 55, 42);
    textSize(15);
    text(line.text, boxX + 20, boxY + 51, boxW - 40, 54);

    if (nChoices > 0) {
      for (int i = 0; i < nChoices; i++) {
        float cy = boxY + 111 + i * 25;
        if (i == dialogue.getSelectedChoice()) {
          fill(67, 102, 67);
          rect(boxX + 18, cy - 3, boxW - 36, 23, 4);
          fill(255, 234, 178);
          text(">  " + line.choices[i], boxX + 30, cy);
        } else {
          fill(75, 67, 50);
          text("   " + line.choices[i], boxX + 30, cy);
        }
      }
      fill(235, 220, 181);
      textAlign(RIGHT, BOTTOM);
      textSize(12);
      text("W/S PILIH   E KONFIRMASI", boxX + boxW - 20, boxY + boxH - 12);
    } else {
      fill(235, 220, 181);
      textAlign(RIGHT, BOTTOM);
      textSize(12);
      text("E LANJUT", boxX + boxW - 20, boxY + boxH - 12);
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

    fill(213, 194, 150);
    rect(108, 126, 300, 322, 6);
    fill(68, 91, 61);
    rect(108, 126, 300, 38, 6);
    fill(249, 229, 184);
    textAlign(LEFT, CENTER);
    textSize(14);
    text("RESEP TERSEDIA", 128, 145);

    int visible = 6;
    int start = 0;
    if (selected >= visible) start = selected - visible + 1;
    for (int i = start; i < min(list.size(), start + visible); i++) {
      Recipe r = list.get(i);
      boolean can = crafting.canCraft(r.id, inv);
      boolean sel = (i == selected);
      float y = 177 + (i - start) * 42;
      if (sel) {
        fill(239, 219, 171);
        rect(118, y - 4, 280, 36, 4);
      }
      fill(can ? color(57, 83, 55) : color(116, 105, 83));
      textAlign(LEFT, CENTER);
      textSize(14);
      text((sel ? "> " : "   ") + r.name, 130, y + 5);
      if (can) {
        fill(83, 127, 74);
        textAlign(RIGHT, CENTER);
        textSize(10);
        text("SIAP", 389, y + 5);
      }
    }
    if (list.isEmpty()) {
      fill(93, 79, 57);
      textAlign(LEFT, TOP);
      textSize(14);
      text("Belum ada resep yang terbuka.", 128, 184);
    }

    fill(239, 225, 190);
    rect(428, 126, 424, 322, 6);
    fill(68, 91, 61);
    rect(428, 126, 424, 38, 6);
    fill(249, 229, 184);
    textAlign(LEFT, CENTER);
    textSize(14);
    text("BAHAN DAN HASIL", 450, 145);

    if (!list.isEmpty() && selected >= 0 && selected < list.size()) {
      Recipe r = list.get(selected);
      boolean can = crafting.canCraft(r.id, inv);
      fill(56, 69, 48);
      textAlign(LEFT, TOP);
      textSize(21);
      text(r.name, 452, 185);
      fill(119, 94, 58);
      rect(452, 218, 376, 2);
      fill(77, 70, 52);
      textSize(13);
      text("BAHAN YANG DIPERLUKAN", 452, 235);

      for (int k = 0; k < r.ingredientIds.length; k++) {
        int have = inv.getQuantity(r.ingredientIds[k]);
        int need = r.ingredientQty[k];
        fill(have >= need ? color(73, 105, 64) : color(150, 79, 57));
        textSize(14);
        text(itemName(inv, r.ingredientIds[k]) + "    " + have + " / " + need, 460, 264 + k * 28);
      }

      fill(119, 94, 58);
      rect(452, 357, 376, 2);
      fill(77, 70, 52);
      textSize(13);
      text("HASIL", 452, 374);
      fill(56, 69, 48);
      textSize(15);
      text(itemName(inv, r.outputId) + "  x" + r.outputQty, 460, 399);
      fill(can ? color(65, 111, 58) : color(137, 91, 63));
      textAlign(RIGHT, BOTTOM);
      textSize(12);
      text(can ? "SIAP DIRACIK" : "BAHAN BELUM CUKUP", 828, 429);
    }
    drawFooter("W/S PILIH   E RACIK   C TUTUP");
  }

  void renderPause(boolean hasSave) {
    drawFrame("Jeda");
    textAlign(CENTER, TOP);
    fill(75, 71, 52);
    textSize(16);
    text("Petualangan sedang berhenti sejenak.", width / 2, 137);

    drawKeyCard("K", "SIMPAN PERMAINAN", "Bisa juga dengan F5 saat bermain", 168);
    drawKeyCard("L", "MUAT PERMAINAN", hasSave ? "Memuat simpanan terakhir (F9 saat bermain)"
                                                  : "Belum ada data simpanan", 244);
    drawKeyCard("M", "MENU UTAMA", "Progres yang belum disimpan akan hilang", 320);
    drawFooter("ESC LANJUT BERMAIN");
  }

  // Main Menu: Lanjutkan, Permainan Baru, Keluar.
  void renderMenu(int selected, boolean hasSave) {
    drawMenuLandscape();
    fill(19, 34, 32, 70);
    noStroke();
    rect(0, 0, width, height);

    fill(38, 58, 45, 238);
    stroke(203, 158, 91);
    rect(width / 2 - 220, 52, 440, 130, 9);
    noStroke();
    fill(237, 221, 181);
    rect(width / 2 - 214, 58, 428, 118, 6);
    fill(50, 79, 55);
    textAlign(CENTER, TOP);
    textSize(34);
    text("Whispers of Knowledge", width / 2, 79);
    fill(112, 90, 60);
    textSize(14);
    text("Jelajahi, temukan, dan rawat pengetahuan.", width / 2, 130);

    String[] labels = {"Lanjutkan", "Permainan Baru", "Keluar"};
    for (int i = 0; i < labels.length; i++) {
      boolean enabled = (i != 0) || hasSave;
      drawMenuButton(labels[i], i == selected, enabled, 214 + i * 54);
    }
    if (!hasSave) {
      fill(246, 225, 186);
      textSize(12);
      text("Belum ada data simpanan.", width / 2, 382);
    }

    fill(38, 58, 45, 230);
    stroke(203, 158, 91);
    rect(width / 2 - 150, height - 52, 300, 30, 5);
    noStroke();
    fill(246, 230, 193);
    textSize(12);
    textAlign(CENTER, BOTTOM);
    text("W / S PILIH     E KONFIRMASI", width / 2, height - 32);
  }

  void drawMenuButton(String label, boolean selected, boolean enabled, float y) {
    fill(selected ? color(67, 94, 60) : color(63, 65, 48, 230));
    stroke(selected ? color(239, 202, 125) : color(173, 140, 83));
    rect(width / 2 - 148, y, 296, 42, 6);
    noStroke();
    fill(!enabled ? color(153, 145, 124) : color(248, 231, 191));
    textAlign(CENTER, CENTER);
    textSize(18);
    text((selected ? ">  " : "") + label, width / 2, y + 21);
  }

  void drawMenuLandscape() {
    background(145, 190, 186);
    noStroke();
    fill(244, 211, 139);
    ellipse(790, 105, 54, 54);

    fill(128, 166, 152);
    rect(0, 210, width, 105);
    fill(102, 145, 129);
    rect(0, 246, 230, 72);
    rect(205, 218, 184, 100);
    rect(570, 229, 178, 90);
    rect(740, 244, 220, 80);

    fill(99, 145, 92);
    rect(0, 294, width, height - 294);
    fill(117, 157, 90);
    rect(0, 331, width, 47);
    fill(176, 150, 97);
    rect(0, 385, width, 25);
    rect(0, 431, width, 22);
    fill(196, 171, 114);
    rect(0, 391, width, 10);

    // Rumah kecil di kejauhan, digambar dengan blok agar sesuai pixel art.
    fill(99, 67, 49);
    rect(102, 278, 112, 83);
    fill(148, 88, 59);
    rect(90, 267, 137, 15);
    rect(101, 254, 111, 14);
    fill(219, 187, 127);
    rect(119, 295, 27, 24);
    rect(166, 295, 27, 24);
    fill(64, 75, 56);
    rect(145, 322, 28, 39);

    drawPixelTree(48, 293);
    drawPixelTree(830, 287);
    drawPixelTree(895, 298);

    fill(220, 207, 159);
    rect(36, 421, 24, 3);
    rect(128, 421, 24, 3);
    rect(220, 421, 24, 3);
    rect(312, 421, 24, 3);
    rect(404, 421, 24, 3);
    rect(496, 421, 24, 3);
    rect(588, 421, 24, 3);
    rect(680, 421, 24, 3);
    rect(772, 421, 24, 3);
    rect(864, 421, 24, 3);
  }

  void drawPixelTree(float x, float y) {
    noStroke();
    fill(103, 72, 48);
    rect(x + 14, y + 32, 11, 42);
    fill(53, 93, 62);
    rect(x + 3, y + 17, 33, 25);
    rect(x + 8, y + 5, 25, 20);
    rect(x, y + 25, 39, 19);
    fill(75, 121, 71);
    rect(x + 8, y + 10, 21, 12);
    rect(x + 5, y + 24, 13, 9);
  }

  void drawKeyCard(String keyLabel, String title, String detail, float y) {
    float x = 170;
    float w = width - 340;
    fill(226, 211, 174);
    stroke(151, 116, 69);
    rect(x, y, w, 62, 5);
    noStroke();
    fill(66, 91, 59);
    rect(x + 12, y + 9, 44, 44, 5);
    fill(250, 230, 186);
    textAlign(CENTER, CENTER);
    textSize(21);
    text(keyLabel, x + 34, y + 31);
    fill(57, 70, 48);
    textAlign(LEFT, TOP);
    textSize(14);
    text(title, x + 72, y + 11);
    fill(104, 88, 62);
    textSize(12);
    text(detail, x + 72, y + 34);
  }

  void drawOverlay() {
    noStroke();
    fill(19, 29, 27, 150);
    rect(0, 0, width, height);
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
    drawOverlay();
    noStroke();
    fill(21, 33, 28);
    rect(72, 39, width - 144, height - 78, 10);
    fill(128, 88, 52);
    rect(78, 44, width - 156, height - 88, 8);
    fill(237, 222, 185);
    rect(83, 49, width - 166, height - 98, 6);
    fill(58, 84, 58);
    rect(83, 49, width - 166, 52, 6);
    fill(58, 84, 58);
    rect(83, 87, width - 166, 14);
    noStroke();
    fill(250, 231, 189);
    textAlign(LEFT, TOP);
    textSize(22);
    text(title, 112, 62);
    fill(210, 178, 116);
    rect(width - 131, 62, 18, 18, 3);
    fill(58, 84, 58);
    rect(width - 126, 67, 8, 8);
  }

  void drawFooter(String hint) {
    fill(114, 94, 62);
    textSize(12);
    textAlign(RIGHT, BOTTOM);
    text(hint, width - 112, height - 74);
  }

  // Panel berisi baris teks yang bisa digulir dengan W/S.
  void drawPanel(String title, ArrayList<String> rows, String hint) {
    int maxScroll = max(0, rows.size() - VISIBLE_ROWS);
    if (scroll > maxScroll) scroll = maxScroll;

    drawFrame(title);
    fill(226, 211, 176);
    noStroke();
    rect(106, 112, width - 212, height - 202, 5);
    textSize(14);
    textAlign(LEFT, TOP);
    for (int i = 0; i < VISIBLE_ROWS && scroll + i < rows.size(); i++) {
      int rowIndex = scroll + i;
      float y = 121 + i * 22;
      String row = rows.get(rowIndex);
      if (i % 2 == 0) {
        fill(238, 225, 195, 175);
        rect(114, y - 3, width - 228, 21, 3);
      }
      if (row.startsWith("Pelajaran:")) fill(68, 105, 66);
      else if (row.startsWith("[") || row.contains("[ACTIVE]") || row.contains("[COMPLETED]"))
        fill(63, 83, 55);
      else fill(67, 61, 46);
      text(row, 124, y);
    }
    drawFooter(maxScroll > 0 ? hint + "  |  W/S gulir" : hint);
  }
}

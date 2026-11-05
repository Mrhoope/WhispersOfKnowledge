// UI.pde
// Semua tampilan antarmuka (HUD, dialog, inventory, journal, quest log, pause). (Anggota 3)
// UI hanya MENGGAMBAR. Data dan logika tetap di class masing-masing.
// Belum ada: Main Menu dan Crafting Interface (Fase 6).

class UI {
  String notification = "";
  int notificationUntil = 0;

  void showNotification(String message) {
    notification = message;
    notificationUntil = millis() + 3000;
  }

  // ---------- HUD ----------

  void renderHud(QuestManager quests, boolean canInteract) {
    noStroke();
    fill(0, 150);
    rect(0, 0, width, 26);
    fill(255);
    textAlign(LEFT, CENTER);
    textSize(13);
    text("WASD: gerak | E: interaksi | I: Inventory | J: Journal | Q: Quest | ESC: Pause", 10, 13);

    // quest aktif pertama
    for (Quest q : quests.getAllQuests()) {
      if (q.status == QuestStatus.ACTIVE) {
        fill(255, 230, 140);
        textAlign(RIGHT, CENTER);
        text("Quest: " + q.title, width - 10, 13);
        break;
      }
    }

    // prompt interaksi
    if (canInteract) {
      fill(0, 170);
      rect(width / 2 - 70, height - 60, 140, 30, 6);
      fill(255);
      textAlign(CENTER, CENTER);
      text("[E] Bicara", width / 2, height - 45);
    }
  }

  void renderNotification() {
    if (millis() >= notificationUntil) return;
    noStroke();
    fill(0, 190);
    rect(width / 2 - 200, 40, 400, 30, 6);
    fill(180, 255, 180);
    textAlign(CENTER, CENTER);
    textSize(13);
    text(notification, width / 2, 55);
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
    ArrayList<String> lines = new ArrayList<String>();
    for (Map.Entry<String, Integer> e : inventory.getAll().entrySet()) {
      ItemData d = inventory.getItemData(e.getKey());
      if (d != null) {
        lines.add(d.name + "  x" + e.getValue() + "   (" + d.category + ")");
      } else {
        lines.add(e.getKey() + "  x" + e.getValue());
      }
    }
    if (lines.isEmpty()) lines.add("(kosong)");
    drawPanel("Inventory  (I untuk menutup)", lines);
  }

  void renderJournal(Journal journal) {
    ArrayList<String> lines = new ArrayList<String>();
    for (JournalEntry e : journal.getDiscovered()) {
      lines.add("[" + e.category + "] " + e.title + ": " + e.description);
      lines.add("      Pelajaran: " + e.learningInfo);
    }
    if (lines.isEmpty()) lines.add("(belum ada pengetahuan yang ditemukan)");
    drawPanel("Journal  (J untuk menutup)", lines);
  }

  void renderQuestLog(QuestManager quests) {
    ArrayList<String> lines = new ArrayList<String>();
    for (Quest q : quests.getAllQuests()) {
      if (q.status == QuestStatus.LOCKED) continue;
      lines.add(q.title + "  [" + q.status + "]");
      lines.add("      " + q.description);
      if (q.status == QuestStatus.ACTIVE || q.status == QuestStatus.COMPLETED) {
        for (int i = 0; i < q.objectives.length; i++) {
          lines.add("      " + (q.done[i] ? "[x] " : "[ ] ") + q.objectives[i]);
        }
      }
    }
    if (lines.isEmpty()) lines.add("(belum ada quest)");
    drawPanel("Quest Log  (Q untuk menutup)", lines);
  }

  void renderPause() {
    ArrayList<String> lines = new ArrayList<String>();
    lines.add("Permainan dijeda.");
    lines.add("Tekan ESC untuk melanjutkan.");
    drawPanel("Pause", lines);
  }

  // Panel umum: judul dan daftar baris teks.
  void drawPanel(String title, ArrayList<String> lines) {
    fill(0, 220);
    stroke(255);
    rect(120, 60, width - 240, height - 120, 10);
    noStroke();
    fill(255, 230, 140);
    textAlign(LEFT, TOP);
    textSize(18);
    text(title, 145, 80);
    fill(255);
    textSize(14);
    float y = 118;
    for (String s : lines) {
      text(s, 145, y, width - 290, 26);
      y += 26;
    }
  }
}

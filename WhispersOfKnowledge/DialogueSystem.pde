// DialogueSystem.pde
// Dialog bertahap dengan pilihan jawaban sederhana. (Anggota 3)
//
// Dialog adalah array DialogueLine. Setiap baris menunjuk ke baris berikutnya
// lewat indeks. Indeks -1 berarti dialog selesai.
//
// Baris biasa : new DialogueLine("Teks", indeksBerikutnya, "aksi")
// Baris pilihan: new DialogueLine("Teks", new String[]{"A","B"}, new int[]{2,3})
//
// "aksi" adalah perintah teks yang dijalankan Game saat baris itu ditampilkan.
// Beberapa perintah dipisah dengan ";". Perintah yang tersedia (lihat Game.runAction):
//   start_quest:<questId>
//   objective:<questId>:<indeks>
//   give_item:<itemId>:<jumlah>
//   discover:<journalEntryId>

class DialogueLine {
  String text;
  String[] choices;    // pilihan jawaban, array kosong jika tanpa pilihan
  int[] choiceNext;    // tujuan tiap pilihan (indeks baris), -1 = selesai
  int next;            // tujuan jika tanpa pilihan, -1 = selesai
  String action;       // "" jika tidak ada aksi

  // Baris biasa (tanpa pilihan)
  DialogueLine(String text, int next, String action) {
    this.text = text;
    this.choices = new String[0];
    this.choiceNext = new int[0];
    this.next = next;
    this.action = action;
  }

  // Baris dengan pilihan jawaban
  DialogueLine(String text, String[] choices, int[] choiceNext) {
    this.text = text;
    this.choices = choices;
    this.choiceNext = choiceNext;
    this.next = -1;
    this.action = "";
  }

  boolean hasChoices() {
    return choices.length > 0;
  }
}

class DialogueSystem {
  NPC npc = null;
  DialogueLine[] lines = null;
  int currentIndex = -1;       // -1 = dialog tidak terbuka
  int selectedChoice = 0;
  String pendingAction = null;

  // Mulai dialog dengan NPC (biasanya dipanggil dari NPC.interact()).
  void start(NPC npc) {
    DialogueLine[] d = npc.getDialogue();
    if (d == null || d.length == 0) return;
    this.npc = npc;
    this.lines = d;
    goTo(0);
  }

  void goTo(int index) {
    if (lines == null || index < 0 || index >= lines.length) {
      close();
      return;
    }
    currentIndex = index;
    selectedChoice = 0;
    String a = lines[index].action;
    if (a != null && a.length() > 0) {
      pendingAction = a;
    }
  }

  boolean isOpen() {
    return currentIndex >= 0;
  }

  DialogueLine getCurrentLine() {
    return isOpen() ? lines[currentIndex] : null;
  }

  String getSpeakerName() {
    return (npc == null) ? "" : npc.getName();
  }

  boolean hasChoices() {
    return isOpen() && lines[currentIndex].hasChoices();
  }

  int getSelectedChoice() {
    return selectedChoice;
  }

  // delta = -1 (naik) atau 1 (turun)
  void moveSelection(int delta) {
    if (!hasChoices()) return;
    int n = lines[currentIndex].choices.length;
    selectedChoice = (selectedChoice + delta + n) % n;
  }

  // Tombol E: lanjut ke baris berikutnya, atau konfirmasi pilihan.
  void confirm() {
    if (!isOpen()) return;
    DialogueLine line = lines[currentIndex];
    if (line.hasChoices()) {
      goTo(line.choiceNext[selectedChoice]);
    } else {
      goTo(line.next);
    }
  }

  // Mengambil aksi yang menunggu (sekali saja), atau null jika tidak ada.
  String pollAction() {
    String a = pendingAction;
    pendingAction = null;
    return a;
  }

  void close() {
    if (npc != null) {
      npc.markTalked();
    }
    npc = null;
    lines = null;
    currentIndex = -1;
    selectedChoice = 0;
  }
}

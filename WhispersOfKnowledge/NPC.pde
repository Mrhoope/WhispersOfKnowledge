// NPC.pde
// NPC: posisi, tampilan, jarak interaksi, dan data dialog. (Anggota 3)
// Posisi (x, y) adalah titik di KAKI karakter.
// Logika jalannya dialog ada di DialogueSystem.

// Aturan memilih dialog sesuai status quest.
// state: "locked", "available", "active", "ready" (aktif dan tinggal kembali), "completed"
class DialogueRule {
  String questId;
  String state;
  String dialogueId;

  DialogueRule(String questId, String state, String dialogueId) {
    this.questId = questId;
    this.state = state;
    this.dialogueId = dialogueId;
  }
}

class NPC {
  String id;
  String name;
  float x, y;
  DialogueLine[] dialogue;            // dialog yang sedang dipakai
  DialogueLine[] defaultDialogue;     // dialog bila tidak ada aturan yang cocok
  ArrayList<DialogueRule> rules = new ArrayList<DialogueRule>();
  int timesTalked = 0;                // status interaksi
  PImage sprite = null;               // null = pakai placeholder kotak

  final float INTERACT_RANGE = 28;    // pixel dunia

  NPC(String id, String name, float x, float y, DialogueLine[] dialogue) {
    this.id = id;
    this.name = name;
    this.x = x;
    this.y = y;
    this.dialogue = dialogue;
    this.defaultDialogue = dialogue;
  }

  void setSprite(PImage img) {
    sprite = img;
  }

  void render() {
    if (sprite != null) {
      image(sprite, x - sprite.width / 2.0, y - sprite.height);
      return;
    }
    // Placeholder: kotak oranye
    noStroke();
    fill(40, 40, 40, 90);
    ellipse(x, y, 12, 5);
    fill(225, 150, 60);
    rect(x - 6, y - 16, 12, 16);
  }

  boolean isNear(Player p) {
    return dist(x, y, p.getX(), p.getY()) <= INTERACT_RANGE;
  }

  // Memulai dialog dengan NPC ini.
  void interact(DialogueSystem dialogueSystem) {
    dialogueSystem.start(this);
  }

  void addRule(DialogueRule r) { rules.add(r); }
  ArrayList<DialogueRule> getRules() { return rules; }

  DialogueLine[] getDialogue()        { return dialogue; }
  DialogueLine[] getDefaultDialogue() { return defaultDialogue; }
  // Mengganti dialog, misalnya sesuai progres quest.
  void setDialogue(DialogueLine[] newDialogue) { dialogue = newDialogue; }
  void markTalked()            { timesTalked++; }
  int getTimesTalked()         { return timesTalked; }
  String getId()               { return id; }
  String getName()             { return name; }
  float getX()                 { return x; }
  float getY()                 { return y; }
}

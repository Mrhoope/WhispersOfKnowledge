// NPC.pde
// NPC: posisi, tampilan, jarak interaksi, dan data dialog. (Anggota 3)
// Posisi (x, y) adalah titik di KAKI karakter.
// Logika jalannya dialog ada di DialogueSystem.

class NPC {
  String id;
  String name;
  float x, y;
  DialogueLine[] dialogue;
  int timesTalked = 0;     // status interaksi
  PImage sprite = null;    // null = pakai placeholder kotak

  final float INTERACT_RANGE = 28;  // pixel dunia

  NPC(String id, String name, float x, float y, DialogueLine[] dialogue) {
    this.id = id;
    this.name = name;
    this.x = x;
    this.y = y;
    this.dialogue = dialogue;
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

  DialogueLine[] getDialogue() { return dialogue; }
  void markTalked()            { timesTalked++; }
  int getTimesTalked()         { return timesTalked; }
  String getId()               { return id; }
  String getName()             { return name; }
  float getX()                 { return x; }
  float getY()                 { return y; }
}

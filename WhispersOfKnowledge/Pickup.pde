// Pickup.pde
// Objek di dunia yang bisa diambil dengan tombol E: tanaman, bahan, sumber air. (Anggota 3)
// Posisi (x, y) adalah titik di tanah (pusat tile).
// Pickup "repeatable" (misalnya kolam air) bisa diambil berulang kali.

class Pickup {
  String id;
  String name;
  String itemId;        // item yang diterima pemain
  int quantity;
  float x, y;
  boolean repeatable;
  String journalId;     // entry Journal yang ditemukan saat diambil, "" jika tidak ada
  boolean collected = false;
  int r, g, b;          // warna placeholder
  PImage sprite = null; // null = pakai lingkaran placeholder

  final float INTERACT_RANGE = 24;  // pixel dunia

  Pickup(String id, String name, String itemId, int quantity, float x, float y,
         boolean repeatable, String journalId, int r, int g, int b) {
    this.id = id;
    this.name = name;
    this.itemId = itemId;
    this.quantity = quantity;
    this.x = x;
    this.y = y;
    this.repeatable = repeatable;
    this.journalId = journalId;
    this.r = r;
    this.g = g;
    this.b = b;
  }

  boolean isAvailable() {
    return repeatable || !collected;
  }

  boolean isNear(Player p) {
    return isAvailable() && dist(x, y, p.getX(), p.getY()) <= INTERACT_RANGE;
  }

  void markCollected() {
    if (!repeatable) {
      collected = true;
    }
  }

  // Placeholder: lingkaran berwarna. Diganti sprite AI di Fase 5.
  void setSprite(PImage img) {
    sprite = img;
  }

  void render() {
    if (!isAvailable()) return;
    if (sprite != null) {
      image(sprite, x - sprite.width / 2.0, y - sprite.height);
      return;
    }
    noStroke();
    fill(40, 40, 40, 70);
    ellipse(x, y, 10, 4);
    fill(r, g, b);
    ellipse(x, y - 5, 9, 9);
    fill(255, 255, 255, 170);
    ellipse(x - 1, y - 6, 3, 3);
  }

  String getId()        { return id; }
  String getName()      { return name; }
  String getItemId()    { return itemId; }
  int getQuantity()     { return quantity; }
  String getJournalId() { return journalId; }
  float getX()          { return x; }
  float getY()          { return y; }
}

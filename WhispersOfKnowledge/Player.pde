// Player.pde
// Pemain: gerak 4 arah dengan collision. (Anggota 2)
// Posisi (x, y) adalah titik di KAKI karakter.

class Player {
  float x, y;
  float speed = 1.2;     // pixel dunia per frame
  int facing = 0;        // 0 bawah, 1 atas, 2 kiri, 3 kanan
  boolean moving = false;
  PImage[] sprites = new PImage[4];   // per arah hadap (0 bawah, 1 atas, 2 kiri, 3 kanan)
  PImage spriteAny = null;            // cadangan bila arah tertentu tidak punya gambar

  // kotak collision di sekitar kaki
  final float HALF_W = 5;
  final float BOX_H = 6;

  Player(float startX, float startY) {
    x = startX;
    y = startY;
  }

  void update(World world, int dirX, int dirY) {
    moving = (dirX != 0 || dirY != 0);
    if (!moving) return;

    if (dirY < 0) facing = 1;
    if (dirY > 0) facing = 0;
    if (dirX < 0) facing = 2;
    if (dirX > 0) facing = 3;

    // gerak diagonal tidak boleh lebih cepat
    float len = sqrt(dirX * dirX + dirY * dirY);
    float vx = dirX / len * speed;
    float vy = dirY / len * speed;

    // cek sumbu X dan Y terpisah supaya bisa meluncur di sepanjang dinding
    if (!collides(world, x + vx, y)) x += vx;
    if (!collides(world, x, y + vy)) y += vy;
  }

  boolean collides(World world, float nx, float ny) {
    return world.isBlockedPx(nx - HALF_W, ny - BOX_H)
        || world.isBlockedPx(nx + HALF_W, ny - BOX_H)
        || world.isBlockedPx(nx - HALF_W, ny)
        || world.isBlockedPx(nx + HALF_W, ny);
  }

  // Mengatur gambar untuk satu arah hadap. img boleh null.
  void setSprite(int facingDir, PImage img) {
    if (facingDir >= 0 && facingDir < 4) sprites[facingDir] = img;
  }

  void setFallbackSprite(PImage img) {
    spriteAny = img;
  }

  // Memakai sprite bila ada, kalau tidak ada: placeholder kotak biru.
  void render() {
    PImage img = (sprites[facing] != null) ? sprites[facing] : spriteAny;
    if (img != null) {
      image(img, x - img.width / 2.0, y - img.height);
      return;
    }
    noStroke();
    fill(40, 40, 40, 90);
    ellipse(x, y, 12, 5);         // bayangan
    fill(70, 110, 220);
    rect(x - 6, y - 16, 12, 16);  // badan
    fill(255);
    // penanda arah hadap
    if (facing == 0) rect(x - 2, y - 6, 4, 2);
    if (facing == 1) rect(x - 2, y - 15, 4, 2);
    if (facing == 2) rect(x - 6, y - 10, 2, 4);
    if (facing == 3) rect(x + 4, y - 10, 2, 4);
  }

  float getX() { return x; }
  float getY() { return y; }

  void setPosition(float newX, float newY) {
    x = newX;
    y = newY;
  }
}

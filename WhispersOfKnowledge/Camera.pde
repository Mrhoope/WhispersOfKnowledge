// Camera.pde
// Kamera yang mengikuti pemain. (Anggota 2)
// Satuan: pixel dunia. View = ukuran layar dibagi ZOOM.

class Camera {
  float x = 0;       // sudut kiri-atas area yang terlihat
  float y = 0;
  float viewW;       // lebar area terlihat (pixel dunia)
  float viewH;

  Camera(float viewW, float viewH) {
    this.viewW = viewW;
    this.viewH = viewH;
  }

  // Pusatkan kamera pada target, tetapi tidak keluar dari batas dunia.
  void follow(float targetX, float targetY, World world) {
    x = constrain(targetX - viewW / 2, 0, max(0, world.getPixelWidth() - viewW));
    y = constrain(targetY - viewH / 2, 0, max(0, world.getPixelHeight() - viewH));
  }

  // Terapkan zoom dan geser kamera. Panggil di antara pushMatrix() dan popMatrix().
  void apply() {
    scale(ZOOM);
    translate(-x, -y);
  }

  float getX() { return x; }
  float getY() { return y; }
  float getViewW() { return viewW; }
  float getViewH() { return viewH; }
}

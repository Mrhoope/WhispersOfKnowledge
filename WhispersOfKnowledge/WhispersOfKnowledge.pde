// WhispersOfKnowledge.pde
// File utama: hanya setup, draw, dan meneruskan input ke Game.
// Logika permainan ada di tab lain (Game, Player, World, dst).

import java.util.*;   // diperlukan untuk Map dan LinkedHashMap

final int TILE_SIZE = 16;  // ukuran satu tile (pixel dunia)
final int ZOOM = 3;        // pembesaran tampilan

Game game;

void setup() {
  size(960, 540);
  noSmooth();              // supaya pixel art tidak buram
  frameRate(60);
  surface.setTitle("Whispers of Knowledge");
  game = new Game();
}

void draw() {
  game.update();
  game.render();
}

void keyPressed() {
  game.keyPressed();
  // ESC dipakai untuk Pause, jadi jangan biarkan Processing menutup aplikasi
  if (key == ESC) {
    key = 0;
  }
}

void keyReleased() {
  game.keyReleased();
}

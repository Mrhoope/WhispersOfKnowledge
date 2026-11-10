// World.pde
// Peta berbasis tile, rendering, dan collision. (Anggota 2)
// Saat ini peta digenerate lewat kode sebagai placeholder.
// Nanti diganti memuat map dan tileset dari data/maps dan data/tilesets.

class World {
  final int GRASS = 0;
  final int TREE = 1;   // menghalangi
  final int WATER = 2;  // menghalangi
  final int PATH = 3;

  // Zona Whispering Forest (placeholder): tile x >= 20 dan y <= 14.
  final int FOREST_MIN_TX = 20;
  final int FOREST_MAX_TY = 14;

  int tilesWide, tilesHigh;
  int[][] tiles;

  World(int tilesWide, int tilesHigh) {
    this.tilesWide = tilesWide;
    this.tilesHigh = tilesHigh;
    tiles = new int[tilesWide][tilesHigh];
    generatePlaceholderMap();
  }

  void generatePlaceholderMap() {
    for (int tx = 0; tx < tilesWide; tx++) {
      for (int ty = 0; ty < tilesHigh; ty++) {
        int t = GRASS;
        // pohon tersebar
        if ((tx * 7 + ty * 13) % 23 == 0) t = TREE;
        // jalan mendatar
        if (ty == 15) t = PATH;
        // kolam
        if (tx >= 25 && tx <= 30 && ty >= 18 && ty <= 22) t = WATER;
        // batas area
        if (tx == 0 || ty == 0 || tx == tilesWide - 1 || ty == tilesHigh - 1) t = TREE;
        tiles[tx][ty] = t;
      }
    }
    // area awal pemain dan NPC dipastikan bebas
    for (int tx = 4; tx <= 13; tx++) {
      for (int ty = 4; ty <= 10; ty++) {
        tiles[tx][ty] = GRASS;
      }
    }
  }

  void render(float camX, float camY, float viewW, float viewH) {
    int startX = max(0, floor(camX / TILE_SIZE));
    int endX = min(tilesWide - 1, floor((camX + viewW) / TILE_SIZE));
    int startY = max(0, floor(camY / TILE_SIZE));
    int endY = min(tilesHigh - 1, floor((camY + viewH) / TILE_SIZE));

    noStroke();
    for (int tx = startX; tx <= endX; tx++) {
      for (int ty = startY; ty <= endY; ty++) {
        drawTile(tiles[tx][ty], tx * TILE_SIZE, ty * TILE_SIZE);
      }
    }
  }

  void drawTile(int type, int px, int py) {
    if (type == WATER) {
      fill(70, 130, 200);
      rect(px, py, TILE_SIZE, TILE_SIZE);
    } else if (type == PATH) {
      fill(190, 160, 110);
      rect(px, py, TILE_SIZE, TILE_SIZE);
    } else {
      if (isForest(px / TILE_SIZE, py / TILE_SIZE)) {
        fill(78, 140, 68);   // rumput hutan sedikit lebih gelap
      } else {
        fill(96, 160, 80);
      }
      rect(px, py, TILE_SIZE, TILE_SIZE);
      if (type == TREE) {
        fill(110, 75, 40);
        rect(px + 6, py + 9, 4, 7);    // batang
        fill(40, 110, 50);
        ellipse(px + 8, py + 6, 14, 12); // daun
      }
    }
  }

  boolean isBlocked(int tileX, int tileY) {
    if (tileX < 0 || tileY < 0 || tileX >= tilesWide || tileY >= tilesHigh) return true;
    int t = tiles[tileX][tileY];
    return t == TREE || t == WATER;
  }

  boolean isForest(int tileX, int tileY) {
    return tileX >= FOREST_MIN_TX && tileY <= FOREST_MAX_TY;
  }

  boolean isForestPx(float px, float py) {
    return isForest(floor(px / TILE_SIZE), floor(py / TILE_SIZE));
  }

  boolean isBlockedPx(float px, float py) {
    return isBlocked(floor(px / TILE_SIZE), floor(py / TILE_SIZE));
  }

  int getPixelWidth()  { return tilesWide * TILE_SIZE; }
  int getPixelHeight() { return tilesHigh * TILE_SIZE; }
}

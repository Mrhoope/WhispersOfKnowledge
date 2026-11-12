// World.pde
// Peta berbasis tile, zona, rendering, dan collision. (Anggota 2)
// Peta dimuat dari data/maps/*.json lewat loadFromJson() (dipanggil oleh DataLoader).
// Jika file peta gagal dimuat, dipakai peta placeholder yang digenerate kode.

// Area persegi di peta (dalam tile, batas ikut dihitung), misalnya hutan.
class Zone {
  String id;
  String name;
  int x1, y1, x2, y2;

  Zone(String id, String name, int x1, int y1, int x2, int y2) {
    this.id = id;
    this.name = name;
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
  }

  boolean contains(int tileX, int tileY) {
    return tileX >= x1 && tileX <= x2 && tileY >= y1 && tileY <= y2;
  }
}

class World {
  final int GRASS = 0;
  final int TREE = 1;   // menghalangi
  final int WATER = 2;  // menghalangi
  final int PATH = 3;

  int tilesWide, tilesHigh;
  int[][] tiles;
  ArrayList<Zone> zones = new ArrayList<Zone>();
  int startTileX = 5;
  int startTileY = 5;

  World(int tilesWide, int tilesHigh) {
    this.tilesWide = tilesWide;
    this.tilesHigh = tilesHigh;
    tiles = new int[tilesWide][tilesHigh];
    generatePlaceholderMap();
  }

  // Peta cadangan bila file peta tidak ada atau rusak.
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
    zones.clear();
    zones.add(new Zone("forest", "Whispering Forest", 20, 0, tilesWide - 1, 14));
  }

  // Karakter peta: . rumput, T pohon, ~ air, = jalan. Mengembalikan -1 jika tidak dikenal.
  int tileFromChar(char c) {
    if (c == '.') return GRASS;
    if (c == 'T') return TREE;
    if (c == '~') return WATER;
    if (c == '=') return PATH;
    return -1;
  }

  // Memuat peta dari JSON. Mengembalikan false (dan mengisi errors) jika ada yang salah;
  // dalam kasus itu peta lama tidak berubah.
  boolean loadFromJson(JSONObject json, ArrayList<String> errors) {
    int w = json.getInt("width", 0);
    int h = json.getInt("height", 0);
    if (w <= 0 || h <= 0 || !json.hasKey("rows")) {
      errors.add("Peta: width, height, dan rows wajib diisi.");
      return false;
    }
    JSONArray rows = json.getJSONArray("rows");
    if (rows.size() != h) {
      errors.add("Peta: jumlah baris di rows (" + rows.size() + ") tidak sama dengan height (" + h + ").");
      return false;
    }

    int[][] newTiles = new int[w][h];
    for (int ty = 0; ty < h; ty++) {
      String row = rows.getString(ty);
      if (row.length() != w) {
        errors.add("Peta: baris " + ty + " panjangnya " + row.length() + ", seharusnya " + w + ".");
        return false;
      }
      for (int tx = 0; tx < w; tx++) {
        int t = tileFromChar(row.charAt(tx));
        if (t < 0) {
          errors.add("Peta: karakter '" + row.charAt(tx) + "' di baris " + ty + ", kolom " + tx + " tidak dikenal.");
          return false;
        }
        newTiles[tx][ty] = t;
      }
    }

    ArrayList<Zone> newZones = new ArrayList<Zone>();
    if (json.hasKey("zones")) {
      JSONArray zs = json.getJSONArray("zones");
      for (int i = 0; i < zs.size(); i++) {
        JSONObject z = zs.getJSONObject(i);
        String zid = z.getString("id", "");
        if (zid.length() == 0) {
          errors.add("Peta: zona ke-" + i + " tidak punya id.");
          return false;
        }
        newZones.add(new Zone(zid, z.getString("name", zid),
          z.getInt("x1", 0), z.getInt("y1", 0), z.getInt("x2", w - 1), z.getInt("y2", h - 1)));
      }
    }

    int sx = 5;
    int sy = 5;
    if (json.hasKey("playerStart")) {
      JSONObject s = json.getJSONObject("playerStart");
      sx = s.getInt("tileX", sx);
      sy = s.getInt("tileY", sy);
    }
    if (sx < 0 || sy < 0 || sx >= w || sy >= h || newTiles[sx][sy] == TREE || newTiles[sx][sy] == WATER) {
      errors.add("Peta: playerStart (" + sx + ", " + sy + ") di luar peta atau di tile yang menghalangi.");
      return false;
    }

    // semua benar, terapkan
    tilesWide = w;
    tilesHigh = h;
    tiles = newTiles;
    zones = newZones;
    startTileX = sx;
    startTileY = sy;
    return true;
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

  boolean isBlockedPx(float px, float py) {
    return isBlocked(floor(px / TILE_SIZE), floor(py / TILE_SIZE));
  }

  // ---------- zona ----------

  ArrayList<Zone> getZones() {
    return zones;
  }

  Zone getZone(String id) {
    for (Zone z : zones) {
      if (z.id.equals(id)) return z;
    }
    return null;
  }

  boolean isInZone(String id, int tileX, int tileY) {
    Zone z = getZone(id);
    return z != null && z.contains(tileX, tileY);
  }

  boolean isInZonePx(String id, float px, float py) {
    return isInZone(id, floor(px / TILE_SIZE), floor(py / TILE_SIZE));
  }

  // Zona hutan dipakai untuk warna rumput yang lebih gelap.
  boolean isForest(int tileX, int tileY) {
    return isInZone("forest", tileX, tileY);
  }

  boolean isForestPx(float px, float py) {
    return isInZonePx("forest", px, py);
  }

  // ---------- ukuran dan titik awal ----------

  int getPixelWidth()  { return tilesWide * TILE_SIZE; }
  int getPixelHeight() { return tilesHigh * TILE_SIZE; }
  float getStartX()    { return startTileX * TILE_SIZE + TILE_SIZE / 2; }
  float getStartY()    { return startTileY * TILE_SIZE + TILE_SIZE / 2; }
}

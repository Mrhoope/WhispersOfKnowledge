// Assets.pde
// Memuat gambar (sprite dan tile) dari folder data/ dengan aman. (Anggota 1)
//
// Prinsip: aset TIDAK WAJIB ada. Bila file tidak ditemukan atau rusak,
// get() mengembalikan null dan game memakai placeholder (kotak/lingkaran
// berwarna). Jadi gambar bisa ditambahkan satu per satu tanpa mengubah kode.
// Aturan nama dan ukuran: docs/ASSET_GUIDE.md.

class Assets {
  HashMap<String, PImage> cache = new HashMap<String, PImage>();
  ArrayList<String> loaded = new ArrayList<String>();

  // Mengembalikan gambar, atau null bila file tidak ada atau tidak bisa dibaca.
  PImage get(String path) {
    if (cache.containsKey(path)) return cache.get(path);
    PImage img = null;
    try {
      if (new java.io.File(dataPath(path)).exists()) {
        img = loadImage(path);
        if (img != null && (img.width <= 0 || img.height <= 0)) img = null;   // file gambar rusak
      }
    } catch (Exception e) {
      img = null;
    }
    cache.put(path, img);
    if (img != null) loaded.add(path);
    return img;
  }

  // Gambar pertama yang ada: pathA, kalau tidak ada maka pathB.
  PImage first(String pathA, String pathB) {
    PImage img = get(pathA);
    return (img != null) ? img : get(pathB);
  }

  // Ringkasan di console: aset mana saja yang terpakai.
  void printSummary() {
    if (loaded.isEmpty()) {
      println("[ASET] Belum ada gambar. Semua memakai placeholder.");
      return;
    }
    println("[ASET] " + loaded.size() + " gambar dipakai:");
    for (String p : loaded) {
      println("[ASET]   " + p);
    }
  }
}

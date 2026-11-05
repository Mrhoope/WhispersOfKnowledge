// Inventory.pde
// Penyimpanan item. (Anggota 3)
// Jumlah item tidak pernah negatif.

class ItemData {
  String id;
  String name;
  String description;
  String category;  // Materials, Plants, Crafted Items, Quest Items
  String icon;      // nama file ikon di data/ui, "" jika belum ada

  ItemData(String id, String name, String description, String category, String icon) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.category = category;
    this.icon = icon;
  }
}

class Inventory {
  LinkedHashMap<String, Integer> items = new LinkedHashMap<String, Integer>();
  HashMap<String, ItemData> itemDefs = new HashMap<String, ItemData>();

  void registerItem(ItemData d) {
    itemDefs.put(d.id, d);
  }

  ItemData getItemData(String id) {
    return itemDefs.get(id);
  }

  boolean addItem(String id, int qty) {
    if (qty <= 0) return false;
    items.put(id, getQuantity(id) + qty);
    return true;
  }

  // Jika jumlah kurang, tidak ada yang berubah dan mengembalikan false.
  boolean removeItem(String id, int qty) {
    if (qty <= 0 || getQuantity(id) < qty) return false;
    int left = getQuantity(id) - qty;
    if (left == 0) {
      items.remove(id);
    } else {
      items.put(id, left);
    }
    return true;
  }

  boolean hasItem(String id, int qty) {
    return getQuantity(id) >= qty;
  }

  int getQuantity(String id) {
    Integer q = items.get(id);
    return (q == null) ? 0 : q;
  }

  LinkedHashMap<String, Integer> getAll() {
    return items;
  }
}

// CraftingSystem.pde
// Crafting berbasis resep. (Anggota 3)
// Resep bisa dikunci (unlocked = false) dan dibuka lewat reward quest.

class Recipe {
  String id;
  String name;
  String[] ingredientIds;
  int[] ingredientQty;
  String outputId;
  int outputQty;
  boolean unlocked = true;

  Recipe(String id, String name, String[] ingredientIds, int[] ingredientQty,
         String outputId, int outputQty) {
    this.id = id;
    this.name = name;
    this.ingredientIds = ingredientIds;
    this.ingredientQty = ingredientQty;
    this.outputId = outputId;
    this.outputQty = outputQty;
  }
}

class CraftingSystem {
  LinkedHashMap<String, Recipe> recipes = new LinkedHashMap<String, Recipe>();

  void addRecipe(Recipe r) {
    recipes.put(r.id, r);
  }

  Recipe getRecipe(String id) {
    return recipes.get(id);
  }

  // Membuka resep yang terkunci. false jika tidak ada atau sudah terbuka.
  boolean unlockRecipe(String id) {
    Recipe r = recipes.get(id);
    if (r == null || r.unlocked) return false;
    r.unlocked = true;
    return true;
  }

  // Resep yang sudah terbuka, sesuai urutan pendaftaran.
  ArrayList<Recipe> getUnlockedRecipes() {
    ArrayList<Recipe> result = new ArrayList<Recipe>();
    for (Recipe r : recipes.values()) {
      if (r.unlocked) result.add(r);
    }
    return result;
  }

  // true jika resep terbuka dan semua bahan cukup. Tidak mengubah inventory.
  boolean canCraft(String recipeId, Inventory inv) {
    Recipe r = recipes.get(recipeId);
    if (r == null || !r.unlocked) return false;
    for (int i = 0; i < r.ingredientIds.length; i++) {
      if (!inv.hasItem(r.ingredientIds[i], r.ingredientQty[i])) {
        return false;
      }
    }
    return true;
  }

  // Cek SEMUA bahan dulu. Jika kurang, gagal tanpa mengubah inventory.
  boolean craft(String recipeId, Inventory inv) {
    if (!canCraft(recipeId, inv)) return false;
    Recipe r = recipes.get(recipeId);
    for (int i = 0; i < r.ingredientIds.length; i++) {
      inv.removeItem(r.ingredientIds[i], r.ingredientQty[i]);
    }
    inv.addItem(r.outputId, r.outputQty);
    return true;
  }
}

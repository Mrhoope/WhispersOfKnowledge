// CraftingSystem.pde
// Crafting berbasis resep. (Anggota 3)

class Recipe {
  String id;
  String name;
  String[] ingredientIds;
  int[] ingredientQty;
  String outputId;
  int outputQty;

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
  HashMap<String, Recipe> recipes = new HashMap<String, Recipe>();

  void addRecipe(Recipe r) {
    recipes.put(r.id, r);
  }

  Recipe getRecipe(String id) {
    return recipes.get(id);
  }

  // Cek SEMUA bahan dulu. Jika kurang, gagal tanpa mengubah inventory.
  boolean craft(String recipeId, Inventory inv) {
    Recipe r = recipes.get(recipeId);
    if (r == null) return false;

    for (int i = 0; i < r.ingredientIds.length; i++) {
      if (!inv.hasItem(r.ingredientIds[i], r.ingredientQty[i])) {
        return false;
      }
    }
    for (int i = 0; i < r.ingredientIds.length; i++) {
      inv.removeItem(r.ingredientIds[i], r.ingredientQty[i]);
    }
    inv.addItem(r.outputId, r.outputQty);
    return true;
  }
}

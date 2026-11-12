// QuestManager.pde
// Pengelola quest. (Anggota 1)
// Status: LOCKED -> AVAILABLE -> ACTIVE -> COMPLETED (tanpa FAILED).

enum QuestStatus {
  LOCKED, AVAILABLE, ACTIVE, COMPLETED
}

// Syarat otomatis sebuah objective. Diperiksa oleh Game.checkQuestProgress().
//   "manual"     : tidak otomatis (diselesaikan lewat aksi dialog)
//   "enter_zone" : pemain pernah masuk zona (zoneId)
//   "discover"   : semua entry Journal di discoverIds sudah ditemukan
//   "have_items" : inventory punya semua itemIds sebanyak itemQty
//                  (atau entry orDiscover sudah ditemukan, bila diisi)
class Trigger {
  String type = "manual";
  String zoneId = "";
  String[] discoverIds = new String[0];
  String[] itemIds = new String[0];
  int[] itemQty = new int[0];
  String orDiscover = "";
}

// Hadiah quest. Diberikan satu kali lewat QuestManager.claimReward().
class QuestReward {
  String[] itemIds = new String[0];
  int[] itemQty = new int[0];
  String[] recipeIds = new String[0];
  String[] journalIds = new String[0];
}

class Quest {
  String id;
  String title;
  String description;
  QuestStatus status = QuestStatus.LOCKED;
  String[] objectives;
  boolean[] done;
  Trigger[] triggers;                       // satu per objective, null = manual
  QuestReward reward = new QuestReward();
  boolean rewardGiven = false;

  Quest(String id, String title, String description, String[] objectives) {
    this.id = id;
    this.title = title;
    this.description = description;
    this.objectives = objectives;
    this.done = new boolean[objectives.length];
    this.triggers = new Trigger[objectives.length];
  }

  boolean allObjectivesDone() {
    for (int i = 0; i < done.length; i++) {
      if (!done[i]) return false;
    }
    return true;
  }

  // true jika semua objective selesai kecuali yang terakhir (kembali ke NPC).
  boolean readyToReturn() {
    for (int i = 0; i < done.length - 1; i++) {
      if (!done[i]) return false;
    }
    return true;
  }
}

class QuestManager {
  HashMap<String, Quest> quests = new HashMap<String, Quest>();
  ArrayList<Quest> order = new ArrayList<Quest>();

  void addQuest(Quest q) {
    if (quests.containsKey(q.id)) return;
    quests.put(q.id, q);
    order.add(q);
  }

  Quest getQuest(String id) {
    return quests.get(id);
  }

  ArrayList<Quest> getAllQuests() {
    return order;
  }

  boolean unlockQuest(String id) {
    Quest q = quests.get(id);
    if (q == null || q.status != QuestStatus.LOCKED) return false;
    q.status = QuestStatus.AVAILABLE;
    return true;
  }

  boolean startQuest(String id) {
    Quest q = quests.get(id);
    if (q == null || q.status != QuestStatus.AVAILABLE) return false;
    q.status = QuestStatus.ACTIVE;
    return true;
  }

  boolean completeObjective(String id, int index) {
    Quest q = quests.get(id);
    if (q == null || q.status != QuestStatus.ACTIVE) return false;
    if (index < 0 || index >= q.done.length) return false;
    q.done[index] = true;
    return true;
  }

  // Selesai hanya jika semua objective terpenuhi.
  boolean completeQuest(String id) {
    Quest q = quests.get(id);
    if (q == null || q.status != QuestStatus.ACTIVE) return false;
    if (!q.allObjectivesDone()) return false;
    q.status = QuestStatus.COMPLETED;
    return true;
  }

  // Mengambil hak reward. Mengembalikan true HANYA satu kali per quest.
  // Pemanggil memberikan reward (item, resep, journal) hanya jika hasilnya true.
  boolean claimReward(String id) {
    Quest q = quests.get(id);
    if (q == null || q.status != QuestStatus.COMPLETED || q.rewardGiven) return false;
    q.rewardGiven = true;
    return true;
  }
}

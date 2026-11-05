// QuestManager.pde
// Pengelola quest. (Anggota 1)
// Status: LOCKED -> AVAILABLE -> ACTIVE -> COMPLETED (tanpa FAILED).

enum QuestStatus {
  LOCKED, AVAILABLE, ACTIVE, COMPLETED
}

class Quest {
  String id;
  String title;
  String description;
  QuestStatus status = QuestStatus.LOCKED;
  String[] objectives;
  boolean[] done;
  boolean rewardGiven = false;

  Quest(String id, String title, String description, String[] objectives) {
    this.id = id;
    this.title = title;
    this.description = description;
    this.objectives = objectives;
    this.done = new boolean[objectives.length];
  }

  boolean allObjectivesDone() {
    for (int i = 0; i < done.length; i++) {
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

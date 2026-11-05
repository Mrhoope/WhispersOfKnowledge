// Journal.pde
// Knowledge Journal: pusat informasi edukatif pemain. (Anggota 3)
// Setiap entry punya status ditemukan atau belum ditemukan.

class JournalEntry {
  String id;
  String title;
  String category;      // Biology, Alchemy, Mathematics, Logic, Social Interaction, Science
  String description;
  String learningInfo;
  boolean discovered = false;

  JournalEntry(String id, String title, String category,
               String description, String learningInfo) {
    this.id = id;
    this.title = title;
    this.category = category;
    this.description = description;
    this.learningInfo = learningInfo;
  }
}

class Journal {
  LinkedHashMap<String, JournalEntry> entries = new LinkedHashMap<String, JournalEntry>();

  // Mendaftarkan entry sebagai katalog (status belum ditemukan).
  void registerEntry(JournalEntry e) {
    if (!entries.containsKey(e.id)) {
      entries.put(e.id, e);
    }
  }

  // Menandai entry sebagai ditemukan. false jika tidak ada atau sudah ditemukan.
  boolean discover(String id) {
    JournalEntry e = entries.get(id);
    if (e == null || e.discovered) return false;
    e.discovered = true;
    return true;
  }

  // Mendaftarkan sekaligus menemukan. false jika sudah ditemukan sebelumnya.
  boolean addEntry(JournalEntry e) {
    registerEntry(e);
    return discover(e.id);
  }

  // true jika entry sudah ditemukan.
  boolean hasEntry(String id) {
    JournalEntry e = entries.get(id);
    return e != null && e.discovered;
  }

  // Mengembalikan entry hanya jika sudah ditemukan, selain itu null.
  JournalEntry getEntry(String id) {
    return hasEntry(id) ? entries.get(id) : null;
  }

  ArrayList<JournalEntry> getDiscovered() {
    ArrayList<JournalEntry> result = new ArrayList<JournalEntry>();
    for (JournalEntry e : entries.values()) {
      if (e.discovered) result.add(e);
    }
    return result;
  }

  ArrayList<JournalEntry> getAll() {
    return new ArrayList<JournalEntry>(entries.values());
  }
}

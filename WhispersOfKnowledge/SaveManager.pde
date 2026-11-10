// SaveManager.pde
// Simpan dan muat progress. (Anggota 1)
// STUB: akan diimplementasi di Fase 6. Kontrak sudah ditetapkan.
//
// Rencana: JSON (JSONObject bawaan Processing) di saves/save.json berisi
// posisi pemain, isi inventory, journal yang ditemukan, status dan objective quest.
//
// Pesan hasil (berhasil atau gagal) tersedia lewat getLastMessage()
// supaya UI bisa menampilkannya (PRD 18: kegagalan harus punya pesan jelas).

class SaveManager {
  String lastMessage = "";

  boolean saveGame(Game game) {
    lastMessage = "Fitur simpan belum tersedia.";
    return false;
  }

  boolean loadGame(Game game) {
    lastMessage = "Fitur muat belum tersedia.";
    return false;
  }

  String getLastMessage() {
    return lastMessage;
  }
}

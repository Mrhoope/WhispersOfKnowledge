# Catatan Pengembangan

Tambahkan satu entri di bagian atas setiap kali ada kemajuan yang berarti (format: tanggal, siapa, apa, hasil uji).

## 2026-11-12

- **Aset visual:** jalur pemuatan sprite dan tile (`Assets.pde`), panduan `docs/ASSET_GUIDE.md`, skrip `tools/prepare_asset.py`, aset contoh di `docs/asset-test/`. Gambar opsional dengan placeholder. Diuji manual: aman (placeholder). Uji dengan gambar asli: menunggu Anggota 4.
- **Konten MVP draf:** tiga NPC, dua side quest (Hitungan Pedagang, Mata Pengamat Hutan), 11 item, 14 entry Journal, 10 benda, seluruhnya lewat JSON. Diuji manual: aman.
- **Main Menu:** Lanjutkan, Permainan Baru, Keluar. Diuji manual: aman.
- **Save/Load:** satu slot `saves/save.json`, F5/F9, K/L di Pause. Diuji manual: aman.
- **Konten data-driven:** semua konten dan peta dipindah ke JSON (`DataLoader.pde`), file rusak ditampilkan sebagai kotak merah tanpa crash. Diuji manual: aman.

## Sebelum 2026-11-12

- **Loop Forgotten Garden** dapat dimainkan: pickup, quest, crafting, dialog bercabang, reward sekali, Journal, Quest Log, HUD tujuan. Diuji manual dan aman.
- **Refactor arsitektur:** `Game` mengatur sistem, `UI` hanya menggambar, `Camera` dipisah, dialog dengan pilihan dan aksi.
- **Fondasi:** struktur folder, PRD, README, aturan kolaborasi, pembagian tugas, kerangka game (pemain, peta, kamera).

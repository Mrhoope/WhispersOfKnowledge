# Aturan Kolaborasi Tim

Panduan ini wajib dibaca semua anggota sebelum mulai bekerja.

## 1. Struktur Branch

```text
main        <- hanya versi stabil / rilis
└── develop <- hasil integrasi semua fitur
    ├── feature/core
    ├── feature/player
    ├── feature/world
    ├── feature/ui
    ├── feature/audio
    └── ...
```

- Jangan commit langsung ke `main` atau `develop`.
- Satu anggota bekerja di branch miliknya. Nama branch: `feature/<nama>`, `fix/<nama>`, `chore/<nama>`, atau `docs/<nama>`.

## 2. Alur Kerja Harian

```powershell
git switch develop
git pull                          # 1. ambil update terbaru
git switch feature/nama-branch    # 2. pindah ke branch kerja
git merge develop                 # 3. samakan dengan develop terbaru
# ... coding ...
git add .
git commit -m "feat: add player movement"
git push                          # 4. kirim ke GitHub
```

Lalu buka **Pull Request** ke **`develop`** (bukan `main`).

## 3. Pull Request

Sebelum membuat PR, pastikan:

- [ ] Sketch berjalan di Processing 4 tanpa error
- [ ] Fitur sudah diuji sendiri
- [ ] Tidak mengubah file milik anggota lain tanpa kesepakatan
- [ ] Tidak ada file sampah (`.class`, file save, dll.)
- [ ] Deskripsi PR menjelaskan apa yang berubah dan cara mengujinya

Alur review: PR dibuat, Project Lead me-review, perbaiki jika ada catatan, lalu merge ke `develop`. Merge ke `main` hanya jika versi stabil dan sudah diuji bersama.

## 4. Format Commit

```text
feat:     fitur baru
fix:      perbaikan bug
art:      aset visual
docs:     dokumentasi
refactor: merapikan kode tanpa mengubah perilaku
test:     pengujian
chore:    setup, struktur, konfigurasi
```

Contoh: `feat: implement inventory`, `fix: resolve collision issue`, `art: add AI-generated village tileset`.

Gunakan pesan yang jelas. Hindari pesan seperti `update` atau `fix bug`.

## 5. Aturan Kode

- Satu class = satu tab `.pde`. Nama file sama dengan nama class (`Player.pde`, `Inventory.pde`).
- File utama `WhispersOfKnowledge.pde` hanya untuk `setup()`, `draw()`, dan alur game. Logika masuk ke class masing-masing.
- Ikuti kontrak class di `TECHNICAL_SPEC.md` (nama method dan parameter tidak boleh diubah sepihak).
- Beri komentar singkat untuk logika yang tidak jelas.
- Jangan menambah library atau dependency tanpa diskusi.

## 6. Aturan Aset (File Binary)

Git tidak bisa menggabungkan PNG atau audio seperti menggabungkan kode.

- Satu aset punya satu penanggung jawab.
- Jangan mengedit file aset yang sama secara bersamaan.
- Nama file huruf kecil, pakai underscore: `player_idle_down.png`, `tile_grass.png`.
- Standar ukuran: tile 16x16, sprite 16x24 atau 16x32, format PNG dengan transparansi.
- Jangan commit hasil generate yang tidak dipakai.
- Setiap aset baru wajib dicatat di `docs/ASSET_CREDITS.md` (tool AI, tanggal, prompt, status, ketentuan lisensi).

## 7. Definition of Done

Fitur dianggap selesai jika:

1. Berjalan di Processing 4
2. Memenuhi acceptance criteria di PRD bagian 18
3. Tidak ada error kritis dan tidak merusak fitur lain
4. Sudah diuji dan didokumentasikan
5. PR sudah di-review dan di-merge ke `develop`

## 8. Jika Ada Konflik Merge

1. Jangan panik dan jangan hapus file sembarangan.
2. Beri tahu Project Lead.
3. Selesaikan konflik bersama, lalu commit hasilnya.

## 9. Penggunaan AI Coding Agent

- Berikan [AI_INSTRUCTION.md](AI_INSTRUCTION.md) dan [PRD.md](PRD.md) sebagai konteks.
- Minta fitur secara bertahap, satu fitur per permintaan.
- Kode dari AI harus dijalankan dan diuji sebelum di-commit.
- Pahami kode yang Anda commit. Jangan commit kode yang tidak dimengerti.

## 10. Komunikasi

- Kabari tim jika terblokir lebih dari satu hari.
- Catat kemajuan di `docs/DEVELOPMENT_LOG.md`.
- Perubahan besar (kontrak class, struktur folder) didiskusikan dulu.

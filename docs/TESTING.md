# Panduan Pengujian

Dipakai tim sebelum **setiap pull request** dan sebelum menggabungkan ke `develop`. Semua langkah dijalankan di Processing 4 yang asli. Waktu: sekitar 5 menit untuk uji cepat, 20 menit untuk uji lengkap.

Kontrol: WASD atau panah (gerak), E (interaksi, konfirmasi), W/S (pilih dan gulir), I (Inventory), J (Journal), Q (Quest Log), C (Crafting), ESC (Pause atau tutup), F5/F9 (simpan/muat). Di layar Pause: K simpan, L muat, M menu utama.

## A. Uji cepat (wajib setiap PR)

| # | Langkah | Hasil yang benar |
|---|---|---|
| A1 | Run di Processing | Tidak ada error merah di console, **tidak ada kotak merah** di layar, muncul Main Menu |
| A2 | Pilih "Permainan Baru" | Dunia tampil, pemain bisa bergerak dengan WASD |
| A3 | Jalan ke pohon dan ke kolam air | Pemain tidak bisa menembus pohon dan air |
| A4 | Tekan I, J, Q, C satu per satu | Tiap layar terbuka dan tertutup dengan tombol yang sama atau ESC |
| A5 | Bicara dengan Penjaga Taman (E) | Dialog tampil, pilihan bisa dipilih dengan W/S lalu E |
| A6 | F5 lalu F9 | Muncul "Permainan disimpan." lalu "Permainan dimuat." |

Bila ada langkah yang gagal, **jangan** buat pull request. Perbaiki dulu atau laporkan (bagian F).

## B. Alur utama: The Forgotten Garden

| # | Langkah | Hasil yang benar |
|---|---|---|
| B1 | Jalan ke timur melewati jalan sampai rumput lebih gelap | Notifikasi "Kamu memasuki Whispering Forest" |
| B2 | Ambil Green Leaf (E di dekat lingkaran hijau) | Masuk Inventory, entry baru di Journal |
| B3 | Tekan C lalu E | "Bahan tidak cukup", inventory tidak berubah |
| B4 | Terima quest dari Penjaga Taman | Quest Log: objective 1 dan 2 `[x]`, kotak "Tujuan" di kiri atas |
| B5 | Ambil semua tanaman dan air | Objective tanaman dan bahan selesai otomatis |
| B6 | Bicara dengan penjaga sebelum crafting | Dialog pengingat |
| B7 | Crafting Herbal Tea | Herbal Tea masuk inventory, bahan berkurang |
| B8 | Bicara dengan penjaga | Quest selesai, reward muncul, Garden Tonic terbuka |
| B9 | Bicara lagi | Reward **tidak** bertambah (Garden Seed tetap 1) |

## C. Side quest

| # | Langkah | Hasil yang benar |
|---|---|---|
| C1 | Pedagang Pasar: terima, kumpulkan 6 beri dari 3 semak selatan jalan | Objective beri selesai otomatis |
| C2 | Kembali, jawab pertanyaan dengan jawaban **salah** | Muncul petunjuk, pertanyaan diulang |
| C3 | Jawab benar | Entry Pembagian Rata ditemukan, quest selesai, 3 Koin Perak |
| C4 | Penjaga Hutan: terima, temukan jamur dan aster | Objective selesai otomatis |
| C5 | Kembali, jawab dua pertanyaan | Entry Mengelompokkan, quest selesai, 2 Koin Perak dan entry Habitat Hutan |

## D. Simpan, muat, dan menu

| # | Langkah | Hasil yang benar |
|---|---|---|
| D1 | Di tengah quest: F5, ambil benda lain, F9 | Semua kembali seperti saat F5, benda tadi muncul lagi |
| D2 | Tutup game, buka lagi, "Lanjutkan" | Progres kembali (posisi, inventory, Journal, quest) |
| D3 | Hapus folder `WhispersOfKnowledge/saves`, buka game | "Lanjutkan" redup, pesan "Belum ada data simpanan." |
| D4 | ESC lalu M | Kembali ke Main Menu, progres yang belum disimpan hilang |
| D5 | Buka dialog lalu tekan F5 | Tidak terjadi apa-apa (dialog tidak disimpan) |

## E. Data dan aset (setelah mengubah file di `data/`)

| # | Langkah | Hasil yang benar |
|---|---|---|
| E1 | Edit file JSON, jalankan game | Tidak ada kotak merah. Bila ada, pesannya menyebut file dan masalahnya |
| E2 | Sengaja hapus satu koma di `items.json`, jalankan | Kotak merah: "items.json: tidak bisa dibaca...". Game tetap jalan. **Kembalikan filenya** |
| E3 | Tambah gambar di `data/sprites/` atau `data/tilesets/` | Console menampilkan `[ASET] ...`, gambar tampil di game |
| E4 | Ganti nama file gambar menjadi salah | Kembali ke placeholder, tidak ada error |

Bila save lama ditolak setelah mengubah ID di JSON, itu normal: hapus `saves/save.json`.

## F. Melaporkan bug

Buat issue di GitHub dengan format:

```text
Judul: singkat dan spesifik (contoh: "Pedagang tidak memberi reward setelah jawaban benar")

Langkah:
1. ...
2. ...
Hasil yang terjadi:
Hasil yang diharapkan:
Branch / commit:
Pesan error di console (salin teks) atau screenshot:
Apakah terjadi setiap kali? (selalu / kadang)
```

## G. Syarat sebuah pull request boleh digabung

- [ ] Uji cepat (A) lulus di komputer penulis.
- [ ] Bagian yang diubah diuji dari daftar B sampai E yang relevan.
- [ ] Tidak ada kotak merah dan tidak ada error di console.
- [ ] Ditinjau minimal satu anggota lain yang **menjalankan** branch-nya.
- [ ] Dokumen terkait ikut diperbarui (`TECHNICAL_SPEC.md`, `DATA_FORMAT.md`, atau `ASSET_GUIDE.md`).

## H. Pengujian otomatis

Selama pengembangan, logika game diuji otomatis di luar Processing memakai pengganti API Processing (stub), hanya untuk logika: alur quest, crafting, dialog, Save/Load, Main Menu, pemuatan data dan aset, serta kasus data rusak. Tes ini **tidak menggantikan** uji manual di atas, karena tidak memeriksa tampilan dan input asli. Ringkasan hasilnya ada di `TECHNICAL_SPEC.md` bagian 10.

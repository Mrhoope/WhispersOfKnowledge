# Whispers of Knowledge

Game edukasi **2D top-down pixel art adventure RPG** yang dibuat dengan **Processing 4 (Java Mode)**.

Pemain menjelajahi dunia fantasi (desa, hutan, taman alkimia, perpustakaan), berbicara dengan NPC, menyelesaikan quest, dan melakukan crafting. Pembelajaran terjadi lewat aktivitas bermain, bukan sekadar tanya-jawab.

> **Status:** Fase 2 terverifikasi. Skenario *The Forgotten Garden* dapat dimainkan dengan visual placeholder
> (Fase 3 dan 4, menunggu verifikasi tim). Dokumen acuan: [PRD.md](PRD.md) v1.7

## Fitur MVP

- Eksplorasi 2D top-down dengan kamera dan collision
- Dialog dengan NPC
- Satu main quest (*The Forgotten Garden*) dan dua side quest
- Inventory dan crafting dasar
- Knowledge Journal
- Save dan Load
- Aset visual buatan AI (pixel art, cozy fantasy)

Fitur di luar MVP (combat, multiplayer, dll.) ada di PRD bagian 20.

## Teknologi

| Komponen | Pilihan |
|---|---|
| Engine | Processing 4 (Java Mode) |
| Versi Processing | 4.x.x (isi versi yang dipakai tim) |
| Bahasa | Java |
| Editor | Visual Studio Code (alternatif: Processing IDE 4) |
| Version control | Git + GitHub |
| Platform | Windows PC |

## Cara Menjalankan

1. Install [Processing 4](https://processing.org/download).
2. Clone repository:
   ```powershell
   git clone https://github.com/Mrhoope/WhispersOfKnowledge.git
   cd WhispersOfKnowledge
   git switch develop
   ```
3. Buka `WhispersOfKnowledge/WhispersOfKnowledge.pde` di Processing IDE.
4. Tekan tombol **Run**.

> Seluruh tim wajib memakai versi Processing 4 yang sama.

## Kontrol

| Tombol | Fungsi |
|---|---|
| W/A/S/D atau Panah | Bergerak |
| E | Interaksi |
| J | Journal |
| I | Inventory |
| Q | Quest Log |
| C | Crafting |
| W/S saat dialog, Crafting, atau panel | Memilih jawaban, memilih resep, atau menggulir |
| ESC | Pause (di sini: K simpan, L muat, M menu utama) |
| F5 / F9 | Simpan / Muat permainan |

## Struktur Proyek

```text
WhispersOfKnowledge/                  <- root repo
├── README.md
├── PRD.md
├── AI_INSTRUCTION.md
├── TECHNICAL_SPEC.md
├── CONTRIBUTING.md
├── .gitignore
├── docs/
│   ├── TEAM_TASKS.md
│   ├── DEVELOPMENT_LOG.md
│   ├── ASSET_CREDITS.md
│   └── TESTING.md
└── WhispersOfKnowledge/              <- folder sketch Processing
    ├── WhispersOfKnowledge.pde
    ├── Game  Camera  Player  World          (.pde)
    ├── NPC  DialogueSystem  Pickup  UI      (.pde)
    ├── QuestManager  Inventory  CraftingSystem  Journal  SaveManager  DataLoader  (.pde)
    └── data/
        ├── sprites/  tilesets/  audio/  ui/
        ├── maps/        greenhaven.json
        └── game-data/   items, recipes, journal, quests, dialogues, npcs, pickups (.json)
```

Catatan: Processing hanya mengenali file `.pde` di folder sketch dan aset di `data/`. Tiap class dibuat sebagai tab `.pde` terpisah.

## Dokumentasi

- [PRD.md](PRD.md): kebutuhan produk
- [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md): kontrak class
- [docs/DATA_FORMAT.md](docs/DATA_FORMAT.md): cara menambah NPC, quest, item, dan peta lewat file JSON
- [CONTRIBUTING.md](CONTRIBUTING.md): aturan kolaborasi tim
- [docs/TEAM_TASKS.md](docs/TEAM_TASKS.md): pembagian tugas
- [docs/ASSET_CREDITS.md](docs/ASSET_CREDITS.md): catatan aset AI
- [AI_INSTRUCTION.md](AI_INSTRUCTION.md): panduan untuk AI coding agent

## Tim

4 anggota (semua pemula). Peran dan tanggung jawab ada di [docs/TEAM_TASKS.md](docs/TEAM_TASKS.md).

## Prinsip

**Build Small, Integrate Early, Expand Gradually.**

# 03 — Rebranding To JAAW And Product Scope Expansion

**Metadata Tracking:**
* **Tanggal Dibuat:** `2026-09-10 00:49:06 WIB`
* **Pembaruan Terakhir:** `2026-09-10 00:49:06 WIB`
* **Status:** `Completed`
* **Target Versi / CalVer:** `v2026.09.x`
* **Kategori:** `Foundation & Architecture`
* **Komponen Terkait:** `bin/jaaw`, `Makefile`, `install.sh`, `uninstall.sh`, `README.md`, `completions/*`, `TaskDev/*`
* **Tags:** `[#rebrand, #jaaw, #architecture, #scope-expansion, #adr]`

---

## 🎯 1. Konteks & Pernyataan Masalah

### 1.1 Keterbatasan Nama Lama (`adbqr`)
Sebelumnya, proyek ini dinamai `adbqr` karena fokus awalnya adalah alat bantu pairing nirkabel menggunakan QR code. Namun seiring evolusi arsitektur dan kebutuhan nyata pengembang di Linux, nama ini menghadapi beberapa keterbatasan kritis:
1. **Feature-Locked Naming**: Nama `adbqr` mempersempit persepsi publik seolah-olah alat ini *hanya* generator QR code satu kali pakai, padahal telah memiliki mesin deteksi event mDNS Avahi real-time, switch USB 5555, dan integrasi tuning `scrcpy`.
2. **Komoditisasi Nama**: Di ekosistem GitHub, nama `adbqr` / `adb-qr` sudah digunakan oleh beberapa repositori dan skrip kecil lain sehingga kehilangan keunikan dan daya saing brand (*brand identity*).
3. **Perluasan Skop Produk (Product Scope Expansion)**: Roadmap baru menetapkan penambahan modul-modul penting:
   - **Device Alias Management & Smart Wrapper** (memetakan nama perangkat acak mDNS TLS ke alias manusiawi seperti `poco`).
   - **Interactive Debloater** (profil penghapusan bloatware aman untuk Xiaomi HyperOS/MIUI, Samsung OneUI, Google, BBK).
   - **Universal Companion Workflow** (screen mirror presets, quick package installer, logcat helper).

Untuk menaungi seluruh kapabilitas modern ini, proyek memerlukan identitas mandiri yang unik, mudah diingat, dan berwibawa di komunitas Linux & open-source.

---

## 🏗️ 2. Evaluasi Opsi & Matriks Keputusan (ADR)

### 2.1 Opsi yang Dipertimbangkan

| Kriteria Evaluasi | Opsi A: Tetap `adbqr` | Opsi B: Prefix ADB (`adbx` / `adbox` / `adbctl`) | Opsi C: Mandiri & Akronim Cerdas (**`jaaw`**) |
|---|---|---|---|
| **Daya Saing Brand** | Rendah (generik) | Sedang (terasa seperti wrapper script bawahan ADB) | **Tinggi** (identitas mandiri berkarakter kuat) |
| **Kesesuaian Skop Luas** | Buruk (terkunci ke QR) | Cukup baik | **Sangat Baik** (mewakili seluruh ekosistem Android) |
| **Ergonomi Mengetik** | 5 huruf (`a-d-b-q-r`) | 4–6 huruf | **4 huruf** (`j-a-a-w`, super cepat di keyboard) |
| **Tabrakan Nama (Collision)** | Banyak kesamaan di GitHub | Ada modul LSPosed `ADB_X` | **0 Konflik** (100% unik di GitHub & Distro Linux) |
| **Kedalaman Filosofi/Lore** | Fungsional biasa | Singkatan teknis | **Linguistik resmi (Awakutu = Debugging)** |

---

## ⚖️ 3. Keputusan Terpilih & Justifikasi

### 3.1 Identitas Resmi Terpilih: **`jaaw`**
Diputuskan secara resmi untuk me-rebrand seluruh proyek menjadi **`jaaw`**.

* **Biner CLI**: `jaaw`
* **Akronim Utama (Bahasa Indonesia)**:
  $$\textbf{J}\text{embatan } \textbf{A}\text{wakutu } \textbf{A}\text{ndroid } \textbf{W}\text{ireless}$$
* **Subtitle Internasional**:
  *Android Debug Bridge Wireless Companion for Linux* / *Joint Android & ADB Workbench*
* **Tagline**:
  > *"The modern, zero-config Android companion for Linux — pairing, debloating, mirroring, and device management made effortless."*

### 3.2 Alasan Justifikasi:
1. **Ketepatan Linguistik**: Istilah *"Awakutu"* adalah terjemahan resmi KBBI / Badan Bahasa untuk *debugging* (proses menghilangkan kutu/bug perangkat lunak). Akronim JAAW menerjemahkan *Android Debug Bridge Wireless* secara elegan dan presisi.
2. **Easter Egg Budaya & Sejarah**: Fondasi Android dibangun di atas ekosistem Java. Pelafalan *"jaaw"* selaras dengan homage lokal (*Jawa/Java*), serupa dengan fenomena tool populer Arch Linux `paru`.
3. **Internasional & Punchy**: Di mata pengguna global, `jaaw` terdengar tajam, pendek (4 huruf), dan langsung menempati peringkat teratas mesin pencari karena nihil duplikasi nama.

---

## 🔍 4. Ringkasan Eksekusi Refaktor & Migrasi Lokal

Perubahan telah diterapkan secara menyeluruh pada workspace lokal **tanpa melakukan commit git** terlebih dahulu:

### 4.1 Pembaruan File Codebase
1. **Renaming Biner & Completions**:
   - `bin/adbqr` $\rightarrow$ `bin/jaaw`
   - `completions/adbqr.bash` $\rightarrow$ `completions/jaaw.bash`
   - `completions/_adbqr` $\rightarrow$ `completions/_jaaw`
   - `completions/adbqr.fish` $\rightarrow$ `completions/jaaw.fish`
2. **Konfigurasi & Skrip Sistem**:
   - [**`bin/jaaw`**](file:///home/nefla/Devel/adbqr/bin/jaaw): Migrasi direktori config ke `~/.config/jaaw/`, prefix pairing nirkabel `jaaw-xxxx`, update URL GitHub ke repo `jaaw`.
   - [**`install.sh`**](file:///home/nefla/Devel/adbqr/install.sh) & [**`uninstall.sh`**](file:///home/nefla/Devel/adbqr/uninstall.sh): Pembaruan path biner `/usr/local/bin/jaaw`, direktori data, dan completions.
   - [**`Makefile`**](file:///home/nefla/Devel/adbqr/Makefile): Validasi syntax check `bin/jaaw`.
   - [**`README.md`**](file:///home/nefla/Devel/adbqr/README.md): Dokumentasi lengkap diperbarui dengan identitas JAAW.

### 4.2 Migrasi Data & Pembersihan Jejak Sistem (System Cleanup)
1. **Data Migration**:
   - File riwayat perangkat `~/.config/adbqr/devices.tsv` telah dipindahkan dengan aman ke direktori baru `~/.config/jaaw/devices.tsv`.
2. **User-Space Purge**:
   - Direktori lama `~/.config/adbqr/` telah dihapus bersih.
3. **System-Space Cleanup**:
   - Disediakan instruksi penghapusan biner dan completions root lama (`/usr/local/bin/adbqr`, `/usr/local/sbin/adbqr`, dll.).

---

## 📋 5. Checkpoints & Matriks Verifikasi

| No | Komponen / Pengujian | Kriteria Keberhasilan | Status |
|---|---|---|---|
| 1 | Bash Syntax Check | `make check` lolos 100% tanpa error | **Tuntas** (✅ Pass) |
| 2 | Codebase String Audit | 0 kemunculan string `adbqr` tersisa di kode sumber | **Tuntas** (✅ 0 Found) |
| 3 | CLI Version Execution | `./bin/jaaw --version` menampilkan identitas JAAW | **Tuntas** (✅ Pass) |
| 4 | TaskDev Validation | `taskdev-cli validate` 100% valid dan tersinkronisasi | **Tuntas** (✅ Pass) |
| 5 | Git Safety | Perubahan berstatus working tree tanpa commit otomatis | **Tuntas** (✅ Pass) |

---

## ⏱️ 6. Riwayat Revisi & Audit Trail
| Tanggal & Waktu | Versi / Commit | Penulis | Ringkasan Perubahan |
|---|---|---|---|
| `2026-09-10 00:49 WIB` | `v2026.09.x` | Neflalabs & AI Pair | Perumusan ADR rebrand ke JAAW, perluasan skop produk, dan pencatatan migrasi sistem |

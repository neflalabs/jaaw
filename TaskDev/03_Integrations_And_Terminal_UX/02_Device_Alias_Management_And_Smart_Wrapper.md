# 02 — Device Alias Management And Smart Wrapper

**Metadata Tracking:**
* **Tanggal Dibuat:** `2026-09-10 00:27:23 WIB`
* **Pembaruan Terakhir:** `2026-09-10 00:57:00 WIB`
* **Status:** `Completed`
* **Target Versi / CalVer:** `v2026.09.x`
* **Kategori:** `Integrations And Terminal UX`
* **Komponen Terkait:** `bin/jaaw`, `completions/jaaw.bash`, `completions/jaaw.zsh`, `completions/jaaw.fish`
* **Tags:** `[#alias, #terminal, #ux, #adb-wrapper, #mDNS]`

---

## 🎯 1. Latar Belakang & Success Criteria

### 1.1 Latar Belakang Masalah
Koneksi nirkabel Android 11+ via mDNS TLS menghasilkan string serial acak yang panjang (`adb-<serial>-<random>._adb-tls-connect._tcp`). Meskipun mDNS memberikan keuntungan besar berupa **Zero-Configuration Networking** (kebal terhadap pergantian port dinamis dan perubahan IP via DHCP), format serial ini membawa friksi besar pada developer experience (DX):
1. **Sulit Dihafal / Diketik**: Pengembang harus menyalin string TLS acak setiap kali ingin menjalankan `adb -s <target> <command>`.
2. **Keterbatasan ADB Bawaan**: Google ADB tidak menyediakan fitur bawaan untuk me-rename atau memberi alias pada perangkat yang terdaftar di `adb devices`.
3. **Multi-device Ambiguity**: Ketika beberapa perangkat nirkabel terhubung bersamaan, output `adb devices` sulit dibedakan sekilas tanpa melihat detail flag `-l`.

Solusi yang dirancang adalah **Sistem Manajemen Alias Perangkat & Smart Wrapper** di dalam `jaaw`, yang menjembatani kenyamanan mDNS TLS dengan penamaan humanis (misal `poco`, `tab`, `pixel`).

### 1.2 Success Criteria Terukur (Acceptance Criteria)
- [x] **Kriteria 1 (Alias Storage & CRUD)**: Menyimpan pemetaan alias ke identifier perangkat di `~/.config/jaaw/aliases.tsv` dengan perintah intuitif (`jaaw alias set <name> [target]`, `jaaw alias list`, `jaaw alias rm <name>`).
- [x] **Kriteria 2 (Pretty Devices Table)**: Sub-command `jaaw devices` menampilkan tabel humanis yang memetakan Alias, Nama Model HP, Status Koneksi, IP:Port saat ini, dan Target Asli mDNS TLS secara rapi.
- [x] **Kriteria 3 (Smart Passthrough / Execution)**: Kemampuan menjalankan perintah langsung via alias (`jaaw exec <alias> <args...>`, `jaaw shell <alias>`, `jaaw scrcpy <alias>`).
- [x] **Kriteria 4 (Context Switcher / jaaw use)**: Perintah `jaaw use <alias>` mengekspor `ANDROID_SERIAL` aktif ke session shell atau menghasilkan snippet command untuk memfokuskan target ADB.
- [x] **Kriteria 5 (Shell Integration Opsional)**: Penyediaan helper function `jaaw init` untuk Bash/Zsh sehingga perintah standar `adb -s <alias>` otomatis di-resolve ke target serial aslinya secara transparan.

---

## 🏗️ 2. Arsitektur, Alur Sistem & Keputusan ADR-Lite

### 2.1 Diagram Alur & Topologi (ASCII)

```text
Pengguna Terminal
  │
  ├──> [ jaaw alias set poco ] ───> Simpan ke ~/.config/jaaw/aliases.tsv
  │
  ├──> [ jaaw devices ] ─────────> Baca Avahi/ADB + Mapping Alias ──> Output Tabel Rapi
  │
  ├──> [ jaaw shell poco ] ──────> Resolve "poco" ──> adb -s adb-xxxx... shell
  │
  └──> [ adb -s poco shell ] ─────> Smart Shell Wrapper (Opsional via jaaw init)
                                           │
                                           ▼
                              Resolve Alias -> Real Serial
                                           │
                                           ▼
                                 /usr/bin/adb ASLI
```

### 2.2 Keputusan Arsitektur & Alternatif yang Dipertimbangkan (ADR-Lite)
* **Solusi Terpilih**: 
  Pendekatan hibrida dua lapis:
  1. *Lapis Inti (Native CLI)*: Sub-command bawaan `jaaw` (`jaaw alias`, `jaaw devices`, `jaaw exec`, `jaaw use`) yang tidak memerlukan modifikasi konfigurasi shell pengguna.
  2. *Lapis Shell Helper (Opsional)*: Fungsi shell `adb()` tipis via `eval "$(jaaw init)"` untuk pengguna yang menginginkan perintah `adb -s <alias>` bekerja langsung dari shell prompt.
* **Alternatif Lain yang Dipertimbangkan**:
  1. *Opsi A: Mengganti binary /usr/bin/adb dengan symlink wrapper*:
     **Ditolak karena:** Terlalu invasif, berisiko merusak IDE (Android Studio, VS Code ADB extensions) yang mengekspektasikan format biner ADB murni.
  2. *Opsi B: Memaksa koneksi via IP:PORT saja agar nama di adb devices rapi*:
     **Ditolak karena:** Menghilangkan keunggulan utama mDNS (kebal terhadap dynamic port switching dan perubahan IP DHCP saat perangkat reconnect).
* **Konsekuensi / Dampak Positif & Negatif**:
  * (+) Fleksibel: Pengguna bisa memilih menggunakan perintah `jaaw` langsung atau memasang alias shell.
  * (+) Zero-breakage: Tidak mengganggu integrasi Android Studio atau tooling lain.
  * (-) Perlu resolusi cepat (<20ms) saat query alias agar tidak terasa ada latensi eksekusi.

---

## 🛡️ 3. Three-Tier Boundaries Matrix

| Tingkatan | Batasan & Aturan Eksekusi |
|---|---|
| **Always Do** | • Selalu lolos linter `shellcheck` tanpa error/warning kritis.<br/>• Gunakan delimiter Tab (`\t`) standar TSV untuk parsing aman tanpa dependensi eksternal (cukup `awk`/`grep`).<br/>• Fallback graceful jika target alias sedang offline atau tidak ditemukan di ADB. |
| **Ask First** | • Penambahan file konfigurasi global baru di luar `~/.config/jaaw/`.<br/>• Modifikasi skrip instalasi `install.sh` untuk otomatis menginjeksi rc-file (`.bashrc` / `.zshrc`). |
| **Never Do** | • Dilarang menimpa binary asli `adb` di PATH sistem.<br/>• Dilarang membuat subshell blocking lambat (>50ms) pada shell completion / wrapper.<br/>• Dilarang menghilangkan kompatibilitas mDNS TLS yang sudah stabil. |

---

## 🔍 4. Rincian Desain & Spesifikasi Teknis

### 4.1 Skema Penyimpanan Data (~/.config/jaaw/aliases.tsv)
File berformat TSV (Tab-Separated Values):
```text
# ALIAS    TARGET_IDENTIFIER                      DEVICE_MODEL   LAST_SEEN_IP_PORT    UPDATED_AT
poco       adb-a1b2c3d4-xyz._adb-tls-connect._tcp POCO F4        192.168.1.50:39845   2026-09-10 00:25:00
tablet     adb-99887766-abc._adb-tls-connect._tcp Galaxy Tab S9  192.168.1.80:41203   2026-09-09 21:10:00
```

### 4.2 Desain Antarmuka Perintah Baru

1. **Kelola Alias**:
   ```bash
   jaaw alias set <alias> [target_serial]   # Jika target dikosongkan, prompt picker interaktif
   jaaw alias list                          # Menampilkan seluruh alias tersimpan
   jaaw alias rm <alias>                    # Menghapus alias
   ```

2. **Pretty Device List**:
   ```bash
   jaaw devices
   # Output:
   # ALIAS    MODEL       STATUS   IP:PORT              REAL SERIAL / SERVICE
   # poco     POCO F4     device   192.168.1.50:39845   adb-a1b2c3d4-xyz._adb-tls-connect._tcp
   # -        Pixel 7     device   192.168.1.55:40129   adb-55667788-def._adb-tls-connect._tcp
   ```

3. **Execution Passthrough**:
   ```bash
   jaaw exec <alias> <adb-args...>          # Contoh: jaaw exec poco shell
   jaaw shell <alias>                       # Shortcut interaktif shell
   jaaw scrcpy <alias> [scrcpy-args...]     # Shortcut screen mirror
   ```

4. **Context / Target Selector**:
   ```bash
   jaaw use <alias>
   # Output instruksi / export environment:
   # export ANDROID_SERIAL="adb-a1b2c3d4-xyz._adb-tls-connect._tcp"
   ```

---

## 🍰 5. Rencana Vertical Slices & Task Sizing

### Slice 1: Database Alias Storage & CRUD Helper (Size: S)
- **Tugas**: 
  - Buat fungsi `get_alias_target()`, `set_device_alias()`, `remove_device_alias()`, dan `list_device_aliases()`.
  - Dukung interaktif picker saat menambahkan alias jika parameter target tidak disertakan.
- **Target File**: `bin/jaaw`
- **Verifikasi**: Uji penambahan, pembacaan, dan penghapusan alias dari terminal.

### Slice 2: Pretty Table Renderer jaaw devices (Size: S)
- **Tugas**:
  - Ambil daftar perangkat aktif dari `adb devices -l`.
  - Cross-reference dengan data mDNS / `aliases.tsv` / `devices.tsv`.
  - Tampilkan tabel terformat rapi dengan warna ANSI.
- **Target File**: `bin/jaaw`
- **Verifikasi**: Jalankan `jaaw devices` saat 0, 1, dan >1 perangkat nirkabel terhubung.

### Slice 3: Passthrough Execution & Context Switcher (Size: M)
- **Tugas**:
  - Implementasikan router argumen `exec`, `shell`, `scrcpy`, dan `use`.
  - Tangani resolusi alias ke serial riil secara cepat.
  - Berikan pesan error ramah jika alias belum terdaftar.
- **Target File**: `bin/jaaw`
- **Verifikasi**: Jalankan perintah `jaaw shell <alias>` dan validasi eksekusi perintah di HP target.

### Slice 4: Shell Integration & Autocompletion Update (Size: S)
- **Tugas**:
  - Buat command `jaaw init` yang mencetak fungsi shell wrapper transparan (`adb()`).
  - Update skrip auto-completion (Bash, Zsh, Fish) untuk mendukung tab-completion nama alias.
- **Target File**: `bin/jaaw`, `completions/jaaw.bash`, `completions/jaaw.zsh`, `completions/jaaw.fish`
- **Verifikasi**: Source file completion dan uji coba tab autocompletion untuk nama alias.

---

## 📋 6. Checkpoints & Matriks Verifikasi

### Checkpoint Fase:
- [x] **Checkpoint 1 (Alias Core)**: CRUD alias berfungsi stabil dan tersimpan presisten di `~/.config/jaaw/aliases.tsv`.
- [x] **Checkpoint 2 (CLI Commands)**: Perintah `devices`, `exec`, `shell`, dan `use` tervalidasi bekerja dengan benar.
- [x] **Checkpoint 3 (Shell & Completion)**: Autocompletion mengenali nama alias dan fungsi wrapper transparan berjalan lancar.

### Matriks Hasil Pengujian:
| No | Komponen / Pengujian | Kriteria Keberhasilan | Status |
|---|---|---|---|
| 1 | ShellCheck / Bash Syntax | 0 Error / Warning kritis pada `bin/jaaw` | **Pass (0 Errors)** |
| 2 | Alias CRUD Operations | Create, Read, Delete berhasil di TSV | **Pass (Tuntas)** |
| 3 | Pretty Devices Display | Render tabel rapi dan akurat | **Pass (Tuntas)** |
| 4 | Execution Passthrough & Wrapper | Perintah diteruskan ke real adb tanpa glitch | **Pass (Tuntas)** |

---

## ⏱️ 7. Riwayat Revisi & Audit Trail
| Tanggal & Waktu | Versi / Commit | Penulis | Ringkasan Perubahan |
|---|---|---|---|
| `2026-09-10 00:57 WIB` | `v2026.09.x` | Neflalabs & AI Pair | Implementasi tuntas: Alias CRUD, `jaaw devices`, `exec`, `shell`, `scrcpy`, `use`, `init`, completions, dan automated test suite |
| `2026-09-10 00:27 WIB` | `v2026.09.x` | Neflalabs & AI Pair | Perumusan spesifikasi fitur Device Alias Management & Smart Wrapper |

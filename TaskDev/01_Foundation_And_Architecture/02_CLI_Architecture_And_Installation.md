# 02 — CLI Architecture, Dependency Management & Shell Completions

**Metadata Tracking:**
* **Tanggal Dibuat:** `2026-09-08 07:55:00 WIB`
* **Pembaruan Terakhir:** `2026-09-08 07:55:00 WIB`
* **Status:** `Completed`
* **Target Versi / CalVer:** `v2026.08.29.1`
* **Kategori:** `Foundation & Architecture`
* **Komponen Terkait:** `bin/jaaw`, `install.sh`, `uninstall.sh`, `completions/`
* **Tags:** `[#cli, #installer, #bash, #completions]`

---

## 🎯 1. Latar Belakang Masalah & Tujuan

Sebelum `jaaw` dibuat, pengembang Android di Linux harus:
1. Membuka menu Developer Options di HP.
2. Mencatat IP address dan 5-digit port pairing manual.
3. Menjalankan `adb pair <IP>:<PORT>` dan memasukkan kode 6 digit.
4. Kembali mengecek IP dan port koneksi (yang berbeda dari port pairing), lalu menjalankan `adb connect <IP>:<CONNECT_PORT>`.

`jaaw` mengabstraksi seluruh proses ini menjadi satu ketukan tombol atau satu perintah CLI dengan QR code langsung di terminal.

---

## 🏗️ 2. Desain Arsitektur Eksekusi

### 2.1 Alur Bootstrapping CLI
```text
  User Invocation (e.g. jaaw -p)
                 │
                 ▼
        check_dependencies()
      (adb, qrencode, avahi)
                 │
                 ▼
       get_wifi_ssid() & Subnet
                 │
                 ▼
          Dispatch Action:
  ├── -p: flow_qr_pairing()
  ├── -c: flow_quick_connect()
  ├── -u: flow_usb_to_wireless()
  ├── -m: flow_manual_pair()
  ├── -l: flow_history()
  └── -d: flow_diagnostics()
```

### 2.2 Manajemen Dependensi Multi-Distro
Helper `install_hint()` menyediakan panduan perintah instalasi sesuai paket manajer aktif:
- Fedora/RHEL: `dnf install android-tools qrencode avahi-tools`
- Debian/Ubuntu: `apt install adb qrencode avahi-utils`
- Arch Linux: `pacman -S android-tools qrencode avahi`

---

## ⏱️ 3. Riwayat Revisi & Audit Trail
| Tanggal & Waktu | Versi / Commit | Penulis | Ringkasan Perubahan |
|---|---|---|---|
| `2026-09-08 07:55 WIB` | `v2026.08.29.1` | Neflalabs | Dokumentasi arsitektur CLI dan installer |

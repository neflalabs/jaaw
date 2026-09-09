# 01 — Project Compass & Architecture Tracker

**Metadata Tracking:**
* **Tanggal Dibuat:** `2026-09-08 07:55:00 WIB`
* **Pembaruan Terakhir:** `2026-09-10 00:58:00 WIB`
* **Status:** `In Progress`
* **Target Versi / CalVer:** `v2026.09.x`
* **Kategori:** `Foundation & Architecture`
* **Komponen Terkait:** `bin/jaaw`, `install.sh`, `Makefile`, `README.md`
* **Tags:** `[#compass, #architecture, #roadmap, #cli, #jaaw]`

---

## 🎯 1. Visi & Kompas Proyek

`jaaw` (**Jembatan Awakutu Android Wireless** / *Android Debug Bridge Wireless Companion*) adalah ekosistem perkakas CLI & Wizard modern di Linux untuk mengelola perangkat Android secara nirkabel, instan, dan elegan.

### Prinsip Utama Desain:
1. **Zero Configuration**: Tanpa konfigurasi rumit, mendeteksi Wi-Fi lokal, subnet, dan mDNS service secara otomatis.
2. **Sub-100ms Discovery**: Menggunakan streaming pipeline `avahi-browse` (event-driven via non-blocking FIFO pipe) dengan fallback ke `adb mdns check`.
3. **Pure Wireless First**: Mengutamakan alur nirkabel penuh (QR pairing & mDNS TLS auto-connect) dengan tetap menyediakan opsi 1-Click USB switch.
4. **Human-Friendly Terminal UX**: Penamaan perangkat humanis via alias (`jaaw alias`, `jaaw devices`) dan perintah passthrough tanpa menghafal serial mDNS acak.
5. **Integrated Companion Toolkit**: Screen mirroring `scrcpy` (tuning anti-jitter Wi-Fi), modul debloat interaktif, notifikasi desktop, dan diagnostik firewall.

---

## 🧭 2. Roadmap & Status Fase Pengembangan

### Fase 1: Fondasi CLI & Rendering QR (`Completed`)
- [x] Deteksi dependensi sistem (`adb`, `qrencode`, `avahi-tools` / `avahi-utils`).
- [x] Generator payload Wi-Fi ADB QR (`WIFI:T:ADB;S:<NAME>;P:<CODE>;;`).
- [x] Multi-engine rendering terminal (Kitty, iTerm2, ANSI UTF-8).
- [x] Skrip instalasi universal (`install.sh`, `uninstall.sh`, `Makefile`) dan shell completions (Bash, Zsh, Fish).

### Fase 2: Mesin Penemuan mDNS & Pairing TLS (`Completed`)
- [x] Sub-100ms real-time event streaming mDNS via Avahi FIFO.
- [x] Automatic polling fallback untuk distro dengan paket `adb mdns`.
- [x] Ekstraksi TXT record mDNS untuk model perangkat dan versi Android.
- [x] Alur pairing manual 6-digit PIN (`jaaw -m`).
- [x] 1-Click switch dari USB ke port TCP 5555 (`jaaw -u`).

### Fase 3: Modernisasi mDNS TLS Default Connection (`Completed` — `v2026.09.x`)
- [x] Prioritaskan koneksi via mDNS TLS service identifier (`adb-xxxx._adb-tls-connect._tcp`) pada `jaaw pair` dan `jaaw connect`.
- [x] Implementasi `safe_adb_connect` untuk memvalidasi status riil ADB (mitigasi silent exit code 0).
- [x] Deduplikasi deteksi perangkat pada Quick-Connect (`jaaw -c`).
- [x] Integrasi histori perangkat dan peluncuran `scrcpy` berbasis nama service TLS.

### Fase 4: Rebranding JAAW & Device Alias System (`Completed` — `v2026.09.x`)
- [x] Rebrand menyeluruh ke `jaaw` (**J**embatan **A**wakutu **A**ndroid **W**ireless).
- [x] Pembersihan jejak legacy `adbqr` di sistem dan migrasi riwayat perangkat ke `~/.config/jaaw/`.
- [x] Database alias perangkat persisten (`~/.config/jaaw/aliases.tsv`).
- [x] Sub-command `jaaw alias`, pretty table `jaaw devices`, dan context switcher `jaaw use`.
- [x] Smart passthrough command (`jaaw shell <alias>`, `jaaw exec`, `jaaw scrcpy <alias>`).
- [x] Shell completion update untuk auto-complete nama alias.

### Fase 5: Modul Debloater & Advanced Android Companion (`Planning`)
- [ ] Modul debloater interaktif berbasis terminal (preset Safe Xiaomi/HyperOS, Samsung OneUI, Google AOSP).
- [ ] Mekanisme rollback / restore package (`pm install-existing`).
- [ ] Wireless package installer & batch APK sideload.
- [ ] Auto-reconnect daemon opsional saat mendeteksi Wi-Fi terpercaya.

---

## ⏱️ 3. Riwayat Revisi & Audit Trail
| Tanggal & Waktu | Versi / Commit | Penulis | Ringkasan Perubahan |
|---|---|---|---|
| `2026-09-10 00:58 WIB` | `v2026.09.x` | Neflalabs | Fase 4 Tuntas: Integrasi penuh Device Alias Management, Smart Wrapper, pretty devices, dan autocompletion |
| `2026-09-10 00:49 WIB` | `v2026.09.x` | Neflalabs | Update identitas JAAW, penyesuaian roadmap Fase 4 (Alias) dan Fase 5 (Debloater) |
| `2026-09-08 07:55 WIB` | `v2026.08.29.1` | Neflalabs | Inisiasi kompas proyek dan pelacak status pengembangan |

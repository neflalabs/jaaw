# 01 — Terminal Graphics Protocols & Scrcpy Integration

**Metadata Tracking:**
* **Tanggal Dibuat:** `2026-09-08 07:55:00 WIB`
* **Pembaruan Terakhir:** `2026-09-08 07:55:00 WIB`
* **Status:** `Completed`
* **Target Versi / CalVer:** `v2026.08.29.1`
* **Kategori:** `Integrations & Terminal UX`
* **Komponen Terkait:** `bin/jaaw`
* **Tags:** `[#scrcpy, #kitty, #iterm2, #terminal, #graphics]`

---

## 🎯 1. Desain Rendering Gambar Terminal

Untuk kenyamanan scan QR oleh kamera HP, `jaaw` menyediakan 3 tingkatan rendering:
1. **Kitty Graphics Protocol** (Ghostty, Kitty terminal): Rendering bitmap PNG inline langsung ke framebuffer terminal tanpa pixelasi teks.
2. **iTerm2 Protocol** (WezTerm, iTerm2): Rendering base64 PNG inline.
3. **ANSI UTF-8 Fallback**: Karakter Unicode half-block (`▀`, `▄`) untuk terminal Linux standar (GNOME Terminal, Konsole, Alacritty, XFCE).

---

## ⚡ 2. Tuning Koneksi Nirkabel Scrcpy

Saat flag `-s` / `--screen` aktif, `maybe_launch_scrcpy()` menyematkan profil streaming optimal untuk jaringan Wi-Fi agar tidak patah-patah:
* `--video-buffer=50`: Mencegah micro-stutter akibat jitter transmisi nirkabel.
* `--audio-buffer=50`: Sinkronisasi audio stabil.
* `--max-size=1280`: Membatasi resolusi agar tidak membebani bandwidth jaringan lokal.
* `--max-fps=60`: Menghindari saturasi encoder perangkat ber-refresh rate tinggi (90Hz / 120Hz).
* `--video-bit-rate=6M`: Bitrate standar stabil untuk Wi-Fi rumah/kantor.

---

## ⏱️ 3. Riwayat Revisi & Audit Trail
| Tanggal & Waktu | Versi / Commit | Penulis | Ringkasan Perubahan |
|---|---|---|---|
| `2026-09-08 07:55 WIB` | `v2026.08.29.1` | Neflalabs | Dokumentasi tuning scrcpy dan protokol grafis terminal |

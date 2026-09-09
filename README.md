# jaaw 📱⚡

**Jembatan Awakutu Android Wireless** (Android Debug Bridge Wireless Companion for Linux)

[![CI](https://github.com/neflalabs/jaaw/actions/workflows/ci.yml/badge.svg)](https://github.com/neflalabs/jaaw/actions/workflows/ci.yml)
[![License: GPL v2](https://img.shields.io/badge/License-GPLv2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)

Tool CLI & Wizard Linux untuk menghubungkan **Android Wireless Debugging** (Android 11 – 16+) menggunakan **QR Code** di terminal secara instan tanpa perlu Android Studio atau mengetik IP & port pairing secara manual.

---

## ✨ Fitur Utama

- ⚡ **Deteksi Instan (<100ms)**: Menggunakan streaming event mDNS Avahi secara real-time.
- 🏷️ **Device Alias & Smart Wrapper**: Beri nama alias humanis (misal: `poco`, `tab`) untuk menggantikan serial TLS acak yang panjang, dengan perintah `jaaw shell <alias>`, `jaaw scrcpy <alias>`, dan wrapper transparan.
- 📶 **Deteksi Wi-Fi Aktif**: Menampilkan nama SSID Wi-Fi yang sedang terhubung di laptop.
- 🔄 **Auto-Connect**: Otomatis mencari port debugging dan langsung menghubungkan perangkat setelah pairing sukses.
- 🖥️ **Integrasi scrcpy (`-s` / `--screen`)**: Otomatis membuka mirror layar HP segera setelah terhubung.
- 🔔 **Notifikasi Desktop**: Mengirim notifikasi sistem saat HP berhasil tersambung.
- 🔌 **1-Click USB to Wireless**: Beralih dari mode kabel USB ke Wireless ADB (`adb tcpip 5555`) dalam satu langkah.
- 📜 **Device History**: Menyimpan riwayat IP & perangkat yang pernah terhubung di `~/.config/jaaw/`.
- 🔄 **Self-Updater**: Perbarui tool dan auto-completions langsung dari GitHub dengan `jaaw update`.
- ⌨️ **Shell Auto-Completion**: Dukungan autocomplete TAB untuk **Bash**, **Zsh**, dan **Fish**.
- 🖼️ **Dukungan Terminal Luas**: Rendering gambar beresolusi tinggi di terminal Ghostty/Kitty/WezTerm serta fallback ANSI UTF-8 untuk terminal standar.

---

## 📦 Dependensi

```sh
# Fedora
sudo dnf install android-tools qrencode avahi-tools

# Debian / Ubuntu
sudo apt install adb qrencode avahi-utils

# Arch Linux
sudo pacman -S android-tools qrencode avahi
```

*(Opsional)* Pasang `scrcpy` untuk fitur screen mirroring: `sudo dnf install scrcpy` / `sudo apt install scrcpy`.

---

## 🚀 Instalasi & Hapus

### One-line Install (Langsung dari GitHub)
```sh
curl -fsSL https://raw.githubusercontent.com/neflalabs/jaaw/main/install.sh | bash
```

### One-line Uninstall
```sh
# Uninstall standar
curl -fsSL https://raw.githubusercontent.com/neflalabs/jaaw/main/uninstall.sh | bash

# Uninstall beserta hapus riwayat & config (~/.config/jaaw)
curl -fsSL https://raw.githubusercontent.com/neflalabs/jaaw/main/uninstall.sh | bash -s -- --purge
```

### Atau via Clone Repo Manual
```sh
# Install ke /usr/local/bin (beserta shell completions)
sudo ./install.sh

# Uninstall
sudo ./uninstall.sh

# Uninstall & hapus seluruh riwayat perangkat (~/.config/jaaw)
sudo ./uninstall.sh --purge
```

---

## 💻 Penggunaan

```sh
jaaw                 # Menampilkan menu bantuan (help)
jaaw -p              # Scan QR code & auto-connect
jaaw -w              # Menu TUI Wizard interaktif
jaaw -c              # Quick-connect ke perangkat aktif di Wi-Fi
jaaw -u              # Ubah koneksi kabel USB ke Wi-Fi (port 5555)
jaaw -s              # Konek & otomatis buka mirror scrcpy (Smooth Wi-Fi preset)
jaaw -c -s -b 2M     # Quick connect + scrcpy bitrate 2M
jaaw -s --screen-off # Konek + scrcpy dengan layar HP mati (--turn-screen-off)
jaaw -s -- -b 2M --stay-awake # Teruskan argumen mentah ke scrcpy via '--'
jaaw -m              # Pairing manual dengan 6-digit code & IP:Port
jaaw -l              # Lihat riwayat perangkat tersimpan
jaaw -d              # Diagnostik sistem, firewall, dan status mDNS
jaaw -r              # Putus koneksi & restart ADB server
jaaw update          # Periksa & unduh pembaruan jaaw dari GitHub
jaaw -v              # Tampilkan versi & info pembuat

# Manajemen Alias & Smart Execution
jaaw alias set poco       # Beri alias 'poco' pada perangkat
jaaw alias list           # Tampilkan daftar alias yang tersimpan
jaaw alias rm poco        # Hapus alias
jaaw devices              # Tampilkan tabel rapi perangkat aktif + mapping alias
jaaw shell poco           # Shortcut masuk ke adb shell perangkat 'poco'
jaaw scrcpy poco          # Buka scrcpy mirror layar perangkat 'poco'
jaaw exec poco <perintah> # Jalankan perintah ADB langsung ke alias
jaaw use poco             # Set sesi shell aktif ke target 'poco'
eval "$(jaaw init)"       # Aktifkan alias transparan: 'adb -s poco shell'
```

### 📱 Langkah di HP Android:
1. Buka **Settings** > **Developer options**.
2. Aktifkan **Wireless debugging** lalu ketuk menu tersebut.
3. Pilih **Pair device with QR code** dan arahkan kamera HP ke QR di terminal.

### ⚡ Mirroring Lancar di Wi-Fi (`scrcpy`)
Secara default saat menggunakan flag `-s`, `jaaw` menerapkan tuning optimal untuk koneksi nirkabel (jitter buffer 50ms, cap 60 FPS, max resolution 1280px) agar streaming mulus tanpa patah-patah / micro-stutters. Anda juga bisa mengatur default argumen melalui environment variable:
```sh
export SCRCPY_ARGS="-b 4M --video-buffer=50 --turn-screen-off"
```

---

## ⚠️ Catatan Wi-Fi Publik / Isolasi AP
Jika berada di Wi-Fi publik (kampus, kafe, kantor) yang mengaktifkan *AP Isolation*, mDNS antar perangkat akan diblokir oleh router. Gunakan **Hotspot HP** atau opsi **1-Click USB to Wireless** (`jaaw --usb`).

---

## 📄 Lisensi

Didistribusikan di bawah lisensi **GNU General Public License v2.0 (GPL-2.0)**.




# ADB_MDNS_CHEATSHEET

**Metadata:**
* **Tanggal Dibuat:** `2026-09-08 07:55:00 WIB`
* **Pembaruan Terakhir:** `2026-09-08 07:55:00 WIB`
* **Kategori:** `Quick Reference / Operational Runbook`
* **Tags:** `[#cheatsheet, #adb, #mdns, #troubleshooting]`

---

## 🎯 1. Perintah Kunci Diagnostik mDNS ADB

```bash
# 1. Cek status daemon mDNS di ADB
adb mdns check

# 2. Lihat seluruh layanan mDNS yang terdeteksi oleh ADB server
adb mdns services

# 3. Pantau siaran mDNS via Avahi secara real-time
avahi-browse -r -p "_adb-tls-connect._tcp"
avahi-browse -r -p "_adb-tls-pairing._tcp"

# 4. Hubungkan langsung via service name mDNS TLS
adb connect "<service-name>._adb-tls-connect._tcp"

# 5. Eksekusi perintah shell menggunakan Transport ID (-t)
adb -t 1 shell
```

---

## ⚠️ 2. Solusi Masalah Umum (*Troubleshooting*)

1. **Konflik Nama mDNS dengan Sufiks `(2)`**:
   * Masalah: Nama muncul sebagai `adb-xxxx (2)._adb-tls-connect._tcp`.
   * Solusi: Terjadi akibat cache DNS/Avahi lama belum kedaluwarsa. Jalankan `adb kill-server && adb start-server`, lalu matikan dan nyalakan toggle Wireless Debugging di HP.

2. **AP Isolation di Wi-Fi Publik**:
   * Masalah: mDNS tidak terdeteksi sama sekali meskipun HP dan laptop terhubung ke Wi-Fi yang sama.
   * Solusi: Router memblokir lalu lintas antar klien (AP Isolation). Gunakan Hotspot dari HP atau gunakan mode 1-Click USB switch (`jaaw -u`).

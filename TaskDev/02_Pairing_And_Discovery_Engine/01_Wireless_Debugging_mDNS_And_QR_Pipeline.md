# 01 — Wireless Debugging mDNS Discovery & QR Pairing Pipeline

**Metadata Tracking:**
* **Tanggal Dibuat:** `2026-09-08 07:55:00 WIB`
* **Pembaruan Terakhir:** `2026-09-08 07:55:00 WIB`
* **Status:** `Completed`
* **Target Versi / CalVer:** `v2026.08.29.1`
* **Kategori:** `Pairing & Discovery Engine`
* **Komponen Terkait:** `bin/jaaw`
* **Tags:** `[#mdns, #qr, #pairing, #avahi]`

---

## 🎯 1. Konsep & Payload QR Android 11+

Fitur *Wireless Debugging* Android 11 ke atas menerima pairing QR code dengan format payload Wi-Fi standar:
```text
WIFI:T:ADB;S:<SERVICE_NAME>;P:<PAIRING_CODE>;;
```
* **`S:<SERVICE_NAME>`**: Nama service unik (contoh: `jaaw-a1b2c3d4`).
* **`P:<PAIRING_CODE>`**: PIN numerik 6 digit acak yang dibuat oleh CLI.

---

## 🏗️ 2. Sub-100ms Event Streaming Discovery

Daripada melakukan polling berulang (`sleep 1 && avahi-browse`), `jaaw` memanfaatkan **Linux Named Pipe (FIFO)**:
```bash
fifo=$(mktemp -u "${TMPDIR:-/tmp}/jaaw-fifo.XXXXXX")
mkfifo "$fifo"
exec 3<>"$fifo"
avahi-browse -r -p "$service_type" >&3 2>/dev/null &
```

Setiap paket mDNS yang masuk dibaca secara *non-blocking* (`read -r -t 0.1 -u 3`) sehingga latency respons di bawah 100ms dan animasi spinner UI tetap lancar.

---

## ⏱️ 3. Riwayat Revisi & Audit Trail
| Tanggal & Waktu | Versi / Commit | Penulis | Ringkasan Perubahan |
|---|---|---|---|
| `2026-09-08 07:55 WIB` | `v2026.08.29.1` | Neflalabs | Dokumentasi pipeline mDNS discovery dan QR code |

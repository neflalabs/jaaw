# 02 — Default mDNS TLS Connection Refactor & Silent Failure Mitigation

**Metadata Tracking:**
* **Tanggal Dibuat:** `2026-09-08 07:55:00 WIB`
* **Pembaruan Terakhir:** `2026-09-08 07:55:00 WIB`
* **Status:** `Completed`
* **Target Versi / CalVer:** `v2026.09.x`
* **Kategori:** `Pairing & Discovery Engine`
* **Komponen Terkait:** `bin/jaaw`
* **Tags:** `[#mdns, #tls, #autoconnect, #bugfix, #refactor]`

---

## 🎯 1. Latar Belakang Masalah & Keputusan

### 1.1 Masalah
1. Sebelumnya, setelah pairing berhasil, `auto_connect_device()` selalu menghubungkan ke alamat IP fisik dan port mentah (`adb connect 192.168.1.50:41235`).
2. Masalah muncul ketika perangkat Android me-restart koneksi Wi-Fi atau DHCP me-refresh IP/Port: koneksi ADB terputus dan pengguna harus manual melakukan koneksi ulang.
3. Sebaliknya, koneksi melalui service mDNS TLS (`adb-xxxx._adb-tls-connect._tcp`) memungkinkan ADB Server secara otomatis melacak port dan IP yang berubah secara dinamis di jaringan lokal.
4. Perintah `adb connect` memiliki kelemahan bawaan: sering kali mengembalikan exit code `0` meskipun koneksi gagal (misal: *Connection refused* atau *Name or service not known*).

### 1.2 Solusi Terpilih
1. Menjadikan koneksi via nama service mDNS TLS (`_adb-tls-connect._tcp`) sebagai **prioritas default** pada `auto_connect_device()` dan `flow_quick_connect()`.
2. Menyediakan fallback otomatis ke alamat `IP:Port` jika resolusi service mDNS gagal.
3. Menambahkan fungsi pembungkus `safe_adb_connect()` untuk memvalidasi output `connected to` atau `already connected to`.
4. Melakukan deduplikasi entri mDNS pada `flow_quick_connect()` agar perangkat tidak muncul ganda di daftar menu.

---

## 🏗️ 2. Perubahan Kode & Arsitektur

### 2.1 Ekstraksi `TARGET_SERVICE` pada Discovery Engine
```bash
# Avahi stream parser
[ -n "$name" ] && [ -n "$type" ] && TARGET_SERVICE="$name.$type"

# Fallback parser
res=$(adb mdns services 2>/dev/null | awk -F'\t' -v svc="$service_type" -v name="$target_name" '
    $2 ~ svc {
        if (name == "" || index($1, name) > 0) {
            print $3 "|" $1 "." $2;
            exit;
        }
    }
')
```

### 2.2 Validasi Respon ADB (`safe_adb_connect`)
```bash
# ❌ Kode Lama:
if adb connect "$connect_addr"; then
    # Menganggap berhasil meski output adalah "Connection refused" (exit code 0)
fi

# ✅ Kode Baru:
safe_adb_connect() {
    local target="$1"
    local output
    output=$(adb connect "$target" 2>&1)
    echo "$output"
    if [[ "$output" == *"connected to "* ]] || [[ "$output" == *"already connected to "* ]]; then
        return 0
    fi
    return 1
}
```

### 2.3 Alur Prioritas Auto-Connect
```text
      stream_discover_mdns()
                 │
      ┌──────────┴──────────┐
      ▼                     ▼
TARGET_SERVICE         TARGET_ADDR
 (mDNS TLS Name)        (IP:Port)
      │                     │
      ▼ (Prioritas 1)       │
safe_adb_connect "$svc"     │
      │                     │
      ├── [Sukses] ─────────┼──────> Selesai & Luncurkan scrcpy
      │                     │
      ▼ [Gagal]             ▼ (Prioritas 2)
                 safe_adb_connect "$ip:$port"
                            │
                            ├── [Sukses] ──> Selesai
                            └── [Gagal] ───> Prompt Port Manual
```

---

## 📋 3. Matriks Hasil Pengujian & Verifikasi

| No | Kasus Uji | Target | Hasil Ekspektasi | Status |
|---|---|---|---|---|
| 1 | Syntax Check | `make check` | Bash syntax valid tanpa error | ✅ Pass |
| 2 | Connect via mDNS TLS | `adb-xxxx._adb-tls-connect._tcp` | Perangkat terhubung dan terdaftar di `adb devices -l` | ✅ Pass |
| 3 | Scrcpy Invocation Target | `-s "adb-xxxx._adb-tls-connect._tcp"` | Target serial diterima tanpa error parsing | ✅ Pass |
| 4 | Exit Code Failure Check | Port dummy / non-existent | `safe_adb_connect` mengembalikan exit code 1 | ✅ Pass |

---

## ⏱️ 4. Riwayat Revisi & Audit Trail
| Tanggal & Waktu | Versi / Commit | Penulis | Ringkasan Perubahan |
|---|---|---|---|
| `2026-09-08 07:55 WIB` | `v2026.09.x` | Neflalabs | Implementasi default koneksi mDNS TLS, safe_adb_connect, dan deduplikasi perangkat |

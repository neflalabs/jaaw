# Fish completion for jaaw

complete -c jaaw -f

function __jaaw_aliases
    set -l alias_file "$HOME/.config/jaaw/aliases.tsv"
    if test -f "$alias_file"
        awk -F'\t' '$1 !~ /^#/ && NF {printf "%s\t%s (%s)\n", $1, $3, $2}' "$alias_file" 2>/dev/null
    end
end

# Subcommands
complete -c jaaw -n "__fish_use_subcommand" -a "alias" -d "Kelola alias nama perangkat Android"
complete -c jaaw -n "__fish_use_subcommand" -a "devices" -d "Tampilkan tabel perangkat aktif dengan mapping alias"
complete -c jaaw -n "__fish_use_subcommand" -a "exec" -d "Jalankan perintah ADB pada alias target"
complete -c jaaw -n "__fish_use_subcommand" -a "shell" -d "Buka shell ADB interaktif pada alias target"
complete -c jaaw -n "__fish_use_subcommand" -a "scrcpy" -d "Buka mirror screen scrcpy pada alias target"
complete -c jaaw -n "__fish_use_subcommand" -a "use" -d "Pilih perangkat aktif (export ANDROID_SERIAL)"
complete -c jaaw -n "__fish_use_subcommand" -a "init" -d "Inisialisasi wrapper shell fungsi adb transparan"
complete -c jaaw -n "__fish_use_subcommand" -a "update" -d "Periksa dan pasang pembaruan terbaru dari GitHub"

# Subcommand arguments
complete -c jaaw -n "__fish_seen_subcommand_from alias" -a "set list rm get"
complete -c jaaw -n "__fish_seen_subcommand_from alias; and __fish_prev_arg_in rm get" -a "(__jaaw_aliases)"
complete -c jaaw -n "__fish_seen_subcommand_from exec shell scrcpy use" -a "(__jaaw_aliases)"
complete -c jaaw -n "__fish_seen_subcommand_from init" -a "bash zsh fish"

# Modes & Actions
complete -c jaaw -s w -l wizard -d "Buka menu wizard TUI interaktif"
complete -c jaaw -s p -l pair -d "Pairing via QR Code dan auto-connect"
complete -c jaaw -s c -l connect -d "Quick-connect ke perangkat aktif di Wi-Fi"
complete -c jaaw -s u -l usb -d "Alihkan perangkat USB ke Wireless ADB port 5555"
complete -c jaaw -s m -l manual -d "Pairing manual dengan 6-digit code & IP:Port"
complete -c jaaw -s l -l list -d "Lihat riwayat perangkat tersimpan"
complete -c jaaw -s d -l diag -d "Jalankan diagnostik sistem & firewall"
complete -c jaaw -s r -l reset -d "Restart ADB server & disconnect perangkat"
complete -c jaaw -s U -l update -d "Periksa dan pasang pembaruan terbaru dari GitHub"

# Mirroring & Streaming
complete -c jaaw -s s -l screen -d "Auto-launch scrcpy mirror screen setelah konek"
complete -c jaaw -s b -l bitrate -x -a "1M 2M 4M 6M 8M 12M 16M" -d "Set custom scrcpy video bitrate"
complete -c jaaw -l screen-off -l off -d "Matikan layar HP saat mirror screen"
complete -c jaaw -l scrcpy-args -x -d "Kirim argumen custom ke scrcpy"

# General Options
complete -c jaaw -s t -l timeout -x -a "10 30 60 120" -d "Set timeout deteksi mDNS (detik)"
complete -c jaaw -s v -l version -d "Tampilkan informasi versi & pembuat"
complete -c jaaw -s h -l help -d "Tampilkan bantuan"

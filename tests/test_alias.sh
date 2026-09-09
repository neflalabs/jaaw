#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
JAAW_BIN="$PROJECT_ROOT/bin/jaaw"

echo "=== Running JAAW Alias & Smart Wrapper Test Suite ==="

# Temporary directory for test environment
TEST_TMP="$(mktemp -d /tmp/jaaw-test.XXXXXX)"
trap 'rm -rf "$TEST_TMP"' EXIT

export XDG_CONFIG_HOME="$TEST_TMP/config"
export CONFIG_DIR="$XDG_CONFIG_HOME/jaaw"
export ALIAS_FILE="$CONFIG_DIR/aliases.tsv"
export HISTORY_FILE="$CONFIG_DIR/devices.tsv"
mkdir -p "$CONFIG_DIR"

# 1. Test alias set
echo "[1] Testing jaaw alias set..."
"$JAAW_BIN" alias set poco "adb-a1b2c3d4-xyz._adb-tls-connect._tcp" "POCO F4" "192.168.1.50:39845"
[ -f "$ALIAS_FILE" ] || { echo "FAIL: ALIAS_FILE was not created!"; exit 1; }

# 2. Test alias get
echo "[2] Testing jaaw alias get..."
TARGET=$("$JAAW_BIN" alias get poco)
if [ "$TARGET" != "adb-a1b2c3d4-xyz._adb-tls-connect._tcp" ]; then
    echo "FAIL: Expected adb-a1b2c3d4-xyz._adb-tls-connect._tcp, got: $TARGET"
    exit 1
fi

# 3. Test nonexistent alias get
echo "[3] Testing nonexistent alias get..."
if "$JAAW_BIN" alias get nonexistent 2>/dev/null; then
    echo "FAIL: Expected non-zero exit for nonexistent alias"
    exit 1
fi

# 4. Test adding second alias
echo "[4] Testing adding second alias..."
"$JAAW_BIN" alias set tablet "adb-99887766-tab._adb-tls-connect._tcp" "Galaxy Tab S9" "192.168.1.80:41203"
TAB_TARGET=$("$JAAW_BIN" alias get tablet)
if [ "$TAB_TARGET" != "adb-99887766-tab._adb-tls-connect._tcp" ]; then
    echo "FAIL: Expected tablet target, got: $TAB_TARGET"
    exit 1
fi

# 5. Test alias list output
echo "[5] Testing jaaw alias list..."
LIST_OUT=$("$JAAW_BIN" alias list)
echo "$LIST_OUT" | grep -q "poco" || { echo "FAIL: 'poco' not in alias list"; exit 1; }
echo "$LIST_OUT" | grep -q "tablet" || { echo "FAIL: 'tablet' not in alias list"; exit 1; }
echo "$LIST_OUT" | grep -q "POCO F4" || { echo "FAIL: 'POCO F4' not in alias list"; exit 1; }

# 6. Test jaaw use
echo "[6] Testing jaaw use..."
USE_OUT=$("$JAAW_BIN" use poco 2>/dev/null)
if [[ "$USE_OUT" != *"export ANDROID_SERIAL=\"adb-a1b2c3d4-xyz._adb-tls-connect._tcp\""* ]]; then
    echo "FAIL: jaaw use output incorrect: $USE_OUT"
    exit 1
fi

# 7. Test jaaw devices (runs gracefully even with no real ADB devices)
echo "[7] Testing jaaw devices..."
"$JAAW_BIN" devices >/dev/null 2>&1 || true

# 8. Test jaaw init (bash & zsh wrapper syntax & eval)
echo "[8] Testing jaaw init..."
INIT_BASH=$("$JAAW_BIN" init bash)
echo "$INIT_BASH" | bash -n || { echo "FAIL: syntax error in jaaw init bash"; exit 1; }

if command -v zsh >/dev/null 2>&1; then
    INIT_ZSH=$("$JAAW_BIN" init zsh)
    echo "$INIT_ZSH" | zsh -n || { echo "FAIL: syntax error in jaaw init zsh"; exit 1; }
fi

INIT_FISH=$("$JAAW_BIN" init fish)
[ -n "$INIT_FISH" ] || { echo "FAIL: jaaw init fish returned empty"; exit 1; }

# Test smart wrapper functionality in a subshell
echo "[9] Testing smart shell wrapper in subshell..."
MOCK_BIN_DIR="$TEST_TMP/mock_bin"
mkdir -p "$MOCK_BIN_DIR"
cat << 'EOF' > "$MOCK_BIN_DIR/adb"
#!/usr/bin/env bash
echo "MOCK_ADB_CALLED: $@"
EOF
chmod +x "$MOCK_BIN_DIR/adb"

(
    export PATH="$PROJECT_ROOT/bin:$MOCK_BIN_DIR:$PATH"
    
    # Eval the jaaw init wrapper
    eval "$("$JAAW_BIN" init bash)"

    # Test alias resolution in wrapper
    OUT1=$(adb -s poco shell ls /sdcard)
    if [[ "$OUT1" != *"MOCK_ADB_CALLED: -s adb-a1b2c3d4-xyz._adb-tls-connect._tcp shell ls /sdcard"* ]]; then
        echo "FAIL: adb wrapper did not resolve poco: $OUT1"
        exit 1
    fi

    # Test attached flag -spoco
    OUT2=$(adb -spoco getprop)
    if [[ "$OUT2" != *"MOCK_ADB_CALLED: -s adb-a1b2c3d4-xyz._adb-tls-connect._tcp getprop"* ]] && [[ "$OUT2" != *"MOCK_ADB_CALLED: -sadb-a1b2c3d4-xyz._adb-tls-connect._tcp getprop"* ]]; then
        echo "FAIL: adb wrapper did not resolve -spoco: $OUT2"
        exit 1
    fi

    # Test non-alias target passthrough
    OUT3=$(adb -s 192.168.1.99:5555 shell)
    if [[ "$OUT3" != *"MOCK_ADB_CALLED: -s 192.168.1.99:5555 shell"* ]]; then
        echo "FAIL: adb wrapper altered non-alias: $OUT3"
        exit 1
    fi

    # Test command without -s
    OUT4=$(adb devices -l)
    if [[ "$OUT4" != *"MOCK_ADB_CALLED: devices -l"* ]]; then
        echo "FAIL: adb wrapper broke normal adb devices: $OUT4"
        exit 1
    fi
)

if command -v zsh >/dev/null 2>&1; then
    echo "[9b] Testing smart shell wrapper in zsh..."
    zsh -c '
        export XDG_CONFIG_HOME="'"$XDG_CONFIG_HOME"'"
        MOCK_BIN_DIR="'"$MOCK_BIN_DIR"'"
        PATH="'"$PROJECT_ROOT/bin:$MOCK_BIN_DIR:$PATH"'"
        eval "$("'"$JAAW_BIN"'" init zsh)"
        OUT=$(adb -s tablet shell getprop)
        [[ "$OUT" == *"MOCK_ADB_CALLED: -s adb-99887766-tab._adb-tls-connect._tcp shell getprop"* ]] || {
            echo "FAIL: zsh wrapper failed: $OUT"
            exit 1
        }
    '
fi

echo "[9c] Testing serial with spaces and mDNS parentheses..."
"$JAAW_BIN" alias set space_dev "adb-28c77a26-gVrR7o (2)._adb-tls-connect._tcp" "POCO X3" "-"
SPACE_TARGET=$("$JAAW_BIN" alias get space_dev)
if [ "$SPACE_TARGET" != "adb-28c77a26-gVrR7o (2)._adb-tls-connect._tcp" ]; then
    echo "FAIL: Expected serial with space and (2), got: $SPACE_TARGET"
    exit 1
fi

# 10. Test alias remove
echo "[10] Testing jaaw alias rm..."
"$JAAW_BIN" alias rm poco
if "$JAAW_BIN" alias get poco 2>/dev/null; then
    echo "FAIL: 'poco' still exists after rm!"; exit 1;
fi
# 'tablet' should still exist
"$JAAW_BIN" alias get tablet >/dev/null || { echo "FAIL: 'tablet' was incorrectly deleted!"; exit 1; }

echo ""
echo "=== ALL TESTS PASSED SUCCESSFULLY! ==="

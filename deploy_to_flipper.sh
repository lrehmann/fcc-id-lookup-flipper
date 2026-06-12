#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

MODE="fast-start"
PORT="auto"
for arg in "$@"; do
    case "$arg" in
        --catalog)
            MODE="catalog"
            ;;
        --fast-start)
            MODE="fast-start"
            ;;
        -*)
            echo "Unknown option: $arg" >&2
            echo "Usage: $0 [--fast-start|--catalog] [serial-port|auto]" >&2
            exit 2
            ;;
        *)
            PORT="$arg"
            ;;
    esac
done

UFBT_HOME_DIR="$PWD/.ufbt"
PY="$PWD/.venv/bin/python"
UFBT="$PWD/.venv/bin/ufbt"
TARGET="/ext/apps/Tools/fcc_id_lookup.fap"
DB_LOCAL="$PWD/files/fcc_freq_v2.fcz"
DB_TARGET_DIR="/ext/apps_data/fcc_id_lookup"
DB_TARGET="$DB_TARGET_DIR/fcc_freq_v2.fcz"

if [ ! -x "$PY" ]; then
    python3 -m venv .venv
fi

if [ ! -x "$UFBT" ]; then
    "$PY" -m pip install --upgrade pip ufbt colorlog pyserial requests
fi

if [ "$MODE" = "catalog" ]; then
    echo "Building catalog-style FAP with bundled app assets."
    UFBT_HOME="$UFBT_HOME_DIR" "$UFBT" build
    FAP="$PWD/.ufbt/build/fcc_id_lookup.fap"
else
    echo "Building fast-start local FAP with database sidecar."
    FAST_APP_DIR="$PWD/.ufbt/fast_start_app"
    rm -rf "$FAST_APP_DIR"
    mkdir -p "$FAST_APP_DIR"
    cp application.fam fcc_id_lookup.c fcc_id_lookup_icon.png fcc_qr_code.h "$FAST_APP_DIR/"
    "$PY" - "$FAST_APP_DIR/application.fam" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
text = text.replace('    fap_file_assets="files",\n', '')
text = text.replace(
    '    sources=["fcc_id_lookup.c"],\n',
    '    cdefines=["FCC_SIDELOAD_DB"],\n    sources=["fcc_id_lookup.c"],\n',
)
path.write_text(text)
PY
    (
        cd "$FAST_APP_DIR"
        UFBT_HOME="$UFBT_HOME_DIR" "$UFBT" build
    )
    FAP="$FAST_APP_DIR/.ufbt/build/fcc_id_lookup.fap"
    if [ ! -f "$FAP" ]; then
        FAP="$PWD/.ufbt/build/fcc_id_lookup.fap"
    fi
fi

RESOLVED_PORT="$("$PY" - "$PORT" <<'PY'
import sys
from serial.tools import list_ports

requested = sys.argv[1]
if requested != "auto":
    print(requested)
    raise SystemExit(0)

matches = []
for port in list_ports.comports():
    serial_number = port.serial_number or ""
    description = port.description or ""
    device = port.device or ""
    if serial_number.startswith("flip_") or "Flipper" in description or "usbmodemflip_" in device:
        matches.append(device)

if not matches:
    print("No Flipper serial port found.", file=sys.stderr)
    raise SystemExit(2)
if len(matches) > 1:
    print("Multiple Flippers found; pass one serial port explicitly:", file=sys.stderr)
    for match in matches:
        print(f"  {match}", file=sys.stderr)
    raise SystemExit(2)

print(matches[0])
PY
)"

"$PY" - "$RESOLVED_PORT" <<'PY'
import serial
import sys
import time

port = sys.argv[1]
try:
    ser = serial.Serial(port, 115200, timeout=0.25, write_timeout=1)
except Exception as exc:
    print(f"Cannot open Flipper serial port {port}: {exc}", file=sys.stderr)
    raise SystemExit(2)

try:
    ser.write(b"\x03\r")
    ser.flush()
    time.sleep(0.3)
    ser.reset_input_buffer()
    ser.write(b"loader close\r")
    ser.flush()
    time.sleep(0.5)
finally:
    ser.close()
PY

"$PY" - "$UFBT_HOME_DIR" "$RESOLVED_PORT" "$FAP" "$TARGET" "$MODE" "$DB_LOCAL" "$DB_TARGET_DIR" "$DB_TARGET" <<'PY'
import os
import sys

ufbt_home, port, fap, target, mode, db_local, db_target_dir, db_target = sys.argv[1:]
sys.path.insert(0, os.path.join(ufbt_home, "current", "scripts"))

from flipper.storage import FlipperStorage, FlipperStorageOperations

with FlipperStorage(port) as storage:
    ops = FlipperStorageOperations(storage)
    ops.send_file_to_storage(target, fap, True)

    if mode == "fast-start":
        for stale_path in (
            "/ext/apps_assets/fcc_id_lookup/fcc_freq_v2.fcz",
            "/ext/apps_assets/fcc_id_lookup/.assets.signature",
            "/ext/apps_assets/fcc_id_lookup",
        ):
            try:
                storage.remove(stale_path)
            except Exception:
                pass

        ops.mkpath(db_target_dir)
        local_size = os.path.getsize(db_local)
        remote_size = None
        try:
            remote_size = storage.size(db_target)
        except Exception:
            remote_size = None

        if remote_size == local_size:
            print(f"Database sidecar already present ({remote_size} bytes); skipping upload.")
        else:
            ops.send_file_to_storage(db_target, db_local, True)
            print(f"Uploaded database sidecar ({local_size} bytes).")
PY

echo "Installed FCC ID Lookup."
if [ "$MODE" = "catalog" ]; then
    echo "Mode: catalog bundled assets. First launch may wait while Flipper unpacks assets."
else
    echo "Mode: fast-start sidecar. Splash should appear before database preparation."
fi
echo "Launch it from Apps > Tools > FCC ID Lookup on the Flipper."

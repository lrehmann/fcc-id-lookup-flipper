#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PORT="${1:-auto}"
UFBT_HOME_DIR="$PWD/.ufbt"
PY="$PWD/.venv/bin/python"
UFBT="$PWD/.venv/bin/ufbt"
FAP="$PWD/.ufbt/build/fcc_id_lookup.fap"
TARGET="/ext/apps/Tools/fcc_id_lookup.fap"

if [ ! -x "$PY" ]; then
    python3 -m venv .venv
fi

if [ ! -x "$UFBT" ]; then
    "$PY" -m pip install --upgrade pip ufbt colorlog pyserial requests
fi

UFBT_HOME="$UFBT_HOME_DIR" "$UFBT" build

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
    if serial_number.startswith("flip_") or "Flipper" in description or "flip_" in device:
        matches.append(device)

if not matches:
    print("No connected Flipper serial port found.", file=sys.stderr)
    raise SystemExit(2)

print(matches[0])
PY
)"

"$PY" - "$RESOLVED_PORT" <<'PY'
import sys
import time
import serial

port = sys.argv[1]
try:
    ser = serial.Serial(port, 115200, timeout=0.25, write_timeout=1)
except Exception as exc:
    print(f"Cannot open Flipper serial port {port}: {exc}", file=sys.stderr)
    raise SystemExit(2)

try:
    ser.reset_input_buffer()
    for payload in (b"\x03", b"\r", b"device_info\r"):
        ser.write(payload)
        ser.flush()
        time.sleep(0.25)

    deadline = time.time() + 5
    data = bytearray()
    while time.time() < deadline:
        chunk = ser.read(256)
        if chunk:
            data.extend(chunk)
            if b"hardware_model" in data or b">:" in data:
                break
finally:
    ser.close()

if b"hardware_model" not in data and b">:" not in data:
    print(
        f"Flipper CLI is not responding on {port}.\n"
        "Reboot the Flipper, reconnect USB, then rerun this script.\n"
        "If the previous FCC ID Lookup build crashed, the device may expose USB "
        "while the CLI is still wedged.",
        file=sys.stderr,
    )
    raise SystemExit(3)

try:
    ser = serial.Serial(port, 115200, timeout=0.25, write_timeout=1)
    ser.write(b"loader close\r")
    ser.flush()
    time.sleep(0.5)
finally:
    try:
        ser.close()
    except Exception:
        pass
PY

"$PY" - "$UFBT_HOME_DIR" "$PY" "$RESOLVED_PORT" "$FAP" "$TARGET" <<'PY'
import os
import subprocess
import sys

ufbt_home, python, port, fap, target = sys.argv[1:]
env = os.environ.copy()
env["UFBT_HOME"] = ufbt_home
cmd = [
    python,
    os.path.join(ufbt_home, "current", "scripts", "storage.py"),
    "-p",
    port,
    "send",
    "-f",
    fap,
    target,
]

try:
    subprocess.run(cmd, env=env, check=True, timeout=240)
except subprocess.TimeoutExpired:
    print(
        "Timed out while installing to the Flipper. Reboot the Flipper and rerun "
        "this script; the serial installer should not remain stuck indefinitely.",
        file=sys.stderr,
    )
    raise SystemExit(124)
PY

echo "Installed FCC ID Lookup."
echo "Database is bundled as a compressed FAP asset and cached on first lookup."
echo "Launch it from Apps > Tools > FCC ID Lookup on the Flipper."

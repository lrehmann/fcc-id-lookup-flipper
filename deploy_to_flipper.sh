#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PORT="${1:-auto}"
UFBT_HOME_DIR="$PWD/.ufbt"
PY="$PWD/.venv/bin/python"
UFBT="$PWD/.venv/bin/ufbt"
SDK="$UFBT_HOME_DIR/current"
DB_FILE="fcc_freq_v2.bin"
DB_DEST="/ext/apps_data/fcc_id_lookup/$DB_FILE"

if [[ ! -x "$PY" ]]; then
    python3 -m venv .venv
fi

if ! "$PY" -c 'import serial, colorlog, requests' >/dev/null 2>&1 || [[ ! -x "$UFBT" ]]; then
    "$PY" -m pip install --upgrade pip ufbt colorlog pyserial requests
fi

if [[ ! -d "$SDK" ]]; then
    UFBT_HOME="$UFBT_HOME_DIR" "$UFBT" update
fi

UFBT_HOME="$UFBT_HOME_DIR" "$UFBT" build

STORAGE_PORT_ARGS=()
UFBT_PORT_ARGS=()
if [[ "$PORT" != "auto" ]]; then
    STORAGE_PORT_ARGS=(-p "$PORT")
    UFBT_PORT_ARGS=(FLIP_PORT="$PORT")
fi

"$PY" "$SDK/scripts/storage.py" "${STORAGE_PORT_ARGS[@]}" mkdir /ext/apps_data || true
"$PY" "$SDK/scripts/storage.py" "${STORAGE_PORT_ARGS[@]}" mkdir /ext/apps_data/fcc_id_lookup || true

LOCAL_DB_SIZE="$(wc -c < "$DB_FILE" | tr -d ' ')"
REMOTE_DB_SIZE="$("$PY" "$SDK/scripts/storage.py" "${STORAGE_PORT_ARGS[@]}" size "$DB_DEST" 2>/dev/null | tail -n 1 | tr -dc '0-9' || true)"

if [[ "$REMOTE_DB_SIZE" == "$LOCAL_DB_SIZE" ]]; then
    echo "Database already present on Flipper ($LOCAL_DB_SIZE bytes); skipping upload."
else
    "$PY" "$SDK/scripts/storage.py" "${STORAGE_PORT_ARGS[@]}" send -f "$DB_FILE" "$DB_DEST"
fi

UFBT_HOME="$UFBT_HOME_DIR" "$UFBT" launch "${UFBT_PORT_ARGS[@]}"

echo "Installed FCC ID Lookup."
echo "Database: $DB_DEST"

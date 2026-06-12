#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PORT="${1:-auto}"
UFBT_HOME_DIR="$PWD/.ufbt"
PY="$PWD/.venv/bin/python"
UFBT="$PWD/.venv/bin/ufbt"

if [ ! -x "$PY" ]; then
    python3 -m venv .venv
fi

if [ ! -x "$UFBT" ]; then
    "$PY" -m pip install --upgrade pip ufbt colorlog pyserial requests
fi

UFBT_HOME="$UFBT_HOME_DIR" "$UFBT" build

if [ "$PORT" = "auto" ]; then
    UFBT_HOME="$UFBT_HOME_DIR" "$UFBT" launch
else
    UFBT_HOME="$UFBT_HOME_DIR" FLIP_PORT="$PORT" "$UFBT" launch
fi

echo "Installed FCC ID Lookup."
echo "Database is bundled in the FAP and unpacked to app assets on launch."

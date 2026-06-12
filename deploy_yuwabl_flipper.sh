#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

exec ./deploy_to_flipper.sh /dev/cu.usbmodemflip_Yuwabl1

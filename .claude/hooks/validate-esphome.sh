#!/bin/bash
set -euo pipefail

if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 not on PATH, skipping validation" >&2
    exit 0
fi

FILE=$(cat | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('file_path', ''))
except Exception:
    print('')
")

[[ "$FILE" != *.yaml ]] && exit 0
[[ "$FILE" == *secrets.yaml ]] && exit 0

if [[ "$FILE" == */templates/* ]]; then
    TEMPLATE_NAME=$(basename "$FILE")
    DEVICE_FILE=$(grep -rlF "$TEMPLATE_NAME" "$(dirname "$FILE")/.." --include="*.yaml" | grep -m 1 -v '/templates/') || DEVICE_FILE=""
    if [[ -z "$DEVICE_FILE" ]]; then
        echo "No device file references $TEMPLATE_NAME, skipping validation" >&2
        exit 0
    fi
    FILE="$DEVICE_FILE"
fi

if ! command -v esphome >/dev/null 2>&1; then
    echo "esphome not on PATH, skipping validation" >&2
    exit 0
fi

cd "$(dirname "$FILE")" || { echo "Cannot cd to $(dirname "$FILE")" >&2; exit 1; }
if ! ESPHOME_OUTPUT=$(esphome config "$(basename "$FILE")" 2>&1); then
    echo "$ESPHOME_OUTPUT" >&2
    exit 2
fi

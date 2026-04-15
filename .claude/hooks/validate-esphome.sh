#!/bin/bash

FILE=$(cat | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('tool_input', {}).get('file_path', ''))")

[[ "$FILE" != *.yaml ]] && exit 0
[[ "$FILE" == *secrets.yaml ]] && exit 0

if [[ "$FILE" == */templates/* ]]; then
    TEMPLATE_NAME=$(basename "$FILE")
    DEVICE_FILE=$(grep -rl "$TEMPLATE_NAME" "$(dirname "$FILE")/.." --include="*.yaml" | grep -v templates | head -1)
    [[ -z "$DEVICE_FILE" ]] && exit 0
    FILE="$DEVICE_FILE"
fi

cd "$(dirname "$FILE")" && esphome config "$(basename "$FILE")"

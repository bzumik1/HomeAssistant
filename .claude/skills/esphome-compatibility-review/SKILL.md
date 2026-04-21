---
name: esphome-compatibility-review
description: Reviews ESPHome configs in this repo for compatibility issues with newer ESPHome versions. For each potential issue found, looks up the official documentation and presents findings to the user for approval before making any changes.
---

Review all ESPHome YAML configs in this repository for compatibility issues with current ESPHome versions.

## Process

Follow these steps strictly — do not skip or reorder them:

### 1. Scan configs
Go through all `.yaml` files in `EspHome/` (excluding `.esphome/` build cache). Look for patterns known to have changed across ESPHome versions:
- `ota:` without `platform:` list
- Deprecated component names or configuration keys
- Removed or renamed actions/services
- Changed sensor/platform names
- Any other patterns that might cause validation warnings or errors

### 2. For each potential issue — verify in documentation
Before flagging anything, find a concrete source:
- [ESPHome Changelog](https://esphome.io/changelog/) — search for the exact keyword
- The specific component docs page on esphome.io
- GitHub PR or issue if changelog doesn't mention it

If no documentation can be found, do NOT flag it. State clearly that you couldn't verify it and skip it.

### 3. Present findings for approval
For each verified issue, present:
- Which file(s) and line(s) are affected
- What exactly needs to change and why
- A direct link to the documentation source

Wait for explicit user approval before making any edit.

### 4. Apply approved changes one at a time
- Fix one logical change at a time
- After each fix, verify the diff contains only the expected changes (no pre-existing unrelated modifications)
- Each logical change gets its own commit

### 5. Commit with clean diffs
Before staging, always run `git diff` for the affected file(s) and confirm with the user that the diff contains only the intended changes — not unrelated pre-existing modifications.

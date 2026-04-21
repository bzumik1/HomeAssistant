---
name: esphome-use-local-templates
description: Switches github:// template references in ESPHome device configs to local !include paths. Used for local testing before committing changes to the shared github templates.
---

Switch all `github://bzumik1/HomeAssistant/EspHome/templates/` template references in the specified file(s) to local `!include` equivalents.

The user will either name specific file(s) or say "current file" — use context from the conversation or IDE to determine which file to modify.

## Mapping rule

```
github://bzumik1/HomeAssistant/EspHome/templates/<filename>@main
→
!include ../templates/<filename>
```

The `../templates/` path is relative to `EspHome/location*/` device files. Only apply to packages that pull from `github://bzumik1/HomeAssistant/EspHome/templates/` — leave all other github:// references (e.g. `bluetooth-proxy.yaml`) unchanged.

## Process

1. Read the target file(s)
2. For each package entry that matches `github://bzumik1/HomeAssistant/EspHome/templates/<name>@main`, replace it with `!include ../templates/<name>`
3. Show the diff and wait for user confirmation before writing
4. Apply the change — do NOT commit

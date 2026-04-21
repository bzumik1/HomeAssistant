---
name: esphome-use-github-templates
description: Switches local !include template references in ESPHome device configs back to github:// paths. Used after local testing is done and changes to shared templates have been committed.
---

Switch all local `!include ../templates/` template references in the specified file(s) back to `github://` equivalents.

The user will either name specific file(s) or say "current file" — use context from the conversation or IDE to determine which file to modify.

## Mapping rule

```
!include ../templates/<filename>
→
github://bzumik1/HomeAssistant/EspHome/templates/<filename>@main
```

Only apply to packages that use `!include ../templates/` — leave all other `!include` references unchanged.

## Process

1. Read the target file(s)
2. For each package entry that matches `!include ../templates/<name>`, replace it with `github://bzumik1/HomeAssistant/EspHome/templates/<name>@main`
3. Show the diff and wait for user confirmation before writing
4. Apply the change — do NOT commit

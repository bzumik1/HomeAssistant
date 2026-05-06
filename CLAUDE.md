# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an ESPHome configuration repository for a multi-location smart home setup. All device configurations are YAML files compiled and flashed via the ESPHome toolchain, which integrates with Home Assistant.

## ESPHome CLI Commands

Use `esphome config/compile/run/upload/logs <file.yaml>` from within a location directory (e.g. `location1/`).

## Repository Structure

Configs live in `location1-4/` directories. Shared base config in `templates/` (`common.yaml` + hardware-specific templates). Custom C++ components in `components/` (e.g. `ld2450_uart.h` for LD2450 radar). Standalone device configs in `rest/` (Shelly, switches, relays). Home Assistant automations in `Blueprints/`. Secrets in root-level and per-location `secrets.yaml` (gitignored).

## Architecture: Packages & Templates

Device configs are kept minimal by using ESPHome's `packages` system:

```yaml
# Typical device file pattern:
substitutions:
  name: "esp-svetlo-jidelna"
  friendly_name: "Světlo - jídelna"

packages:
  penta-mini-template: !include ../templates/template-esp-an-penta-mini-wired-single-color.yaml
```

- `templates/common.yaml` — included by almost every template; provides WiFi, HA API, OTA, fallback AP, restart button, status sensor, wifi signal/uptime sensors
- Hardware templates (e.g. `template-esp-sonoff-dual-r3.yaml`, `template-esp-an-penta-mini-wired-single-color.yaml`) include `common.yaml` and add board-specific config
- Device files only define `substitutions` and list packages — avoid duplicating config already in templates
- Some devices pull templates directly from GitHub: `github://bzumik1/HomeAssistant/EspHome/templates/...@main`

## Secrets

All credentials use `!secret` references. The `secrets.yaml` file exists per-location and at the root level. Common secret keys:
- `wifi_ssid`, `wifi_password`
- `esp_home_api_password`
- `esp_home_ota_password`
- `esp_home_fallback_wifi_password`

## Local Overrides

`CLAUDE.local.md` (gitignored) maps location folder names to real-world places. Read it before making changes scoped to a specific location.

## Editor Automation

`.claude/hooks/validate-esphome.sh` runs automatically after every `Edit` or `Write` on a `.yaml` file and invokes `esphome config` on the affected device file. Its output in the tool result is normal — it is not an error from your own command.

## Git Workflow

- Each logical change gets its own commit — never mix unrelated changes in one commit
- Before staging, always run `git diff` for the affected files and confirm the diff contains only the intended changes, not pre-existing unrelated modifications
- If a file contains both intended changes and pre-existing unrelated work, stage only the relevant hunks or commit them separately
- When renaming or moving files or directories, always use `git mv` instead of `mv` to preserve history

## Language

Device names, sensor names, and comments are in Czech.

## Binary Sensor Debounce

All mechanical contacts (wall switches, garage door reed switches, mini-switch buttons) use the `delayed_on_off: 20ms` filter to suppress contact bounce. The filter publishes a state change only after the new state has remained stable for 20 ms in either direction (ON→OFF and OFF→ON). Keep this value consistent across the repo when adding new binary sensors for mechanical inputs.

## Hardware Patterns

- **ESP32-C3** (AN Penta Mini): LEDC PWM outputs for single-color LED strips, I2C on GPIO6/7, `esp-idf` framework
- **Sonoff Dual R3**: Dual relay + power monitoring, events emitted to HA on button press
- **ESP32 dev boards**: Used for custom projects (garage door, HRV ventilation unit)
- **HRV (rekuperace)**: Uses DAC outputs + Modbus RS485 for fan speed control with boost mode logic
- **LD2450**: Custom UART component (`components/ld2450_uart.h`) for mmWave presence radar

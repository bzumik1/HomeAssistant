# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an ESPHome configuration repository for a multi-location smart home setup. All device configurations are YAML files compiled and flashed via the ESPHome toolchain, which integrates with Home Assistant.

## ESPHome CLI Commands

Work is done from within a location directory (e.g. `EspHome/location1/`):

```bash
# Validate a config without compiling
esphome config esp-svetlo-jidelna.yaml

# Compile firmware
esphome compile esp-svetlo-jidelna.yaml

# Compile and flash over the network (OTA)
esphome run esp-svetlo-jidelna.yaml

# Flash via USB
esphome upload esp-svetlo-jidelna.yaml --device /dev/ttyUSB0

# View live logs from a device
esphome logs esp-svetlo-jidelna.yaml
```

## Repository Structure

```
EspHome/
  secrets.yaml          # Root-level secrets (gitignored)
  templates/
    common.yaml         # Shared base config included by most devices (WiFi, API, OTA, sensors)
    template-esp-*.yaml # Reusable hardware-specific templates
  components/
    ld2450_uart.h       # Custom C++ component for LD2450 radar sensor (UART-based)
  location1/            # Apartment / primary residence
  location2/            # Secondary location (garage door, doorbell, power monitor)
  location3/            # Location with many Sonoff Dual R3 switches + HRV unit
  location4/            # Test/new devices
  rest/                 # Standalone device configs (Shelly, switches, relays)
Blueprints/             # Home Assistant automation blueprints (YAML)
```

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

## Hardware Patterns

- **ESP32-C3** (AN Penta Mini): LEDC PWM outputs for single-color LED strips, I2C on GPIO6/7, `esp-idf` framework
- **Sonoff Dual R3**: Dual relay + power monitoring, events emitted to HA on button press
- **ESP32 dev boards**: Used for custom projects (garage door, HRV ventilation unit)
- **HRV (rekuperace)**: Uses DAC outputs + Modbus RS485 for fan speed control with boost mode logic
- **LD2450**: Custom UART component (`components/ld2450_uart.h`) for mmWave presence radar

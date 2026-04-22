# ESPHome Configuration

ESPHome firmware configurations for a multi-location smart home setup, integrated with Home Assistant. All devices are compiled and flashed via the ESPHome CLI.

## Structure

Device configs are organized by location (`location1/` through `location4/`) plus a `rest/` folder for standalone devices. Shared configuration lives in `templates/` — `common.yaml` provides WiFi, API, OTA, and diagnostics; hardware-specific templates build on top of it. A custom C++ component for the LD2450 mmWave radar lives in `components/ld2450_uart.h`. Home Assistant automation blueprints are in `Blueprints/`.

## Architecture

Device files define only `substitutions` and pull in a hardware template via `packages`:

```yaml
substitutions:
  name: "esp-svetlo-jidelna"
  friendly_name: "Světlo - jídelna"

packages:
  penta-mini-template: !include ../templates/template-esp-an-penta-mini-wired-single-color.yaml
```

Templates can also be pulled from GitHub (`github://bzumik1/HomeAssistant/EspHome/templates/...@main`).

## CLI

Run these from inside the relevant location directory:

```bash
esphome config <device>.yaml          # validate
esphome run <device>.yaml             # compile + flash OTA
esphome upload <device>.yaml --device /dev/ttyUSB0  # flash via USB
esphome logs <device>.yaml            # live logs
```

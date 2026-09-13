# BLUEPAD32 Gamepad — Build and Usage Guide (EN)

## 1. Purpose

ESP32 firmware for our Bluepad32 Gamepad controller. Reference version: v0.2.0.

Confirmed functions:
- L1 / R1 digital → Enter
- L2 / R2 analog → 0 when value is > 100
- Share → F9
- Options → F10
- Share and Options are independent of GPIO15 layout selection

## 2. Verified build configuration

- PlatformIO Core: 6.1.19
- SCons: 4.8.1
- Click: 8.1.7
- ESP32 platform: pioarduino 54.03.21
- Board: esp32dev
- Framework: ESP-IDF

platformio.ini:
```ini
platform = https://github.com/pioarduino/platform-espressif32/releases/download/54.03.21/platform-espressif32.zip
```

## 3. Build

In VS Code + PlatformIO: open the project and press Build.

Terminal:
```bash
pio run -e esp32dev
```

Build output:
```text
gamepad_r<VERSION>_<timestamp>.bin
gamepad_r<VERSION>_x000_<timestamp>.bin
```

The `_x000_` image is the complete image intended for flashing at `0x0000`.

## 4. ESP32 ↔ Pico/RP2040 and joystick

Only 7 connections are used.

### PS/2
| ESP32 GPIO | Signal | Pico/RP2040 | Signal |
|---:|---|---:|---|
| GPIO22 | PS/2 CLOCK | GP28 (U3 pin 19) | CLK |
| GPIO23 | PS/2 DATA | GP29 (U3 pin 20) | DATA |

### Joystick — the 5 signals
| ESP32 GPIO | Function | KEMPSTON U8 connector |
|---:|---|---|
| GPIO16 | UP | Pin 1 — UP |
| GPIO17 | DOWN | Pin 2 — DOWN |
| GPIO18 | LEFT | Pin 3 — LEFT |
| GPIO19 | RIGHT | Pin 4 — RIGHT |
| GPIO25 | FIRE | Pin 6 — J_FIRE |

## 5. RP2040-Zero U3 — hardware reference

| U3 Pin | GPIO / signal | Net / function |
|---:|---|---|
| 23 | 5V | VCC |
| 22 | GND | GND |
| 21 | 3V3 | not connected in the shown schematic |
| 20 | GP29 | DATA |
| 19 | GP28 | CLK |
| 18 | GP27 | KB_CS |
| 17 | GP26 | KB_SCK |
| 16 | GP15 | GPIO15 |
| 15 | GP14 | GPIO14 |
| 1 | GP0 | BLUE |
| 2 | GP1 | GREEN |
| 3 | GP2 | RED |
| 4 | GP3 | BL_OUT |
| 5 | GP4 | SSI |
| 6 | GP5 | KSI |
| 7 | GP6 | F_CLK |
| 8 | GP7 | KB_MOSI |
| 9 | GP8 | GP8 |
| 10 | GP9 | GP9 |
| 11 | GP10 | GP10 |
| 12 | GP11 | GP11 |
| 13 | GP12 | GP12 |
| 14 | GP13 | GP13 |

## 6. KEMPSTON U8 connector

| Pin | Signal |
|---:|---|
| 1 | UP |
| 2 | DOWN |
| 3 | LEFT |
| 4 | RIGHT |
| 5 | BT2 |
| 6 | J_FIRE |
| 7 | J_D6 |
| 8 | GND |
| 9 | J_BT3 |
| 10 | GND |
| 11 | GND |

For the functional ESP32 ↔ joystick interface, only UP, DOWN, LEFT, RIGHT and FIRE are used.

## 7. Flashing

For Windows / esptool, use the complete `_x000_` image:

```text
esptool.exe --chip esp32 write-flash 0x0000 gamepad_r<VERSION>_x000_<timestamp>.bin
```

## 8. Hardware verification

After flashing:
- Share → F9
- Options → F10
- L1 / R1 → Enter
- L2 / R2 → 0 when value > 100
- UP / DOWN / LEFT / RIGHT
- verify the selected layout

## 9. Builder rule

Open the project → Build → check `firmware/`.

For the complete programming image, use the `_x000_` file at `0x0000`.

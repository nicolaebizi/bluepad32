# BLUEPAD32 Gamepad — Ghid de build și utilizare (RO)

## 1. Scop

Firmware ESP32 pentru controllerul nostru Bluepad32 Gamepad. Versiunea de referință este v0.2.0.

Funcții confirmate:
- L1 / R1 digitale → Enter
- L2 / R2 analogice → 0 când valoarea este > 100
- Share → F9
- Options → F10
- Share și Options sunt independente de layout-ul GPIO15

## 2. Configurația verificată

- PlatformIO Core: 6.1.19
- SCons: 4.8.1
- Click: 8.1.7
- Platformă ESP32: pioarduino 54.03.21
- Board: esp32dev
- Framework: ESP-IDF

platformio.ini:
```ini
platform = https://github.com/pioarduino/platform-espressif32/releases/download/54.03.21/platform-espressif32.zip
```

## 3. Build

În VS Code + PlatformIO: deschide proiectul și apasă Build.

Din Terminal:
```bash
pio run -e esp32dev
```

Buildul generează în `firmware/`:
```text
gamepad_r<VERSION>_<timestamp>.bin
gamepad_r<VERSION>_x000_<timestamp>.bin
```

Imaginea `_x000_` este imaginea completă pentru flash la adresa `0x0000`.

## 4. ESP32 ↔ Pico/RP2040 și joystick

Interfața folosește doar 7 conexiuni.

### PS/2
| ESP32 GPIO | Semnal | Pico/RP2040 | Semnal |
|---:|---|---:|---|
| GPIO22 | PS/2 CLOCK | GP28 (U3 pin 19) | CLK |
| GPIO23 | PS/2 DATA | GP29 (U3 pin 20) | DATA |

### Joystick — cele 5 semnale
| ESP32 GPIO | Funcție | Mufa KEMPSTON U8 |
|---:|---|---|
| GPIO16 | UP | Pin 1 — UP |
| GPIO17 | DOWN | Pin 2 — DOWN |
| GPIO18 | LEFT | Pin 3 — LEFT |
| GPIO19 | RIGHT | Pin 4 — RIGHT |
| GPIO25 | FIRE | Pin 6 — J_FIRE |

## 5. RP2040-Zero U3 — referință hardware

| Pin U3 | GPIO / semnal | Net / funcție |
|---:|---|---|
| 23 | 5V | VCC |
| 22 | GND | GND |
| 21 | 3V3 | neconectat în schema prezentată |
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

## 6. Mufa KEMPSTON U8

| Pin | Semnal |
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

Pentru interfața funcțională ESP32 ↔ joystick se folosesc doar UP, DOWN, LEFT, RIGHT și FIRE.

## 7. Flash

Pentru Windows / esptool se folosește imaginea completă `_x000_`:

```text
esptool.exe --chip esp32 write-flash 0x0000 gamepad_r<VERSION>_x000_<timestamp>.bin
```

## 8. Verificare hardware

După flash:
- Share → F9
- Options → F10
- L1 / R1 → Enter
- L2 / R2 → 0 la valoare > 100
- UP / DOWN / LEFT / RIGHT
- verificarea layout-ului

## 9. Regula pentru constructor

Deschide proiectul → Build → verifică `firmware/`.

Pentru imaginea completă folosită la programare: fișierul `_x000_` la `0x0000`.

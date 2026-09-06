# PROJECT JOURNAL

## 2026-09-06

### Updates
- Added PS/2 keyboard output from the ESP32 for the Bluetooth keyboard.
- PS/2 pins on ESP32:
  - GPIO22 = CLOCK
  - GPIO23 = DATA
- PS/2 service task configured to run on CPU0.
- Bluepad32 / Arduino runs on CPU1.
- Added PS/2 activity LED:
  - GPIO21
  - 330 ohm resistor + LED
- Gamepad joystick mapping:
  - GPIO16 = UP
  - GPIO17 = DOWN
  - GPIO18 = LEFT
  - GPIO19 = RIGHT
  - GPIO25 = FIRE (L1)
- Added onboard ESP32 D2 LED (GPIO2) for Bluetooth connection status:
  - ON = at least one Bluetooth device connected
  - OFF = no Bluetooth device connected
- Test confirmed: D2 turns on when a Bluetooth device connects and turns off when it disconnects.
- Pico / Pentagon LEO-1024 PS/2 connection:
  - GPIO28 = PS/2 CLOCK
  - GPIO29 = PS/2 DATA
- Latest `esp32dev` firmware is stored in `bin=esp32dev/firmware.bin`.

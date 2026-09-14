bluepad32 — Gamepad PS4 & Keyboard Bluetooth for Leo 1024 Pentagon

Bluetooth gamepad (PS4) and keyboard support for the Leo 1024 Pentagon, built on top of Bluepad32 for ESP32.

Documentation / Documentație

Full build documentation is available in both English and Romanian:

🇬🇧 Build Guide (English)
🇷🇴 Ghid de construcție (Română)
Quick start

This project uses PlatformIO with the ESP-IDF framework.

Supported build environments (see platformio.ini):

esp32dev
esp32-s3-devkitc-1
esp32-c3-devkitc-02
esp32-c6-devkitc-1
esp32-h2-devkitm-1
bash
pio run -e esp32dev

The build produces two firmware files in the firmware/ folder:

gamepad_<version>_<timestamp>.bin — application binary only
gamepad_<version>_x000_<timestamp>.bin — merged binary (bootloader + partitions + app), flash at address 0x0000

For full wiring, hardware requirements, and step-by-step build instructions, see the build guides linked above.

Photos

See the Foto/ folder for build photos.

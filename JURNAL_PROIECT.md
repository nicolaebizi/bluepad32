# JURNAL PROIECT

## 2026-09-06

### Actualizari
- Adaugat suport pentru iesire PS/2 din ESP32 pentru tastatura Bluetooth.
- PS/2:
  - GPIO22 = CLOCK
  - GPIO23 = DATA
- Task PS/2 configurat pe CPU0.
- Bluepad32 / Arduino ruleaza pe CPU1.
- LED activitate PS/2:
  - GPIO21
  - rezistor 330 ohm + LED
- Joystick:
  - GPIO16 = UP
  - GPIO17 = DOWN
  - GPIO18 = LEFT
  - GPIO19 = RIGHT
  - GPIO25 = FOC (L1)
- LED D2 al placii ESP32 (GPIO2):
  - ON = cel putin un dispozitiv Bluetooth conectat
  - OFF = niciun dispozitiv Bluetooth conectat
- Test confirmat: D2 se aprinde la conectare Bluetooth si se stinge la deconectare.
- Pico / Pentagon LEO-1024:
  - GPIO28 = PS/2 CLOCK
  - GPIO29 = PS/2 DATA
- Ultima compilare `esp32dev` este pastrata in `bin=esp32dev/firmware.bin`.

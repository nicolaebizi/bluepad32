#!/bin/bash
set -euo pipefail

echo "== Backup =="
cp main/sketch.cpp main/sketch.cpp.bak_ps2fix
cp platformio.ini platformio.ini.bak_ps2fix

echo "== Eliminate biblioteca PS/2 standalone din platformio.ini =="
python3 - <<'PY'
from pathlib import Path
p = Path("platformio.ini")
s = p.read_text()
s = s.replace("""lib_deps =
    https://github.com/Hamberthm/esp32-ps2dev.git

""", "")
p.write_text(s)
PY

echo "== Instaleaza implementarea PS/2 Hambert =="
mkdir -p components/esp32-ps2dev/src

curl -L --fail -sS \
  https://raw.githubusercontent.com/Hamberthm/esp32-bt2ps2/refs/heads/main/main/esp32-ps2dev.cpp \
  -o components/esp32-ps2dev/src/esp32-ps2dev.cpp

curl -L --fail -sS \
  https://raw.githubusercontent.com/Hamberthm/esp32-bt2ps2/refs/heads/main/include/esp32-ps2dev.h \
  -o components/esp32-ps2dev/src/esp32-ps2dev.h

curl -L --fail -sS \
  https://raw.githubusercontent.com/Hamberthm/esp32-bt2ps2/refs/heads/main/include/scan_codes_set_2.h \
  -o components/esp32-ps2dev/src/scan_codes_set_2.h

rm -rf components/esp32-ps2dev/.git

cat > components/esp32-ps2dev/CMakeLists.txt <<'CMAKE'
idf_component_register(
    SRCS "src/esp32-ps2dev.cpp"
    INCLUDE_DIRS "src"
    REQUIRES arduino
)
CMAKE

echo "== Modifica sketch.cpp =="
python3 - <<'PY'
from pathlib import Path
p = Path("main/sketch.cpp")
s = p.read_text()

if '#include "driver/gpio.h"' not in s:
    s = s.replace(
        '#include <esp32-ps2dev.h>\n',
        '#include <esp32-ps2dev.h>\n#include "driver/gpio.h"\n'
    )

if '#define PS2_ACTIVITY_LED 21' not in s:
    s = s.replace(
        '#define GPIO_RIGHT  19\n',
        '#define GPIO_RIGHT  19\n#define PS2_ACTIVITY_LED 21\n'
    )

start = s.index("void processKeyboard(ControllerPtr ctl) {")
end = s.index("\nvoid processBalanceBoard", start)

new_fn = r'''void processKeyboard(ControllerPtr ctl) {
    for (int key = Keyboard_A; key <= Keyboard_RightMeta; key++) {
        bool pressed = ctl->isKeyPressed(static_cast<KeyboardKey>(key));
        bool wasPressed = previousKeyboardState[key];

        if (pressed != wasPressed) {
            ps2Keyboard.keyHid_send(static_cast<uint8_t>(key), pressed);
            previousKeyboardState[key] = pressed;

            if (pressed) {
                digitalWrite(PS2_ACTIVITY_LED, HIGH);
                delay(10);
                digitalWrite(PS2_ACTIVITY_LED, LOW);
            }

            Console.printf(
                "PS/2 %s HID key 0x%02X\n",
                pressed ? "DOWN" : "UP",
                key
            );
        }
    }

    dumpKeyboard(ctl);
}
'''
s = s[:start] + new_fn + s[end:]

# PS/2 initialization
old = '''    // Start PS/2 keyboard emulation first.
    // The PS/2 library handles its protocol task on CPU 0.
    ps2Keyboard.begin();
'''
new = '''    // PS/2 pins: open-drain with pull-ups.
    gpio_set_direction((gpio_num_t)PS2_CLOCK, GPIO_MODE_OUTPUT_OD);
    gpio_set_direction((gpio_num_t)PS2_DATA, GPIO_MODE_OUTPUT_OD);
    gpio_set_pull_mode((gpio_num_t)PS2_CLOCK, GPIO_PULLUP_ONLY);
    gpio_set_pull_mode((gpio_num_t)PS2_DATA, GPIO_PULLUP_ONLY);

    // LED activity: GPIO21 -> 330 ohm -> LED -> GND.
    pinMode(PS2_ACTIVITY_LED, OUTPUT);
    digitalWrite(PS2_ACTIVITY_LED, LOW);

    // PS/2 service on CPU0.
    ps2Keyboard.config(10, 0);
    ps2Keyboard.begin();
'''
if old in s:
    s = s.replace(old, new)
else:
    s = s.replace('    ps2Keyboard.begin();', new, 1)

s = s.replace('    BP32.forgetBluetoothKeys();\n', '')
s = s.replace('    delay(150);', '    delay(5);')

p.write_text(s)
PY

echo "== Curata build-ul si compileaza =="
rm -rf .pio/build/esp32dev
pio run -e esp32dev

echo
echo "=== GATA ==="
echo "Test osciloscop: GPIO22 = CLOCK, GPIO23 = DATA"

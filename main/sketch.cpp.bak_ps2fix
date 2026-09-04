// SPDX-License-Identifier: Apache-2.0
// Copyright 2021 Ricardo Quesada
// http://retro.moe/unijoysticle2

#include "sdkconfig.h"

#include <Arduino.h>
#include <Bluepad32.h>
#include <esp32-ps2dev.h>


// GPIO pentru D-pad
#define GPIO_UP     16
#define GPIO_DOWN   17
#define GPIO_LEFT   18
#define GPIO_RIGHT  19
#define PS2_ACTIVITY_LED 21
//
// README FIRST, README FIRST, README FIRST
//
// Bluepad32 has a built-in interactive console.
// By default, it is enabled (hey, this is a great feature!).
// But it is incompatible with Arduino "Serial" class.
//
// Instead of using "Serial" you can use Bluepad32 "Console" class instead.
// It is somewhat similar to Serial but not exactly the same.
//
// Should you want to still use "Serial", you have to disable the Bluepad32's console
// from "sdkconfig.defaults" with:
//    CONFIG_BLUEPAD32_USB_CONSOLE_ENABLE=n

ControllerPtr myControllers[BP32_MAX_GAMEPADS];

// PS/2 keyboard output: CLOCK = GPIO22, DATA = GPIO23.
// The library creates its PS/2 service task on CPU 0 by default.
#define PS2_CLOCK 22
#define PS2_DATA  23
esp32_ps2dev::PS2Keyboard ps2Keyboard(PS2_CLOCK, PS2_DATA);

// Previous Bluetooth keyboard state, used to generate make/break events only once.
static bool previousKeyboardState[256] = {false};

// This callback gets called any time a new gamepad is connected.
// Up to 4 gamepads can be connected at the same time.
void onConnectedController(ControllerPtr ctl) {
    bool foundEmptySlot = false;
    for (int i = 0; i < BP32_MAX_GAMEPADS; i++) {
        if (myControllers[i] == nullptr) {
            Console.printf("CALLBACK: Controller is connected, index=%d\n", i);
            // Additionally, you can get certain gamepad properties like:
            // Model, VID, PID, BTAddr, flags, etc.
            ControllerProperties properties = ctl->getProperties();
            Console.printf("Controller model: %s, VID=0x%04x, PID=0x%04x\n", ctl->getModelName(), properties.vendor_id,
                           properties.product_id);
            myControllers[i] = ctl;
            foundEmptySlot = true;
            break;
        }
    }
    if (!foundEmptySlot) {
        Console.println("CALLBACK: Controller connected, but could not found empty slot");
    }
}

void onDisconnectedController(ControllerPtr ctl) {
    bool foundController = false;

    for (int i = 0; i < BP32_MAX_GAMEPADS; i++) {
        if (myControllers[i] == ctl) {
            Console.printf("CALLBACK: Controller disconnected from index=%d\n", i);
            myControllers[i] = nullptr;
            foundController = true;
            break;
        }
    }

    if (!foundController) {
        Console.println("CALLBACK: Controller disconnected, but not found in myControllers");
    }
}

void dumpGamepad(ControllerPtr ctl) {
    Console.printf(
        "idx=%d, dpad: 0x%02x, buttons: 0x%04x, axis L: %4d, %4d, axis R: %4d, %4d, brake: %4d, throttle: %4d, "
        "misc: 0x%02x, gyro x:%6d y:%6d z:%6d, accel x:%6d y:%6d z:%6d\n",
        ctl->index(),        // Controller Index
        ctl->dpad(),         // D-pad
        ctl->buttons(),      // bitmask of pressed buttons
        ctl->axisX(),        // (-511 - 512) left X Axis
        ctl->axisY(),        // (-511 - 512) left Y axis
        ctl->axisRX(),       // (-511 - 512) right X axis
        ctl->axisRY(),       // (-511 - 512) right Y axis
        ctl->brake(),        // (0 - 1023): brake button
        ctl->throttle(),     // (0 - 1023): throttle (AKA gas) button
        ctl->miscButtons(),  // bitmask of pressed "misc" buttons
        ctl->gyroX(),        // Gyro X
        ctl->gyroY(),        // Gyro Y
        ctl->gyroZ(),        // Gyro Z
        ctl->accelX(),       // Accelerometer X
        ctl->accelY(),       // Accelerometer Y
        ctl->accelZ()        // Accelerometer Z
    );
}

void dumpMouse(ControllerPtr ctl) {
    Console.printf("idx=%d, buttons: 0x%04x, scrollWheel=0x%04x, delta X: %4d, delta Y: %4d\n",
                   ctl->index(),        // Controller Index
                   ctl->buttons(),      // bitmask of pressed buttons
                   ctl->scrollWheel(),  // Scroll Wheel
                   ctl->deltaX(),       // (-511 - 512) left X Axis
                   ctl->deltaY()        // (-511 - 512) left Y axis
    );
}

void dumpKeyboard(ControllerPtr ctl) {
    static const char* key_names[] = {
        // clang-format off
        // To avoid having too much noise in this file, only a few keys are mapped to strings.
        // Starts with "A", which is offset 4.
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
        "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
        // Special keys
        "Enter", "Escape", "Backspace", "Tab", "Spacebar", "Underscore", "Equal", "OpenBracket", "CloseBracket",
        "Backslash", "Tilde", "SemiColon", "Quote", "GraveAccent", "Comma", "Dot", "Slash", "CapsLock",
        // Function keys
        "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
        // Cursors and others
        "PrintScreen", "ScrollLock", "Pause", "Insert", "Home", "PageUp", "Delete", "End", "PageDown",
        "RightArrow", "LeftArrow", "DownArrow", "UpArrow",
        // clang-format on
    };
    static const char* modifier_names[] = {
        // clang-format off
        // From 0xe0 to 0xe7
        "Left Control", "Left Shift", "Left Alt", "Left Meta",
        "Right Control", "Right Shift", "Right Alt", "Right Meta",
        // clang-format on
    };
    Console.printf("idx=%d, Pressed keys: ", ctl->index());
    for (int key = Keyboard_A; key <= Keyboard_UpArrow; key++) {
        if (ctl->isKeyPressed(static_cast<KeyboardKey>(key))) {
            const char* keyName = key_names[key - 4];
            Console.printf("%s,", keyName);
        }
    }
    for (int key = Keyboard_LeftControl; key <= Keyboard_RightMeta; key++) {
        if (ctl->isKeyPressed(static_cast<KeyboardKey>(key))) {
            const char* keyName = modifier_names[key - 0xe0];
            Console.printf("%s,", keyName);
        }
    }
    Console.printf("\n");
}

void dumpBalanceBoard(ControllerPtr ctl) {
    Console.printf("idx=%d,  TL=%u, TR=%u, BL=%u, BR=%u, temperature=%d\n",
                   ctl->index(),        // Controller Index
                   ctl->topLeft(),      // top-left scale
                   ctl->topRight(),     // top-right scale
                   ctl->bottomLeft(),   // bottom-left scale
                   ctl->bottomRight(),  // bottom-right scale
                   ctl->temperature()   // temperature: used to adjust the scale value's precision
    );
}

void processGamepad(ControllerPtr ctl) {
    uint8_t dpad = ctl->dpad();

    // D-pad -> GPIO, activ LOW
    digitalWrite(GPIO_UP,    (dpad & DPAD_UP)    ? LOW : HIGH);
    digitalWrite(GPIO_DOWN,  (dpad & DPAD_DOWN)  ? LOW : HIGH);
    digitalWrite(GPIO_LEFT,  (dpad & DPAD_LEFT)  ? LOW : HIGH);
    digitalWrite(GPIO_RIGHT, (dpad & DPAD_RIGHT) ? LOW : HIGH);

    // Restul este doar pentru afișare/debug
    if (ctl->a())
        Console.println("A pressed");

    if (ctl->b())
        Console.println("B pressed");

    dumpGamepad(ctl);
}

void processMouse(ControllerPtr ctl) {
    // This is just an example.
    if (ctl->scrollWheel() > 0) {
        // Do Something
    } else if (ctl->scrollWheel() < 0) {
        // Do something else
    }

    // See "dumpMouse" for possible things to query.
    dumpMouse(ctl);
}

void processKeyboard(ControllerPtr ctl) {
    // Convert Bluepad32 HID usage IDs to esp32-ps2dev scan-code keys.
    auto hidToPs2 = [](uint8_t hid, esp32_ps2dev::scancodes::Key& out) -> bool {
        using namespace esp32_ps2dev::scancodes;

        switch (hid) {
            case 4:  out = K_A; break; case 5:  out = K_B; break;
            case 6:  out = K_C; break; case 7:  out = K_D; break;
            case 8:  out = K_E; break; case 9:  out = K_F; break;
            case 10: out = K_G; break; case 11: out = K_H; break;
            case 12: out = K_I; break; case 13: out = K_J; break;
            case 14: out = K_K; break; case 15: out = K_L; break;
            case 16: out = K_M; break; case 17: out = K_N; break;
            case 18: out = K_O; break; case 19: out = K_P; break;
            case 20: out = K_Q; break; case 21: out = K_R; break;
            case 22: out = K_S; break; case 23: out = K_T; break;
            case 24: out = K_U; break; case 25: out = K_V; break;
            case 26: out = K_W; break; case 27: out = K_X; break;
            case 28: out = K_Y; break; case 29: out = K_Z; break;

            case 30: out = K_1; break; case 31: out = K_2; break;
            case 32: out = K_3; break; case 33: out = K_4; break;
            case 34: out = K_5; break; case 35: out = K_6; break;
            case 36: out = K_7; break; case 37: out = K_8; break;
            case 38: out = K_9; break; case 39: out = K_0; break;

            case 40: out = K_RETURN; break;
            case 41: out = K_ESCAPE; break;
            case 42: out = K_BACKSPACE; break;
            case 43: out = K_TAB; break;
            case 44: out = K_SPACE; break;
            case 45: out = K_MINUS; break;
            case 46: out = K_EQUALS; break;
            case 47: out = K_LEFTBRACKET; break;
            case 48: out = K_RIGHTBRACKET; break;
            case 49: out = K_BACKSLASH; break;
            case 51: out = K_SEMICOLON; break;
            case 52: out = K_QUOTE; break;
            case 54: out = K_COMMA; break;
            case 55: out = K_PERIOD; break;
            case 56: out = K_SLASH; break;

            case 58: out = K_F1; break;  case 59: out = K_F2; break;
            case 60: out = K_F3; break;  case 61: out = K_F4; break;
            case 62: out = K_F5; break;  case 63: out = K_F6; break;
            case 64: out = K_F7; break;  case 65: out = K_F8; break;
            case 66: out = K_F9; break;  case 67: out = K_F10; break;
            case 68: out = K_F11; break; case 69: out = K_F12; break;

            case 70: out = K_PRINT; break;
            case 71: out = K_SCROLLOCK; break;
            case 72: out = K_PAUSE; break;
            case 73: out = K_INSERT; break;
            case 74: out = K_HOME; break;
            case 75: out = K_PAGEUP; break;
            case 76: out = K_DELETE; break;
            case 77: out = K_END; break;
            case 78: out = K_PAGEDOWN; break;
            case 79: out = K_RIGHT; break;
            case 80: out = K_LEFT; break;
            case 81: out = K_DOWN; break;
            case 82: out = K_UP; break;

            case 224: out = K_LCTRL; break;
            case 225: out = K_LSHIFT; break;
            case 226: out = K_LALT; break;
            case 227: out = K_LSUPER; break;
            case 228: out = K_RCTRL; break;
            case 229: out = K_RSHIFT; break;
            case 230: out = K_RALT; break;
            case 231: out = K_RSUPER; break;

            default:
                return false;  // Ignore HID keys without a PS/2 mapping.
        }
        return true;
    };

    for (int key = Keyboard_A; key <= Keyboard_RightMeta; key++) {
        bool pressed = ctl->isKeyPressed(static_cast<KeyboardKey>(key));
        bool wasPressed = previousKeyboardState[key];

        if (pressed != wasPressed) {
            esp32_ps2dev::scancodes::Key ps2Key;

            if (hidToPs2(static_cast<uint8_t>(key), ps2Key)) {
                if (pressed) {
                    ps2Keyboard.keydown(ps2Key);
                } else {
                    ps2Keyboard.keyup(ps2Key);
                }

                // LED ON briefly for every PS/2 key event.
                digitalWrite(PS2_ACTIVITY_LED, HIGH);
                delay(10);
                digitalWrite(PS2_ACTIVITY_LED, LOW);

                Console.printf(
                    "PS/2 %s HID key 0x%02X\n",
                    pressed ? "DOWN" : "UP",
                    key
                );
            }

            previousKeyboardState[key] = pressed;
        }
    }

    dumpKeyboard(ctl);
}

void processBalanceBoard(ControllerPtr ctl) {
    // This is just an example.
    if (ctl->topLeft() > 10000) {
        // Do Something
    }

    // See "dumpBalanceBoard" for possible things to query.
    dumpBalanceBoard(ctl);
}

void processControllers() {
    for (auto myController : myControllers) {
        if (myController && myController->isConnected() && myController->hasData()) {
            if (myController->isGamepad()) {
                processGamepad(myController);
            } else if (myController->isMouse()) {
                processMouse(myController);
            } else if (myController->isKeyboard()) {
                processKeyboard(myController);
            } else if (myController->isBalanceBoard()) {
                processBalanceBoard(myController);
            } else {
                Console.printf("Unsupported controller\n");
            }
        }
    }
}

// Arduino setup function. Runs in CPU 1
void setup() {
  
pinMode(GPIO_UP, OUTPUT);
pinMode(GPIO_DOWN, OUTPUT);
pinMode(GPIO_LEFT, OUTPUT);
pinMode(GPIO_RIGHT, OUTPUT);

// Stare inițială: HIGH = dezactivat
digitalWrite(GPIO_UP, HIGH);
digitalWrite(GPIO_DOWN, HIGH);
digitalWrite(GPIO_LEFT, HIGH);
digitalWrite(GPIO_RIGHT, HIGH);
  
  
  
    Console.printf("Firmware: %s\n", BP32.firmwareVersion());
    const uint8_t* addr = BP32.localBdAddress();
    Console.printf("BD Addr: %2X:%2X:%2X:%2X:%2X:%2X\n", addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);

    // LED activity indicator: GPIO21 -> 330 ohm -> LED -> GND.
    pinMode(PS2_ACTIVITY_LED, OUTPUT);
    digitalWrite(PS2_ACTIVITY_LED, LOW);

    // Run the PS/2 service task on CPU 0 explicitly.
    ps2Keyboard.config(10, 0);
    ps2Keyboard.begin();

    // Setup the Bluepad32 callbacks, and the default behavior for scanning or not.
    // By default, if the "startScanning" parameter is not passed, it will do the "start scanning".
    // Notice that "Start scanning" will try to auto-connect to devices that are compatible with Bluepad32.
    // E.g: if a Gamepad, keyboard or mouse are detected, it will try to auto connect to them.
    bool startScanning = true;
    BP32.setup(&onConnectedController, &onDisconnectedController, startScanning);

    // Notice that scanning can be stopped / started at any time by calling:
    // BP32.enableNewBluetoothConnections(enabled);

    // "forgetBluetoothKeys()" should be called when the user performs
    // a "device factory reset", or similar.
    // Calling "forgetBluetoothKeys" in setup() just as an example.
    // Forgetting Bluetooth keys prevents "paired" gamepads to reconnect.
    // But it might also fix some connection / re-connection issues.
    BP32.forgetBluetoothKeys();

    // Enables mouse / touchpad support for gamepads that support them.
    // When enabled, controllers like DualSense and DualShock4 generate two connected devices:
    // - First one: the gamepad
    // - Second one, which is a "virtual device", is a mouse.
    // By default, it is disabled.
    BP32.enableVirtualDevice(false);

    // Enables the BLE Service in Bluepad32.
    // This service allows clients, like a mobile app, to setup and see the state of Bluepad32.
    // By default, it is disabled.
    BP32.enableBLEService(false);
}

// Arduino loop function. Runs in CPU 1.
void loop() {
    // This call fetches all the controllers' data.
    // Call this function in your main loop.
    bool dataUpdated = BP32.update();
    if (dataUpdated)
        processControllers();

    // The main loop must have some kind of "yield to lower priority task" event.
    // Otherwise, the watchdog will get triggered.
    // If your main loop doesn't have one, just add a simple `vTaskDelay(1)`.
    // Detailed info here:
    // https://stackoverflow.com/questions/66278271/task-watchdog-got-triggered-the-tasks-did-not-reset-the-watchdog-in-time

    //     vTaskDelay(1);
    delay(5);
}

Import("env")

EXPECTED_PIO = "6.1.19"
EXPECTED_SCONS = "4.8.1"
EXPECTED_CLICK = "8.1.7"

try:
    import platformio
    actual_pio = platformio.__version__
except Exception as exc:
    raise RuntimeError(f"Nu pot verifica PlatformIO Core: {exc}")

try:
    import SCons
    actual_scons = SCons.__version__
except Exception as exc:
    raise RuntimeError(f"Nu pot verifica SCons: {exc}")

try:
    import click
    actual_click = click.__version__
except Exception as exc:
    raise RuntimeError(f"Nu pot verifica Click: {exc}")

problems = []
if actual_pio != EXPECTED_PIO:
    problems.append(f"PlatformIO Core {actual_pio} (asteptat {EXPECTED_PIO})")
if actual_scons != EXPECTED_SCONS:
    problems.append(f"SCons {actual_scons} (asteptat {EXPECTED_SCONS})")
if actual_click != EXPECTED_CLICK:
    problems.append(f"Click {actual_click} (asteptat {EXPECTED_CLICK})")

if problems:
    raise RuntimeError(
        "Mediul de build nu este cel verificat pentru acest proiect:\n  - " +
        "\n  - ".join(problems) +
        "\nNu continua build-ul; restaureaza mediul aprobat."
    )

print("=== Bluepad32 Gamepad: mediu verificat ===")
print(f"PlatformIO Core : {actual_pio}")
print(f"SCons           : {actual_scons}")
print(f"Click           : {actual_click}")
print("ESP32 platform  : pioarduino 54.03.21 (fixata in platformio.ini)")

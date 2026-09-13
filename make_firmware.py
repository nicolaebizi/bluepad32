Import("env")

import os
import shutil
import subprocess
from datetime import datetime

VERSION = "r0.1.1"
PROJECT_DIR = env.subst("$PROJECT_DIR")
BUILD_DIR = env.subst("$BUILD_DIR")
OUT_DIR = os.path.join(PROJECT_DIR, "firmware")

APP_BIN = os.path.join(BUILD_DIR, "firmware.bin")
BOOTLOADER_BIN = os.path.join(BUILD_DIR, "bootloader.bin")
PARTITIONS_BIN = os.path.join(BUILD_DIR, "partitions.bin")

ESPTOOL_DIR = env.PioPlatform().get_package_dir("tool-esptoolpy")
ESPTOOL = os.path.join(ESPTOOL_DIR, "esptool.py")
PYTHON = env.subst("$PYTHONEXE")


def unique_path(path):
    if not os.path.exists(path):
        return path

    base, ext = os.path.splitext(path)
    counter = 1
    while True:
        candidate = f"{base}_{counter:02d}{ext}"
        if not os.path.exists(candidate):
            return candidate
        counter += 1


def make_firmware(target, source, env):
    os.makedirs(OUT_DIR, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    normal_out = unique_path(
        os.path.join(OUT_DIR, f"gamepad_{VERSION}_{timestamp}.bin")
    )
    merged_out = unique_path(
        os.path.join(OUT_DIR, f"gamepad_{VERSION}_x000_{timestamp}.bin")
    )

    shutil.copy2(APP_BIN, normal_out)

    cmd = [
        PYTHON,
        ESPTOOL,
        "--chip",
        "esp32",
        "merge-bin",
        "-o",
        merged_out,
        "0x1000",
        BOOTLOADER_BIN,
        "0x8000",
        PARTITIONS_BIN,
        "0x10000",
        APP_BIN,
    ]

    print("=== Generare firmware-uri ===")
    print(f"Normal : {normal_out}")
    print(f"x000   : {merged_out}")
    print("Flash x000 la adresa 0x0000")

    result = subprocess.run(cmd, cwd=PROJECT_DIR)
    if result.returncode != 0:
        raise RuntimeError(
            "esptool merge-bin a esuat; firmware-ul x000 nu a fost generat."
        )

    print("=== Firmware-uri generate cu succes ===")


env.AddPostAction("$BUILD_DIR/firmware.bin", make_firmware)

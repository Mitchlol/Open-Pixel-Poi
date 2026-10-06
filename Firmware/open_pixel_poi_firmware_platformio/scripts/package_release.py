"""Packages the built kit firmwares for the web based flashing tool.

Usage: package_release.py <version> <firmware site directory>

Writes <firmware site directory>/<version>/<kit>/ with the binaries and two
esp-web-tools manifests per kit, and adds the release to index.json.
"""

import csv
import datetime
import json
import os
import re
import shutil
import sys
from pathlib import Path

PROJECT = Path(__file__).resolve().parent.parent

KITS = {
    "kit_3_0_0_25px": "PCB V3.0.0 25-Pixels",
    "kit_3_0_0_55px": "PCB V3.0.0 55-Pixels",
    "kit_2_2_1_20px": "PCB V2.2.1 20-Pixels",
}

BOOTLOADER_OFFSET = 0x0
PARTITIONS_OFFSET = 0x8000


def partition_offset(name):
    with open(PROJECT / "opp_partitions.csv") as partitions:
        for row in csv.reader(partitions):
            if row and row[0].strip() == name:
                return int(row[3].strip(), 16)
    raise SystemExit(f"Partition {name} not found in opp_partitions.csv")


def manifest(version, parts, prompt_erase):
    return {
        "name": "OpenPixelPoi",
        "version": version,
        "funding_url": "https://github.com/Mitchlol/Open-Pixel-Poi/blob/main/README.md",
        "new_install_prompt_erase": prompt_erase,
        "builds": [{"chipFamily": "ESP32-C3", "parts": parts}],
    }


def version_key(version):
    return [int(part) for part in version.split(".")]


def write_json(path, content):
    path.write_text(json.dumps(content, indent=2) + "\n")


def main():
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    version = sys.argv[1]
    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        raise SystemExit(f"Version {version} is not of the form 3.1.0")
    site = Path(sys.argv[2])

    core = Path(os.environ.get("PLATFORMIO_CORE_DIR", Path.home() / ".platformio"))
    boot_app0 = (
        core
        / "packages/framework-arduinoespressif32/tools/partitions/boot_app0.bin"
    )

    base_parts = [
        {"path": "bootloader.bin", "offset": BOOTLOADER_OFFSET},
        {"path": "partitions.bin", "offset": PARTITIONS_OFFSET},
        {"path": "boot_app0.bin", "offset": partition_offset("otadata")},
        {"path": "firmware.bin", "offset": partition_offset("app0")},
    ]
    filesystem_part = {"path": "littlefs.bin", "offset": partition_offset("spiffs")}

    variants = []
    for kit, name in KITS.items():
        build = PROJECT / ".pio/build" / kit
        target = site / version / kit
        if target.exists():
            shutil.rmtree(target)
        target.mkdir(parents=True)

        for binary in ("bootloader.bin", "partitions.bin", "firmware.bin", "littlefs.bin"):
            shutil.copy(build / binary, target / binary)
        shutil.copy(boot_app0, target / "boot_app0.bin")

        # A full install erases the chip and writes the default patterns.
        write_json(
            target / "manifest.json",
            manifest(version, base_parts + [filesystem_part], False),
        )
        # An update skips the filesystem and lets the user keep the chip
        # unerased, so stored patterns and settings survive.
        write_json(
            target / "manifest-update.json",
            manifest(version, base_parts, True),
        )

        variants.append(
            {
                "id": kit,
                "name": name,
                "install": f"{version}/{kit}/manifest.json",
                "update": f"{version}/{kit}/manifest-update.json",
            }
        )

    index_path = site / "index.json"
    index = json.loads(index_path.read_text()) if index_path.exists() else {"releases": []}
    releases = [
        release for release in index["releases"] if release["version"] != version
    ]
    releases.append(
        {
            "version": version,
            "date": datetime.date.today().isoformat(),
            "variants": variants,
        }
    )
    releases.sort(key=lambda release: version_key(release["version"]), reverse=True)
    write_json(index_path, {"releases": releases})


if __name__ == "__main__":
    main()

# Compiling Info
1. Connect your ESP32 PCB to your computer via USB, on windows it should show up as "USB Serial Device (COM#)" with the "#" being a random number.
1. Open this folder up in VSCode with the PlatformIO plugin stalled.
1. Pick the environment that matches your hardware with the environment switcher on the bottom bar, see the table below.
1. Hit the -> arrow button on the bottom bar to compile and upload the firmware to your PCB.

All the library dependencies and board config is contained in the platformio.ini file in this folder.

| Environment | Hardware |
| --- | --- |
| `blank_canvas` (default) | No output until configured with the app |
| `kit_2_2_1_20px` | PCB V2.2.1 with 20 NeoPixels |
| `kit_3_0_0_25px` | PCB V3.0.0 with 25 NeoPixels |
| `kit_3_0_0_55px` | PCB V3.0.0 with 55 DotStars |

Each environment sets `OPP_KIT`, which picks the matching defaults in [config.h](./src/config.h). From the command line, `pio run -e kit_3_0_0_25px` builds a single environment.

# Releasing to the web based firmware flasher
Run the "Release Firmware" workflow from the Actions tab and give it a version, for example `3.1.0`.

It builds the three kit environments and publishes them to the `web` branch, which GitHub Pages serves at https://mitchlol.github.io/Open-Pixel-Poi/firmware/. Each release gets its own folder, so older versions stay available:

- `firmware/index.json` lists every release and its kits, newest first. The flasher page reads it to build its buttons.
- `firmware/<version>/<kit>/manifest.json` is the full install. It erases the chip and writes the default patterns.
- `firmware/<version>/<kit>/manifest-update.json` is the update. It leaves the filesystem alone and asks before erasing, so patterns and settings survive when "Erase device" is left unchecked.

Releasing an existing version again replaces it.

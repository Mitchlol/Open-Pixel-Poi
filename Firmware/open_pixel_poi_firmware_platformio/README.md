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

# Note for self: Export a compiled firmware to web-based firmware flashy tool.
1. Hit the -> arrow button on the bottom bar to compile and upload the firmware to your PCB.
1. copy .pio/build/<environment>/firmware.bin to opp_firmware folder in the mitchlol.github.io project, replacing the old one.
1. update the manifest.json in that same folder with the current date to have some minimal tracking.


# Compiling Info
1. Connect your ESP32 PCB to your computer via USB, on windows it should show up as "USB Serial Device (COM#)" with the "#" being a random number.
1. Open this folder up in VSCode with the PlatformIO plugin stalled.
1. Hit the -> arrow button on the bottom bar to compile and upload the firmware to your PCB.

All the library dependencies and board config is contained in the platformio.ini file in this folder.

# Note for self: Export a compiled firmware to web-based firmware flashy tool.
1. Hit the -> arrow button on the bottom bar to compile and upload the firmware to your PCB.
1. copy .pio/build/seeed_xiao_esp32c3/firmware.bin to opp_firmware folder in the mitchlol.github.io project, replacing the old one.
1. update the manifest.json in that same folder with the current date to have some minimal tracking.


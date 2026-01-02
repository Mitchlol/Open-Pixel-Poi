# Open Pixel Poi Firmware

##### Links
- [User Manual](./MANUAL.md)
- [Firmware Flashy Thing](https://mitchlol.github.io/#openpixelpoi)

##### Firmware info
This is the firmware, it is an arduino project designed to be built in platformio.

Platformio should get all the correct dependancies automatically based on the config, but in case it doesn't here are the details.
It uses the neopixelbus library.
It requires the esp32 boards to be installed, I reccomend v2.0.12 as newer versions cause led glitches.
When builiding, use the XIAO_ESP32C3 board for the gpio config to line up. All the other board settings can be default.

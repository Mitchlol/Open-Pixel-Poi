# Notes about the config.h and app overrides

The [config.h](./open_pixel_poi_firmware_platformio/src/config.h) file contains all the constant perameters for the firmware. Most of these should never be changed, unless you are building custom hardware.

Some of the fields however can be changed via the app, such as renaming your device, changing the led quantity or type, or even changing your 6 speed options.

To enter to enter the device settings page, long press the app name on the patterns page.

Settings changed via the app will permanently overwrite the default config.h, unless a full chip erase is done. My firmware flashing webpage does a full erase. The default upload button in platformio does not.

To get a fully custom config, simply change what you need, recompile, and upload.

#ifndef _CONFIG_H
#define _CONFIG_H

#define BATTERY_VOLTAGE_SENSOR true
#define BATTERY_LATCH 0.05
#define BATTERY_VOLTAGE_LOW 3.45
#define BATTERY_VOLTAGE_CRITICAL 3.33
#define BATTERY_VOLTAGE_SHUTDOWN 3.25

#define OUTPUT_CURRENT_LIMIT 1.2
#define OUTPUT_CHANNELS 3
#define OUTPUT_WS2812B_5050_DRAW 0.050
#define OUTPUT_WS2812B_5050_SCALE 2.55
#define OUTPUT_SK9822_2020_DRAW 0.060
#define OUTPUT_SK9822_2020_SCALE 1.00 // Data sheet says max brightness = 10/32 = 79/255, but yolo we do 100/255

#define PATTERN_BANK_SIZE 5
#define PATTERN_BANK_COUNT 3

// Blank Canvas config (Defaults can be overriden with the bluetooth app)
#define DEFAULT_HARDWARE_VERSION 0 // 0 = no output, 1 = v2.2.1, 2 = v3.0.0
#define DEFAULT_LED_TYPE 0 // 0 = no output, 1 = Neo Pixel, 2 = Dot Star
#define DEFAULT_LED_COUNT 0
#define DEFAULT_DEVICE_NAME "Open Pixel Poi"

// Hardware kit 2.2.1 config
// #define DEFAULT_HARDWARE_VERSION 1 // 0 = no output, 1 = v2.2.1, 2 = v3.0.0
// #define DEFAULT_LED_TYPE 1 // 0 = no output, 1 = Neo Pixel, 2 = Dot Star
// #define DEFAULT_LED_COUNT 20
// #define DEFAULT_DEVICE_NAME "Open Pixel Poi"

// Hardware kit 3.0.0 25 NeoPixel config
// #define DEFAULT_HARDWARE_VERSION 2 // 0 = no output, 1 = v2.2.1, 2 = v3.0.0
// #define DEFAULT_LED_TYPE 1 // 0 = no output, 1 = Neo Pixel, 2 = Dot Star
// #define DEFAULT_LED_COUNT 25
// #define DEFAULT_DEVICE_NAME "Open Pixel Poi"

// Hardware kit 3.0.0 55 DotStar config
// #define DEFAULT_HARDWARE_VERSION 2 // 0 = no output, 1 = v2.2.1, 2 = v3.0.0
// #define DEFAULT_LED_TYPE 2 // 0 = no output, 1 = Neo Pixel, 2 = Dot Star
// #define DEFAULT_LED_COUNT 55
// #define DEFAULT_DEVICE_NAME "Open Pixel Poi"


#endif // _CONFIG_H

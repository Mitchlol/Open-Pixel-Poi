#ifndef _CONFIG_H
#define _CONFIG_H

#define BATTERY_VOLTAGE_SENSOR true
#define BATTERY_VOLTAGE_LATCH 0.05
#define BATTERY_VOLTAGE_LOW 3.45
#define BATTERY_VOLTAGE_CRITICAL 3.33
#define BATTERY_VOLTAGE_SHUTDOWN 3.25

#define OUTPUT_CURRENT_LIMIT 1.2
#define OUTPUT_CHANNELS 3
#define OUTPUT_WS2812B_5050_DRAW 0.050
#define OUTPUT_WS2812B_5050_SCALE 2.55
#define OUTPUT_SK9822_2020_DRAW 0.060
#define OUTPUT_SK9822_2020_SCALE 1.00 // Data sheet says max brightness = 10/32 = 79/255, but yolo we do 100/255

// These limits max out the available space in the current partition scheme. They are also hardcoded in the app.
#define PATTERN_BANK_SIZE 5
#define PATTERN_BANK_COUNT 3
#define PATTERN_PIXEL_LIMIT 40000
#define PATTERN_SHUFFLE_DURATION 10 // This one is editable


#define DEFAULT_DEVICE_NAME "Open Pixel Poi"
#define BRIGHTNESS_OPTIONS (uint16_t[]){ 1, 3, 10, 25, 50, 100}


// Blank Canvas config (Defaults can be overriden with the bluetooth app)
#define DEFAULT_HARDWARE_VERSION 0 // 0 = no output, 1 = v2.2.1, 2 = v3.0.0
#define DEFAULT_LED_TYPE 0 // 0 = no output, 1 = Neo Pixel, 2 = Dot Star
#define DEFAULT_LED_COUNT 0
#define SPEED_OPTIONS (uint16_t[]){ 1, 3, 30, 100, 400, 600}

// Hardware kit 2.2.1 config
// #define DEFAULT_HARDWARE_VERSION 1 // 0 = no output, 1 = v2.2.1, 2 = v3.0.0
// #define DEFAULT_LED_TYPE 1 // 0 = no output, 1 = Neo Pixel, 2 = Dot Star
// #define DEFAULT_LED_COUNT 20
// #define SPEED_OPTIONS (uint16_t[]){ 1, 3, 30, 100, 400, 600}

// Hardware kit 3.0.0 25 NeoPixel config
// #define DEFAULT_HARDWARE_VERSION 2 // 0 = no output, 1 = v2.2.1, 2 = v3.0.0
// #define DEFAULT_LED_TYPE 1 // 0 = no output, 1 = Neo Pixel, 2 = Dot Star
// #define DEFAULT_LED_COUNT 25
// #define SPEED_OPTIONS (uint16_t[]){ 1, 3, 30, 150, 600, 800}

// Hardware kit 3.0.0 55 DotStar config
// #define DEFAULT_HARDWARE_VERSION 2 // 0 = no output, 1 = v2.2.1, 2 = v3.0.0
// #define DEFAULT_LED_TYPE 2 // 0 = no output, 1 = Neo Pixel, 2 = Dot Star
// #define DEFAULT_LED_COUNT 55
// #define SPEED_OPTIONS (uint16_t[]){ 1, 3, 30, 500, 1500, 2000}

#endif // _CONFIG_H

#ifndef _CONFIG_H
#define _CONFIG_H

#define BATTERY_VOLTAGE_SENSOR false
#define BATTERY_LATCH 0.05
#define BATTERY_VOLTAGE_LOW 3.45
#define BATTERY_VOLTAGE_CRITICAL 3.33
#define BATTERY_VOLTAGE_SHUTDOWN 3.25

#define PATTERN_BANK_SIZE 5
#define PATTERN_BANK_COUNT 3

 // 0 = no output, 1 = v2.2.1, 2 = v3.0.0
#define DEFAULT_HARDWARE_VERSION 1
// 0 = Neo Pixel, 1 = Dot Star
#define DEFAULT_LED_TYPE 1
#define DEFAULT_LED_COUNT 20
#define DEFAULT_DEVICE_NAME "Open Pixel Poi"

#endif // _CONFIG_H

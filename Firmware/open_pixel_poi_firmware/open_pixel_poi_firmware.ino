// Sub-Modules
#include "open_pixel_poi_led.cpp"
#include "open_pixel_poi_ble.cpp"

#define DEBUG  // Comment this line out to remove printf statements in released version
#ifdef DEBUG
#define debugf(...) Serial.print("<<main>> ");Serial.printf(__VA_ARGS__);
#define debugf_noprefix(...) Serial.printf(__VA_ARGS__);
#else
#define debugf(...)
#define debugf_noprefix(...)
#endif

OpenPixelPoiConfig config;
OpenPixelPoiPatterns patterns(config);
OpenPixelPoiBLE ble(config, patterns);
OpenPixelPoiLED led(config);

int refreshRate = 30;

void setup() {
  Serial.begin(57600);
  while(!Serial);  // required for Serial.print* to work correctly

  debugf("Open Pixel POI\n");
  debugf("Setup Begin\n");

  config.setup();
  led.setup();
  ble.setup();
  debugf("- Setup Complete\n");
}

void loop() {
  ble.loop();
  led.loop();
}

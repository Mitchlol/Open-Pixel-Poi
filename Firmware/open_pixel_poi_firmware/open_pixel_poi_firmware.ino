// Sub-Modules
#include "open_pixel_poi_led.cpp"
#include "open_pixel_poi_ble.cpp"

// Release Version (2023.05.07)
// Program Storage Space
// -   943,324 (71%)
// - 1,310,720 Max
// Dynamic Memory
// - Max = 327,680
// - Global Variables = 39,476 bytes
// - Local Variable Space = 288,204

// Debug Version (2023.05.07)
// Program Storage Space
// -   945,460 (72%)
// - 1,310,720 Max
// Dynamic Memory
// - Max = 327,680
// - Global Variables     =  39,476 bytes
// - Local Variable Space = 288,204 bytes

#define DEBUG  // Comment this line out to remove printf statements in released version
#ifdef DEBUG
#define debugf(...) Serial.print("<<main>> ");Serial.printf(__VA_ARGS__);
#define debugf_noprefix(...) Serial.printf(__VA_ARGS__);
#else
#define debugf(...)
#define debugf_noprefix(...)
#endif


OpenPixelPoiConfig config;
OpenPixelPoiBLE ble(config);
OpenPixelPoiLED led(config);
OpenPixelPoiPatterns patterns;

//TaskHandle_t Task1;

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
  //config.loop();
  ble.loop();
  led.loop();
  delay(1000/refreshRate);
}

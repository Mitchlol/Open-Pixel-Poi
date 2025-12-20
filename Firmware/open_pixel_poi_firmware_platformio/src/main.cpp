// Sub-Modules
#include "open_pixel_poi_led.cpp"
#include "open_pixel_poi_ble.cpp"
#include "open_pixel_poi_button.cpp"

//#define DEBUG  // Comment this line out to remove printf statements in released version
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
OpenPixelPoiButton button(config);

void setup() {
  #ifdef DEBUG
    Serial.begin(19200);
    Serial.setDebugOutput(true);
    // while(!Serial);  // required for Serial.print* to work correctly
  #endif

  debugf("Open Pixel POI\n");
  debugf("Setup Begin\n");

  config.setup();
  led.setup();
  ble.setup();
  button.setup();
  debugf("- Setup Complete\n");
}

void loop() {
  // Redundent loop to avoid a lag every 2 seconds caused by 
  // https://github.com/espressif/arduino-esp32/blob/50ef6f4369fb85139f000f7bbc5a9f9d5bc02b9f/cores/esp32/main.cpp#L68
  while(true){
    if(ble.multipartPattern == 0){
      ble.loop();
      config.loop();
      led.loop();
      button.loop();
    }else{
      delay(250);
      // jammed
      if(millis() - ble.bleLastReceived > 5000){
        ble.multipartPattern = 0;
      }
    }
  }
}

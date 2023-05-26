#ifndef _OPEN_PIXEL_POI_BUTTON
#define _OPEN_PIXEL_POI_BUTTON

#include "open_pixel_poi_config.cpp"

//#define DEBUG  // Comment this line out to remove printf statements in released version
#ifdef DEBUG
#define debugf(...) Serial.print("<<button>> ");Serial.printf(__VA_ARGS__);
#define debugf_noprefix(...) Serial.printf(__VA_ARGS__);
#else
#define debugf(...)
#define debugf_noprefix(...)
#endif

class OpenPixelPoiButton {

private:
  OpenPixelPoiConfig& config;

  int buttonState = 0;
  long downTime = 0;

public:
  OpenPixelPoiButton(OpenPixelPoiConfig& _config): config(_config) {}    

  void setup() {
    pinMode(D1,INPUT);
  }

  void loop() {
    if(analogRead(D1) < 100){
      if(buttonState == 0){
        downTime = millis();
        buttonState = 1;
      }else if(buttonState == 1 && millis() - downTime > 750){
        buttonState = 2;
        config.setPatternSlot((config.patternSlot + 1) %5);
      }
    }else{
      buttonState = 0;
    }
  }

};

#endif

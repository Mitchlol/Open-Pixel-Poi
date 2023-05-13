#ifndef _OPEN_PIXEL_POI_LED
#define _OPEN_PIXEL_POI_LED

#include "open_pixel_poi_config.cpp"

// LED
#include <Adafruit_NeoPixel.h>

#define DEBUG  // Comment this line out to remove printf statements in released version
#ifdef DEBUG
#define debugf(...) Serial.print("  <<led>> ");Serial.printf(__VA_ARGS__);
#define debugf_noprefix(...) Serial.printf(__VA_ARGS__);
#else
#define debugf(...)
#define debugf_noprefix(...)
#endif

class OpenPixelPoiLED {
  private:
    OpenPixelPoiConfig& config;

    bool flipflop = true;
    int brightness = 0;

    // Declare our NeoPixel strip object:
    Adafruit_NeoPixel led_strip{22, D0, NEO_GRB + NEO_KHZ800};
    
  public:
    OpenPixelPoiLED(OpenPixelPoiConfig& _config): config(_config) {}    
    int frameIndex;
    void setup(){
      debugf("Setup begin\n");


      // LED Setup:
      led_strip.begin();
      frameIndex = 0;

      debugf("Setup complete\n");
    }

    void loop(){
      
      uint8_t red;
      uint8_t green;
      uint8_t blue;

      led_strip.clear();
      for (int j=0; j<20; j++){
        
        red = config.pattern[frameIndex*config.frameHeight*3 + j%config.frameHeight*3 + 0];
        green = config.pattern[frameIndex*config.frameHeight*3 + j%config.frameHeight*3 + 1];
        blue = config.pattern[frameIndex*config.frameHeight*3 + j%config.frameHeight*3 + 2];
        led_strip.setPixelColor(j, led_strip.Color(red, green, blue));
      }
      led_strip.setBrightness(config.ledBrightness);

      led_strip.show();
      delay(1000/config.animationSpeed);
      frameIndex += 1;
      if(frameIndex >= config.frameCount){
        frameIndex = 0;
      }
    }
};

#endif

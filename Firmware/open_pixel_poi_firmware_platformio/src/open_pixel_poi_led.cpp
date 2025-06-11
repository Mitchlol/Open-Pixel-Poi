#ifndef _OPEN_PIXEL_POI_LED
#define _OPEN_PIXEL_POI_LED

#include "open_pixel_poi_config.cpp"

// LED
#include <Adafruit_NeoPixel.h>

//#define DEBUG  // Comment this line out to remove printf statements in released version
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
    uint8_t red;
    uint8_t green;
    uint8_t blue;
    long lastFrameIndex = 0;

    // Declare our NeoPixel strip object:
    Adafruit_NeoPixel led_strip{20, D8, NEO_GRB + NEO_KHZ800};
    
  public:
    OpenPixelPoiLED(OpenPixelPoiConfig& _config): config(_config) {}    
    int frameIndex;
    void setup(){
      debugf("Setup begin\n");


      // LED Setup:
      led_strip.begin();
      frameIndex = 0;

      debugf("LED setup complete\n");
    }

    void loop(){
      led_strip.clear();
      if(config.displayState == DS_PATTERN || config.displayState == DS_PATTERN_ALL  || config.displayState == DS_PATTERN_ALL_ALL){
        frameIndex = ((millis() - config.displayStateLastUpdated) / (1000/(config.animationSpeed*2))) % config.frameCount;
        if(lastFrameIndex == frameIndex){
          return;
        }else{
          lastFrameIndex = frameIndex;
        }
        for (int j=0; j<20; j++){
          red = config.pattern[frameIndex*config.frameHeight*3 + j%config.frameHeight*3 + 0];
          green = config.pattern[frameIndex*config.frameHeight*3 + j%config.frameHeight*3 + 1];
          blue = config.pattern[frameIndex*config.frameHeight*3 + j%config.frameHeight*3 + 2];
          led_strip.setPixelColor(19-j, led_strip.Color(red, green, blue)); // Invert display, this makes a veritical image right side up at the top of a poi's arc, when it is upside down.
        }
      }else if(config.displayState == DS_WAITING || config.displayState == DS_WAITING2 || config.displayState == DS_WAITING3 || config.displayState == DS_WAITING4 || config.displayState == DS_WAITING5){
        // 500ms or till interupted
        if(config.displayState == DS_WAITING){
          // Blue for blinky!
          red = 0x00;
          green = 0x00;
          blue = 0xff;
        }else if(config.displayState == DS_WAITING2){
          // Pink for bank select & demo mode!
          red = 255;
          green = 0;
          blue = 255;
        }else if(config.displayState == DS_WAITING3){
          // White for brightness!
          red = 0x88;
          green = 0x88;
          blue = 0x88;
        }else if(config.displayState == DS_WAITING4){
          // RED for speed!
          red = 0xFF;
          green = 0x00;
          blue = 0x00;
        }else if(config.displayState == DS_WAITING5){
          // Green -> RED fade for battery!
          red = 0xFF * ((millis() - config.displayStateLastUpdated)/500.0);
          green = 0xFF - red;
          blue = 0x00;
        }
        for(int j=0; j<20; j++){
          if(j == (millis() - config.displayStateLastUpdated)/50 || 20 - j == (millis() - config.displayStateLastUpdated)/50){
            led_strip.setPixelColor(j, led_strip.Color(red, green, blue));
          }else{
            led_strip.setPixelColor(j, led_strip.Color(0x00, 0x00, 0x00));
          }
        }
      }else if(config.displayState == DS_VOLTAGE){
        if(config.batteryVoltage >= 4.00){
          green = 255;
        }else if(config.batteryVoltage <= 3.50){
          green = 0;
        }else{
          green = (((config.batteryVoltage - 3.50) * 2) * 255);
        } 
        red = 0xff - green;
        blue = 0x00;
        for (int j=0; j<20; j++){
          led_strip.setPixelColor(j, led_strip.Color(red, green, blue));
        }
      }else if(config.displayState == DS_VOLTAGE2){
        if(config.batteryVoltage > 3.90){
          red = 0x00;
          green = 0xff;
          blue = 0x00;
        }else if(config.batteryVoltage > 3.50){
          red = 0xAA;
          green = 0xAA;
          blue = 0x00;
        }else{
          red = 0xFF;
          green = 0x00;
          blue = 0x00;
        }
        
        for (int j=0; j<(int)config.batteryVoltage; j++){
          led_strip.setPixelColor(j, led_strip.Color(0, 0, 255));
        }
        for (int j=0; j<(int)((config.batteryVoltage - (int)config.batteryVoltage) * 10); j++){
          if(j > 5){
            led_strip.setPixelColor(j+11, led_strip.Color(red, green, blue)); 
          }else if(j > 2){
            led_strip.setPixelColor(j+10, led_strip.Color(red, green, blue)); 
          }else{
            led_strip.setPixelColor(j+9, led_strip.Color(red, green, blue)); 
          }
        }
      }else if(config.displayState == DS_SHUTDOWN){
        if(config.batteryVoltage >= 4.00){
          green = 255;
        }else if(config.batteryVoltage <= 3.50){
          green = 0;
        }else{
          green = (((config.batteryVoltage - 3.50) * 2) * 255);
        } 
        red = (0xff - green);
        blue = 0x00;
        // 2000ms Blink & Pixel Crush
        if (millis() - config.displayStateLastUpdated > 200) {
          for(int j=9; j>=((millis() - config.displayStateLastUpdated)/200); j--){
            led_strip.setPixelColor(j, led_strip.Color(red, green, blue));
            led_strip.setPixelColor(9+(10-j), led_strip.Color(red, green, blue));
          }
        }
      }else if(config.displayState == DS_BANK){
        if (millis() - config.displayStateLastUpdated < 1500){
          for (int j=0; j <= (millis() - config.displayStateLastUpdated)/125; j+=4){
            led_strip.setPixelColor(j, led_strip.Color(0xFF, 0x00, 0xFF));
            led_strip.setPixelColor(j+1, led_strip.Color(0xFF, 0x00, 0xFF));
            led_strip.setPixelColor(j+2, led_strip.Color(0xFF, 0x00, 0xFF));
          }
        }else {
          for (int j=0; j < 12; j+=4){
            led_strip.setPixelColor(j, led_strip.Color(0xFF, 0x00, 0xFF));
            led_strip.setPixelColor(j+1, led_strip.Color(0xFF, 0x00, 0xFF));
            led_strip.setPixelColor(j+2, led_strip.Color(0xFF, 0x00, 0xFF));
          }
          if (millis() - config.displayStateLastUpdated < 2000){
            led_strip.setPixelColor(1, led_strip.Color(0x00, 0x00, 0xFF));
            led_strip.setPixelColor(5, led_strip.Color(0x00, 0x00, 0xFF));
            led_strip.setPixelColor(9, led_strip.Color(0x00, 0x00, 0xFF));
          }else if (millis() - config.displayStateLastUpdated < 2500){
            led_strip.setPixelColor(1, led_strip.Color(0x00, 0x00, 0xFF));
          }else if (millis() - config.displayStateLastUpdated < 3000){
            led_strip.setPixelColor(5, led_strip.Color(0x00, 0x00, 0xFF));
          }else{
            led_strip.setPixelColor(9, led_strip.Color(0x00, 0x00, 0xFF));
          }
        }
      }else if(config.displayState == DS_BRIGHTNESS){
        // Override brightness without saving it. Button will save it upon release.
        if(millis() - config.displayStateLastUpdated < 500){
          config.ledBrightness = 1;
        }else if(millis() - config.displayStateLastUpdated < 1000){
          config.ledBrightness = 4;
        }else if(millis() - config.displayStateLastUpdated < 1500){
          config.ledBrightness = 10;
        }else if(millis() - config.displayStateLastUpdated < 2000){
          config.ledBrightness = 25;
        }else{
          config.ledBrightness = 100;
        }
        red = 0xFF;
        green = 0xFF;
        blue = 0xFF;
        for (int j=0; j< 20; j++){
          if (j % 4 == 1 || j % 4 == 2){
            led_strip.setPixelColor(j, led_strip.Color(red, green, blue));
          }
        }
      }else if(config.displayState == DS_SPEED){
        red = 0xFF;
        for (int j=0; j < (millis() - config.displayStateLastUpdated)/250; j+=2){
          led_strip.setPixelColor(j, led_strip.Color(red, 0, 0));
          led_strip.setPixelColor(j+1, led_strip.Color(red, 0, 0));
        }
      }

      // Set Brightness. Low voltage = force low brightness
      if(config.batteryState == BAT_LOW && config.ledBrightness > 10){
        led_strip.setBrightness(10);
      }else if(config.batteryState == BAT_CRITICAL || config.batteryState == BAT_SHUTDOWN){
        led_strip.setBrightness(1);
      }else{
        led_strip.setBrightness(config.ledBrightness);
      }
      // Shutdown fadeout
      if(config.displayState == DS_SHUTDOWN){
        uint8_t fadedBrightness = led_strip.getBrightness() * ((2000-(millis() - config.displayStateLastUpdated))/2000.0);
        if (fadedBrightness == 0){
          fadedBrightness = 1;
        }
        led_strip.setBrightness(fadedBrightness);
      }

      // Super low voltage, only display red
      if(config.batteryState == BAT_CRITICAL && (config.displayState == DS_PATTERN || config.displayState == DS_PATTERN_ALL)){
        led_strip.clear();
        led_strip.setPixelColor(0, led_strip.Color(255, 0x00, 0x00));
        led_strip.setPixelColor(19, led_strip.Color(255, 0x00, 0x00));
      }
      led_strip.show();
    }
};

#endif

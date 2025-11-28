#ifndef _OPEN_PIXEL_POI_LED
#define _OPEN_PIXEL_POI_LED

#include "open_pixel_poi_config.cpp"

#include <NeoPixelBusLg.h>
//#define DEBUG  // Comment this line out to remove printf statements in released version
#ifdef DEBUG
#define debugf(...) Serial.print("  <<led>> ");Serial.printf(__VA_ARGS__);
#define debugf_noprefix(...) Serial.printf(__VA_ARGS__);
#else
#define debugf(...)
#define debugf_noprefix(...)
#endif

class ILedStrip {
public:
    virtual void Begin() = 0;
    virtual void Show() = 0;
    virtual void SetPixelColor(uint16_t i, RgbColor color) = 0;
    virtual void ClearTo(RgbColor color) = 0;
    virtual void SetLuminance(uint8_t luminance) = 0;
    virtual uint8_t GetLuminance() = 0;
    virtual ~ILedStrip() = default;
};

class NeoPixelStrip : public ILedStrip {
public:
    NeoPixelStrip(uint16_t count, uint8_t dataPin) : strip(count, dataPin) {}

    void Begin() override { strip.Begin(); }
    void Show() override { strip.Show(); }
    void SetPixelColor(uint16_t i, RgbColor color) override { strip.SetPixelColor(i, color); }
    void ClearTo(RgbColor color) override { strip.ClearTo(color); }
    void SetLuminance(uint8_t i) override { strip.SetLuminance(i); }
    uint8_t GetLuminance() override { return strip.GetLuminance(); }

private:
    NeoPixelBusLg<NeoGrbFeature, NeoWs2812xMethod, NeoGammaNullMethod> strip;
};

class DotStarStrip  : public ILedStrip {
public:
    DotStarStrip(uint16_t count, uint8_t dataPin, uint8_t clockPin) : strip(count, clockPin, dataPin) {}

    void Begin() override { strip.Begin(); }
    void Show() override { strip.Show(); }
    void SetPixelColor(uint16_t i, RgbColor color) override { strip.SetPixelColor(i, color); }
    void ClearTo(RgbColor color) override { strip.ClearTo(color); }
    void SetLuminance(uint8_t i) override { strip.SetLuminance(i); }
    uint8_t GetLuminance() override { return strip.GetLuminance(); }

private:
    NeoPixelBusLg<DotStarBgrFeature, DotStarMethod, NeoGammaNullMethod> strip;
};


class OpenPixelPoiLED {
  private:
    OpenPixelPoiConfig& config;
    uint8_t red;
    uint8_t green;
    uint8_t blue;
    long lastFrameIndex = 0;

    // Declare our NeoPixel strip object:
    // Adafruit_NeoPixel led_strip{20, D8, NEO_GRB + NEO_KHZ800};
    // NeoPixelBusLg<NeoGrbFeature, NeoWs2812xMethod, NeoGammaNullMethod> led_strip{20, D8};
    // NeoPixelBusLg<NeoGrbFeature, NeoWs2812xMethod, NeoGammaNullMethod> led_strip;
    //, led_strip(_config.ledCount, _config.pinoutVariant == 1? 8 : 6)
    ILedStrip* ledStrip;

  public:
    OpenPixelPoiLED(OpenPixelPoiConfig& _config): config(_config), ledStrip(nullptr) {
      if(config.ledType == 1){
        ledStrip = new NeoPixelStrip(config.ledCount, config.pinoutVariant == 1 ? 8 : 6);
      }else{
        ledStrip = new DotStarStrip(config.ledCount, 6, 7);
      }
    }    
    int frameIndex;
    void setup(){
      debugf("Setup begin\n");

      // LED Setup:
      ledStrip->Begin();
      frameIndex = 0;

      // Neopixelbus is weird for the first frame so render it blank
      ledStrip->ClearTo(RgbColor(0,0,0));
      ledStrip->SetLuminance(0);
      ledStrip->Show();

      debugf("LED setup complete\n");
    }

    void loop(){
      ledStrip->ClearTo(RgbColor(0,0,0));
      if(config.displayState == DS_PATTERN || config.displayState == DS_PATTERN_ALL  || config.displayState == DS_PATTERN_ALL_ALL){
        frameIndex = ((micros() - (config.displayStateLastUpdated * 1000)) / (1000000/(config.animationSpeed))) % config.frameCount;
        if(lastFrameIndex == frameIndex){
          return;
        }else{
          lastFrameIndex = frameIndex;
        }
        for (int j=0; j<config.ledCount; j++){
          red = config.pattern[frameIndex*config.frameHeight*3 + j%config.frameHeight*3 + 0];
          green = config.pattern[frameIndex*config.frameHeight*3 + j%config.frameHeight*3 + 1];
          blue = config.pattern[frameIndex*config.frameHeight*3 + j%config.frameHeight*3 + 2];
          ledStrip->SetPixelColor(config.ledCount-1-j, RgbColor(red, green, blue)); // Invert display, this makes a veritical image right side up at the top of a poi's arc, when it is upside down.
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
            ledStrip->SetPixelColor(j, RgbColor(red, green, blue));
          }else{
            ledStrip->SetPixelColor(j, RgbColor(0x00, 0x00, 0x00));
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
          ledStrip->SetPixelColor(j, RgbColor(red, green, blue));
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
          ledStrip->SetPixelColor(j, RgbColor(0, 0, 255));
        }
        for (int j=0; j<(int)((config.batteryVoltage - (int)config.batteryVoltage) * 10); j++){
          if(j > 5){
            ledStrip->SetPixelColor(j+11, RgbColor(red, green, blue)); 
          }else if(j > 2){
            ledStrip->SetPixelColor(j+10, RgbColor(red, green, blue)); 
          }else{
            ledStrip->SetPixelColor(j+9, RgbColor(red, green, blue)); 
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
            ledStrip->SetPixelColor(j, RgbColor(red, green, blue));
            ledStrip->SetPixelColor(9+(10-j), RgbColor(red, green, blue));
          }
        }
      }else if(config.displayState == DS_BANK){
        if (millis() - config.displayStateLastUpdated < 1500){
          for (int j=0; j <= (millis() - config.displayStateLastUpdated)/125; j+=4){
            ledStrip->SetPixelColor(j, RgbColor(0xFF, 0x00, 0xFF));
            ledStrip->SetPixelColor(j+1, RgbColor(0xFF, 0x00, 0xFF));
            ledStrip->SetPixelColor(j+2, RgbColor(0xFF, 0x00, 0xFF));
          }
        }else {
          for (int j=0; j < 12; j+=4){
            ledStrip->SetPixelColor(j, RgbColor(0xFF, 0x00, 0xFF));
            ledStrip->SetPixelColor(j+1, RgbColor(0xFF, 0x00, 0xFF));
            ledStrip->SetPixelColor(j+2, RgbColor(0xFF, 0x00, 0xFF));
          }
          if (millis() - config.displayStateLastUpdated < 2000){
            ledStrip->SetPixelColor(1, RgbColor(0x00, 0x00, 0xFF));
            ledStrip->SetPixelColor(5, RgbColor(0x00, 0x00, 0xFF));
            ledStrip->SetPixelColor(9, RgbColor(0x00, 0x00, 0xFF));
          }else if (millis() - config.displayStateLastUpdated < 2500){
            ledStrip->SetPixelColor(1, RgbColor(0x00, 0x00, 0xFF));
          }else if (millis() - config.displayStateLastUpdated < 3000){
            ledStrip->SetPixelColor(5, RgbColor(0x00, 0x00, 0xFF));
          }else{
            ledStrip->SetPixelColor(9, RgbColor(0x00, 0x00, 0xFF));
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
            ledStrip->SetPixelColor(j, RgbColor(red, green, blue));
          }
        }
      }else if(config.displayState == DS_SPEED){
        red = 0xFF;
        for (int j=0; j < (millis() - config.displayStateLastUpdated)/250; j+=2){
          ledStrip->SetPixelColor(j, RgbColor(red, 0, 0));
          ledStrip->SetPixelColor(j+1, RgbColor(red, 0, 0));
        }
      }

      // Set Brightness. Low voltage = force low brightness
      if(config.batteryState == BAT_LOW && config.ledBrightness > 10){
        ledStrip->SetLuminance(10);
      }else if(config.batteryState == BAT_CRITICAL || config.batteryState == BAT_SHUTDOWN){
        ledStrip->SetLuminance(1);
      }else{ // Normal operation
        ledStrip->SetLuminance(config.ledBrightness);
      }
      // Shutdown fadeout
      if(config.displayState == DS_SHUTDOWN){
        uint8_t fadedBrightness = ledStrip->GetLuminance() * ((2000-(millis() - config.displayStateLastUpdated))/2000.0);
        if (fadedBrightness == 0){
          fadedBrightness = 1;
        }
        ledStrip->SetLuminance(fadedBrightness);
      }

      // Super low voltage, only display red
      if(config.batteryState == BAT_CRITICAL && (config.displayState == DS_PATTERN || config.displayState == DS_PATTERN_ALL)){
        ledStrip->ClearTo(RgbColor(0,0,0));
        ledStrip->SetPixelColor(0, RgbColor(255, 0x00, 0x00));
        ledStrip->SetPixelColor(19, RgbColor(255, 0x00, 0x00));
      }

      // Output
      ledStrip->Show();
    }
};

#endif

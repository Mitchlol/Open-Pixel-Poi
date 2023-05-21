#ifndef _OPEN_PIXEL_POI_CONFIG
#define _OPEN_PIXEL_POI_CONFIG

#include <Preferences.h>

#define DEBUG  // Comment this line out to remove printf statements in released version
#ifdef DEBUG
#define debugf(...) Serial.print("  <<config>> ");Serial.printf(__VA_ARGS__);
#define debugf_noprefix(...) Serial.printf(__VA_ARGS__);
#else
#define debugf(...)
#define debugf_noprefix(...)
#endif



// Seeed Studio XIAO ESP32C3
  // 512 Bytes EEPROM
  // 400KB SRAM
  // 4MB Flash memory
  
class OpenPixelPoiConfig {
  private:
    Preferences preferences;
    
  public:
    // Debug Config
    bool logToSerial = true;

    // Settings (come in from the app)
    uint8_t ledBrightness; 
    uint8_t animationSpeed;
    uint8_t frameHeight; // Will come in on the pattern payload
    uint8_t frameCount;
    uint8_t *pattern = (uint8_t *) malloc(2000*sizeof(uint8_t));
    uint16_t patternLength;

    // Variables
    long configLastUpdated;

    void setLedBrightness(uint8_t ledBrightness) {
      this->ledBrightness = ledBrightness;
      preferences.putChar("brightness", this->ledBrightness);
      this->configLastUpdated = millis();
    }
    
    void setAnimationSpeed(uint8_t animationSpeed) {
      this->animationSpeed = animationSpeed;
      preferences.putChar("animationSpeed", this->animationSpeed);
      this->configLastUpdated = millis();
    }
    
    void setFrameHeight(uint8_t frameHeight) {
      this->frameHeight = frameHeight;
      preferences.putChar("frameHeight", this->frameHeight);
      this->configLastUpdated = millis();
    }
    
    void setFrameCount(uint8_t frameCount) {
      this->frameCount = frameCount;
      preferences.putChar("frameCount", this->frameCount);
      this->configLastUpdated = millis();
    }
    
    void savePattern() {
      debugf("Save Pattern\n");
      debugf("- length = %d", this->patternLength);
      for (int i=0; i<this->patternLength; i+=3) {
        if (i%this->frameHeight*3 == 0) {
          debugf_noprefix("\n");
          debugf("  ");
        }
        debugf_noprefix("0x%02X%02X%02X ", this->pattern[i], this->pattern[i+1], this->pattern[i+2]);
      }
      debugf_noprefix("\n");
      preferences.putBytes("pattern", this->pattern, this->patternLength);
      this->configLastUpdated = millis();
    }
      
    
    void setup() {
      debugf("Setup begin\n");
      debugf("Load Config (setup)\n");

      preferences.begin("led_pattern", false);

      this->ledBrightness = preferences.getChar("brightness", 0xff);
      debugf("- brightness = %d\n", this->ledBrightness);

      this->animationSpeed = preferences.getChar("animationSpeed", 0);
      debugf("- animation speed = %d frames per sec\n", this->animationSpeed);

      this->frameHeight = preferences.getChar("frameHeight", 0);
      this->frameCount = preferences.getChar("frameCount", 0);
      debugf("- frame\n");
      debugf("  - height = %d\n", this->frameHeight);
      debugf("  - count = %d\n", this->frameCount);
      
      for (int i=0; i<sizeof(this->pattern); i++) {
        this->pattern[i] = 0;
      }
      int savedPatternLength = preferences.getBytesLength("pattern");
      preferences.getBytes( "pattern", pattern, savedPatternLength );
      debugf("- pattern\n");
      debugf("  - length = %d", savedPatternLength);
      for (int i = 0; i < savedPatternLength; i+=3 ) {
        if (i%this->frameHeight*3 == 0) {
          debugf_noprefix("\n");
          debugf("    ");
        }
        debugf_noprefix("0x%02X%02X%02X ", this->pattern[i], this->pattern[i+1], this->pattern[i+2]);
      }
      debugf_noprefix("\n");
      debugf("Setup complete\n");
    }

    void loop() {}
};

#endif

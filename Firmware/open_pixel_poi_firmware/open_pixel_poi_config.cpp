#ifndef _OPEN_PIXEL_POI_CONFIG
#define _OPEN_PIXEL_POI_CONFIG

#include <FS.h>
#include <SPIFFS.h>
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
    // Settings (come in from the app)
    uint8_t ledBrightness; 
    uint8_t animationSpeed;
    uint8_t patternSlot;
    // Pattern
    uint8_t frameHeight; 
    uint16_t frameCount;
    uint8_t *pattern = (uint8_t *) malloc(24000*sizeof(uint8_t));
    uint16_t patternLength;

    // Variables
    long configLastUpdated;

    void setLedBrightness(uint8_t ledBrightness) {
      debugf("Save Brightness = %d\n", ledBrightness);
      this->ledBrightness = ledBrightness;
      preferences.putChar("brightness", this->ledBrightness);
      this->configLastUpdated = millis();
    }
    
    void setAnimationSpeed(uint8_t animationSpeed) {
      debugf("Save Speed = %d\n", animationSpeed * 2);
      this->animationSpeed = animationSpeed;
      preferences.putChar("animationSpeed", this->animationSpeed);
      this->configLastUpdated = millis();
    }

    void setPatternSlot(uint8_t patternSlot) {
      debugf("Save Pattern Slot = %d\n", patternSlot);
      this->patternSlot = patternSlot;
      preferences.putChar("patternSlot", this->patternSlot);

      loadFrameHeight();
      loadFrameCount();
      fillDefaultPattern();
      loadPattern();

      debugf("- frame\n");
      debugf("  - height = %d\n", this->frameHeight);
      debugf("  - count = %d\n", this->frameCount);
      
      this->configLastUpdated = millis();
    }
    
    void setFrameHeight(uint8_t frameHeight) {
      this->frameHeight = frameHeight;
      char * key;
      switch(this->patternSlot){
        case 0:
          key = "p0Height";
          break;
        case 1:
          key = "p1Height";
          break;
        case 2:
          key = "p2Height";
          break;
        case 3:
          key = "p3Height";
          break;
        case 4:
          key = "p4Height";
          break;
      }
      preferences.putChar(key, this->frameHeight);
      this->configLastUpdated = millis();
    }
    
    void setFrameCount(uint16_t frameCount) {
      this->frameCount = frameCount;
      char * key;
      switch(this->patternSlot){
        case 0:
          key = "p0FCount";
          break;
        case 1:
          key = "p1FCount";
          break;
        case 2:
          key = "p2FCount";
          break;
        case 3:
          key = "p3FCount";
          break;
        case 4:
          key = "p4FCount";
          break;
      }
      preferences.putUShort(key, this->frameCount);
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

      File file = SPIFFS.open(String("/pattern") + this->patternSlot + ".oppp", FILE_WRITE);
      if(!file || file.isDirectory()){
        debugf("− failed to open file for reading\n");
      }else{
        debugf(" - opened file for writing: %d\n");
        
        int written = file.write(pattern, patternLength);
        file.close();
        debugf(" - this much written: %d\n", written);
      }
      
      this->configLastUpdated = millis();
    }

    void fillDefaultPattern(){
      for (int i=0; i < this->frameCount; i++) {
        for (int j=0; j < this->frameHeight; j++) {
          if(i % 2 == 1){
            pattern[(i * this->frameHeight * 3) + (j*3) + 0] = 0xFF;
            pattern[(i * this->frameHeight * 3) + (j*3) + 1] = 0xFF;
            pattern[(i * this->frameHeight * 3) + (j*3) + 2] = 0x00;
          }else{
            pattern[(i * this->frameHeight * 3) + (j*3) + 0] = 0x00;
            pattern[(i * this->frameHeight * 3) + (j*3) + 1] = 0x00;
            pattern[(i * this->frameHeight * 3) + (j*3) + 2] = 0x00;
          }
        }
      }
    }

    void loadPattern(){
      File file = SPIFFS.open(String("/pattern") + this->patternSlot + ".oppp");
      if(!file || file.isDirectory()){
        debugf("− failed to open file for reading\n");
      }else{
        debugf(" - this much available: %d\n", file.available());
        file.read(pattern, file.available());
        file.close();
      }
    }

    void loadFrameHeight(){
      char * key;
      switch(this->patternSlot){
        case 0:
          key = "p0Height";
          break;
        case 1:
          key = "p1Height";
          break;
        case 2:
          key = "p2Height";
          break;
        case 3:
          key = "p3Height";
          break;
        case 4:
          key = "p4Height";
          break;
      }
      this->frameHeight = preferences.getChar(key, 20);
    }

    void loadFrameCount(){
      char * key;
      switch(this->patternSlot){
        case 0:
          key = "p0FCount";
          break;
        case 1:
          key = "p1FCount";
          break;
        case 2:
          key = "p2FCount";
          break;
        case 3:
          key = "p3FCount";
          break;
        case 4:
          key = "p4FCount";
          break;
      }
      debugf("key = %s\n", key);
      this->frameCount = preferences.getUShort(key, 2);
    }
      
    
    void setup() {
      debugf("Setup begin\n");
      debugf("Load Config (setup)\n");

      if(!SPIFFS.begin(true)){
        debugf("SPIFFS Mount Failed\n");
      }

      preferences.begin("led_pattern", false);
      debugf("Preffs free entries: %d\n", preferences.freeEntries());

      this->ledBrightness = preferences.getChar("brightness", 0x0A);
      debugf("- brightness = %d\n", this->ledBrightness);

      this->animationSpeed = preferences.getChar("animationSpeed", 0x0A);
      debugf("- animation speed = %d frames per sec\n", this->animationSpeed * 2);

      this->patternSlot = preferences.getChar("patternSlot", 0x00);
      debugf("- pattern slot = %d\n", this->patternSlot);

      loadFrameHeight();
      loadFrameCount();
      debugf("- frame\n");
      debugf("  - height = %d\n", this->frameHeight);
      debugf("  - count = %d\n", this->frameCount);
      
      fillDefaultPattern();

      loadPattern();

      debugf("- pattern\n");
      for (int i = 0; i < this->frameHeight * this->frameCount; i+=3 ) {
        if (i%this->frameHeight*3 == 0) {
          debugf_noprefix("\n");
          debugf("    ");
        }
        debugf_noprefix("0x%02X%02X%02X ", this->pattern[i], this->pattern[i+1], this->pattern[i+2]);
      }
      debugf_noprefix("\n");
      
      debugf("Setup complete\n");
    }
};

#endif

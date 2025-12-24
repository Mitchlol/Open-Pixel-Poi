#ifndef _OPEN_PIXEL_POI_CONFIG
#define _OPEN_PIXEL_POI_CONFIG

#include <FS.h>
#include <LittleFS.h>
#include <Preferences.h>
#include "config.h"

//#define DEBUG  // Comment this line out to remove printf statements in released version
#ifdef DEBUG
#define debugf(...) Serial.print("  <<config>> ");Serial.printf(__VA_ARGS__);
#define debugf_noprefix(...) Serial.printf(__VA_ARGS__);
#else
#define debugf(...)
#define debugf_noprefix(...)
#endif

enum DisplayState {
  DS_PATTERN,
  DS_PATTERN_ALL,
  DS_PATTERN_ALL_ALL,
  DS_WAITING,
  DS_WAITING2,
  DS_WAITING3,
  DS_WAITING4,
  DS_WAITING5,
  DS_VOLTAGE,
  DS_VOLTAGE2,
  DS_BANK,
  DS_BRIGHTNESS,
  DS_SPEED,
  DS_SHUTDOWN
};

enum BatteryState {
  BAT_OK,
  BAT_LOW,
  BAT_CRITICAL,
  BAT_SHUTDOWN,
};
  
class OpenPixelPoiConfig {
  private:
    Preferences preferences;
    File patternFile;
    
  public:
    // Runtime State
    float batteryVoltage = BATTERY_VOLTAGE_LOW;
    BatteryState batteryState = BAT_OK;
    DisplayState displayState = DS_PATTERN;
    long displayStateLastUpdated = 0;
    // Hardware Settings (Defaults from config.h but can be overriden using the app) 
    uint8_t hardwareVersion;
    uint8_t ledType;
    uint8_t ledCount;
    String deviceName;
    // Display Settings (come in from the app or changed via button)
    uint8_t ledBrightness;
    uint8_t ledBrightnessOptions[6]; 
    uint16_t animationSpeed;
    uint16_t animationSpeedOptions[6];
    uint8_t patternSlot;
    uint8_t patternBank;
    uint8_t patternShuffleDuration;
    // Pattern
    uint8_t frameHeight; 
    uint16_t frameCount;
    uint8_t *pattern = (uint8_t *) malloc(PATTERN_PIXEL_LIMIT * 3 * sizeof(uint8_t));
    uint32_t patternLength;
    // Sequencer
    uint8_t *sequencer = (uint8_t *) malloc(1785*sizeof(uint8_t)); // 255 Instruction max (7 bits per instruction)
    uint16_t sequencerLength;
    int sequencerStep;
    ulong sequencerDelayed;

    // Variables
    long configLastUpdated;

    void setHardwareVersion(uint8_t hardwareVersion) {
      debugf("Save Hardware Version = %d\n", hardwareVersion);
      preferences.putChar("hardwareVersion", hardwareVersion);
    }

    void setLedType(uint8_t ledType) {
      debugf("Save LED Type = %d\n", ledBrightness);
      preferences.putChar("ledType", ledType);
    }

    void setLedCount(uint8_t ledCount) {
      debugf("Save LED Count = %d\n", ledCount);
      preferences.putChar("ledCount", ledCount);
    }

    void setDeviceName(String deviceName) {
      debugf("Save Device Name = %s\n", deviceName);
      preferences.putString("deviceName", deviceName);
    }

    void setLedBrightness(uint8_t ledBrightness) {
      debugf("Save Brightness = %d\n", ledBrightness);
      this->ledBrightness = ledBrightness;
      preferences.putChar("brightness", this->ledBrightness);
      this->configLastUpdated = millis();
    }

    void setLedBrightnessOptions(uint8_t b0, uint8_t b1, uint8_t b2, uint8_t b3, uint8_t b4, uint8_t b5) {
      debugf("Save Brightness Options = %d %d %d %d %d %d\n", b0, b1, b2, b3, b4, b5);
      this->ledBrightnessOptions[0] = max((uint8_t)1, min((uint8_t)100, b0));
      this->ledBrightnessOptions[1] = max((uint8_t)1, min((uint8_t)100, b1));
      this->ledBrightnessOptions[2] = max((uint8_t)1, min((uint8_t)100, b2));
      this->ledBrightnessOptions[3] = max((uint8_t)1, min((uint8_t)100, b3));
      this->ledBrightnessOptions[4] = max((uint8_t)1, min((uint8_t)100, b4));
      this->ledBrightnessOptions[5] = max((uint8_t)1, min((uint8_t)100, b5));
      preferences.putChar("brightnessOption0", this->ledBrightnessOptions[0]);
      preferences.putChar("brightnessOption1", this->ledBrightnessOptions[1]);
      preferences.putChar("brightnessOption2", this->ledBrightnessOptions[2]);
      preferences.putChar("brightnessOption3", this->ledBrightnessOptions[3]);
      preferences.putChar("brightnessOption4", this->ledBrightnessOptions[4]);
      preferences.putChar("brightnessOption5", this->ledBrightnessOptions[5]);
      this->configLastUpdated = millis();
    }
    
    void setAnimationSpeed(uint16_t animationSpeed) {
      debugf("Save Speed = %d\n", animationSpeed);
      this->animationSpeed = animationSpeed;
      preferences.putUShort("animationSpeed", this->animationSpeed);
      this->configLastUpdated = millis();
    }

    void setAnimationSpeedOptions(uint16_t s0, uint16_t s1, uint16_t s2, uint16_t s3, uint16_t s4, uint16_t s5) {
      debugf("Save Brightness Options = %d %d %d %d %d %d\n", s0, s1, s2, s3, s4, s5);
      this->animationSpeedOptions[0] = max((uint16_t)1, min((uint16_t)2000, s0));
      this->animationSpeedOptions[1] = max((uint16_t)1, min((uint16_t)2000, s1));
      this->animationSpeedOptions[2] = max((uint16_t)1, min((uint16_t)2000, s2));
      this->animationSpeedOptions[3] = max((uint16_t)1, min((uint16_t)2000, s3));
      this->animationSpeedOptions[4] = max((uint16_t)1, min((uint16_t)2000, s4));
      this->animationSpeedOptions[5] = max((uint16_t)1, min((uint16_t)2000, s5));
      preferences.putUShort("animationSpeedOption0", this->animationSpeedOptions[0]);
      preferences.putUShort("animationSpeedOption1", this->animationSpeedOptions[1]);
      preferences.putUShort("animationSpeedOption2", this->animationSpeedOptions[2]);
      preferences.putUShort("animationSpeedOption3", this->animationSpeedOptions[3]);
      preferences.putUShort("animationSpeedOption4", this->animationSpeedOptions[4]);
      preferences.putUShort("animationSpeedOption5", this->animationSpeedOptions[5]);
      this->configLastUpdated = millis();
    }

    void setPatternSlot(uint8_t patternSlot, bool save) {
      debugf("Save Pattern Slot = %d\n", patternSlot);
      this->patternSlot = patternSlot;
      if(save){
        preferences.putChar("patternSlot", this->patternSlot);
      }

      loadFrameHeight();
      loadFrameCount();
      startLoadingPattern();

      debugf("- frame\n");
      debugf("  - height = %d\n", this->frameHeight);
      debugf("  - count = %d\n", this->frameCount);
      
      this->configLastUpdated = millis();
    }

    void setPatternBank(uint8_t patternBank, bool save) {
      this->patternBank = patternBank;
      if(save){
        preferences.putChar("patternBank", this->patternBank);
      }
      loadFrameHeight();
      loadFrameCount();
      startLoadingPattern();
      
      this->configLastUpdated = millis();
    }

    void setPatternShuffleDuration(uint8_t patternShuffleDuration) {
      debugf("Save Pattern Shuffle Duration = %d\n", patternShuffleDuration);
      this->patternShuffleDuration = patternShuffleDuration;
      preferences.putChar("patternShuffleDuration", this->patternShuffleDuration);
      this->configLastUpdated = millis();
    }
    
    void setFrameHeight(uint8_t frameHeight) {
      this->frameHeight = frameHeight;
      String key = "p";
      key += this->patternSlot + (this->patternBank * PATTERN_BANK_SIZE);
      key += "Height";
      preferences.putChar(key.c_str(), this->frameHeight);
      this->configLastUpdated = millis();
    }
    
    void setFrameCount(uint16_t frameCount) {
      this->frameCount = frameCount;
      String key = "p";
      key += this->patternSlot + (this->patternBank * PATTERN_BANK_SIZE);
      key += "FCount";
      preferences.putUShort(key.c_str(), this->frameCount);
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

      File file = LittleFS.open(String("/pattern") + (this->patternSlot + (this->patternBank * PATTERN_BANK_SIZE)) + ".oppp", FILE_WRITE);
      if(!file || file.isDirectory()){
        debugf("− failed to open file for writing\n");
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

    void startLoadingPattern(){
      if(patternFile){
        patternFile.close();
      }
      patternFile = LittleFS.open(String("/pattern") + (this->patternSlot  + (this->patternBank * PATTERN_BANK_SIZE)) + ".oppp");
      if(!patternFile || patternFile.isDirectory()){
        debugf("− failed to open file for reading\n");
        fillDefaultPattern();
      }else{
        debugf(" - this much available: %d\n", file.available());
        // Filling the whole pattern with data is way too slow
        // just fill one pixel so we don't have a completely black pattern if something goes weird
        pattern[0] = 0xFF;
      }
      // Load first frame immediately (For large/fast patterns this is futile, as we already lagged past it)
      continueLoadingPattern();
    }

    void continueLoadingPattern(){
      if(patternFile && patternFile.available() > 0){
        if(patternFile.available() <= frameHeight * 3){
          patternFile.read(pattern + patternFile.position(), patternFile.available());
        }else{
          patternFile.read(pattern + patternFile.position(), frameHeight * 3);
        }
      }
    }

    void loadFrameHeight(){
      String key = "p";
      key += (this->patternSlot  + (this->patternBank * PATTERN_BANK_SIZE));
      key += "Height";
      this->frameHeight = preferences.getChar(key.c_str(), 5);
    }

    void loadFrameCount(){
      String key = "p";
      key += (this->patternSlot  + (this->patternBank * PATTERN_BANK_SIZE));
      key += "FCount";
      debugf("key = %s\n", key);
      this->frameCount = preferences.getUShort(key.c_str(), 5);
    }

    void saveSequencer() {
      debugf("Save Sequencer\n");
      debugf("- length = %d\n", this->sequencerLength);

      preferences.putUShort("sequencerLength", this->sequencerLength);

      File file = LittleFS.open("/sequencer.opps", FILE_WRITE);
      if(!file || file.isDirectory()){
        debugf("− failed to open file for writing\n");
      }else{
        debugf(" - opened file for writing: %d\n");
        
        int written = file.write(this->sequencer, this->sequencerLength);
        file.close();
        debugf(" - this much written: %d\n", written);
      }
    }

    void loadSequencer(){
      this->sequencerLength = preferences.getUShort("sequencerLength", 0x00);
      File file = LittleFS.open("/sequencer.opps");
      if(!file || file.isDirectory()){
        debugf("− failed to open file for reading\n");
      }else{
        file.read(this->sequencer, file.available());
        file.close();
      }
      this->sequencerStep = -1;
    }
      
    
    void setup() {
      debugf("Setup begin\n");
      debugf("Load Config (setup)\n");

      // Initialize storage access
      if(!LittleFS.begin(true)){
        debugf("LittleFS Mount Failed\n");
      }

      preferences.begin("led_pattern", false);
      debugf("Preffs free entries: %d\n", preferences.freeEntries());

      // Load hardware settings
      this->hardwareVersion = preferences.getChar("hardwareVersion", DEFAULT_HARDWARE_VERSION);
      this->ledType = preferences.getChar("ledType", DEFAULT_LED_TYPE);
      this->ledCount = preferences.getChar("ledCount", DEFAULT_LED_COUNT);
      this->deviceName = preferences.getString("deviceName", DEFAULT_DEVICE_NAME);

      // Load Display settings
      this->ledBrightness = preferences.getChar("brightness", BRIGHTNESS_OPTIONS[0]);
      debugf("- brightness = %d\n", this->ledBrightness);

      this->ledBrightnessOptions[0] = preferences.getChar("brightnessOption0", BRIGHTNESS_OPTIONS[0]);
      this->ledBrightnessOptions[1] = preferences.getChar("brightnessOption1", BRIGHTNESS_OPTIONS[1]);
      this->ledBrightnessOptions[2] = preferences.getChar("brightnessOption2", BRIGHTNESS_OPTIONS[2]);
      this->ledBrightnessOptions[3] = preferences.getChar("brightnessOption3", BRIGHTNESS_OPTIONS[3]);
      this->ledBrightnessOptions[4] = preferences.getChar("brightnessOption4", BRIGHTNESS_OPTIONS[4]);
      this->ledBrightnessOptions[5] = preferences.getChar("brightnessOption5", BRIGHTNESS_OPTIONS[5]);

      this->animationSpeed = preferences.getUShort("animationSpeed", SPEED_OPTIONS[5]);
      debugf("- animation speed = %d frames per sec\n", this->animationSpeed);

      this->animationSpeedOptions[0] = preferences.getUShort("animationSpeedOption0", SPEED_OPTIONS[0]);
      this->animationSpeedOptions[1] = preferences.getUShort("animationSpeedOption1", SPEED_OPTIONS[1]);
      this->animationSpeedOptions[2] = preferences.getUShort("animationSpeedOption2", SPEED_OPTIONS[2]);
      this->animationSpeedOptions[3] = preferences.getUShort("animationSpeedOption3", SPEED_OPTIONS[3]);
      this->animationSpeedOptions[4] = preferences.getUShort("animationSpeedOption4", SPEED_OPTIONS[4]);
      this->animationSpeedOptions[5] = preferences.getUShort("animationSpeedOption5", SPEED_OPTIONS[5]);

      this->patternSlot = preferences.getChar("patternSlot", 0x00);
      debugf("- pattern slot = %d\n", this->patternSlot);

      this->patternBank = preferences.getChar("patternBank", 0x00);
      debugf("- pattern bank = %d\n", this->patternBank);

      this->patternShuffleDuration = preferences.getChar("patternShuffleDuration", PATTERN_SHUFFLE_DURATION);
      debugf("- pattern shuffle duration = %d\n", this->patternShuffleDuration);

      loadFrameHeight();
      loadFrameCount();
      debugf("- frame\n");
      debugf("  - height = %d\n", this->frameHeight);
      debugf("  - count = %d\n", this->frameCount);

      startLoadingPattern();
      loadSequencer();

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

    void loop(){
      // Pattern Shuffle
      if((this->displayState == DS_PATTERN_ALL || this->displayState == DS_PATTERN_ALL_ALL) && millis() - this->displayStateLastUpdated > this->patternShuffleDuration * 1000){
        this->setPatternSlot((this->patternSlot + 1) % PATTERN_BANK_SIZE, false);
        if(this->patternSlot == 0 && this->displayState == DS_PATTERN_ALL_ALL){
          this->setPatternBank((this->patternBank + 1) % PATTERN_BANK_COUNT, false);
        }
        this->displayStateLastUpdated = millis();
      }

      // Sequencer (pattern slot, battern bank, brightness, speedx2, durationx2)
      if(this->displayState == DS_PATTERN && this->sequencerStep < (this ->sequencerLength / 7) - 1){
        uint16_t offset; 
        uint16_t previousTargetDuration;
        if(sequencerStep == -1){
          this->displayStateLastUpdated = millis();
          previousTargetDuration = 0;
          this->sequencerDelayed = 0;
        }else{
          offset = this->sequencerStep * 7; 
          previousTargetDuration = this->sequencer[offset+ 5] << 8 | this->sequencer[offset + 6];
        }
        ulong lastStepStartTime = (this->displayStateLastUpdated - this->sequencerDelayed);
        if(millis() - lastStepStartTime >= previousTargetDuration){
          this->sequencerStep++;
          offset = this->sequencerStep * 7; 
          this->patternSlot = this->sequencer[offset + 0];
          this->patternBank = this->sequencer[offset + 1];
          this->ledBrightness = this->sequencer[offset + 2];
          this->animationSpeed = this->sequencer[offset+ 3] << 8 | this->sequencer[offset + 4];
          loadFrameHeight();
          loadFrameCount();
          startLoadingPattern();
          // Roll over time from previous update to keep real time regardless of pattern load times
          // But offset displayStateLastUpdated by the load time, so we start rendering from the start of the pattern
          // This is important because the file is not fully loaded yet.
          this->sequencerDelayed = millis() - (lastStepStartTime + previousTargetDuration);
          this->displayStateLastUpdated = lastStepStartTime + previousTargetDuration + this->sequencerDelayed;
        }
      }else{
        // Abort sequencer on button press
        this->sequencerStep = this->sequencerLength / 7;
      }

      // Chunked pattern loading to avoid lag spike on pattern chanage
      continueLoadingPattern();

      // Battery latching state
      if(batteryVoltage <= BATTERY_VOLTAGE_SHUTDOWN || batteryState == BAT_SHUTDOWN){
        batteryState = BAT_SHUTDOWN;
      }else if(batteryVoltage <= BATTERY_VOLTAGE_CRITICAL || (batteryState == BAT_CRITICAL && batteryVoltage <= BATTERY_VOLTAGE_CRITICAL + BATTERY_VOLTAGE_LATCH)){
        batteryState = BAT_CRITICAL;
      }else if(batteryVoltage <= BATTERY_VOLTAGE_LOW || (batteryState == BAT_LOW && batteryVoltage <= BATTERY_VOLTAGE_LOW + BATTERY_VOLTAGE_LATCH)){
        batteryState = BAT_LOW;
      }else {
        batteryState = BAT_OK;
      }
      
    }
};

#endif

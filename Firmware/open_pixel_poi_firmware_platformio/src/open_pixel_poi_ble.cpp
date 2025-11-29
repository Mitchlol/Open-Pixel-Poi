// Some things need to be included here, seems files are loaded alphabetically
#include <arduino.h>
#include <Update.h>
#include "config.h"
#include "open_pixel_poi_config.cpp"

// BLE
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

//#define DEBUG  // Comment this line out to remove printf statements in released version
#ifdef DEBUG
#define debugf(...) Serial.print("  <<ble>> ");Serial.printf(__VA_ARGS__);
#define debugf_noprefix(...) Serial.printf(__VA_ARGS__);
#else
#define debugf(...)
#define debugf_noprefix(...)
#endif

// Message Protocol
// Start (1 byte)    = D0
// CommCode (1 byte)
//  Set Brightness   = 02
//  Set Speed        = 03
//  Set Pattern      = 04
// Message-specific payload (1 or more bytes) = <see message examples below>
// End (1 byte)      = D1   

// Set Brightness - 0 (off) to 255 (100%)
//   MessageType = 02
//   Payload = 1 byte
// D0 02 00 D1 (Off)
// D0 02 01 D1 (Very Dim)
// D0 02 80 D1 (Medium)
// D0 03 FF D1 (Very Bright)

// Set Animation Speed (0 to 255 Hz)
//   MessageType = 03
//   Payload = 1 byte
// DO 03 01 D1 (1 frame / sec)
// D0 03 B4 D1 (180 frames / sec; If you swing at 1 rotation per second each frame will be 1 degree)

// Set display pattern
//   MessageType = 04
//   FrameHeight = 1 byte
//   FrameCount = 1 byte
//   Pattern 3 bytes * frameHeight * frameCount = R,G,B (1 byte each)
// D0 04 01 01 FF FF FF D1 (1 Solid Red Pixel)
// D0 04 01 02 FF FF FF 00 00 00 D1 (1 Blinking Red Pixel)
// D0 04 03 03 00 00 FF 00 00 00 00 00 FF 00 00 00 00 00 FF 00 00 00 00 00 FF 00 00 00 00 00 FF D1 (solid blue x)

enum CommCode {
  CC_SUCCESS,             // 0
  CC_ERROR,               // 1
  CC_SET_BRIGHTNESS,      // 2
  CC_SET_SPEED,           // 3
  CC_SET_PATTERN,         // 4
  CC_SET_PATTERN_SLOT,    // 5
  CC_SET_PATTERN_ALL,     // 6
  CC_SET_BANK,            // 7
  CC_SET_BANK_ALL,        // 8
  CC_GET_FW_VERSION,      // 9
  CC_SET_HARDWARE_VERSION,// 10
  CC_SET_LED_TYPE,        // 11
  CC_SET_LED_COUNT,       // 12
  CC_SET_DEVICE_NAME,     // 13
};

class OpenPixelPoiBLE : public BLEServerCallbacks, public BLECharacteristicCallbacks{
  
  private:
    OpenPixelPoiConfig& config;

    int multipartPatternOffset = 0;
    
    // Nordic nRF
    BLEUUID pixelPoiServiceUUID = BLEUUID("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
    BLEUUID pixelPoiRxCharacteristicUUID = BLEUUID("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
    BLEUUID pixelPoiTxCharacteristicUUID = BLEUUID("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");
    BLEUUID pixelPoiNotifyCharacteristicUUID = BLEUUID("6E400004-B5A3-F393-E0A9-E50E24DCCA9E");

    BLEServer* server;
    bool deviceConnected = false;
    bool oldDeviceConnected = false;
    
    BLEService* pixelPoiService;
    BLECharacteristic* pixelPoiRxCharacteristic;
    BLECharacteristic* pixelPoiTxCharacteristic;
    BLECharacteristic* pixelPoiNotifyCharacteristic;

    void bleSendError(){
      uint8_t response[] = {0xD0, 0x00, 0x05, CC_ERROR, 0xD1};
      writeToPixelPoi(response);
    }
    
    void bleSendSuccess(){
      uint8_t response[] = {0xD0, 0x00, 0x05, CC_SUCCESS, 0xD1};
      writeToPixelPoi(response);
    }

    void bleSendFWVersion(){
      uint8_t response[] = {0xD0, 0x00, 0x06, CC_GET_FW_VERSION, 0x02, 0xD1};
      writeToPixelPoi(response);
    }
    
  public:
    OpenPixelPoiBLE(OpenPixelPoiConfig& _config): config(_config) {}

    long bleLastReceived;
    bool flagMultipartPattern = false;
    void setup(){
      debugf("Setup begin\n");
      // Create the BLE Device
      BLEDevice::init(config.deviceName.c_str());

      // Create the BLE Server
      server = BLEDevice::createServer();
      server->setCallbacks(this);
      
      // Create the pixelPoi BLE Service
      pixelPoiService = server->createService(pixelPoiServiceUUID);
      pixelPoiTxCharacteristic = pixelPoiService->createCharacteristic(pixelPoiTxCharacteristicUUID, BLECharacteristic::PROPERTY_READ);
      pixelPoiTxCharacteristic->addDescriptor(new BLE2902());
      pixelPoiNotifyCharacteristic = pixelPoiService->createCharacteristic(pixelPoiNotifyCharacteristicUUID, BLECharacteristic::PROPERTY_NOTIFY);
      pixelPoiNotifyCharacteristic->addDescriptor(new BLE2902());
      pixelPoiRxCharacteristic = pixelPoiService->createCharacteristic(pixelPoiRxCharacteristicUUID, BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR);
      pixelPoiRxCharacteristic->addDescriptor(new BLE2902());
      pixelPoiRxCharacteristic->setCallbacks(this);
      pixelPoiService->start();

      // Start advertising
      server->getAdvertising()->start();
      debugf("Waiting a client connection to notify..\n");
      debugf("Setup complete\n");
    }

    void loop(){      
      // disconnecting
      if (!deviceConnected && oldDeviceConnected) {
        delay(500); // give the bluetooth stack the chance to get things ready
        server->startAdvertising(); // restart advertising
        debugf("start advertising\n");
        oldDeviceConnected = deviceConnected;
      }
      // connecting
      if (deviceConnected && !oldDeviceConnected) {
        debugf("connecting!\n");
        // do stuff here on connecting
        oldDeviceConnected = deviceConnected;
      }
    }

    void writeToPixelPoi(uint8_t* data){
      if (deviceConnected) {
        pixelPoiTxCharacteristic->setValue(data, data[1] << 8 | data[2]);
        pixelPoiNotifyCharacteristic->notify();
      }
    }
    
    void onWrite(BLECharacteristic *characteristic) {
      debugf("OnWrite()!\n");
      if(characteristic->getUUID().equals(pixelPoiRxCharacteristicUUID)){
        bleLastReceived = millis();
        uint8_t* bleStatus = characteristic->getData();
        size_t bleLength = characteristic->getLength();
        
        
        debugf("Message incoming!\n");
        debugf("- len = %d\n", bleLength);
        debugf("- msg = ");
        for(int i = 0; i < bleLength; i++){
          debugf_noprefix("0x%x ",bleStatus[i]);
        }
        debugf("\n");
        
        // Process BLE
        if(bleStatus[0] == 0xD0 && bleStatus[bleLength - 1] == 0xD1 && !flagMultipartPattern){
          CommCode requestCode = static_cast<CommCode>(bleStatus[1]);
          if(requestCode == CC_SET_BRIGHTNESS){
            config.setLedBrightness(bleStatus[2]);
            bleSendSuccess();
          }else if(requestCode == CC_SET_SPEED){
            config.setAnimationSpeed(bleStatus[2] << 8 | bleStatus[3]);
            bleSendSuccess();
          }else if(requestCode == CC_SET_PATTERN){
            for (int i=0; i<sizeof(config.pattern); i++){
              config.pattern[i]=0;
            }
            config.setFrameHeight(bleStatus[2]);
            config.setFrameCount(bleStatus[3] << 8 | bleStatus[4]);
            config.patternLength = config.frameHeight*config.frameCount*3; // Need exception handling for buffer overruns!!!
            for (int i=0; i<config.patternLength; i++){
              config.pattern[i]=bleStatus[i+5];
            }
            config.savePattern();
            
            bleSendSuccess();
          }else if(requestCode == CC_SET_PATTERN_SLOT){
            config.setPatternSlot(bleStatus[2]%PATTERN_BANK_SIZE, true);
            config.displayState = DS_PATTERN;
            config.displayStateLastUpdated = millis();
            bleSendSuccess();
          }else if(requestCode == CC_SET_PATTERN_ALL){
            config.displayState = DS_PATTERN_ALL;
            config.displayStateLastUpdated = millis();
            bleSendSuccess();
          }else if(requestCode == CC_SET_BANK){
            config.setPatternBank(bleStatus[2]%PATTERN_BANK_COUNT, true);
            config.displayState = DS_PATTERN;
            config.displayStateLastUpdated = millis();
            bleSendSuccess();
          }else if(requestCode == CC_SET_BANK_ALL){
            config.displayState = DS_PATTERN_ALL_ALL;
            config.displayStateLastUpdated = millis();
            bleSendSuccess();
          }else if(requestCode == CC_GET_FW_VERSION){
            bleSendFWVersion();
          }else if(requestCode == CC_SET_HARDWARE_VERSION){
            config.setHardwareVersion(bleStatus[2]);
            bleSendSuccess();
          }else if(requestCode == CC_SET_LED_TYPE){
            config.setLedType(bleStatus[2]);
            bleSendSuccess();
          }else if(requestCode == CC_SET_LED_COUNT){
            config.setLedCount(bleStatus[2]);
            bleSendSuccess();
          }else if(requestCode == CC_SET_DEVICE_NAME){
            if(bleLength > 3 && bleLength <= 18){
              config.setDeviceName(String((char*)bleStatus).substring(2, bleLength -1) + " Pixel Poi");
              bleSendSuccess();
            }else{
              bleSendError();
            }
            
          }else{
            debugf("Recieved message with unknown code!\n");
            bleSendError();
          }
        }else{
          if(!flagMultipartPattern && bleStatus[0] == 0xD0 && static_cast<CommCode>(bleStatus[1]) == CC_SET_PATTERN){
            debugf("Start multipart pattern! %d bits\n", bleStatus[2] * (bleStatus[3] << 8 | bleStatus[4]));
            flagMultipartPattern = true;
            multipartPatternOffset = 0;
            for (int i=0; i<sizeof(config.pattern); i++){
              config.pattern[i]=0;
            }
            config.setFrameHeight(bleStatus[2]);
            config.setFrameCount(bleStatus[3] << 8 | bleStatus[4]);
            config.patternLength = config.frameHeight*config.frameCount*3;// Need exception handling for buffer overruns!!!
            if(config.patternLength > 24000){
              // set error pattern
              config.setFrameHeight(1);
              config.setFrameCount(2);
              config.patternLength = 6;
              config.fillDefaultPattern();
              config.savePattern();
              flagMultipartPattern = false;
              return;
            }
            
            for (int i=5; i < bleLength; i++){
              config.pattern[multipartPatternOffset] = bleStatus[i];
              multipartPatternOffset++;
            }
          }else if(flagMultipartPattern && bleLength < 509){
            debugf("End multipart message!\n");
            flagMultipartPattern = false;

            for (int i= 0; i < bleLength - 1; i++){
              config.pattern[multipartPatternOffset] = bleStatus[i];
              multipartPatternOffset++;
            }
            
            config.savePattern();
          }else if(flagMultipartPattern){
            debugf("Middle of multipart message! Offset = %d\n", multipartPatternOffset);
            for (int i= 0; i < bleLength; i++){
              config.pattern[multipartPatternOffset] = bleStatus[i];
              multipartPatternOffset++;
            }
          }
        }
      }
    }

    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      debugf("onConnect\n");
    }

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      debugf("onDisconnect\n");
    }

};

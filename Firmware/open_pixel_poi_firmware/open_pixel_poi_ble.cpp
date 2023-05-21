// Some things need to be included here, seems files are loaded alphabetically
#include <arduino.h>
#include <Update.h>
#include "open_pixel_poi_config.cpp"
#include "open_poi_patterns.cpp"

// BLE
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define DEBUG  // Comment this line out to remove printf statements in released version
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
  CC_SUCCESS,           // 0
  CC_ERROR,             // 1
  CC_SET_BRIGHTNESS,    // 2
  CC_SET_SPEED,         // 3
  CC_SET_PATTERN        // 4
};

class OpenPixelPoiBLE : public BLEServerCallbacks, public BLECharacteristicCallbacks{
  
  private:
    OpenPixelPoiConfig& config;
    OpenPixelPoiPatterns patterns;
    
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
      uint8_t response[] = {0x45, 0x46, 0x00, 0x07, CC_ERROR, 0x46, 0x45};
      writeToPixelPoi(response);
    }
    
    void bleSendSuccess(){
      uint8_t response[] = {0x45, 0x46, 0x00, 0x07, CC_SUCCESS, 0x46, 0x45};
      writeToPixelPoi(response);
    }

    void bleSendLolcat(){
      debugf("Send error lolcat\n");
      uint8_t response[] = {0x01, 0x02, 0x00, 0x05, 0x01};
      writeToPixelPoi(response);
    }
    
  public:
    OpenPixelPoiBLE(OpenPixelPoiConfig& _config): config(_config) {}

    long bleLastReceived;
    void setup(){
      debugf("Setup begin\n");
      // Create the BLE Device
      BLEDevice::init("Pixel Poi ESP32C3");

      // Create the BLE Server
      server = BLEDevice::createServer();
      server->setCallbacks(this);
      
      // Create the pixelPoi BLE Service
      pixelPoiService = server->createService(pixelPoiServiceUUID);
      pixelPoiTxCharacteristic = pixelPoiService->createCharacteristic(pixelPoiTxCharacteristicUUID, BLECharacteristic::PROPERTY_READ);
      pixelPoiTxCharacteristic->addDescriptor(new BLE2902());
      pixelPoiNotifyCharacteristic = pixelPoiService->createCharacteristic(pixelPoiNotifyCharacteristicUUID, BLECharacteristic::PROPERTY_NOTIFY);
      pixelPoiNotifyCharacteristic->addDescriptor(new BLE2902());
      pixelPoiRxCharacteristic = pixelPoiService->createCharacteristic(pixelPoiRxCharacteristicUUID, BLECharacteristic::PROPERTY_WRITE);
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
        pixelPoiTxCharacteristic->setValue(data, data[2] << 8 | data[3]);
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
        if(bleStatus[0] == 0x61 && bleStatus[1] == 0x73 && bleStatus[2] == 0x64 & bleStatus[3] == 0x66){
          debugf("Got ASDF!\n");
          debugf("patterns.Z_HEIGHT = %d\n", patterns.Z_HEIGHT);
          debugf("patterns.Z_COUNT = %d\n", patterns.Z_COUNT);
          config.setFrameHeight(patterns.Z_HEIGHT);
          config.setFrameCount(patterns.Z_COUNT);
          for(int i=0; i<patterns.Z_HEIGHT*patterns.Z_COUNT*3; i++){
            config.pattern[i] = 0;
          }
          for(int i=0; i<patterns.Z_COUNT; i++){
            for(int j=0; j<patterns.Z_HEIGHT; j++){
              debugf("i=%d, j=%d\n",i, j);
              config.pattern[((i*patterns.Z_HEIGHT)+j)*3]=0x0;
              config.pattern[((i*patterns.Z_HEIGHT)+j)*3+1]=0x0;
              if(patterns.BIG_Z[i][j]=='B'){
                config.pattern[((i*patterns.Z_HEIGHT)+j)*3+2]=0xff;
              } else {
                config.pattern[((i*patterns.Z_HEIGHT)+j)*3+2]=0x0;              
              }
            }
          }
          debugf("config.patternLength (before) = %d\n",config.patternLength);
          config.patternLength = patterns.Z_HEIGHT*patterns.Z_COUNT*3;
          debugf("config.patternLength (after) = %d\n",config.patternLength);
          debugf("patterns.Z_HEIGHT = %d\n", patterns.Z_HEIGHT);
          debugf("patterns.Z_COUNT = %d\n", patterns.Z_COUNT);
          debugf("fH*fC*3 = %d", patterns.Z_HEIGHT*patterns.Z_COUNT*3);
          config.savePattern();
        }else if (bleStatus[0] == 0x66 && bleStatus[1] == 0x64 && bleStatus[2] == 0x73 & bleStatus[3] == 0x61){
          debugf("Got FDSA!\n");
          debugf("patterns.COS_HEIGHT = %d\n", patterns.COS_HEIGHT);
          debugf("patterns.COS_COUNT = %d\n", patterns.COS_COUNT);
          config.setFrameHeight(patterns.COS_HEIGHT);
          config.setFrameCount(patterns.COS_COUNT);
          for(int i=0; i<patterns.COS_HEIGHT*patterns.COS_COUNT*3; i++){
            config.pattern[i] = 0;
          }
          for(int i=0; i<patterns.COS_COUNT; i++){
            for(int j=0; j<patterns.Z_HEIGHT; j++){
              debugf("i=%d, j=%d\n",i, j);
              config.pattern[((i*patterns.COS_HEIGHT)+j)*3]=0x0;
              config.pattern[((i*patterns.COS_HEIGHT)+j)*3+1]=0x0;

              if(patterns.COS_STRING[i][j]=='R'){
                config.pattern[((i*patterns.COS_HEIGHT)+j)*3]=0xFF;
                config.pattern[((i*patterns.COS_HEIGHT)+j)*3+1]=0x0;
                config.pattern[((i*patterns.COS_HEIGHT)+j)*3+2]=0x0;
              } else {
                config.pattern[((i*patterns.COS_HEIGHT)+j)*3]=0x80;
                config.pattern[((i*patterns.COS_HEIGHT)+j)*3+1]=0x0;
                config.pattern[((i*patterns.COS_HEIGHT)+j)*3+2]=0x80;              
              }
            }
          }
          debugf("config.patternLength (before) = %d\n",config.patternLength);
          config.patternLength = patterns.COS_HEIGHT*patterns.COS_COUNT*3;
          debugf("config.patternLength (after) = %d\n",config.patternLength);
          debugf("patterns->cosFrameHeight = %d\n", patterns.COS_HEIGHT);
          debugf("patterns->cosFrameCount = %d\n", patterns.COS_COUNT);
          debugf("fH*fC*3 = %d", patterns.COS_HEIGHT*patterns.COS_COUNT*3);
          config.savePattern();
        }else if(bleStatus[0] == 0xD0 && bleStatus[bleLength - 1] == 0xD1){
          CommCode requestCode = static_cast<CommCode>(bleStatus[1]);
          if(requestCode == CC_SET_BRIGHTNESS){
            config.setLedBrightness(bleStatus[2]);
            bleSendSuccess();
          }else if(requestCode == CC_SET_SPEED){
            config.setAnimationSpeed(bleStatus[2]);
            bleSendSuccess();
          }else if(requestCode == CC_SET_PATTERN){
            for (int i=0; i<sizeof(config.pattern); i++){
              config.pattern[i]=0;
            }
            config.setFrameHeight(bleStatus[2]);
            config.setFrameCount(bleStatus[3]);
            // Need exception handling for buffer overruns!!!
            config.patternLength = config.frameHeight*config.frameCount*3;
            for (int i=0; i<config.patternLength; i++){
              config.pattern[i]=bleStatus[i+4];
            }
            config.savePattern();
            
            bleSendSuccess();
          }
          else{
            bleSendError();
          }
        }else{
          bleSendLolcat();
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

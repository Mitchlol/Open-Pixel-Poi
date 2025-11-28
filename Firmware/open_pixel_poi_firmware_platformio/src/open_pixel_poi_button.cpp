#ifndef _OPEN_PIXEL_POI_BUTTON
#define _OPEN_PIXEL_POI_BUTTON

#include "open_pixel_poi_config.cpp"
#include <driver/rtc_io.h>
#include <driver/gpio.h>
#include "esp_sleep.h"

//#define DEBUG  // Comment this line out to remove printf statements in released version
#ifdef DEBUG
#define debugf(...) Serial.print("<<button>> ");Serial.printf(__VA_ARGS__);
#define debugf_noprefix(...) Serial.printf(__VA_ARGS__);
#else
#define debugf(...)
#define debugf_noprefix(...)
#endif

enum ButtonState {
  BS_INITIAL,
  BS_CLICK_DOWN,
  BS_CLICK_HOLD,
  BS_CLICK_HOLD_LONG,
  BS_CLICK_UP,
  BS_CLICK2_DOWN,
  BS_CLICK2_HOLD,
  BS_CLICK2_UP,
  BS_CLICK3_DOWN,
  BS_CLICK3_HOLD,
  BS_CLICK3_UP,
  BS_CLICK4_DOWN,
  BS_CLICK4_HOLD,
  BS_CLICK4_UP,
  BS_CLICK5_DOWN,
  BS_CLICK5_HOLD,
  BS_CLICK5_UP
};

class OpenPixelPoiButton {

private:
  OpenPixelPoiConfig& config;

  int filteredButtonInput = 1000;
  int buttonState = 0;
  long downTime = 0;
  bool regulatorEnabled = true;

  long shutDownAt = 0;

public:
  OpenPixelPoiButton(OpenPixelPoiConfig& _config): config(_config) {}    

  void setup() {
    // Voltage Input
    pinMode(A0, INPUT);

    //Button Input
    pinMode(3,INPUT_PULLUP);

    // Regulator Output
    pinMode(D7, OUTPUT);
    regulatorEnabled = true;
    digitalWrite(D7, HIGH);

  }

  void loop() {
    filteredButtonInput = (filteredButtonInput * 0.92) + (analogRead(3) * .08);
    if(filteredButtonInput < 100){
      if(buttonState == BS_INITIAL){ // Single Click
        downTime = millis();
        buttonState = BS_CLICK_DOWN;
        // Trigger Waiting Animation
        config.displayState = DS_WAITING;
        config.displayStateLastUpdated = millis();
      }else if(buttonState == BS_CLICK_UP){ // Double Click
        downTime = millis();
        buttonState = BS_CLICK2_DOWN;
        // Trigger Waiting Animation
        config.displayState = DS_WAITING2;
        config.displayStateLastUpdated = millis();
      }else if(buttonState == BS_CLICK2_UP){ // Triple Click
        downTime = millis();
        buttonState = BS_CLICK3_DOWN;
        // Trigger Waiting Animation
        config.displayState = DS_WAITING3;
        config.displayStateLastUpdated = millis();
      }else if(buttonState == BS_CLICK3_UP){ // Quad Click
        downTime = millis();
        buttonState = BS_CLICK4_DOWN;
        // Trigger Waiting Animation
        config.displayState = DS_WAITING4;
        config.displayStateLastUpdated = millis();
      }else if(buttonState == BS_CLICK4_UP){ // Penta Click
        downTime = millis();
        buttonState = BS_CLICK5_DOWN;
        // Trigger Waiting Animation
        config.displayState = DS_WAITING5;
        config.displayStateLastUpdated = millis();
      }else if(buttonState == BS_CLICK_DOWN && millis() - downTime >= 500){ // Click Hold
        buttonState = BS_CLICK_HOLD;
        // Trigger voltage display
        config.displayState = DS_VOLTAGE;
        config.displayStateLastUpdated = millis();
      }else if(buttonState == BS_CLICK_HOLD && millis() - downTime >= 2000){ // Click Long Hold
        buttonState = BS_CLICK_HOLD_LONG;
        config.displayState = DS_SHUTDOWN;
        config.displayStateLastUpdated = millis();
        shutDownAt = millis();
      }else if(buttonState == BS_CLICK2_DOWN && millis() - downTime >= 500){ // Click2 Hold
        buttonState = BS_CLICK2_HOLD;
        // Trigger bank display
        config.displayState = DS_BANK;
        config.displayStateLastUpdated = millis();
      }else if(buttonState == BS_CLICK3_DOWN && millis() - downTime >= 500){ // Click3 Hold
        buttonState = BS_CLICK3_HOLD;
        // Trigger voltage display
        config.displayState = DS_BRIGHTNESS;
        config.displayStateLastUpdated = millis();
      }else if(buttonState == BS_CLICK4_DOWN && millis() - downTime >= 500){ // Click4 Hold
        buttonState = BS_CLICK4_HOLD;
        // Trigger speed display
        config.displayState = DS_SPEED;
        config.displayStateLastUpdated = millis();
      }else if(buttonState == BS_CLICK5_DOWN && millis() - downTime >= 500){ // Click5 Hold
        buttonState = BS_CLICK5_HOLD;
        // Do Nothing (display pattern)
        config.displayState = DS_PATTERN;
        config.displayStateLastUpdated = millis();
      }
    }else{
      if(buttonState == BS_CLICK_DOWN){
        buttonState = BS_CLICK_UP;
      }else if(buttonState == BS_CLICK2_DOWN){
        buttonState = BS_CLICK2_UP;
      }else if(buttonState == BS_CLICK3_DOWN){
        buttonState = BS_CLICK3_UP;
      }else if(buttonState == BS_CLICK4_DOWN){
        buttonState = BS_CLICK4_UP;
      }else if(buttonState == BS_CLICK5_DOWN){
        buttonState = BS_CLICK5_UP;
      }else if(buttonState == BS_CLICK_HOLD){
        buttonState = BS_INITIAL;
        config.displayState = DS_PATTERN;
        config.displayStateLastUpdated = millis();
      }else if(buttonState == BS_CLICK2_HOLD){
        if(millis() - downTime < 1000){
          config.setPatternBank(0, true);
          config.displayState = DS_PATTERN;
          config.displayStateLastUpdated = millis();
        }else if(millis() - downTime < 1500){
          config.setPatternBank(1, true);
          config.displayState = DS_PATTERN;
          config.displayStateLastUpdated = millis();
        }else if(millis() - downTime < 2000){
          config.setPatternBank(2, true);
          config.displayState = DS_PATTERN;
          config.displayStateLastUpdated = millis();
        }else if(millis() - downTime < 2500){
          config.displayState = DS_PATTERN_ALL_ALL;
          config.displayStateLastUpdated = millis();
        }else if(millis() - downTime < 3000){
          config.setPatternBank(0, true);
          config.displayState = DS_PATTERN_ALL;
          config.displayStateLastUpdated = millis();
        }else if(millis() - downTime < 3500){
          config.setPatternBank(1, true);
          config.displayState = DS_PATTERN_ALL;
          config.displayStateLastUpdated = millis();
        }else{
          config.setPatternBank(2, true);
          config.displayState = DS_PATTERN_ALL;
          config.displayStateLastUpdated = millis();
        }
        buttonState = BS_INITIAL;
      }else if(buttonState == BS_CLICK3_HOLD){
        if(millis() - downTime < 1000){
          config.setLedBrightness(1);
        }else if(millis() - downTime < 1500){
          config.setLedBrightness(4);
        }else if(millis() - downTime < 2000){
          config.setLedBrightness(10);
        }else if(millis() - downTime < 2500){
          config.setLedBrightness(25);
        }else{
          config.setLedBrightness(100);
        }
        buttonState = BS_INITIAL;
        config.displayState = DS_PATTERN;
        config.displayStateLastUpdated = millis();
      }else if(buttonState == BS_CLICK4_HOLD){
        if(millis() - downTime < 1000){
          config.setAnimationSpeed(1);
        }else if(millis() - downTime < 1500){
          config.setAnimationSpeed(2);
        }else if(millis() - downTime < 2000){
          config.setAnimationSpeed(5);
        }else if(millis() - downTime < 2500){
          config.setAnimationSpeed(10);
        }else if(millis() - downTime < 3000){
          config.setAnimationSpeed(25);
        }else if(millis() - downTime < 3500){
          config.setAnimationSpeed(50);
        }else if(millis() - downTime < 4000){
          config.setAnimationSpeed(100);
        }else if(millis() - downTime < 4500){
          config.setAnimationSpeed(200);
        }else if(millis() - downTime < 5000){
          config.setAnimationSpeed(400);
        }else if(millis() - downTime < 5500){
          config.setAnimationSpeed(600);
        }else{
          config.setAnimationSpeed(800);
        }
        buttonState = BS_INITIAL;
        config.displayState = DS_PATTERN;
        config.displayStateLastUpdated = millis();
      }else if(buttonState == BS_CLICK5_HOLD){
        buttonState = BS_INITIAL;
      }
    }

    // Single press detected after timeout, increment pattern
    if(buttonState == BS_CLICK_UP && millis() - downTime >= 500){
      config.setPatternSlot((config.patternSlot + 1) % PATTERN_BANK_SIZE, true);
      config.displayState = DS_PATTERN;
      config.displayStateLastUpdated = millis();
      buttonState = BS_INITIAL;
    }
    // Double press detected after timeout, do nothing
    if(buttonState == BS_CLICK2_UP && millis() - downTime >= 500){
      config.displayState = DS_PATTERN;
      config.displayStateLastUpdated = millis();
      buttonState = BS_INITIAL;
    }
    // Tripple press detected after timeout, do nothing
    if(buttonState == BS_CLICK3_UP && millis() - downTime >= 500){
      config.displayState = DS_PATTERN;
      config.displayStateLastUpdated = millis();
      buttonState = BS_INITIAL;
    }
    // Quad press detected after timeout, do nothing
    if(buttonState == BS_CLICK4_UP && millis() - downTime >= 500){
      config.displayState = DS_PATTERN;
      config.displayStateLastUpdated = millis();
      buttonState = BS_INITIAL;
    }
    // Penta press detected after timeout, display voltage
    if(buttonState == BS_CLICK5_UP && millis() - downTime >= 500){
      config.displayState = DS_VOLTAGE2;
      config.displayStateLastUpdated = millis();
      buttonState = BS_INITIAL;
    }

    // Read battery voltage
    if(BATTERY_VOLTAGE_SENSOR){
      config.batteryVoltage = (config.batteryVoltage * 0.999) + ((analogReadMilliVolts(A0)/500.0) * .001);
    }else{
      config.batteryVoltage = 4.2;
    }

    

    // Super low voltage, emergency shutdown (uses data from previous read, this is ok). 
    if (config.batteryState == BAT_SHUTDOWN && config.displayState != DS_SHUTDOWN){
      config.displayState = DS_SHUTDOWN;
      config.displayStateLastUpdated = millis();
      shutDownAt = millis();
    }

    // do a shutdown if flaged
    if(shutDownAt != 0 && millis() - shutDownAt > 2000){
      // Regulator Shutdown
      digitalWrite(D7, LOW);
      delay(500);
      
      //hold disable, isolate and power domain config functions may be unnecessary
      //gpio_deep_sleep_hold_dis();
      //esp_sleep_config_gpio_isolate();
      //esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_PERIPH, ESP_PD_OPTION_ON);

      // ESP32 Shutdown sequence
      gpio_set_direction(gpio_num_t(3), GPIO_MODE_INPUT);
      esp_deep_sleep_enable_gpio_wakeup(0b001000, ESP_GPIO_WAKEUP_GPIO_LOW);
      esp_deep_sleep_start();
    }

  }

};

#endif

#include "ILedStrip.h"
#include <Arduino.h>

uint8_t ILedStrip::CalculateLuminance(uint8_t brightnessSetting, uint8_t ledCount, double consumption, int outputLimit){
    if(brightnessSetting <= 1){
        return brightnessSetting;
    }
    double consumptionScale = min(1.0, OUTPUT_PCB_CURRENT_LIMIT/(consumption * ledCount * OUTPUT_CHANNELS));
    int calculatedLuminance = (int)ceil(brightnessSetting * 2.55 * consumptionScale);
    return min(outputLimit, calculatedLuminance);
}

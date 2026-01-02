#ifndef _I_LED_STRIP_H
#define _I_LED_STRIP_H

#include <NeoPixelBusLg.h>
#include <config.h>

class ILedStrip {
public:
    virtual ~ILedStrip() = default;

    virtual void Begin() = 0;
    virtual void Show() = 0;
    virtual void SetPixelColor(uint16_t i, RgbColor color) = 0;
    virtual void ClearTo(RgbColor color) = 0;
    virtual void SetBrightness(uint8_t luminance) = 0;
    virtual uint8_t GetLuminance() = 0;
    uint8_t CalculateLuminance(uint8_t brightnessSetting, uint8_t ledCount, double consumption, int outputLimit);
};

#endif

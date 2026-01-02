#ifndef _NEO_PIXEL_STRIP_H
#define _NEO_PIXEL_STRIP_H

#include "ILedStrip.h"

class NeoPixelStrip : public ILedStrip {
public:

    NeoPixelStrip(uint16_t count, uint8_t dataPin);

    void Begin() override;
    void Show() override;
    void SetPixelColor(uint16_t i, RgbColor color) override;
    void ClearTo(RgbColor color) override;
    void SetBrightness(uint8_t i) override;
    uint8_t GetLuminance() override;
private:
    NeoPixelBusLg<NeoGrbFeature, NeoWs2812xMethod, NeoGammaNullMethod> strip;
};

#endif

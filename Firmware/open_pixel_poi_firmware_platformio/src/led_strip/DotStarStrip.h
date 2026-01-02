#ifndef DOT_STAR_STRIP_H
#define DOT_STAR_STRIP_H

#include "ILedStrip.h"

class DotStarStrip : public ILedStrip {
public:
    DotStarStrip(uint16_t count, int8_t dataPin, int8_t clockPin);

    void Begin() override;
    void Show() override;
    void SetPixelColor(uint16_t i, RgbColor color) override;
    void ClearTo(RgbColor color) override;
    void SetBrightness(uint8_t i) override;
    uint8_t GetLuminance() override;

private:
    uint8_t dataPin_;
    uint8_t clockPin_;
    NeoPixelBusLg<DotStarBgrFeature, DotStarSpi20MhzMethod, NeoGammaNullMethod> strip;
};

#endif

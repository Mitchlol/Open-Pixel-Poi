#ifndef _NO_STRIP_H
#define _NO_STRIP_H

#include "ILedStrip.h"

class NoStrip : public ILedStrip {
public:
    NoStrip();

    void Begin() override;
    void Show() override;
    void SetPixelColor(uint16_t i, RgbColor color) override;
    void ClearTo(RgbColor color) override;
    void SetBrightness(uint8_t i) override;
    uint8_t GetLuminance() override;
};

#endif

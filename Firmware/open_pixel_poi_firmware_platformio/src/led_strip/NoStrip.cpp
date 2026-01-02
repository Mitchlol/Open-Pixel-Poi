#include "NoStrip.h"

NoStrip::NoStrip() {}

void NoStrip::Begin() {}
void NoStrip::Show() {}
void NoStrip::SetPixelColor(uint16_t i, RgbColor color) {}
void NoStrip::ClearTo(RgbColor color) {}
void NoStrip::SetBrightness(uint8_t i) {}
uint8_t NoStrip::GetLuminance() {
    return 0;
}

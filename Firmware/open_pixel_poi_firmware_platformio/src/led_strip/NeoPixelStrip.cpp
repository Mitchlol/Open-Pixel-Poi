#include "NeoPixelStrip.h"
NeoPixelStrip::NeoPixelStrip(uint16_t count, uint8_t dataPin) : strip(count, dataPin) {}

void NeoPixelStrip::Begin() { strip.Begin(); }
void NeoPixelStrip::Show() { strip.Show(); }
void NeoPixelStrip::SetPixelColor(uint16_t i, RgbColor color) { strip.SetPixelColor(i, color); }
void NeoPixelStrip::ClearTo(RgbColor color) { strip.ClearTo(color); }
void NeoPixelStrip::SetBrightness(uint8_t i) { 
    strip.SetLuminance(
        CalculateLuminance(i, strip.PixelCount(), OUTPUT_WS2812B_5050_DRAW, OUTPUT_WS2812B_5050_LIMIT)
    ); 
}
uint8_t NeoPixelStrip::GetLuminance() { return strip.GetLuminance(); }

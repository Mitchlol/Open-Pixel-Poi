#include "DotStarStrip.h"


DotStarStrip::DotStarStrip(uint16_t count, int8_t dataPin, int8_t clockPin) : 
    strip(count, clockPin, dataPin),
    dataPin_(dataPin),
    clockPin_(clockPin) {}
void DotStarStrip::Begin() { 
    strip.Begin(clockPin_, -1, dataPin_, -1); 
}
void DotStarStrip::Show() { strip.Show(); }
void DotStarStrip::SetPixelColor(uint16_t i, RgbColor color) { strip.SetPixelColor(i, color); }
void DotStarStrip::ClearTo(RgbColor color) { strip.ClearTo(color); }
void DotStarStrip::SetBrightness(uint8_t i) { 
    strip.SetLuminance(
        CalculateLuminance(i, strip.PixelCount(), OUTPUT_SK9822_2020_DRAW, OUTPUT_SK9822_2020_LIMIT)
    );
}
uint8_t DotStarStrip::GetLuminance() { return strip.GetLuminance(); }

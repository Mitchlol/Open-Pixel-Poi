#ifndef _OPEN_PIXEL_POI_PATTERNS
#define _OPEN_PIXEL_POI_PATTERNS

#define DEBUG  // Comment this line out to remove printf statements in released version
#ifdef DEBUG
#define debugf(...) Serial.print("<<patterns>> ");Serial.printf(__VA_ARGS__);
#define debugf_noprefix(...) Serial.printf(__VA_ARGS__);
#else
#define debugf(...)
#define debugf_noprefix(...)
#endif

class OpenPixelPoiPatterns {

// This class will handle the creation of complex patterns using syntax similar to game dev level creation.
// The pattern will be a character array where each character represents a color.

// Right now this logic is in the open_pixel_poi_ble class.
// In the future, this logic may be handled by a Flutter app which uses images or character arrays to create and transmit patterns.
// This class would be an intermediate step to clean up the firmware before the Flutter app is ready.

// R = 0xff 0x00 0x00     // Red
// G = 0x00 0xff 0x00     // Green
// B = 0x00 0x00 0xff     // Blue
// b = 0x00 0x00 0x80     // Navy
// F = 0xff 0x00 0xff     // Fuschia
// P = 0x80 0x00 0x80     // Purple
// . = 0x00 0x00 0x00     // Black
// W = 0xFF 0xFF 0xFF     // White
// O = 0xFF 0x8C 0x00     // Orange
// G = 0xC0 0xC0 0xC0     // Light Grey
// g = 0x80 0x80 0x80     // Dark Grey
// C = 0x00 0xFF 0xFF     // Cyan
// t = 0x00 0x80 0x80     // Teal
                                        // 10, 9, 7, 4, 0, -4, -7, -9, -10, -10, -9, -7, -4, 0, 4, 7, 9, 10
// Pattern #1
// sin red/purple
// cos[360] = {  20, 18 grid       |
//    R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R,   // 0 = All Red    +10
//    R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, P,   //                +09
//    R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, P, P, P,   //                +07
//    R, R, R, R, R, R, R, R, R, R, R, R, R, R, P, P, P, P, P, P,   //                +04
//    R, R, R, R, R, R, R, R, R, R, P, P, P, P, P, P, P, P, P, P,   //                 00
//    R, R, R, R, R, R, P, P, P, P, P, P, P, P, P, P, P, P, P, P,   //                -04
//    R, R, R, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P,   //                -07
//    R, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P,   //                -09
//    P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P,   //                -10
//    P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P,   //                -10
//    R, P, P, P, P, P, p, P, P, P, P, P, P, P, P, P, P, P, P, P,   //                -09
//    R, R, R, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P, P,   //                -07
//    R, R, R, R, R, R, P, P, P, P, P, P, P, P, P, P, P, P, P, P,   //                -04
//    R, R, R, R, R, R, R, R, R, R, P, P, P, P, P, P, P, P, P, P,   //                 00
//    R, R, R, R, R, R, R, R, R, R, R, R, R, R, P, P, P, P, P, P,   //                +04
//    R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, P, P, P,   //                +07
//    R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, P,   //                +09
//    R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R, R,   // 0 = All Red    +10
//}

private:

public:

  void setup() {}

  void loop() {}

};

#endif

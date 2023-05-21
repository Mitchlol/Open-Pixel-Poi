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
//};

private:

public:

  // Red/Purple Cosine function
  const int COS_HEIGHT = 20;
  const int COS_COUNT = 18;
  const char COS_STRING[18][21] = {
    "RRRRRRRRRRRRRRRRRRRR",   // 0 = All Red    +10
    "RRRRRRRRRRRRRRRRRRRP",   //                +09
    "RRRRRRRRRRRRRRRRRPPP",   //                +07
    "RRRRRRRRRRRRRRPPPPPP",   //                +04
    "RRRRRRRRRRPPPPPPPPPP",   //                 00
    "RRRRRRPPPPPPPPPPPPPP",   //                -04
    "RRRPPPPPPPPPPPPPPPPP",   //                -07
    "RPPPPPPPPPPPPPPPPPPP",   //                -09
    "PPPPPPPPPPPPPPPPPPPP",   //                -10
    "PPPPPPPPPPPPPPPPPPPP",   //                -10
    "RPPPPPPPPPPPPPPPPPPP",   //                -09
    "RRRPPPPPPPPPPPPPPPPP",   //                -07
    "RRRRRRPPPPPPPPPPPPPP",   //                -04
    "RRRRRRRRRRPPPPPPPPPP",   //                 00
    "RRRRRRRRRRRRRRPPPPPP",   //                +04
    "RRRRRRRRRRRRRRRRRPPP",   //                +07
    "RRRRRRRRRRRRRRRRRRRP",   //                +09
    "RRRRRRRRRRRRRRRRRRRR"    // 0 = All Red    +10
  };

  // Blue "Z"
  const int Z_HEIGHT = 20;
  const int Z_COUNT = 20;
  const char BIG_Z[20][21] = {
    "B.................BB",
    "B................B.B",
    "B...............B..B",
    "B..............B...B",
    "B.............B....B",
    "B............B.....B",
    "B...........B......B",
    "B..........B.......B",
    "B.........B........B",
    "B........B.........B",
    "B.......B..........B",
    "B......B...........B",
    "B.....B............B",
    "B....B.............B",
    "B...B..............B",
    "B..B...............B",
    "B.B................B",
    "BB.................B",
    "....................",
    "...................."
  };

  void setup() {}

  void loop() {}

};


    // int cosFrameHeight = 20;
    // int cosFrameCount = 18;
    // char cos_grid[360] = {                                           // 20, 18 grid       |
    //   'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   // 0 = All Red    +10
    //   'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P',   //                +09
    //   'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P',   //                +07
    //   'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P',   //                +04
    //   'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                 00
    //   'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                -04
    //   'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                -07
    //   'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                -09
    //   'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                -10
    //   'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                -10
    //   'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                -09
    //   'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                -07
    //   'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                -04
    //   'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                 00
    //   'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P',   //                +04
    //   'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P',   //                +07
    //   'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P',   //                +09
    //   'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   // 0 = All Red    +10
    // };


//    int cosFrameHeight = 20;
//    int cosFrameCount = 31;
//    char big_cos_grid[620] = {                        ||
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                 00
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                +02
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P',   //                +04
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P', 'P',   //                +06
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P',   //                +07      5
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P',   //                +08
//      'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                +09
//      'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                +10
//      'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                +10
//      'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                +09     10
//      'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                +08
//      'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                -07
//      'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                -05
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',   //                 03
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P', 'P', 'P', 'P',   //                +01     15
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P', 'P', 'P',   //                -01
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'P',   //                -03
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   //                -04
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   //                -06
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   //                -08     20
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   //                -09
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   //                -09
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   //                -10
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   //                -10
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   //                -10     25
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   //                -09
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   //                -08
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   //                -06
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   //                -05
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   //                -03     30
//      'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',   //                  0
//    };
//



#endif

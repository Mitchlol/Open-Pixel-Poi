#ifndef _OPEN_PIXEL_POI_PATTERNS
#define _OPEN_PIXEL_POI_PATTERNS

#include "open_pixel_poi_config.cpp"

#define DEBUG  // Comment this line out to remove printf statements in released version
#ifdef DEBUG
#define debugf(...) Serial.print("  <<patterns>> ");Serial.printf(__VA_ARGS__);
#define debugf_noprefix(...) Serial.printf(__VA_ARGS__);
#else
#define debugf(...)
#define debugf_noprefix(...)
#endif

class OpenPixelPoiPatterns {

// This class handles the creation of complex patterns using syntax similar to game dev level creation.
// The pattern will be a character array where each character represents a color.

// In the future, this logic may be handled by a Flutter app which uses images or character arrays to create and transmit patterns.
// This class is an intermediate step to clean up the firmware before the Flutter app is ready.

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

private:
  OpenPixelPoiConfig& config;

public:
  OpenPixelPoiPatterns(OpenPixelPoiConfig& _config): config(_config) {}    

  template<int H, int C>
  void loadPattern(int height, int count, char (&pattern)[H][C]) {
    config.frameHeight = height;
    config.frameCount = count;

    debugf("height = %d\n", height);
    debugf("count = %d\n", count);
    config.setFrameHeight(height);
    config.setFrameCount(count);
    for(int i=0; i<height*count*3; i++){
      config.pattern[i] = 0;
    }
    for(int i=0; i<count; i++){
      for(int j=0; j<height; j++){
        // debugf("i=%d, j=%d\n",i, j);
        config.pattern[((i*height)+j)*3]=0x0;
        config.pattern[((i*height)+j)*3+1]=0x0;
        if(this->BIG_Z[i][j]=='B'){ // replace this with param, pattern
          config.pattern[((i*height)+j)*3+2]=0xff;
        } else {
          config.pattern[((i*height)+j)*3+2]=0x0;              
        }
      }
    }
    debugf("config.patternLength (before) = %d\n",config.patternLength);
    config.patternLength = height*count*3;
    debugf("config.patternLength (after) = %d\n",config.patternLength);
    debugf("config.frameHeight = %d\n", config.frameHeight);
    debugf("config.frameCount = %d\n", config.frameCount );
    debugf("fH*fC*3 = %d", config.frameHeight*config.frameCount*3);
    config.savePattern();

  }
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
  char BIG_Z[20][21] = {
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
};

#endif

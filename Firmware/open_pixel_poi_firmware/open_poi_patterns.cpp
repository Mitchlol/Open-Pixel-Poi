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

private:
  OpenPixelPoiConfig& config;

public:
  OpenPixelPoiPatterns(OpenPixelPoiConfig& _config): config(_config) {}    

  void updatePattern(int index, uint8_t R, uint8_t G, uint8_t B) {
    config.pattern[index] = R;
    config.pattern[index+1] = G;
    config.pattern[index+2] = B;
  }

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
        int index = (i*height+j)*3;
        uint8_t value;

        switch(pattern[i][j]) {
          case 'R':   // Red
            updatePattern(index, 0xff, 0x0, 0x00);
            break;
          case 'G':   // Green
            updatePattern(index, 0x0, 0xff, 0x00);
            break;
          case 'B':   // Blue
            updatePattern(index, 0x0, 0x0, 0xff);
            break;
          case 'b':   // Navy
            updatePattern(index, 0x0, 0x0, 0x80);
            break;
          case 'F':   // Fuschia
            updatePattern(index, 0xff, 0x0, 0xff);
            break;
          case 'P':   // Purple
            updatePattern(index, 0x80, 0x0, 0x80);
            break;
          case '.':   // Black
            updatePattern(index, 0x0, 0x0, 0x0);
            break;
          case 'W':   // White
            updatePattern(index, 0xff, 0xff, 0xff);
            break;
          case 'O':   // Orange
            updatePattern(index, 0xff, 0x8c, 0x0);
            break;
          case ';':   // Light Grey
            updatePattern(index, 0xc0, 0xc0, 0xc0);
            break;
          case ',':   // Dark Grey
            updatePattern(index, 0x80, 0x80, 0x80);
            break;
          case 'C':   // Cyan
            updatePattern(index, 0x0, 0xff, 0xff);
            break;
          case 't':   // Teal
            updatePattern(index, 0xff, 0xff, 0xff);
            break;
          case '*':   // Full Random
            updatePattern(index, random(256), random(256), random(256));
            break;
          case '#':   // Random White/Grey
            value = random(256);
            updatePattern(index, value, value, value);
            break;
          default:    // Black
            updatePattern(index, 0x0, 0x0, 0x0);
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
  char COS_STRING[18][21] = {
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

  // Full random (10 frames)
  const int FULL_RANDOM_HEIGHT = 20;
  const int FULL_RANDOM_COUNT = 10;
  char FULL_RANDOM[10][21] = {
    "********************",
    "********************",
    "********************",
    "********************",
    "********************",
    "********************",
    "********************",
    "********************",
    "********************",
    "********************"
  };

  // Grey random (10 frames)
  const int GREY_RANDOM_HEIGHT = 20;
  const int GREY_RANDOM_COUNT = 10;
  char GREY_RANDOM[10][21] = {
    "####################",
    "####################",
    "####################",
    "####################",
    "####################",
    "####################",
    "####################",
    "####################",
    "####################",
    "####################"
  };
};

#endif

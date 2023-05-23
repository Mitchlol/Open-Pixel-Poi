

import 'package:open_pixel_poi/hardware/models/rgb_value.dart';

import '../parse_util.dart';

class LEDPattern{
  int columnHeight = 0;
  int columnCount = 0;
  List<RGBValue> leds = List.empty(growable: true);

  LEDPattern.blank(){
    for(int i = 0; i < 128; i++){
      leds.add(RGBValue([0, 0, 0]));
    }
  }

  LEDPattern(this.columnHeight, this.columnCount, this.leds);
}

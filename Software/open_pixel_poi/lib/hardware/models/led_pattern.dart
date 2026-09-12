

import 'package:open_pixel_poi/hardware/models/rgb_value.dart';

import '../parse_util.dart';

class LedPattern{
  int columnHeight = 0;
  int columnCount = 0;
  List<RgbValue> leds = List.empty(growable: true);

  LedPattern.blank(){
    for(int i = 0; i < 128; i++){
      leds.add(RgbValue([0, 0, 0]));
    }
  }

  LedPattern(this.columnHeight, this.columnCount, this.leds);
}

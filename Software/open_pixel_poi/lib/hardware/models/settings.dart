import 'dart:ui';

import '../parse_util.dart';

class Settings {
  int brightness = 0;
  int speed = 0;

  Settings(List<int> data){
    brightness = ParseUtil.takeInt8(data);
    speed = ParseUtil.takeInt8(data);
  }

}

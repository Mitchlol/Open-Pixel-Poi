import 'dart:ui';

import '../parse_util.dart';


class RGBValue{
  int red = 0, green = 0, blue = 0;

  RGBValue(List<int> data){
    red = ParseUtil.takeInt8(data);
    green = ParseUtil.takeInt8(data);
    blue = ParseUtil.takeInt8(data);
  }

  Color getColor(){
    return Color.fromARGB(255, red, green, blue);
  }

  List<int> serialize(){
    List<int> serialized = List<int>.empty(growable: true);
    ParseUtil.putInt8(serialized, red);
    ParseUtil.putInt8(serialized, green);
    ParseUtil.putInt8(serialized, blue);
    return serialized;
  }

}
import 'package:open_pixel_poi/hardware/poi_hardware_state.dart';
import 'package:open_pixel_poi/database/patterndb.dart';
import 'hardware/poi_hardware.dart';

class Model {
  List<PoiHardware>? connectedPoi;
  PoiHardwareState hardwareState = PoiHardwareState();
  PatternDB patternDB = PatternDB();
}

import '../parse_util.dart';
import 'poi_response.dart';

enum BatteryState { ok, low, critical, shutdown }

class BatteryStatus extends PoiResponse {
  final bool sensorPresent;
  final int millivolts;
  final BatteryState state;

  BatteryStatus(this.sensorPresent, this.millivolts, this.state);

  factory BatteryStatus.fromMessage(List<int> message) {
    bool sensorPresent = ParseUtil.takeBoolean(message);
    int millivolts = ParseUtil.takeInt16(message);
    int stateIndex = ParseUtil.takeInt8(message);
    BatteryState state = stateIndex < BatteryState.values.length ? BatteryState.values[stateIndex] : BatteryState.ok;
    return BatteryStatus(sensorPresent, millivolts, state);
  }

  double get voltage => millivolts / 1000;

  int get percent => percentFromVoltage(voltage);

  // Approximate resting voltage curve of a single lithium ion cell, with the
  // bottom pinned to the voltage where the firmware shuts the poi down.
  static const List<(double, int)> dischargeCurve = [
    (4.20, 100),
    (4.06, 90),
    (3.98, 80),
    (3.92, 70),
    (3.87, 60),
    (3.82, 50),
    (3.79, 40),
    (3.77, 30),
    (3.74, 20),
    (3.68, 10),
    (3.45, 5),
    (3.25, 0),
  ];

  static int percentFromVoltage(double voltage) {
    if (voltage >= dischargeCurve.first.$1) {
      return dischargeCurve.first.$2;
    }
    if (voltage <= dischargeCurve.last.$1) {
      return dischargeCurve.last.$2;
    }
    for (var i = 0; i < dischargeCurve.length - 1; i++) {
      var (highVoltage, highPercent) = dischargeCurve[i];
      var (lowVoltage, lowPercent) = dischargeCurve[i + 1];
      if (voltage >= lowVoltage) {
        double fraction = (voltage - lowVoltage) / (highVoltage - lowVoltage);
        return (lowPercent + fraction * (highPercent - lowPercent)).round();
      }
    }
    return dischargeCurve.last.$2;
  }
}

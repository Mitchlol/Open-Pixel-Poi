import 'package:flutter_test/flutter_test.dart';
import 'package:open_pixel_poi/hardware/models/battery_status.dart';

void main() {
  group('BatteryStatus.fromMessage', () {
    test('parses sensor flag, millivolts and state', () {
      final status = BatteryStatus.fromMessage([1, 0x0F, 0xA0, 1]);

      expect(status.sensorPresent, isTrue);
      expect(status.millivolts, 4000);
      expect(status.voltage, 4.0);
      expect(status.state, BatteryState.low);
    });

    test('falls back to ok for unknown states', () {
      final status = BatteryStatus.fromMessage([0, 0x10, 0x68, 9]);

      expect(status.sensorPresent, isFalse);
      expect(status.millivolts, 4200);
      expect(status.state, BatteryState.ok);
    });
  });

  group('BatteryStatus.percentFromVoltage', () {
    test('clamps to the ends of the curve', () {
      expect(BatteryStatus.percentFromVoltage(4.5), 100);
      expect(BatteryStatus.percentFromVoltage(4.2), 100);
      expect(BatteryStatus.percentFromVoltage(3.25), 0);
      expect(BatteryStatus.percentFromVoltage(3.0), 0);
    });

    test('returns the curve points exactly', () {
      for (final (voltage, percent) in BatteryStatus.dischargeCurve) {
        expect(BatteryStatus.percentFromVoltage(voltage), percent);
      }
    });

    test('interpolates between curve points', () {
      expect(BatteryStatus.percentFromVoltage(3.845), 55);
      expect(BatteryStatus.percentFromVoltage(3.35), 3);
    });

    test('never decreases as voltage rises', () {
      int previous = 0;
      for (var millivolts = 3000; millivolts <= 4300; millivolts += 10) {
        final percent = BatteryStatus.percentFromVoltage(millivolts / 1000);
        expect(percent, greaterThanOrEqualTo(previous));
        previous = percent;
      }
    });
  });
}

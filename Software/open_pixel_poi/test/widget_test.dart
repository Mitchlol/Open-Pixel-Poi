import 'package:flutter_test/flutter_test.dart';
import 'package:open_pixel_poi/hardware/parse_util.dart';

void main() {
  group('ParseUtil', () {
    test('round-trips 8-bit integers', () {
      final buffer = <int>[];
      ParseUtil.putInt8(buffer, 42);
      expect(ParseUtil.takeInt8(buffer), 42);
      expect(buffer, isEmpty);
    });

    test('round-trips 16-bit integers', () {
      final buffer = <int>[];
      ParseUtil.putInt16(buffer, 0xABCD);
      expect(ParseUtil.takeInt16(buffer), 0xABCD);
      expect(buffer, isEmpty);
    });

    test('round-trips 32-bit integers', () {
      final buffer = <int>[];
      ParseUtil.putInt32(buffer, 0x12345678);
      expect(ParseUtil.takeInt32(buffer), 0x12345678);
      expect(buffer, isEmpty);
    });

    test('round-trips strings', () {
      final buffer = <int>[];
      ParseUtil.putString(buffer, 'poi');
      buffer.add(0);
      expect(ParseUtil.takeString(buffer), 'poi');
      expect(buffer, isEmpty);
    });

    test('round-trips booleans', () {
      final buffer = <int>[];
      ParseUtil.putBoolean(buffer, true);
      ParseUtil.putBoolean(buffer, false);
      expect(ParseUtil.takeBoolean(buffer), isTrue);
      expect(ParseUtil.takeBoolean(buffer), isFalse);
    });

    test('round-trips doubles', () {
      final buffer = <int>[];
      ParseUtil.putDouble(buffer, 1.5);
      expect(ParseUtil.takeDouble(buffer), closeTo(1.5, 0.0001));
    });
  });
}

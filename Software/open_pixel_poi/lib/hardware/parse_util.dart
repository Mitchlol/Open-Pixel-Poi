import 'dart:convert';

import 'dart:math';

class ParseUtil {
  static String takeString(List<int> data, [int stringEndIndex = 0]) {
    if(stringEndIndex == 0) {
      stringEndIndex = data.indexWhere((it) => it == 0);
    }
    String string = utf8.decode(data.sublist(0, stringEndIndex));
    data.removeRange(0, stringEndIndex);
    data.removeAt(0);
    return string;
  }
  static int takeInt8(List<int> data) {
    return data.removeAt(0);
  }

  static int takeInt8s(List<int> data) {
    return takeInt8(data).toSigned(8);
  }

  static List<int> takeInt8List(List<int> data, int size) {
    List<int> list = data.sublist(0, size);
    data.removeRange(0, size);
    return list;
  }

  static int takeInt16(List<int> data) {
    return (data.removeAt(0) << 8) + data.removeAt(0);
  }

  static int takeInt16s(List<int> data) {
    return takeInt16(data).toSigned(16);
  }

  static int takeInt32(List<int> data) {
    return (data.removeAt(0) << 24) + (data.removeAt(0) << 16) + (data.removeAt(0) << 8) + data.removeAt(0);
  }

  static int takeInt32s(List<int> data) {
    return takeInt32(data).toSigned(32);
  }

  static double takeDouble2Byte(List<int> data, int scale) {
    return takeInt16(data) / scale;
  }

  static double takeDouble(List<int> data) {
    int res = takeInt32(data);

    int e = (res >> 23) & 0xFF;
    int sigI = res & 0x7FFFFF;
    bool neg = (res & (1 << 31)) != 0;

    double sig = 0.0;
    if (e != 0 || sigI != 0) {
      sig = sigI / (8388608.0 * 2.0) + 0.5;
      e -= 126;
    }

    if (neg) {
      sig = -sig;
    }

    return sig * pow(2, e);
  }

  static List<double> takeDoubleList(List<int> data, int size) {
    List<double> list = List.empty(growable: true);
    for (var i = 0; i < size; i++) {
      list.add(takeDouble(data));
    }
    return list;
  }

  static bool takeBoolean(List<int> data) {
    return data.removeAt(0) == 1;
  }

  static putString(List<int> buffer, String data) {
    buffer.addAll(utf8.encode(data));
  }

  static putInt8(List<int> buffer, int data) {
    buffer.add(data & 0xff);
  }

  static putInt8s(List<int> buffer, int data) {
    return putInt8(buffer, data.toUnsigned(8));
  }

  static putInt8List(List<int> buffer, List<int> data) {
    for (int variable in data) {
      putInt8(buffer, variable);
    }
  }

  static putInt16(List<int> buffer, int data) {
    buffer.add((data >> 8) & 0xff);
    buffer.add(data & 0xff);
  }

  static putInt16s(List<int> buffer, int data) {
    return putInt16(buffer, data.toUnsigned(16));
  }

  static putInt24(List<int> buffer, int data) {
    buffer.add((data >> 16) & 0xff);
    buffer.add((data >> 8) & 0xff);
    buffer.add(data & 0xff);
  }

  static putInt32(List<int> buffer, int data) {
    buffer.add(data >> 24);
    buffer.add((data >> 16) & 0xff);
    buffer.add((data >> 8) & 0xff);
    buffer.add(data & 0xff);
  }

  static putInt32s(List<int> buffer, int data) {
    return putInt32(buffer, data.toUnsigned(32));
  }

  static putDouble2Byte(List<int> buffer, double data, int scale) {
    return putInt16(buffer, (data * scale).truncate());
  }

  static putDouble(List<int> buffer, double number) {
    List frexped = frexp(number);
    int e = frexped[1];
    double sig = frexped[0];
    double sig_abs = sig.abs();
    int sig_i = 0;

    if (sig_abs >= 0.5) {
      sig_i = ((sig_abs - 0.5) * 2.0 * 8388608.0).truncate();
      e += 126;
    }

    int res = ((e & 0xFF) << 23) | (sig_i & 0x7FFFFF);
    if (sig < 0) {
      res |= 1 << 31;
    }

    putInt32(buffer, res);
  }

  static putDoubleList(List<int> buffer, List<double> data) {
    for (double variable in data) {
      putDouble(buffer, variable);
    }
  }

  static putBoolean(List<int> buffer, bool data) {
    return buffer.add(data ? 1 : 0);
  }

  static List frexp(double number) {
    double m = 0;
    int e = 0;
    if (number != 0) {
      double sign = number.sign;
      double unsigned = number.abs();

      if (unsigned >= 0.5 && unsigned < 1) {
        m = number;
      } else if (unsigned >= 1) {
        e = 1 + (log(unsigned) / log(2)).truncate();
        m = unsigned / pow(2, e);
        m = m * sign;
      } else {
        e = (log(unsigned) / log(2)).truncate();
        m = unsigned / pow(2, e);
        m = m * sign;
      }
    }

    return [m, e];
  }
}

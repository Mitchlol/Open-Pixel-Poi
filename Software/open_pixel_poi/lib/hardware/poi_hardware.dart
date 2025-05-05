import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';
import 'package:open_pixel_poi/database/dbimage.dart';
import 'package:rxdart/rxdart.dart';

import './models/comm_code.dart';
import 'ble_uart.dart';
import 'models/confirmtation.dart';
import 'models/led_pattern.dart';
import 'parse_util.dart';

class PoiHardware {
  BLEUart uart;
  late List<int> _buffer;
  BehaviorSubject<BluetoothConnectionState> state = BehaviorSubject<BluetoothConnectionState>();
  BehaviorSubject<double> largeSendProgress = BehaviorSubject<double>.seeded(0);
  late StreamSubscription<BluetoothConnectionState> subscription;
  bool isConncted = false;

  PoiHardware(this.uart) {
    subscription = uart.device.connectionState.listen((event) {
      state.add(event);
      isConncted = event == BluetoothConnectionState.connected;
    });
  }

  Future<bool> _sendIt(List<int> message, [bool confirmation = true]) {
    if(message.length < 509 && confirmation){
      return _writePacketWithConfirmation(_buildRequest(message));
    }else {
      return _writePackets(_buildRequest(message));
    }
  }

  Future<bool> _writePackets(List<int> request) async {
    int maxPacketsize = 509;
    int packets = (request.length / maxPacketsize).ceil();
    print("Write: request length = ${request.length}, splitting into $packets packets");
    largeSendProgress.add(0);

    int sentSize = 0;
    int sentPackets = 0;
    int consecutiveFailures = 0;
    while (request.isNotEmpty) {
      try {
        List<int> packet = request.take(maxPacketsize).toList();
        await uart.write(packet, withoutResponse: true);

        sentPackets++;
        sentSize += packet.length;
        print("Write batch: ${sentPackets / packets}% packet# = $sentPackets, length = ${packet.length}, sent = $sentSize, remaining = ${request.length -
            packet.length} data = $packet");
        request.removeRange(0, packet.length);
        largeSendProgress.add(sentPackets / packets);
        consecutiveFailures = 0;
      } catch (e, s){
        consecutiveFailures++;
        print("Failure, consecutive failures = $consecutiveFailures");
        print("Error: $e");
        if(consecutiveFailures > 2){
          return true;
        }
        await Future.delayed(const Duration(milliseconds: 250));
      }
    }
    return false;
  }

  Future<bool> _writePacketWithConfirmation(List<int> request) async {
    print("Write single packet:length = ${request.length}, data = $request");
    if(request.length > 512){
      return true;
    }
    return await uart.write(request).then((value) {
      print("Write Success!");
      return false;
    }, onError: (value) {
      print("Write Fail! $value");
      return true;
    });
  }

  List<int> _buildRequest(List<int> message) {
    // Build request
    List<int> request = List.empty(growable: true);
    // Start bit
    request.add(0xD0);
    // Add message length
    // ParseUtil.putInt16(request, message.length + 6); // Start bit, size 2bits, end bit
    // Message itself
    request.addAll(message);
    // End bit
    request.add(0xD1);

    // debugPrint("Request = ${request.map((e) => e.toRadixString(16)).toList()}", wrapWidth: 1024);

    return request;
  }

  Future<dynamic> readResponse() async {

    await uart.txCharacteristic.read();

    _buffer = List<int>.empty(growable: true);
    _buffer.addAll(uart.txCharacteristic.lastValue);
    print("onRecievePacket: From TX Characteristic " + uart.txCharacteristic.lastValue.toString());


    if (_buffer.isEmpty || _buffer[0] != 0xD0 || _buffer[_buffer.length -1] != 0xD1) {
      // Not the start of a message, ignore this packet
      print("onRecievePacket: Invalid packet, discarding " + _buffer.toString());
      _buffer = List.empty();
      return;
    }

    // Check packet length
    // int packetLength = (_buffer[2] << 8) + _buffer[3];
    // if (_buffer.length != packetLength) {
    //   print("onRecievePacket: Invalid packet length, discarding");
    //   _buffer = null;
    //   return;
    // }

    List<int> message = _buffer.sublist(1, _buffer.length -1);
    print("onRecievePacket: Found message: " + message.toString());
    _buffer = List.empty();
    return onRecieveMessage(message);
  }

  dynamic onRecieveMessage(List<int> message) {
    CommCode commCode = CommCode.values[message.removeAt(0)];
    switch (commCode) {
      case CommCode.CC_SUCCESS:
        return Confirmation(true);
      case CommCode.CC_ERROR:
        return Confirmation(false);
     default:
        print("Unhandled message recieved: code = $commCode, message = $message");
        return null;
    }
  }

  // Commands
  Future<bool> sendCommCode(CommCode code, [bool confirmation = true]) {
    List<int> message = [];
    ParseUtil.putInt8(message, code.index);
    return _sendIt(message, confirmation);
  }
  Future<bool> sendBool(bool value, CommCode code, [bool confirmation = true]) {
    List<int> message = [];
    ParseUtil.putInt8(message, code.index);
    ParseUtil.putBoolean(message, value);
    return _sendIt(message, confirmation);
  }
  Future<bool> sendInt8(int value, CommCode code, [bool confirmation = true]) {
    List<int> message = [];
    ParseUtil.putInt8(message, code.index);
    ParseUtil.putInt8(message, value);
    return _sendIt(message, confirmation);
  }
  Future<bool> sendInt8s(int value, CommCode code, [bool confirmation = true]) {
    List<int> message = [];
    ParseUtil.putInt8(message, code.index);
    ParseUtil.putInt8s(message, value);
    message.insert(0, code.index);
    return _sendIt(message, confirmation);
  }
  Future<bool> sendPattern(LEDPattern pattern) {
    List<int> message = [];
    ParseUtil.putInt8(message, CommCode.CC_SET_PATTERN.index);
    ParseUtil.putInt8(message, pattern.columnHeight);
    ParseUtil.putInt16(message, pattern.columnCount);
    for(int i = 0; i < pattern.columnHeight * pattern.columnCount; i++){
      ParseUtil.putInt8(message, pattern.leds[i].red);
      ParseUtil.putInt8(message, pattern.leds[i].green);
      ParseUtil.putInt8(message, pattern.leds[i].blue);
    }
    return _sendIt(message);
  }

  Future<bool> sendPattern2(DBImage pattern) {
    List<int> message = [];
    ParseUtil.putInt8(message, CommCode.CC_SET_PATTERN.index);
    ParseUtil.putInt8(message, pattern.height);
    ParseUtil.putInt16(message, pattern.count);
    ParseUtil.putInt8List(message, pattern.bytes);
    return _sendIt(message);
  }
}

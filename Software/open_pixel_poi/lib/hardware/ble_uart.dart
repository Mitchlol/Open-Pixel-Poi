import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';

class BleUart {
  // Nordic nRF
  static const serviceUuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const rxUuid = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  static const txUuid = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";
  static const notifyUuid = "6e400004-b5a3-f393-e0a9-e50e24dcca9e";

  BluetoothDevice device;
  late BluetoothService service;
  late BluetoothCharacteristic rxCharacteristic;
  late BluetoothCharacteristic txCharacteristic;
  late BluetoothCharacteristic notifyCharacteristic;

  late Future<bool> isIntialized;

  BleUart(this.device) {
    isIntialized = init();
  }

  Future<bool> init() async {
    if (await device.connectionState.first.timeout(
          Duration(seconds: 1),
          onTimeout: () => .disconnected,
        ) ==
        .connected) {
      await device.disconnect();
    }

    try {
      await device
          .connect(
            timeout: const Duration(seconds: 5),
            autoConnect: false,
            license: License.nonprofit,
          )
          .timeout(
            Duration(milliseconds: 5250),
            onTimeout: () => throw Exception("Connection Timeout"),
          );
    } catch (e) {
      // Retry once
      await device
          .connect(
            timeout: const Duration(seconds: 5),
            autoConnect: false,
            license: License.nonprofit,
          )
          .timeout(
            Duration(milliseconds: 5250),
            onTimeout: () => throw Exception("Connection Timeout"),
          );
    }

    List<BluetoothService> services = await device.discoverServices(timeout: 5);
    service = services.firstWhere(
      (BluetoothService service) => service.uuid.toString() == serviceUuid,
    );

    rxCharacteristic = service.characteristics.firstWhere(
      (characteristic) => characteristic.uuid.toString() == rxUuid,
    );
    txCharacteristic = service.characteristics.firstWhere(
      (characteristic) => characteristic.uuid.toString() == txUuid,
    );
    notifyCharacteristic = service.characteristics.firstWhere(
      (characteristic) => characteristic.uuid.toString() == notifyUuid,
    );

    // No longer using notifications!
    // bool notificationsEnabled = await notifyCharacteristic.setNotifyValue(true);
    // if (notificationsEnabled == false) {
    //   throw Exception("Unable to enable message notification");
    // }
    return true;
  }

  Future<void> write(List<int> value, {bool withoutResponse = false}) {
    return rxCharacteristic.write(value, withoutResponse: withoutResponse);
  }

  Future<void> read(List<int> value, {bool withoutResponse = false}) {
    return rxCharacteristic.write(value, withoutResponse: withoutResponse);
  }

  // Stream<List<int>> getDataStream() {
  //   return notifyCharacteristic.value;
  // }

  Future disconnect() async {
    try {
      return await device.disconnect();
    } catch (e) {
      debugPrint("$e");
    }
  }
}

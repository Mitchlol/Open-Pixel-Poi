import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:universal_ble/universal_ble.dart';

class BleUart {
  // Nordic nRF
  static const serviceUuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const rxUuid = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  static const txUuid = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";
  static const notifyUuid = "6e400004-b5a3-f393-e0a9-e50e24dcca9e";

  /// The poi sends packets of up to 512 bytes, so the link needs an MTU
  /// large enough to carry them. Only Android leaves the negotiation to
  /// the app.
  static const requestedMtu = 512;

  final BleDevice device;
  late BleService service;
  late BleCharacteristic rxCharacteristic;
  late BleCharacteristic txCharacteristic;
  late BleCharacteristic notifyCharacteristic;

  late Future<bool> isIntialized;

  BleUart(this.device) {
    isIntialized = init();
  }

  Future<bool> init() async {
    if (await _isConnected()) {
      await device.disconnect();
    }

    try {
      await _connect();
    } catch (e) {
      // Retry once
      await _connect();
    }

    if (!kIsWeb && defaultTargetPlatform == .android) {
      try {
        await device.requestMtu(requestedMtu);
      } catch (e) {
        debugPrint("MTU request failed: $e");
      }
    }

    service = await device.getService(serviceUuid, preferCached: false);
    rxCharacteristic = service.getCharacteristic(rxUuid);
    txCharacteristic = service.getCharacteristic(txUuid);
    notifyCharacteristic = service.getCharacteristic(notifyUuid);

    // No longer using notifications!
    // await notifyCharacteristic.notifications.subscribe();
    return true;
  }

  Future<bool> _isConnected() async {
    try {
      return await device.connectionState.timeout(
            const Duration(seconds: 1),
            onTimeout: () => .disconnected,
          ) ==
          .connected;
    } catch (e) {
      return false;
    }
  }

  Future<void> _connect() {
    return device
        .connect(timeout: const Duration(seconds: 5))
        .timeout(
          const Duration(milliseconds: 5250),
          onTimeout: () => throw Exception("Connection Timeout"),
        );
  }

  Future<void> write(List<int> value, {bool withoutResponse = false}) {
    return rxCharacteristic.write(value, withResponse: !withoutResponse);
  }

  Future<Uint8List> read() {
    return txCharacteristic.read();
  }

  // Stream<Uint8List> getDataStream() {
  //   return notifyCharacteristic.onValueReceived;
  // }

  Future<void> disconnect() async {
    try {
      await device.disconnect();
    } catch (e) {
      debugPrint("$e");
    }
  }
}

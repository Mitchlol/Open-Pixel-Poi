import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';

class BLEUart {
  // Nordic nRF
  static const SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const RX_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  static const TX_UUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";
  static const NOTIFY_UUID = "6e400004-b5a3-f393-e0a9-e50e24dcca9e";

  BluetoothDevice device;
  late BluetoothService service;
  late BluetoothCharacteristic rxCharacteristic;
  late BluetoothCharacteristic txCharacteristic;
  late BluetoothCharacteristic notifyCharacteristic;

  late Future<bool> isIntialized;

  BLEUart(this.device) {
    isIntialized = init();
  }

  Future<bool> init() async {

    if (await device.connectionState.first.timeout(Duration(seconds: 1), onTimeout: () => BluetoothConnectionState.disconnected) == BluetoothConnectionState.connected) {
      await device.disconnect();
    }

    try{
      await device
          .connect(timeout: Duration(seconds: 5), autoConnect: false)
          .timeout(Duration(milliseconds: 5250), onTimeout: () => throw Exception("Connection Timeout"));
    }catch(e){
      // Retry once
      await device
          .connect(timeout: Duration(seconds: 5), autoConnect: false)
          .timeout(Duration(milliseconds: 5250), onTimeout: () => throw Exception("Connection Timeout"));
    }

    List<BluetoothService> services = await device.discoverServices(timeout: 5);
    if (services == null) {
      throw Exception("Cant discover bluetooth services");
    }
    service = services.firstWhere((BluetoothService service) => service.uuid.toString() == SERVICE_UUID);
    if (service == null) {
      throw Exception("Device does not have UART service");
    }

    rxCharacteristic = service.characteristics.firstWhere((characteristic) => characteristic.uuid.toString() == RX_UUID);
    txCharacteristic = service.characteristics.firstWhere((characteristic) => characteristic.uuid.toString() == TX_UUID);
    notifyCharacteristic = service.characteristics.firstWhere((characteristic) => characteristic.uuid.toString() == NOTIFY_UUID);
    if (rxCharacteristic == null) {
      throw Exception("Device does not have UART RX characteristic");
    }
    if (txCharacteristic == null) {
      throw Exception("Device does not have UART TX characteristic");
    }
    if (notifyCharacteristic == null) {
      throw Exception("Device does not have UART NOTIFY characteristic");
    }

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
      print(e);
    }
  }
}

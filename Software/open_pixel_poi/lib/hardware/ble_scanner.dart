import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_ble/universal_ble.dart';

import 'ble_uart.dart';

/// Scans for poi and exposes the scanning state and the accumulated results
/// as streams, the way the welcome page consumes them.
class BleScanner {
  static const nameKeyword = "Pixel Poi";

  final BehaviorSubject<bool> _isScanning = BehaviorSubject.seeded(false);
  final BehaviorSubject<List<BleDevice>> _results = BehaviorSubject.seeded([]);
  StreamSubscription<BleDevice>? _subscription;
  Timer? _timeout;

  Stream<bool> get isScanning => _isScanning.stream;
  Stream<List<BleDevice>> get results => _results.stream;

  Future<void> start({Duration timeout = const Duration(seconds: 5)}) async {
    if (_isScanning.value) {
      return;
    }
    _results.add([]);
    _subscription ??= UniversalBle.scanStream.listen(_onDevice);
    _isScanning.add(true);
    try {
      await UniversalBle.startScan(
        platformConfig: PlatformConfig(
          web: WebOptions(optionalServices: [BleUart.serviceUuid]),
        ),
      );
      if (kIsWeb) {
        // Web Bluetooth scans through a chooser dialog that has already
        // returned by the time startScan completes.
        await stop();
      } else {
        _timeout = Timer(timeout, stop);
      }
    } catch (e) {
      debugPrint("Scan failed: $e");
      await stop();
    }
  }

  Future<void> stop() async {
    _timeout?.cancel();
    _timeout = null;
    try {
      await UniversalBle.stopScan();
    } catch (e) {
      debugPrint("Stopping scan failed: $e");
    }
    _isScanning.add(false);
  }

  void _onDevice(BleDevice device) {
    final name = device.name ?? "";
    if (!kIsWeb && !name.contains(nameKeyword)) {
      return;
    }
    final results = [..._results.value];
    final index = results.indexWhere((d) => d.deviceId == device.deviceId);
    if (index == -1) {
      results.add(device);
    } else {
      results[index] = device;
    }
    _results.add(results);
  }

  Future<void> dispose() async {
    await stop();
    await _subscription?.cancel();
    await _isScanning.close();
    await _results.close();
  }
}

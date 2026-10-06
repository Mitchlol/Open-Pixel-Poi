import 'package:flutter/material.dart';
import 'package:open_pixel_poi/hardware/poi_hardware.dart';
import 'package:open_pixel_poi/pages/home.dart';
import 'package:provider/provider.dart';
import 'package:universal_ble/universal_ble.dart';

import '../hardware/ble_scanner.dart';
import '../hardware/ble_uart.dart';
import '../hardware/models/fw_version.dart';
import '../model.dart';
import '../widgets/big_button.dart';
import '../widgets/status_message.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomeState();
}

class _WelcomeState extends State<WelcomePage> {
  bool hasScanned = false;
  bool isConnecting = false;
  bool isDisconnecting = false;
  List<String> checkedMacAddresses = List.empty(growable: true);
  final BleScanner scanner = BleScanner();

  @override
  void dispose() {
    scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<Object>(
          stream: scanner.isScanning,
          builder: (context, snapshot) {
            bool isScanning = false;
            if (snapshot.data != null && snapshot.data == true) {
              isScanning = true;
            }
            return StreamBuilder<List<BleDevice>>(
              stream: scanner.results,
              builder: (context, snapshot) {
                List<BleDevice>? scanResults = snapshot.data;
                if (scanResults != null) {
                  scanResults = scanResults.where((device) => (device.name ?? "").isNotEmpty).toList();
                } else {
                  scanResults = List.empty();
                }
                final selectedDevices = scanResults;
                return Column(
                  mainAxisAlignment: .center,
                  children: <Widget>[
                    Expanded(
                      child: _ScanStatusContent(
                        isConnecting: isConnecting,
                        isDisconnecting: isDisconnecting,
                        isScanning: isScanning,
                        hasScanned: hasScanned,
                        scanResults: scanResults,
                        checkedMacAddresses: checkedMacAddresses,
                        onDeviceToggled: toggleDevice,
                      ),
                    ),
                    _ScanAndConnectButtons(
                      isScanning: isScanning,
                      isBusy: isConnecting || isDisconnecting,
                      showConnect: checkedMacAddresses.isNotEmpty,
                      onScan: scan,
                      onSkipToApp: skipToApp,
                      onConnect: () {
                        connect(
                          selectedDevices
                              .where(
                                (device) => checkedMacAddresses.contains(
                                  device.deviceId,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void toggleDevice(String remoteId) {
    setState(() {
      if (checkedMacAddresses.contains(remoteId)) {
        checkedMacAddresses.remove(remoteId);
      } else {
        checkedMacAddresses.add(remoteId);
      }
    });
  }

  void skipToApp() {
    Provider.of<Model>(context, listen: false).connectedPoi = [];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return HomePage();
        },
      ),
    );
  }

  void scan() async {
    // Clear stale state
    var connectedPoi = Provider.of<Model>(context, listen: false).connectedPoi;
    Provider.of<Model>(context, listen: false).connectedPoi = null;
    if (connectedPoi != null) {
      for (var hardware in connectedPoi) {
        setState(() {
          isDisconnecting = true;
        });
        if (await hardware.uart.device.connectionState == .connected) {
          await hardware.uart.disconnect();
          await Future.delayed(Duration(milliseconds: 2000));
        }
        await hardware.subscription.cancel();
        setState(() {
          isDisconnecting = false;
        });
      }
    }
    // Scan
    hasScanned = true;
    scanner.start();
  }

  void connect(List<BleDevice> devices) async {
    final messenger = ScaffoldMessenger.of(context);
    final model = Provider.of<Model>(context, listen: false);
    // Clear stale state
    var connectedPoi = model.connectedPoi;
    model.connectedPoi = null;
    if (connectedPoi != null) {
      for (var hardware in connectedPoi) {
        setState(() {
          isDisconnecting = true;
        });
        if (await hardware.uart.device.connectionState == .connected) {
          await hardware.uart.disconnect();
        }
        await hardware.subscription.cancel();
        setState(() {
          isDisconnecting = false;
        });
      }
    }
    // Connect
    if (!mounted) return;
    setState(() {
      isConnecting = true;
    });
    model.connectedPoi = List.empty(growable: true);
    for (var device in devices) {
      BleUart bleUart = BleUart(device);
      await bleUart.isIntialized.then(
        (value) {
          debugPrint("BleUart Initialized");
          model.connectedPoi!.add(PoiHardware(bleUart));
        },
        onError: (error) {
          debugPrint("error = $error");
          const snackBar = SnackBar(
            content: Text(
              'Unable to connect, please make sure selected device is a Open Pixel Poi.',
            ),
          );
          messenger.showSnackBar(snackBar);
          return;
        },
      );
    }
    // Check the firmware version of each connected device
    if (!mounted) return;
    debugPrint("Check firmware version");
    for (PoiHardware poi in model.connectedPoi!) {
      await poi.sendInt8(0, .CC_GET_FW_VERSION, true);
      final version = await poi.readResponse() as FWVersion?;
      if (!mounted) return;
      if ((version?.version ?? 0) != 2) {
        setState(() {
          isConnecting = false;
        });
        const snackBar = SnackBar(
          content: Text(
            'Outdated firmware on you Open Pixel Poi, please update your firmware. (Or use an old version of the app.)',
          ),
        );
        messenger.showSnackBar(snackBar);
        return;
      }
    }
    // Start app
    if (!mounted) return;
    if (model.connectedPoi!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return HomePage();
          },
        ),
      );
      await Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          isConnecting = false;
        });
      });
    } else {
      setState(() {
        isConnecting = false;
      });
    }
  }
}

/// Shows the connection progress, a welcome or empty result message, or the
/// list of discovered poi, depending on where in the scan flow the user is.
class _ScanStatusContent extends StatelessWidget {
  final bool isConnecting;
  final bool isDisconnecting;
  final bool isScanning;
  final bool hasScanned;
  final List<BleDevice> scanResults;
  final List<String> checkedMacAddresses;
  final ValueChanged<String> onDeviceToggled;

  const _ScanStatusContent({
    required this.isConnecting,
    required this.isDisconnecting,
    required this.isScanning,
    required this.hasScanned,
    required this.scanResults,
    required this.checkedMacAddresses,
    required this.onDeviceToggled,
  });

  @override
  Widget build(BuildContext context) {
    if (isConnecting) {
      return const StatusMessage(title: "Connecting...", showProgress: true);
    } else if (isDisconnecting) {
      return const StatusMessage(title: "Disconnecting...", showProgress: true);
    } else if (!isScanning && !hasScanned) {
      return const _WelcomeMessage();
    } else if (!isScanning && scanResults.isEmpty) {
      return const StatusMessage(
        title: "No bluetooth devices found!",
        subtitle: "Please make sure bluetooth and location are enabled, and your poi is powered on.",
      );
    }
    return _DiscoveredPoiList(
      scanResults: scanResults,
      checkedMacAddresses: checkedMacAddresses,
      onToggled: onDeviceToggled,
    );
  }
}

class _DiscoveredPoiList extends StatelessWidget {
  final List<BleDevice> scanResults;
  final List<String> checkedMacAddresses;
  final ValueChanged<String> onToggled;

  const _DiscoveredPoiList({
    required this.scanResults,
    required this.checkedMacAddresses,
    required this.onToggled,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: scanResults.length,
      scrollDirection: .vertical,
      itemBuilder: (BuildContext context, int index) {
        final device = scanResults[index];
        return Card(
          child: ListTile(
            leading: Checkbox(
              value: checkedMacAddresses.contains(device.deviceId),
              onChanged: (checked) => onToggled(device.deviceId),
            ),
            title: Text('Name: ${device.name}'),
            subtitle: Text('Address: ${device.deviceId}'),
            trailing: Icon(Icons.bluetooth),
            onTap: () => onToggled(device.deviceId),
          ),
        );
      },
    );
  }
}

class _ScanAndConnectButtons extends StatelessWidget {
  final bool isScanning;
  final bool isBusy;
  final bool showConnect;
  final VoidCallback onScan;
  final VoidCallback onSkipToApp;
  final VoidCallback onConnect;

  const _ScanAndConnectButtons({
    required this.isScanning,
    required this.isBusy,
    required this.showConnect,
    required this.onScan,
    required this.onSkipToApp,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return BigButtonRow(
      buttons: [
        BigButton(
          "Scan",
          onPressed: isScanning || isBusy ? null : onScan,
          onLongPress: isScanning || isBusy ? null : onSkipToApp,
          child: isScanning ? CircularProgressIndicator() : null,
        ),
        if (showConnect)
          BigButton(
            "Connect",
            onPressed: isBusy ? null : onConnect,
            child: isBusy ? CircularProgressIndicator() : null,
          ),
      ],
    );
  }
}

/// Logo and greeting shown before the first scan.
class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: .min,
          children: [
            Image.asset("assets/logo.png", height: 160),
            const SizedBox(height: 30),
            const Text(
              "Welcome to Open Pixel Poi!",
              textAlign: .center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: .bold,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Press scan below to search for your poi, this may launch a permission request.",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

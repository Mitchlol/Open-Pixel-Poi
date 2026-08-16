import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:open_pixel_poi/hardware/poi_hardware.dart';
import 'package:open_pixel_poi/pages/home.dart';
import 'package:provider/provider.dart';

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
  final GlobalKey<State> _key = GlobalKey<State>();

  bool hasScanned = false;
  bool isConnecting = false;
  bool isDisconnecting = false;
  List<String> checkedMacAddresses = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: _key,
        title: const Text("Open Pixel Poi"),
      ),
      body: StreamBuilder<Object>(
        stream: FlutterBluePlus.isScanning,
        builder: (context, snapshot) {
          bool isScanning = false;
          if (snapshot.data != null && snapshot.data == true) {
            isScanning = true;
          }
          return StreamBuilder<List<ScanResult>>(
            stream: FlutterBluePlus.scanResults,
            builder: (context, snapshot) {
              List<ScanResult>? scanResults = snapshot.data;
              if (scanResults != null) {
                scanResults = scanResults
                    .where(
                      (result) =>
                          result.advertisementData.connectable &&
                          result.device.platformName.isNotEmpty,
                    )
                    .toList();
              } else {
                scanResults = List.empty();
              }
              final Widget content;
              if (isConnecting) {
                content = const StatusMessage(
                  title: "Connecting...",
                  showProgress: true,
                );
              } else if (isDisconnecting) {
                content = const StatusMessage(
                  title: "Disconnecting...",
                  showProgress: true,
                );
              } else if (!isScanning && !hasScanned) {
                content = const StatusMessage(
                  title: "Welcome to your poi!",
                  subtitle: "Press scan below to search for your poi, this may launch a permission request.",
                );
              } else if (!isScanning && scanResults.isEmpty) {
                content = const StatusMessage(
                  title: "No bluetooth devices found!",
                  subtitle: "Please make sure bluetooth and location are enabled, and your poi is powered on.",
                );
              } else {
                content = _ScanResultList(
                  scanResults: scanResults,
                  checkedMacAddresses: checkedMacAddresses,
                  onToggled: toggleDevice,
                );
              }
              final selectedDevices = scanResults;
              return Column(
                mainAxisAlignment: .center,
                children: <Widget>[
                  Expanded(child: content),
                  _BottomButtons(
                    isScanning: isScanning,
                    isBusy: isConnecting || isDisconnecting,
                    showConnect: checkedMacAddresses.isNotEmpty,
                    onScan: scan,
                    onSkipToApp: skipToApp,
                    onConnect: () {
                      connect(
                        selectedDevices
                            .where(
                              (scanResult) => checkedMacAddresses.contains(
                                scanResult.device.remoteId.str,
                              ),
                            )
                            .map((e) => e.device)
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
      _key.currentContext!,
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
        if (await hardware.uart.device.connectionState.first == .connected) {
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
    FlutterBluePlus.startScan(
      withKeywords: ["Pixel Poi"],
      webOptionalServices: [Guid(BleUart.serviceUuid)],
      timeout: Duration(seconds: 5),
      androidUsesFineLocation: false,
    );
  }

  void connect(List<BluetoothDevice> devices) async {
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
        if (await hardware.uart.device.connectionState.first == .connected) {
          await hardware.uart.disconnect();
        }
        await hardware.subscription.cancel();
        setState(() {
          isDisconnecting = false;
        });
      }
    }
    // Connect
    setState(() {
      isConnecting = true;
    });
    Provider.of<Model>(_key.currentContext!, listen: false).connectedPoi =
        List.empty(growable: true);
    for (var device in devices) {
      BleUart bleUart = BleUart(device);
      await bleUart.isIntialized.then(
        (value) {
          debugPrint("BleUart Initialized");
          Provider.of<Model>(
            _key.currentContext!,
            listen: false,
          ).connectedPoi!.add(PoiHardware(bleUart));
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
    debugPrint("Check firmware version");
    for (PoiHardware poi in model.connectedPoi!) {
      await poi.sendInt8(0, .getFwVersion, true);
      FWVersion? version = await poi.readResponse();
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
    if (Provider.of<Model>(
      _key.currentContext!,
      listen: false,
    ).connectedPoi!.isNotEmpty) {
      Navigator.push(
        _key.currentContext!,
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

class _ScanResultList extends StatelessWidget {
  final List<ScanResult> scanResults;
  final List<String> checkedMacAddresses;
  final ValueChanged<String> onToggled;

  const _ScanResultList({
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
        final device = scanResults[index].device;
        return Card(
          child: ListTile(
            leading: Checkbox(
              value: checkedMacAddresses.contains(device.remoteId.str),
              onChanged: (checked) => onToggled(device.remoteId.str),
            ),
            title: Text('Name: ${device.platformName}'),
            subtitle: Text('Address: ${device.remoteId.str}'),
            trailing: Icon(Icons.bluetooth),
            onTap: () => onToggled(device.remoteId.str),
          ),
        );
      },
    );
  }
}

class _BottomButtons extends StatelessWidget {
  final bool isScanning;
  final bool isBusy;
  final bool showConnect;
  final VoidCallback onScan;
  final VoidCallback onSkipToApp;
  final VoidCallback onConnect;

  const _BottomButtons({
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

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';
import 'package:open_pixel_poi/hardware/poi_hardware.dart';
import 'package:open_pixel_poi/pages/home.dart';
import 'package:provider/provider.dart';

import '../hardware/ble_uart.dart';
import '../hardware/models/comm_code.dart';
import '../hardware/models/fw_version.dart';
import '../model.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<WelcomePage> {
  final GlobalKey<State> _key = GlobalKey<State>();

  bool hasScanned = false;
  bool isConnecting = false;
  bool isDisconnecting = false;
  bool hwinitState = false;
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
                    scanResults =
                        scanResults.where((result) => result.advertisementData.connectable && result.device.platformName.isNotEmpty).toList();
                  } else {
                    scanResults = List.empty();
                  }
                  return getBody(isScanning, scanResults);
                });
          }),
    );
  }

  Widget getBody(bool isScanning, List<ScanResult> scanResults) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(child: getAllListStates(isScanning, scanResults)),
        getButtons(isScanning, scanResults),
      ],
    );
  }

  Widget getAllListStates(bool isScanning, List<ScanResult> scanResults) {
    if (isConnecting) {
      return getConnecting();
    } else if (isDisconnecting) {
      return getDisconnecting();
    } else if (!isScanning && (scanResults == null || hasScanned == false)) {
      return getWelcome();
    } else if (!isScanning && scanResults.isEmpty) {
      return getEmpty();
    } else {
      return getList(scanResults);
    }
  }

  Widget getWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Welcome to your poi!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Press scan below to search for your poi, this may launch a permission request.",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "No bluetooth devices found!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Please make sure bluetooth and location are enabled, and your poi is powered on.",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getList(List<ScanResult> scanResults) {
    // scanResults.sort((a, b){
    //   if(a.device.platformName.contains("Pixel Poi") && a.device.platformName.contains("Pixel Poi")){
    //     return a.device.remoteId.str.compareTo(b.device.remoteId.str);
    //   }else{
    //     return b.device.platformName.contains("Pixel Poi") ? 1 : -1;
    //   }
    // });
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: scanResults.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: ListTile(
            leading: Checkbox(
              value: checkedMacAddresses.contains(scanResults[index].device.remoteId.str),
              onChanged: (checked) {
                setState(() {
                  if (checkedMacAddresses.contains(scanResults[index].device.remoteId.str)) {
                    checkedMacAddresses.remove(scanResults[index].device.remoteId.str);
                  } else {
                    checkedMacAddresses.add(scanResults[index].device.remoteId.str);
                  }
                });
              },
            ),
            title: Text('Name: ${scanResults[index].device.platformName}'),
            subtitle: Text('Address: ${scanResults[index].device.remoteId.str}'),
            trailing: Icon(Icons.bluetooth),
            onTap: () {
              setState(() {
                if (checkedMacAddresses.contains(scanResults[index].device.remoteId.str)) {
                  checkedMacAddresses.remove(scanResults[index].device.remoteId.str);
                } else {
                  checkedMacAddresses.add(scanResults[index].device.remoteId.str);
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget getConnecting() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Connecting...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget getDisconnecting() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Disconnecting...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget getButtons(bool isRefreshing, List<ScanResult> scanResults) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: isRefreshing || isConnecting || isDisconnecting ? null : () {
                  scan();
                },
                onLongPress: isRefreshing || isConnecting || isDisconnecting ? null : () {
                  Provider.of<Model>(context, listen: false).connectedPoi = [];
                  Navigator.push(
                    _key.currentContext!,
                    MaterialPageRoute(builder: (context) {
                      return MyHomePage();
                    }),
                  );
                },
                child: isRefreshing
                    ? CircularProgressIndicator()
                    : const Text(
                        "Scan",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if(checkedMacAddresses.isNotEmpty)
              const VerticalDivider(width: 8.0),
            if (checkedMacAddresses.isNotEmpty)
              Expanded(
                child: ElevatedButton(
                  onPressed: isConnecting || isDisconnecting
                      ? null
                      : () {
                          connect(scanResults
                              .where((scanResult) => checkedMacAddresses.contains(scanResult.device.remoteId.str))
                              .map((e) => e.device)
                              .toList());
                        },
                  child: isConnecting || isDisconnecting
                      ? CircularProgressIndicator()
                      : const Text(
                          "Connect",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
          ],
        ),
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
        if (await hardware.uart.device.connectionState.first == BluetoothConnectionState.connected) {
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
    FlutterBluePlus.startScan(withKeywords: ["Pixel Poi"], webOptionalServices: [Guid(BLEUart.SERVICE_UUID)], timeout: Duration(seconds: 5), androidUsesFineLocation: false);
    // FlutterBluePlus.startScan(withKeywords: ["Pixel Poi"], timeout: Duration(seconds: 5), androidUsesFineLocation: false);
  }

  void connect(List<BluetoothDevice> devices) async {
    // Clear stale state
    var connectedPoi = Provider.of<Model>(context, listen: false).connectedPoi;
    Provider.of<Model>(context, listen: false).connectedPoi = null;
    if (connectedPoi != null) {
      for (var hardware in connectedPoi) {
        setState(() {
          isDisconnecting = true;
        });
        if (await hardware.uart.device.connectionState.first == BluetoothConnectionState.connected) {
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
    Provider.of<Model>(_key.currentContext!, listen: false).connectedPoi = List.empty(growable: true);
    for (var device in devices) {
      BLEUart bleUart = BLEUart(device);
      await bleUart.isIntialized.then((value) {
        print("BLEUart Initialized");
        Provider.of<Model>(_key.currentContext!, listen: false).connectedPoi!.add(PoiHardware(bleUart));
      }, onError: (error) {
        print("error = $error");
        const snackBar = SnackBar(content: Text('Unable to connect, please make sure selected device is a Open Pixel Poi.'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      });
    }
    // Check the firmware version of each connected device
    print("Check firmware version");
    for(PoiHardware poi in Provider.of<Model>(context, listen: false).connectedPoi!){
      await poi.sendInt8(0, CommCode.CC_GET_FW_VERSION, true);
      FWVersion? version = await poi.readResponse();
      if((version?.version??0) != 2){
        setState(() {
          isConnecting = false;
        });
        const snackBar = SnackBar(content: Text('Outdated firmware on you Open Pixel Poi, please update your firmware. (Or use an old version of the app.)'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }
    // Start app
    if (Provider.of<Model>(_key.currentContext!, listen: false).connectedPoi!.isNotEmpty) {
      Navigator.push(
        _key.currentContext!,
        MaterialPageRoute(builder: (context) {
          return MyHomePage();
        }),
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

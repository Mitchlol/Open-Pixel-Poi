import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';
import 'package:open_pixel_poi/hardware/poi_hardware.dart';
import 'package:provider/provider.dart';
import '../hardware/ble_uart.dart';
import '../model.dart';

class ConnectionStateIndicator extends StatefulWidget {
  int connectedPoiIndex;

  ConnectionStateIndicator(this.connectedPoiIndex, {super.key});

  @override
  State<StatefulWidget> createState() => _CSIState(connectedPoiIndex);
}

class _CSIState extends State<ConnectionStateIndicator> {
  int connectedPoiIndex;
  bool isChanging = false;

  _CSIState(this.connectedPoiIndex);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothConnectionState>(
      stream: Provider.of<Model>(context).connectedPoi![connectedPoiIndex].state,
      builder: (context, snapshot) {
        if (isChanging) {
          return Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 15, right: 12),
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data == BluetoothConnectionState.connected) {
          return IconButton(
            icon: const Icon(
              Icons.bluetooth,
              color: Colors.lightGreenAccent,
            ),
            onPressed: disconnect,
          );
        } else if (snapshot.hasData && snapshot.data == BluetoothConnectionState.disconnected) {
          return IconButton(
              icon: const Icon(
                Icons.bluetooth,
                color: Colors.red,
              ),
              onPressed: connect);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  void connect() {
    setState(() {
      isChanging = true;
    });
    BLEUart bleUart = BLEUart(Provider.of<Model>(context, listen: false).connectedPoi![connectedPoiIndex].uart.device);
    bleUart.isIntialized.then((value) {
      Provider.of<Model>(context, listen: false).connectedPoi![connectedPoiIndex] = PoiHardware(bleUart);
      setState(() {
        isChanging = false;
      });
    }, onError: (error) {
      setState(() {
        isChanging = false;
      });
    });
  }

  void disconnect() async {
    setState(() {
      isChanging = true;
    });
    var hardware = Provider.of<Model>(context, listen: false).connectedPoi![connectedPoiIndex];
    await hardware.uart.disconnect();
    await hardware.subscription.cancel();
    hardware.state.add(BluetoothConnectionState.disconnected); // Manually send disconnect event as our manual disconnect doesn't always trigger one
    hardware.isConncted = false; // Update flag in hardware as it doesn't get triggered
    setState(() {
      isChanging = false;
    });
  }
}

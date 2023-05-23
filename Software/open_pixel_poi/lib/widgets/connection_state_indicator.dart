import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:open_pixel_poi/hardware/poi_hardware.dart';
import 'package:provider/provider.dart';
import '../hardware/ble_uart.dart';
import '../model.dart';

class ConnectionStateIndicator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CSIState();
}

class _CSIState extends State<ConnectionStateIndicator> {
  bool isChanging = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothDeviceState>(
      stream: Provider.of<Model>(context).hardware!.state,
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
        } else if (snapshot.hasData && snapshot.data == BluetoothDeviceState.connected) {
          return IconButton(
            icon: Icon(
              Icons.bluetooth,
              color: Colors.lightGreenAccent,
            ),
            onPressed: disconnect,
          );
        } else if (snapshot.hasData && snapshot.data == BluetoothDeviceState.disconnected) {
          return IconButton(
              icon: Icon(
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
    BLEUart bleUart = BLEUart(Provider.of<Model>(context, listen: false).hardware!.uart.device);
    bleUart.isIntialized?.then((value) {
      Provider.of<Model>(context, listen: false).hardware = PoiHardware(bleUart);
      setState(() {
        isChanging = false;
      });
    }, onError: (error) {
      setState(() {
        isChanging = false;
      });
    });
  }

  void disconnect() {
    setState(() {
      isChanging = true;
    });
    Provider.of<Model>(context, listen: false).hardware!.uart.disconnect();
    Future.delayed(Duration(seconds: 2)).then((value) {
      setState(() {
        isChanging = false;
      });
    });
  }
}

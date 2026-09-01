import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:open_pixel_poi/hardware/poi_hardware.dart';
import 'package:provider/provider.dart';

import '../hardware/ble_uart.dart';
import '../model.dart';

/// One [ConnectionStateIndicator] per connected poi, for use in app bars.
class ConnectionStateIndicators extends StatelessWidget {
  const ConnectionStateIndicators({super.key});

  @override
  Widget build(BuildContext context) {
    final connectedPoi = Provider.of<Model>(context).connectedPoi!;
    return Row(
      mainAxisSize: .min,
      children: [
        for (var i = 0; i < connectedPoi.length; i++)
          ConnectionStateIndicator(i),
      ],
    );
  }
}

class ConnectionStateIndicator extends StatefulWidget {
  final int connectedPoiIndex;

  const ConnectionStateIndicator(this.connectedPoiIndex, {super.key});

  @override
  State<ConnectionStateIndicator> createState() =>
      _ConnectionStateIndicatorState();
}

class _ConnectionStateIndicatorState extends State<ConnectionStateIndicator> {
  bool isChanging = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothConnectionState>(
      stream: Provider.of<Model>(context)
          .connectedPoi![widget.connectedPoiIndex]
          .state,
      builder: (context, snapshot) {
        if (isChanging) {
          return const Padding(
            padding: EdgeInsets.only(top: 15, bottom: 15, right: 12),
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data == .connected) {
          return IconButton(
            icon: const Icon(
              Icons.bluetooth,
              color: Colors.lightGreenAccent,
            ),
            onPressed: disconnect,
          );
        } else if (snapshot.hasData && snapshot.data == .disconnected) {
          return IconButton(
            icon: const Icon(
              Icons.bluetooth,
              color: Colors.red,
            ),
            onPressed: connect,
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  void connect() {
    setState(() {
      isChanging = true;
    });
    BleUart bleUart = BleUart(
      Provider.of<Model>(
        context,
        listen: false,
      ).connectedPoi![widget.connectedPoiIndex].uart.device,
    );
    bleUart.isIntialized.then(
      (value) {
        if (!mounted) {
          return;
        }
        Provider.of<Model>(
          context,
          listen: false,
        ).connectedPoi![widget.connectedPoiIndex] = PoiHardware(
          bleUart,
        );
        setState(() {
          isChanging = false;
        });
      },
      onError: (error) {
        if (!mounted) {
          return;
        }
        setState(() {
          isChanging = false;
        });
      },
    );
  }

  void disconnect() async {
    setState(() {
      isChanging = true;
    });
    var hardware = Provider.of<Model>(
      context,
      listen: false,
    ).connectedPoi![widget.connectedPoiIndex];
    await hardware.uart.disconnect();
    await hardware.subscription.cancel();
    hardware.state.add(.disconnected); // Manually send disconnect event as our manual disconnect doesn't always trigger one
    hardware.isConncted =
        false; // Update flag in hardware as it doesn't get triggered
    if (!mounted) {
      return;
    }
    setState(() {
      isChanging = false;
    });
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../hardware/models/battery_status.dart';
import '../hardware/poi_hardware.dart';
import '../model.dart';

class BatteryIndicator extends StatefulWidget {
  static const Duration refreshInterval = Duration(seconds: 30);

  final int connectedPoiIndex;

  const BatteryIndicator(this.connectedPoiIndex, {super.key});

  @override
  State<BatteryIndicator> createState() => _BatteryIndicatorState();
}

class _BatteryIndicatorState extends State<BatteryIndicator> {
  Timer? timer;
  BatteryStatus? status;
  bool isRefreshing = false;

  PoiHardware get poi => Provider.of<Model>(
    context,
    listen: false,
  ).connectedPoi![widget.connectedPoiIndex];

  @override
  void initState() {
    super.initState();
    status = poi.battery.value;
    timer = Timer.periodic(BatteryIndicator.refreshInterval, (_) => refresh());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    if (!mounted || isRefreshing) {
      return;
    }
    // Other pages read their own responses from the poi, so only poll while
    // this page is on top to avoid picking up each other's replies.
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }
    PoiHardware hardware = poi;
    if (!hardware.isConncted || hardware.isSending) {
      return;
    }
    isRefreshing = true;
    BatteryStatus? latest = await hardware.readBattery();
    isRefreshing = false;
    if (mounted) {
      setState(() {
        status = latest;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    BatteryStatus? current = status;
    if (current == null || !current.sensorPresent) {
      return const SizedBox.shrink();
    }
    return InkWell(
      onTap: refresh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(current), color: _colorFor(current)),
            Text("${current.percent}%"),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(BatteryStatus status) {
    if (status.state == BatteryState.critical || status.state == BatteryState.shutdown) {
      return Icons.battery_alert;
    }
    int percent = status.percent;
    if (percent >= 95) return Icons.battery_full;
    if (percent >= 80) return Icons.battery_6_bar;
    if (percent >= 65) return Icons.battery_5_bar;
    if (percent >= 50) return Icons.battery_4_bar;
    if (percent >= 35) return Icons.battery_3_bar;
    if (percent >= 20) return Icons.battery_2_bar;
    if (percent >= 10) return Icons.battery_1_bar;
    return Icons.battery_0_bar;
  }

  Color _colorFor(BatteryStatus status) {
    if (status.state != BatteryState.ok || status.percent <= 10) {
      return Colors.red;
    }
    if (status.percent <= 30) {
      return Colors.orange;
    }
    return Colors.lightGreenAccent;
  }
}

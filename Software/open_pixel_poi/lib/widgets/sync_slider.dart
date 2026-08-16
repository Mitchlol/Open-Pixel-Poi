import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../hardware/models/comm_code.dart';
import '../model.dart';

String defaultSuffixGenerator(double value) {
  return "${value.toInt()}%";
}

class SyncSlider extends StatefulWidget {
  final String title;
  final CommCode code;
  final int Function() getter;
  final Function(int) setter;
  final double maxValue;
  final double minValue;
  final double scaler;
  final String Function(double) suffixGenerator;

  const SyncSlider(
    this.title,
    this.code,
    this.getter,
    this.setter, {
    super.key,
    this.maxValue = 100.0,
    this.minValue = 0.0,
    this.scaler = 2.55,
    this.suffixGenerator = defaultSuffixGenerator,
  });

  @override
  State<SyncSlider> createState() => _SyncSliderState();
}

class _SyncSliderState extends State<SyncSlider> {
  late double temp = (widget.getter() ~/ widget.scaler).toDouble();

  @override
  void initState() {
    super.initState();
    final scaled = widget.getter() / widget.scaler;
    if (scaled > widget.maxValue || scaled < widget.minValue) {
      widget.setter(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ListTile(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.blue,
          ),
        ),
        subtitle: Slider(
          value: temp,
          max: widget.maxValue,
          min: widget.minValue,
          divisions: max(
            widget.maxValue.toInt().abs() + widget.minValue.toInt().abs(),
            1,
          ),
          label: widget.suffixGenerator(temp),
          onChanged: (double value) {
            setState(() {
              temp = value;
            });
          },
          onChangeEnd: (double value) {
            setInt((value * widget.scaler).round(), context);
          },
        ),
      ),
    );
  }

  void setInt(int value, BuildContext context) async {
    Model model = Provider.of<Model>(context, listen: false);
    int previous = widget.getter();
    try {
      debugPrint("Set int ${widget.code.name}");
      setState(() {
        widget.setter(value);
      });
      for (var poi in model.connectedPoi!) {
        await poi.sendInt8(value, widget.code);
      }
    } catch (e, s) {
      // revert!
      setState(() {
        widget.setter(previous);
      });
      debugPrint("$e");
      debugPrint("$s");
    }
  }
}

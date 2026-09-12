import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../hardware/models/rgb_value.dart';
import '../model.dart';

class LabeledSlider extends StatefulWidget {
  String title;
  int min, max, step;
  int? initial;
  Key? key;
  Function(int) onValueChanged;

  LabeledSlider(
    this.title,
    this.min,
    this.max,
    this.step,
    this.onValueChanged, [
    this.initial,
    this.key,
  ]) {
    if (this.initial == null) {
      this.initial = this.min;
    }
  }

  @override
  _LabeledSliderState createState() => _LabeledSliderState(title, min, max, step, onValueChanged, initial!, key);
}

class _LabeledSliderState extends State<LabeledSlider> {
  String title;
  Function(int) onValueChanged;

  int min, max, step, initial;
  late int value;
  Key? key;

  _LabeledSliderState(
    this.title,
    this.min,
    this.max,
    this.step,
    this.onValueChanged,
    this.initial,
    this.key,
  ) {
    value = initial;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ListTile(
        title: Text(
          "$title: $value",
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
        subtitle: Slider(
          key: key,
          value: value.toDouble(),
          max: max.toDouble(),
          min: min.toDouble(),
          divisions: ((max - min) / step).round(),
          // label: "$value",
          onChanged: (double newValue) {
            setState(() {
              value = newValue.round();
            });
          },
          onChangeEnd: (double newValue) {
            value = newValue.round();
            onValueChanged(value);
          },
        ),
      ),
    );
  }
}

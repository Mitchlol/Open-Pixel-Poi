import 'package:flutter/material.dart';

class LabeledSlider extends StatefulWidget {
  final String title;
  final int min, max, step;
  final int? initial;
  final Function(int) onValueChanged;

  const LabeledSlider(
    this.title,
    this.min,
    this.max,
    this.step,
    this.onValueChanged, [
    this.initial,
    Key? key,
  ]) : super(key: key);

  @override
  State<LabeledSlider> createState() => _LabeledSliderState();
}

class _LabeledSliderState extends State<LabeledSlider> {
  late int value = widget.initial ?? widget.min;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ListTile(
        title: Text(
          "${widget.title}: $value",
          style: const TextStyle(
            color: Colors.blue,
          ),
        ),
        subtitle: Slider(
          value: value.toDouble(),
          max: widget.max.toDouble(),
          min: widget.min.toDouble(),
          divisions: ((widget.max - widget.min) / widget.step).round(),
          onChanged: (double newValue) {
            setState(() {
              value = newValue.round();
            });
          },
          onChangeEnd: (double newValue) {
            value = newValue.round();
            widget.onValueChanged(value);
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../hardware/models/rgb_value.dart';

class ColorPicker extends StatefulWidget {
  final String title;
  final double red, green, blue;
  final Function(RgbValue) onValueChanged;

  const ColorPicker(
    this.title,
    this.red,
    this.green,
    this.blue,
    this.onValueChanged, {
    super.key,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late double red = widget.red;
  late double green = widget.green;
  late double blue = widget.blue;

  void _notify() {
    widget.onValueChanged(RgbValue([red.toInt(), green.toInt(), blue.toInt()]));
  }

  Widget _channelSlider(
    String label,
    double value,
    void Function(double) onChanged,
  ) {
    return Row(
      children: [
        Text(label),
        Expanded(
          child: Slider(
            value: value,
            max: 255.0,
            divisions: 255,
            onChanged: (double newValue) {
              setState(() {
                onChanged(newValue);
              });
            },
            onChangeEnd: (double newValue) {
              _notify();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.blue,
        ),
      ),
      subtitle: Column(
        children: [
          _channelSlider("R:", red, (value) => red = value),
          _channelSlider("G:", green, (value) => green = value),
          _channelSlider("B:", blue, (value) => blue = value),
        ],
      ),
      trailing: SizedBox(
        width: 50,
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(
              255,
              red.toInt(),
              green.toInt(),
              blue.toInt(),
            ),
            border: Border.all(color: Colors.black),
          ),
        ),
      ),
    );
  }
}

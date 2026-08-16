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
          _ChannelSlider(
            label: "R:",
            value: red,
            onChanged: (value) => setState(() => red = value),
            onChangeEnd: _notify,
          ),
          _ChannelSlider(
            label: "G:",
            value: green,
            onChanged: (value) => setState(() => green = value),
            onChangeEnd: _notify,
          ),
          _ChannelSlider(
            label: "B:",
            value: blue,
            onChanged: (value) => setState(() => blue = value),
            onChangeEnd: _notify,
          ),
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

class _ChannelSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onChangeEnd;

  const _ChannelSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        Expanded(
          child: Slider(
            value: value,
            max: 255.0,
            divisions: 255,
            onChanged: onChanged,
            onChangeEnd: (double value) {
              onChangeEnd();
            },
          ),
        ),
      ],
    );
  }
}

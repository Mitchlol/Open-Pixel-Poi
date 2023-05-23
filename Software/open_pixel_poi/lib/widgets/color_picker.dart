import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../hardware/models/rgb_value.dart';
import '../model.dart';

class ColorSetter extends StatefulWidget {
  String title;
  double red, green, blue;
  Function(RGBValue) onValueChanged;

  ColorSetter(this.title, this.red, this.green, this.blue, this.onValueChanged);

  @override
  _ColorSetterState createState() => _ColorSetterState(title, red, green, blue, onValueChanged);
}

class _ColorSetterState extends State<ColorSetter> {
  String title;
  Function(RGBValue) onValueChanged;

  double red, green, blue;

  _ColorSetterState(this.title, this.red, this.green, this.blue, this.onValueChanged);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
      subtitle: Column(
        children: [
          Row(
            children: [
              Text("R:"),
              Expanded(
                child: Slider(
                  value: red,
                  max: 255.0,
                  divisions: 255,
                  onChanged: (double value) {
                    setState(() {
                      red = value;
                    });
                  },
                  onChangeEnd: (double value) {
                    onValueChanged(RGBValue([red.toInt(), green.toInt(), blue.toInt()]));
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text("G:"),
              Expanded(
                child: Slider(
                  value: green,
                  max: 255,
                  divisions: 255,
                  onChanged: (double value) {
                    setState(() {
                      green = value;
                    });
                  },
                  onChangeEnd: (double value) {
                    onValueChanged(RGBValue([red.toInt(), green.toInt(), blue.toInt()]));
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text("B:"),
              Expanded(
                child: Slider(
                  value: blue,
                  max: 255,
                  divisions: 255,
                  onChanged: (double value) {
                    setState(() {
                      blue = value;
                    });
                  },
                  onChangeEnd: (double value) {
                    onValueChanged(RGBValue([red.toInt(), green.toInt(), blue.toInt()]));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: SizedBox(
        width: 50,
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(
                255, red.toInt(), green.toInt(), blue.toInt()),
            border: Border.all(color: Colors.black),
          ),
        ),
      ),
    );
  }
}

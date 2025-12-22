import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../hardware/models/rgb_value.dart';
import '../model.dart';

class LabeledButtonSelect extends StatefulWidget {
  String title;
  int min, max;
  int? initial;
  Key? key;
  Function(int) onValueChanged;

  LabeledButtonSelect(this.title, this.min, this.max, this.onValueChanged, [this.initial, this.key]){
    if (this.initial == null) {
      this.initial = this.min;
    }
  }

  @override
  _LabeledButtonSelectState createState() => _LabeledButtonSelectState(title, min, max, onValueChanged, initial!, key);
}

class _LabeledButtonSelectState extends State<LabeledButtonSelect> {
  String title;
  Function(int) onValueChanged;

  int min, max, initial;
  late int value;
  Key? key;

  _LabeledButtonSelectState(this.title, this.min, this.max, this.onValueChanged, this.initial, this.key){
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
        subtitle: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  child: const Text(
                    "-",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      value = Math.max(min, value - 1000);
                      onValueChanged(value);
                    });
                  },
                ),
              ),
            ),
            const VerticalDivider(width: 8.0),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  child: const Text(
                    "-",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      value = Math.max(min, value - 100);
                      onValueChanged(value);
                    });
                  },
                ),
              ),
            ),
            const VerticalDivider(width: 8.0),
            Expanded(
              child: SizedBox(
                height: 40,
                child: ElevatedButton(
                  child: const Text(
                    "-",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      value = Math.max(min, value - 10);
                      onValueChanged(value);
                    });
                  },
                ),
              ),
            ),
            const VerticalDivider(width: 8.0),
            Expanded(
              child: SizedBox(
                height: 30,
                child: ElevatedButton(
                  child: const Text(
                    "-",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      value = Math.max(min, value - 1);
                      onValueChanged(value);
                    });
                  },
                ),
              ),
            ),
            const VerticalDivider(width: 8.0),
            Expanded(
              child: SizedBox(
                height: 30,
                child: ElevatedButton(
                  child: const Text(
                    "+",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      value = Math.min(max, value + 1);
                      onValueChanged(value);
                    });
                  },
                ),
              ),
            ),
            const VerticalDivider(width: 8.0),
            Expanded(
              child: SizedBox(
                height: 40,
                child: ElevatedButton(
                  child: const Text(
                    "+",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      value = Math.min(max, value + 10);
                      onValueChanged(value);
                    });
                  },
                ),
              ),
            ),
            const VerticalDivider(width: 8.0),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  child: const Text(
                    "+",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      value = Math.min(max, value + 100);
                      onValueChanged(value);
                    });
                  },
                ),
              ),
            ),
            const VerticalDivider(width: 8.0),
            Expanded(
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  child: const Text(
                    "+",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      value = Math.min(max, value + 1000);
                      onValueChanged(value);
                    });
                  },
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}

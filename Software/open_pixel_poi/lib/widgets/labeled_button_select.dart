import 'package:flutter/material.dart';

class LabeledButtonSelect extends StatefulWidget {
  final String title;
  final int min, max;
  final int? initial;
  final Function(int) onValueChanged;

  const LabeledButtonSelect(
    this.title,
    this.min,
    this.max,
    this.onValueChanged, [
    this.initial,
    Key? key,
  ]) : super(key: key);

  @override
  State<LabeledButtonSelect> createState() => _LabeledButtonSelectState();
}

class _LabeledButtonSelectState extends State<LabeledButtonSelect> {
  static const List<int> _steps = [-1000, -100, -10, -1, 1, 10, 100, 1000];

  late int value = widget.initial ?? widget.min;

  // Bigger steps get taller buttons: 30 for 1, up to 60 for 1000.
  double _heightFor(int step) => 20.0 + step.abs().toString().length * 10.0;

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
        subtitle: Row(
          children: [
            for (final (index, step) in _steps.indexed) ...[
              if (index != 0) const VerticalDivider(width: 8.0),
              Expanded(
                child: SizedBox(
                  height: _heightFor(step),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        value = (value + step).clamp(widget.min, widget.max);
                        widget.onValueChanged(value);
                      });
                    },
                    child: Text(
                      step < 0 ? "-" : "+",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: .bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

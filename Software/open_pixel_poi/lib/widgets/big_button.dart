import 'package:flutter/material.dart';

/// Full width, 60 pixels tall button with the app's large bold label style.
///
/// A [child] can be passed to replace the label, for example with a progress
/// indicator or a differently styled text.
class BigButton extends StatelessWidget {
  static const double height = 60;

  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget? child;

  const BigButton(
    this.label, {
    required this.onPressed,
    this.onLongPress,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        child:
            child ??
            Text(
              label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: .bold,
              ),
            ),
      ),
    );
  }
}

/// Evenly spaced row of buttons separated by thin dividers, as used at the
/// bottom of the pattern creator pages.
class BigButtonRow extends StatelessWidget {
  final List<Widget> buttons;

  const BigButtonRow({required this.buttons, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: BigButton.height,
        child: Row(
          crossAxisAlignment: .stretch,
          children: [
            for (final (index, button) in buttons.indexed) ...[
              if (index != 0) const VerticalDivider(width: 8.0),
              Expanded(child: button),
            ],
          ],
        ),
      ),
    );
  }
}

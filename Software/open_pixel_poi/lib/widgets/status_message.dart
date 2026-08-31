import 'package:flutter/material.dart';

/// Centered status panel with a title and optionally a subtitle or a
/// progress indicator.
class StatusMessage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showProgress;

  const StatusMessage({
    required this.title,
    this.subtitle,
    this.showProgress = false,
    super.key,
  });

  const StatusMessage.saving({super.key})
    : title = "Saving...",
      subtitle = null,
      showProgress = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: .min,
          children: [
            Text(
              title,
              textAlign: .center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: .bold,
              ),
            ),
            const SizedBox(height: 30),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 18),
              ),
            if (showProgress) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

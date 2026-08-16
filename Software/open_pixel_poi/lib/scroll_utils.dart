import 'package:flutter/material.dart';

extension ScrollToBottom on ScrollController {
  /// Smoothly scrolls to the bottom once the current frame has been built,
  /// so that a newly added list item is in view.
  void animateToBottomAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}

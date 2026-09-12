import 'dart:typed_data';

import 'package:flutter/material.dart';

class PatternPreviewImage extends StatelessWidget {
  final Uint8List bytes;

  const PatternPreviewImage({required this.bytes, super.key});

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      bytes,
      alignment: Alignment.topLeft,
      fit: BoxFit.fitHeight,
    );
  }
}

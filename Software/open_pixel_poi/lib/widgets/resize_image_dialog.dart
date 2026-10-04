import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../database/db_image.dart';

/// Asks the user which height a too large image should be scaled down to and
/// pops with the resized image, or null when cancelled.
class ResizeImageDialog extends StatefulWidget {
  final img.Image image;

  const ResizeImageDialog({required this.image, super.key});

  static int widthFor(img.Image image, int height) {
    return max(1, (image.width * height / image.height).round());
  }

  static bool fits(img.Image image, int height) {
    return height * widthFor(image, height) <= DBImage.maxPixels;
  }

  static int maxHeightFor(img.Image image) {
    var height = min(image.height, DBImage.maxHeight);
    while (height > 1 && !fits(image, height)) {
      height--;
    }
    return height;
  }

  @override
  State<ResizeImageDialog> createState() => _ResizeImageDialogState();
}

class _ResizeImageDialogState extends State<ResizeImageDialog> {
  late final int maxHeight = ResizeImageDialog.maxHeightFor(widget.image);
  late int height = maxHeight;
  late img.Image resized = _resize(height);

  img.Image _resize(int height) {
    return img.copyResize(
      widget.image,
      width: ResizeImageDialog.widthFor(widget.image, height),
      height: height,
      interpolation: img.Interpolation.average,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = ResizeImageDialog.widthFor(widget.image, height);
    return AlertDialog(
      title: const Text("Image too large"),
      content: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(
            "The poi can hold at most ${DBImage.maxPixels} pixels per pattern, "
            "but this image is ${widget.image.width}x${widget.image.height}.\n\n"
            "Pick the height (pixel count) to scale it down to.",
          ),
          const SizedBox(height: 16),
          _ResizePreview(image: resized),
          const SizedBox(height: 16),
          Text(
            "Height: $height ($width x $height = ${width * height} pixels)",
            style: const TextStyle(color: Colors.blue),
          ),
          Slider(
            value: height.toDouble(),
            min: 1,
            max: maxHeight.toDouble(),
            divisions: max(1, maxHeight - 1),
            onChanged: (value) => setState(() => height = value.round()),
            onChangeEnd: (value) => setState(() => resized = _resize(value.round())),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            resized.height == height ? resized : _resize(height),
          ),
          child: const Text("Resize"),
        ),
      ],
    );
  }
}

class _ResizePreview extends StatelessWidget {
  final img.Image image;

  const _ResizePreview({required this.image});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: double.maxFinite,
      child: Image.memory(
        img.encodePng(image),
        fit: .contain,
        filterQuality: .none,
        gaplessPlayback: true,
      ),
    );
  }
}

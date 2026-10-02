import 'package:flutter/material.dart';

import '../database/pattern_db.dart';
import 'big_button.dart';
import 'pattern_picker.dart';

/// Lets the user pick the stored image that a pattern creator transforms,
/// with Cancel and Save buttons underneath.
///
/// Any [settings] are shown above the image picker.
class SourceImageSelector extends StatelessWidget {
  final PatternEntry? image;
  final ValueChanged<PatternEntry> onImageSelected;
  final ValueChanged<PatternEntry> onDefaultImageAssigned;
  final String tooFewImagesMessage;
  final VoidCallback onSave;
  final List<Widget> settings;

  const SourceImageSelector({
    required this.image,
    required this.onImageSelected,
    required this.onDefaultImageAssigned,
    required this.tooFewImagesMessage,
    required this.onSave,
    this.settings = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...settings,
        PatternPicker(
          label: "Image",
          selected: image,
          onSelected: onImageSelected,
          onDefaultAssigned: onDefaultImageAssigned,
          tooFewImagesMessage: tooFewImagesMessage,
        ),
        BigButtonRow(
          buttons: [
            BigButton("Cancel", onPressed: () => Navigator.pop(context)),
            BigButton("Save", onPressed: onSave),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_blur.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_check.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_fade.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_merge.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_rotate.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_sequence.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_strobe.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_text.dart';

import '../widgets/big_button.dart';
import '../widgets/connection_state_indicator.dart';
import 'pattern_creators/create_solid_color.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Custom Pattern"),
        actions: const [ConnectionStateIndicators()],
      ),
      body: ListView(
        children: [
          _CreatorButton("Solid Color", () => CreateSolidColorPage()),
          _CreatorButton("Check", () => CreateCheckPage()),
          _CreatorButton("Fade", () => CreateFadePage()),
          _CreatorButton("Strobe", () => CreateStrobePage()),
          _CreatorButton("Text", () => CreateTextPage()),
          _CreatorButton("Rotate", () => CreateRotatePage()),
          _CreatorButton("Blur", () => CreateBlurPage()),
          _CreatorButton("Layer", () => CreateMergePage()),
          _CreatorButton("Sequencer Controller", () => CreateSequencePage()),
        ],
      ),
    );
  }
}

/// Opens the given pattern creator page and pops this page too once a
/// pattern has been saved.
class _CreatorButton extends StatelessWidget {
  final String label;
  final Widget Function() pageBuilder;

  const _CreatorButton(this.label, this.pageBuilder);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BigButton(
        label,
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return pageBuilder();
              },
            ),
          );
          if (result != null && result && context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

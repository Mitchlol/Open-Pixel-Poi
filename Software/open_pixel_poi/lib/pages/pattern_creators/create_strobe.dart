import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/db_image.dart';
import '../../hardware/models/rgb_value.dart';
import '../../model.dart';
import '../../widgets/color_picker.dart';
import '../../widgets/connection_state_indicator.dart';
import '../../scroll_utils.dart';
import '../../widgets/big_button.dart';
import '../../widgets/status_message.dart';
import '../../widgets/labeled_slider.dart';

class CreateStrobePage extends StatefulWidget {
  const CreateStrobePage({super.key});

  @override
  State<CreateStrobePage> createState() => _CreateStrobeState();
}

class SegmentValues {
  int width = 10;
  late RgbValue color;
}

class _CreateStrobeState extends State<CreateStrobePage> {
  bool flagFirst = true;
  List<SegmentValues> segmentValues = [];
  bool saving = false;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (flagFirst) {
      flagFirst = false;
      addSegment();
      addSegment();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Strobe Pattern Creator"),
        actions: const [ConnectionStateIndicators()],
      ),
      body: saving
          ? const StatusMessage.saving()
          : _StrobeSegmentList(
              segments: segmentValues,
              scrollController: _scrollController,
              onSegmentChanged: () => setState(() {}),
              onAddSegment: () {
                setState(() {
                  addSegment();
                });
                _scrollController.animateToBottomAfterBuild();
              },
              onSave: _save,
            ),
    );
  }

  Future<void> _save() async {
    saving = true;
    bool success = await makeAndStorePattern(context);
    if (success && mounted) {
      Navigator.pop(context, true);
    }
    saving = false;
  }

  void addSegment() {
    var random = Random();
    RgbValue color = RgbValue([
      random.nextInt(2) * 255,
      random.nextInt(2) * 255,
      random.nextInt(2) * 255,
    ]);
    segmentValues.add(SegmentValues());
    segmentValues.last.color = color;
  }

  Future<bool> makeAndStorePattern(BuildContext context) async {
    int width = segmentValues.fold(0, (sum, next) => sum + next.width);
    if (width > 400) {
      const snackBar = SnackBar(
        content: Text(
          'Patten too wide. Sum of segment lengths must 400 or less.',
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }

    var rgbList = Uint8List(width * 3);
    var rgbOffset = 0;
    for (int segment = 0; segment < segmentValues.length; segment++) {
      if (segment != 0) {
        rgbOffset += segmentValues[segment - 1].width * 3;
      }
      for (int i = 0; i < segmentValues[segment].width; i += 1) {
        rgbList[rgbOffset + (i * 3) + 0] = segmentValues[segment].color.red;
        rgbList[rgbOffset + (i * 3) + 1] = segmentValues[segment].color.green;
        rgbList[rgbOffset + (i * 3) + 2] = segmentValues[segment].color.blue;
      }
    }
    var pattern = DBImage(
      id: null,
      height: 1,
      count: width,
      bytes: rgbList,
    );

    var model = Provider.of<Model>(context, listen: false);
    await model.patternDB.insertImage(pattern);
    return true;
  }
}

class _StrobeSegmentList extends StatelessWidget {
  final List<SegmentValues> segments;
  final ScrollController scrollController;
  final VoidCallback onSegmentChanged;
  final VoidCallback onAddSegment;
  final VoidCallback onSave;

  const _StrobeSegmentList({
    required this.segments,
    required this.scrollController,
    required this.onSegmentChanged,
    required this.onAddSegment,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: segments.length,
            itemBuilder: (context, index) => _StrobeSegmentCard(
              number: index + 1,
              segment: segments[index],
              onChanged: onSegmentChanged,
            ),
          ),
        ),
        BigButtonRow(
          buttons: [
            BigButton("Cancel", onPressed: () => Navigator.pop(context)),
            BigButton("+ Color", onPressed: onAddSegment),
            BigButton("Save", onPressed: onSave),
          ],
        ),
      ],
    );
  }
}

class _StrobeSegmentCard extends StatelessWidget {
  final int number;
  final SegmentValues segment;
  final VoidCallback onChanged;

  const _StrobeSegmentCard({
    required this.number,
    required this.segment,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Strobe Segment: $number",
              style: const TextStyle(fontSize: 24, color: Colors.blue),
            ),
          ),
          LabeledSlider(
            "Segment Length",
            1,
            100,
            1,
            (int value) {
              segment.width = value;
              onChanged();
            },
            segment.width,
          ),
          ColorPicker(
            "Segment Color",
            segment.color.red.toDouble(),
            segment.color.green.toDouble(),
            segment.color.blue.toDouble(),
            (RgbValue color) => segment.color = color,
          ),
        ],
      ),
    );
  }
}

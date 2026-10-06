import 'package:flutter/material.dart';
import 'package:open_pixel_poi/widgets/labeled_button_select.dart';
import 'package:provider/provider.dart';

import '../../model.dart';
import '../../widgets/connection_state_indicator.dart';
import '../../scroll_utils.dart';
import '../../widgets/big_button.dart';
import '../../widgets/status_message.dart';
import '../../widgets/labeled_slider.dart';

class CreateSequencePage extends StatefulWidget {
  const CreateSequencePage({super.key});

  @override
  State<CreateSequencePage> createState() => _CreateSequenceState();
}

class SegmentValues {
  int bank = 1;
  int pattern = 1;
  int brightness = 25;
  int speed = 500;
  int duration = 1000;
  @override
  String toString() {
    return "Segment{bank: $bank, pattern: $pattern, brightness: $brightness, speed: $speed, duration: $duration}";
  }
}

const _sequenceButtonStyle = TextStyle(fontSize: 20, fontWeight: .bold);

class _CreateSequenceState extends State<CreateSequencePage> {
  List<SegmentValues> segments = [];
  bool saving = false;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sequencer Controller"),
        actions: const [ConnectionStateIndicators()],
      ),
      body: saving
          ? const StatusMessage.saving()
          : _SequenceActionList(
              segments: segments,
              scrollController: _scrollController,
              onSegmentChanged: () => setState(() {}),
              onSegmentRemoved: (index) => setState(() {
                segments.removeAt(index);
              }),
              onAddSegment: _addSegmentIfRoom,
              onTrigger: () => triggerSequence(context),
              onSave: () async {
                setState(() {
                  saving = true;
                });
                await setSequence(context);
                setState(() {
                  saving = false;
                });
              },
            ),
    );
  }

  void _addSegmentIfRoom() {
    if (segments.length < 70) {
      setState(() {
        addSegment();
      });
      _scrollController.animateToBottomAfterBuild();
    } else {
      const snackBar = SnackBar(
        content: Text(
          'Sequence length limited to 70. If this bothers you, ask mitch to implement multi-part ble messages for sequences.',
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void addSegment() {
    segments.add(SegmentValues());
    if (segments.length > 1) {
      var last = segments[segments.length - 2];
      segments.last.bank = last.bank;
      segments.last.pattern = last.pattern;
      segments.last.brightness = last.brightness;
      segments.last.speed = last.speed;
      segments.last.duration = last.duration;
    }
  }

  Future<void> triggerSequence(BuildContext context) async {
    for (var poi in Provider.of<Model>(context, listen: false).connectedPoi!) {
      poi.sendCommCode(.CC_START_SEQUENCER, false);
    }
  }

  Future<bool> setSequence(BuildContext context) async {
    final connectedPoi = Provider.of<Model>(
      context,
      listen: false,
    ).connectedPoi!;
    for (var poi in connectedPoi) {
      if (context.mounted) {
        await poi.sendSequence(segments);
      }
    }
    return true;
  }
}

class _SequenceActionList extends StatelessWidget {
  final List<SegmentValues> segments;
  final ScrollController scrollController;
  final VoidCallback onSegmentChanged;
  final ValueChanged<int> onSegmentRemoved;
  final VoidCallback onAddSegment;
  final VoidCallback onTrigger;
  final VoidCallback onSave;

  const _SequenceActionList({
    required this.segments,
    required this.scrollController,
    required this.onSegmentChanged,
    required this.onSegmentRemoved,
    required this.onAddSegment,
    required this.onTrigger,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (segments.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Add a segment to start creating a sequence, or upload a blank sequence to clear your Poi.",
              style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: segments.length,
            itemBuilder: (context, index) => _SequenceActionCard(
              key: ObjectKey(segments[index]),
              number: index + 1,
              segment: segments[index],
              onChanged: onSegmentChanged,
              onRemoved: () => onSegmentRemoved(index),
            ),
          ),
        ),
        BigButtonRow(
          buttons: [
            BigButton(
              "Add Seg",
              onPressed: onAddSegment,
              child: const Text("Add Seg", style: _sequenceButtonStyle),
            ),
            BigButton(
              "Trigger",
              onPressed: onTrigger,
              child: const Text("Trigger", style: _sequenceButtonStyle),
            ),
            BigButton(
              "Save",
              onPressed: onSave,
              child: const Text("Save", style: _sequenceButtonStyle),
            ),
          ],
        ),
      ],
    );
  }
}

class _SequenceActionCard extends StatelessWidget {
  final int number;
  final SegmentValues segment;
  final VoidCallback onChanged;
  final VoidCallback onRemoved;

  const _SequenceActionCard({
    required this.number,
    required this.segment,
    required this.onChanged,
    required this.onRemoved,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Column(
        children: [
          ListTile(
            title: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  "Action: $number",
                  style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.primary),
                ),
                IconButton(
                  onPressed: onRemoved,
                  icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
          LabeledSlider(
            "Pattern Bank",
            1,
            3,
            1,
            (int value) {
              segment.bank = value;
              onChanged();
            },
            segment.bank,
          ),
          LabeledSlider(
            "Pattern",
            1,
            5,
            1,
            (int value) {
              segment.pattern = value;
              onChanged();
            },
            segment.pattern,
          ),
          LabeledSlider(
            "Brightness",
            1,
            100,
            1,
            (int value) {
              segment.brightness = value;
              onChanged();
            },
            segment.brightness,
          ),
          LabeledButtonSelect(
            "Speed",
            1,
            2000,
            (int value) {
              segment.speed = value;
              onChanged();
            },
            segment.speed,
          ),
          LabeledButtonSelect(
            "Duration (milliseconds)",
            1,
            20000,
            (int value) {
              segment.duration = value;
              onChanged();
            },
            segment.duration,
          ),
        ],
      ),
    );
  }
}

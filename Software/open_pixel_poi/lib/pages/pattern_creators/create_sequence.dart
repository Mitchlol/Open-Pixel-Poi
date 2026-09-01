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
      body: saving ? const StatusMessage.saving() : getForm(),
    );
  }

  Widget getForm() {
    return Column(
      children: [
        if (segments.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Add a segment to start creating a sequence, or upload a blank sequence to clear your Poi.",
              style: TextStyle(
                fontSize: 24,
                color: Colors.blue,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: segments.length, // Total number of items in the list
            itemBuilder: (context, index) {
              // Build each item in the list
              return Card(
                key: ObjectKey(segments[index]),
                elevation: 5,
                child: Column(
                  children: [
                    ListTile(
                      title: Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Text(
                            "Action: ${index + 1}",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.blue,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                segments.removeAt(index);
                              });
                            },
                            icon: Icon(Icons.close, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    LabeledSlider(
                      "Pattern Bank",
                      1,
                      3,
                      1,
                      (int value) => setState(() {
                        segments[index].bank = value;
                      }),
                      segments[index].bank,
                    ),
                    LabeledSlider(
                      "Pattern",
                      1,
                      5,
                      1,
                      (int value) => setState(() {
                        segments[index].pattern = value;
                      }),
                      segments[index].pattern,
                    ),
                    LabeledSlider(
                      "Brightness",
                      1,
                      100,
                      1,
                      (int value) => setState(() {
                        segments[index].brightness = value;
                      }),
                      segments[index].brightness,
                    ),
                    LabeledButtonSelect(
                      "Speed",
                      1,
                      2000,
                      (int value) => setState(() {
                        segments[index].speed = value;
                      }),
                      segments[index].speed,
                    ),
                    LabeledButtonSelect(
                      "Duration (milliseconds)",
                      1,
                      20000,
                      (int value) => setState(() {
                        segments[index].duration = value;
                      }),
                      segments[index].duration,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        BigButtonRow(
          buttons: [
            BigButton(
              "Add Seg",
              child: const Text("Add Seg", style: _sequenceButtonStyle),
              onPressed: () {
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
              },
            ),
            BigButton(
              "Trigger",
              child: const Text("Trigger", style: _sequenceButtonStyle),
              onPressed: () {
                triggerSequence(context);
              },
            ),
            BigButton(
              "Save",
              child: const Text("Save", style: _sequenceButtonStyle),
              onPressed: () async {
                setState(() {
                  saving = true;
                });
                await setSequence(context);
                setState(() {
                  saving = false;
                });
              },
            ),
          ],
        ),
      ],
    );
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

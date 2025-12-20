import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_pixel_poi/widgets/labeled_button_select.dart';
import 'package:provider/provider.dart';

import '../../database/dbimage.dart';
import '../../hardware/models/comm_code.dart';
import '../../hardware/models/rgb_value.dart';
import '../../model.dart';
import '../../widgets/color_picker.dart';
import '../../widgets/connection_state_indicator.dart';
import '../../widgets/labeled_slider.dart';


class CreateSequencePage extends StatefulWidget {
  const CreateSequencePage({super.key});

  @override
  _CreateSequenceState createState() => _CreateSequenceState();
}

class SegmentValues{
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

class _CreateSequenceState extends State<CreateSequencePage> {
  List<SegmentValues> segments = [];
  bool saving = false;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sequencer Controller"),
        actions: [
          ...Provider.of<Model>(context)
              .connectedPoi!
              .map((e) => ConnectionStateIndicator(Provider.of<Model>(context).connectedPoi!.indexOf(e)))
        ],
      ),
      body: saving ? getSaving() : getForm(),
    );
  }

  Widget getForm() {
    return Column(
      children: [
        if (segments.isEmpty) Padding(
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
                elevation: 5,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        "Sequence Segment: ${index+1}",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.blue,
                        ),
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
                      1,
                      (int value) => setState(() {
                        segments[index].speed = value;
                      }),
                      segments[index].speed,
                    ),
                    LabeledButtonSelect(
                      "Duration (milliseconds)",
                      1,
                      20000,
                      1,
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if(segments.length < 70){
                        setState(() {
                          addSegment();
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent, // Scroll to the bottom
                            duration: Duration(milliseconds: 300), // Duration of the animation
                            curve: Curves.easeOut, // Smooth easing curve
                          );
                        });
                      }else{
                        const snackBar = SnackBar(content: Text('Sequence length limited to 70. If this bothers you, ask mitch to implement multi-part ble messages for sequences.'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }

                    },
                    child: const Text(
                      "Add Seg",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      triggerSequence(context);
                    },
                    child: const Text(
                      "Trigger",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        saving = true;
                      });
                      bool success = await setSequence(context);
                      setState(() {
                        saving = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget getSaving() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Saving...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void addSegment(){
    segments.add(SegmentValues());
    if(segments.length > 1) {
      var last = segments[segments.length - 2];
      segments.last.bank = last.bank;
      segments.last.pattern = last.pattern;
      segments.last.brightness = last.brightness;
      segments.last.speed = last.speed;
      segments.last.duration = last.duration;
    }
  }

  Future<void> triggerSequence(BuildContext context) async {
    Provider.of<Model>(context, listen: false)
        .connectedPoi!
        .forEach((poi) => poi.sendCommCode(CommCode.CC_START_SEQUENCER, false));
  }

  Future<bool> setSequence(BuildContext context) async{
    for (var poi in Provider.of<Model>(context, listen: false).connectedPoi!) {
      if (context.mounted) {
        await poi.sendSequence(segments);
      }
    }
    return true;
  }
}
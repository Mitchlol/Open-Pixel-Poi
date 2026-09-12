import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/db_image.dart';
import '../../hardware/models/rgb_value.dart';
import '../../model.dart';
import '../../widgets/color_picker.dart';
import '../../widgets/connection_state_indicator.dart';
import '../../widgets/labeled_slider.dart';


class CreateStrobePage extends StatefulWidget {
  const CreateStrobePage({super.key});

  @override
  _CreateStrobeState createState() => _CreateStrobeState();
}

class SegmentValues{
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
    if(flagFirst){
      flagFirst = false;
      addSegment();
      addSegment();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Strobe Pattern Creator"),
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
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: segmentValues.length, // Total number of items in the list
            itemBuilder: (context, index) {
              // Build each item in the list
              return Card(
                elevation: 5,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        "Strobe Segment: ${index+1}",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    LabeledSlider(
                      "Segment Length",
                      1,
                      100,
                      1,
                      (int value) => setState(() {
                        segmentValues[index].width = value;
                      }),
                      segmentValues[index].width,
                    ),
                    ColorPicker(
                      "Segment Color",
                      segmentValues[index].color.red.toDouble(),
                      segmentValues[index].color.green.toDouble(),
                      segmentValues[index].color.blue.toDouble(),
                      (RgbValue color) => segmentValues[index].color = color,
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
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
                    },
                    child: const Text(
                      "+ Color",
                      style: TextStyle(
                        fontSize: 24,
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      saving = true;
                      bool success = await makeAndStorePattern(context);
                      if(success && context.mounted) { // Do we actually want this check?
                        Navigator.pop(context, true);
                      }
                      saving = false;
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
    var random = Random();
    RgbValue color = RgbValue([random.nextInt(2) * 255, random.nextInt(2) * 255, random.nextInt(2) * 255]);
    segmentValues.add(SegmentValues());
    segmentValues.last.color = color;
  }

  Future<bool> makeAndStorePattern(BuildContext context) async{
    int width = segmentValues.fold(0, (sum, next) => sum + next.width);
    if(width > 400){
      const snackBar = SnackBar(content: Text('Patten too wide. Sum of segment lengths must 400 or less.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }

    var rgbList = Uint8List(width * 3);
    var rgbOffset = 0;
    for(int segment = 0; segment < segmentValues.length; segment++){
      if(segment != 0) {
        rgbOffset += segmentValues[segment-1].width * 3;
      }
      for(int i = 0; i < segmentValues[segment].width; i += 1){
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
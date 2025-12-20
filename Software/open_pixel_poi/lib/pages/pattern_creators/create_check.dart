import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_pixel_poi/widgets/labeled_slider.dart';
import 'package:provider/provider.dart';

import '../../database/dbimage.dart';
import '../../hardware/models/rgb_value.dart';
import '../../model.dart';
import '../../widgets/color_picker.dart';
import '../../widgets/connection_state_indicator.dart';


class CreateCheckPage extends StatefulWidget {
  const CreateCheckPage({super.key});

  @override
  _CreateCheckState createState() => _CreateCheckState();
}

class _CreateCheckState extends State<CreateCheckPage> {
  bool flagFirst = true;
  late int gridSize = 1;
  late RGBValue colorOne;
  late RGBValue colorTwo;
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    if(flagFirst){
      flagFirst = false;
      var random = Random();
      colorOne = RGBValue([random.nextInt(256), random.nextInt(256), random.nextInt(256)]);
      colorTwo = RGBValue([0, 0, 0]);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check Pattern Creator"),
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
    return ListView(
      children: [
        LabeledSlider(
            "Check size",
            1,
            55,
            1,
                (int value) => setState(() {
                  gridSize = value;
                }),
        ),
        ColorPicker(
          "Primary Color",
          colorOne.red.toDouble(),
          colorOne.green.toDouble(),
          colorOne.blue.toDouble(),
              (RGBValue color) => colorOne = color,
        ),
        ColorPicker(
          "Other Color",
          colorTwo.red.toDouble(),
          colorTwo.green.toDouble(),
          colorTwo.blue.toDouble(),
              (RGBValue color) => colorTwo = color,
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
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      saving = true;
                      await makeAndStorePattern(context);
                      if(context.mounted) { // Do we actually want this check?
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

  Future<void> makeAndStorePattern(BuildContext context) async{
    var rgbList = Uint8List(((gridSize * 2) * (gridSize * 2)) * 3);
    for(int column = 0; column < gridSize * 2; column++){
      for(int row = 0; row < gridSize * 2; row++){
        var pixelOffset = (column * (gridSize * 2)) + row;
        var rgbOffset = pixelOffset * 3;
        if((column < gridSize && row < gridSize) || (column >= gridSize && row >= gridSize)){
          rgbList[rgbOffset] = colorOne.red;
          rgbList[rgbOffset + 1] = colorOne.green;
          rgbList[rgbOffset + 2] = colorOne.blue;
        }else{
          rgbList[rgbOffset] = colorTwo.red;
          rgbList[rgbOffset + 1] = colorTwo.green;
          rgbList[rgbOffset + 2] = colorTwo.blue;
        }
      }
    }

    var pattern = DBImage(
      id: null,
      height: gridSize * 2,
      count: gridSize * 2,
      bytes: rgbList,
    );

    var model = Provider.of<Model>(context, listen: false);
    await model.patternDB.insertImage(pattern);
  }
}
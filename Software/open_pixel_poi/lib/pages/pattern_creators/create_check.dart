import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_pixel_poi/widgets/labeled_slider.dart';
import 'package:provider/provider.dart';

import '../../database/db_image.dart';
import '../../hardware/models/rgb_value.dart';
import '../../model.dart';
import '../../widgets/color_picker.dart';
import '../../widgets/connection_state_indicator.dart';
import '../../widgets/big_button.dart';
import '../../widgets/status_message.dart';

class CreateCheckPage extends StatefulWidget {
  const CreateCheckPage({super.key});

  @override
  State<CreateCheckPage> createState() => _CreateCheckState();
}

class _CreateCheckState extends State<CreateCheckPage> {
  bool flagFirst = true;
  late int gridSize = 1;
  late RgbValue colorOne;
  late RgbValue colorTwo;
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    if (flagFirst) {
      flagFirst = false;
      var random = Random();
      colorOne = RgbValue([
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      ]);
      colorTwo = RgbValue([0, 0, 0]);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check Pattern Creator"),
        actions: const [ConnectionStateIndicators()],
      ),
      body: saving ? const StatusMessage.saving() : getForm(),
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
          (RgbValue color) => colorOne = color,
        ),
        ColorPicker(
          "Other Color",
          colorTwo.red.toDouble(),
          colorTwo.green.toDouble(),
          colorTwo.blue.toDouble(),
          (RgbValue color) => colorTwo = color,
        ),
        BigButtonRow(
          buttons: [
            BigButton("Cancel", onPressed: () => Navigator.pop(context)),
            BigButton(
              "Save",
              onPressed: () async {
                saving = true;
                await makeAndStorePattern(context);
                if (mounted) {
                  Navigator.pop(context, true);
                }
                saving = false;
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> makeAndStorePattern(BuildContext context) async {
    var rgbList = Uint8List(((gridSize * 2) * (gridSize * 2)) * 3);
    for (int column = 0; column < gridSize * 2; column++) {
      for (int row = 0; row < gridSize * 2; row++) {
        var pixelOffset = (column * (gridSize * 2)) + row;
        var rgbOffset = pixelOffset * 3;
        if ((column < gridSize && row < gridSize) ||
            (column >= gridSize && row >= gridSize)) {
          rgbList[rgbOffset] = colorOne.red;
          rgbList[rgbOffset + 1] = colorOne.green;
          rgbList[rgbOffset + 2] = colorOne.blue;
        } else {
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

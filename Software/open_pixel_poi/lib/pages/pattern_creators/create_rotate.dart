import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/db_image.dart';
import '../../database/pattern_db.dart';
import '../../model.dart';
import '../../widgets/connection_state_indicator.dart';
import '../../widgets/pattern_picker.dart';
import '../../widgets/big_button.dart';
import '../../widgets/status_message.dart';
import '../../widgets/labeled_slider.dart';

class CreateRotatePage extends StatefulWidget {
  const CreateRotatePage({super.key});

  @override
  State<CreateRotatePage> createState() => _CreateRotateState();
}

class _CreateRotateState extends State<CreateRotatePage> {
  bool saving = false;
  int outputImageHeightLimit = 25;
  PatternEntry? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rotate image 90 degrees"),
        actions: const [ConnectionStateIndicators()],
      ),
      body: saving ? const StatusMessage.saving() : getForm(),
    );
  }

  Widget getForm() {
    return ListView(
      children: [
        LabeledSlider(
          "Rotated Image Height Limit",
          1,
          100,
          1,
          (int value) => setState(() {
            outputImageHeightLimit = value;
          }),
          25,
        ),
        PatternPicker(
          label: "Image",
          selected: image,
          onSelected: (entry) => setState(() => image = entry),
          onDefaultAssigned: (entry) => image = entry,
          tooFewImagesMessage:
              'You must have at least 1 image stored to rotate.',
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
    var model = Provider.of<Model>(context, listen: false);

    int desiredWidth = max(2, image!.dbImage.height);
    int desiredHeight = min(outputImageHeightLimit, image!.dbImage.count);
    var imgImage = (await model.patternDB.getImgImages([image!.dbImage]))[0];
    var rgbList = Uint8List((desiredWidth * desiredHeight) * 3);

    for (var column = 0; column < desiredWidth; column++) {
      for (var row = 0; row < desiredHeight; row++) {
        var columnOffset = column * desiredHeight * 3;
        var rowOffset = row * 3;
        var pixel = imgImage.getPixel(row, column % image!.dbImage.height);
        rgbList[columnOffset + rowOffset + 0] = pixel.r.toInt();
        rgbList[columnOffset + rowOffset + 1] = pixel.g.toInt();
        rgbList[columnOffset + rowOffset + 2] = pixel.b.toInt();
      }
    }
    var pattern = DBImage(
      id: null,
      height: desiredHeight,
      count: desiredWidth,
      bytes: rgbList,
    );
    await model.patternDB.insertImage(pattern);
  }
}

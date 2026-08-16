import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:provider/provider.dart';

import '../../database/db_image.dart';
import '../../database/pattern_db.dart';
import '../../model.dart';
import '../../widgets/connection_state_indicator.dart';
import '../../widgets/pattern_picker.dart';
import '../../widgets/big_button.dart';
import '../../widgets/status_message.dart';

class CreateBlurPage extends StatefulWidget {
  const CreateBlurPage({super.key});

  @override
  State<CreateBlurPage> createState() => _CreateBlurState();
}

class _CreateBlurState extends State<CreateBlurPage> {
  bool saving = false;
  PatternEntry? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blur image"),
        actions: const [ConnectionStateIndicators()],
      ),
      body: saving ? const StatusMessage.saving() : getForm(),
    );
  }

  Widget getForm() {
    return ListView(
      children: [
        PatternPicker(
          label: "Image",
          selected: image,
          onSelected: (entry) => setState(() => image = entry),
          onDefaultAssigned: (entry) => image = entry,
          tooFewImagesMessage: 'You must have at least 1 image stored to blur.',
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

    int desiredWidth = image!.dbImage.count;
    int desiredHeight = image!.dbImage.height;
    var imgImage = (await model.patternDB.getImgImages([image!.dbImage]))[0];
    var rgbList = Uint8List((desiredWidth * desiredHeight) * 3);

    for (var column = 0; column < desiredWidth; column++) {
      for (var row = 0; row < desiredHeight; row++) {
        var columnOffset = column * desiredHeight * 3;
        var rowOffset = row * 3;

        var pixel1 = row == 0
            ? ColorRgb8(0, 0, 0)
            : imgImage.getPixel(
                (column - 1) % image!.dbImage.count,
                (row - 1) % image!.dbImage.height,
              );
        var pixel2 = imgImage.getPixel(
          (column - 1) % image!.dbImage.count,
          (row) % image!.dbImage.height,
        );
        var pixel3 = row == desiredHeight - 1
            ? ColorRgb8(0, 0, 0)
            : imgImage.getPixel(
                (column - 1) % image!.dbImage.count,
                (row + 1) % image!.dbImage.height,
              );
        var pixel4 = row == 0
            ? ColorRgb8(0, 0, 0)
            : imgImage.getPixel(
                (column) % image!.dbImage.count,
                (row - 1) % image!.dbImage.height,
              );
        var pixel5 = imgImage.getPixel(
          (column) % image!.dbImage.count,
          (row) % image!.dbImage.height,
        );
        var pixel6 = row == desiredHeight - 1
            ? ColorRgb8(0, 0, 0)
            : imgImage.getPixel(
                (column) % image!.dbImage.count,
                (row + 1) % image!.dbImage.height,
              );
        var pixel7 = row == 0
            ? ColorRgb8(0, 0, 0)
            : imgImage.getPixel(
                (column + 1) % image!.dbImage.count,
                (row - 1) % image!.dbImage.height,
              );
        var pixel8 = imgImage.getPixel(
          (column + 1) % image!.dbImage.count,
          (row) % image!.dbImage.height,
        );
        var pixel9 = row == desiredHeight - 1
            ? ColorRgb8(0, 0, 0)
            : imgImage.getPixel(
                (column + 1) % image!.dbImage.count,
                (row + 1) % image!.dbImage.height,
              );

        rgbList[columnOffset + rowOffset + 0] =
            ((pixel1.r +
                        pixel2.r +
                        pixel3.r +
                        pixel4.r +
                        pixel5.r +
                        pixel6.r +
                        pixel7.r +
                        pixel8.r +
                        pixel9.r) /
                    9)
                .toInt();
        rgbList[columnOffset + rowOffset + 1] =
            ((pixel1.g +
                        pixel2.g +
                        pixel3.g +
                        pixel4.g +
                        pixel5.g +
                        pixel6.g +
                        pixel7.g +
                        pixel8.g +
                        pixel9.g) /
                    9)
                .toInt();
        rgbList[columnOffset + rowOffset + 2] =
            ((pixel1.b +
                        pixel2.b +
                        pixel3.b +
                        pixel4.b +
                        pixel5.b +
                        pixel6.b +
                        pixel7.b +
                        pixel8.b +
                        pixel9.b) /
                    9)
                .toInt();
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

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

class CreateMergePage extends StatefulWidget {
  const CreateMergePage({super.key});

  @override
  State<CreateMergePage> createState() => _CreateMergeState();
}

class _CreateMergeState extends State<CreateMergePage> {
  bool saving = false;
  PatternEntry? topImage;
  PatternEntry? bottomImage;

  String blendMode = "Normal";
  List<String> blendModes = [
    "Normal",
    "Hard Normal",
    "Lighten",
    "Darken",
    "Add",
    "Multiply",
    "Average",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Merge Two Images"),
        actions: const [ConnectionStateIndicators()],
      ),
      body: saving ? const StatusMessage.saving() : getForm(),
    );
  }

  Widget getForm() {
    return ListView(
      children: [
        PatternPicker(
          label: "Top Image",
          selected: topImage,
          onSelected: (entry) => setState(() => topImage = entry),
          onDefaultAssigned: (entry) => topImage = entry,
          tooFewImagesMessage:
              'You must have at least 2 images stored to make merged image.',
        ),
        PatternPicker(
          label: "Bottom Image",
          selected: bottomImage,
          onSelected: (entry) => setState(() => bottomImage = entry),
          onDefaultAssigned: (entry) => bottomImage = entry,
          defaultIndex: 1,
          tooFewImagesMessage:
              'You must have at least 2 images stored to make merged image.',
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "Blend Mode",
            style: TextStyle(
              fontSize: 20,
              color: Colors.blue,
            ),
          ),
        ),
        ListTile(
          subtitle: DropdownButton<String>(
            isExpanded: true,
            icon: Icon(Icons.arrow_downward, color: Colors.blue),
            value: blendMode,
            items: blendModes.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (item) {
              setState(() {
                blendMode = item ?? blendMode;
              });
            },
          ),
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

    var topWidth = topImage!.dbImage.count;
    var bottomWidth = bottomImage!.dbImage.count;

    // Taller of the 2 images
    int desiredHeight = max(
      topImage!.dbImage.height,
      bottomImage!.dbImage.height,
    );

    // Find least common multiple
    int x = topWidth, y = bottomWidth;
    while (y != 0) {
      int temp = y;
      y = x % y;
      x = temp;
    }
    int gcd = x;
    int lcm = (topWidth * bottomWidth) ~/ gcd;

    int desiredWidth = min(40000 ~/ desiredHeight, lcm);

    var images = await model.patternDB.getImgImages([
      topImage!.dbImage,
      bottomImage!.dbImage,
    ]);
    var rgbList = Uint8List((desiredWidth * desiredHeight) * 3);

    for (var column = 0; column < desiredWidth; column++) {
      for (var row = 0; row < desiredHeight; row++) {
        var columnOffset = column * desiredHeight * 3;
        var rowOffset = row * 3;
        var top = images[0].getPixel(
          column % topWidth,
          row % topImage!.dbImage.height,
        );
        var bottom = images[1].getPixel(
          column % bottomWidth,
          row % bottomImage!.dbImage.height,
        );
        if (blendMode == "Lighten") {
          rgbList[columnOffset + rowOffset + 0] =
              (top.r > bottom.r ? top.r : bottom.r).toInt();
          rgbList[columnOffset + rowOffset + 1] =
              (top.g > bottom.g ? top.g : bottom.g).toInt();
          rgbList[columnOffset + rowOffset + 2] =
              (top.b > bottom.b ? top.b : bottom.b).toInt();
        } else if (blendMode == "Darken") {
          rgbList[columnOffset + rowOffset + 0] =
              (top.r < bottom.r ? top.r : bottom.r).toInt();
          rgbList[columnOffset + rowOffset + 1] =
              (top.g < bottom.g ? top.g : bottom.g).toInt();
          rgbList[columnOffset + rowOffset + 2] =
              (top.b < bottom.b ? top.b : bottom.b).toInt();
        } else if (blendMode == "Hard Normal") {
          if (top.r > 0 || top.g > 0 || top.b > 0) {
            rgbList[columnOffset + rowOffset + 0] = (top.r).toInt();
            rgbList[columnOffset + rowOffset + 1] = (top.g).toInt();
            rgbList[columnOffset + rowOffset + 2] = (top.b).toInt();
          } else {
            rgbList[columnOffset + rowOffset + 0] = (bottom.r).toInt();
            rgbList[columnOffset + rowOffset + 1] = (bottom.g).toInt();
            rgbList[columnOffset + rowOffset + 2] = (bottom.b).toInt();
          }
        } else if (blendMode == "Normal") {
          var topAlpha = max(max(top.r, top.g), top.b) / 255;
          rgbList[columnOffset + rowOffset + 0] =
              ((topAlpha * top.r) + ((1 - topAlpha) * bottom.r)).toInt();
          rgbList[columnOffset + rowOffset + 1] =
              ((topAlpha * top.g) + ((1 - topAlpha) * bottom.g)).toInt();
          rgbList[columnOffset + rowOffset + 2] =
              ((topAlpha * top.b) + ((1 - topAlpha) * bottom.b)).toInt();
        } else if (blendMode == "Add") {
          rgbList[columnOffset + rowOffset + 0] = (min(
            255,
            top.r + bottom.r,
          )).toInt();
          rgbList[columnOffset + rowOffset + 1] = (min(
            255,
            top.g + bottom.g,
          )).toInt();
          rgbList[columnOffset + rowOffset + 2] = (min(
            255,
            top.b + bottom.b,
          )).toInt();
        } else if (blendMode == "Multiply") {
          rgbList[columnOffset + rowOffset + 0] = ((top.r * bottom.r) / 255)
              .toInt();
          rgbList[columnOffset + rowOffset + 1] = ((top.g * bottom.g) / 255)
              .toInt();
          rgbList[columnOffset + rowOffset + 2] = ((top.b * bottom.b) / 255)
              .toInt();
        } else if (blendMode == "Average") {
          rgbList[columnOffset + rowOffset + 0] = ((top.r + bottom.r) / 2)
              .toInt();
          rgbList[columnOffset + rowOffset + 1] = ((top.g + bottom.g) / 2)
              .toInt();
          rgbList[columnOffset + rowOffset + 2] = ((top.b + bottom.b) / 2)
              .toInt();
        }
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

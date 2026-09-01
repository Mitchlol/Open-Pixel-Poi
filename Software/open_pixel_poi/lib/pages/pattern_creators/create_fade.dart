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

class CreateFadePage extends StatefulWidget {
  const CreateFadePage({super.key});

  @override
  State<CreateFadePage> createState() => _CreateFadeState();
}

class _CreateFadeState extends State<CreateFadePage> {
  bool flagFirst = true;
  late int fadeSize = 10;
  List<RgbValue> colors = List<RgbValue>.empty(growable: true);
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
        title: const Text("Fade Pattern Creator"),
        actions: const [ConnectionStateIndicators()],
      ),
      body: saving ? const StatusMessage.saving() : getForm(),
    );
  }

  Widget getForm() {
    return Column(
      children: [
        LabeledSlider(
          "Fade width",
          colors.length * 5,
          (400 / colors.length).toInt() * colors.length,
          colors.length,
          (int value) => setState(() {
            fadeSize = value;
          }),
          colors.length * 5,
          Key("${colors.length}"),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: colors.length,
            itemBuilder: (BuildContext context, int index) {
              return ColorPicker(
                "Color ${index + 1}",
                colors[index].red.toDouble(),
                colors[index].green.toDouble(),
                colors[index].blue.toDouble(),
                (RgbValue color) => colors[index] = color,
              );
            },
          ),
        ),
        BigButtonRow(
          buttons: [
            BigButton("Cancel", onPressed: () => Navigator.pop(context)),
            BigButton(
              "+ Color",
              onPressed: () {
                setState(() {
                  addSegment();
                });
                _scrollController.animateToBottomAfterBuild();
              },
            ),
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

  void addSegment() {
    var random = Random();
    colors.add(
      RgbValue([
        random.nextInt(2) * 255,
        random.nextInt(2) * 255,
        random.nextInt(2) * 255,
      ]),
    );
    fadeSize = colors.length * 5;
  }

  Uint8List createFade(RgbValue start, RgbValue end, width) {
    var rgbList = Uint8List(width * 3);
    int rgbOffset = 0;
    double percent = 0.0;
    for (int pixel = 0; pixel < width; pixel++) {
      rgbOffset = pixel * 3;
      percent = (width - pixel) / width;
      rgbList[rgbOffset] = ((start.red * percent) + (end.red * (1 - percent)))
          .toInt();
      rgbList[rgbOffset + 1] =
          ((start.green * percent) + (end.green * (1 - percent))).toInt();
      rgbList[rgbOffset + 2] =
          ((start.blue * percent) + (end.blue * (1 - percent))).toInt();
    }
    return rgbList;
  }

  Future<void> makeAndStorePattern(BuildContext context) async {
    var rgbList = Uint8List(fadeSize * 3);
    int subwidth = (fadeSize / colors.length).toInt();
    for (int i = 0; i < colors.length; i++) {
      rgbList.setAll(
        i * subwidth * 3,
        createFade(
          colors[i],
          i == (colors.length - 1) ? colors[0] : colors[i + 1],
          subwidth,
        ),
      );
    }
    var pattern = DBImage(
      id: null,
      height: 1,
      count: fadeSize,
      bytes: rgbList,
    );

    var model = Provider.of<Model>(context, listen: false);
    await model.patternDB.insertImage(pattern);
  }
}

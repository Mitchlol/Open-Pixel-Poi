import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/db_image.dart';
import '../../hardware/models/rgb_value.dart';
import '../../model.dart';
import '../../widgets/color_picker.dart';
import '../../widgets/connection_state_indicator.dart';
import '../../widgets/big_button.dart';
import '../../widgets/status_message.dart';

class CreateSolidColorPage extends StatefulWidget {
  const CreateSolidColorPage({super.key});

  @override
  State<CreateSolidColorPage> createState() => _CreateSolidColorState();
}

class _CreateSolidColorState extends State<CreateSolidColorPage> {
  bool flagFirst = true;
  late RgbValue pickedColor;
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    if (flagFirst) {
      flagFirst = false;
      var random = Random();
      pickedColor = RgbValue([
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      ]);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solid Color Pattern Creator"),
        actions: const [ConnectionStateIndicators()],
      ),
      body: saving
          ? const StatusMessage.saving()
          : ListView(
              children: [
                ColorPicker(
                  "Primary Color",
                  pickedColor.red.toDouble(),
                  pickedColor.green.toDouble(),
                  pickedColor.blue.toDouble(),
                  (RgbValue color) {
                    pickedColor = color;
                  },
                ),
                BigButtonRow(
                  buttons: [
                    BigButton(
                      "Cancel",
                      onPressed: () => Navigator.pop(context),
                    ),
                    BigButton(
                      "Save",
                      onPressed: () async {
                        saving = true;
                        await makeAndStorePattern(context);
                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                        saving = false;
                      },
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> makeAndStorePattern(BuildContext context) async {
    var model = Provider.of<Model>(context, listen: false);
    var pattern = DBImage(
      id: null,
      height: 1,
      count: 2, // Two pixel wide is a hack to get around single frame pattern issues for now
      bytes: Uint8List.fromList([
        ...pickedColor.serialize(),
        ...pickedColor.serialize(),
      ]),
    );
    await model.patternDB.insertImage(pattern);
  }
}

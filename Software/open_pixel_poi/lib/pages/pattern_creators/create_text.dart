import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import '../../database/db_image.dart';
import '../../hardware/models/rgb_value.dart';
import '../../model.dart';
import '../../widgets/color_picker.dart';
import '../../widgets/connection_state_indicator.dart';
import '../../widgets/big_button.dart';
import '../../widgets/status_message.dart';

class CreateTextPage extends StatefulWidget {
  const CreateTextPage({super.key});

  @override
  State<CreateTextPage> createState() => _CreateTextState();
}

class _CreateTextState extends State<CreateTextPage> {
  bool flagFirst = true;
  int textHeight = 25;
  String text = "";
  late RgbValue textColor, backgroundColor;
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    if (flagFirst) {
      flagFirst = false;
      var random = Random();
      textColor = RgbValue([
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      ]);
      backgroundColor = RgbValue([0, 0, 0]);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Pattern Creator"),
        actions: const [ConnectionStateIndicators()],
      ),
      body: saving
          ? const StatusMessage.saving()
          : ListView(
              children: [
                ListTile(
                  title: Text(
                    "Text Size:",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue,
                    ),
                  ),
                  subtitle: DropdownButton<int>(
                    isExpanded: true,
                    style: Theme.of(context).textTheme.headlineSmall,
                    value: textHeight,
                    items: [
                      DropdownMenuItem(
                        value: 20,
                        child: Center(child: Text("20px")),
                      ),
                      DropdownMenuItem(
                        value: 25,
                        child: Center(child: Text("25px")),
                      ),
                      DropdownMenuItem(
                        value: 55,
                        child: Center(child: Text("55px")),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        textHeight = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    "Text:",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue,
                    ),
                  ),
                  subtitle: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Your text',
                    ),
                    onChanged: (newValue) => text = newValue,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter(
                        RegExp("[0-9A-Z ]"),
                        allow: true,
                      ),
                    ],
                    maxLength: textHeight == 55 ? 13 : 25,
                  ),
                ),
                ColorPicker(
                  "Text Color",
                  textColor.red.toDouble(),
                  textColor.green.toDouble(),
                  textColor.blue.toDouble(),
                  (RgbValue color) {
                    textColor = color;
                  },
                ),
                ColorPicker(
                  "Background Color",
                  backgroundColor.red.toDouble(),
                  backgroundColor.green.toDouble(),
                  backgroundColor.blue.toDouble(),
                  (RgbValue color) {
                    backgroundColor = color;
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
    final model = Provider.of<Model>(context, listen: false);

    Uint8List fontZipFile;
    int xAdvance;
    if (textHeight == 20) {
      xAdvance = 18;
      fontZipFile = Uint8List.sublistView(
        await rootBundle.load("fonts/max20.zip"),
      );
    } else if (textHeight == 25) {
      xAdvance = 22;
      fontZipFile = Uint8List.sublistView(
        await rootBundle.load("fonts/max25.zip"),
      );
    } else {
      xAdvance = 49;
      fontZipFile = Uint8List.sublistView(
        await rootBundle.load("fonts/max55.zip"),
      );
    }

    int width = (text.length * xAdvance) + (xAdvance * 1.5).toInt();

    final font = img.BitmapFont.fromZip(fontZipFile);
    final image = img.Image(width: width, height: textHeight);
    img.fill(
      image,
      color: img.ColorRgb8(
        backgroundColor.red,
        backgroundColor.green,
        backgroundColor.blue,
      ),
    );
    img.drawString(
      image,
      text,
      font: font,
      x: 0,
      y: 0,
      color: img.ColorRgb8(textColor.red, textColor.green, textColor.blue),
    );

    await model.patternDB.insertImage(DBImage.fromImg(image));
  }
}

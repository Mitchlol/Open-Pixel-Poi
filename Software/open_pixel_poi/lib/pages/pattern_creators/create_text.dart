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
          : _TextAndColorInputs(
              textHeight: textHeight,
              textColor: textColor,
              backgroundColor: backgroundColor,
              onTextHeightChanged: (value) => setState(() {
                textHeight = value;
              }),
              onTextChanged: (value) => text = value,
              onTextColorChanged: (color) => textColor = color,
              onBackgroundColorChanged: (color) => backgroundColor = color,
              onSave: _save,
            ),
    );
  }

  Future<void> _save() async {
    saving = true;
    await makeAndStorePattern(context);
    if (mounted) {
      Navigator.pop(context, true);
    }
    saving = false;
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

class _TextAndColorInputs extends StatelessWidget {
  static const _titleStyle = TextStyle(fontSize: 24, color: Colors.blue);

  final int textHeight;
  final RgbValue textColor;
  final RgbValue backgroundColor;
  final ValueChanged<int> onTextHeightChanged;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<RgbValue> onTextColorChanged;
  final ValueChanged<RgbValue> onBackgroundColorChanged;
  final VoidCallback onSave;

  const _TextAndColorInputs({
    required this.textHeight,
    required this.textColor,
    required this.backgroundColor,
    required this.onTextHeightChanged,
    required this.onTextChanged,
    required this.onTextColorChanged,
    required this.onBackgroundColorChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text("Text Size:", style: _titleStyle),
          subtitle: DropdownButton<int>(
            isExpanded: true,
            style: Theme.of(context).textTheme.headlineSmall,
            value: textHeight,
            items: [
              for (final height in const [20, 25, 55])
                DropdownMenuItem(
                  value: height,
                  child: Center(child: Text("${height}px")),
                ),
            ],
            onChanged: (value) => onTextHeightChanged(value!),
          ),
        ),
        ListTile(
          title: const Text("Text:", style: _titleStyle),
          subtitle: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Your text',
            ),
            onChanged: onTextChanged,
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
          onTextColorChanged,
        ),
        ColorPicker(
          "Background Color",
          backgroundColor.red.toDouble(),
          backgroundColor.green.toDouble(),
          backgroundColor.blue.toDouble(),
          onBackgroundColorChanged,
        ),
        BigButtonRow(
          buttons: [
            BigButton("Cancel", onPressed: () => Navigator.pop(context)),
            BigButton("Save", onPressed: onSave),
          ],
        ),
      ],
    );
  }
}

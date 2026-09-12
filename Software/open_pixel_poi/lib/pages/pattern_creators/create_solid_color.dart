import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/db_image.dart';
import '../../hardware/models/rgb_value.dart';
import '../../model.dart';
import '../../widgets/color_picker.dart';
import '../../widgets/connection_state_indicator.dart';


class CreateSolidColorPage extends StatefulWidget {
  const CreateSolidColorPage({super.key});

  @override
  _CreateSolidColorState createState() => _CreateSolidColorState();
}

class _CreateSolidColorState extends State<CreateSolidColorPage> {
  bool flagFirst = true;
  late RgbValue pickedColor;
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    if(flagFirst){
      flagFirst = false;
      var random = Random();
      pickedColor = RgbValue([random.nextInt(256), random.nextInt(256), random.nextInt(256)]);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solid Color Pattern Creator"),
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
        ColorPicker(
          "Primary Color",
          pickedColor.red.toDouble(),
          pickedColor.green.toDouble(),
          pickedColor.blue.toDouble(),
              (RgbValue color) {
            pickedColor = color;
          },
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
    var model = Provider.of<Model>(context, listen: false);
    var pattern = DBImage(
      id: null,
      height: 1,
      count: 2, // Two pixel wide is a hack to get around single frame pattern issues for now
      bytes: Uint8List.fromList([...pickedColor.serialize(), ...pickedColor.serialize()]),
    );
    await model.patternDB.insertImage(pattern);
  }
}
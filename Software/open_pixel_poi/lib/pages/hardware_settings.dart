import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_pixel_poi/hardware/models/confirmtation.dart';
import 'package:provider/provider.dart';

import '../../database/dbimage.dart';
import '../../hardware/models/rgb_value.dart';
import '../../model.dart';
import '../../widgets/color_picker.dart';
import '../../widgets/connection_state_indicator.dart';
import '../hardware/models/comm_code.dart';
import '../hardware/poi_hardware.dart';


class HardwareSettingsPage extends StatefulWidget {
  const HardwareSettingsPage({super.key});

  @override
  _HardwareSettingsState createState() => _HardwareSettingsState();
}

class Utf8TextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    try {
      // Try encoding to UTF-8
      utf8.encode(newValue.text);
      return newValue; // valid UTF-8
    } catch (e) {
      return oldValue; // invalid UTF-8, reject change
    }
  }
}


class _HardwareSettingsState extends State<HardwareSettingsPage> {
  int ledCount = -1;
  int ledType = -1;
  int hardwareVersion = -1;
  String deviceName = "";
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hardware Settings"),
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
        Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(
                  "Instructions",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  "1) Changing any of these settings requires a reboot of the Poi to take effect.\n"
                  + "2) The settings are saved individually.\n"
                  + "3 )Saving an settings will overwrite the current value on all connected Poi.\n"
                  + "4) You can batch change multiple settings before a reboot to activate them all.\n"
                  + "5) Setting the wrong \"Hardware Version\" can permanently damage your Poi.",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                )
              ],
            ),
          )
        ),
        getDeviceName(),
        getLedCount(),
        getLedType(),
        getHardwareVersion(),
      ],
    );
  }

  Widget getDeviceName(){
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Device Name:",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blue,
                ),
              ),
              TextField(
                decoration: InputDecoration(border: OutlineInputBorder(), labelText: '--------------- Pixel Poi'),
                onChanged: (newValue) => setState(() {
                  deviceName = newValue;
                }),
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  Utf8TextInputFormatter()
                ],
                maxLength: 15,
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: deviceName == ""? null : () async {
                    setState(() {
                      saving = true;
                    });
                    for(PoiHardware poi in Provider.of<Model>(context, listen: false).connectedPoi!){
                      await poi.sendString(deviceName, CommCode.CC_SET_DEVICE_NAME, true).timeout(Duration(seconds: 5));
                      Confirmation? confirmation = await poi.readResponse().timeout(Duration(seconds: 5));
                      if((confirmation?.success??0) != true){
                        const snackBar = SnackBar(content: Text('Error setting device name.'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                    const snackBar = SnackBar(content: Text('Device name updated!'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    setState(() {
                      deviceName = "";
                      saving = false;
                    });
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ]
        ),
      ),
    );
  }

  Widget getLedCount(){
    List<DropdownMenuItem<int>> dropdownItems = [DropdownMenuItem(value: -1, child: Center(child: Text("------")))];
    for(int i = 1; i <= 100; i++){
      dropdownItems.add(DropdownMenuItem(value: i, child: Center(child: Text("$i"))));
    }
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pixel Count:",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blue,
                ),
              ),
              DropdownButton<int>(
                isExpanded: true,
                style: Theme.of(context).textTheme.headlineSmall,
                value: ledCount,
                items: dropdownItems,
                onChanged: (value) {
                  setState(() {
                    ledCount = value!;
                  });
                },
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: ledCount == -1? null : () async {
                    setState(() {
                      saving = true;
                    });
                    for(PoiHardware poi in Provider.of<Model>(context, listen: false).connectedPoi!){
                      await poi.sendInt8(ledCount, CommCode.CC_SET_LED_COUNT, true).timeout(Duration(seconds: 5));
                      Confirmation? confirmation = await poi.readResponse().timeout(Duration(seconds: 5));
                      if((confirmation?.success??0) != true){
                        const snackBar = SnackBar(content: Text('Error setting pixel count.'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                    const snackBar = SnackBar(content: Text('Pixel count updated!'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    setState(() {
                      ledCount = -1;
                      saving = false;
                    });
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ]
        ),
      ),
    );
  }

  Widget getLedType(){
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pixel Type:",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blue,
                ),
              ),
              DropdownButton<int>(
                isExpanded: true,
                style: Theme.of(context).textTheme.headlineSmall,
                value: ledType,
                items: [
                  DropdownMenuItem(value: -1, child: Center(child: Text("------"))),
                  DropdownMenuItem(value: 0, child: Center(child: Text("N\\A"))),
                  DropdownMenuItem(value: 1, child: Center(child: Text("NeoPixel"))),
                  DropdownMenuItem(value: 2, child: Center(child: Text("DotStar"))),
                ],
                onChanged: (value) {
                  setState(() {
                    ledType = value!;
                  });
                },
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: ledType == -1? null : () async {
                    setState(() {
                      saving = true;
                    });
                    for(PoiHardware poi in Provider.of<Model>(context, listen: false).connectedPoi!){
                      await poi.sendInt8(ledType, CommCode.CC_SET_LED_TYPE, true).timeout(Duration(seconds: 5));
                      Confirmation? confirmation = await poi.readResponse().timeout(Duration(seconds: 5));
                      if((confirmation?.success??0) != true){
                        const snackBar = SnackBar(content: Text('Error setting pixel count.'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                    const snackBar = SnackBar(content: Text('Pixel type updated!'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    setState(() {
                      ledType = -1;
                      saving = false;
                    });
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ]
        ),
      ),
    );
  }

  Widget getHardwareVersion(){
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hardware Version:",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blue,
                ),
              ),
              Text(
                "⚠️ Setting this wrong can permanently damage your Poi circuit board.",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                ),
              ),
              DropdownButton<int>(
                isExpanded: true,
                style: Theme.of(context).textTheme.headlineSmall,
                value: hardwareVersion,
                items: [
                  DropdownMenuItem(value: -1, child: Center(child: Text("------"))),
                  DropdownMenuItem(value: 0, child: Center(child: Text("0.0.0"))),
                  DropdownMenuItem(value: 1, child: Center(child: Text("2.2.1"))),
                  DropdownMenuItem(value: 2, child: Center(child: Text("3.0.0"))),
                ],
                onChanged: (value) {
                  setState(() {
                    hardwareVersion = value!;
                  });
                },
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: hardwareVersion == -1? null : () async {
                    setState(() {
                      saving = true;
                    });
                    for(PoiHardware poi in Provider.of<Model>(context, listen: false).connectedPoi!){
                      await poi.sendInt8(hardwareVersion, CommCode.CC_SET_HARDWARE_VERSION, true).timeout(Duration(seconds: 5));
                      Confirmation? confirmation = await poi.readResponse().timeout(Duration(seconds: 5));
                      if((confirmation?.success??0) != true){
                        const snackBar = SnackBar(content: Text('Error setting hardware version.'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                    const snackBar = SnackBar(content: Text('Hardware version updated!'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    setState(() {
                      hardwareVersion = -1;
                      saving = false;
                    });
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ]
        ),
      ),
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
    // var model = Provider.of<Model>(context, listen: false);
    // var pattern = DBImage(
    //   id: null,
    //   height: 1,
    //   count: 2, // Two pixel wide is a hack to get around single frame pattern issues for now
    //   bytes: Uint8List.fromList([...pickedColor.serialize(), ...pickedColor.serialize()]),
    // );
    // await model.patternDB.insertImage(pattern);
  }
}
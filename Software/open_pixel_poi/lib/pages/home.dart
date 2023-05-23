import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_pixel_poi/hardware/models/led_pattern.dart';
import 'package:open_pixel_poi/hardware/models/rgb_value.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;

import '../hardware/models/comm_code.dart';
import '../model.dart';
import '../widgets/connection_state_indicator.dart';
import '../widgets/remixer_slider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("(^'.')> Open Pixel Poi <('.'^)"),
          actions: [ConnectionStateIndicator()]),
      body: getButtons(context),
    );
  }

  Widget getButtons(BuildContext buildContext) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            getPrimarySettings(buildContext),
            getPatternSettings(buildContext)
          ],
        ),
      ),
    );
  }

  Widget getPrimarySettings(BuildContext buildContext){
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: const Text('Primary Settings',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )),
          subtitle: Column(
            children: [
              RemixerSlider(
                "Brightness: ${Provider.of<Model>(context, listen: false).hardwareState.settings!.brightness ~/ 2.55}%",
                CommCode.CC_SET_BRIGHTNESS,
                    () => Provider.of<Model>(context, listen: false)
                    .hardwareState
                    .settings!
                    .brightness,
                    (int newValue) {
                  setState(() {
                    Provider.of<Model>(context, listen: false)
                        .hardwareState
                        .settings!
                        .brightness = newValue;
                  });
                },
                // minValue: 1,
                // maxValue: 100,
              ),
              const Divider(
                height: 1,
                thickness: 1,
                indent: 0,
                endIndent: 0,
              ),
              RemixerSlider(
                "Speed: ${Provider.of<Model>(context, listen: false).hardwareState.settings!.speed}hz",
                CommCode.CC_SET_SPEED,
                    () => Provider.of<Model>(context, listen: false)
                    .hardwareState
                    .settings!
                    .speed,
                    (int newValue) {
                  setState(() {
                    Provider.of<Model>(context, listen: false)
                        .hardwareState
                        .settings!
                        .speed = newValue;
                  });
                },
                minValue: 1,
                maxValue: 255,
                scaler: 1,
                suffixGenerator: (value) => "${value.toInt()}hz",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getPatternSettings(BuildContext buildContext){
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: const Text('Pattern Settings',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )),
          subtitle: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      LEDPattern pattern = LEDPattern(2,2, [
                        RGBValue([0x00,0xff,0x00]),RGBValue([0x00,0x00,0xFF]),
                        RGBValue([0x00,0x00,0xFF]), RGBValue([0x00,0xff,0x00])
                      ]);
                      Provider.of<Model>(context, listen: false).hardware!.sendPattern(pattern);
                    },
                    child: const Text(
                      "Send Preset 1",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                indent: 0,
                endIndent: 0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      LEDPattern pattern = LEDPattern(1,6, [
                        RGBValue([0xFF,0xFF,0x00]),
                        RGBValue([0xFF,0xFF,0x00]),
                        RGBValue([0xFF,0xFF,0x00]),
                        RGBValue([0xFF,0xFF,0x00]),
                        RGBValue([0xFF,0xFF,0x00]),
                        RGBValue([0x00,0x00,0x00]),
                      ]);
                      Provider.of<Model>(context, listen: false).hardware!.sendPattern(pattern);
                    },
                    child: const Text(
                      "Send Preset 2",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                indent: 0,
                endIndent: 0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      LEDPattern pattern = LEDPattern(6,1, [
                        RGBValue([0xFF,0x00,0x00]),
                        RGBValue([0xFF,0xFF,0x00]),
                        RGBValue([0x00,0xFF,0x00]),
                        RGBValue([0x00,0xFF,0xFF]),
                        RGBValue([0x00,0x00,0xFF]),
                        RGBValue([0xFF,0x00,0xFF]),
                      ]);
                      Provider.of<Model>(context, listen: false).hardware!.sendPattern(pattern);
                    },
                    child: const Text(
                      "Send Preset 3",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                indent: 0,
                endIndent: 0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      sendIt(context, 'patterns/pattern1.bmp');
                    },
                    child: const Text(
                      "Send Image 1",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      sendIt(context, 'patterns/pattern2.bmp');
                    },
                    child: const Text(
                      "Send Image 2",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      sendIt(context, 'patterns/pattern3.bmp');
                    },
                    child: const Text(
                      "Send Image 3",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendIt(BuildContext context, String filename) async {
    // Uint8List bytes = File('patterns/pattern1.bmp').readAsBytesSync();
    ByteData bytes = await rootBundle.load(filename);
    Uint8List bytesList = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    img.Image? image = img.decodeBmp(bytesList);

    List<RGBValue> leds = List.empty(growable: true);
    for (var w = 0; w < image!.width; w ++){
      for (var h = 0; h < image!.height; h ++){
        var pixel = image!.getPixel(w, h);
        leds.add(RGBValue([pixel.r.toInt(),pixel.g.toInt(),pixel.b.toInt()]));
      }
    }

    LEDPattern pattern = LEDPattern(image!.height, image!.width, leds);
    Provider.of<Model>(context, listen: false).hardware!.sendPattern(pattern);
  }

}

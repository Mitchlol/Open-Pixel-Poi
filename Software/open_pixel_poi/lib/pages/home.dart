import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_pixel_poi/hardware/models/led_pattern.dart';
import 'package:open_pixel_poi/hardware/models/rgb_value.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:tuple/tuple.dart';

import '../database/dbimage.dart';
import '../hardware/models/comm_code.dart';
import '../model.dart';
import '../widgets/connection_state_indicator.dart';
import '../widgets/pattern_import_button.dart';
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
        title: const Text("(^'.')> Open Pixel Poi <('.'^)"),
        actions: [
          PatternImportButton(() {
            setState(() {});
          }),
          ConnectionStateIndicator(),
        ],
      ),
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
            getImagesList(buildContext),
          ],
        ),
      ),
    );
  }

  Widget getPrimarySettings(BuildContext buildContext) {
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
                "Brightness: ${Provider.of<Model>(context, listen: false).hardwareState.settings!.brightness}%",
                CommCode.CC_SET_BRIGHTNESS,
                () => Provider.of<Model>(context, listen: false).hardwareState.settings!.brightness,
                (int newValue) {
                  setState(() {
                    Provider.of<Model>(context, listen: false).hardwareState.settings!.brightness = newValue;
                  });
                },
                // minValue: 1,
                // maxValue: 100,
                scaler: 1,
              ),
              const Divider(
                height: 1,
                thickness: 1,
                indent: 0,
                endIndent: 0,
              ),
              RemixerSlider(
                "Speed: ${Provider.of<Model>(context, listen: false).hardwareState.settings!.speed * 2}hz",
                CommCode.CC_SET_SPEED,
                () => Provider.of<Model>(context, listen: false).hardwareState.settings!.speed,
                (int newValue) {
                  setState(() {
                    Provider.of<Model>(context, listen: false).hardwareState.settings!.speed = newValue;
                  });
                },
                minValue: 1,
                maxValue: 255,
                scaler: 1,
                suffixGenerator: (value) => "${value.toInt() * 2}hz",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getImagesList(BuildContext buildContext) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: const Text(
            'Patterns',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: FutureBuilder<List<Tuple2<Widget, DBImage>>>(
            future: Provider.of<Model>(context).getImages(context),
            builder: (BuildContext context, AsyncSnapshot<List<Tuple2<Widget, DBImage>>> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                List<Tuple2<Widget, DBImage>>? tuples = snapshot.data;
                tuples ??= List.empty();
                List<Widget> widgets = List.empty(growable: true);
                for (var tuple in tuples) {
                  widgets.add(
                    InkWell(
                      onTap: () {
                        Provider.of<Model>(context, listen: false).hardware!.sendPattern2(tuple.item2);
                      },
                      onLongPress: () {
                        Provider.of<Model>(context, listen: false).deleteImage(tuple.item2.id!);
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 80,
                              child: tuple.item1,
                            ),
                            const SizedBox(
                              width: 100,
                              height: 8,
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              indent: 0,
                              endIndent: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                children = widgets;
              } else if (snapshot.hasError) {
                children = <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error Loading Patterns: ${snapshot.error}'),
                  ),
                ];
              } else {
                children = const <Widget>[
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Loading patterns...'),
                  ),
                ];
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              );

              // return imagesList(buildContext, images);
            },
          ),
        ),
      ),
    );
  }

  Widget imagesList(BuildContext buildContext, List<DBImage> images) {
    return Text("");
  }
}

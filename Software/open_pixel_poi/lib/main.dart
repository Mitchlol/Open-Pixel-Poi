import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import 'OpenPixelPoiApp.dart';
import 'model.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider(create: (_) => FlutterBluePlus.instance),
      Provider(create: (_) => Model()),
    ],
    child: const OpenPixelPoiApp(),
  ));
}

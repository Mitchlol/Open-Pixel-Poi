import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'OpenPixelPoiApp.dart';
import 'model.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider(lazy: false, create: (_) => Model()),
    ],
    child: const OpenPixelPoiApp(),
  ));
}

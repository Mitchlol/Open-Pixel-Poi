import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'open_pixel_poi_app.dart';
import 'model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        Provider(lazy: false, create: (_) => Model()),
      ],
      child: const OpenPixelPoiApp(),
    ),
  );
}

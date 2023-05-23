import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_pixel_poi/pages/welcome.dart';

class OpenPixelPoiApp extends StatelessWidget {
  const OpenPixelPoiApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open Pixel Poi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomePage(),
    );
  }
}
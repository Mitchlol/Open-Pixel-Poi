import 'package:flutter/material.dart';
import 'package:open_pixel_poi/pages/welcome.dart';
import 'package:open_pixel_poi/theme.dart';

class OpenPixelPoiApp extends StatelessWidget {
  const OpenPixelPoiApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open Pixel Poi',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) => ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(top: false, child: child!),
      ),
      home: const WelcomePage(),
    );
  }
}

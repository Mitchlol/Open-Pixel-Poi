import 'package:flutter/material.dart';

final ThemeData lightTheme = _buildTheme(
  ColorScheme.fromSwatch(primarySwatch: Colors.blue),
);

final ThemeData darkTheme = _buildTheme(
  ColorScheme.dark(
    primary: Colors.blue.shade200,
    secondary: Colors.blue.shade200,
  ),
);

ThemeData _buildTheme(ColorScheme colorScheme) {
  return ThemeData(
    useMaterial3: false,
    colorScheme: colorScheme,
    tabBarTheme: TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.primary,
      indicatorColor: colorScheme.primary,
    ),
  );
}

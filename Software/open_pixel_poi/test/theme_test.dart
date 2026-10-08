import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_pixel_poi/theme.dart';

class _ThemeProbe extends StatelessWidget {
  const _ThemeProbe();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(
        'probe',
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

void main() {
  Future<ThemeData> pumpWithBrightness(
    WidgetTester tester,
    Brightness brightness,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const _ThemeProbe(),
      ),
    );
    return Theme.of(tester.element(find.text('probe')));
  }

  testWidgets('uses the light theme when the device is in light mode', (
    tester,
  ) async {
    final theme = await pumpWithBrightness(tester, Brightness.light);

    expect(theme.brightness, Brightness.light);
    expect(theme.useMaterial3, isTrue);
  });

  testWidgets('uses the dark theme when the device is in dark mode', (
    tester,
  ) async {
    final theme = await pumpWithBrightness(tester, Brightness.dark);

    expect(theme.brightness, Brightness.dark);
    expect(theme.useMaterial3, isTrue);
  });

  testWidgets('switches theme when the device setting changes', (tester) async {
    await pumpWithBrightness(tester, Brightness.light);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();

    final theme = Theme.of(tester.element(find.text('probe')));
    expect(theme.brightness, Brightness.dark);
  });
}

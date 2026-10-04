import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:open_pixel_poi/database/db_image.dart';
import 'package:open_pixel_poi/widgets/resize_image_dialog.dart';

void main() {
  group('ResizeImageDialog sizing', () {
    test('keeps the aspect ratio when scaling the width', () {
      final image = img.Image(width: 400, height: 200);
      expect(ResizeImageDialog.widthFor(image, 50), 100);
      expect(ResizeImageDialog.widthFor(image, 1), 2);
    });

    test('never scales the width below one pixel', () {
      final image = img.Image(width: 1, height: 1000);
      expect(ResizeImageDialog.widthFor(image, 10), 1);
    });

    test('picks the tallest height that fits the pixel limit', () {
      final image = img.Image(width: 1000, height: 1000);
      final height = ResizeImageDialog.maxHeightFor(image);
      expect(height, 200);
      expect(ResizeImageDialog.fits(image, height), isTrue);
      expect(ResizeImageDialog.fits(image, height + 1), isFalse);
    });

    test('caps the height at what the protocol can send', () {
      final image = img.Image(width: 10, height: 1000);
      expect(ResizeImageDialog.maxHeightFor(image), DBImage.maxHeight);
    });

    test('never asks for a height taller than the image', () {
      final image = img.Image(width: 1000, height: 30);
      expect(ResizeImageDialog.maxHeightFor(image), 30);
    });
  });

  group('ResizeImageDialog widget', () {
    Future<Future<img.Image?>> openDialog(WidgetTester tester, img.Image image) async {
      final completer = Completer<img.Image?>();
      var opened = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              if (!opened) {
                opened = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  completer.complete(
                    showDialog<img.Image>(
                      context: context,
                      builder: (context) => ResizeImageDialog(image: image),
                    ),
                  );
                });
              }
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      return completer.future;
    }

    testWidgets('returns a resized image that fits on the poi', (tester) async {
      final image = img.Image(width: 800, height: 400);
      final future = await openDialog(tester, image);

      expect(find.text('Image too large'), findsOneWidget);
      expect(find.textContaining('Height: 141'), findsOneWidget);

      await tester.tap(find.text('Resize'));
      await tester.pumpAndSettle();

      final resized = await future;
      expect(resized, isNotNull);
      expect(resized!.height, 141);
      expect(resized.width, 282);
      expect(resized.width * resized.height, lessThanOrEqualTo(DBImage.maxPixels));
    });

    testWidgets('returns null when cancelled', (tester) async {
      final image = img.Image(width: 800, height: 400);
      final future = await openDialog(tester, image);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await future, isNull);
    });
  });
}

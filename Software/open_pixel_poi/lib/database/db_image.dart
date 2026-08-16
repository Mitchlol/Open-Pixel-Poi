import 'dart:typed_data';

import 'package:image/image.dart' as img;

class DBImage {
  final int? id;
  final int height;
  final int count;
  final Uint8List bytes;

  const DBImage({
    required this.id,
    required this.height,
    required this.count,
    required this.bytes,
  });

  /// Serializes [image] column by column into the RGB byte layout the poi
  /// hardware expects.
  factory DBImage.fromImg(img.Image image) {
    final bytes = Uint8List(image.width * image.height * 3);
    var offset = 0;
    for (var w = 0; w < image.width; w++) {
      for (var h = 0; h < image.height; h++) {
        final pixel = image.getPixel(w, h);
        bytes[offset++] = pixel.r.toInt();
        bytes[offset++] = pixel.g.toInt();
        bytes[offset++] = pixel.b.toInt();
      }
    }
    return DBImage(
      id: null,
      height: image.height,
      count: image.width,
      bytes: bytes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'height': height,
      'count': count,
      'bytes': bytes,
    };
  }

  @override
  String toString() {
    return 'Image{id: $id, height: $height, count: $count, bytes: <REDACTED>}';
  }
}

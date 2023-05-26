import 'dart:typed_data';

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
    return 'Dog{id: $id, height: $height, count: $count, bytes: <REDACTED>}';
  }
}
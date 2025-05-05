import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dbimage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

class PatternDB {
  late Future<Database> databaseFuture;
  List<Tuple2<Widget, DBImage>>? inMemoryCache;

  PatternDB(){
    getDB(); // Loads async without await, but user needs to scan for bluetooth so we have time.
  }

  Future<void> getDB() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (!Platform.isAndroid) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    databaseFuture = openDatabase(
      join(await getDatabasesPath(), 'images.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE images(id INTEGER PRIMARY KEY, height INTEGER, count INTEGER, bytes BLOB)',
        );
      },
      version: 1,
    );

    List<DBImage> images = await getDBImages();
    if (images.isEmpty) {
      print("DB Empty, inserting included images");
      for (int i = 1; i <= 10; i++) {
        ByteData fileBytes = await rootBundle.load("patterns/pattern$i.bmp");
        Uint8List bytesList = fileBytes.buffer.asUint8List(fileBytes.offsetInBytes, fileBytes.lengthInBytes);
        img.Image image = img.decodeBmp(bytesList)!;

        List<int> imageBytes = List.empty(growable: true);
        for (var w = 0; w < image.width; w++) {
          for (var h = 0; h < image.height; h++) {
            var pixel = image.getPixel(w, h);
            imageBytes.add(pixel.r.toInt());
            imageBytes.add(pixel.g.toInt());
            imageBytes.add(pixel.b.toInt());
          }
        }

        var pattern = DBImage(
          id: null,
          height: image.height,
          count: image.width,
          bytes: Uint8List.fromList(imageBytes),
        );

        await insertImage(pattern);
      }
    }
  }

  Future<void> insertImage(DBImage image) async {
    final db = await databaseFuture;
    await db.insert(
      'images',
      image.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    clearInMemoryCache();
  }

  Future<void> deleteImage(int id) async {
    final db = await databaseFuture;

    await db.delete(
      'images',
      where: 'id = ?',
      whereArgs: [id],
    );
    clearInMemoryCache();
  }

  Future<List<DBImage>> getDBImages() async {
    final db = await databaseFuture;

    final List<Map<String, dynamic>> maps = await db.query('images');

    return List.generate(maps.length, (i) {
      return DBImage(
        id: maps[i]['id'],
        height: maps[i]['height'],
        count: maps[i]['count'],
        bytes: maps[i]['bytes'],
      );
    });
  }

  Future<DBImage> getDBImage(int id) async {
    final db = await databaseFuture;

    final List<Map<String, dynamic>> maps = await db.query('images', where: "id = ?", whereArgs: [id]);

    return DBImage(
      id: maps[0]['id'],
      height: maps[0]['height'],
      count: maps[0]['count'],
      bytes: maps[0]['bytes'],
    );
  }

  Future<void> invertImage(int id) async {
    var image = await getDBImage(id);
    List<int> inverted = List.empty(growable: true);
    for(int column = 0; column < image.count; column++){
      int offset = column * image.height * 3;
      for(int pixel = image.height - 1; pixel >= 0; pixel--){
        inverted.add(image.bytes[offset + (pixel * 3) + 0]);
        inverted.add(image.bytes[offset + (pixel * 3) + 1]);
        inverted.add(image.bytes[offset + (pixel * 3) + 2]);
      }
    }
    deleteImage(id);
    insertImage(DBImage(id: image.id, height: image.height, count: image.count, bytes: Uint8List.fromList(inverted)));
    clearInMemoryCache();
  }

  Future<void> reverseImage(int id) async {
    var image = await getDBImage(id);
    List<int> reversed = List.empty(growable: true);
    for(int column = image.count - 1; column >= 0; column--){
      int offset = column * image.height * 3;
      for(int pixel = 0; pixel < image.height; pixel++){
        reversed.add(image.bytes[offset + (pixel * 3) + 0]);
        reversed.add(image.bytes[offset + (pixel * 3) + 1]);
        reversed.add(image.bytes[offset + (pixel * 3) + 2]);
      }
    }
    await deleteImage(id);
    await insertImage(DBImage(id: image.id, height: image.height, count: image.count, bytes: Uint8List.fromList(reversed)));
    clearInMemoryCache();
  }

  // Gets actual size image
  Future<List<img.Image>> getImgImages(List<DBImage> dbImages) async {
    List<img.Image> imgimages = List.empty(growable: true);
    for (var dbImage in dbImages) {
      final imgimage = img.Image(width: dbImage.count, height: dbImage.height);
      // Iterate over its pixels
      for (var pixel in imgimage) {
        pixel.r = dbImage.bytes[((pixel.y * 3) + 0) + (pixel.x * imgimage.height * 3)];
        pixel.g = dbImage.bytes[((pixel.y * 3) + 1) + (pixel.x * imgimage.height * 3)];
        pixel.b = dbImage.bytes[((pixel.y * 3) + 2) + (pixel.x * imgimage.height * 3)];
      }
      imgimages.add(imgimage);
    }
    return imgimages;
  }

  // Get image that is is repeating to look nice for display
  Future<List<img.Image>> getRepeatingImgImages(List<DBImage> dbImages) async {
    List<img.Image> imgimages = List.empty(growable: true);
    for (var dbImage in dbImages) {
      int desiredWidth = 0;
      while(desiredWidth < 100){
        desiredWidth += dbImage.count;
      }
      final imgimage = img.Image(width: desiredWidth, height: 20);
      // Iterate over its pixels
      for (var pixel in imgimage) {
        pixel.r = dbImage.bytes[(((pixel.y % dbImage.height) * 3) + 0) + ((pixel.x % dbImage.count) * (dbImage.height) * 3)];
        pixel.g = dbImage.bytes[(((pixel.y % dbImage.height) * 3) + 1) + ((pixel.x % dbImage.count) * (dbImage.height) * 3)];
        pixel.b = dbImage.bytes[(((pixel.y % dbImage.height) * 3) + 2) + ((pixel.x % dbImage.count) * (dbImage.height) * 3)];
      }
      imgimages.add(imgimage);
    }
    return imgimages;
  }

  Future<List<Tuple2<Widget, DBImage>>> getImages(BuildContext context) async {
    if(inMemoryCache != null){
      return Future.value(inMemoryCache);
    }
    var dbImages = await getDBImages();
    List<img.Image> imgImages = await getRepeatingImgImages(dbImages);
    List<Tuple2<Widget, DBImage>> imageWidgets = List.empty(growable: true);
    for (var imgImage in imgImages) {
      imageWidgets.add(Tuple2(
          Image.memory(
            img.encodeJpg(imgImage),
            // width: imgImage.width.toDouble(),
            // height: imgImage.height.toDouble(),
            // scale: 1.0,
            // width: 400,
            // height: 20,
            // repeat: ImageRepeat.repeat,
            alignment: Alignment.topLeft,
            fit: BoxFit.fitHeight,
          ),
          dbImages[imgImages.indexOf(imgImage)]));
    }
    inMemoryCache = imageWidgets;
    return imageWidgets;
  }

  void clearInMemoryCache(){
    inMemoryCache = null;
  }
}
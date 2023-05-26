import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:open_pixel_poi/hardware/poi_hardware_state.dart';
import 'package:tuple/tuple.dart';

import 'hardware/poi_hardware.dart';
import 'database/dbimage.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:image/image.dart' as img;
import 'package:sqflite/sqflite.dart';

class Model {
  PoiHardware? hardware;
  PoiHardwareState hardwareState = PoiHardwareState();
  late Future<Database> databaseFuture;

  Model() {
    getDB();
  }

  void getDB() async {
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
      for (int i = 1; i <= 5; i++) {
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
  }

  Future<void> deleteImage(int id) async {
    final db = await databaseFuture;

    await db.delete(
      'images',
      where: 'id = ?',
      whereArgs: [id],
    );
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
      final imgimage = img.Image(width: 400, height: 20);
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
    return imageWidgets;
  }
}

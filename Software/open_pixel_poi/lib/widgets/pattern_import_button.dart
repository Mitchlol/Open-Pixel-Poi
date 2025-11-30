import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

import '../database/dbimage.dart';
import '../model.dart';

class PatternImportButton extends StatelessWidget {
  Function() onImageImported;
  PatternImportButton(this.onImageImported, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        try {
          SnackBar snackBar = SnackBar(content: Text("Importing..."));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          await importPattern(context);
          SnackBar snackBar2 = SnackBar(content: Text("Import succeeded!"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar2);
        } on Exception catch(error){
          SnackBar snackBar = SnackBar(content: Text("$error"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      icon: const Icon(
        Icons.add_photo_alternate_outlined,
        color: Colors.blue,
      ),
    );
  }

  Future<void> importPattern(BuildContext context) async {
    var model = Provider.of<Model>(context, listen: false);

    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    final List<DBImage> patterns = [];
    for (var imageFile in images){
      if(imageFile == null){
        throw Exception("Invalid file.");
      }

      img.Image? image = null;
      if(imageFile.name.endsWith('bmp') || imageFile.name.endsWith('BMP')){
        image = img.decodeBmp(await imageFile.readAsBytes())!;
      }
      if(imageFile.name.endsWith('png') || imageFile.name.endsWith('PNG')){
        image = img.decodePng(await imageFile.readAsBytes())!;
      }
      if(imageFile.name.endsWith('jpg') || imageFile.name.endsWith('JPG') || imageFile.name.endsWith('jpeg') || imageFile.name.endsWith('JPEG')){
        image = img.decodeJpg(await imageFile.readAsBytes())!;
      }
      if(image == null){
        throw Exception("Unacceptable image format.");
      }

      if(image.width * image.height > 40000){
        throw Exception("Imported image is too large, max size is 40,000 pixels (200x200/100x400/25x1600 etc..).");
      }
      List<int> imageBytes = List.empty(growable: true);
      for (var w = 0; w < image.width; w++) {
        for (var h = 0; h < image.height; h++) {
          var pixel = image.getPixel(w, h);
          imageBytes.add(pixel.r.toInt());
          imageBytes.add(pixel.g.toInt());
          imageBytes.add(pixel.b.toInt());
        }
      }

      patterns.add(DBImage(
        id: null,
        height: image.height,
        count: image.width,
        bytes: Uint8List.fromList(imageBytes),
      ));
    }

    for(var pattern in patterns){
      await model.patternDB.insertImage(pattern);
    }

    onImageImported();
  }

  // Future<void> getLostData() async {
  //   final ImagePicker picker = ImagePicker();
  //   final LostDataResponse response = await picker.retrieveLostData();
  //   if (response.isEmpty) {
  //     return;
  //   }
  //   final List<XFile>? files = response.files;
  //   if (files != null) {
  //     _handleLostFiles(files);
  //   } else {
  //     _handleError(response.exception);
  //   }
  // }
}

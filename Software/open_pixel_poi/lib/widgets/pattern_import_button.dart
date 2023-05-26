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
      onPressed: () {
        importPattern(context);
      },
      icon: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  void importPattern(BuildContext context) async {
    var model = Provider.of<Model>(context, listen: false);
    var db = await model.databaseFuture;

    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);
    if(imageFile == null){
      return;
    }

    img.Image image = img.decodeBmp(await imageFile.readAsBytes())!;
    if(image.width > 400 || image.height > 20){
      throw Exception("Imported image is too large");
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

    var pattern = DBImage(
      id: null,
      height: image.height,
      count: image.width,
      bytes: Uint8List.fromList(imageBytes),
    );

    await model.insertImage(pattern);
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

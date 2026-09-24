import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

import '../database/db_image.dart';
import '../model.dart';

class PatternImportButton extends StatelessWidget {
  final Function() onImageImported;
  const PatternImportButton(this.onImageImported, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          messenger.showSnackBar(const SnackBar(content: Text("Importing...")));
          await importPattern(context);
          messenger.showSnackBar(
            const SnackBar(content: Text("Import succeeded!")),
          );
        } on Exception catch (error) {
          messenger.showSnackBar(SnackBar(content: Text("$error")));
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
    for (var imageFile in images) {
      img.Image? image;
      if (imageFile.name.endsWith('bmp') || imageFile.name.endsWith('BMP')) {
        image = img.decodeBmp(await imageFile.readAsBytes())!;
      }
      if (imageFile.name.endsWith('png') || imageFile.name.endsWith('PNG')) {
        image = img.decodePng(await imageFile.readAsBytes())!;
      }
      if (imageFile.name.endsWith('jpg') ||
          imageFile.name.endsWith('JPG') ||
          imageFile.name.endsWith('jpeg') ||
          imageFile.name.endsWith('JPEG')) {
        image = img.decodeJpg(await imageFile.readAsBytes())!;
      }
      if (image == null) {
        throw Exception("Unacceptable image format.");
      }

      if (image.width * image.height > 40000) {
        throw Exception(
          "Imported image is too large, max size is 40,000 pixels (200x200/100x400/25x1600 etc..).",
        );
      }
      patterns.add(DBImage.fromImg(image));
    }

    for (var pattern in patterns) {
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

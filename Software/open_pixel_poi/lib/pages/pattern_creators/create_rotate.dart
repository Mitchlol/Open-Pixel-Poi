import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../database/dbimage.dart';
import '../../model.dart';
import '../../widgets/connection_state_indicator.dart';
import '../../widgets/labeled_slider.dart';


class CreateRotatePage extends StatefulWidget {
  const CreateRotatePage({super.key});

  @override
  _CreateRotateState createState() => _CreateRotateState();
}

class _CreateRotateState extends State<CreateRotatePage> {
  bool saving = false;
  int outputImageHeightLimit = 25;
  Tuple2<Widget, DBImage>? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rotate image 90 degrees"),
        actions: [
          ...Provider.of<Model>(context)
              .connectedPoi!
              .map((e) => ConnectionStateIndicator(Provider.of<Model>(context).connectedPoi!.indexOf(e)))
        ],
      ),
      body: saving ? getSaving() : getForm(),
    );
  }

  Widget getForm() {
    return ListView(
      children: [
        LabeledSlider(
          "Rotated Image Height Limit",
          1,
          100,
          1,
          (int value) => setState(() {
            outputImageHeightLimit = value;
          }),
          25,
        ),
        InkWell(
          onTap: () => showDialog<void>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text("Select Image"),
              content: FutureBuilder<List<Tuple2<Widget, DBImage>>>(
                future: Provider.of<Model>(context).patternDB.getImages(context),
                builder: (BuildContext context, AsyncSnapshot<List<Tuple2<Widget, DBImage>>> snapshot) {
                  if (snapshot.hasData) {
                    return SizedBox(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index){
                          return InkWell(
                            onTap: (){
                              image = snapshot.data![index];
                              Navigator.pop(context, 'Cancel');
                              setState(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 80,
                                    child: snapshot.data![index].item1,
                                  ),
                                  const SizedBox(
                                    width: 100,
                                    height: 8,
                                  ),
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    indent: 0,
                                    endIndent: 0,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }else if(snapshot.hasError){
                    tooFewImagesError(context);
                    return Container();
                  }else{
                    return Container();
                  }
                },
              ),
              actionsPadding: const EdgeInsets.all(0.0),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Image",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: FutureBuilder<List<Tuple2<Widget, DBImage>>>(
                    future: Provider.of<Model>(context).patternDB.getImages(context),
                    builder: (BuildContext context, AsyncSnapshot<List<Tuple2<Widget, DBImage>>> snapshot) {
                      if (image != null){
                        return image!.item1;
                      }else if (snapshot.hasData && snapshot.data!.length >= 2) {
                        image = snapshot.data![0];
                        return snapshot.data!.first.item1;
                      }else if(snapshot.hasError || (snapshot.hasData && snapshot.data!.length < 2)){
                        tooFewImagesError(context);
                        return Container();
                      }else{
                        return Container();
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 100,
                  height: 8,
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      saving = true;
                      await makeAndStorePattern(context);
                      if(context.mounted) { // Do we actually want this check?
                        Navigator.pop(context, true);
                      }
                      saving = false;
                    },
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget getSaving() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Saving...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Future<void> makeAndStorePattern(BuildContext context) async{
    var model = Provider.of<Model>(context, listen: false);

    int desiredWidth = max(2, image!.item2.height);
    int desiredHeight = min(outputImageHeightLimit, image!.item2.count);
    var imgImage = (await model.patternDB.getImgImages([image!.item2]))[0];
    var rgbList = Uint8List((desiredWidth*desiredHeight)*3);

    for(var column = 0; column < desiredWidth; column++){
      for(var row = 0; row < desiredHeight; row++){
        var columnOffset = column * desiredHeight * 3;
        var rowOffset = row * 3;
        var pixel = imgImage.getPixel(row, column % image!.item2.height);
        rgbList[columnOffset + rowOffset + 0] = pixel.r.toInt();
        rgbList[columnOffset + rowOffset + 1] = pixel.g.toInt();
        rgbList[columnOffset + rowOffset + 2] = pixel.b.toInt();
      }
    }
    var pattern = DBImage(
      id: null,
      height: desiredHeight,
      count: desiredWidth,
      bytes: rgbList,
    );
    await model.patternDB.insertImage(pattern);
  }

  void tooFewImagesError(BuildContext context){
    const snackBar = SnackBar(content: Text('You must have at least 1 image stored to rotate.'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    if(context.mounted) { // Do we actually want this check?
      Navigator.pop(context);
    }
  }
}
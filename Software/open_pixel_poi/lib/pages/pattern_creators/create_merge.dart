import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/db_image.dart';
import '../../database/pattern_db.dart';
import '../../model.dart';
import '../../widgets/connection_state_indicator.dart';


class CreateMergePage extends StatefulWidget {
  const CreateMergePage({super.key});

  @override
  _CreateMergeState createState() => _CreateMergeState();
}

class _CreateMergeState extends State<CreateMergePage> {
  bool saving = false;
  PatternEntry? topImage;
  PatternEntry? bottomImage;

  String blendMode = "Normal";
  List<String> blendModes = ["Normal", "Hard Normal", "Lighten", "Darken", "Add", "Multiply", "Average"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Merge Two Images"),
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
        InkWell(
          onTap: () => showDialog<void>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text("Select top Image"),
              content: FutureBuilder<List<PatternEntry>>(
                future: Provider.of<Model>(context).patternDB.getImages(context),
                builder: (BuildContext context, AsyncSnapshot<List<PatternEntry>> snapshot) {
                  if (snapshot.hasData) {
                    return SizedBox(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index){
                          return InkWell(
                            onTap: (){
                              topImage = snapshot.data![index];
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
                                    child: snapshot.data![index].preview,
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
                    "Top Image",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: FutureBuilder<List<PatternEntry>>(
                    future: Provider.of<Model>(context).patternDB.getImages(context),
                    builder: (BuildContext context, AsyncSnapshot<List<PatternEntry>> snapshot) {
                      if (topImage != null){
                        return topImage!.preview;
                      }else if (snapshot.hasData && snapshot.data!.length >= 2) {
                        topImage = snapshot.data![0];
                        return snapshot.data!.first.preview;
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
        InkWell(
          onTap: () => showDialog<void>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text("Select bottom Image"),
              content: FutureBuilder<List<PatternEntry>>(
                future: Provider.of<Model>(context).patternDB.getImages(context),
                builder: (BuildContext context, AsyncSnapshot<List<PatternEntry>> snapshot) {
                  if (snapshot.hasData) {
                    return SizedBox(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index){
                          return InkWell(
                            onTap: (){
                              bottomImage = snapshot.data![index];
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
                                    child: snapshot.data![index].preview,
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
                    "Bottom Image",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: FutureBuilder<List<PatternEntry>>(
                    future: Provider.of<Model>(context).patternDB.getImages(context),
                    builder: (BuildContext context, AsyncSnapshot<List<PatternEntry>> snapshot) {
                      if (bottomImage != null){
                        return bottomImage!.preview;
                      }else if (snapshot.hasData && snapshot.data!.length >= 2) {
                        bottomImage = snapshot.data![1];
                        return snapshot.data![1].preview;
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
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "Blend Mode",
            style: TextStyle(
              fontSize: 20,
              color: Colors.blue,
            ),
          ),
        ),
        ListTile(
          subtitle: DropdownButton<String>(
            isExpanded: true,
            icon: Icon(Icons.arrow_downward, color: Colors.blue),
            value: blendMode,
            items: blendModes.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (item){
              setState(() {
                blendMode = item ?? blendMode;
              });
            },
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

    var topWidth = topImage!.dbImage.count;
    var bottomWidth = bottomImage!.dbImage.count;

    // Taller of the 2 images
    int desiredHeight = max(topImage!.dbImage.height, bottomImage!.dbImage.height);

    // Find least common multiple
    int x = topWidth, y = bottomWidth;
    while (y != 0) {
      int temp = y;
      y = x % y;
      x = temp;
    }
    int gcd = x;
    int lcm = (topWidth * bottomWidth) ~/ gcd;

    int desiredWidth = min(40000~/desiredHeight, lcm);

    var images = await model.patternDB.getImgImages([topImage!.dbImage, bottomImage!.dbImage]);
    var rgbList = Uint8List((desiredWidth*desiredHeight)*3);

    for(var column = 0; column < desiredWidth; column++){
      for(var row = 0; row < desiredHeight; row++){
        var columnOffset = column * desiredHeight * 3;
        var rowOffset = row * 3;
        var top = images[0].getPixel(column % topWidth, row % topImage!.dbImage.height);
        var bottom = images[1].getPixel(column % bottomWidth, row % bottomImage!.dbImage.height);
        if (blendMode == "Lighten") {
          rgbList[columnOffset + rowOffset + 0] = (top.r > bottom.r ? top.r : bottom.r).toInt();
          rgbList[columnOffset + rowOffset + 1] = (top.g > bottom.g ? top.g : bottom.g).toInt();
          rgbList[columnOffset + rowOffset + 2] = (top.b > bottom.b ? top.b : bottom.b).toInt();
        }else if (blendMode == "Darken") {
          rgbList[columnOffset + rowOffset + 0] = (top.r < bottom.r ? top.r : bottom.r).toInt();
          rgbList[columnOffset + rowOffset + 1] = (top.g < bottom.g ? top.g : bottom.g).toInt();
          rgbList[columnOffset + rowOffset + 2] = (top.b < bottom.b ? top.b : bottom.b).toInt();
        }else if(blendMode == "Hard Normal"){
          if(top.r > 0 || top.g > 0 || top.b > 0){
            rgbList[columnOffset + rowOffset + 0] = (top.r).toInt();
            rgbList[columnOffset + rowOffset + 1] = (top.g).toInt();
            rgbList[columnOffset + rowOffset + 2] = (top.b).toInt();
          }else{
            rgbList[columnOffset + rowOffset + 0] = (bottom.r).toInt();
            rgbList[columnOffset + rowOffset + 1] = (bottom.g).toInt();
            rgbList[columnOffset + rowOffset + 2] = (bottom.b).toInt();
          }
        }else if(blendMode == "Normal"){
          var topAlpha = max(max(top.r, top.g), top.b) / 255;
          rgbList[columnOffset + rowOffset + 0] = ((topAlpha * top.r) + ((1-topAlpha) * bottom.r)).toInt();
          rgbList[columnOffset + rowOffset + 1] = ((topAlpha * top.g) + ((1-topAlpha) * bottom.g)).toInt();
          rgbList[columnOffset + rowOffset + 2] = ((topAlpha * top.b) + ((1-topAlpha) * bottom.b)).toInt();
        }else if(blendMode == "Add") {
          rgbList[columnOffset + rowOffset + 0] = (min(255, top.r + bottom.r)).toInt();
          rgbList[columnOffset + rowOffset + 1] = (min(255, top.g + bottom.g)).toInt();
          rgbList[columnOffset + rowOffset + 2] = (min(255, top.b + bottom.b)).toInt();
        }else if(blendMode == "Multiply") {
          rgbList[columnOffset + rowOffset + 0] = ((top.r * bottom.r) / 255).toInt();
          rgbList[columnOffset + rowOffset + 1] = ((top.g * bottom.g) / 255).toInt();
          rgbList[columnOffset + rowOffset + 2] = ((top.b * bottom.b) / 255).toInt();
        }else if(blendMode == "Average") {
          rgbList[columnOffset + rowOffset + 0] = ((top.r + bottom.r) / 2).toInt();
          rgbList[columnOffset + rowOffset + 1] = ((top.g + bottom.g) / 2).toInt();
          rgbList[columnOffset + rowOffset + 2] = ((top.b + bottom.b) / 2).toInt();
        }
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
    const snackBar = SnackBar(content: Text('You must have at least 2 images stored to make merged image.'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    if(context.mounted) { // Do we actually want this check?
      Navigator.pop(context);
    }
  }
}
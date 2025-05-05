import 'package:flutter/material.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_blur.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_check.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_fade.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_merge.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_rotate.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_strobe.dart';
import 'package:open_pixel_poi/pages/pattern_creators/create_text.dart';
import 'package:provider/provider.dart';

import '../model.dart';
import '../widgets/connection_state_indicator.dart';
import 'pattern_creators/create_solid_color.dart';


class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<CreatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Custom Pattern"),
        actions: [
          ...Provider.of<Model>(context)
              .connectedPoi!
              .map((e) => ConnectionStateIndicator(Provider.of<Model>(context).connectedPoi!.indexOf(e)))
        ],
      ),
      body: ListView(
        children: [
          getCreatorButton("Solid Color", () => CreateSolidColorPage()),
          getCreatorButton("Check", () => CreateCheckPage()),
          getCreatorButton("Fade", () => CreateFadePage()),
          getCreatorButton("Strobe", () => CreateStrobePage()),
          getCreatorButton("Text", () => CreateTextPage()),
          getCreatorButton("Rotate", () => CreateRotatePage()),
          getCreatorButton("Blur", () => CreateBlurPage()),
          getCreatorButton("Layer", () => CreateMergePage()),
        ],
      ),
    );
  }

  Widget getCreatorButton(String label, dynamic Function() constructor){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          child: Text(label, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          onPressed: () async {
            var result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
              return constructor();
            }));
            if (result != null && result && context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}
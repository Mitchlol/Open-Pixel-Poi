import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../hardware/models/comm_code.dart';
import '../hardware/models/confirmtation.dart';
import '../model.dart';

String defaultSuffixgenerator(double value) {
  return "${value.toInt()}%";
}
class RemixerSlider extends StatefulWidget {
  String title;
  CommCode code;
  int Function() getter;
  Function(int) setter;
  double maxValue;
  double minValue;
  double scaler;
  String Function(double) suffixGenerator;

  RemixerSlider(this.title, this.code, this.getter, this.setter, {this.maxValue = 100.0, this.minValue = 0.0, this.scaler = 2.55, this.suffixGenerator = defaultSuffixgenerator}){
    if(getter()/scaler > maxValue){
      setter(0);
    }
    if(getter()/scaler < minValue){
      setter(0);
    }
  }

  @override
  _RemixerSliderState createState() => _RemixerSliderState(title, code, getter, setter, maxValue, minValue, scaler, suffixGenerator);
}

class _RemixerSliderState extends State<RemixerSlider> {
  String title;
  CommCode code;
  int Function() getter;
  Function(int) setter;
  double maxValue;
  double minValue;
  double scaler;
  String Function(double) suffixGenerator;

  late double temp;

  _RemixerSliderState(this.title, this.code, this.getter, this.setter, this.maxValue, this.minValue, this.scaler, this.suffixGenerator){
    temp = (getter()~/scaler).toDouble();
  }

  @override
  void didUpdateWidget(RemixerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    this.title = widget.title;
    // Default constructor values don't seem to be applied -_-
    // this.code = widget.code;
    // this.getter = widget.getter;
    // this.setter = widget.setter;
    // this.strip = widget.strip;
    // this.maxValue = widget.maxValue;
    // this.maxValue = widget.minValue;
    // this.scaler = widget.scaler;
    // this.suffix = widget.suffix;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
        subtitle: Slider(
          value: temp,
          max: maxValue,
          min: minValue,
          divisions: max(maxValue.toInt().abs() + minValue.toInt().abs(), 1),
          label: suffixGenerator(temp),
          onChanged: (double value) {
            setState(() {
              temp = value;
            });
          },
          onChangeEnd: (double value) {
            setInt((value * scaler).round(), context);
          },
        ),
      ),
    );
  }

  void setInt(int value, BuildContext context) async {
    Model model = Provider.of<Model>(context, listen: false);
    int previous = getter();
    try{
      print("Set int ${code.name}");
      setState(() {
        setter(value);
      });
      await model.hardware!.sendInt8(value, code);
      // TODO: Ignoring confirmations for now
      // await Future.delayed(Duration(milliseconds: 100));
      // Confirmation response = await model.hardware!.readResponse().timeout(Duration(seconds: 3));
      // if(!response.success){
      //   throw Exception("Device returned err :-O");
      // }
    }catch (e, s){
      // revert!
      setState(() {
        setter(previous);
      });
      print(e);
      print(s);
    }
  }

}
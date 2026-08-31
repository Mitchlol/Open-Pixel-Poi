import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_pixel_poi/hardware/models/confirmation.dart';
import 'package:provider/provider.dart';

import '../hardware/poi_hardware.dart';
import '../model.dart';
import '../widgets/big_button.dart';
import '../widgets/connection_state_indicator.dart';
import '../widgets/labeled_button_select.dart';
import '../widgets/status_message.dart';

class HardwareSettingsPage extends StatefulWidget {
  const HardwareSettingsPage({super.key});

  @override
  State<HardwareSettingsPage> createState() => _HardwareSettingsState();
}

class Utf8TextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    try {
      // Try encoding to UTF-8
      utf8.encode(newValue.text);
      return newValue; // valid UTF-8
    } catch (e) {
      return oldValue; // invalid UTF-8, reject change
    }
  }
}

class _HardwareSettingsState extends State<HardwareSettingsPage> {
  int ledCount = -1;
  int ledType = -1;
  int hardwareVersion = -1;
  String deviceName = "";
  int patternShuffleDuration = -1;
  List<int> brightnesses = [0, 0, 0, 0, 0, 0];
  List<int> animationSpeeds = [0, 0, 0, 0, 0, 0];
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hardware Settings"),
        actions: const [ConnectionStateIndicators()],
      ),
      body: saving
          ? const StatusMessage.saving()
          : ListView(
              children: [
                const _SettingsCard(
                  title: "Instructions",
                  children: [
                    Text(
                      "1) Each setting must be saved individually.\n"
                      "2) Saving a setting will overwrite the current value on all connected Poi.\n"
                      "3) Settings marked with the 🔄 symbol require a reboot of the Poi to take effect. You can batch save multiple settings before a single reboot to activate them all.\n"
                      "4) Setting the wrong \"Hardware Version\" can permanently damage your Poi circuit board.",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                _SettingsCard(
                  title: "Pattern Shuffle Delay:",
                  children: [
                    _SettingsDropdown(
                      value: patternShuffleDuration,
                      options: {for (var i = 1; i <= 120; i++) i: "$i Seconds"},
                      onChanged: (value) =>
                          setState(() => patternShuffleDuration = value),
                    ),
                    BigButton(
                      "Save",
                      onPressed: patternShuffleDuration == -1
                          ? null
                          : () => _saveSetting(
                              send: (poi) => poi.sendInt8(
                                patternShuffleDuration,
                                .setPatternShuffleDuration,
                                true,
                              ),
                              errorText: 'Error setting shuffle duration.',
                              successText: 'Shuffle duration updated!',
                              onSaved: () => patternShuffleDuration = -1,
                            ),
                    ),
                  ],
                ),
                _SettingsCard(
                  title: "🔄Device Name:",
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '--------------- Pixel Poi',
                      ),
                      onChanged: (newValue) => setState(() {
                        deviceName = newValue;
                      }),
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [Utf8TextInputFormatter()],
                      maxLength: 15,
                    ),
                    BigButton(
                      "Save",
                      onPressed: deviceName == ""
                          ? null
                          : () => _saveSetting(
                              send: (poi) => poi.sendString(
                                deviceName,
                                .setDeviceName,
                                true,
                              ),
                              errorText: 'Error setting device name.',
                              successText: 'Device name updated!',
                              onSaved: () => deviceName = "",
                            ),
                    ),
                  ],
                ),
                _SettingsCard(
                  title: "🔄Pixel Count:",
                  children: [
                    _SettingsDropdown(
                      value: ledCount,
                      options: {for (var i = 1; i <= 100; i++) i: "$i"},
                      onChanged: (value) => setState(() => ledCount = value),
                    ),
                    BigButton(
                      "Save",
                      onPressed: ledCount == -1
                          ? null
                          : () => _saveSetting(
                              send: (poi) =>
                                  poi.sendInt8(ledCount, .setLedCount, true),
                              errorText: 'Error setting pixel count.',
                              successText: 'Pixel count updated!',
                              onSaved: () => ledCount = -1,
                            ),
                    ),
                  ],
                ),
                _SettingsCard(
                  title: "🔄Pixel Type:",
                  children: [
                    _SettingsDropdown(
                      value: ledType,
                      options: const {0: "N\\A", 1: "NeoPixel", 2: "DotStar"},
                      onChanged: (value) => setState(() => ledType = value),
                    ),
                    BigButton(
                      "Save",
                      onPressed: ledType == -1
                          ? null
                          : () => _saveSetting(
                              send: (poi) =>
                                  poi.sendInt8(ledType, .setLedType, true),
                              errorText: 'Error setting pixel type.',
                              successText: 'Pixel type updated!',
                              onSaved: () => ledType = -1,
                            ),
                    ),
                  ],
                ),
                _SettingsCard(
                  title: "🔄Hardware Version:",
                  children: [
                    const Text(
                      "⚠️ Setting this wrong can permanently damage your Poi circuit board.",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                      ),
                    ),
                    _SettingsDropdown(
                      value: hardwareVersion,
                      options: const {0: "0.0.0", 1: "2.2.1", 2: "3.0.0"},
                      onChanged: (value) =>
                          setState(() => hardwareVersion = value),
                    ),
                    BigButton(
                      "Save",
                      onPressed: hardwareVersion == -1
                          ? null
                          : () => _saveSetting(
                              send: (poi) => poi.sendInt8(
                                hardwareVersion,
                                .setHardwareVersion,
                                true,
                              ),
                              errorText: 'Error setting hardware version.',
                              successText: 'Hardware version updated!',
                              onSaved: () => hardwareVersion = -1,
                            ),
                    ),
                  ],
                ),
                _SettingsCard(
                  title: "Animation Speed Options FPS:",
                  children: [
                    for (final (index, speed) in animationSpeeds.indexed)
                      LabeledButtonSelect(
                        "Animation Speed ${index + 1} FPS",
                        0,
                        2000,
                        (int value) => setState(() {
                          animationSpeeds[index] = value;
                        }),
                        speed,
                      ),
                    BigButton(
                      "Save",
                      onPressed: animationSpeeds.contains(0)
                          ? null
                          : () => _saveSetting(
                              send: (poi) => poi.sendInt16Array(
                                animationSpeeds,
                                .setSpeedOptions,
                                true,
                              ),
                              errorText: 'Error setting speed options.',
                              successText: 'Speed options updated!',
                              onSaved: () =>
                                  animationSpeeds = [0, 0, 0, 0, 0, 0],
                            ),
                    ),
                  ],
                ),
                _SettingsCard(
                  title: "Brightness Options Values:",
                  children: [
                    for (final (index, brightness) in brightnesses.indexed)
                      LabeledButtonSelect(
                        "Brightness ${index + 1}",
                        0,
                        100,
                        (int value) => setState(() {
                          brightnesses[index] = value;
                        }),
                        brightness,
                      ),
                    BigButton(
                      "Save",
                      onPressed: brightnesses.contains(0)
                          ? null
                          : () => _saveSetting(
                              send: (poi) => poi.sendInt8Array(
                                brightnesses,
                                .setBrightnessOptions,
                                true,
                              ),
                              errorText: 'Error setting brightness options.',
                              successText: 'Brightness options updated!',
                              onSaved: () => brightnesses = [0, 0, 0, 0, 0, 0],
                            ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> _saveSetting({
    required Future<void> Function(PoiHardware poi) send,
    required String errorText,
    required String successText,
    required VoidCallback onSaved,
  }) async {
    final model = Provider.of<Model>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      saving = true;
    });
    for (PoiHardware poi in model.connectedPoi!) {
      await send(poi).timeout(const Duration(seconds: 5));
      Confirmation? confirmation = await poi.readResponse().timeout(
        const Duration(seconds: 5),
      );
      if ((confirmation?.success ?? 0) != true) {
        messenger.showSnackBar(SnackBar(content: Text(errorText)));
      }
    }
    messenger.showSnackBar(SnackBar(content: Text(successText)));
    setState(() {
      onSaved();
      saving = false;
    });
  }
}

/// Card with a blue section title above its [children].
class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.blue,
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Full width dropdown with a "------" placeholder at value -1 and one entry
/// per option.
class _SettingsDropdown extends StatelessWidget {
  final int value;
  final Map<int, String> options;
  final ValueChanged<int> onChanged;

  const _SettingsDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      isExpanded: true,
      style: Theme.of(context).textTheme.headlineSmall,
      value: value,
      items: [
        const DropdownMenuItem(value: -1, child: Center(child: Text("------"))),
        for (final option in options.entries)
          DropdownMenuItem(
            value: option.key,
            child: Center(child: Text(option.value)),
          ),
      ],
      onChanged: (value) => onChanged(value!),
    );
  }
}

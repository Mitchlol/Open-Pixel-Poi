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
                const _SettingsInstructionsCard(),
                _DropdownSettingCard(
                  title: "Pattern Shuffle Delay:",
                  value: patternShuffleDuration,
                  options: {for (var i = 1; i <= 120; i++) i: "$i Seconds"},
                  onChanged: (value) => setState(() => patternShuffleDuration = value),
                  onSave: () => _saveSetting(
                    send: (poi) => poi.sendInt8(
                      patternShuffleDuration,
                      .CC_SET_PATTERN_SHUFFLE_DURATION,
                      true,
                    ),
                    errorText: 'Error setting shuffle duration.',
                    successText: 'Shuffle duration updated!',
                    onSaved: () => patternShuffleDuration = -1,
                  ),
                ),
                _DeviceNameSettingCard(
                  deviceName: deviceName,
                  onChanged: (value) => setState(() => deviceName = value),
                  onSave: () => _saveSetting(
                    send: (poi) => poi.sendString(
                      deviceName,
                      .CC_SET_DEVICE_NAME,
                      true,
                    ),
                    errorText: 'Error setting device name.',
                    successText: 'Device name updated!',
                    onSaved: () => deviceName = "",
                  ),
                ),
                _DropdownSettingCard(
                  title: "🔄Pixel Count:",
                  value: ledCount,
                  options: {for (var i = 1; i <= 100; i++) i: "$i"},
                  onChanged: (value) => setState(() => ledCount = value),
                  onSave: () => _saveSetting(
                    send: (poi) => poi.sendInt8(ledCount, .CC_SET_LED_COUNT, true),
                    errorText: 'Error setting pixel count.',
                    successText: 'Pixel count updated!',
                    onSaved: () => ledCount = -1,
                  ),
                ),
                _DropdownSettingCard(
                  title: "🔄Pixel Type:",
                  value: ledType,
                  options: const {0: "N\\A", 1: "NeoPixel", 2: "DotStar"},
                  onChanged: (value) => setState(() => ledType = value),
                  onSave: () => _saveSetting(
                    send: (poi) => poi.sendInt8(ledType, .CC_SET_LED_TYPE, true),
                    errorText: 'Error setting pixel type.',
                    successText: 'Pixel type updated!',
                    onSaved: () => ledType = -1,
                  ),
                ),
                _DropdownSettingCard(
                  title: "🔄Hardware Version:",
                  warning: "⚠️ Setting this wrong can permanently damage your Poi circuit board.",
                  value: hardwareVersion,
                  options: const {0: "0.0.0", 1: "2.2.1", 2: "3.0.0"},
                  onChanged: (value) => setState(() => hardwareVersion = value),
                  onSave: () => _saveSetting(
                    send: (poi) => poi.sendInt8(
                      hardwareVersion,
                      .CC_SET_HARDWARE_VERSION,
                      true,
                    ),
                    errorText: 'Error setting hardware version.',
                    successText: 'Hardware version updated!',
                    onSaved: () => hardwareVersion = -1,
                  ),
                ),
                _NumberOptionsSettingCard(
                  title: "Animation Speed Options FPS:",
                  optionLabel: (number) => "Animation Speed $number FPS",
                  max: 2000,
                  values: animationSpeeds,
                  onChanged: (index, value) => setState(() => animationSpeeds[index] = value),
                  onSave: () => _saveSetting(
                    send: (poi) => poi.sendInt16Array(
                      animationSpeeds,
                      .CC_SET_SPEED_OPTIONS,
                      true,
                    ),
                    errorText: 'Error setting speed options.',
                    successText: 'Speed options updated!',
                    onSaved: () => animationSpeeds = [0, 0, 0, 0, 0, 0],
                  ),
                ),
                _NumberOptionsSettingCard(
                  title: "Brightness Options Values:",
                  optionLabel: (number) => "Brightness $number",
                  max: 100,
                  values: brightnesses,
                  onChanged: (index, value) => setState(() => brightnesses[index] = value),
                  onSave: () => _saveSetting(
                    send: (poi) => poi.sendInt8Array(
                      brightnesses,
                      .CC_SET_BRIGHTNESS_OPTIONS,
                      true,
                    ),
                    errorText: 'Error setting brightness options.',
                    successText: 'Brightness options updated!',
                    onSaved: () => brightnesses = [0, 0, 0, 0, 0, 0],
                  ),
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
      final confirmation = await poi.readResponse().timeout(
        const Duration(seconds: 5),
      ) as Confirmation?;
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

class _SettingsInstructionsCard extends StatelessWidget {
  const _SettingsInstructionsCard();

  @override
  Widget build(BuildContext context) {
    return const _SettingsCard(
      title: "Instructions",
      children: [
        Text(
          "1) Each setting must be saved individually.\n"
          "2) Saving a setting will overwrite the current value on all connected Poi.\n"
          "3) Settings marked with the 🔄 symbol require a reboot of the Poi to take effect. You can batch save multiple settings before a single reboot to activate them all.\n"
          "4) Setting the wrong \"Hardware Version\" can permanently damage your Poi circuit board.",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ],
    );
  }
}

/// A setting picked from a dropdown of [options], which can only be saved once
/// something other than the "------" placeholder is selected.
class _DropdownSettingCard extends StatelessWidget {
  final String title;
  final String? warning;
  final int value;
  final Map<int, String> options;
  final ValueChanged<int> onChanged;
  final VoidCallback onSave;

  const _DropdownSettingCard({
    required this.title,
    this.warning,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: title,
      children: [
        if (warning case final warning?)
          Text(
            warning,
            style: const TextStyle(fontSize: 20, color: Colors.red),
          ),
        _SettingsDropdown(value: value, options: options, onChanged: onChanged),
        BigButton("Save", onPressed: value == -1 ? null : onSave),
      ],
    );
  }
}

class _DeviceNameSettingCard extends StatelessWidget {
  final String deviceName;
  final ValueChanged<String> onChanged;
  final VoidCallback onSave;

  const _DeviceNameSettingCard({
    required this.deviceName,
    required this.onChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: "🔄Device Name:",
      children: [
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: '--------------- Pixel Poi',
          ),
          onChanged: onChanged,
          textCapitalization: TextCapitalization.words,
          inputFormatters: [Utf8TextInputFormatter()],
          maxLength: 15,
        ),
        BigButton("Save", onPressed: deviceName == "" ? null : onSave),
      ],
    );
  }
}

/// One number selector per entry in [values], which can only be saved once
/// every entry has been set to something other than 0.
class _NumberOptionsSettingCard extends StatelessWidget {
  final String title;
  final String Function(int number) optionLabel;
  final int max;
  final List<int> values;
  final void Function(int index, int value) onChanged;
  final VoidCallback onSave;

  const _NumberOptionsSettingCard({
    required this.title,
    required this.optionLabel,
    required this.max,
    required this.values,
    required this.onChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: title,
      children: [
        for (final (index, value) in values.indexed)
          LabeledButtonSelect(
            optionLabel(index + 1),
            0,
            max,
            (int newValue) => onChanged(index, newValue),
            value,
          ),
        BigButton("Save", onPressed: values.contains(0) ? null : onSave),
      ],
    );
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

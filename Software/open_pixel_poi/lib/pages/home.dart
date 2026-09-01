import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/pattern_db.dart';
import '../hardware/poi_hardware.dart';
import '../model.dart';
import '../widgets/connection_state_indicator.dart';
import '../widgets/pattern_import_button.dart';
import './create.dart';
import 'hardware_settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  int tabIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return HardwareSettingsPage();
                },
              ),
            );
          },
          child: Text("Open Pixel Poi"),
        ),
        actions: [
          ...Provider.of<Model>(context).connectedPoi!.map(
            (e) => ConnectionStateIndicator(
              Provider.of<Model>(context).connectedPoi!.indexOf(e),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          getButtons(context),
          getLoading(context),
        ],
      ),
    );
  }

  Widget getLoading(BuildContext buildContext) {
    return ValueListenableBuilder<bool>(
      valueListenable: loading,
      builder: (BuildContext context, bool value, Widget? child) {
        if (!value) {
          return const SizedBox.shrink();
        }
        return Container(
          color: Colors.black38,
          child: Center(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: .min,
                  children: const [
                    Text(
                      "Transmitting Pattern...",
                      textAlign: .center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: .bold,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget getButtons(BuildContext buildContext) {
    return Column(
      children: [
        getPrimarySettings(buildContext),
        Expanded(
          child: getImagesList(buildContext),
        ),
      ],
    );
  }

  Widget getPrimarySettings(BuildContext buildContext) {
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: Column(
        children: [
          TabBar(
            onTap: (index) {
              setState(() {
                tabIndex = index;
              });
            },
            tabs: const [
              Tab(
                icon: Icon(
                  Icons.blur_linear,
                  color: Colors.blue,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.attractions,
                  color: Colors.blue,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.brightness_6,
                  color: Colors.blue,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.sixty_fps_select_rounded,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          if (tabIndex == 1) getPatternSots(buildContext),
          if (tabIndex == 2) getBrightnessButtons(buildContext),
          if (tabIndex == 3) getFrequencyButtons(buildContext),
        ],
      ),
    );
  }

  static const _buttonTextStyle = TextStyle(fontSize: 24, fontWeight: .bold);
  static const _cardTitleStyle = TextStyle(
    color: Colors.blue,
    fontSize: 24,
    fontWeight: .bold,
  );

  void _forEachPoi(void Function(PoiHardware poi) action) {
    for (final poi in Provider.of<Model>(
      context,
      listen: false,
    ).connectedPoi!) {
      action(poi);
    }
  }

  Widget _commandButton(String label, void Function(PoiHardware poi) action) {
    return ElevatedButton(
      onPressed: () => _forEachPoi(action),
      child: Text(label, style: _buttonTextStyle),
    );
  }

  Widget _buttonRow(List<Widget> buttons) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        for (final (index, button) in buttons.indexed) ...[
          if (index != 0) const VerticalDivider(width: 8.0),
          button,
        ],
      ],
    );
  }

  Widget getBrightnessButtons(BuildContext buildContext) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListTile(
          title: const Text("Brightness Level", style: _cardTitleStyle),
          subtitle: Column(
            children: [
              for (final options in const [
                [0, 1, 2],
                [3, 4, 5],
              ])
                _buttonRow([
                  for (final option in options)
                    _commandButton(
                      "${option + 1}",
                      (poi) => poi.sendInt8(
                        option,
                        .CC_SET_BRIGHTNESS_OPTION,
                        false,
                      ),
                    ),
                ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget getFrequencyButtons(BuildContext buildContext) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListTile(
          title: const Text("Animation Speed (FPS)", style: _cardTitleStyle),
          subtitle: Column(
            children: [
              for (final options in const [
                [0, 1, 2],
                [3, 4, 5],
              ])
                _buttonRow([
                  for (final option in options)
                    _commandButton(
                      "${option + 1}",
                      (poi) =>
                          poi.sendInt8(option, .CC_SET_SPEED_OPTION, false),
                    ),
                ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget getPatternSots(BuildContext buildContext) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Pattern Bank", style: _cardTitleStyle),
              subtitle: _buttonRow([
                for (final bank in const [0, 1, 2])
                  _commandButton(
                    "${bank + 1}",
                    (poi) => poi.sendInt8(bank, .CC_SET_BANK, false),
                  ),
                _commandButton(
                  "∞",
                  (poi) => poi.sendCommCode(.CC_SET_BANK_ALL, false),
                ),
              ]),
            ),
            ListTile(
              title: const Text("Pattern Slot", style: _cardTitleStyle),
              subtitle: Column(
                children: [
                  _buttonRow([
                    for (final slot in const [0, 1, 2])
                      _commandButton(
                        "${slot + 1}",
                        (poi) =>
                            poi.sendInt8(slot, .CC_SET_PATTERN_SLOT, false),
                      ),
                  ]),
                  _buttonRow([
                    for (final slot in const [3, 4])
                      _commandButton(
                        "${slot + 1}",
                        (poi) =>
                            poi.sendInt8(slot, .CC_SET_PATTERN_SLOT, false),
                      ),
                    _commandButton(
                      "∞",
                      (poi) => poi.sendCommCode(.CC_SET_PATTERN_ALL, false),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getImagesList(BuildContext buildContext) {
    return Card(
      elevation: 5,
      child: ListTile(
        title: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            const Text(
              'Patterns',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 24,
                fontWeight: .bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return CreatePage();
                        },
                      ),
                    );
                    showNewestPattern();
                  },
                  icon: const Icon(
                    Icons.create_outlined,
                    color: Colors.blue,
                  ),
                ),
                PatternImportButton(() {
                  showNewestPattern();
                }),
              ],
            ),
          ],
        ),
        subtitle: FutureBuilder<List<PatternEntry>>(
          future: Provider.of<Model>(context).patternDB.getImages(context),
          builder:
              (
                BuildContext context,
                AsyncSnapshot<List<PatternEntry>> snapshot,
              ) {
                List<Widget> children;
                if (snapshot.hasData) {
                  List<PatternEntry>? tuples = snapshot.data;
                  tuples ??= List.empty();
                  List<Widget> widgets = List.empty(growable: true);
                  for (var tuple in tuples) {
                    widgets.add(
                      InkWell(
                        onTap: () async {
                          final connectedPoi =
                              Provider.of<Model>(context, listen: false)
                                  .connectedPoi!
                                  .where((poi) => poi.isConncted)
                                  .toList();
                          setState(() {
                            loading.value = true;
                          });
                          for (var poi in connectedPoi) {
                            if (!kIsWeb) {
                              // Calling connect seems to bring device to the front of a magic queue and operate faster, and properly
                              await poi.uart.device
                                  .connect(
                                    timeout: const Duration(seconds: 5),
                                    autoConnect: false,
                                  )
                                  .timeout(Duration(milliseconds: 5250));
                              await poi.uart.device
                                  .clearGattCache(); // Boosts speed too
                            }
                            await poi
                                .sendPattern2(tuple.dbImage)
                                .timeout(
                                  const Duration(seconds: 5),
                                  onTimeout: () {
                                    return false;
                                  },
                                );
                          }
                          setState(() {
                            loading.value = false;
                          });
                        },
                        onLongPress: () => showDialog<void>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text("Edit/Delete Pattern"),
                            content: Text(
                              'Image Stats:\nwidth=${tuple.dbImage.count}\nheight=${tuple.dbImage.height}',
                            ),
                            actionsPadding: const EdgeInsets.all(0.0),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 'Flip');
                                  Provider.of<Model>(context, listen: false)
                                      .patternDB
                                      .invertImage(tuple.dbImage.id!)
                                      .then((value) => setState(() {}));
                                },
                                child: const Text('Flip'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 'Mirror');
                                  Provider.of<Model>(context, listen: false)
                                      .patternDB
                                      .reverseImage(tuple.dbImage.id!)
                                      .then((value) => setState(() {}));
                                },
                                child: const Text('Mirror'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 'Delete');
                                  Provider.of<Model>(context, listen: false)
                                      .patternDB
                                      .deleteImage(tuple.dbImage.id!)
                                      .then((value) => setState(() {}));
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Column(
                            mainAxisAlignment: .center,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: .horizontal,
                                child: SizedBox(
                                  height: 80,
                                  child: tuple.preview,
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
                    );
                  }
                  children = widgets;
                } else if (snapshot.hasError) {
                  children = <Widget>[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error Loading Patterns: ${snapshot.error}'),
                    ),
                  ];
                } else {
                  children = const <Widget>[
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Loading patterns...'),
                    ),
                  ];
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 65.0),
                    child: ListView(
                      controller: _scrollController,
                      children: children,
                    ),
                  ),
                );
              },
        ),
      ),
    );
  }

  void showNewestPattern() {
    setState(() {
      // tabIndex = 0; // This doesn't properly select the tab
    });
    // This is probably the most gross thing ive ever done, and im sorry 😭 (also the animation doesn't work)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent, // Scroll to the bottom
            duration: Duration(milliseconds: 500), // Duration of the animation
            curve: Curves.easeOut, // Smooth easing curve
          );
        });
      });
    });
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/pattern_db.dart';
import '../hardware/models/comm_code.dart';
import '../hardware/poi_hardware.dart';
import '../model.dart';
import '../widgets/connection_state_indicator.dart';
import '../widgets/pattern_import_button.dart';
import '../widgets/status_message.dart';
import './create.dart';
import 'hardware_settings.dart';

const _buttonTextStyle = TextStyle(fontSize: 24, fontWeight: .bold);
const _cardTitleStyle = TextStyle(
  color: Colors.blue,
  fontSize: 24,
  fontWeight: .bold,
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<bool> loading = ValueNotifier<bool>(false);

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
        actions: const [ConnectionStateIndicators()],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const _QuickControlTabs(),
              Expanded(
                child: _StoredPatternsCard(loading: loading),
              ),
            ],
          ),
          _TransmittingOverlay(loading: loading),
        ],
      ),
    );
  }
}

/// Fullscreen overlay shown while a pattern is being transmitted to the poi.
class _TransmittingOverlay extends StatelessWidget {
  final ValueListenable<bool> loading;

  const _TransmittingOverlay({required this.loading});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: loading,
      builder: (BuildContext context, bool value, Widget? child) {
        if (!value) {
          return const SizedBox.shrink();
        }
        return Container(
          color: Colors.black38,
          child: const Center(
            child: ColoredBox(
              color: Colors.white,
              child: StatusMessage(
                title: "Transmitting Pattern...",
                showProgress: true,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Tab bar with the quick controls: pattern slots, brightness, and speed.
class _QuickControlTabs extends StatefulWidget {
  const _QuickControlTabs();

  @override
  State<_QuickControlTabs> createState() => _QuickControlTabsState();
}

class _QuickControlTabsState extends State<_QuickControlTabs> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
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
          if (tabIndex == 1) const _PatternBankAndSlotCard(),
          if (tabIndex == 2)
            const _NumberedOptionsCard(
              title: "Brightness Level",
              code: .CC_SET_BRIGHTNESS_OPTION,
            ),
          if (tabIndex == 3)
            const _NumberedOptionsCard(
              title: "Animation Speed (FPS)",
              code: .CC_SET_SPEED_OPTION,
            ),
        ],
      ),
    );
  }
}

/// Sends [action] to every connected poi when pressed.
class _PoiCommandButton extends StatelessWidget {
  final String label;
  final void Function(PoiHardware poi) action;

  const _PoiCommandButton(this.label, this.action);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        for (final poi in Provider.of<Model>(
          context,
          listen: false,
        ).connectedPoi!) {
          action(poi);
        }
      },
      child: Text(label, style: _buttonTextStyle),
    );
  }
}

class _SpacedButtonRow extends StatelessWidget {
  final List<Widget> buttons;

  const _SpacedButtonRow({required this.buttons});

  @override
  Widget build(BuildContext context) {
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
}

/// Two rows of numbered buttons that send option 0 through 5 with [code].
class _NumberedOptionsCard extends StatelessWidget {
  final String title;
  final CommCode code;

  const _NumberedOptionsCard({required this.title, required this.code});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListTile(
          title: Text(title, style: _cardTitleStyle),
          subtitle: Column(
            children: [
              for (final options in const [
                [0, 1, 2],
                [3, 4, 5],
              ])
                _SpacedButtonRow(
                  buttons: [
                    for (final option in options)
                      _PoiCommandButton(
                        "${option + 1}",
                        (poi) => poi.sendInt8(option, code, false),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatternBankAndSlotCard extends StatelessWidget {
  const _PatternBankAndSlotCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Pattern Bank", style: _cardTitleStyle),
              subtitle: _SpacedButtonRow(
                buttons: [
                  for (final bank in const [0, 1, 2])
                    _PoiCommandButton(
                      "${bank + 1}",
                      (poi) => poi.sendInt8(bank, .CC_SET_BANK, false),
                    ),
                  _PoiCommandButton(
                    "∞",
                    (poi) => poi.sendCommCode(.CC_SET_BANK_ALL, false),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text("Pattern Slot", style: _cardTitleStyle),
              subtitle: Column(
                children: [
                  _SpacedButtonRow(
                    buttons: [
                      for (final slot in const [0, 1, 2])
                        _PoiCommandButton(
                          "${slot + 1}",
                          (poi) => poi.sendInt8(slot, .CC_SET_PATTERN_SLOT, false),
                        ),
                    ],
                  ),
                  _SpacedButtonRow(
                    buttons: [
                      for (final slot in const [3, 4])
                        _PoiCommandButton(
                          "${slot + 1}",
                          (poi) => poi.sendInt8(slot, .CC_SET_PATTERN_SLOT, false),
                        ),
                      _PoiCommandButton(
                        "∞",
                        (poi) => poi.sendCommCode(.CC_SET_PATTERN_ALL, false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The stored patterns, with buttons to create or import new ones. Tapping a
/// pattern transmits it to the connected poi, long pressing lets the user
/// edit or delete it.
class _StoredPatternsCard extends StatefulWidget {
  final ValueNotifier<bool> loading;

  const _StoredPatternsCard({required this.loading});

  @override
  State<_StoredPatternsCard> createState() => _StoredPatternsCardState();
}

class _StoredPatternsCardState extends State<_StoredPatternsCard> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: ListTile(
        title: _StoredPatternsHeader(onPatternAdded: showNewestPattern),
        subtitle: FutureBuilder<List<PatternEntry>>(
          future: Provider.of<Model>(context).patternDB.getImages(context),
          builder: (context, snapshot) {
            final List<Widget> children;
            if (snapshot.hasData) {
              children = [
                for (final entry in snapshot.data ?? <PatternEntry>[])
                  _StoredPatternTile(
                    entry: entry,
                    loading: widget.loading,
                    onChanged: () => setState(() {}),
                  ),
              ];
            } else if (snapshot.hasError) {
              children = [_PatternsLoadError(error: snapshot.error)];
            } else {
              children = const [_PatternsLoading()];
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
    setState(() {});
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

class _StoredPatternTile extends StatelessWidget {
  final PatternEntry entry;
  final ValueNotifier<bool> loading;
  final VoidCallback onChanged;

  const _StoredPatternTile({
    required this.entry,
    required this.loading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final connectedPoi = Provider.of<Model>(
          context,
          listen: false,
        ).connectedPoi!.where((poi) => poi.isConncted).toList();
        loading.value = true;
        for (var poi in connectedPoi) {
          await poi
              .sendPattern2(entry.dbImage)
              .timeout(
                const Duration(seconds: 5),
                onTimeout: () {
                  return false;
                },
              );
        }
        loading.value = false;
      },
      onLongPress: () => showDialog<void>(
        context: context,
        builder: (context) => _EditPatternDialog(entry: entry, onChanged: onChanged),
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
                child: entry.preview,
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
    );
  }
}

/// The "Patterns" title with buttons to create or import a pattern.
/// [onPatternAdded] is called when the user comes back from either flow.
class _StoredPatternsHeader extends StatelessWidget {
  final VoidCallback onPatternAdded;

  const _StoredPatternsHeader({required this.onPatternAdded});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        const Text('Patterns', style: _cardTitleStyle),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreatePage()),
                );
                onPatternAdded();
              },
              icon: const Icon(Icons.create_outlined, color: Colors.blue),
            ),
            PatternImportButton(onPatternAdded),
          ],
        ),
      ],
    );
  }
}

class _PatternsLoading extends StatelessWidget {
  const _PatternsLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('Loading patterns...'),
        ),
      ],
    );
  }
}

class _PatternsLoadError extends StatelessWidget {
  final Object? error;

  const _PatternsLoadError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 60),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text('Error Loading Patterns: $error'),
        ),
      ],
    );
  }
}

/// Lets the user flip, mirror, or delete [entry], calling [onChanged] once
/// the database has been updated.
class _EditPatternDialog extends StatelessWidget {
  final PatternEntry entry;
  final VoidCallback onChanged;

  const _EditPatternDialog({required this.entry, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final patternDB = Provider.of<Model>(context, listen: false).patternDB;
    final id = entry.dbImage.id!;
    return AlertDialog(
      title: const Text("Edit/Delete Pattern"),
      content: Text(
        'Image Stats:\nwidth=${entry.dbImage.count}\nheight=${entry.dbImage.height}',
      ),
      actionsPadding: const EdgeInsets.all(0.0),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Flip');
            patternDB.invertImage(id).then((value) => onChanged());
          },
          child: const Text('Flip'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Mirror');
            patternDB.reverseImage(id).then((value) => onChanged());
          },
          child: const Text('Mirror'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Delete');
            patternDB.deleteImage(id).then((value) => onChanged());
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/pattern_db.dart';
import '../model.dart';

/// Lets the user pick one of the stored patterns.
///
/// Shows the selected pattern's preview under a [label], and opens a
/// selection dialog when tapped. While no pattern has been picked yet,
/// the entry at [defaultIndex] is assigned through [onDefaultAssigned]
/// as soon as the stored patterns have loaded.
class PatternPicker extends StatelessWidget {
  final String label;
  final PatternEntry? selected;
  final ValueChanged<PatternEntry> onSelected;
  final ValueChanged<PatternEntry> onDefaultAssigned;
  final int defaultIndex;
  final int minImages;
  final String tooFewImagesMessage;

  const PatternPicker({
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.onDefaultAssigned,
    required this.tooFewImagesMessage,
    this.defaultIndex = 0,
    this.minImages = 2,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final imagesFuture = Provider.of<Model>(context).patternDB.getImages();
    return InkWell(
      onTap: () => showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("Select $label"),
          content: FutureBuilder<List<PatternEntry>>(
            future: imagesFuture,
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<List<PatternEntry>> snapshot,
                ) {
                  if (snapshot.hasData) {
                    return SizedBox(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              onSelected(snapshot.data![index]);
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: PatternPreview(
                                child: PatternPreviewImage(
                                  bytes: snapshot.data![index].previewBytes,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else if (snapshot.hasError) {
                    _tooFewImagesError(context);
                    return Container();
                  } else {
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
          mainAxisAlignment: .center,
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                ),
              ),
            ),
            PatternPreview(
              child: FutureBuilder<List<PatternEntry>>(
                future: imagesFuture,
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<List<PatternEntry>> snapshot,
                    ) {
                      if (selected != null) {
                        return PatternPreviewImage(
                          bytes: selected!.previewBytes,
                        );
                      } else if (snapshot.hasData &&
                          snapshot.data!.length >= minImages) {
                        final entry = snapshot.data![defaultIndex];
                        onDefaultAssigned(entry);
                        return PatternPreviewImage(bytes: entry.previewBytes);
                      } else if (snapshot.hasError ||
                          (snapshot.hasData &&
                              snapshot.data!.length < minImages)) {
                        _tooFewImagesError(context);
                        return Container();
                      } else {
                        return Container();
                      }
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tooFewImagesError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tooFewImagesMessage)),
    );
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}

/// Renders a stored pattern's JPEG encoded preview bytes.
class PatternPreviewImage extends StatelessWidget {
  final Uint8List bytes;

  const PatternPreviewImage({required this.bytes, super.key});

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      bytes,
      alignment: Alignment.topLeft,
      fit: .fitHeight,
    );
  }
}

/// A pattern preview strip at its standard 80 pixel height, underlined by a
/// thin divider.
class PatternPreview extends StatelessWidget {
  final Widget child;

  const PatternPreview({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      crossAxisAlignment: .start,
      children: [
        SizedBox(height: 80, child: child),
        const SizedBox(width: 100, height: 8),
        const Divider(height: 1, thickness: 1, indent: 0, endIndent: 0),
      ],
    );
  }
}

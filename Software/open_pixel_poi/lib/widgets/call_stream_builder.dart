import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';

typedef CallStreamBuilderWidgetBuilder<T> = Widget Function(
  BuildContext context,
  Function call,
  bool isLoading,
  T value,
);

class CallStreamBuilder<T> extends StatefulWidget {
  static const Duration defaultTimeout = Duration(seconds: 4);

  final CallStreamBuilderWidgetBuilder<T> builder;
  final Function call;
  final Stream<T> stream;
  final Duration timeout;
  final bool autoLoad;

  const CallStreamBuilder({
    required this.builder,
    required this.call,
    required this.stream,
    this.timeout = defaultTimeout,
    this.autoLoad = false,
    super.key,
  });

  @override
  State<CallStreamBuilder<T>> createState() => _CallStreamBuilderState<T>();
}

class _CallStreamBuilderState<T> extends State<CallStreamBuilder<T>> {
  late T responseValue;
  bool isLoading = false;
  CancelableOperation<void>? cancelableOperation;
  late final StreamSubscription<T> subscription;
  late bool autoLoad = widget.autoLoad;

  @override
  void initState() {
    super.initState();
    subscription = widget.stream.listen((event) {
      setState(() {
        responseValue = event;
        isLoading = false;
        final operation = cancelableOperation;
        if (operation != null &&
            !operation.isCanceled &&
            !operation.isCompleted) {
          operation.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (autoLoad) {
      autoLoad = false;
      callWrapper();
    }
    return widget.builder(context, callWrapper, isLoading, responseValue);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void callWrapper() {
    setState(() {
      isLoading = true;
      cancelableOperation = CancelableOperation.fromFuture(
        Future<void>.delayed(widget.timeout).then((value) {
          setState(() {
            isLoading = false;
          });
        }),
      );
    });
    widget.call();
  }
}

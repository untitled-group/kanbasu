import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rxdart/rxdart.dart';

import 'loading.dart';

abstract class StreamWidget<T> extends HookWidget {
  Stream<T> getStream();

  Widget buildWidget(T? data);

  bool showLoadingWidget() => false;

  @override
  Widget build(BuildContext context) {
    return HookBuilder(builder: (context) {
      final triggerRefresh = useState(Completer());

      final itemStream = useMemoized(
          () => getStream().doOnDone(() {
                triggerRefresh.value.complete();
              }).handleError((error, _) {
                triggerRefresh.value.complete();
              }),
          [triggerRefresh.value]);

      final snapshot = useStream(itemStream, initialData: null);
      final data = snapshot.data;

      final widget =
          data == null && snapshot.error == null && showLoadingWidget()
              ? LoadingWidget(isMore: true)
              : buildWidget(data);
      return widget;
    });
  }
}

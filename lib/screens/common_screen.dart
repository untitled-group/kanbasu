import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/scaffolds/common.dart';
import 'package:kanbasu/utils/stream_op.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:kanbasu/widgets/snack.dart';
import 'package:rxdart/rxdart.dart';

abstract class CommonScreen<T> extends HookWidget {
  Stream<T> getStream();

  Widget buildWidget(T data);

  Widget getTitle();

  Widget? getAction(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    return HookBuilder(builder: (context) {
      final manualRefresh = useState(false);
      final triggerRefresh = useState(Completer());

      final itemStream = useMemoized(
        () {
          final stream = getStream()
              // Notify RefreshIndicator to complete refresh
              .doOnDone(() {
            triggerRefresh.value.complete();
          }).doOnError((error, _) {
            showErrorSnack(context, error);
            triggerRefresh.value.complete();
          });

          // if manually refresh, return only latest result
          return manualRefresh.value ? yieldLast(stream) : stream;
        },
        [manualRefresh.value, triggerRefresh.value],
      );

      final snapshot = useStream(itemStream, initialData: null);
      final data = snapshot.data;

      final refreshIndicator = RefreshIndicator(
        onRefresh: () async {
          manualRefresh.value = true;
          final completer = Completer();
          triggerRefresh.value = completer;
          await completer.future;
        },
        child: data == null && snapshot.error == null
            ? LoadingWidget(isMore: true)
            : buildWidget(data!),
      );

      return CommonScaffold(
        title: getTitle(),
        body: refreshIndicator,
        action: getAction(context),
      );
    });
  }
}

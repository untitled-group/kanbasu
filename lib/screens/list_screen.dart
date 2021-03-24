import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/scaffolds/common.dart';
import 'package:kanbasu/scaffolds/stream_list.dart';
import 'package:kanbasu/widgets/snack.dart';
import 'package:kanbasu/utils/stream_op.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:rxdart/rxdart.dart';

/// [ListViewScreen] takes a stream from parent model, and display it in
/// [StreamListScaffold].
abstract class ListViewScreen<T> extends HookWidget {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  Stream<Stream<T>> getStream();

  Widget buildWidget(BuildContext context, T item);

  Widget getTitle();

  Widget? getAction(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    return HookBuilder(builder: (context) {
      final manualRefresh = useState(false);
      final triggerRefresh = useState(Completer());

      final itemStream = useMemoized(() {
        final stream = getStream()
            // The stream may be subscribed multiple times by children,
            // so we need to replay it, with the help of RxDart extension.
            .map((s) => s.shareReplay())
            // Wait until there are enough elements to fill the screen
            .asyncMap(waitFor<T>(10))
            // Notify RefreshIndicator to complete refresh
            .doOnDone(() => triggerRefresh.value.complete())
            .doOnError((error, _) {
          showErrorSnack(context, error);
          triggerRefresh.value.complete();
        });
        if (manualRefresh.value) {
          // if manually refresh, return only latest result
          return yieldLast(stream);
        } else {
          return stream;
        }
      }, [
        manualRefresh.value,
        triggerRefresh.value,
      ]);

      final listSnapshot = useStream(itemStream, initialData: null);

      final listData = listSnapshot.data;

      final refreshIndicator = RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          manualRefresh.value = true;
          final completer = Completer();
          triggerRefresh.value = completer;
          await completer.future;
        },
        child: listData == null && listSnapshot.error == null
            ? LoadingWidget(isMore: true)
            : StreamListScaffold<T>(
                itemBuilder: (item) => buildWidget(context, item),
                itemStream: listData ?? Stream.empty(),
              ),
      );

      return CommonScaffold(
        title: getTitle(),
        body: refreshIndicator,
        action: getAction(context),
      );
    });
  }
}

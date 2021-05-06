import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:kanbasu/widgets/snack.dart';

class FutureSnapshot<T> {
  T? data;
  Object? error;
  FutureSnapshot(this.data, this.error);
}

FutureSnapshot<T> useFutureCombination<T>(
    List<Future<T>> futures, bool refreshWidget,
    {T? initialData}) {
  // return last future with data fetched
  var data;
  var error;
  final snapshots = <AsyncSnapshot<T?>>[];

  for (final future in futures.reversed) {
    final snapshot =
        useFuture(future, initialData: initialData, preserveState: true);
    snapshots.add(snapshot);
  }

  for (final snapshot in snapshots) {
    if (snapshot.data != null) {
      data = snapshot.data;
      break;
    }
    if (snapshot.error != null) {
      error = snapshot.error;
    }
    if (refreshWidget) {
      break;
    }
  }
  return FutureSnapshot(data, error);
}

abstract class RefreshableListWidget<T> extends HookWidget {
  List<Future<T>> getFutures(BuildContext context);

  Widget buildWidget(BuildContext context, T? data);

  bool showLoadingWidget() => false;

  void onError(BuildContext context, Object? error) {
    showErrorSnack(context, error);
  }

  @override
  Widget build(BuildContext context) {
    return HookBuilder(builder: (context) {
      final manualRefresh = useState(false);
      final triggerRefresh = useState(Completer());

      final itemFutures = useMemoized(
        () {
          var hasCompleted = false;
          final completion = triggerRefresh.value;

          // rewrite futures to catch errors inside
          final items = getFutures(context).map((future) async {
            try {
              final result = await future;
              if (!hasCompleted) {
                triggerRefresh.value.complete();
                hasCompleted = true;
              }
              return result;
            } catch (error) {
              onError(context, error);
              if (!hasCompleted) {
                completion.complete();
                hasCompleted = true;
              }
            }
            return null;
          });
          return items.toList();
        },
        [triggerRefresh.value],
      );

      final snapshot = useFutureCombination(itemFutures, manualRefresh.value,
          initialData: null);

      // Always build widget to prevent `use` error
      final hookWidget = buildWidget(context, snapshot.data);

      final widget =
          snapshot.data == null && snapshot.error == null && showLoadingWidget()
              ? LoadingWidget(isMore: true)
              : hookWidget;

      final refreshIndicator = RefreshIndicator(
        onRefresh: () async {
          manualRefresh.value = true;
          final completer = Completer();
          triggerRefresh.value = completer;
          await Future.wait([completer.future, HapticFeedback.mediumImpact()]);
        },
        child: widget,
      );

      return refreshIndicator;
    });
  }
}

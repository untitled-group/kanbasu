import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/widgets/border.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:kanbasu/widgets/snack.dart';
import 'package:rxdart/rxdart.dart';

/// [CommonListView] takes `List<T>` and display the items in view.
/// This scaffold supports batch-update and on-demand-showing stream items.
class CommonListView<T> extends HookWidget {
  final Widget Function(T payload) itemBuilder;
  final List<T>? itemList;
  final bool showLoadingWidget;

  CommonListView({
    required this.itemBuilder,
    required this.itemList,
    required this.showLoadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return HookBuilder(builder: (context) {
      final data = itemList;

      if (data == null && showLoadingWidget) {
        return LoadingWidget(isMore: false);
      }

      final items = (data ?? []).where((i) => i != null).toList();
      final itemsLength = items.length;

      final buildItem = (BuildContext context, int index) {
        if (index == 2 * itemsLength) {
          return Container();
        } else if (index % 2 == 1) {
          return ListBorder();
        } else {
          return itemBuilder(items[index ~/ 2]);
        }
      };

      final list = ListView.builder(
        itemBuilder: buildItem,
        itemCount: items.length * 2 + 1,
      );

      return Scrollbar(child: list);
    });
  }
}

class StreamSnapshot<T> {
  List<T>? data;
  Object? error;
  StreamSnapshot(this.data, this.error);
}

StreamSnapshot<T> useStreamCombination<T>(
    List<Stream<List<T>>> streams, int atLeast, bool refreshWidget,
    {List<T>? initialData}) {
  // return last future with data fetched
  var data;
  var error;

  final snapshots = <AsyncSnapshot<List<T>?>>[];
  var isFirstOne = true;

  for (final stream in streams.reversed) {
    final snapshot = useStream(
        refreshWidget && !isFirstOne ? Stream<List<T>>.empty() : stream,
        initialData: initialData,
        preserveState: true);
    snapshots.add(snapshot);
    isFirstOne = false;
  }

  for (final snapshot in snapshots) {
    final snapshotData = snapshot.data;
    if (snapshotData != null &&
        (snapshot.connectionState == ConnectionState.done ||
            snapshotData.length >= atLeast ||
            (refreshWidget && snapshotData.isNotEmpty))) {
      data = snapshotData;
      break;
    }
    if (snapshot.error != null) {
      error = snapshot.error;
    }
    if (refreshWidget) {
      break;
    }
  }
  return StreamSnapshot(data, error);
}

abstract class RefreshableStreamListWidget<T> extends HookWidget {
  List<Stream<T>> getStreams(BuildContext context);

  Widget buildItem(BuildContext context, T item);

  int atLeast() => 10;

  int refreshInterval() => 200;

  bool showLoadingWidget() => true;

  void dataPostProcess(List<T> data) {}

  Widget buildWidget(BuildContext context, List<T>? data) {
    if (data != null) {
      dataPostProcess(data);
    }

    if (data?.isEmpty ?? false) {
      return CommonListView<void>(
        itemBuilder: (_) => Center(child: Text('这里什么也没有')),
        itemList: [0],
        showLoadingWidget: showLoadingWidget(),
      );
    }

    return CommonListView<T>(
      itemBuilder: (item) => buildItem(context, item),
      itemList: data,
      showLoadingWidget: showLoadingWidget(),
    );
  }

  void onError(BuildContext context, Object? error) {
    showErrorSnack(context, error);
  }

  @override
  Widget build(BuildContext context) {
    return HookBuilder(builder: (context) {
      final manualRefresh = useState(false);
      final triggerRefresh = useState(Completer());
      final itemStreams = useMemoized(
        () {
          var hasCompleted = false;
          final completion = triggerRefresh.value;
          // rewrite streams to catch errors inside
          var items = getStreams(context)
              .map((itemStream) => itemStream.handleError((error, _) {
                    onError(context, error);
                    if (!hasCompleted) {
                      completion.complete();
                      hasCompleted = true;
                    }
                  }).doOnDone(() {
                    if (!hasCompleted) {
                      completion.complete();
                      hasCompleted = true;
                    }
                  }).scan((List<T>? acc, T s, _) {
                    final list = acc ?? List<T>.empty(growable: true);
                    list.add(s);
                    return list;
                  }).defaultIfEmpty([]));

          final interval = refreshInterval();

          if (interval != 0) {
            items = items.map((stream) =>
                stream.throttleTime(Duration(milliseconds: interval)));
          }

          return items.toList();
        },
        [triggerRefresh.value],
      );

      final snapshot = useStreamCombination(
        itemStreams,
        atLeast(),
        manualRefresh.value,
        initialData: null,
      );

      final widget =
          snapshot.data == null && snapshot.error == null && showLoadingWidget()
              ? LoadingWidget(isMore: true)
              : buildWidget(context, snapshot.data);

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

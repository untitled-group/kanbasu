import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/utils/stream_op.dart';
import 'package:kanbasu/widgets/border.dart';
import 'package:kanbasu/widgets/refreshable_stream.dart';
import 'package:kanbasu/widgets/snack.dart';
import 'package:rxdart/rxdart.dart';

/// [_StreamListView] takes `Stream<T>` and display the items in view.
/// This scaffold supports batch-update and on-demand-showing stream items.
class _StreamListView<T> extends HookWidget {
  final Widget Function(T payload) itemBuilder;
  final Stream<T> itemStream;

  _StreamListView({
    required this.itemBuilder,
    required this.itemStream,
  });

  @override
  Widget build(BuildContext context) {
    return HookBuilder(builder: (context) {
      final stream = useMemoized(
        () => itemStream
            .handleError((error, _) => showErrorSnack(context, error))
            .scan((List<T>? acc, T s, _) {
          final list = acc ?? List<T>.empty(growable: true);
          list.add(s);
          return list;
        }).throttleTime(Duration(milliseconds: 200)),
        [itemStream],
      );
      final itemsSnapshot = useStream(stream, initialData: List<T>.empty());

      final Widget list;
      final items = itemsSnapshot.data!;
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

      list = ListView.builder(
        itemBuilder: buildItem,
        itemCount: items.length * 2 + 1,
      );

      return Scrollbar(child: list);
    });
  }
}

abstract class RefreshableStreamListWidget<T>
    extends RefreshableStreamWidget<Stream<T>> {
  Stream<Stream<T>> getStreamStream();

  Widget buildItem(T item);

  @override
  Stream<Stream<T>> getStream() {
    final context = useContext();
    return getStreamStream()
        // The stream may be subscribed multiple times by children,
        // so we need to replay it, with the help of RxDart extension.
        .map((s) => s
            .handleError((error) => showErrorSnack(context, error))
            .shareReplay())
        // Wait until there are enough elements to fill the screen
        .asyncMap(waitFor<T>(10));
  }

  @override
  Widget buildWidget(Stream<T>? data) {
    return _StreamListView<T>(
      itemBuilder: buildItem,
      itemStream: data ?? Stream<T>.empty(),
    );
  }
}

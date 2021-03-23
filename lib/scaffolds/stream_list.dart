import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/widgets/border.dart';
import 'package:rxdart/rxdart.dart';

/// [StreamListScaffold] takes `Stream<T>` and display the items in view.
/// This scaffold supports batch-update and on-demand-showing stream items.
class StreamListScaffold<T> extends HookWidget {
  final Widget Function(T payload) itemBuilder;
  final Stream<T> itemStream;

  StreamListScaffold({
    required this.itemBuilder,
    required this.itemStream,
  });

  @override
  Widget build(BuildContext context) {
    return HookBuilder(builder: (context) {
      final stream = useMemoized(
        () => itemStream.scan((List<T>? acc, T s, _) {
          final list = acc ?? List<T>.empty(growable: true);
          list.add(s);
          return list;
        }).debounceTime(Duration(milliseconds: 200)),
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

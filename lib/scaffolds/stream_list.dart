import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/widgets/border.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:rxdart/rxdart.dart';
import 'common.dart';

class StreamListScaffold<T> extends HookWidget {
  final Widget title;
  final Widget Function()? actionBuilder;
  final Widget Function(T payload) itemBuilder;
  final Stream<T> itemStream;

  StreamListScaffold({
    required this.title,
    required this.itemBuilder,
    required this.itemStream,
    this.actionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: title,
      body: HookBuilder(builder: (context) {
        final stream = useMemoized(() => itemStream
            .scan((List<T>? acc, T s, _) => (acc ?? []) + [s])
            .debounceTime(Duration(milliseconds: 200)));
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

        if (items.isNotEmpty) {
          return Scrollbar(child: list);
        } else {
          return LoadingWidget(isMore: true);
        }
      }),
      action: actionBuilder?.call(),
    );
  }
}

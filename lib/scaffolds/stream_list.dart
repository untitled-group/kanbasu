import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/widgets/border.dart';
import 'common.dart';

class StreamListScaffold<T> extends HookWidget {
  final Widget title;
  final Widget Function()? actionBuilder;
  final Widget Function(T payload) itemBuilder;
  final Future<void> Function() refresh;
  final Stream<T> itemStream;

  StreamListScaffold({
    required this.title,
    required this.itemBuilder,
    required this.itemStream,
    required this.refresh,
    this.actionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: title,
      body: HookBuilder(builder: (context) {
        final itemsSnapshot =
            useFuture(itemStream.toList(), initialData: List<T>.empty());

        final Widget list;

        final items = itemsSnapshot.data!;

        final buildItem = (BuildContext context, int index) {
          if (index == 2 * items.length) {
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
      }),
      action: actionBuilder?.call(),
    );
  }
}

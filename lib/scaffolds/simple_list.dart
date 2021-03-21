import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/widgets/border.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'common.dart';

/// [StreamListScaffold] takes `List<T>` and display the items in view.
class SimpleListScaffold<T> extends HookWidget {
  final Widget title;
  final Widget Function()? actionBuilder;
  final Widget Function(T payload) itemBuilder;
  final List<T> items;

  SimpleListScaffold({
    required this.title,
    required this.itemBuilder,
    required this.items,
    this.actionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: title,
      body: HookBuilder(builder: (context) {
        final Widget list;
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

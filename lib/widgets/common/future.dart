import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:kanbasu/widgets/snack.dart';
import 'package:kanbasu/widgets/common/refreshable_future.dart';

abstract class FutureWidget<T> extends HookWidget {
  List<Future<T>> getFutures(BuildContext context);

  Widget buildWidget(BuildContext context, T? data);

  bool showLoadingWidget() => false;

  void onError(BuildContext context, Object? error) {
    showErrorSnack(context, error);
  }

  @override
  Widget build(BuildContext context) {
    return HookBuilder(builder: (context) {
      final itemFutures = useMemoized(
        () {
          // rewrite futures to catch errors inside
          final items = getFutures(context).map((future) async {
            try {
              return await future;
            } catch (error) {
              onError(context, error);
            }
            return null;
          });
          return items.toList();
        },
        [],
      );

      final snapshot =
          useFutureCombination(itemFutures, false, initialData: null);

      final widget =
          snapshot.data == null && snapshot.error == null && showLoadingWidget()
              ? LoadingWidget(isMore: true)
              : buildWidget(context, snapshot.data);

      return widget;
    });
  }
}

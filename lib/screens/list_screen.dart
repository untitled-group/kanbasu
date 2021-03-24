import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kanbasu/scaffolds/stream_list.dart';
import 'package:kanbasu/screens/common_screen.dart';
import 'package:kanbasu/utils/stream_op.dart';
import 'package:rxdart/rxdart.dart';

/// [ListScreen] takes a stream from parent model, and display it in
/// [StreamListScaffold].
abstract class ListScreen<T> extends CommonScreen<Stream<T>> {
  Stream<Stream<T>> getStreamStream();

  Widget buildItem(T item);

  @override
  Stream<Stream<T>> getStream() {
    return getStreamStream()
        // The stream may be subscribed multiple times by children,
        // so we need to replay it, with the help of RxDart extension.
        .map((s) => s.shareReplay())
        // Wait until there are enough elements to fill the screen
        .asyncMap(waitFor<T>(10));
  }

  @override
  Widget buildWidget(Stream<T> data) {
    return StreamListScaffold<T>(
      itemBuilder: buildItem,
      itemStream: data,
    );
  }
}

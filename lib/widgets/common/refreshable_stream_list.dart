import 'dart:async';
import 'dart:math';

import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:kanbasu/widgets/border.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:kanbasu/widgets/nothing_here.dart';
import 'package:kanbasu/widgets/snack.dart';
import 'package:mutex/mutex.dart';

/// [CommonListView] takes `List<T>` and display the items in view.
/// This scaffold supports batch-update and on-demand-showing stream items.
class CommonListView<T> extends StatelessWidget {
  final Widget Function(T payload) itemBuilder;
  final List<T> itemList;

  CommonListView({
    required this.itemBuilder,
    required this.itemList,
  });

  @override
  Widget build(BuildContext context) {
    final items = itemList;
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
  }
}

class UIState<T> {
  List<T>? data;
  bool refreshing;
  bool maybeStale;

  UIState(this.data, this.refreshing, this.maybeStale);

  UIState.initial()
      : data = null,
        refreshing = false,
        maybeStale = true;
}

abstract class RefreshableStreamListWidget<T> extends StatefulWidget {
  List<Stream<T>> getStreams(BuildContext context);

  Widget buildItem(BuildContext context, T item);

  int atLeast() => 10;

  bool showRefreshingIndicator() => false;

  void dataPostProcess(List<T> data) {}

  void onError(BuildContext context, Object? error) {
    showErrorSnack(context, error);
  }

  @override
  _RefreshableStreamListWidgetState<T> createState() =>
      _RefreshableStreamListWidgetState<T>();
}

class _RefreshableStreamListWidgetState<T>
    extends State<RefreshableStreamListWidget<T>> {
  StreamSubscription<T>? _sub;
  int _refreshCount = 0;
  bool _shown = false;

  UIState<T> state = UIState<T>.initial();

  Future<Completer> _subscribeToNewStream(Stream<T> stream) async {
    await _sub?.cancel();

    final shown = _shown;
    final maybeStale = _refreshCount == 0;
    final itemsBuffer = <T>[];

    final completer = Completer();
    var error = false;

    _sub = stream.listen(
      (item) {
        itemsBuffer.add(item);

        final shouldShow = itemsBuffer.isNotEmpty &&
            itemsBuffer.length % max(widget.atLeast(), 1) == 0 &&
            !shown;
        if (shouldShow) {
          final items = itemsBuffer.toList();
          setState(() => state.data = items);
        }
      },
      onDone: () {
        setState(() => state.refreshing = false);

        final shouldShow = !_shown || !error;
        if (shouldShow) {
          final items = itemsBuffer.toList();
          setState(() => state.data = items);
          if (items.isNotEmpty) _shown = true;
          setState(() => state.maybeStale = maybeStale);
        }
        completer.complete();
      },
      onError: (e) {
        error = true;
        widget.onError(context, e);
      },
    );

    return completer;
  }

  final _refreshMutex = Mutex();
  Future<Completer> _requestRefresh({required bool mannually}) async {
    await _refreshMutex.acquire();

    final streams = widget.getStreams(context);
    final stream = streams[min(streams.length - 1, _refreshCount)];

    if (mannually) setState(() => state.refreshing = true);
    final completer = await _subscribeToNewStream(stream);
    _refreshCount += 1;

    _refreshMutex.release();

    return completer;
  }

  @override
  void initState() {
    super.initState();
    () async {
      final completer = await _requestRefresh(mannually: false);
      await completer.future;
      await _requestRefresh(mannually: widget.showRefreshingIndicator());
    }();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;

    if (state.data == null) {
      child = LoadingWidget(isMore: false);
    } else {
      final data = state.data!;
      if (data.isEmpty) {
        child = state.maybeStale
            ? LoadingWidget(isMore: false)
            : NothingHereWidget();
      } else {
        widget.dataPostProcess(data);
        child = CommonListView<T>(
          itemBuilder: (item) => widget.buildItem(context, item),
          itemList: data,
        );
      }
    }

    final refreshIndicator = DeclarativeRefreshIndicator(
      refreshing: state.refreshing,
      onRefresh: () => _requestRefresh(mannually: true),
      child: child,
    );

    return refreshIndicator;
  }
}

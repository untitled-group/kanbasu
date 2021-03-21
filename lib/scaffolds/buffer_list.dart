import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kanbasu/scaffolds/common.dart';
import 'package:kanbasu/widgets/border.dart';
import 'package:kanbasu/widgets/snack.dart';

class BufferListScaffold<T> extends StatefulWidget {
  final Widget title;
  final Widget Function()? actionBuilder;
  final Widget Function(T payload) itemBuilder;
  final Stream<Stream<T>> Function() ssBuilder;

  BufferListScaffold({
    required this.title,
    required this.itemBuilder,
    required this.ssBuilder,
    this.actionBuilder,
  });

  @override
  _BufferListScaffoldState<T> // fuck the generics
      createState() => _BufferListScaffoldState();
}

class _BufferListScaffoldState<T> extends State<BufferListScaffold<T>> {
  List<T> _items = [];
  bool _manuallyRefreshed = false;

  StreamSubscription<T>? _sub;

  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      await _refreshIndicatorKey.currentState!
          .show(); // refresh using the first stream
      await Future.delayed(Duration(milliseconds: 200));
      await _refreshIndicatorKey.currentState!
          .show(); // refresh using the last stream
    });
  }

  Future<void> _subscribeToNewStream(Stream<T> stream) async {
    await _sub?.cancel();
    await _clear();

    var itemsBuffer = <T>[];
    var completer = Completer<void>();

    _sub = stream.listen(
      (item) {
        if (!completer.isCompleted) {
          itemsBuffer.add(item);
          if (itemsBuffer.length >= 15) {
            setState(() {
              _items = itemsBuffer;
            });
            completer.complete();
          }
        } else {
          setState(() {
            _items.add(item);
          });
        }
      },
      onDone: () {
        // note that streams `onError` may be also `onDone`
        setState(() {
          if (!completer.isCompleted) {
            if (itemsBuffer.isNotEmpty) {
              setState(() {
                _items = itemsBuffer;
              });
            }
            completer.complete();
          }
        });
      },
      onError: (e) {
        setState(() {
          showErrorSnack(context, e);
        });
      },
    );

    await completer.future;
  }

  Future<void> _clear({bool hard = false}) async {
    setState(() {
      if (hard) {
        _items.clear();
      }
    });
  }

  Future<void> _refresh() async {
    final stream;
    if (!_manuallyRefreshed) {
      stream = await widget.ssBuilder().first;
      _manuallyRefreshed = true;
    } else {
      stream = await widget.ssBuilder().last;
    }
    await _subscribeToNewStream(stream);
  }

  Widget _buildBody() {
    final Widget list;

    list = ListView.builder(
      itemBuilder: _buildItem,
      itemCount: _items.length * 2 + 1,
    );

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: Scrollbar(child: list),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index == 2 * _items.length) {
      return Container();
    } else if (index % 2 == 1) {
      return ListBorder();
    } else {
      return widget.itemBuilder(_items[index ~/ 2]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _clear(hard: true);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: widget.title,
      body: _buildBody(),
      action: widget.actionBuilder?.call(),
    );
  }
}

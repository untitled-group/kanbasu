import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kanbasu/scaffolds/common.dart';
import 'package:kanbasu/widgets/border.dart';
import 'package:kanbasu/widgets/error.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class BufferListPayload<T, K> {
  Iterable<T> items;
  bool hasMore;
  K? nextCursor;

  BufferListPayload({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });
}

class BufferListScaffold<T, K> extends StatefulWidget {
  final Widget title;
  final Widget Function()? actionBuilder;
  final Widget Function(T payload) itemBuilder;
  final Stream<Stream<T>> ss;

  BufferListScaffold({
    required this.title,
    required this.itemBuilder,
    required this.ss,
    this.actionBuilder,
  });

  @override
  _BufferListScaffoldState<T, K> // fuck the generics
      createState() => _BufferListScaffoldState();
}

class _BufferListScaffoldState<T, K> extends State<BufferListScaffold<T, K>> {
  List<T> _items = [];
  bool _hasMore = true;
  bool _nowLoading = false;
  String? _error;

  Stream<T>? _stream;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(onScroll);
    _ssListen();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _ssListen() async {
    await for (final stream in widget.ss) {
      setState(() {
        _stream = stream.asBroadcastStream();
      });
      print('STREAM');
      await _doRefresh(hard: true);
      await Future.delayed(Duration(seconds: 3));
    }
  }

  Future<BufferListPayload<T, K>> _streamFetch() async {
    const N_LOAD = 20;
    print(_stream);
    final items = (await _stream?.take(N_LOAD).toList()) ?? <T>[];
    print('Get ${items.length}'); // FIXME: always get 0 from the second `take`
    return BufferListPayload(
      items: items,
      hasMore: true,
    );
  }

  double get _scrollDistance {
    double ret;
    try {
      ret = _controller.position.maxScrollExtent - _controller.offset;
      print('$ret, $_nowLoading, $_hasMore');
    } catch (e) {
      print('Nope');
      ret = 0;
    }
    return ret;
  }

  void onScroll() {
    if (_scrollDistance < 300 &&
        !_controller.position.outOfRange &&
        !_nowLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      _nowLoading = true;
    });

    try {
      final payload = await _streamFetch();
      // FIXME: empty if both streams are consumed,
      //  we should reconstruct a stream on user's refreshing
      setState(() {
        _items.addAll(payload.items);
        _hasMore = payload.hasMore;
      });
    } catch (e) {
      setState(() {
        if (e is DioError) {
          _error = e.error.toString();
        } else {
          _error = e.runtimeType.toString();
        }
      });
      rethrow;
    } finally {
      setState(() {
        _nowLoading = false;
      });
    }
  }

  Future<void> _doRefresh({bool hard = false}) async {
    setState(() {
      if (hard) {
        _items.clear();
      }
      _hasMore = true;
      _nowLoading = true;
      _error = null;
    });

    try {
      final payload = await _streamFetch();
      setState(() {
        _items = payload.items.toList();
        _hasMore = payload.hasMore;
      });
    } catch (e) {
      setState(() {
        if (e is DioError) {
          _error = e.error.toString();
        } else {
          _error = e.runtimeType.toString();
        }
      });
      rethrow;
    } finally {
      setState(() {
        _nowLoading = false;
      });
    }

    // avoid failing to load more due to insufficient data
    while (_scrollDistance == 0 && !_nowLoading && _hasMore) {
      await _loadMore();
    }
  }

  Widget _buildBody() {
    final Widget list;

    if (_error != null) {
      list = ListView(
        children: [
          KErrorWidget(
            errorText: _error!,
            tips: '''
Check:
  - the network connectivity,
  - or if you provide a valid api key in "Me -> Settings".
                ''',
            onTap: _doRefresh,
          )
        ],
      );
    } else {
      list = ListView.builder(
        controller: _controller,
        itemBuilder: _buildItem,
        itemCount: _items.length * 2 + 1,
      );
    }

    return RefreshIndicator(
        onRefresh: _doRefresh, child: Scrollbar(child: list));
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index == 2 * _items.length) {
      if (_hasMore) {
        return LoadingWidget(isMore: _items.isNotEmpty);
      } else {
        return Container();
      }
    } else if (index % 2 == 1) {
      return ListBorder();
    } else {
      return widget.itemBuilder(_items[index ~/ 2]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _doRefresh(hard: true);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
        title: widget.title,
        body: _buildBody(),
        action: widget.actionBuilder?.call());
  }
}

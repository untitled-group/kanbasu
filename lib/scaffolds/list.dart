import 'package:flutter/material.dart';
import 'package:kanbasu/scaffolds/common.dart';
import 'package:kanbasu/widgets/border.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:kanbasu/widgets/snack.dart';

class ListPayload<T, K> {
  Iterable<T> items;
  bool hasMore;
  K? nextCursor;

  ListPayload({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });
}

class ListScaffold<T, K> extends StatefulWidget {
  final Widget title;
  final Widget Function()? actionBuilder;
  final Widget Function(T payload) itemBuilder;
  final Future<ListPayload<T, K>> Function(K? cursor) fetch;

  ListScaffold({
    required this.title,
    required this.itemBuilder,
    required this.fetch,
    this.actionBuilder,
  });

  @override
  _ListScaffoldState<T, K> // fuck the generics
      createState() => _ListScaffoldState();
}

class _ListScaffoldState<T, K> extends State<ListScaffold<T, K>> {
  List<T> _items = [];
  bool _hasMore = true;
  bool _nowLoading = false;
  K? _nextCursor;
  bool _error = false;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(onScroll);
  }

  double get _scrollDistance =>
      _controller.position.maxScrollExtent - _controller.offset;

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
      final payload = await widget.fetch(_nextCursor);
      setState(() {
        _items.addAll(payload.items);
        _hasMore = payload.hasMore;
        _nextCursor = payload.nextCursor;
      });
    } catch (e) {
      showErrorSnack(context, e);
      _error = true;
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
      _nextCursor = null;
      _error = false;
    });

    try {
      final payload = await widget.fetch(null);
      setState(() {
        _items = payload.items.toList();
        _hasMore = payload.hasMore;
        _nextCursor = payload.nextCursor;
      });
    } catch (e) {
      showErrorSnack(context, e);
      _error = true;
    } finally {
      setState(() {
        _nowLoading = false;
      });
    }

    // avoid failing to load more due to insufficient data
    while (_scrollDistance == 0 && !_nowLoading && _hasMore && !_error) {
      await _loadMore();
    }
  }

  Widget _buildBody() {
    final Widget list;

    list = ListView.builder(
      controller: _controller,
      itemBuilder: _buildItem,
      itemCount: _items.length * 2 + 1,
    );

    return RefreshIndicator(
      onRefresh: _doRefresh,
      child: Scrollbar(child: list),
    );
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

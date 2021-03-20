import 'package:flutter/material.dart';
import 'package:kanbasu/scaffolds/common.dart';
import 'package:kanbasu/widgets/border.dart';
import 'package:kanbasu/widgets/loading.dart';

class ListPayload<T, K> {
  Iterable<T> items;
  bool hasMore;

  ListPayload({
    required this.items,
    required this.hasMore,
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

  Future<void> _doRefresh() async {
    final _payload = await widget.fetch(null);
    setState(() {
      _hasMore = _payload.hasMore;
      _items = _payload.items.toList();
    });
  }

  Widget _buildBody() {
    final list = Scrollbar(
      child: ListView.builder(
        itemBuilder: _buildItem,
        itemCount: _items.length * 2 + 1,
      ),
    );

    return RefreshIndicator(onRefresh: _doRefresh, child: list);
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
  void initState() {
    super.initState();
    _doRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
        title: widget.title,
        body: _buildBody(),
        action: widget.actionBuilder?.call());
  }
}

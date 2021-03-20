import 'package:flutter/material.dart';
import 'package:kanbasu/scaffolds/common.dart';

class ListPayload<T, K> {
  K cursor;
  Iterable<T> items;
  bool hasMore;

  ListPayload({
    required this.items,
    required this.cursor,
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
  _ListScaffoldState createState() => _ListScaffoldState();
}

class _ListScaffoldState<T, K> extends State<ListScaffold<T, K>> {
  List<T> items = [];
  bool _hasMore = false;

  Future<void> _onRefresh() async {
    final _payload = await widget.fetch(null);
    setState(() {
      _hasMore = _payload.hasMore;
      items = _payload.items.toList();
    });
  }

  Widget _buildBody() {
    final list = Scrollbar(
      child: ListView.builder(
        itemBuilder: _buildItem,
      ),
    );

    return RefreshIndicator(onRefresh: _onRefresh, child: list);
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index == 2 * items.length) {
      if (_hasMore) {
        return Container(); // TODO: loading widget
      } else {
        return Container();
      }
    } else if (index % 2 == 1) {
      return Container(
        height: 1,
        color: Colors.grey,
      );
    } else {
      return widget.itemBuilder(items[index ~/ 2]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(title: widget.title, body: _buildBody());
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kanbasu/scaffolds/common.dart';
import 'package:kanbasu/widgets/border.dart';
import 'package:kanbasu/widgets/error.dart';
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
  String? error;

  Future<void> _doRefresh({bool hard = false}) async {
    if (hard) {
      setState(() {
        _items.clear();
      });
    }
    error = null;

    try {
      final _payload = await widget.fetch(null);
      setState(() {
        _hasMore = _payload.hasMore;
        _items = _payload.items.toList();
      });
    } catch (e) {
      setState(() {
        if (e is DioError) {
          error = e.error.toString();
        } else {
          error = e.runtimeType.toString();
        }
      });
      rethrow;
    }
  }

  Widget _buildBody() {
    final Widget list;

    if (error != null) {
      list = ListView(
        children: [
          KErrorWidget(
            errorText: error!,
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

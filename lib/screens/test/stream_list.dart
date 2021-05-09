import 'package:flutter/material.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';

class StreamListTestView extends RefreshableStreamListWidget<String> {
  @override
  int atLeast() => 888;

  @override
  bool showRefreshingIndicator() => true;

  StreamListTestView();

  @override
  List<Stream<String>> getStreams(context) => [
        Stream.fromFuture(
          Future.delayed(Duration(milliseconds: 500), () => 'old'),
        ),
        Stream.fromFuture(
          Future.delayed(Duration(milliseconds: 1000), () => 'new'),
        ),
        Stream.fromFutures([
          Future.delayed(Duration(milliseconds: 1000), () => 'newnew 1000'),
          Future.delayed(Duration(milliseconds: 1500), () => 'newnew 1500'),
        ]),
      ];

  @override
  Widget buildItem(context, String item) => Text(item);
}

class StreamListTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(runtimeType.toString())),
      body: StreamListTestView(),
    );
  }
}

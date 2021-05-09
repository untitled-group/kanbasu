import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/common/refreshable_future.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
import 'package:provider/provider.dart';

Widget wrapWidgetForTest(Widget child) {
  final model = Model();
  return ChangeNotifierProvider(
    create: (context) => model,
    child: MaterialApp(home: child),
  );
}

class TestStruct {
  final String data;
  TestStruct(this.data);
}

// ignore: deprecated_member_use_from_same_package
// class TestListScreen extends RefreshableStreamListWidget<TestStruct> {
//   @override
//   List<Stream<TestStruct>> getStreamStream(context) => List.of([
//         Stream.fromIterable([TestStruct('old')]),
//         Stream.fromIterable([TestStruct('new')])
//       ]);

//   @override
//   Widget buildItem(context, TestStruct item) => Text(item.data);
// }

class TestFutureScreen extends RefreshableListWidget<TestStruct> {
  @override
  List<Future<TestStruct>> getFutures(context) =>
      [Future.value(TestStruct('old')), Future.value(TestStruct('new'))];

  @override
  Widget buildWidget(context, TestStruct? item) =>
      Text(item?.data ?? 'Loading');

  @override
  bool showLoadingWidget() {
    return false;
  }
}

// ignore: must_be_immutable
class TestFutureScreenError extends RefreshableListWidget<TestStruct> {
  @override
  List<Future<TestStruct>> getFutures(context) =>
      List.of([Future.value(TestStruct('old')), Future.error('Test Error')]);

  @override
  Widget buildWidget(context, TestStruct? item) =>
      Text(item?.data ?? 'Loading');

  bool onErrorCalled = false;

  @override
  void onError(BuildContext context, Object? error) {
    onErrorCalled = true;
  }

  @override
  bool showLoadingWidget() {
    return false;
  }
}

class TestStreamScreen extends RefreshableStreamListWidget<TestStruct> {
  @override
  int atLeast() {
    return 0;
  }

  @override
  List<Stream<TestStruct>> getStreams(context) => [
        Stream.fromIterable([TestStruct('old')]),
        Stream.fromIterable([TestStruct('new')]),
      ];

  @override
  Widget buildItem(context, TestStruct item) => Text(item.data);
}

// ignore: must_be_immutable
class TestStreamScreenError extends RefreshableStreamListWidget<TestStruct> {
  @override
  int atLeast() {
    return 100;
  }

  @override
  List<Stream<TestStruct>> getStreams(context) => [
        Stream.fromFuture(Future.value(TestStruct('old'))),
        Stream.error('Test Error')
      ];

  @override
  Widget buildItem(context, TestStruct item) => Text(item.data);

  bool onErrorCalled = false;

  @override
  void onError(BuildContext context, Object? error) {
    onErrorCalled = true;
  }
}

void main() {
  group('RefreshableStreamWidget', () {
    testWidgets('should show latest information', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWidgetForTest(TestFutureScreen()));
      await tester.pumpAndSettle();
      expect(find.text('new'), findsOneWidget);
    });

    testWidgets('should correctly handle error', (WidgetTester tester) async {
      final widget = TestFutureScreenError();
      await tester.pumpWidget(wrapWidgetForTest(widget));
      await tester.pumpAndSettle();
      expect(find.text('old'), findsOneWidget);
      expect(widget.onErrorCalled, equals(true));
    });
  });

  // group('RefreshableStreamListWidget', () {
  //   testWidgets('should show latest information', (WidgetTester tester) async {
  //     await tester.pumpWidget(wrapWidgetForTest(TestStreamScreen()));
  //     await tester.pumpAndSettle();
  //     expect(find.text('new'), findsOneWidget);
  //   });

  //   testWidgets('should correctly handle error', (WidgetTester tester) async {
  //     final widget = TestStreamScreenError();
  //     await tester.pumpWidget(wrapWidgetForTest(widget));
  //     await tester.pumpAndSettle();
  //     expect(widget.onErrorCalled, equals(true));
  //   });
  // });
}

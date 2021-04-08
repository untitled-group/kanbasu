// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/screens/list_screen.dart';
import 'package:provider/provider.dart';

Widget wrapWidgetForTest(Widget child) {
  final model = Model();
  return ChangeNotifierProvider(
    create: (context) => model,
    child: MaterialApp(home: TestListScreen()), // for rebirthing the app
  );
}

class TestStruct {
  final String data;
  TestStruct(this.data);
}

// ignore: deprecated_member_use_from_same_package
class TestListScreen extends ListScreen<TestStruct> {
  @override
  Stream<Stream<TestStruct>> getStreamStream() => Stream.fromIterable([
        Stream.fromIterable([TestStruct('old')]),
        Stream.fromIterable([TestStruct('new')])
      ]);

  @override
  Widget getTitle(s) => Text('Test Screen');

  @override
  Widget buildItem(TestStruct item) => Text(item.data);
}

void main() {
  group('ListScreen', () {
    testWidgets('should show latest information', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWidgetForTest(TestListScreen()));
      await tester.pumpAndSettle();
      expect(find.text('new'), findsOneWidget);
    });
  });
}

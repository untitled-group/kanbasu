import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kanbasu/screens/list_screen.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/widgets/activity.dart';
import 'package:kanbasu/models/model.dart';

class ActivitiesScreen extends ListViewScreen<ActivityItem> {
  @override
  Stream<Stream<ActivityItem>> getStream(Model model) =>
      model.canvas.getCurrentUserActivityStream();

  @override
  Widget getTitle() => Text('Activities');

  @override
  Widget buildWidget(ActivityItem item) => ActivityWidget(item);
}

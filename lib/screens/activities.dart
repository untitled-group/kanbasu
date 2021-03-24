import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/screens/list_screen.dart';
import 'package:kanbasu/widgets/activity.dart';
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class ActivitiesScreen extends ListScreen<ActivityItem> {
  @override
  Stream<Stream<ActivityItem>> getStreamStream() =>
      Provider.of<Model>(useContext()).canvas.getCurrentUserActivityStream();

  @override
  Widget getTitle() => Text('title.activities'.tr());

  @override
  Widget buildItem(ActivityItem item) => ActivityWidget(item);
}

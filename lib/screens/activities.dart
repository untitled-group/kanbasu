import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/widgets/activity.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/refreshable_stream_list.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class _ActivitiesView extends RefreshableStreamListWidget<ActivityItem> {
  @override
  Stream<Stream<ActivityItem>> getStreamStream() =>
      Provider.of<Model>(useContext()).canvas.getCurrentUserActivityStream();

  @override
  Widget buildItem(ActivityItem item) => ActivityWidget(item);
}

class ActivitiesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('title.activities'.tr()),
      ),
      body: _ActivitiesView(),
    );
  }
}

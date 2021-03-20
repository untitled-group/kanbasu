import 'package:flutter/material.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/scaffolds/list.dart';
import 'package:kanbasu/widgets/activity.dart';
import 'package:provider/provider.dart';

class ActivitiesScreen extends StatefulWidget {
  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  @override
  Widget build(BuildContext context) {
    return ListScaffold<ActivityItem, int>(
        title: Text('Activities'),
        itemBuilder: (item) {
          return ActivityWidget(item);
        },
        fetch: (_cursor) async {
          final model = context.read<Model>();
          final activities = await model.canvas.getCurrentUserActivityStream();
          return ListPayload(items: activities.data, hasMore: false);
        });
  }
}

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
    final model = Provider.of<Model>(context);
    // FIXME: a change of `model.canvas` won't make the widget rebuild

    return ListScaffold<ActivityItem, int>(
      title: Text('Activities'),
      itemBuilder: (item) {
        return ActivityWidget(item);
      },
      fetch: (cursor) async {
        final stream = await model.canvas.getCurrentUserActivityStreamF();
        final activities = await stream.skip(cursor ?? 0).take(5).toList();
        return ListPayload(items: activities, hasMore: true);
      },
    );
  }
}

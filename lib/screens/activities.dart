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
      fetch: (_cursor) async {
        const N_LOAD = 10;

        final cursor = _cursor ?? 0;
        final stream = await model.canvas.getCurrentUserActivityStreamF();
        final activities = await stream.skip(cursor).take(N_LOAD).toList();

        return ListPayload(
            items: activities,
            hasMore: activities.length == N_LOAD,
            nextCursor: cursor + activities.length);
      },
    );
  }
}

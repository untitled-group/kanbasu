import 'package:flutter/material.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/scaffolds/buffer_list.dart';
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

    return BufferListScaffold<ActivityItem>(
      title: Text('Activities'),
      itemBuilder: (item) => ActivityWidget(item),
      ssBuilder: model.canvas.getCurrentUserActivityStream,
    );
  }
}

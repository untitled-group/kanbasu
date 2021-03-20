import 'package:flutter/material.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/scaffolds/list.dart';

class ActivitiesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListScaffold<ActivityItem, int>(
        title: Text('Activities'),
        itemBuilder: (item) {
          return Container(child: Text(item.toString()));
        },
        fetch: () async {
          return ListPayload(items: [], hasMore: true);
        });
  }
}

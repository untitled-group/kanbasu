import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/widgets/activity.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/link.dart';
import 'package:kanbasu/widgets/refreshable_stream_list.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class _ActivitiesView extends RefreshableStreamListWidget<ActivityItem> {
  @override
  List<Stream<ActivityItem>> getStreamStream(context) =>
      Provider.of<Model>(context).canvas.getCurrentUserActivityStream();

  @override
  Widget buildItem(context, ActivityItem item) => Link(
      path: '/course/${item.courseId}/${_typeToTabId[item.type] ?? ''}',
      child: ActivityWidget(item));
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

// AssessmentRequest, Announcement, Collaboration, Conference, Submission, Message, Conversation, DiscussionTopic
final Map<String, String> _typeToTabId = {
  'Announcement': 'announcements',
  'Submission': 'assignments',
  'Message': 'assignments',
  'DiscussionTopic': 'discussions'
};

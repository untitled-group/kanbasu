import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kanbasu/aggregation.dart';
import 'package:kanbasu/models/brief_info.dart';
import 'package:kanbasu/widgets/activity.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/link.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class _ActivitiesView extends RefreshableStreamListWidget<BriefInfo> {
  Stream<BriefInfo> getAggregationStream(context, bool useOnlineData) async* {
    final stream = aggregate(Provider.of<Model>(context, listen: false).canvas,
        useOnlineData: useOnlineData);
    if (useOnlineData) {
      // TODO: do not buffer items, avoid unnecessary updates on ui part
      final items = await stream.toList();
      for (final item in items) {
        yield item;
      }
    } else {
      await for (final item in stream) {
        yield item;
      }
    }
  }

  @override
  void dataPostProcess(List<BriefInfo> data) {
    data.sort((a, b) {
      final createdAtCmp = -a.createdAt.compareTo(b.createdAt);
      if (createdAtCmp == 0) {
        return a.title.compareTo(b.title);
      } else {
        return createdAtCmp;
      }
    });
  }

  @override
  List<Stream<BriefInfo>> getStreams(context) => [
        getAggregationStream(context, false),
        getAggregationStream(context, true),
      ];

  @override
  Widget buildItem(context, BriefInfo item) => Link(
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

final _typeToTabId = {
  BriefInfoType.announcements: 'announcements',
  BriefInfoType.assignment: 'assignments',
  BriefInfoType.file: 'files',
  BriefInfoType.grading: 'assignments',
  BriefInfoType.assignmentDue: 'assignments'
};

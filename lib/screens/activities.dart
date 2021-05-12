import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:kanbasu/aggregation.dart';
import 'package:kanbasu/models/brief_info.dart';
import 'package:kanbasu/widgets/activity.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/link.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeago;

class _ActivitiesView extends RefreshableStreamListWidget<BriefInfo> {
  Stream<BriefInfo> getAggregationStream(
      BuildContext context, bool useOnlineData) {
    final stream = aggregate(
      context.read<Model>().canvas,
      useOnlineData: useOnlineData,
    );
    return stream;
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
        getAggregationStream(context, true).doOnDone(() {
          final model = context.read<Model>();
          model.setAggregatedNow();
        }),
      ];

  @override
  Widget buildItem(context, BriefInfo item) => Link(
        path: '/course/${item.courseId}/${_typeToTabId[item.type] ?? ''}',
        child: ActivityWidget(item),
      );

  @override
  bool showRefreshingIndicator() => true;
}

class ActivitiesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<Model>();
    final aggregatedAt = model.aggregatedAt;

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('title.activities'.tr()),
        Text(
          aggregatedAt != null
              ? timeago.format(
                  aggregatedAt,
                  locale: context.locale.toStringWithSeparator(),
                )
              : '',
          style: TextStyle(fontSize: 12, color: model.theme.tertiaryText),
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: title,
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

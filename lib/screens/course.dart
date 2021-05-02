import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/tab.dart' as t;
import 'package:kanbasu/screens/course/announcements.dart';
import 'package:kanbasu/screens/course/files.dart';
import 'package:kanbasu/screens/course/assignments.dart';
import 'package:kanbasu/screens/course/home.dart';
import 'package:kanbasu/screens/course/syllabus.dart';
import 'package:kanbasu/utils/stream_op.dart';
import 'package:kanbasu/widgets/common/refreshable_future.dart';
import 'package:kanbasu/widgets/common/future.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class _CourseTabView extends FutureWidget<void> {
  final int courseId;
  final Course? course;
  final t.Tab tab;

  _CourseTabView(
    this.courseId,
    this.course,
    this.tab,
  );

  @override
  Widget buildWidget(context, void data) {
    switch (tab.id) {
      case 'home':
        return CourseHomeScreen();
      case 'announcements':
        return CourseAnnouncementsScreen(courseId);
      case 'files':
        return CourseFilesScreen(courseId);
      case 'syllabus':
        return course != null ? CourseSyllabusScreen(course!) : Container();
      case 'assignments':
        return CourseAssignmentsScreen(courseId);
      default:
        return Center(child: Text('It\'s ${tab.id} here'));
    }
  }

  @override
  List<Future<void>> getFutures(context) => [];
}

class _CourseMeta {
  final Course? course;
  final List<t.Tab> tabs;

  _CourseMeta(this.course, this.tabs);
}

class CourseScreen extends RefreshableListWidget<_CourseMeta> {
  final int courseId;
  final String? initialTabId;

  CourseScreen({required this.courseId, this.initialTabId});

  @override
  bool showLoadingWidget() => true;

  @override
  Widget buildWidget(context, _CourseMeta? data) {
    final course = data?.course;
    final tabs = data?.tabs;

    final title = Text(course?.name ?? 'title.course'.tr());

    if (tabs == null) {
      return Scaffold(
        appBar: AppBar(title: title),
      );
    } else {
      final validTabs = _filterTabs(tabs);

      final action = course == null
          ? null
          : IconButton(
              icon: Icon(Icons.folder),
              tooltip: 'tabs.file'.tr(),
              onPressed: () {},
            );

      final tabBar = TabBar(
        tabs: validTabs.map((t) => Tab(text: t.label)).toList(),
        isScrollable: true,
      );

      final scaffold = Scaffold(
          appBar: AppBar(
            title: title,
            actions: [action].whereType<Widget>().toList(),
            bottom: tabBar,
          ),
          body: TabBarView(
            children: validTabs
                .map((t) => _CourseTabView(courseId, course, t))
                .toList(),
          ));

      final initialIndex = initialTabId == null
          ? 0
          : max(validTabs.indexWhere((t) => t.id == initialTabId), 0);

      return DefaultTabController(
        length: validTabs.length,
        initialIndex: initialIndex,
        child: scaffold,
      );
    }
  }

  @override
  List<Future<_CourseMeta>> getFutures(context) {
    final canvas = Provider.of<Model>(context).canvas;
    return zip2(
      canvas.getCourse(courseId),
      canvas.getTabs(courseId).map((s) => s.toList()),
      (Course? course, List<t.Tab> tabs) => _CourseMeta(course, tabs),
    ).toList();
  }
}

List<t.Tab> _filterTabs(List<t.Tab> ts) {
  final excludeIds = ['people', 'grades'];
  return ts
      .where((t) =>
          t.type != 'external' &&
          t.visibility == 'public' &&
          !excludeIds.contains(t.id))
      .toList();
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/resolver_model.dart';
import 'package:kanbasu/models/tab.dart' as t;
import 'package:kanbasu/screens/course/announcements.dart';
import 'package:kanbasu/screens/course/discussions.dart';
import 'package:kanbasu/screens/course/files.dart';
import 'package:kanbasu/screens/course/assignments.dart';
import 'package:kanbasu/screens/course/home.dart';
import 'package:kanbasu/screens/course/syllabus.dart';
import 'package:kanbasu/utils/stream_op.dart';
import 'package:kanbasu/widgets/common/refreshable_future.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class _CourseTabView extends StatelessWidget {
  final int courseId;
  final Course? course;
  final t.Tab tab;

  _CourseTabView(this.courseId, this.course, this.tab);

  @override
  Widget build(BuildContext context) {
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
      case 'discussions':
        return CourseDiscussionsScreen(courseId);
      default:
        return Center(child: Text('It\'s ${tab.id} here'));
    }
  }
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

      final tabBar = TabBar(
        tabs: validTabs.map((t) => Tab(text: t.label)).toList(),
        isScrollable: true,
      );

      final initialIndex = initialTabId == null
          ? 0
          : max(validTabs.indexWhere((t) => t.id == initialTabId), 0);

      return DefaultTabController(
        length: validTabs.length,
        initialIndex: initialIndex,
        child: HookBuilder(builder: (BuildContext context) {
          final children = validTabs
              .map((t) => _CourseTabView(courseId, course, t))
              .toList();

          final tabBarView = TabBarView(children: children);

          final resolverModel = Provider.of<ResolverModel>(context);

          final action = course == null
              ? null
              : IconButton(
                  icon: Icon(Icons.file_download),
                  tooltip: 'tabs.download_all_file'.tr(),
                  onPressed: () {
                    final filesTab =
                        validTabs.indexWhere((t) => t.id == 'files');
                    if (filesTab >= 0) {
                      DefaultTabController.of(context)?.animateTo(filesTab);
                      resolverModel.requestDownloadAll(courseId);
                    }
                  });

          return Scaffold(
              appBar: AppBar(
                title: title,
                actions: [action].whereType<Widget>().toList(),
                bottom: tabBar,
              ),
              body: tabBarView);
        }),
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
  final excludeIds = ['people', 'grades', 'home'];
  return ts
      .where((t) =>
          t.type != 'external' &&
          t.visibility == 'public' &&
          !excludeIds.contains(t.id))
      .toList();
}

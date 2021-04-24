import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/tab.dart' as t;
import 'package:kanbasu/router.dart';
import 'package:kanbasu/screens/course/announcements.dart';
import 'package:kanbasu/screens/course/home.dart';
import 'package:kanbasu/widgets/refreshable_stream.dart';
import 'package:kanbasu/widgets/stream.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rxdart/rxdart.dart';

class _CourseTabView extends RefreshableStreamWidget<void> {
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
      default:
        return Center(child: Text('It\'s ${tab.id} here'));
    }
  }

  @override
  Stream<void> getStream(context) => Stream.empty();
}

class _CourseMeta {
  final Course? course;
  final List<t.Tab> tabs;

  _CourseMeta(this.course, this.tabs);
}

class CourseScreen extends StreamWidget<_CourseMeta> {
  final int courseId;
  final String? initialTabId;

  CourseScreen({required this.courseId, this.initialTabId});

  @override
  bool showLoadingWidget() {
    return true;
  }

  @override
  Widget buildWidget(context, _CourseMeta? data) {
    final course = data?.course;
    final tabs = data?.tabs;

    final title = Text(course?.name ?? 'title.course'.tr());
    final action = course == null
        ? null
        : IconButton(
            icon: Icon(Icons.folder),
            tooltip: 'tabs.file'.tr(),
            onPressed: () async {
              final path = '/course/${course.id}/files';
              await navigateTo(path);
            },
          );

    if (tabs == null) {
      return Scaffold(
        appBar: AppBar(
          title: title,
          actions: [action].whereType<Widget>().toList(),
        ),
      );
    } else {
      final validTabs = tabs
          .where((t) => t.type != 'external' && t.visibility == 'public')
          .toList();

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
  Stream<_CourseMeta> getStream(context) {
    final canvas = Provider.of<Model>(context).canvas;
    return ZipStream.zip2(
        canvas.getCourse(courseId),
        canvas.getTabs(courseId), // should we yield the last?
        (a, b) => _CourseMeta(a as Course?, b as List<t.Tab>));
  }
}

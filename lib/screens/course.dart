import 'dart:math';

import 'package:flutter/foundation.dart';
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
import 'package:kanbasu/screens/course/modules.dart';
import 'package:kanbasu/screens/course/pages.dart';
import 'package:kanbasu/screens/course/syllabus.dart';
import 'package:kanbasu/utils/stream_op.dart';
import 'package:kanbasu/widgets/common/refreshable_future.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:kanbasu/widgets/snack.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

enum KnownTabType {
  home,
  announcements,
  files,
  syllabus,
  assignments,
  discussions,
  modules,
  pages,
  unknown,
}

class TabsModel {
  final List<t.Tab> validTabs;

  TabsModel(this.validTabs);

  void animateToTab(BuildContext context, KnownTabType type) {
    final index = validTabs.indexWhere((t) => t.id == describeEnum(type));
    if (index < 0) return;
    DefaultTabController.of(context)?.animateTo(index);
  }
}

class _CourseTabView extends StatefulWidget {
  final int courseId;
  final Course? course;
  final t.Tab tab;

  _CourseTabView(this.courseId, this.course, this.tab);

  @override
  _CourseTabViewState createState() => _CourseTabViewState();
}

class _CourseTabViewState extends State<_CourseTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final courseId = widget.courseId;
    final course = widget.course;
    final tab = widget.tab;

    final type = KnownTabType.values.firstWhere(
      (e) => describeEnum(e) == tab.id,
      orElse: () => KnownTabType.unknown,
    );

    final screen = () {
      switch (type) {
        case KnownTabType.home:
          return CourseHomeScreen();
        case KnownTabType.announcements:
          return CourseAnnouncementsScreen(courseId);
        case KnownTabType.files:
          return CourseFilesScreen(courseId);
        case KnownTabType.syllabus:
          return course != null ? CourseSyllabusScreen(course) : Container();
        case KnownTabType.assignments:
          return CourseAssignmentsScreen(courseId);
        case KnownTabType.discussions:
          return CourseDiscussionsScreen(courseId);
        case KnownTabType.modules:
          return CourseModulesScreen(courseId);
        case KnownTabType.pages:
          return CoursePagesScreen(courseId);
        case KnownTabType.unknown:
          return Center(child: Text('It\'s ${tab.id} here'));
      }
    }();

    return screen;
  }

  @override
  bool get wantKeepAlive => true;
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

    if (tabs == null || course == null || tabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: title),
        body: LoadingWidget(isMore: false),
      );
    }

    final validTabs = _filterTabs(tabs);

    final tabBar = TabBar(
      tabs: validTabs.map((t) => Tab(text: t.label)).toList(),
      isScrollable: true,
    );

    final initialIndex =
        max(validTabs.indexWhere((t) => t.id == initialTabId), 0);

    final tabBarView = TabBarView(
      children:
          validTabs.map((t) => _CourseTabView(courseId, course, t)).toList(),
    );

    final downloadAllAction = () {
      return HookBuilder(
        builder: (BuildContext context) {
          final resolverModel = context.watch<ResolverModel>();
          final tabsModel = context.read<TabsModel>();
          final isDownloading = useState(false);

          final downloadAll = () async {
            isDownloading.value = true;
            tabsModel.animateToTab(context, KnownTabType.files);
            showSnack(context, 'files.start_download_all'.tr());
            final count = await resolverModel.requestDownloadAll(courseId);
            showSnack(
              context,
              'files.done_download'.tr(args: [count.toString()]),
            );
            isDownloading.value = false;
          };

          return IconButton(
            icon: Icon(Icons.cloud_download_outlined),
            tooltip: 'files.download_all'.tr(),
            onPressed: isDownloading.value == false ? downloadAll : null,
          );
        },
      );
    }();

    final scaffold = Scaffold(
      appBar: AppBar(
        title: title,
        actions: [downloadAllAction].whereType<Widget>().toList(),
        bottom: tabBar,
      ),
      body: tabBarView,
    );

    return DefaultTabController(
      length: validTabs.length,
      initialIndex: initialIndex,
      child: Provider(
        create: (_) => TabsModel(validTabs),
        child: scaffold,
      ),
    );
  }

  @override
  List<Future<_CourseMeta>> getFutures(context) {
    final canvas = context.read<Model>().canvas;
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

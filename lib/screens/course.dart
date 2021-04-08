import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/tab.dart' as t;
import 'package:kanbasu/router.dart';
import 'package:kanbasu/widgets/refreshable_stream.dart';
import 'package:kanbasu/widgets/stream.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rxdart/rxdart.dart';

class _CourseMockTabView extends RefreshableStreamWidget<void> {
  final t.Tab tab;

  _CourseMockTabView(this.tab);

  @override
  Widget buildWidget(void data) {
    final model = Provider.of<Model>(useContext());
    final mockHome = ListView.builder(
        itemCount: 20,
        itemBuilder: (BuildContext context, int index) {
          if (index % 5 == 0 || index == 2) {
            return Container(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      index / 5 == 0
                          ? 'overview.activities'.tr()
                          : index == 2
                              ? 'tabs.announcement'.tr()
                              : index / 5 == 1
                                  ? 'tabs.assignment'.tr()
                                  : index / 5 == 2
                                      ? 'tabs.discussion'.tr()
                                      : index / 5 == 3
                                          ? 'tabs.file'.tr()
                                          : '',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    TextButton(
                      onPressed: () {
                        DefaultTabController.of(context)!.animateTo(1);
                      },
                      child: Text('overview.more'.tr()),
                    )
                  ],
                ));
          }
          if (index == 1) {
            return Container(
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                child: Container(
                    decoration: BoxDecoration(
                        color: model.theme.grayBackground,
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Column(children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: '作业',
                                        style: TextStyle(
                                            color: Colors.blueAccent)),
                                    TextSpan(
                                      text: ' · ',
                                    ),
                                    TextSpan(
                                      text: '第三章作业',
                                    ),
                                    TextSpan(
                                      text: ' · ',
                                    ),
                                    TextSpan(
                                      text: '截止时间修改为 4 月 1 日',
                                    ),
                                    TextSpan(
                                      text: ' · ',
                                    ),
                                    TextSpan(
                                      text: '已提交',
                                      style: TextStyle(color: Colors.green),
                                    )
                                  ],
                                ),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: '文件',
                                        style: TextStyle(
                                            color: Colors.purpleAccent)),
                                    TextSpan(
                                      text: ' · ',
                                    ),
                                    TextSpan(
                                      text: '4.4 设计模式 - 2.pdf',
                                    ),
                                    TextSpan(
                                      text: ' · ',
                                    ),
                                    TextSpan(
                                      text: '修改于 2 月 35 日',
                                    )
                                  ],
                                ),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: '公告',
                                        style: TextStyle(
                                            color: Colors.greenAccent)),
                                    TextSpan(
                                      text: ' · ',
                                    ),
                                    TextSpan(
                                      text: '课程分组',
                                    ),
                                    TextSpan(
                                      text: ' · ',
                                    ),
                                    TextSpan(text: '发布于 3 月 34 日')
                                  ],
                                ),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: '作业',
                                        style: TextStyle(
                                            color: Colors.blueAccent)),
                                    TextSpan(
                                      text: ' · ',
                                    ),
                                    TextSpan(
                                      text: '第二章作业',
                                    ),
                                    TextSpan(
                                      text: ' · ',
                                    ),
                                    TextSpan(
                                      text: '截止时间修改为 4 月 1 日',
                                    ),
                                    TextSpan(
                                      text: ' · ',
                                    ),
                                    TextSpan(
                                      text: '已评分 (A)',
                                      style: TextStyle(color: Colors.green),
                                    )
                                  ],
                                ),
                              )),
                        ]))));
          }
          if (1 <= index % 5 && index % 5 < 5) {
            return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                child: Card(
                    child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.description)),
                  title: Text('第三章作业'),
                  subtitle: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: '截止时间：2021 年 4 月 1 日',
                        ),
                        TextSpan(
                          text: ' · ',
                        ),
                        TextSpan(
                          text: '已提交',
                          style: TextStyle(color: Colors.green),
                        )
                      ],
                    ),
                  ),
                  trailing: Badge(
                      elevation: 0,
                      showBadge: index % 5 <= 2,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () {},
                      )),
                )));
          }
          return Container();
        });

    return tab.position == 1
        ? mockHome
        : Center(child: Text("It's cloudy here"));
  }

  @override
  Stream<void> getStream() => Stream.empty();
}

class _CourseMeta {
  final Course? course;
  final List<t.Tab> tabs;

  _CourseMeta(this.course, this.tabs);
}

class CourseScreen extends StreamWidget<_CourseMeta> {
  final int courseId;

  CourseScreen({required this.courseId});

  @override
  bool showLoadingWidget() {
    return true;
  }

  @override
  Widget buildWidget(_CourseMeta? data) {
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
      final tabBar = TabBar(
        tabs: tabs.map((t) => Tab(text: t.label)).toList(),
        isScrollable: true,
      );
      final scaffold = Scaffold(
          appBar: AppBar(
            title: title,
            actions: [action].whereType<Widget>().toList(),
            bottom: tabBar,
          ),
          body: TabBarView(
            children: tabs.map((t) => _CourseMockTabView(t)).toList(),
          ));
      return DefaultTabController(length: tabs.length, child: scaffold);
    }
  }

  @override
  Stream<_CourseMeta> getStream() {
    final canvas = Provider.of<Model>(useContext()).canvas;
    return ZipStream.zip2(
        canvas.getCourse(courseId),
        canvas.getTabs(courseId), // should we yield the last?
        (a, b) => _CourseMeta(a as Course?, b as List<t.Tab>));
  }
}

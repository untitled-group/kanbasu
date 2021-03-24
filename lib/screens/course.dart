import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/screens/common_screen.dart';
import 'package:provider/provider.dart';

class CourseScreen extends CommonScreen<Course?> {
  final int id;

  CourseScreen({required this.id});

  @override
  Widget buildWidget(Course? data) {
    return DefaultTabController(
      initialIndex: 1,
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(data?.name ?? ''),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Overview',
              ),
              Tab(
                text: '公告',
              ),
              Tab(
                text: '作业',
              ),
              Tab(
                text: '讨论',
              ),
              Tab(
                text: '文件',
              ),
              Tab(
                text: '大纲',
              ),
              Tab(
                text: '单元',
              ),
            ],
          ),
        ),
        body: TabBarView(children: <Widget>[
          Scrollbar(
              child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text('第三章作业'),
                      subtitle: Text('请给出支付宝得花呗系统的基本功能用例图，并描述出用例之间的include与extend关系。'),
                    );
                  })),
          Center(
            child: Text('It\'s cloudy here'),
          ),
          Center(
            child: Text('It\'s cloudy here'),
          ),
          Center(
            child: Text('It\'s cloudy here'),
          ),
          Center(
            child: Text('It\'s cloudy here'),
          ),
          Center(
            child: Text('It\'s cloudy here'),
          ),
          Center(
            child: Text('It\'s cloudy here'),
          ),
        ]),
      ),
    );
  }

  @override
  Stream<Course?> getStream() =>
      Provider.of<Model>(useContext()).canvas.getCourse(id);

  @override
  Widget getTitle() => Text('Course');
}

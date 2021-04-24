import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';

class CourseHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Model>(context);
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
    return mockHome;
  }
}

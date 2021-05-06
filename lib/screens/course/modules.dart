import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/module.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/module.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
import 'package:provider/provider.dart';

class CourseModulesScreen extends RefreshableStreamListWidget<Module> {
  final int courseId;

  CourseModulesScreen(this.courseId);

  @override
  List<Stream<Module>> getStreams(context) =>
      Provider.of<Model>(context).canvas.getModules(courseId);

  @override
  Widget buildItem(context, Module item) {
    return InkWell(
      child: ModuleWidget(item),
    );
  }
}

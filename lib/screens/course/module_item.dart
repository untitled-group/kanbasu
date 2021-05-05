import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/module_item.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/module_item.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
import 'package:provider/provider.dart';

class CourseModuleItemScreen extends RefreshableStreamListWidget<ModuleItem> {
  final int courseId;
  final int moduleId;

  CourseModuleItemScreen(this.courseId, this.moduleId);

  @override
  List<Stream<ModuleItem>> getStreams(context) =>
      Provider.of<Model>(context).canvas.getModuleItems(courseId, moduleId);

  @override
  Widget buildItem(context, ModuleItem item) {
    return InkWell(
      child: ModuleItemWidget(item),
    );
  }
}

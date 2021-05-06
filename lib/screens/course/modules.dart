import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/module_list_item.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/module.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
import 'package:provider/provider.dart';

class CourseModulesScreen extends RefreshableStreamListWidget<ModuleListItem> {
  final int courseId;

  CourseModulesScreen(this.courseId);

  Stream<ModuleListItem> getModuleListStream(canvas, courseId, online) async* {
    final modules = await (online
        ? canvas.getModules(courseId).last
        : canvas.getModules(courseId).first);
    for (final module in modules) {
      yield ModuleListItem.ModuleIs(module);
      await for (final moduleItem
          in canvas.getModuleItem(courseId, module.Id)) {
        yield ModuleListItem.ModuleItemIs(moduleItem);
      }
    }
  }

  @override
  List<Stream<ModuleListItem>> getStreams(context) => [
        getModuleListStream(
            Provider.of<Model>(context).canvas, courseId, false),
        getModuleListStream(Provider.of<Model>(context).canvas, courseId, true),
      ];

  @override
  Widget buildItem(context, ModuleListItem item) {
    return InkWell(
      child: ModuleListItemWidget(item),
    );
  }
}



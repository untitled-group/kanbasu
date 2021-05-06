import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/aggregation.dart';
import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/module.dart';
import 'package:kanbasu/models/module_item.dart';
import 'package:kanbasu/widgets/module.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
import 'package:provider/provider.dart';

class CourseModulesScreen
    extends RefreshableStreamListWidget<ComposedModuleData> {
  final int courseId;

  CourseModulesScreen(this.courseId);

  Stream<ComposedModuleData> getModuleListStream(
      CanvasBufferClient canvas, int courseId, bool useOnlineData) async* {
    final modules =
        await getListDataFromApi(canvas.getModules(courseId), useOnlineData);
    for (final module in modules) {
      final items = await getListDataFromApi(
          canvas.getModuleItems(courseId, module.id), useOnlineData);
      yield ComposedModuleData(module, items);
    }
  }

  @override
  List<Stream<ComposedModuleData>> getStreams(context) => [
        getModuleListStream(
            Provider.of<Model>(context).canvas, courseId, false),
        getModuleListStream(Provider.of<Model>(context).canvas, courseId, true),
      ];

  @override
  Widget buildItem(context, ComposedModuleData item) {
    return InkWell(
      child: ModuleWidget(item),
    );
  }
}

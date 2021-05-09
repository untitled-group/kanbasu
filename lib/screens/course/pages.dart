import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/page.dart' as p;
import 'package:kanbasu/widgets/page.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
import 'package:provider/provider.dart';

class CoursePagesScreen extends RefreshableStreamListWidget<p.Page> {
  final int courseId;

  CoursePagesScreen(this.courseId);
  @override
  List<Stream<p.Page>> getStreams(context) =>
      context.read<Model>().canvas.getPages(courseId);

  @override
  Widget buildItem(context, p.Page item) {
    return PageItemWidget(courseId, item);
  }
}

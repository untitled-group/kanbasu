import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/assignment.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
import 'package:provider/provider.dart';

class CourseAssignmentsScreen extends RefreshableStreamListWidget<Assignment> {
  final int courseId;

  CourseAssignmentsScreen(this.courseId);

  @override
  List<Stream<Assignment>> getStreams(context) =>
      context.read<Model>().canvas.getAssignments(courseId);

  @override
  Widget buildItem(context, Assignment item) {
    return AssignmentWidget(item);
  }
}

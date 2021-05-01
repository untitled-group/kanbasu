import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/assignment.dart';
import 'package:kanbasu/widgets/refreshable_stream_list.dart';
import 'package:provider/provider.dart';

class CourseAssignmentsScreen extends RefreshableStreamListWidget<Assignment> {
  final int courseId;

  CourseAssignmentsScreen(this.courseId);

  @override
  List<Stream<Assignment>> getStreams(context) =>
      Provider.of<Model>(context).canvas.getAssignments(courseId);

  @override
  Widget buildItem(context, Assignment item) {
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        isScrollControlled: true,
        builder: (context) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.3,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: AssignmentContentWidget(item),
          );
        },
      ),
      child: AssignmentWidget(item, false),
    );
  }
}

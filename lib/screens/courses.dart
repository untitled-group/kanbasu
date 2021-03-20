import 'package:flutter/material.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/scaffolds/list.dart';
import 'package:kanbasu/widgets/course.dart';
import 'package:provider/provider.dart';

class CoursesScreen extends StatefulWidget {
  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Model>(context);
    // FIXME: a change of `model.canvas` won't make the widget rebuild

    return ListScaffold<Course, int>(
      title: Text('Courses'),
      itemBuilder: (item) {
        return CourseWidget(item);
      },
      fetch: (_cursor) async {
        final courses = await model.canvas.getCoursesF();
        return ListPayload(items: courses, hasMore: false);
      },
    );
  }
}

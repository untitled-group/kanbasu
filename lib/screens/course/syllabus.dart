import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/widgets/single.dart';

class CourseSyllabusScreen extends StatelessWidget {
  final Course course;

  CourseSyllabusScreen(this.course);

  @override
  Widget build(BuildContext context) {
    return Single(Html(data: course.syllabusBody ?? ''));
  }
}

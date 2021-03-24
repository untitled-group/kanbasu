import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/screens/common_screen.dart';
import 'package:kanbasu/widgets/single.dart';
import 'package:provider/provider.dart';

class CourseScreen extends CommonScreen<Course?> {
  final int id;
  CourseScreen({required this.id});

  @override
  Widget buildWidget(Course? data) {
    return Single(child: Text(data.toString()));
  }

  @override
  Stream<Course?> getStream() =>
      Provider.of<Model>(useContext()).canvas.getCourse(id);

  @override
  Widget getTitle() => Text('Course');
}

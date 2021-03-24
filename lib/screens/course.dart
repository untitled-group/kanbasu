import 'package:flutter/material.dart';
import 'package:kanbasu/scaffolds/common.dart';

class CourseScreen extends StatelessWidget {
  final int id;
  const CourseScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: Text('Course $id'),
      body: Container(child: Text('$id')),
    );
  }
}

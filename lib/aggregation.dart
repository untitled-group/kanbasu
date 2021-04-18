import 'package:dio/dio.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/planner.dart';

Future<List<Map>> aggregate() async {
  // needed keys: title, type, course_id, description, url, upload_date, due_date
  final dio = Dio();
  final api = CanvasRestClient(dio);

  // ignore: omit_local_variable_types
  List<Map> aggregations = [];

  var available_courses = [];
  final courses = await api.getCourses();
  for (var course in courses.data) {
    available_courses.add(course.id);
  }

  for (var course_id in available_courses) {
    final assignments = await api.getAssignments(course_id);
    for (var assignment in assignments.data) {
      var new_res = aggregate_from_assignment(assignment, course_id);
      aggregations.add(new_res);
    }

    final files = await api.getFiles(course_id);
    for (var file in files.data) {
      var new_res = aggregate_from_file(file, course_id);
      aggregations.add(new_res);
    }
  }

  final planners = await api.getPlanners();
  for (var planner in planners.data) {
    if (planner.plannableType != 'announcements') continue;
    var new_res = aggregate_from_planner(planner); // exist errors
    aggregations.add(new_res);
  }

  return aggregations;
}

Map aggregate_from_planner(Planner planner) {
  // only deal with announcements
  // meet some problems
  var res = {};
  // res['title'] = planner.plannable.title;
  res['type'] = 'announcements';
  res['course_id'] = planner.courseId;
  // res['description'] = planner.plannable.message;
  res['url'] = planner.htmlUrl;
  res['upload_date'] = planner.plannableDate;
  res['due_date'] = null;
  return res;
}

Map aggregate_from_assignment(Assignment assignment, int course_id) {
  // only deal with announcements
  // meet some problems
  var res = {};
  res['title'] =
      'Assignment {assignment.id} of course {course_id}'; // seems confusing to use id ?
  res['type'] = 'assignment';
  res['course_id'] = course_id;
  res['description'] = assignment.description;
  res['url'] = assignment.htmlUrl;
  res['upload_date'] = null;
  res['due_date'] = assignment.dueAt;
  return res;
}

Map aggregate_from_file(File file, int course_id) {
  // only deal with announcements
  // meet some problems
  var res = {};
  res['title'] =
      'Uploaded file {file.filename} of course {course_id}'; // seems confusing to use id ?
  res['type'] = 'file';
  res['course_id'] = course_id;
  res['description'] = file.filename;
  res['url'] = file.url;
  res['upload_date'] = file.updatedAt;
  res['due_date'] = null;
  return res;
}

import 'package:dio/dio.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/planner.dart';

import 'package:tuple/tuple.dart';

class BriefInfo {
  String? title; // in practice, it will never be null
  String type; // also create a struct?
  int course_id; // or String?
  String? description;
  String? url;
  DateTime? upload_date;
  DateTime? due_date;

  BriefInfo(this.title, this.type, this.course_id);
  void fillInfo(
      {String? description,
      String? url,
      DateTime? upload_date,
      DateTime? due_date}) {
    this.description = description;
    this.url = url;
    this.upload_date = upload_date;
    this.due_date = due_date;
  }
}

Future<List> getDataFromApi(Stream stream, bool useOnlineData) async {
  if (useOnlineData) {
    final data = (await stream.last).toList();
    return data;
  } else {
    final data = (await stream.first).toList();
    return data;
  }
}

Future<List<BriefInfo>> aggregate({bool useOnlineData = false}) async {
  // needed keys: title, type, course_id, description, url, upload_date, due_date
  final dio = Dio();
  final restClient = CanvasRestClient(dio);
  final api = CanvasBufferClient(restClient, null);

  // ignore: omit_local_variable_types
  List<BriefInfo> aggregations = [];

  var available_courses = [];
  var courses = await getDataFromApi(api.getCourses(), useOnlineData);

  for (var course in courses) {
    available_courses.add(Tuple2<int, String>(course.id, course.name));
  }

  for (var course_info in available_courses) {
    var course_id = course_info.item1;
    var course_name = course_info.item2;
    var assignments =
        await getDataFromApi(api.getAssignments(course_id), useOnlineData);
    for (var assignment in assignments) {
      var new_res = aggregateFromAssignment(assignment, course_id, course_name);
      aggregations.add(new_res);
    }

    final files = await getDataFromApi(api.getFiles(course_id), useOnlineData);
    for (var file in files) {
      var new_res = aggregateFromFile(file, course_id, course_name);
      aggregations.add(new_res);
    }
  }

  final planners = await getDataFromApi(api.getPlanners(), useOnlineData);
  for (var planner in planners) {
    if (planner.plannableType != 'announcements') continue;
    var new_res = aggregateFromPlanner(planner);
    aggregations.add(new_res);
  }

  return aggregations;
}

BriefInfo aggregateFromPlanner(Planner planner) {
  // only deal with announcements
  var res =
      BriefInfo(planner.plannable.title, 'announcements', planner.courseId);
  res.fillInfo(
      description: planner.plannable.message,
      url: planner.htmlUrl,
      upload_date: planner.plannableDate);

  return res;
}

BriefInfo aggregateFromAssignment(
    Assignment assignment, int course_id, String course_name) {
  var res = BriefInfo('{course_name} 课程作业布置', 'assignment', course_id);
  res.fillInfo(
      description: assignment.description,
      url: assignment.htmlUrl,
      due_date: assignment.dueAt);

  return res;
}

BriefInfo aggregateFromFile(File file, int course_id, String course_name) {
  var res = BriefInfo('{course_name} 新上传文件 {file.filename}', 'file', course_id);
  res.fillInfo(
      description: file.filename, url: file.url, upload_date: file.updatedAt);

  return res;
}

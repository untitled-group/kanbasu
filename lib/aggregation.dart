import 'package:dio/dio.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/planner.dart';
import 'package:kanbasu/models/submission.dart';

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

Future<List> getListDataFromApi(Stream stream, bool useOnlineData) async {
  if (useOnlineData) {
    final data = (await stream.last).toList();
    return data;
  } else {
    final data = (await stream.first).toList();
    return data;
  }
}

Future getItemDataFromApi(Stream stream, bool useOnlineData) async {
  if (useOnlineData) {
    final data = (await stream.last);
    return data;
  } else {
    final data = (await stream.first);
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
  // ignore: omit_local_variable_types
  Map<int, String> course_id_name = {};

  var available_courses = [];
  var courses = await getListDataFromApi(api.getCourses(), useOnlineData);

  for (var course in courses) {
    available_courses.add(course.id);
    course_id_name[course.id] = course.name;
  }

  // info about assignment, file and grading
  for (var course_id in available_courses) {
    var course_name = course_id_name[course_id] ?? 'course null';

    final assignments =
        await getListDataFromApi(api.getAssignments(course_id), useOnlineData);
    for (var assignment in assignments) {
      var assignment_id = assignment.id;
      var new_agg = aggregateFromAssignment(assignment, course_id, course_name);
      aggregations.add(new_agg);

      var submission = await getItemDataFromApi(
          api.getSubmission(course_id, assignment_id), useOnlineData);
      if (submission.grade != null) {
        var new_agg =
            aggregateFromSubmisson(submission, course_id, course_name);
        aggregations.add(new_agg);
      }
    }

    final files =
        await getListDataFromApi(api.getFiles(course_id), useOnlineData);
    for (var file in files) {
      var new_agg = aggregateFromFile(file, course_id, course_name);
      aggregations.add(new_agg);
    }
  }

  // info about announcement
  final planners = await getListDataFromApi(api.getPlanners(), useOnlineData);
  for (var planner in planners) {
    if (planner.plannableType != 'announcements') continue;
    var course_id = planner.courseId;
    var course_name = course_id_name[course_id] ?? 'course null';
    var new_agg = aggregateFromPlanner(planner, course_id, course_name);
    aggregations.add(new_agg);
  }

  return aggregations;
}

BriefInfo aggregateFromPlanner(
    Planner planner, int course_id, String course_name) {
  // only deal with announcements
  var title = '{course_name} 通知: {planner.plannable.title}';
  var res = BriefInfo(title, 'announcements', planner.courseId);
  res.fillInfo(
      description: planner.plannable.message,
      url: planner.htmlUrl,
      upload_date: planner.plannableDate);

  return res;
}

BriefInfo aggregateFromAssignment(
    Assignment assignment, int course_id, String course_name) {
  var res = BriefInfo('{course_name} 课程作业: {assignment.name} 已布置', 'assignment',
      course_id); // need a little change, because we don not know the format of assignment.name
  res.fillInfo(
      description: assignment.description,
      url: assignment.htmlUrl,
      due_date: assignment.dueAt);

  return res;
}

BriefInfo aggregateFromFile(File file, int course_id, String course_name) {
  var res =
      BriefInfo('{course_name} 课程上传文件: {file.filename}', 'file', course_id);
  res.fillInfo(
      description: file.filename, url: file.url, upload_date: file.updatedAt);

  return res;
}

BriefInfo aggregateFromSubmisson(
    Submission submission, int course_id, String course_name) {
  var res = BriefInfo(
      '{course_name} 课程作业: {assignment.name} 已批改', 'grading', course_id);
  res.fillInfo(
      description: '{submission.grade} / {submission.score}',
      url: submission.url); // or previewUrl?

  return res;
}

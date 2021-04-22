import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/planner.dart';
import 'package:kanbasu/models/submission.dart';

class BriefInfo {
  String? title; // in practice, it will never be null
  String type;
  int course_id;
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

  BriefInfo.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        type = json['type'],
        course_id = json['course_id'],
        description = json['description'];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'course_id': course_id,
      'description': description
    };
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

Future<List<BriefInfo>> aggregate(CanvasBufferClient api,
    {bool useOnlineData = false}) async {
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
    var course_name = course_id_name[course_id] ?? 'null course';

    final assignments =
        await getListDataFromApi(api.getAssignments(course_id), useOnlineData);
    for (var assignment in assignments) {
      var new_agg = aggregateFromAssignment(assignment, course_id, course_name);
      aggregations.add(new_agg);
    }

    var submissions =
        await getListDataFromApi(api.getSubmissions(course_id), useOnlineData);
    for (var submission in submissions) {
      if (submission.grade != null) {
        var new_agg =
            aggregateFromSubmission(submission, course_id, course_name);
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
  var title = '$course_name 通知: ${planner.plannable.title}';
  var res = BriefInfo(title, 'announcements', planner.courseId);
  res.fillInfo(
      description: planner.plannable.message,
      url: planner.htmlUrl,
      upload_date: planner.plannableDate);

  return res;
}

BriefInfo aggregateFromAssignment(
    Assignment assignment, int course_id, String course_name) {
  var title = '$course_name 课程作业已布置';
  if (assignment.name != null) {
    title = '$course_name 课程作业: ${assignment.name} 已布置';
  }
  var res = BriefInfo(title, 'assignment', course_id);
  res.fillInfo(
      description: assignment.description,
      url: assignment.htmlUrl,
      due_date: assignment.dueAt);

  return res;
}

BriefInfo aggregateFromFile(File file, int course_id, String course_name) {
  var res =
      BriefInfo('$course_name 课程上传文件: ${file.displayName}', 'file', course_id);
  res.fillInfo(
      description: file.displayName,
      url: file.url,
      upload_date: file.updatedAt);

  return res;
}

BriefInfo aggregateFromSubmission(
    Submission submission, int course_id, String course_name) {
  var title = '$course_name 课程作业已评分';
  var assignment = submission.assignment;
  if (assignment != null) {
    title = '$course_name 课程作业: ${assignment.name} 已批改';
  }

  var res = BriefInfo(title, 'grading', course_id);
  var description = '分数: ${submission.grade}';

  if (submission.submissionComments != null &&
      submission.submissionComments!.isNotEmpty) {
    var comment = submission.submissionComments![0]['comments'];
    if (comment != null) {
      description = '分数: ${submission.grade}, [$comment]';
    }
  }

  res.fillInfo(description: description, url: submission.previewUrl);

  return res;
}

import 'dart:math';

import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/planner.dart';
import 'package:kanbasu/models/submission.dart';
import 'package:kanbasu/models/brief_info.dart';
import 'package:html/parser.dart' show parse;

String getPlainText(String htmlData) {
  final bodyText = parse(htmlData).body?.text;
  return bodyText ?? '';
}

Future<List<T>> getListDataFromApi<T>(
    List<Stream<T>> stream, bool useOnlineData) async {
  if (useOnlineData) {
    return await stream.last.toList();
  } else {
    return await stream.first.toList();
  }
}

Future<T> getItemDataFromApi<T>(
    List<Future<T>> stream, bool useOnlineData) async {
  if (useOnlineData) {
    return (await stream.last);
  } else {
    return (await stream.first);
  }
}

Future<List<BriefInfo>> aggregate(CanvasBufferClient api,
    {bool useOnlineData = false}) async {
  // ignore: omit_local_variable_types
  List<BriefInfo> aggregations = [];
  // ignore: omit_local_variable_types
  Map<int, String> course_id_name = {};

  final available_courses = [];
  final courses = await getListDataFromApi(api.getCourses(), useOnlineData);
  final latestTerm = courses.map((c) => c.term?.id ?? 0).fold(0, max);
  final latestCourses =
      courses.where((c) => (c.term?.id ?? 0) >= latestTerm).toList();

  for (final course in latestCourses) {
    available_courses.add(course.id);
    course_id_name[course.id] = course.name;
  }

  // info about assignment, file and grading
  for (final course_id in available_courses) {
    final course_name = course_id_name[course_id] ?? 'null course';

    final assignments =
        await getListDataFromApi(api.getAssignments(course_id), useOnlineData);
    for (final assignment in assignments) {
      final new_agg =
          aggregateFromAssignment(assignment, course_id, course_name);
      aggregations.add(new_agg);
    }

    final submissions =
        await getListDataFromApi(api.getSubmissions(course_id), useOnlineData);
    for (final submission in submissions) {
      if (submission.grade != null) {
        final new_agg =
            aggregateFromSubmission(submission, course_id, course_name);
        aggregations.add(new_agg);
      }
    }

    final files =
        await getListDataFromApi(api.getFiles(course_id), useOnlineData);
    for (final file in files) {
      final new_agg = aggregateFromFile(file, course_id, course_name);
      aggregations.add(new_agg);
    }
  }

  // info about announcement
  final planners = await getListDataFromApi(api.getPlanners(), useOnlineData);
  for (final planner in planners) {
    if (planner.plannableType != 'announcements') continue;
    final course_id = planner.courseId;
    final course_name = course_id_name[course_id] ?? 'course null';
    final new_agg = aggregateFromPlanner(planner, course_id, course_name);
    aggregations.add(new_agg);
  }
  aggregations.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
  return aggregations.reversed.toList();
}

BriefInfo aggregateFromPlanner(
    Planner planner, int course_id, String course_name) {
  // only deal with announcements
  final title = '$course_name 通知: ${planner.plannable.title}';
  final description = getPlainText(planner.plannable.message ?? '');

  return BriefInfo((i) => i
    ..title = title
    ..description = description
    ..url = planner.htmlUrl
    ..updatedAt = planner.plannableDate
    ..type = 'announcements'
    ..courseId = course_id);
}

BriefInfo aggregateFromAssignment(
    Assignment assignment, int course_id, String course_name) {
  final title;
  if (assignment.name != null) {
    title = '$course_name 课程作业: ${assignment.name} 已布置';
  } else {
    title = '$course_name 课程作业已布置';
  }
  final description = getPlainText(assignment.description ?? '');
  final updatedAt = assignment.updatedAt ?? assignment.createdAt;

  return BriefInfo((i) => i
    ..title = title
    ..description = description
    ..url = assignment.htmlUrl
    ..updatedAt = updatedAt
    ..dueDate = assignment.dueAt
    ..type = 'assignment'
    ..courseId = course_id);
}

BriefInfo aggregateFromFile(File file, int course_id, String course_name) {
  return BriefInfo((i) => i
    ..title = '$course_name 课程上传文件: ${file.displayName}'
    ..description = file.displayName
    ..url = file.url
    ..updatedAt = file.updatedAt
    ..type = 'file'
    ..courseId = course_id);
}

BriefInfo aggregateFromSubmission(
    Submission submission, int course_id, String course_name) {
  final title;
  final assignment = submission.assignment;
  if (assignment != null) {
    title = '$course_name 课程作业: ${assignment.name} 已批改';
  } else {
    title = '$course_name 课程作业已评分';
  }

  var description = '分数: ${submission.grade}';

  if (submission.submissionComments != null &&
      submission.submissionComments!.isNotEmpty) {
    var comment = submission.submissionComments![0]['comments'];
    if (comment != null) {
      description = '分数: ${submission.grade}, [$comment]';
    }
  }

  return BriefInfo((i) => i
    ..title = title
    ..description = description
    ..url = submission.previewUrl
    ..updatedAt = submission.gradedAt!
    ..type = 'grading'
    ..courseId = course_id);
}

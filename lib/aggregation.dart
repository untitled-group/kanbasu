import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/planner.dart';
import 'package:kanbasu/models/submission.dart';
import 'package:kanbasu/models/brief_info.dart';
import 'package:html/parser.dart' show parse;
import 'package:kanbasu/utils/courses.dart';

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
  final aggregations = <BriefInfo>[];
  final latestCourses = toLatestCourses(
      await getListDataFromApi(api.getCourses(), useOnlineData));
  final idToCourse = {
    for (final course in latestCourses) course.id: course,
  };

  // info about assignment, file and grading
  for (final course in latestCourses) {
    final courseId = course.id;

    final assignments =
        await getListDataFromApi(api.getAssignments(courseId), useOnlineData);
    for (final assignment in assignments) {
      final newAgg = aggregateFromAssignment(assignment, course);
      aggregations.add(newAgg);
    }

    final submissions =
        await getListDataFromApi(api.getSubmissions(courseId), useOnlineData);
    for (final submission in submissions) {
      if (submission.grade != null) {
        final newAgg = aggregateFromSubmission(submission, course);
        aggregations.add(newAgg);
      }
    }

    final files =
        await getListDataFromApi(api.getFiles(courseId), useOnlineData);
    for (final file in files) {
      final newAgg = aggregateFromFile(file, course);
      aggregations.add(newAgg);
    }
  }

  // info about announcement
  final planners = await getListDataFromApi(api.getPlanners(), useOnlineData);
  for (final planner in planners) {
    if (planner.plannableType != 'announcement') continue;
    print(planner);
    final courseId = planner.courseId;
    final course = idToCourse[courseId];
    if (courseId != null && course != null) {
      final newAgg = aggregateFromPlanner(planner, course);
      aggregations.add(newAgg);
    }
  }

  aggregations.sort((a, b) => -a.updatedAt.compareTo(b.updatedAt));
  return aggregations;
}

BriefInfo aggregateFromPlanner(Planner planner, Course course) {
  // only deal with announcements
  final title = '${planner.plannable.title}';
  final description = getPlainText(planner.plannable.message ?? '');

  return BriefInfo((i) => i
    ..title = title
    ..description = description
    ..url = planner.htmlUrl
    ..updatedAt = planner.plannableDate
    ..type = BriefInfoType.announcements
    ..courseId = course.id
    ..courseName = course.name);
}

BriefInfo aggregateFromAssignment(Assignment assignment, Course course) {
  final title;
  if (assignment.name != null) {
    title = assignment.name!.trim();
  } else {
    title = '作业';
  }
  final description = getPlainText(assignment.description ?? '');
  final updatedAt = assignment.updatedAt ?? assignment.createdAt;

  return BriefInfo((i) => i
    ..title = title
    ..suffix = '已发布'
    ..description = description
    ..url = assignment.htmlUrl
    ..updatedAt = updatedAt
    ..dueDate = assignment.dueAt
    ..type = BriefInfoType.assignment
    ..courseId = course.id
    ..courseName = course.name);
}

BriefInfo aggregateFromFile(File file, Course course) {
  return BriefInfo((i) => i
    ..title = '${file.displayName.trim()}'
    ..suffix = '已上传'
    ..description = ''
    ..url = file.url
    ..updatedAt = file.updatedAt
    ..type = BriefInfoType.file
    ..courseId = course.id
    ..courseName = course.name);
}

BriefInfo aggregateFromSubmission(Submission submission, Course course) {
  final title;
  final assignment = submission.assignment;
  if (assignment != null) {
    title = '${assignment.name!.trim()}';
  } else {
    title = '作业';
  }

  var description = '分数：${submission.grade}';

  if (submission.submissionComments != null &&
      submission.submissionComments!.isNotEmpty) {
    var comment = submission.submissionComments![0]['comments'];
    if (comment != null) {
      description = '分数: ${submission.grade}, [$comment]';
    }
  }

  return BriefInfo((i) => i
    ..title = title
    ..suffix = '已评分'
    ..description = description
    ..url = submission.previewUrl
    ..updatedAt = submission.gradedAt!
    ..type = BriefInfoType.grading
    ..courseId = course.id
    ..courseName = course.name);
}

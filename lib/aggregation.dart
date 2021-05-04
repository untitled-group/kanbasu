import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/planner.dart';
import 'package:kanbasu/models/submission.dart';
import 'package:kanbasu/models/brief_info.dart';
import 'package:html/parser.dart' show parse;
import 'package:kanbasu/utils/courses.dart';
import 'package:easy_localization/easy_localization.dart';

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
  Future<void> processCourse(Course course) async {
    final assignments =
        await getListDataFromApi(api.getAssignments(course.id), useOnlineData);
    for (final assignment in assignments) {
      final newAgg = aggregateFromAssignment(assignment, course);
      aggregations.add(newAgg);
    }

    final submissions =
        await getListDataFromApi(api.getSubmissions(course.id), useOnlineData);
    for (final submission in submissions) {
      if (submission.grade != null) {
        final newAgg = aggregateFromSubmission(submission, course);
        aggregations.add(newAgg);
      }
    }

    final files =
        await getListDataFromApi(api.getFiles(course.id), useOnlineData);
    for (final file in files) {
      final newAgg = aggregateFromFile(file, course);
      aggregations.add(newAgg);
    }
  }

  // info about announcement
  Future<void> processAnnouncements() async {
    final planners = await getListDataFromApi(api.getPlanners(), useOnlineData);
    for (final planner in planners) {
      if (planner.plannableType != 'announcement') continue;
      final courseId = planner.courseId;
      final course = idToCourse[courseId];
      if (courseId != null && course != null) {
        final newAgg = aggregateFromPlanner(planner, course);
        aggregations.add(newAgg);
      }
    }
  }

  await Future.wait([
    for (final course in latestCourses) processCourse(course),
    processAnnouncements(),
  ]);

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
    title = 'aggregate.assignment'.tr();
  }
  final description = getPlainText(assignment.description ?? '');
  final updatedAt = assignment.updatedAt ?? assignment.createdAt;

  return BriefInfo((i) => i
    ..title = title
    ..suffix = 'aggregate.suffix.published'.tr()
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
    ..suffix = 'aggregate.suffix.uploaded'.tr()
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
    title = assignment.name!.trim();
  } else {
    title = 'aggregate.assignment'.tr();
  }

  var description = '${'aggregate.score'.tr()}: ${submission.grade}';

  if (submission.submissionComments != null &&
      submission.submissionComments!.isNotEmpty) {
    var comment = submission.submissionComments![0]['comments'];
    if (comment != null) {
      description = '${'aggregate.score'.tr()}: ${submission.grade}\n'
          '${'aggregate.comment'.tr()}: $comment]';
    }
  }

  return BriefInfo((i) => i
    ..title = title
    ..suffix = 'aggregate.suffix.graded'.tr()
    ..description = description
    ..url = submission.previewUrl
    ..updatedAt = submission.gradedAt!
    ..type = BriefInfoType.grading
    ..courseId = course.id
    ..courseName = course.name);
}

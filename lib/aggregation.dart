import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/planner.dart';
import 'package:kanbasu/models/submission.dart';
import 'package:kanbasu/models/brief_info.dart';
import 'package:kanbasu/utils/courses.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kanbasu/utils/html.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart/rxdart.dart';

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

Stream<BriefInfo> aggregate(CanvasBufferClient api,
    {bool useOnlineData = false}) async* {
  final latestCourses = toLatestCourses(
      await getListDataFromApi(api.getCourses(), useOnlineData));
  final idToCourse = {
    for (final course in latestCourses) course.id: course,
  };

  // info about assignment, file and grading
  Future<List<BriefInfo>> processCourse(Course course) async {
    final aggregations = <BriefInfo?>[];

    final assignments =
        await getListDataFromApi(api.getAssignments(course.id), useOnlineData);
    for (final assignment in assignments) {
      final newAgg = aggregateFromAssignment(assignment, course);
      aggregations.add(newAgg);

      final newAgg2 = aggregateFromAssignmentDue(assignment, course);
      aggregations.add(newAgg2);
    }

    final submissions =
        await getListDataFromApi(api.getSubmissions(course.id), useOnlineData);
    for (final submission in submissions) {
      final newAgg = aggregateFromSubmission(submission, course);
      aggregations.add(newAgg);
    }

    final files =
        await getListDataFromApi(api.getFiles(course.id), useOnlineData);
    for (final file in files) {
      final newAgg = aggregateFromFile(file, course);
      aggregations.add(newAgg);
    }

    return aggregations.whereType<BriefInfo>().toList();
  }

  // info about announcement
  Future<List<BriefInfo>> processAnnouncements() async {
    final aggregations = <BriefInfo?>[];

    final planners = await getListDataFromApi(api.getPlanners(), useOnlineData);
    for (final planner in planners) {
      if (planner.plannableType != 'announcement') continue;
      final course = idToCourse[planner.courseId];
      if (course != null) {
        final newAgg = aggregateFromPlanner(planner, course);
        aggregations.add(newAgg);
      }
    }

    return aggregations.whereType<BriefInfo>().toList();
  }

  final subject = PublishSubject<List<BriefInfo>>();

  unawaited(Future.wait(
    [
      for (final course in latestCourses)
        processCourse(course).then((d) => subject.add(d)),
      processAnnouncements().then((d) => subject.add(d)),
    ],
  ).then((_) => subject.close()));

  final stream = subject.stream.flatMap((value) => Stream.fromIterable(value));
  await for (final items in stream) {
    yield items;
  }
}

BriefInfo? aggregateFromPlanner(Planner planner, Course course) {
  // only deal with announcements
  final title = '${planner.plannable.title}';
  final description = getPlainText(planner.plannable.message ?? '');

  return BriefInfo((i) => i
    ..title = title
    ..description = description
    ..url = planner.htmlUrl
    ..createdAt = planner.plannableDate
    ..type = BriefInfoType.announcements
    ..courseId = course.id
    ..courseName = course.name
    ..isDone = true);
}

BriefInfo? aggregateFromAssignment(Assignment assignment, Course course) {
  final title;
  if (assignment.name != null) {
    title = assignment.name!.trim();
  } else {
    title = 'aggregate.assignment'.tr();
  }
  final description = getPlainText(assignment.description ?? '');

  return BriefInfo((i) => i
    ..title = title
    ..suffix = 'aggregate.suffix.published'.tr()
    ..description = description
    ..url = assignment.htmlUrl
    ..createdAt = assignment.createdAt!
    ..dueAt = assignment.dueAt
    ..type = BriefInfoType.assignment
    ..courseId = course.id
    ..courseName = course.name
    ..isDone = true);
}

BriefInfo? aggregateFromAssignmentDue(Assignment assignment, Course course) {
  if (assignment.dueAt == null) return null;

  final String title;
  if (assignment.name != null) {
    title = assignment.name!.trim();
  } else {
    title = 'aggregate.assignment'.tr();
  }

  final hasSubmitted = (assignment.hasSubmittedSubmissions ?? false) &&
      (assignment.submission?.attempt ?? 0) >= 1;
  ;
  final description =
      hasSubmitted ? 'aggregate.submitted'.tr() : 'aggregate.unsubmitted'.tr();
  final wasDue = assignment.dueAt!.compareTo(DateTime.now()) <= 0;
  final isDone = wasDue || hasSubmitted;
  final suffix = wasDue
      ? 'aggregate.suffix.was_due'.tr()
      : 'aggregate.suffix.will_due'.tr();

  return BriefInfo((i) => i
    ..title = title
    ..suffix = suffix
    ..description = description
    ..url = assignment.htmlUrl
    ..createdAt = assignment.dueAt!
    ..dueAt = assignment.dueAt
    ..type = BriefInfoType.assignmentDue
    ..courseId = course.id
    ..courseName = course.name
    ..isDone = isDone);
}

BriefInfo? aggregateFromFile(File file, Course course) {
  return BriefInfo((i) => i
    ..title = file.displayName.trim()
    ..suffix = 'aggregate.suffix.uploaded'.tr()
    ..description = ''
    ..url = file.url
    ..createdAt = file.updatedAt
    ..type = BriefInfoType.file
    ..courseId = course.id
    ..courseName = course.name
    ..isDone = true);
}

BriefInfo? aggregateFromSubmission(Submission submission, Course course) {
  if (submission.grade == null) return null;

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
    var comment = submission.submissionComments![0].asMap['comments'];
    if (comment != null) {
      description = '${'aggregate.score'.tr()}: ${submission.grade}\n'
          '${'aggregate.comment'.tr()}: $comment';
    }
  }

  return BriefInfo((i) => i
    ..title = title
    ..suffix = 'aggregate.suffix.graded'.tr()
    ..description = description
    ..url = submission.previewUrl
    ..createdAt = submission.gradedAt!
    ..type = BriefInfoType.grading
    ..courseId = course.id
    ..courseName = course.name
    ..isDone = true);
}

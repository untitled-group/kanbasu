import 'package:test/test.dart';
import 'package:dio/dio.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import '../mocks/mock_adapter.dart';

void main() {
  final dio = Dio();
  dio.httpClientAdapter = MockAdapter();
  final api = CanvasRestClient(dio, baseUrl: MockAdapter.mockBase);

  group('CanvasRestClient', () {
    test('should get course list', () async {
      final response = await api.getCourses();
      expect(response.data[0].courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
      expect(response.data[1].id, equals(233333));
    });

    test('should get single course', () async {
      final response = await api.getCourse(23333);
      expect(response.data.courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
      expect(response.data.startAt,
          equals(DateTime.parse('2019-09-10T07:49:23Z')));
    });

    test('should get tabs', () async {
      final response = await api.getTabs(23333);
      expect(response.data[0].id, equals('home'));
    });

    test('should get user', () async {
      final response = await api.getCurrentUser();
      expect(response.data.name, equals('Somebody'));
    });

    test('should get user activity stream', () async {
      await api.getCurrentUserActivityStream();
    });

    test('should get modules', () async {
      final modules = await api.getModules(23333);
      expect(modules.data[0].name, equals('课程介绍'));
    });

    test('should get a single module', () async {
      final module = await api.getModule(23333, 89728);
      expect(module.data.name, equals('课程介绍'));
    });

    test('should get module items', () async {
      final module_items = await api.getModuleItems(23333, 89729);
      expect(module_items.data[0].id, equals(400460));
    });

    test('should get a single module item', () async {
      final module_item = await api.getModuleItem(23333, 89729, 400460);
      expect(module_item.data.title, equals('1. Introduction to SE.pdf'));
    });

    test('should get assignments', () async {
      final assignments = await api.getAssignments(23333);
      expect(assignments.data[0].id, equals(86658));
    });

    test('should get submission', () async {
      final submission = await api.getSubmission(23333, 24444);
      expect(submission.data.id, equals(24444));
    });

    test('should get information for not-available submissions', () async {
      final submission = await api.getSubmission(23333, 25555);
      expect(submission.data.id, equals(25555));
    });

    test('should get files for a course', () async {
      final files = await api.getFiles(23333);
      expect(files.data[0].id, equals(24444));
    });

    test('should get info about a single file for a course', () async {
      final file = await api.getFile(23333, 24444);
      expect(file.data.id, equals(24444));
    });

    test('should get pages for a course', () async {
      final pages = await api.getPages(23333);
      expect(pages.data[0].title, equals('第四节课在线视频'));
    });

    test('should get info about a single page for a course', () async {
      final page = await api.getPage(23333, 41136);
      expect(page.data.title, equals('第一节课在线视频'));
    });

    test('should get planners', () async {
      final planners = await api.getPlanners();
      expect(planners.data[0].courseId, equals(31427));
    });

    test('should get folders for a course', () async {
      final folders = await api.getFolders(23333);
      expect(folders.data[0].id, equals(313142));
    });

    test('should get info about a single folder for a course', () async {
      final folder = await api.getFolder(23333, 313142);
      expect(folder.data.id, equals(313142));
    });

    test('should get info about all submissions of a course', () async {
      final submissions = await api.getSubmissions(23333);
      expect(submissions.data[0].id, equals(3463087));
    });

    test('should get announcements for course', () async {
      final announcements = await api.getAnnouncements(['course_23333']);
      expect(announcements.data[0].id, equals(66394));
    });

    test('should get info about all submissions of a course with queries',
        () async {
      final submissions = await api.getSubmissions(23334);
      expect(submissions.data[0].id, equals(3904019));
    });

    test('should get info about all discussion topics of a course', () async {
      final topics = await api.getDiscussionTopics(23333);
      expect(topics.data[0].id, equals(66394));
    });

    test('should get info about a discussion topic of a course', () async {
      final topic = await api.getDiscussionTopic(23333, 66394);
      expect(topic.data.id, equals(66394));
    });

    test('should get info about all discussion entries of a topic in a course',
        () async {
      final entries = await api.getDiscussionEntries(23333, 66394);
      expect(entries.data[0].id, equals(161846));
    });
  });
}

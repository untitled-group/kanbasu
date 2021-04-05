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
  });
}

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

    test('should get assignments', () async {
      final assignments = await api.getAssignments(23333);
      expect(assignments.data[0].id, equals(86658));
    });
  });
}

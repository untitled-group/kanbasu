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
      expect(response.data[1].courseCode, isNull);
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
  });
}

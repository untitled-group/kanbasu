import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:test/test.dart';
import 'package:dio/dio.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import '../mocks/course_mock.dart';

void main() {
  group('CanvasBufferClient', () {
    final dio = Dio();
    dio.httpClientAdapter = MockAdapter();
    final restClient = CanvasRestClient(dio, baseUrl: MockAdapter.mockBase);
    final api = CanvasBufferClient(restClient);

    test('should get course list', () async {
      final data = await api.getCourses().toList();
      expect(data.length, equals(3));
      expect(data[0].courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
      expect(data[1].courseCode, equals(null));
      expect(data[2].id, equals(318720));
    });

    test('should get single course', () async {
      final response = await api.getCourse(23333);
      expect(response!.courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
    });

    test('should return null when 404', () async {
      final response = await api.getCourse(23334);
      expect(response, equals(null));
    });
  });
}

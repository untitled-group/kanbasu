import 'package:test/test.dart';
import 'mock_adapter.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:kanbasu/rest_api/canvas.dart';

void main() {
  group('REST API - Course', () {
    test('should get course list', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockAdapter();
      final api = CanvasRestClient(dio, baseUrl: MockAdapter.mockBase);
      final response = await api.getCourses();
      expect(response.data[0].courseCode, equals("(2019-2020-1)-MA119-4-概率统计"));
      expect(response.data[1].courseCode, equals(null));
    });
  });
}

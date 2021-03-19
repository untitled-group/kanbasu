import 'dart:convert';
import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:test/test.dart';
import 'package:dio/dio.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import '../mocks/mock_adapter.dart';

void main() {
  KvStore.initFfi();

  group('CanvasBufferClient', () {
    final dio = Dio();
    dio.httpClientAdapter = MockAdapter();
    final restClient = CanvasRestClient(dio, baseUrl: MockAdapter.mockBase);
    final api = CanvasBufferClient(restClient, null);

    test('should get course list', () async {
      final data = (await api.getCourses().last).toList();
      final dataF = await api.getCoursesF();
      expect(data.map((e) => e.toJson()), equals(dataF.map((e) => e.toJson())));
      expect(data.length, equals(3));
      expect(data[0].courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
      expect(data[1].courseCode, isNull);
      expect(data[2].id, equals(318720));
    });

    test('should get single course', () async {
      final response = await api.getCourse(23333).last;
      final response2 = await api.getCourseF(23333);
      expect(response.toJson(), equals(response2!.toJson()));
      expect(response.courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
    });

    test('should return null when 404', () async {
      final response = await api.getCourse(23334).toList();
      expect(response, isEmpty);
      final response2 = await api.getCourseF(23334);
      expect(response2, isNull);
    });
  });

  group('CanvasBufferClient/KvStore', () {
    var api;
    var kvStore;
    var restClient;

    setUp(() async {
      final dio = Dio();
      dio.httpClientAdapter = MockAdapter();
      restClient = CanvasRestClient(dio, baseUrl: MockAdapter.mockBase);
      kvStore = await KvStore.openInMemory();
      api = CanvasBufferClient(restClient, kvStore);
    });

    tearDown(() {
      api.close();
      restClient = null;
      kvStore = null;
      api = null;
    });

    test('should get course list multiple times with cache', () async {
      await api.getCourses().last;
      await api.getCoursesF();
      await api.getCourses().last;
      await api.getCoursesF();
      final dataF = await api.getCoursesF();
      final data = await api.getCourses().last;
      expect(data.map((e) => e.toJson()), equals(dataF.map((e) => e.toJson())));
      expect(data.length, equals(3));
      expect(data[0].courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
      expect(data[1].courseCode, isNull);
      expect(data[2].id, equals(318720));
    });

    test('should get course in offline mode', () async {
      final onlineData = await api.getCourses().toList();
      expect(onlineData[0].length, equals(0));
      expect(onlineData[1].length, equals(3));
      api.enableOffline();
      final dataF = await api.getCoursesF();
      final data = await api.getCourses().last;
      expect(data.map((e) => e.toJson()), equals(dataF.map((e) => e.toJson())));
      expect(data.length, equals(3));
      expect(data[0].courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
      expect(data[1].courseCode, isNull);
      expect(data[2].id, equals(318720));
      final data2 = await api.getCourse(23333).last;
      expect(data2.courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
    });

    test('should get tabs in offline mode', () async {
      final onlineData = await api.getTabs(23333).toList();
      expect(onlineData[0].length, equals(0));
      expect(onlineData[1].length, equals(9));
      api.enableOffline();
      final data = await api.getTabs(23333).last;
      expect(data.length, equals(9));
      expect(data[0].id, equals('home'));
    });

    test('should get activity stream in one-shot mode', () async {
      final data = await api.getCurrentUserActivityStreamF();
      final dataJson = await data.toList();
      api.enableOffline();
      final offlineData = await api.getCurrentUserActivityStreamF();
      final offlineDataJson = await offlineData.toList();
      expect(dataJson.length, equals(offlineDataJson.length));
      expect(json.encode(dataJson), equals(json.encode(offlineDataJson)));
    });

    test('should get activity stream in stream mode', () async {
      final data = await api.getCurrentUserActivityStream().last;
      final dataJson = await data.toList();
      final offlineData = await api.getCurrentUserActivityStream().first;
      final offlineDataJson = await offlineData.toList();
      expect(dataJson.length, equals(offlineDataJson.length));
      expect(json.encode(dataJson), equals(json.encode(offlineDataJson)));
    });
  });
}

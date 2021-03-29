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
      expect(data.length, equals(2));
      expect(data[0].courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
      expect(data[1].id, equals(318720));
    });

    test('should get single course', () async {
      final response = await api.getCourse(23333).last;
      expect(response!.courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
    });

    test('should catch inner error when 404', () async {
      var errCount = 0;
      await api.getCourse(23334).handleError((_) => errCount += 1).toList();
      expect(errCount, equals(1));
    });

    test('should catch listing inner error when 404', () async {
      var errCount = 0;
      final result = await api
          .getTabs(23333333)
          .handleError((_) => errCount += 1)
          .toList();
      expect(result.length, equals(1));
      expect(errCount, equals(1));
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
      kvStore = KvStore.openInMemory();
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
      await api.getCourses().last;
      final data = await api.getCourses().last;
      expect(data.length, equals(2));
      expect(data[0].courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
      expect(data[1].id, equals(318720));
    });

    test('should get course in offline mode', () async {
      final onlineData = await api.getCourses().toList();
      expect(onlineData[0].length, equals(0));
      expect(onlineData[1].length, equals(2));
      api.enableOffline();
      final data = await api.getCourses().last;
      expect(data.length, equals(2));
      expect(data[0].courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
      expect(data[1].id, equals(318720));
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

    test('should get activity stream in stream mode', () async {
      final data = await api.getCurrentUserActivityStream().last;
      final dataJson = await data.toList();
      final offlineData = await api.getCurrentUserActivityStream().first;
      final offlineDataJson = await offlineData.toList();
      expect(dataJson.length, equals(offlineDataJson.length));
      expect(json.encode(dataJson), equals(json.encode(offlineDataJson)));
    });

    test('should get modules in stream mode', () async {
      final data = await api.getModules(23333).last;
      final dataJson = await data.toList();
      final offlineData = await api.getModules(23333).first;
      final offlineDataJson = await offlineData.toList();
      expect(dataJson.length, equals(offlineDataJson.length));
      expect(json.encode(dataJson), equals(json.encode(offlineDataJson)));
    });

    test('should get assignments in stream mode', () async {
      final data = await api.getAssignments(23333).last;
      final dataJson = await data.toList();
      final offlineData = await api.getAssignments(23333).first;
      final offlineDataJson = await offlineData.toList();
      expect(dataJson.length, equals(offlineDataJson.length));
      expect(json.encode(dataJson), equals(json.encode(offlineDataJson)));
    });

    test('should get submission summary in stream mode', () async {
      final data = await api.getSubmission(23333, 24444).last;
      final offlineData = await api.getSubmission(23333, 24444).first;
      expect(data!.id, equals(3904019));
      expect(json.encode(data), equals(json.encode(offlineData)));
    });
  });
}

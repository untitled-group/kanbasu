import 'dart:async';
import 'dart:convert';
import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:kanbasu/models/course.dart';
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
      final data = await (api.getCourses().last).toList();
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

      final result = api.getCourse(23334);
      expect(await result.first, isNull);
      // https://github.com/dart-lang/sdk/issues/44386
      try {
        expect(await result.last, isNull);
      } catch (err) {
        errCount += 1;
      }
      expect(errCount, equals(1));
    });

    test('should catch listing inner error when 404', () async {
      var errCount = 0;
      final result = api.getTabs(23333333);
      final onError = (Object err, StackTrace st) {
        errCount += 1;
        return null;
      };

      expect(result.length, equals(2));
      await result[0].handleError(onError).toList();
      await result[1].handleError(onError).toList();

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
      // api.close();
      restClient = null;
      kvStore = null;
      api = null;
    });

    test('should get current user', () async {
      final data = await api.getCurrentUser();
      expect(data.length, equals(2));
      expect((await data[1]).id, equals(23334));
    });

    test('should return only one item in offline mode', () async {
      api.enableOffline();
      final data = await api.getCurrentUser();
      expect(data.length, equals(1));
      expect(await data[0], isNull);
    });

    test('should get course list multiple times with cache', () async {
      await api.getCourses().last.toList();
      await api.getCourses().last.toList();
      final data = await api.getCourses().first.toList();
      expect(data.length, equals(2));
      expect(data[0].courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
      expect(data[1].id, equals(318720));
    });

    test('should get course in offline mode', () async {
      final onlineData = await api.getCourses();
      expect((await onlineData[0].toList()).length, equals(0));
      expect((await onlineData[1].toList()).length, equals(2));
      api.enableOffline();
      final data = await api.getCourses().last.toList();
      expect(data.length, equals(2));
      expect(data[0].courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
      expect(data[1].id, equals(318720));
      final data2 = await api.getCourse(23333).last;
      expect(data2.courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
      api.disableOffline();
    });

    test('should fill course cache when listing', () async {
      await api.getCourses().last.toList();
      final data = await api.getCourse(23333).first;
      expect(data!.courseCode, equals('(2019-2020-1)-MA119-4-概率统计'));
    });

    test('should get tabs in offline mode', () async {
      final onlineData = api.getTabs(23333);
      expect(await onlineData[0].length, equals(0));
      expect(await onlineData[1].length, equals(9));
      api.enableOffline();
      final data = await api.getTabs(23333).last.toList();
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

    test('should get info about a single module in stream mode', () async {
      final data = await api.getModule(23333, 89728).last;
      final offlineData = await api.getModule(23333, 89728).first;
      expect(data!.name, equals('课程介绍'));
      expect(json.encode(data), equals(json.encode(offlineData)));
    });

    test('should cache module when fetching all modules', () async {
      final data = await api.getModules(23333).toList();
      expect(await data[0].toList(), equals([]));
      await data[1].toList(); // ensure all REST APIs have been called
      final offlineData = await api.getModule(23333, 89728).first;
      expect(offlineData!.name, equals('课程介绍'));
    });

    test('should get module items in stream mode', () async {
      final data = await api.getModuleItems(23333, 89729).last;
      final dataJson = await data.toList();
      final offlineData = await api.getModuleItems(23333, 89729).first;
      final offlineDataJson = await offlineData.toList();
      expect(dataJson.length, equals(offlineDataJson.length));
      expect(json.encode(dataJson), equals(json.encode(offlineDataJson)));
    });

    test('should get info about a single module item in stream mode', () async {
      final data = await api.getModuleItem(23333, 89729, 400460).last;
      final offlineData = await api.getModuleItem(23333, 89729, 400460).first;
      expect(data!.title, equals('1. Introduction to SE.pdf'));
      expect(json.encode(data), equals(json.encode(offlineData)));
    });

    test('should cache module item when fetching all module items', () async {
      final data = await api.getModuleItems(23333, 89729).toList();
      expect(await data[0].toList(), equals([]));
      await data[1].toList(); // ensure all REST APIs have been called
      final offlineData = await api.getModuleItem(23333, 89729, 400460).first;
      expect(offlineData!.title, equals('1. Introduction to SE.pdf'));
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
      expect(data!.id, equals(24444));
      expect(json.encode(data), equals(json.encode(offlineData)));
    });

    test('should get unsubmitted submission summary in stream mode', () async {
      final data = await api.getSubmission(23333, 25555).last;
      final offlineData = await api.getSubmission(23333, 25555).first;
      expect(data!.id, equals(25555));
      expect(json.encode(data), equals(json.encode(offlineData)));
    });

    test('should get files in stream mode', () async {
      final data = await api.getFiles(23333).last;
      final dataJson = await data.toList();
      final offlineData = await api.getFiles(23333).first;
      final offlineDataJson = await offlineData.toList();
      expect(dataJson.length, equals(offlineDataJson.length));
      expect(json.encode(dataJson), equals(json.encode(offlineDataJson)));
    });

    test('should get info about a single file in stream mode', () async {
      final data = await api.getFile(23333, 24444).last;
      final offlineData = await api.getFile(23333, 24444).first;
      expect(data!.filename, equals('0.+Course+Introduction.pdf'));
      expect(json.encode(data), equals(json.encode(offlineData)));
    });

    test('should cache file when fetching all files', () async {
      final data = await api.getFiles(23333).toList();
      expect(await data[0].toList(), equals([]));
      await data[1].toList(); // ensure all REST APIs have been called
      final offlineData = await api.getFile(23333, 24444).first;
      expect(offlineData!.filename, equals('0.+Course+Introduction.pdf'));
    });

    test('should get pages in stream mode', () async {
      final data = await api.getPages(23333).last;
      final dataJson = await data.toList();
      final offlineData = await api.getPages(23333).first;
      final offlineDataJson = await offlineData.toList();
      expect(dataJson.length, equals(offlineDataJson.length));
      expect(json.encode(dataJson), equals(json.encode(offlineDataJson)));
    });

    test('should get info about a single page in stream mode', () async {
      final data = await api.getPage(23333, 41136).last;
      final offlineData = await api.getPage(23333, 41136).first;
      expect(data!.title, equals('第一节课在线视频'));
      expect(json.encode(data), equals(json.encode(offlineData)));
    });

    test('should cache page when fetching all pages', () async {
      final data = await api.getPages(23333).toList();
      expect(await data[0].toList(), equals([]));
      await data[1].toList(); // ensure all REST APIs have been called
      final offlineData = await api.getPage(23333, 41136).first;
      expect(offlineData!.title, equals('第一节课在线视频'));
    });

    test('should get planners in stream mode', () async {
      final data = await api.getPlanners().last;
      final dataJson = await data.toList();
      final offlineData = await api.getPlanners().first;
      final offlineDataJson = await offlineData.toList();
      expect(dataJson.length, equals(offlineDataJson.length));
      expect(json.encode(dataJson), equals(json.encode(offlineDataJson)));
    });

    test('should get folders in stream mode', () async {
      final data = await api.getFolders(23333).last;
      final dataJson = await data.toList();
      final offlineData = await api.getFolders(23333).first;
      final offlineDataJson = await offlineData.toList();
      expect(dataJson.length, equals(offlineDataJson.length));
      expect(json.encode(dataJson), equals(json.encode(offlineDataJson)));
    });

    test('should get info about a single folder in stream mode', () async {
      final data = await api.getFolder(23333, 313142).last;
      final offlineData = await api.getFolder(23333, 313142).first;
      expect(data!.name, equals('assignments'));
      expect(json.encode(data), equals(json.encode(offlineData)));
    });

    test('should cache page when fetching all folders', () async {
      final data = await api.getFolders(23333).toList();
      expect(await data[0].toList(), equals([]));
      await data[1].toList(); // ensure all REST APIs have been called
      final offlineData = await api.getFolder(23333, 313142).first;
      expect(offlineData!.name, equals('assignments'));
    });

    test('should get info about all submissions in stream mode', () async {
      final data = await api.getSubmissions(23333).last;
      final dataJson = await data.toList();
      final offlineData = await api.getSubmissions(23333).first;
      final offlineDataJson = await offlineData.toList();
      expect(dataJson.length, equals(offlineDataJson.length));
      expect(json.encode(dataJson), equals(json.encode(offlineDataJson)));
    });

    test('should get info about all submissions with queries in stream mode',
        () async {
      final data = await api.getSubmissions(23334).last;
      final dataJson = await data.toList();
      final offlineData = await api.getSubmissions(23334).first;
      final offlineDataJson = await offlineData.toList();
      expect(dataJson.length, equals(offlineDataJson.length));
      expect(json.encode(dataJson), equals(json.encode(offlineDataJson)));
    });
  });
}

import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:kanbasu/resolver/resolver.dart';
import 'package:test/test.dart';
import 'package:dio/dio.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import './mocks/mock_adapter.dart';

void main() {
  KvStore.initFfi();

  group('Resolver', () {
    final dio = Dio();
    dio.httpClientAdapter = MockAdapter();
    final restClient = CanvasRestClient(dio, baseUrl: MockAdapter.mockBase);
    final api = CanvasBufferClient(restClient, null);

    test('should be able to resolve all items', () async {
      final resolver = Resolver(api);
      await resolver.resolve().toList();
    });
  });
}

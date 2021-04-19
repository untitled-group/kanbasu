import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:kanbasu/resolver/resolver.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import 'package:kanbasu/utils/logging.dart';

Future<void> resolverMain() async {
  final logger = createLogger();
  final apiKey = Platform.environment['CANVAS_API_KEY'];
  logger.i('Using API Key $apiKey');

  logger.i('Creating KeySpace...');
  final keyspace = KvStore.openInMemory();

  logger.i('Creating REST client...');
  final rest = CanvasRestClient(
    Dio(BaseOptions(
      headers: {HttpHeaders.authorizationHeader: 'Bearer $apiKey'},
    )),
    baseUrl: 'https://oc.sjtu.edu.cn/api/v1',
  );

  logger.i('Resolving...');
  final resolver = Resolver(rest, keyspace, logger);
  await for (final progress in resolver.visit()) {
    logger.i(progress);
  }
}

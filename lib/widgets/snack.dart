import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kanbasu/utils/logging.dart';

void showErrorSnack(BuildContext context, dynamic e) {
  final String error;
  final logger = createLogger();
  if (e is DioError) {
    error = e.error.toString();
  } else {
    error = e.runtimeType.toString();
  }
  logger.e(e);
  showSnack(context, 'error.check_net_api'.tr(args: [error]));
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
  ));
}

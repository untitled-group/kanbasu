import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/utils/logging.dart';
import 'package:provider/provider.dart';

void showErrorSnack(BuildContext context, dynamic e) {
  final String error;
  final logger = createLogger();
  final model = context.watch<Model>();

  if (e is DioError) {
    error = e.error.toString();
    if (e.error is SocketException) {
      model.connected = false;
    }
  } else {
    error = e.runtimeType.toString();
  }
  logger.e(e);

  if (model.connected) {
    showSnack(context, 'error.check_net_api'.tr(args: [error]));
  }
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
  ));
}

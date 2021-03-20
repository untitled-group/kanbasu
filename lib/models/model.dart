import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../rest_api/canvas.dart';
import '../config.dart';

class Model with ChangeNotifier {
  int _activeTab = 0;
  int get activeTab => _activeTab;

  late final CanvasRestClient canvas = CanvasRestClient(
      Dio(BaseOptions(headers: {
        HttpHeaders.authorizationHeader: 'Bearer $CANVAS_API_KEY'
      })),
      baseUrl: CANVAS_API_ENDPOINT);

  void setActiveTab(int v) {
    _activeTab = v;
    notifyListeners();
  }
}

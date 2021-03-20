import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../rest_api/canvas.dart';
import '../config.dart';

class Palette {
  final Color primary;
  final Color text;
  final Color secondaryText;
  final Color tertiaryText;
  final Color background;
  final Color grayBackground;
  final Color border;

  const Palette({
    required this.primary,
    required this.text,
    required this.secondaryText,
    required this.tertiaryText,
    required this.background,
    required this.grayBackground,
    required this.border,
  });
}

class Model with ChangeNotifier {
  final theme = Palette(
    primary: Color(0xffE5242E),
    text: Colors.black,
    secondaryText: Colors.grey.shade800,
    tertiaryText: Colors.grey.shade600,
    background: Colors.white,
    grayBackground: Colors.grey.shade100,
    border: Colors.grey.shade300,
  );

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

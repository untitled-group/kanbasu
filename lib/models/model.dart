import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import 'package:kanbasu/utils/prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    primary: Colors.red.shade700,
    text: Colors.black,
    secondaryText: Colors.grey.shade800,
    tertiaryText: Colors.grey.shade600,
    background: Colors.white,
    grayBackground: Colors.grey.shade100,
    border: Colors.grey.shade300,
  );

  int _activeTab = 0;
  int get activeTab => _activeTab;

  late CanvasRestClient _canvas;
  CanvasRestClient get canvas => _canvas;

  Future<void> updateCanvasClient() async {
    final prefs = await SharedPreferences.getInstance();

    final api_key = getApiKey(prefs);
    final api_endpoint = getApiEndpoint(prefs);

    _canvas = CanvasRestClient(
        Dio(BaseOptions(
            headers: {HttpHeaders.authorizationHeader: 'Bearer $api_key'})),
        baseUrl: '$api_endpoint');

    // TODO: notify widgets to refresh
    notifyListeners();
  }

  Future<void> init() async {
    await updateCanvasClient();
  }

  void setActiveTab(int v) {
    _activeTab = v;
    notifyListeners();
  }
}

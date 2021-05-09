import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import 'package:kanbasu/utils/persistence.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Palette {
  final Color primary;
  final Color text;
  final Color secondaryText;
  final Color tertiaryText;
  final Color background;
  final Color grayBackground;
  final Color border;
  final Color succeed;
  final Color warning;

  const Palette({
    required this.primary,
    required this.text,
    required this.secondaryText,
    required this.tertiaryText,
    required this.background,
    required this.grayBackground,
    required this.border,
    required this.succeed,
    required this.warning,
  });
}

class Model with ChangeNotifier {
  final _themeLight = Palette(
    primary: Colors.red.shade700,
    text: Colors.black,
    secondaryText: Colors.grey.shade800,
    tertiaryText: Colors.grey.shade600,
    background: Colors.white,
    grayBackground: Colors.grey.shade50,
    border: Colors.grey.shade300,
    succeed: Colors.green,
    warning: Colors.yellow,
  );

  final _themeDark = Palette(
    primary: Colors.red.shade700,
    text: Colors.grey.shade300,
    secondaryText: Colors.grey.shade400,
    tertiaryText: Colors.grey.shade500,
    background: Colors.black,
    grayBackground: Colors.grey.shade900,
    border: Colors.grey.shade700,
    succeed: Colors.green,
    warning: Colors.yellow,
  );

  var _brightness = Brightness.light;
  Brightness get brightness => _brightness;
  set brightness(Brightness brightness) {
    if (brightness != _brightness) {
      Future.microtask(() {
        _brightness = brightness;
        notifyListeners();
      });
    }
  }

  Palette get theme => brightness == Brightness.dark ? _themeDark : _themeLight;

  late CanvasBufferClient _canvas;
  CanvasBufferClient get canvas => _canvas;

  late CanvasRestClient _rest;
  CanvasRestClient get rest => _rest;

  late KvStore _kvs;
  KvStore get kvs => _kvs;

  bool _connected = true;
  bool get connected => _connected;
  set connected(value) {
    _connected = value;
    notifyListeners();
  }

  Future<void> updateCanvasClient() async {
    final prefs = await SharedPreferences.getInstance();

    final api_key = getApiKey(prefs);
    final api_endpoint = getApiEndpoint(prefs);

    final restCanvas = CanvasRestClient(
      Dio(BaseOptions(
        headers: {HttpHeaders.authorizationHeader: 'Bearer $api_key'},
      )),
      baseUrl: '$api_endpoint',
    );
    final kvs = KvStore.open(KvStoreIdentifiers.main(api_key));

    _rest = restCanvas;
    _kvs = kvs;
    _canvas = CanvasBufferClient(restCanvas, kvs);

    notifyListeners();
  }

  Future<void> deleteKv() async {
    await _canvas.kvStore?.delete();
  }

  Future<void> init() async {
    await updateCanvasClient();
  }
}

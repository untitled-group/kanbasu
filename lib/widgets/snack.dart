import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void showErrorSnack(BuildContext context, dynamic e) {
  final String error;
  if (e is DioError) {
    error = e.error.toString();
  } else {
    error = e.runtimeType.toString();
  }
  showSnack(context,
      'Error: $error.\nCheck the connection and your provided API key.');
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
  ));
}

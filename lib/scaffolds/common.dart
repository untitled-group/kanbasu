import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonScaffold extends StatelessWidget {
  final Widget title;
  final Widget body;
  final Widget? action;
  final PreferredSizeWidget? bottom;

  CommonScaffold({
    required this.title,
    required this.body,
    this.action,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: [action].whereType<Widget>().toList(),
        bottom: bottom,
      ),
      body: body,
    );
  }
}

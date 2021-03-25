import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:kanbasu/router.dart';

class Link extends StatelessWidget {
  final String path;
  final Widget child;

  const Link({
    Key? key,
    required this.path,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => navigateTo(context, path),
      child: child,
    );
  }
}

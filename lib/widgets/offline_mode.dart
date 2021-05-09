import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/utils/connectivity.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class _OfflineModeWidget extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<Model>().theme;

    return Container(
      color: theme.grayBackground,
      child: Center(
        child: Text(
          'error.offline_mode'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: theme.tertiaryText,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(20);
}

class OfflineModeWrapper extends HookWidget {
  final Widget? child;

  OfflineModeWrapper({this.child});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<Model>();

    useEffect(() {
      final timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        final newConnected = await checkConnectivity();
        model.connected = newConnected;
      });
      return () => timer.cancel();
    });

    return model.connected
        ? child ?? Container()
        : Scaffold(
            appBar: _OfflineModeWidget(),
            body: child,
          );
  }
}

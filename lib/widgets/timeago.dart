import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/utils/timeago.dart';

typedef TimeagoBuilder = Widget Function(BuildContext context, String value);

class TimeagoWidget extends HookWidget {
  final DateTime dateTime;
  final TimeagoBuilder builder;

  TimeagoWidget({
    required this.dateTime,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final refreshKey = useState(0);
    final formatted = timeagoFormat(context, dateTime);

    useEffect(() {
      final timer = Timer.periodic(
        Duration(minutes: 1),
        (_) => refreshKey.value += 1,
      );
      return () => timer.cancel();
    });

    return builder(context, formatted);
  }
}

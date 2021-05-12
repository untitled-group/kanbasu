import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:easy_localization/easy_localization.dart';

String timeagoFormat(BuildContext context, DateTime dateTime) => timeago.format(
      dateTime,
      locale: context.locale.toStringWithSeparator(),
      allowFromNow: true,
    );

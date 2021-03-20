import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';

import 'assignment.dart';
import 'lock_info.dart';
import 'user.dart';
import 'tab.dart';
import 'course.dart';
import 'activity_item.dart';

part 'serializers.g.dart';

@SerializersFor([Assignment, LockInfo, User, Tab, Course, ActivityItem])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(Iso8601DateTimeSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();

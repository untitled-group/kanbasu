import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:kanbasu/models/term.dart';
import 'package:kanbasu/models/user_display.dart';
import 'package:kanbasu/models/discussion_topic.dart';

import 'assignment.dart';
import 'lock_info.dart';
import 'user.dart';
import 'tab.dart';
import 'course.dart';
import 'maybe_course.dart';
import 'activity_item.dart';
import 'module.dart';
import 'module_item.dart';
import 'submission.dart';
import 'file.dart';
import 'folder.dart';
import 'page.dart';
import 'planner.dart';
import 'plannable.dart';
import 'brief_info.dart';

part 'serializers.g.dart';

@SerializersFor([
  Assignment,
  LockInfo,
  User,
  Tab,
  Course,
  ActivityItem,
  MaybeCourse,
  Module,
  ModuleItem,
  Submission,
  File,
  Page,
  Planner,
  Folder,
  UserDisplay,
  DiscussionTopic,
  BriefInfo,
  Term,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(Iso8601DateTimeSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();

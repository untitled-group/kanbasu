import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/discussion_topic.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/announcement.dart';
import 'package:kanbasu/widgets/refreshable_stream_list.dart';
import 'package:provider/provider.dart';

class CourseAnnouncementsScreen
    extends RefreshableStreamListWidget<DiscussionTopic> {
  final int courseId;

  CourseAnnouncementsScreen(this.courseId);

  @override
  Stream<Stream<DiscussionTopic>> getStreamStream(context) =>
      Provider.of<Model>(context).canvas.getAnnouncements(courseId);

  @override
  Widget buildItem(context, DiscussionTopic item) {
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        isScrollControlled: true,
        builder: (context) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.3,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: AnnouncementContentWidget(item),
          );
        },
      ),
      child: AnnouncementWidget(item),
    );
  }
}

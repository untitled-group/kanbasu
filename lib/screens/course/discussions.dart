import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/discussion_topic.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
import 'package:kanbasu/widgets/discussion.dart';
import 'package:provider/provider.dart';

class CourseDiscussionsScreen
    extends RefreshableStreamListWidget<DiscussionTopic> {
  final int courseId;

  CourseDiscussionsScreen(this.courseId);

  @override
  List<Stream<DiscussionTopic>> getStreams(context) =>
      Provider.of<Model>(context).canvas.getDiscussionTopics(courseId);

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
            child: DiscussionContentWidget(courseId, item),
          );
        },
      ),
      child: DiscussionWidget(item),
    );
  }
}

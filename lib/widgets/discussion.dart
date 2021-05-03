import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kanbasu/models/discussion_entry.dart';
import 'package:kanbasu/models/discussion_topic.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/router.dart';
import 'package:kanbasu/widgets/announcement.dart';
import 'package:kanbasu/widgets/common/future.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:provider/provider.dart';

class DiscussionWidget extends AnnouncementWidget {
  DiscussionWidget(DiscussionTopic item) : super(item);
}

class DiscussionContentWidget extends FutureWidget<List<DiscussionEntry>> {
  final int courseId;
  final DiscussionTopic topic;

  DiscussionContentWidget(this.courseId, this.topic);

  Widget _buildEntry(
    BuildContext context,
    DiscussionEntry entry,
    int floorNumber,
  ) {
    final theme = Provider.of<Model>(context).theme;
    final bubbleStyle = BubbleStyle(
      radius: Radius.circular(12),
      nip: BubbleNip.leftTop,
      color: theme.background,
      elevation: 2,
      margin: BubbleEdges.only(top: 8, bottom: 8),
      alignment: Alignment.topLeft,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.user.avatarImageUrl != null) ...[
          Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(entry.user.avatarImageUrl!),
              ),
              SizedBox(height: 6),
              Text.rich(TextSpan(children: [
                TextSpan(
                  text: entry.user.displayName ?? '',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ])),
            ],
          ),
          SizedBox(width: 10),
        ],
        Flexible(
          child: Bubble(
            style: bubbleStyle,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topRight,
                  child: Text(
                    '#${floorNumber.toString()}',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.secondaryText,
                    ),
                  ),
                ),
                Html(
                  data: entry.message,
                  shrinkWrap: true,
                  onLinkTap: (url, _, __, ___) {
                    if (url != null) navigateTo(url);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildWidget(BuildContext context, List<DiscussionEntry>? data) {
    data?.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return ListView(
      shrinkWrap: true,
      children: [
        DiscussionWidget(topic),
        if (data != null) ...[
          for (final entry in data.asMap().entries)
            Container(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: _buildEntry(context, entry.value, entry.key + 1),
            ),
        ] else
          LoadingWidget(isMore: false),
      ],
    );
  }

  @override
  List<Future<List<DiscussionEntry>>> getFutures(BuildContext context) =>
      Provider.of<Model>(context)
          .canvas
          .getDiscussionEntries(courseId, topic.id)
          .map((stream) => stream.toList())
          .toList();
}

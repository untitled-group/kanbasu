import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/discussion_entry.dart';
import 'package:kanbasu/models/discussion_topic.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/utils/html.dart';
import 'package:kanbasu/widgets/announcement.dart';
import 'package:kanbasu/widgets/border.dart';
import 'package:kanbasu/widgets/common/future.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:provider/provider.dart';

class DiscussionWidget extends AnnouncementWidget {
  DiscussionWidget(DiscussionTopic item) : super(item);
}

class DiscussionPostWidget extends HookWidget {
  final int courseId;
  final int topicId;
  final VoidCallback refresh;

  DiscussionPostWidget(
    this.courseId,
    this.topicId,
    this.refresh,
  );

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final sending = useState<bool>(false);

    final textField = TextField(
      controller: controller,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 5,
      autofocus: true,
      readOnly: sending.value,
      style: TextStyle(
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: 'Post something',
      ),
    );

    final button = IconButton(
      icon: Icon(Icons.send),
      onPressed: sending.value
          ? null
          : () async {
              final rest = context.read<Model>().rest;
              final message = controller.value.text;

              sending.value = true;
              try {
                final response = await rest.postDiscussionEntry(
                  courseId,
                  topicId,
                  message,
                );
                // await Future.delayed(Duration(seconds: 1));
                print(response.data.toString());
              } finally {
                controller.clear();
                sending.value = false;
                refresh();
              }
            },
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: textField),
          button,
        ],
      ),
    );
  }
}

class DiscussionEntriesWidget extends FutureWidget<List<DiscussionEntry>> {
  final int courseId;
  final DiscussionTopic topic;

  DiscussionEntriesWidget(this.courseId, this.topic, refreshTimes)
      : super(refreshTimes: refreshTimes);

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
              SizedBox(height: 2),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(getPlainText(entry.message)),
                ),
                SizedBox(width: 10),
                Text(
                  '#${floorNumber.toString()}',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.secondaryText,
                  ),
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

    final controller = useScrollController();
    useEffect(() {
      if (controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView(
      controller: controller,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: [
        if (data != null) ...[
          for (final entry in data.asMap().entries)
            Container(
              padding: EdgeInsets.only(left: 16, right: 4, bottom: 4),
              child: _buildEntry(context, entry.value, entry.key + 1),
            ),
        ] else
          LoadingWidget(isMore: false),
      ],
    );
  }

  @override
  List<Future<List<DiscussionEntry>>> getFutures(BuildContext context) =>
      context
          .read<Model>()
          .canvas
          .getDiscussionEntries(courseId, topic.id)
          .map((stream) => stream.toList())
          .toList();
}

class DiscussionContentWidget extends HookWidget {
  final int courseId;
  final DiscussionTopic topic;

  DiscussionContentWidget(this.courseId, this.topic);

  @override
  Widget build(BuildContext context) {
    final refreshTimes = useState<int>(0);
    final refresh = () => refreshTimes.value += 1;

    return Column(
      children: [
        DiscussionWidget(topic),
        Expanded(child: DiscussionEntriesWidget(courseId, topic, refreshTimes)),
        ListBorder(),
        DiscussionPostWidget(courseId, topic.id, refresh)
      ],
    );
  }
}

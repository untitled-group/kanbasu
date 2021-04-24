import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/discussion_topic.dart';
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:separated_column/separated_column.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:easy_localization/easy_localization.dart';

class AnnouncementWidget extends StatelessWidget {
  final DiscussionTopic item;

  AnnouncementWidget(this.item);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Model>(context).theme;
    final isRead = item.readState == 'read';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SeparatedColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  separatorBuilder: (context, index) => SizedBox(height: 1),
                  children: [
                    Text.rich(
                      TextSpan(
                          style: TextStyle(
                            fontSize: 17,
                            color: theme.text,
                            fontWeight: isRead ? null : FontWeight.bold,
                          ),
                          children: [
                            TextSpan(text: item.title.trim()),
                          ]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          timeago.format(
                            item.postedAt,
                            locale: context.locale.toStringWithSeparator(),
                          ),
                          style: TextStyle(
                              fontSize: 14, color: theme.tertiaryText),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          isRead ? Icons.done : null,
                          color: theme.primary,
                          size: 15,
                        ),
                        Spacer(),
                        Text(
                          item.author.displayName,
                          style: TextStyle(
                              fontSize: 14, color: theme.tertiaryText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnnouncementContentWidget extends StatelessWidget {
  final DiscussionTopic item;

  AnnouncementContentWidget(this.item);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        AnnouncementWidget(item),
        Html(data: item.message),
      ],
    );
  }
}

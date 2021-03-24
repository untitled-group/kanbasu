import 'package:flutter/material.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:separated_column/separated_column.dart';
import 'package:easy_localization/easy_localization.dart';

class ActivityWidget extends StatelessWidget {
  final ActivityItem item;

  ActivityWidget(this.item);

  Widget _buildItems(BuildContext context) {
    final theme = Provider.of<Model>(context).theme;
    final isDone = item.readState || item.workflowState == 'graded';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: theme.primary,
                foregroundColor: theme.background,
                child: Text('activity.short_type.${item.type}'.tr()),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: SeparatedColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  separatorBuilder: (context, index) => SizedBox(height: 1),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.course?.name ?? item.courseId.toString(),
                          style: TextStyle(fontSize: 14, color: theme.primary),
                        )
                      ],
                    ),
                    Text.rich(
                      TextSpan(
                          style: TextStyle(
                            fontSize: 17,
                            color: theme.text,
                            fontWeight: isDone ? null : FontWeight.bold,
                          ),
                          children: [
                            TextSpan(text: item.title.trim()),
                            //* add more span here
                          ]),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timeago.format(
                            item.updatedAt,
                            locale: context.locale.toStringWithSeparator(),
                          ),
                          style: TextStyle(
                              fontSize: 14, color: theme.tertiaryText),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          isDone ? Icons.done : null,
                          color: theme.primary,
                          size: 15,
                        )
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

  @override
  Widget build(BuildContext context) {
    return _buildItems(context);
  }
}

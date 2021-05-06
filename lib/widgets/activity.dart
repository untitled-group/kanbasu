import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kanbasu/models/brief_info.dart';
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:separated_column/separated_column.dart';
import 'package:easy_localization/easy_localization.dart';

class ActivityWidget extends StatelessWidget {
  final BriefInfo item;

  ActivityWidget(this.item);

  Widget _buildItems(BuildContext context) {
    final theme = Provider.of<Model>(context).theme;
    final IconData icon;
    switch (item.type) {
      case BriefInfoType.announcements:
        icon = Icons.campaign_outlined;
        break;
      case BriefInfoType.assignment:
        icon = Icons.assignment_outlined;
        break;
      case BriefInfoType.file:
        icon = Icons.upload_file;
        break;
      case BriefInfoType.grading:
        icon = Icons.assignment_turned_in_outlined;
        break;
      case BriefInfoType.assignmentDue:
        icon = Icons.assignment_late_outlined;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: theme.primary,
            foregroundColor: theme.background,
            child: Icon(icon),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      item.courseName,
                      style: TextStyle(fontSize: 14, color: theme.primary),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            item.isDone ? Icons.done : null,
                            color: theme.primary,
                            size: 14,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            timeago.format(
                              item.createdAt,
                              locale: context.locale.toStringWithSeparator(),
                              allowFromNow: true,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.tertiaryText,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 1),
                Row(
                  children: [
                    Expanded(
                      child: SeparatedColumn(
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 1),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.text,
                              ),
                              children: [
                                TextSpan(
                                  text: item.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (item.suffix != null &&
                                    item.suffix!.isNotEmpty)
                                  TextSpan(
                                    text: ' · ${item.suffix}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.secondaryText,
                                    ),
                                  )
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          if (item.description.isNotEmpty)
                            Text(
                              item.description.trim(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.secondaryText,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.arrow_forward,
                      color: theme.tertiaryText,
                      size: 18,
                    ),
                  ],
                )
              ],
            ),
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

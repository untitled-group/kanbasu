import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:separated_column/separated_column.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:easy_localization/easy_localization.dart';

class AssignmentWidget extends StatelessWidget {
  final Assignment item;
  final bool dueTimeDetails;
  AssignmentWidget(this.item, this.dueTimeDetails);

  @override
  Widget build(BuildContext context) {
    final String dueTimeString;
    final bool passDue;
    final bool submitted;
    final TextStyle dueTimeStyle;
    final theme = Provider.of<Model>(context).theme;

    if (item.dueAt != null) {
      dueTimeString = 'assignment.due_time_is'.tr() +
          (dueTimeDetails
              ? item.dueAt!.toLocal().toString().substring(0, 19)
              : item.dueAt!.toLocal().toString().substring(0, 10));
      passDue = DateTime.now().isAfter(item.dueAt!);
    } else {
      dueTimeString = 'assignment.no_due_time'.tr();
      passDue = false;
    }
    if (passDue) {
      dueTimeStyle = TextStyle(fontSize: 14, color: theme.primary);
    } else {
      dueTimeStyle = TextStyle(fontSize: 14, color: theme.succeed);
    }

    if (item.submission != null) {
      submitted = true;
    } else {
      submitted = false;
    }

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
                          ),
                          children: [
                            TextSpan(text: item.name?.trim()),
                          ]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (item.createdAt != null)
                          Text(
                            timeago.format(
                              item.createdAt!,
                              locale: context.locale.toStringWithSeparator(),
                            ),
                            style: TextStyle(
                                fontSize: 14, color: theme.tertiaryText),
                          ),
                        SizedBox(
                          width: 5,
                        ),
                        Spacer(),
                        Text(
                          dueTimeString,
                          style: dueTimeStyle,
                        ),
                        Icon(
                          submitted ? Icons.done : Icons.error,
                          color: theme.succeed,
                          size: 15,
                        ),
                        // Icon(
                        //   submitted ? Icons.error,
                        //   color: theme.primary,
                        //   size: 15,
                        // ),
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

class AssignmentContentWidget extends StatelessWidget {
  final Assignment item;

  AssignmentContentWidget(this.item);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        AssignmentWidget(item, true),
        Html(data: item.description ?? '<h1> 暂无详情 </h1>'),
      ],
    );
  }
}

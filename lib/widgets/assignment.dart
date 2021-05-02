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
  final bool showDetails;
  AssignmentWidget(this.item, this.showDetails);

  @override
  Widget build(BuildContext context) {
    final String dueTimeString;
    final bool _passDue;
    final bool _submitted;
    final bool _late;
    final bool successfulSubmission;
    final bool lateSubmission;
    final bool waitForSubmission;
    final bool failedSubmission;
    final TextStyle dueTimeStyle;
    final theme = Provider.of<Model>(context).theme;

    if (item.dueAt != null) {
      dueTimeString = 'assignment.due_time_is'.tr() +
          (showDetails
              ? item.dueAt!.toLocal().toString().substring(0, 19)
              : item.dueAt!.toLocal().toString().substring(0, 10));
      _passDue = DateTime.now().isAfter(item.dueAt!);
    } else {
      dueTimeString = 'assignment.no_due_time'.tr();
      _passDue = false;
    }
    if (_passDue) {
      dueTimeStyle = TextStyle(fontSize: 14, color: theme.primary);
    } else {
      dueTimeStyle = TextStyle(fontSize: 14, color: theme.succeed);
    }

    if (item.submission == null) {
      _submitted = false;
      _late = false;
    } else {
      _submitted = item.submission!.attempt != null
          ? item.submission!.attempt! >= 1
          : false;
      _late = item.submission!.late;
    }

    //submission state:
    // 1. failed submission
    // 2. late submission
    // 3. waiting for submission
    // 4. successful submission
    failedSubmission = !_submitted && _passDue;
    lateSubmission = _late;
    waitForSubmission = !_passDue && !_submitted;
    successfulSubmission = _submitted && !_late;

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
                        if (!successfulSubmission)
                          Text(
                            dueTimeString,
                            style: dueTimeStyle,
                          ),
                        SizedBox(
                          width: 5,
                        ),
                        if (successfulSubmission)
                          Icon(
                            Icons.done,
                            color: theme.succeed,
                            size: 15,
                          ),
                        if (successfulSubmission && showDetails)
                          Text('assignment.submission.successful'.tr()),
                        if (failedSubmission || lateSubmission)
                          Icon(
                            Icons.error,
                            color: theme.primary,
                            size: 15,
                          ),
                        if (failedSubmission && showDetails)
                          Text('assignment.submission.failed'.tr()),
                        if (lateSubmission && showDetails)
                          Text('assignment.submission.late'.tr()),
                        if (waitForSubmission)
                          Icon(
                            Icons.warning,
                            color: theme.warning,
                            size: 15,
                          ),
                        if (waitForSubmission && showDetails)
                          Text('assignment.submission.waiting'.tr()),
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
        Html(
            data: item.description ??
                '<h3> ${'assignment.no_details'.tr()} </h3>'),
      ],
    );
  }
}
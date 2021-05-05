import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/module.dart';
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:separated_column/separated_column.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:easy_localization/easy_localization.dart';

class ModuleWidget extends StatelessWidget {
  final Module item;
  ModuleWidget(this.item);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Model>(context).theme;
    final Icon? icon;
    switch (item.state) {
      case 'started':
        icon = Icon(
          Icons.play_arrow_outlined,
          color: theme.warning,
          size: 15,
        );
        break;
      case 'completed':
        icon = Icon(
          Icons.done_all,
          color: theme.succeed,
          size: 15,
        );
        break;
      case 'locked':
        icon = Icon(
          Icons.lock,
          color: theme.primary,
          size: 15,
        );
        break;
      case 'unlock':
        icon = Icon(
          Icons.lock_open,
          color: theme.warning,
          size: 15,
        );
        break;
      default:
        icon = null;
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
                            TextSpan(text: item.name),
                          ]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // if (item.createdAt != null)
                        //   Text(
                        //     timeago.format(
                        //       item.createdAt!,
                        //       locale: context.locale.toStringWithSeparator(),
                        //     ),
                        //     style: TextStyle(
                        //         fontSize: 14, color: theme.tertiaryText),
                        //   ),
                        SizedBox(
                          width: 5,
                        ),
                        Spacer(),
                        if (icon != null) 
                          icon,
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

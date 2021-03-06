import 'package:flutter/material.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';
import 'package:separated_column/separated_column.dart';

class CourseWidget extends StatelessWidget {
  final Course item;

  CourseWidget(this.item);

  Widget _buildItems(BuildContext context) {
    final theme = Provider.of<Model>(context).theme;

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
                child: Text(item.name.substring(0, 1)),
              ),
              SizedBox(
                width: 10,
              ),
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
                            TextSpan(text: item.name.trim()),
                            //* add more span here
                          ]),
                    ),
                    if (item.teachers != null)
                      Text(
                        item.teachers!.map((t) => t.displayName).join(' '),
                        style:
                            TextStyle(fontSize: 14, color: theme.tertiaryText),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: theme.tertiaryText,
                size: 18,
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

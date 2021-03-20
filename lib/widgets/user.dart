import 'package:flutter/material.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/user.dart';
import 'package:provider/provider.dart';
import 'package:separated_column/separated_column.dart';

class UserWidget extends StatelessWidget {
  final User user;

  UserWidget(this.user);

  Widget _buildItems(BuildContext context) {
    final theme = Provider.of<Model>(context).theme;
    final studentId = user.sortableName.split(RegExp(r'-')).firstWhere(
        (e) => BigInt.tryParse(e) != null,
        orElse: () => user.sortableName);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                user.avatarUrl,
                width: 80,
                height: 80,
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
                        style: TextStyle(fontSize: 24, color: theme.text),
                        children: [
                          TextSpan(text: user.name),
                          //* add more span here
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          studentId,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.tertiaryText,
                          ),
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

  @override
  Widget build(BuildContext context) {
    return _buildItems(context);
  }
}

import 'package:flutter/material.dart';
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';
import 'package:separated_column/separated_column.dart';

class KErrorWidget extends StatelessWidget {
  final String errorText;
  final String tips;
  final void Function() onTap;

  KErrorWidget(
      {required this.errorText, required this.tips, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Model>(context).theme;

    return Container(
      padding: EdgeInsets.all(20),
      child: SeparatedColumn(
        separatorBuilder: (context, index) => SizedBox(height: 10),
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'An error occured, some tips:\n\n'),
                TextSpan(text: tips),
              ],
              style: TextStyle(fontSize: 16),
            ),
          ),
          Text(
            errorText,
            style: TextStyle(
              color: theme.primary,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }
}
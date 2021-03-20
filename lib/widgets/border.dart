import 'package:flutter/material.dart';
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';

class ListBorder extends StatelessWidget {
  final double? height;
  final double leftPadding;

  ListBorder({
    this.height,
    this.leftPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Model>(context).theme;

    if (height == null) {
      // Physical pixel
      return Container(
        margin: EdgeInsets.only(left: leftPadding),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.border, width: 0),
          ),
        ),
      );
    }

    return Row(
      children: <Widget>[
        SizedBox(
          width: leftPadding,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(color: theme.background),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(color: theme.border),
            ),
          ),
        ),
      ],
    );
  }
}

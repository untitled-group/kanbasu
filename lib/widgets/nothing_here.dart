import 'package:flutter/material.dart';
import 'package:kanbasu/widgets/single.dart';
import 'package:easy_localization/easy_localization.dart';

class NothingHereWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Single(
        SizedBox(
          height: constraints.maxHeight,
          child: Center(child: Text('error.nothing_here'.tr())),
        ),
      ),
    );
  }
}

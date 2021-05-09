import 'package:flutter/material.dart';
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class OfflineModeWidget extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<Model>().theme;

    return Container(
      color: theme.grayBackground,
      child: Center(
        child: Text(
          'error.offline_mode'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: theme.tertiaryText,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(20);
}

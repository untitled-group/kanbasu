import 'package:flutter/material.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/user.dart';
import 'package:kanbasu/widgets/common/future.dart';
import 'package:provider/provider.dart';

class DrawerHeaderWidget extends FutureWidget<User?> {
  @override
  Widget buildWidget(context, User? user) {
    final studentId = user?.sortableName.split(RegExp(r'-')).firstWhere(
          (e) => BigInt.tryParse(e) != null,
          orElse: () => user.sortableName,
        );

    return UserAccountsDrawerHeader(
      accountName: Text(
        user?.name ?? 'Kanbasu',
        style: TextStyle(fontSize: 18),
      ),
      accountEmail: Text(
        studentId ?? 'Untitled Group',
        style: TextStyle(fontSize: 14),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundImage: NetworkImage(user?.avatarUrl ?? ''),
      ),
    );
  }

  @override
  List<Future<User?>> getFutures(context) =>
      context.read<Model>().canvas.getCurrentUser();
}

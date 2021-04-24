import 'package:flutter/material.dart';

/// [Single] make a single widget scrollable and then refreshable in a
/// [CommonScreen]. It might be used for test purpose.
class Single extends StatelessWidget {
  final Widget child;
  const Single(this.child, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      children: [child],
    );
  }
}

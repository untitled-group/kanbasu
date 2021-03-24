import 'package:flutter/material.dart';

/// [Single] make a single widget scrollable and then refreshable in a
/// [CommonScreen]. It might be used for test purpose.
class Single extends StatelessWidget {
  final Widget child;
  const Single({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final bool isMore;

  LoadingWidget({required this.isMore});

  Widget _buildIndicator(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isMore ? 20 : 100),
        child: _buildIndicator(context),
      ),
    );
  }
}

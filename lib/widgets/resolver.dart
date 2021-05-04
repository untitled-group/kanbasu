import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/resolver/resolver.dart';
import 'package:separated_column/separated_column.dart';

class ResolverWidget extends HookWidget {
  final Stream<ResolveProgress> _resolverStream;

  ResolverWidget(this._resolverStream);

  @override
  Widget build(BuildContext context) {
    final snapshot = useStream(_resolverStream,
        initialData: ResolveProgress(percent: 0.0, message: '加载中'));

    return Container(
        padding: EdgeInsets.all(15),
        child: SeparatedColumn(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            separatorBuilder: (context, index) => SizedBox(height: 5),
            children: [
              LinearProgressIndicator(value: snapshot.data?.percent ?? 0.0),
              Text(snapshot.data?.message ?? '加载中')
            ]));
  }
}

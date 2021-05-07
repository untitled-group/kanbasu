import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/resolver_model.dart';
import 'package:kanbasu/resolver/resolve_progress.dart';
import 'package:provider/provider.dart';
import 'package:separated_column/separated_column.dart';

class ResolverWidget extends HookWidget {
  final Stream<ResolveProgress> _resolverStream;

  ResolverWidget(this._resolverStream);

  @override
  Widget build(BuildContext context) {
    final resolverModel = Provider.of<ResolverModel>(context);
    final progress = useValueListenable(resolverModel.resolveProgress);

    if (progress != null) {
      return Container(
          padding: EdgeInsets.all(15),
          child: SeparatedColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              separatorBuilder: (context, index) => SizedBox(height: 5),
              children: [
                LinearProgressIndicator(value: progress.percent),
                Text(progress.message)
              ]));
    } else {
      return Container();
    }
  }
}

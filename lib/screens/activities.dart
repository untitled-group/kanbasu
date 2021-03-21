import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/widgets/snack.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/scaffolds/stream_list.dart';
import 'package:kanbasu/widgets/activity.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:kanbasu/utils/stream_op.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ActivitiesScreen extends HookWidget {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Model>(context);

    return HookBuilder(builder: (context) {
      final manualRefresh = useState(false);
      final triggerRefresh = useState(Completer());

      final userActivityStream = useMemoized(() {
        final stream = model.canvas
            .getCurrentUserActivityStream()
            // The stream may be subscribed multiple times by children,
            // so we need to replay it, with the help of RxDart extension.
            .map((s) => s.shareReplay())
            // Wait until there are enough elements to fill the screen
            .asyncMap(waitFor(20))
            // Notify RefreshIndicator to complete refresh
            .doOnDone(() => triggerRefresh.value.complete())
            .doOnError((error, _) => showErrorSnack(context, error));
        if (manualRefresh.value) {
          // if manually refresh, return only latest result
          return yieldLast(stream);
        } else {
          return stream;
        }
      }, [manualRefresh.value, triggerRefresh.value]);

      final activitiesSnapshot =
          useStream(userActivityStream, initialData: null);

      final activitiesData = activitiesSnapshot.data;

      return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            manualRefresh.value = true;
            final completer = Completer();
            triggerRefresh.value = completer;
            await completer.future;
          },
          child: activitiesData != null
              ? StreamListScaffold<ActivityItem>(
                  title: Text('Activities'),
                  itemBuilder: (item) => ActivityWidget(item),
                  itemStream: activitiesData)
              : (activitiesSnapshot.error != null
                  ? ElevatedButton(
                      onPressed: () async {
                        final completer = Completer();
                        triggerRefresh.value = completer;
                        await completer.future;
                      },
                      child: Text('Retry'))
                  : LoadingWidget(isMore: true)));
    });
  }
}

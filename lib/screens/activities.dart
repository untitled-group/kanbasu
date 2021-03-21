import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/scaffolds/stream_list.dart';
import 'package:kanbasu/widgets/activity.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

Stream<T> yieldLast<T>(Stream<T> stream) {
  return () async* {
    T? lastItem;
    await for (final item in stream) {
      lastItem = item;
    }
    if (lastItem != null) {
      yield lastItem;
    }
  }();
}

class ActivitiesScreen extends HookWidget {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Model>(context);

    return HookBuilder(
      builder: (context) {
        final manualRefresh = useState(false);
        final triggerRefresh = useState(0);

        final userActivityStream = useMemoized(() {
          final stream = model.canvas
              .getCurrentUserActivityStream()
              // The stream may be subscribed multiple times by children,
              // so we need to replay it, with the help of RxDart extension.
              .map((s) => s.shareReplay());
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
        if (activitiesData != null) {
          return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async {
                // trigger refresh
                manualRefresh.value = true;
                triggerRefresh.value += 1;
                // wait until data has been refreshed
                await activitiesData.length;
              },
              child: StreamListScaffold<ActivityItem>(
                  title: Text('Activities'),
                  itemBuilder: (item) => ActivityWidget(item),
                  itemStream: activitiesData));
        } else {
          return LoadingWidget(isMore: true);
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/scaffolds/stream_list.dart';
import 'package:kanbasu/widgets/activity.dart';
import 'package:kanbasu/models/model.dart';
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
    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      await _refreshIndicatorKey.currentState!.show();
    });

    final model = Provider.of<Model>(context);

    return HookBuilder(
      builder: (context) {
        final refreshCount = useState(0);
        final userActivityStream = useMemoized(() {
          final stream = model.canvas
              .getCurrentUserActivityStream()
              // The stream may be subscribed multiple times by children,
              // so we need to replay it, with the help of RxDart extension.
              .map((s) => s
                  .shareReplay()
                  // Remove this delay later
                  .delay(Duration(seconds: 1)));
          if (refreshCount.value > 0) {
            // if manually refresh, return only latest result
            return yieldLast(stream);
          } else {
            return stream;
          }
        }, [refreshCount]);

        final activitiesSnapshot =
            useStream(userActivityStream, initialData: null);

        final activitiesData = activitiesSnapshot.data;

        if (activitiesData != null) {
          return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async {
                // wait until current data have been fully loaded
                await activitiesData.length;
              },
              child: StreamListScaffold<ActivityItem>(
                  title: Text('Activities'),
                  itemBuilder: (item) => ActivityWidget(item),
                  itemStream: activitiesData,
                  refresh: () async {
                    // notify refresh
                    refreshCount.value += 1;
                  }));
        } else {
          return Container();
        }
      },
    );
  }
}

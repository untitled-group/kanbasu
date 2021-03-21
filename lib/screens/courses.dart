import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/scaffolds/simple_list.dart';
import 'package:kanbasu/widgets/course.dart';
import 'package:kanbasu/widgets/snack.dart';
import 'package:kanbasu/utils/stream_op.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class CoursesScreen extends HookWidget {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Model>(context);

    return HookBuilder(builder: (context) {
      final manualRefresh = useState(false);
      final triggerRefresh = useState(Completer());

      final coursesStream = useMemoized(() {
        final stream = model.canvas
            .getCourses()
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

      final coursesSnapshot = useStream(coursesStream, initialData: null);

      final coursesData = coursesSnapshot.data;

      return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            manualRefresh.value = true;
            final completer = Completer();
            triggerRefresh.value = completer;
            await completer.future;
          },
          child: coursesData != null
              ? SimpleListScaffold<Course>(
                  title: Text('Courses'),
                  itemBuilder: (item) => CourseWidget(item),
                  items: coursesData)
              : coursesSnapshot.error != null
                  ? ElevatedButton(
                      onPressed: () async {
                        final completer = Completer();
                        triggerRefresh.value = completer;
                        await completer.future;
                      },
                      child: Text('Retry'))
                  : LoadingWidget(isMore: true));
    });
  }
}

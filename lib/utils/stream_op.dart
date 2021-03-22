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

Future<Stream<T>> Function(ReplayStream<T>) waitFor<T>(int N) {
  return (stream) async {
    // Prevent stream from being canceled
    stream.listen(null);
    // Wait for at least `N` elements
    await stream.take(N).length;
    return stream;
  };
}

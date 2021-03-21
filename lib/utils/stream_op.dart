import 'package:pedantic/pedantic.dart';
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
    unawaited(stream.length.then((value) => null));
    // Wait for at least 20 elements
    await stream.take(N).length;
    return stream;
  };
}

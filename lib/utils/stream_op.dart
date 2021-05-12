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

Stream<T> yieldFirst<T>(Stream<T> stream) {
  return stream.firstWhere((element) => element != null).asStream();
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

Iterable<Future<C>> zip2<A, B, C>(
  Iterable<Future<A>> a,
  Iterable<Future<B>> b,
  C Function(A, B) combinator,
) sync* {
  final ita = a.iterator;
  final itb = b.iterator;
  while (ita.moveNext() && itb.moveNext()) {
    yield (Future<A> a, Future<B> b) async {
      return combinator(await a, await b);
    }(ita.current, itb.current);
  }
}

Future<List<T>> getListDataFromApi<T>(
    List<Stream<T>> stream, bool useOnlineData) async {
  if (useOnlineData) {
    return await stream.last.toList();
  } else {
    return await stream.first.toList();
  }
}

Future<T> getItemDataFromApi<T>(
    List<Future<T>> stream, bool useOnlineData) async {
  if (useOnlineData) {
    return (await stream.last);
  } else {
    return (await stream.first);
  }
}

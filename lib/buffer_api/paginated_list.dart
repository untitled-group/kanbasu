import 'dart:async';
import 'package:retrofit/retrofit.dart';

/// Extract one `rel` URL from `Link` header.
Map<String, String>? getRelLink(String linkHeader, String rel) {
  final expectedRel = 'rel="$rel"';
  for (final item in linkHeader.split(',')) {
    final splitItem = item.split('; ');
    final urlStr = splitItem[0];
    final rel = splitItem[1];
    if (rel == expectedRel) {
      final url = Uri.tryParse(urlStr, 1, urlStr.length - 1);
      if (url == null) {
        continue;
      }
      return url.queryParameters;
    }
  }
  return null;
}

/// Extract next page from a paginated list response `Link` header.
/// If current page is the last page, returns null.
Map<String, String>? getNextLink(String? linkHeader) {
  if (linkHeader == null) {
    return null;
  }
  final next = getRelLink(linkHeader, 'next');
  final current = getRelLink(linkHeader, 'current');
  if (next == null || current == null) {
    return null;
  }
  if (next == current) {
    return null;
  }
  return next;
}

class PaginatedList<T> {
  /// [PaginatedList] wraps a paginated-list REST API endpoint.
  /// `all()` function returns a stream of all items from this API endpoint.

  final Future<HttpResponse<List<T>>> Function({Map<String, dynamic> queries})
      _sendRequest;
  PaginatedList(this._sendRequest);

  /// Returns a stream of all items from API endpoint.
  Stream<T> all() async* {
    var nextQuery = <String, String>{};
    while (true) {
      final resp = await _sendRequest(queries: nextQuery);
      for (final item in resp.data) {
        yield item;
      }
      final query = getNextLink(resp.response.headers.value('Link'));
      if (query == null) {
        break;
      }
      nextQuery = query;
    }
  }
}

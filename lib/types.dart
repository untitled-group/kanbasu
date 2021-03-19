import 'package:retrofit/retrofit.dart';

typedef FromJson<T> = T Function(Map<String, dynamic>);
typedef ToJson<T> = Map<String, dynamic> Function(T);
typedef ListPaginated<T> = Future<HttpResponse<List<T>>> Function(
    {Map<String, dynamic>? queries});
typedef GetItem<T> = Future<HttpResponse<T>> Function();
typedef GetId<T> = String Function(T);

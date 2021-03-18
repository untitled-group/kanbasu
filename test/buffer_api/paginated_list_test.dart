import 'package:test/test.dart';
import 'package:kanbasu/buffer_api/paginated_list.dart';
import '../mocks/course_mock.dart';

void main() {
  group('PaginatedList', () {
    test('should parse link header', () {
      expect(getNextLink(null), equals(null));
      expect(
          getNextLink(getCoursesLink), equals({'page': '2', 'per_page': '10'}));
    });
  });
}

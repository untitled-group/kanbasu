import 'package:kanbasu/utils/html.dart';
import 'package:test/test.dart';

void main() {
  group('Aggregation', () {
    test('should convert html to plain text', () async {
      expect(getPlainText('<p>Test2333</p>'), equals('Test2333'));
      expect(getPlainText(''), equals(''));
    });
  });
}

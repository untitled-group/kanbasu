import 'package:test/test.dart';
import 'package:kanbasu/aggregation.dart';

void main() {
  group('Aggregation', () {
    test('should convert html to plain text', () async {
      expect(getPlainText('<p>Test2333</p>'), equals('Test2333'));
      expect(getPlainText(''), equals(''));
    });
  });
}

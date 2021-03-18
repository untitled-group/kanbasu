import 'package:test/test.dart';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:flutter/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KvStore.initFfi();
  group('KvStore', () {
    test('should create in-memory kvstore', () async {
      await KvStore.openInMemory();
    });

    test('should create on-disk kvstore', () async {
      await KvStore.open("test");
    });

    test('should support get and put', () async {
      final db = await KvStore.openInMemory();
      await db.setItem("test-key", "2333333");
      expect(await db.getItem("test-key"), equals("2333333"));
      await db.setItem("test-key-2", "你好，世界！");
      expect(await db.getItem("test-key-2"), equals("你好，世界！"));
      await db.setItem("test-key", "23333333");
      expect(await db.getItem("test-key"), equals("23333333"));
    });

    test('should return null when deleted', () async {
      final db = await KvStore.openInMemory();
      await db.setItem("test-key", "2333333");
      expect(await db.getItem("test-key"), equals("2333333"));
      expect(await db.deleteItem("test-key"), equals(1));
      expect(await db.getItem("test-key"), equals(null));
      expect(await db.deleteItem("test-key"), equals(0));
    });

    test('should support range scan and range delete', () async {
      final db = await KvStore.openInMemory();
      await db.setItem("testt/1", "11");
      await db.setItem("testt/2", "12");
      await db.setItem("test/1", "1");
      await db.setItem("test/2", "2");
      await db.setItem("test/4", "4");
      await db.setItem("test/3", "3");
      expect(await db.scan("test/"),
          equals({'test/1': '1', 'test/2': '2', 'test/4': '4', 'test/3': '3'}));
      expect(await db.rangeDelete("test/"), equals(4));
      expect(await db.scan("test/"), equals({}));
      expect(
          await db.scan("testt/"), equals({'testt/1': '11', 'testt/2': '12'}));
    });
  });
}

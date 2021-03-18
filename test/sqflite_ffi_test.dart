import 'package:test/test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

@TestOn('linux || mac-os || windows')
void main() {
  // Init ffi loader if needed.
  sqfliteFfiInit();

  test('simple sqflite example', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    expect(await db.getVersion(), 0);
    await db.close();
  });
}

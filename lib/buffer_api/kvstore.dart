import 'dart:io' show Platform;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kanbasu/utils/logging.dart';

enum ScanOrder { asc, desc }

class KvStore {
  /// [KvStore] stores key-value pairs. Currently, it is backed by sqlite, a
  /// B-Tree engine. [KvStore] supports put, get and range scan.

  static const String _tableName = 'json';
  final logger = createLogger();
  final Future<Database> _database;

  KvStore(this._database);

  /// Initialize FFI for Sqlite on Flutter Desktop
  static void initFfi() {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }
  }

  static Future<void> _initDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $_tableName(
      key TEXT PRIMARY KEY,
      value TEXT,
      lastUpdated INTEGER
    );
    ''');
  }

  /// Open [KvStore] by [name]. The file is persisted
  static KvStore open(String name) {
    final future = () async {
      final directory = await getApplicationSupportDirectory();
      final path = join(directory.path, '$name.db');
      createLogger().i('Database created at $path');
      return openDatabase(path, onCreate: _initDatabase, version: 1);
    };
    return KvStore(future());
  }

  /// Open a in-memory [KvStore].
  static KvStore openInMemory() {
    final database =
        openDatabase(inMemoryDatabasePath, onCreate: _initDatabase, version: 1, singleInstance: false);
    return KvStore(database);
  }

  /// Close the database
  Future<void> close() async {
    final db = await _database;
    return db.close();
  }

  /// Delete all data from the database
  Future<void> delete() async {
    final db = await _database;
    try {
      await db.delete(_tableName);
    } catch (e) {
      createLogger().w('During deleting database: $e');
    }
  }

  /// Set [key] to [value] in database.
  Future<void> setItem(String key, String value) async {
    final db = await _database;
    final lastUpdated = DateTime.now().millisecondsSinceEpoch;
    await db.rawInsert(
      'INSERT OR REPLACE INTO $_tableName(key, value, lastUpdated) VALUES(?, ?, ?)',
      [key, value, lastUpdated],
    );
  }

  /// Get value of [key] from database. Returns null if not exist.
  Future<String?> getItem(String key) async {
    final db = await _database;
    final List<Map<String, dynamic>> queryResult =
        await db.query(_tableName, where: 'key = ?', whereArgs: [key]);
    if (queryResult.isEmpty) {
      return null;
    }
    return queryResult[0]['value'];
  }

  /// Remove [key] from database.
  Future<int> deleteItem(String key) async {
    final db = await _database;
    return await db.delete(_tableName, where: 'key = ?', whereArgs: [key]);
  }

  /// Get all values with [prefix] from database. Returns null if not exist.
  ///
  /// [order] could be null, asc or desc
  Future<Map<String, String>> scan(String prefix, {ScanOrder? order}) async {
    final db = await _database;
    final orderBy;
    switch (order) {
      case null:
        orderBy = null;
        break;
      case ScanOrder.asc:
        orderBy = 'key ASC';
        break;
      case ScanOrder.desc:
        orderBy = 'key DESC';
        break;
    }
    final List<Map<String, dynamic>> queryResult = await db.query(_tableName,
        where: 'key like ?', whereArgs: ['$prefix%'], orderBy: orderBy);
    if (queryResult.isEmpty) {
      return {};
    }
    return {
      for (var item in queryResult)
        item['key'].toString(): item['value'].toString()
    };
  }

  /// Remove keys with [prefix] from database.
  Future<int> rangeDelete(String prefix) async {
    final db = await _database;
    return await db
        .delete(_tableName, where: 'key like ?', whereArgs: ['$prefix%']);
  }
}

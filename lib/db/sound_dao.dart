// sound_dao.dart
import 'package:app_asd_diagnostic/db/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:app_asd_diagnostic/models/sound.dart';

class SoundDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT,'
      'filePath TEXT)';

  static const String _tableName = 'sounds';

  final dbHelper = DatabaseHelper.instance;

  Future<Sound?> getSoundById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Sound.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Sound>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return Sound.fromMap(maps[i]);
    });
  }

  Future<void> insert(Sound sound) async {
    final db = await dbHelper.database;
    await db.insert(
      _tableName,
      sound.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

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

  Future<List<Map<String, dynamic>>> index() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    // Return a new list where each map is a copy of the original
    return maps.map((map) => Map<String, dynamic>.from(map)).toList();
  }

  Future<Map<String, dynamic>?> getOne(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> update(int id, String name, String filepath) async {
    final db = await dbHelper.database;
    return await db.update(
      _tableName,
      {'name': name, 'filePath': filepath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insert(name, filepath) async {
    final db = await dbHelper.database;
    final insert = await db.insert(
      _tableName,
      {
        "name": name,
        "filePath": filepath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return insert;
  }

  Future<void> delete(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> checkSoundIsInForm(int id) async {
    final db = await dbHelper.database;

    final textResponseResult = await db.query(
      'sound_text_response',
      where: 'sound_id = ?',
      whereArgs: [id],
    );
    if (textResponseResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}

import 'package:app_asd_diagnostic/db/database.dart';

class HashAccessDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'id_patient INTEGER, '
      'accessHash TEXT, '
      'gameLinks TEXT, '
      'FOREIGN KEY (id_patient) REFERENCES patients(id)) ';

  static const String _tableName = 'hash_access';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> hash) async {
    final db = await dbHelper.database;
    return await db.insert('hash_access', hash);
  }

  Future<Map<String, dynamic>?> getOne(String hash) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      _tableName,
      where: 'accessHash = ?',
      whereArgs: [hash],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}

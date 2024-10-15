import 'package:app_asd_diagnostic/db/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HashAccessDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'id_patient INTEGER, '
      'user_id INTEGER, '
      'accessHash TEXT, '
      'gameLinks TEXT, '
      'created_at TIMESTAMP, '
      'FOREIGN KEY(user_id) REFERENCES users(id), '
      'FOREIGN KEY (id_patient) REFERENCES patients(id)) ';

  static const String _tableName = 'hash_access';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> hash) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idUser = prefs.getString('inf');

    final DateTime now = DateTime.now();

    final String createdAt = now.toIso8601String();

    final db = await dbHelper.database;
    hash['user_id'] = idUser;
    hash['created_at'] = createdAt;

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

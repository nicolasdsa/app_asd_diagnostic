import 'package:app_asd_diagnostic/db/database.dart';
import 'package:crypt/crypt.dart';

class UserDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT,'
      'username TEXT,'
      'email TEXT,'
      'password TEXT)';

  static const String _tableName = 'users';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(
      String name, String email, String username, String password) async {
    final db = await dbHelper.database;
    final hashedPassword = _hashPassword(password);
    Map<String, dynamic> row = {
      'name': name,
      'email': email,
      'username': username,
      'password': hashedPassword.toString(),
    };
    return await db.insert(_tableName, row);
  }

  Future<bool> login(String username, String password) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> rows = await db.query(
      _tableName,
      where: 'username = ?',
      whereArgs: [username],
    );

    final List<Map<String, dynamic>> result = await db.query(_tableName);

    print(result);

    if (rows.isEmpty) {
      return false; // User not found
    }

    final storedPassword = rows.first['password'] as String;
    if (isValid(storedPassword, password)) {
      return true; // Login successful
    } else {
      return false; // Invalid password
    }
  }

  Crypt _hashPassword(String password) {
    final c1 = Crypt.sha512(password);
    return c1;
  }

  bool isValid(String cryptFormatHash, String enteredPassword) =>
      Crypt(cryptFormatHash).match(enteredPassword);
}

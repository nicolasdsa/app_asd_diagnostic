import 'package:app_asd_diagnostic/db/database.dart';
import 'package:crypt/crypt.dart';

class UserDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT,'
      'username TEXT,'
      'email TEXT,'
      'institute TEXT,'
      'crm TEXT,'
      'password TEXT)';

  static const String _tableName = 'users';

  final dbHelper = DatabaseHelper.instance;

  Future<Map<String, dynamic>> getOne(String email) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> rows = await db.query(
      _tableName,
      where: 'email = ?',
      whereArgs: [email],
    );

    return rows.first;
  }

  Future<Map<String, dynamic>> getOneId(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    return rows.first;
  }

  Future<int> insert(String name, String email, String username,
      String password, String institute, String crm) async {
    final db = await dbHelper.database;
    final hashedPassword = _hashPassword(password);
    Map<String, dynamic> row = {
      'name': name,
      'email': email,
      'username': username,
      'password': hashedPassword.toString(),
      'institute': institute,
      'crm': crm
    };
    return await db.insert(_tableName, row);
  }

  Future<bool> login(String email, String password) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> rows = await db.query(
      _tableName,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (rows.isEmpty) {
      return false;
    }

    final storedPassword = rows.first['password'] as String;
    if (isValid(storedPassword, password)) {
      return true;
    }

    return false;
  }

  Future<bool> loginHash(String username, String password) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> rows = await db.query(
      _tableName,
      where: 'username = ?',
      whereArgs: [username],
    );

    if (rows.isEmpty) {
      return false;
    }

    final storedPassword = rows.first['password'] as String;
    if (isValid(storedPassword, password)) {
      return true;
    }

    return false;
  }

  Crypt _hashPassword(String password) {
    final c1 = Crypt.sha512(password);
    return c1;
  }

  bool isValid(String cryptFormatHash, String enteredPassword) =>
      Crypt(cryptFormatHash).match(enteredPassword);
}

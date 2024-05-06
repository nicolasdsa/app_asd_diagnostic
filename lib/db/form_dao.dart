import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/screens/components/form_user.dart';

class FormDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT, '
      'id_type INTEGER, '
      'FOREIGN KEY (id_type) REFERENCES type_form(id))';

  static const String _tableName = 'forms';
  static const String _name = 'name';
  static const String _id = 'id';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insertForm(Map<String, dynamic> form) async {
    final db = await dbHelper.database;
    return await db.insert('forms', form);
  }

  Future<List<FormUser>> getAllForms() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    List<FormUser> tasks = toList(result);
    return tasks;
  }

  Future<int> updateForm(Map<String, dynamic> form) async {
    final db = await dbHelper.database;
    return await db.update(
      'forms',
      form,
      where: 'id = ?',
      whereArgs: [form['id']],
    );
  }

  Future<int> deleteForm(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'forms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  List<FormUser> toList(List<Map<String, dynamic>> mapaDeTarefas) {
    final List<FormUser> forms = [];
    for (Map<String, dynamic> linha in mapaDeTarefas) {
      final FormUser form = FormUser(linha[_id], linha[_name]);
      forms.add(form);
    }
    return forms;
  }
}

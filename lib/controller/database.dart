
import 'package:get/get.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;

import '../model/user_model.dart';

class DBHelper extends GetxController{


  @override
  void onInit() {
    super.onInit();
     DBHelper();

  }

  static Database? _db;
  Future<Database?> get db async {
    update();
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    update();
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'employee.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    update();
    await db
        .execute('CREATE TABLE employee (id INTEGER PRIMARY KEY, name TEXT, phone TEXT)');
  }

  Future<Employee> add(Employee employee) async {
    update();
    var dbClient = await db;
    employee.id = await dbClient!.insert('employee', employee.toMap());
    return employee;
  }

  Future<List<Employee>> getEmployee() async {
    update();
    var dbClient = await db;
    List<Map> maps = await dbClient!.query('employee', columns: ['id', 'name','phone']);
    List<Employee> employees = [];
    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        employees.add(Employee.fromMap(maps[i]));
      }
    }
    return employees;
  }

  Future<int> delete(int id) async {
    update();
    var dbClient = await db;
    return await dbClient!.delete(
      'employee',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> Update(Employee employee) async {
    update();
    var dbClient = await db;
    return await dbClient!.update(
      'employee',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future close() async {
    update();
    var dbClient = await db;
    dbClient!.close();
  }
}
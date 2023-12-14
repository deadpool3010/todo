import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  Database? database;

  void create(Database database) {
    database.execute('''
      CREATE TABLE Dhairya(
        ID INTEGER PRIMARY KEY,
        TITLE TEXT,
        COMPLETED INTEGER
      )
    ''');
  }

  Future<void> initdb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = join(directory.path, 'my.db');
    database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        create(db);
      },
    );
  }

  Future<List<Map<String, dynamic>>> read() async {
    if (database == null) await initdb();
    List<Map<String, dynamic>> result = [];
    try {
      var queryResult = await database?.query('Dhairya');
      result = queryResult ?? [];
    } catch (e) {
      print("Error reading data: $e");
    }
    return result;
  }

  Future<int?> insert(Map<String, dynamic> map) async {
    if (database == null) await initdb();
    return await database?.insert('Dhairya', map);
  }

  Future<int?> update(int id, Map<String, dynamic> data) async {
    if (database == null) await initdb();
    return await database
        ?.update('Dhairya', data, where: 'ID = ?', whereArgs: [id]);
  }

  Future<int?> delete(int id) async {
    if (database == null) await initdb();
    return await database?.delete('Dhairya', where: 'ID = ?', whereArgs: [id]);
  }
}

class Todo {
  int? id;
  String? title;
  bool? completed;

  Todo({
    this.id,
    this.title,
    this.completed,
  });

  factory Todo.fromMap(Map<String, dynamic> row) {
    return Todo(
      id: row['ID'],
      title: row['TITLE'],
      completed: row['COMPLETED'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'TITLE': title,
      'COMPLETED': completed == true ? 1 : 0,
    };
  }
}

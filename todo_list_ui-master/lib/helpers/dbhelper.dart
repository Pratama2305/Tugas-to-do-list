import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/models/note.dart';

class DbHelper {
  static late DbHelper _dbHelper;
  static late Database _database;

  DbHelper._createObject();

  factory DbHelper() {
    _dbHelper = DbHelper._createObject();
    return _dbHelper;
  }

  Future<Database> initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'contact.db';
    var contactDatabase = openDatabase(path, version: 1, onCreate: _createDb);
    return contactDatabase;
  }

  void _createDb(Database db, int version) async {
    await db.execute("""
      CREATE TABLE note (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        title TEXT, 
        description TEXT
      )
    """);
  }

  Future<Database> get database async {
    _database = await initDb();
    return _database;
  }

  Future<int> insert(Note object) async {
    Database db = await this.database;
    int count = await db.insert('note', object.toMap());
    return count;
  }

  Future<List<Map<String, dynamic>>> select() async {
    Database db = await this.database;
    var mapList = await db.query('note', orderBy: 'name');
    return mapList;
  }

  Future<int> update(Note object) async {
    Database db = await this.database;
    int count = await db.update('note', object.toMap(),
        where: 'id=?', whereArgs: [object.title]);
    return count;
  }

  Future<int> delete(int id) async {
    Database db = await this.database;
    int count = await db.delete('note', where: 'id=?', whereArgs: [id]);
    return count;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await select();
    int count = noteMapList.length;

    List<Note> noteList = [];
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMap(noteMapList[i]));
    }
    return noteList;
  }
}

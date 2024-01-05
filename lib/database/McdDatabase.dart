import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'McdNote.dart';

class McdDatabase {
  static McdDatabase mcdDatabase;
  static Database _database;
  String mcdTable = 'mcdTable';
  String colId = 'id';

  String coltaskSyskey = 'taskSyskey';

  String colmcdCheck = 'mcdCheck';

  McdDatabase._createInstance();
  factory McdDatabase() {
    if (mcdDatabase == null) {
      mcdDatabase = McdDatabase._createInstance();
    }
    return mcdDatabase;
  }
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializedDatabase();
    }
    return _database;
  }

  Future<Database> initializedDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'OrderDetail.db';

    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $mcdTable($colId INTEGER PRIMARY KEY,$coltaskSyskey TEXT, $colmcdCheck TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    var result = await db.query(mcdTable, orderBy: '$colId ASC');
    return result;
  }

  Future<int> insertNote(McdNote note) async {
    Database db = await this.database;
    var result = await db.insert(mcdTable, note.toMap());
    print('Insert Successfully');
    return result;
  }

  Future<int> updateNote(McdNote note) async {
    Database db = await this.database;
    var result = await db.update(mcdTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    print("You Update");
    return result;
  }

  Future<int> deleteAllNote() async {
    Database db = await this.database;
    var result = await db.rawDelete('DELETE FROM $mcdTable');

    print("Deleted");
    return result;
  }

  // Future<int> updateCheck(String newCheck, int syskey) async {
  //   Database db = await this.database;
  //   var result = await db.rawUpdate(
  //       "UPDATE $mcdTable SET $colmcdCheck = ? WHERE $colId = $syskey", [newCheck]);
  //   print(" Update");
  //   return result;
  // }
  Future<int> updateCheck(McdNote note) async {
    Database db = await this.database;
    var result = await db.update(mcdTable, note.toMap(),
        where: '$coltaskSyskey = ?', whereArgs: [note.taskSyskey]);
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $mcdTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<McdNote>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<McdNote> noteList = List<McdNote>();
    for (int i = 0; i < count; i++) {
      noteList.add(McdNote.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }

  Future<List> getAllNotes() async {
    var dbClient = _database;
    var result = await dbClient
        .query(mcdTable, columns: [colId, coltaskSyskey, colmcdCheck]);
    return result.toList();
  }
}

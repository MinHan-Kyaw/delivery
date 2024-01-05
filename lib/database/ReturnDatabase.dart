import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:delivery_2/database/ReturnNote.dart';

class ReturnDatabase {
  static ReturnDatabase orderDatabase;
  static Database _orderdatabase;
  String orderTable = 'orderTable';
  String colId = 'id';

  String colshopName = 'shopName';

  String colitemCode = 'itemCode';

  String colitemName = 'itemName';

  String colitemQty = 'itemQty';

  String colitemTolCount = 'itemTolCount';
  
  ReturnDatabase._createInstance();
  factory ReturnDatabase() {
    if (orderDatabase == null) {
      orderDatabase = ReturnDatabase
          ._createInstance();
    }
    return orderDatabase;
  }
  Future<Database> get database async {
    if (_orderdatabase == null) {
      _orderdatabase = await initializedDatabase();
    }
    return _orderdatabase;
  }

  Future<Database> initializedDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'ReturnStock.db';

    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $orderTable($colId INTEGER PRIMARY KEY,$colshopName TEXT, $colitemCode TEXT, $colitemName TEXT, $colitemQty TEXT,$colitemTolCount TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    var result = await db.query(orderTable, orderBy: '$colId ASC');
    return result;
  }

  Future<int> insertNote(ReturnNote note) async {
    Database db = await this.database;
    var result = await db.insert(orderTable, note.toMap());
    print('Insert Successfully');
    return result;
  }

  Future<int> updateNote(ReturnNote note) async {
    Database db = await this.database;
    var result = await db.update(orderTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    print("You Update");
    return result;
  }

  Future<int> deleteAllNote() async {
    Database db = await this.database;
    var result =
        await db.rawDelete('DELETE FROM $orderTable');

    print("Deleted");
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $orderTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<ReturnNote>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<ReturnNote> noteList = List<ReturnNote>();
    for (int i = 0; i < count; i++) {
      noteList.add(ReturnNote.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }

  Future<List> getAllNotes() async {
    var dbClient = _orderdatabase;
    var result = await dbClient.query(orderTable, columns: [
      colId,
      colshopName,
      colitemCode,
      colitemName,
      colitemQty,
      colitemTolCount
    ]);
    return result.toList();
  }
}

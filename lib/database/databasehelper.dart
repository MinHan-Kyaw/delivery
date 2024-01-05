import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:delivery_2/database/Note.dart';

class DbOrder {
  static DbOrder dbOrder;
  static Database _orderdatabase;
  String stockTable = 'stockTable';
  String colId = 'id';

  String colSyskey = 'syskey';

  String colCode = 'code';

  String colDesc = 'desc';

  String colImg = 'img';

  String colPackTypeCode = 'packTypeCode';

  String colPackSizeCode = 'packSizeCode';

  String colFloverCode = 'floverCode';

  String colBrandCode = 'brandCode';

  String colBrandOwnerCode = ' brandOwnerCode';

  String colBrandOwnerName = 'brandOwnerName';

  String colBrandOwnerSyskey = 'brandOwnerSyskey';

  String colVendorCode = 'vendorCode';
  String colCategoryCode = 'categoryCode';

  String colSubCategoryCode = 'subCategoryCode';

  String colWhCode = 'whCode';

  String colWhSyskey = 'whSyskey';

  String colDetails = 'details';

  DbOrder._createInstance();
  factory DbOrder() {
    if (dbOrder == null) {
      dbOrder = DbOrder._createInstance();
    }
    return dbOrder;
  }
  Future<Database> get database async {
    if (_orderdatabase == null) {
      _orderdatabase = await initializedDatabase();
    }
    return _orderdatabase;
  }

  Future<Database> initializedDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'Order.db';

    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $stockTable($colId INTEGER PRIMARY KEY,$colSyskey TEXT, $colCode TEXT,$colDesc TEXT, $colImg TEXT,'
        '$colPackTypeCode TEXT,$colPackSizeCode TEXT,$colFloverCode TEXT,$colBrandCode TEXT,$colBrandOwnerCode TEXT,$colBrandOwnerName TEXT,$colBrandOwnerSyskey TEXT,$colVendorCode TEXT,'
        '$colCategoryCode TEXT,$colSubCategoryCode TEXT,$colWhCode TEXT, $colWhSyskey TEXT,$colDetails TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    var result = await db.query(stockTable, orderBy: '$colId ASC');
    return result;
  }

  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(stockTable, note.toMap());
    print('Insert Successfully');
    return result;
  }

  Future<int> updateNote(Note note) async {
    Database db = await this.database;
    var result = await db.update(stockTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    print("You Update");
    return result;
  }

  Future<int> deleteAllNote() async {
    Database db = await this.database;
    var result = await db.rawDelete('DELETE FROM $stockTable');
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $stockTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }

  Future<List> getAllNotes() async {
    var dbClient = _orderdatabase;
    var result = await dbClient.query(stockTable, columns: [
      colId,
      colSyskey,
      colCode,
      colDesc,
      colImg,
      colPackTypeCode,
      colPackSizeCode,
      colFloverCode,
      colBrandCode,
      colBrandOwnerCode,
      colBrandOwnerName,
      colBrandOwnerSyskey,
      colVendorCode,
      colCategoryCode,
      colSubCategoryCode,
      colWhCode,
      colWhSyskey,
      colDetails
    ]);
    return result.toList();
  }
}

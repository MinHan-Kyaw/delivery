import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:delivery_2/database/shopByUserNote.dart';

class ShopsbyUser {
  static ShopsbyUser dbOrder;
  static Database _userdatabase;
  String shopByUserTable = 'shopbyuserTable';
  String colId = 'id';

  String colisSaleOrderLessRouteShop = 'isSaleOrderLessRouteShop';

  String colAddress = 'address';

  String colShopnamemm = 'shopnamemm';

  String colShopsyskey = 'shopsyskey';

  String colLong = 'long';

  String colPhoneno = 'phoneno';

  String colZonecode = 'zonecode';

  String colShopcode = 'shopcode';

  String colShopname = 'shopname';

  String colTeamcode = 'teamcode';

  String colLocation = 'location';

  String colcomment = 'comment';
  String colUsercode = 'usercode';

  String colUser = 'user';

  String colLat = 'lat';

  String colEmail = 'email';

  String colUsername = 'username';

  String colType = 'type';

  ShopsbyUser._createInstance();
  factory ShopsbyUser() {
    if (dbOrder == null) {
      dbOrder = ShopsbyUser
          ._createInstance();
    }
    return dbOrder;
  }
  Future<Database> get database async {
    if (_userdatabase == null) {
      _userdatabase = await initializedDatabase();
    }
    return _userdatabase;
  }

  Future<Database> initializedDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'shopbyUser.db';

    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $shopByUserTable($colId INTEGER PRIMARY KEY,$colisSaleOrderLessRouteShop TEXT,$colAddress TEXT,$colShopnamemm TEXT,$colShopsyskey TEXT,'
        '$colLong TEXT,$colPhoneno TEXT,$colZonecode TEXT,$colShopcode TEXT,$colShopname TEXT,$colTeamcode TEXT,$colLocation TEXT, $colcomment TEXT,'
        '$colUsercode TEXT,$colUser TEXT,$colLat TEXT, $colEmail TEXT,$colUsername TEXT ,$colType TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    var result = await db.query(shopByUserTable, orderBy: '$colId ASC');
    return result;
  }

  Future<int> insertNote(ShopByUserNote note) async {
    Database db = await this.database;
    var result = await db.insert(shopByUserTable, note.toMap());
    print('Insert Successfully');
    return result;
  }

  Future<int> updateNote(ShopByUserNote note) async {
    Database db = await this.database;
    var result = await db.update(shopByUserTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    print(" Update");
    return result;
  }

  Future<int> updateType(String newType, int id) async {
    Database db = await this.database;
    var result = await db.rawUpdate("UPDATE $shopByUserTable SET $colType = $newType WHERE $colId = ?", [id]);
    print(" Update");
    return result;
  }

  Future<int> deleteAllNote() async {

    Database db = await this.database;
    var result =
        await db.rawDelete('DELETE FROM $shopByUserTable');
    return result;
  }

  Future getShopSyskey(String shopName) async {
    final db = await database;
    return await db.query(
      shopByUserTable, 
      where: "$colShopname = ?",
      whereArgs: [shopName],
      limit: 1
    );
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $shopByUserTable');
    int result = Sqflite.firstIntValue(x);

    return result;
  }

  Future<List<ShopByUserNote>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<ShopByUserNote> noteList = List<ShopByUserNote>();
    for (int i = 0; i < count; i++) {
      noteList.add(ShopByUserNote.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }

  Future<List> getAllNotes() async {
    var dbClient = _userdatabase;
    var result = await dbClient.query(shopByUserTable, columns: [
      colId,
      colisSaleOrderLessRouteShop,
      colAddress,
      colShopnamemm,
      colShopsyskey,
      colLong,
      colPhoneno,
      colZonecode,
      colShopcode,
      colShopname,
      colTeamcode,
      colLocation,
      colcomment,
      colUsercode,
      colUser,
      colLat,
      colEmail,
      colUsername,
      colType
    ]);
    return result.toList();
  }
}

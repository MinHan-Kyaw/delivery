import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:delivery_2/database/shopByTeamNote.dart';

class ShopsbyTeam {
  static ShopsbyTeam dbTeam;
  static Database _teamdatabase;
  String shopByTeamTable = 'shopbyteamTable';
  String colId = 'id';

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
  String colUsercode = 'usercode';

  String colUser = 'user';

  String colLat = 'lat';

  String colEmail = 'email';

  String colUsername = 'username';

  ShopsbyTeam._createInstance();
  factory ShopsbyTeam() {
    if (dbTeam == null) {
      dbTeam = ShopsbyTeam
          ._createInstance();
    }
    return dbTeam;
  }
  Future<Database> get database async {
    if (_teamdatabase == null) {
      _teamdatabase = await initializedDatabase();
    }
    return _teamdatabase;
  }

  Future<Database> initializedDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'shopbyTeam.db';

    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $shopByTeamTable($colId INTEGER PRIMARY KEY,$colAddress TEXT, $colShopnamemm TEXT, $colShopsyskey TEXT,'
        '$colLong TEXT,$colPhoneno TEXT,$colZonecode TEXT,$colShopcode TEXT, $colShopname TEXT ,$colTeamcode TEXT,$colLocation TEXT,'
        '$colUsercode TEXT,$colUser TEXT,$colLat TEXT, $colEmail TEXT,$colUsername TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    var result = await db.query(shopByTeamTable, orderBy: '$colId ASC');
    return result;
  }

  Future<int> insertNote(ShopByTeamNote note) async {
    Database db = await this.database;
    var result = await db.insert(shopByTeamTable, note.toMap());
    print('Insert Successfully');
    return result;
  }

  Future<int> updateNote(ShopByTeamNote note) async {
    Database db = await this.database;
    var result = await db.update(shopByTeamTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    print(" Update");
    return result;
  }

  Future<int> deleteAllNote() async {
    Database db = await this.database;
    var result =
        await db.rawDelete('DELETE FROM $shopByTeamTable');
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $shopByTeamTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<ShopByTeamNote>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<ShopByTeamNote> noteList = List<ShopByTeamNote>();
    for (int i = 0; i < count; i++) {
      noteList.add(ShopByTeamNote.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }

  Future<List> getAllNotes() async {
    var dbClient = _teamdatabase;
    var result = await dbClient.query(shopByTeamTable, columns: [
      colId,
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
      colUsercode,
      colUser,
      colLat,
      colEmail,
      colUsername
    ]);
    return result.toList();
  }
}

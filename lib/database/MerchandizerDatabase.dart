import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:delivery_2/database/MerchandizerNote.dart';

class MerchandizerDatabase {
  static MerchandizerDatabase merchandizerDatabase;
  static Database _database;
  String merchandizerTable = 'merchandizingTable';
  String colId = 'id';

  String coluserSyskey = 'userSyskey';

  String colimgPath = 'imgPath';

  String colpathForServer = 'pathForServer';

  String coltaskKey = 'taskKey';

  String colshopSyskey = 'shopSyskey';

  String colcampaignId = 'campaignId';

  String colbrandOwnerId = 'brandOwnerId';

  String colremark = 'remark';

  String coltaskToDo = 'taskToDo';

  String colcompleteCheck = 'completeCheck';

  String colshopComplete = 'shopComplete';

  MerchandizerDatabase._createInstance();
  factory MerchandizerDatabase() {
    if (merchandizerDatabase == null) {
      merchandizerDatabase = MerchandizerDatabase._createInstance();
    }
    return merchandizerDatabase;
  }
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializedDatabase();
    }
    return _database;
  }

  Future<Database> initializedDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'merchandizer.db';

    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $merchandizerTable($colId INTEGER PRIMARY KEY, $coluserSyskey TEXT,$colimgPath TEXT, $colpathForServer TEXT,$coltaskKey TEXT, $colshopSyskey TEXT, $colcampaignId TEXT, $colbrandOwnerId TEXT, $colremark TEXT, $coltaskToDo TEXT,$colcompleteCheck TEXT, $colshopComplete TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    var result = await db.query(merchandizerTable, orderBy: '$colId ASC');
    return result;
  }

  Future<int> insertNote(MerchandizerNote note) async {
    Database db = await this.database;
    var result = await db.insert(merchandizerTable, note.toMap());
    print('Insert Successfully');
    return result;
  }

  // Future<int> updateNote(MerchandizerNote note) async {
  //   Database db = await this.database;
  //   var result = await db.update(merchandizerTable, note.toMap(),
  //       where: '$coltaskKey = ? AND $colshopSyskey = ?',
  //       whereArgs: [note.taskKey, note.shopSyskey]);
  //   print("Updated Successfully to McdDatabase");
  //   print('this is your resut $result');
  //   // print(result);

  //   return result;
  // }
  Future<int> updateNote(MerchandizerNote note) async {
    Database db = await this.database;
    
    var result = await db.update(merchandizerTable, note.toMap(),
        where: '$coltaskKey = ? AND $colshopSyskey = ?', whereArgs: [note.taskKey, note.shopSyskey]);
    print(" Update");
    print(note.taskKey);
    print('this is your result $result');
    return result;
  }

  Future<int> updateComplete(String shopKey, String complete) async {
    Database db = await this.database;
    var result = await db.rawUpdate(
        "UPDATE $merchandizerTable SET $colcompleteCheck = 'McdCompleted' WHERE $colshopSyskey = $shopKey");
    print('this shop key update');
    print('this is your result $result');
    return result;
  }

  Future<int> updateRemark(String shopKey, String imgPath, String remark) async {
    Database db = await this.database;
    var result = await db.rawUpdate(
        "UPDATE $merchandizerTable SET $colremark = '$remark' WHERE $colimgPath = $imgPath");
    print('this shop key update');
    print('this is your result $result');
    return result;
  }

  Future<int> updateShopComplete(String shopKey) async {
    Database db = await this.database;
    var result = await db.rawUpdate(
        "UPDATE $merchandizerTable SET $colshopComplete = 'ShopCompleted' WHERE $colshopSyskey = $shopKey");
    print('this shop key update');
    print('this is your result $result');
    return result;
  }

  Future<int> deleteAllNote() async {
    Database db = await this.database;
    var result = await db.rawDelete('DELETE FROM $merchandizerTable');

    print("Deleted");
    return result;
  }

  Future<int> deleteCompleteRow(String shopSyskey) async {
    Database db = await this.database;
    var result = await db.rawDelete(
        'DELETE FROM $merchandizerTable WHERE $colshopSyskey = $shopSyskey');

    print("Deleted");
    return result;
  }

  Future<int> getRow(String shopSyskey) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        'SELECT * FROM $merchandizerTable WHERE $colshopSyskey = $shopSyskey');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> getTastRow(String shopSyskey, String taskKey) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        'SELECT * FROM $merchandizerTable WHERE $colshopSyskey = $shopSyskey AND $coltaskKey = $taskKey');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $merchandizerTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<MerchandizerNote>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<MerchandizerNote> noteList = List<MerchandizerNote>();
    for (int i = 0; i < count; i++) {
      noteList.add(MerchandizerNote.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }

  Future<List> getAllNotes() async {
    var dbClient = _database;
    var result = await dbClient
        .query(merchandizerTable, columns: [colId, coluserSyskey, colimgPath, colpathForServer, coltaskKey, colshopSyskey, colcampaignId, colbrandOwnerId, colremark, coltaskToDo, colcompleteCheck, colshopComplete]);
    return result.toList();
  }
}

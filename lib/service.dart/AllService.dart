import 'dart:convert';
import 'dart:core';
import 'package:delivery_2/Widgets/MultiGiftDialog.dart';
import 'package:delivery_2/database/McdDatabase.dart';
import 'package:delivery_2/database/McdNote.dart';
import 'package:delivery_2/database/MerchandizerDatabase.dart';
import 'package:delivery_2/database/MerchandizerNote.dart';
import 'package:delivery_2/database/Note.dart';
import 'package:delivery_2/database/databasehelper.dart';
import 'package:delivery_2/database/shopByTeamDatabase.dart';
import 'package:delivery_2/database/shopByTeamNote.dart';
import 'package:delivery_2/database/shopByUserDatabase.dart';
import 'package:delivery_2/database/shopByUserNote.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';

DbOrder helper = DbOrder();
ShopsbyUser shopbyUser = ShopsbyUser();
ShopsbyTeam shopbyTeam = ShopsbyTeam();
DbOrder dbOrder = DbOrder();
List<Note> noteList;
String orgId;
String orgId1;
List merchandiserList = [];
String brandName;
String task;
List tasktoDo = [];
String taskId;
String brandOwnerCode;
String campaignsyskey;
List stockData = [];
String orderDetailSts;
String inVoiceSts;
String campaignId;
String brandOwnerId;
String merT1;
String merT2;
String merT3;
String merchandiserSts;
String saveImageSts;
String orderdetailSyskey;
String shopCode;
String getdata;
String merchandisingSts;
List imageFilePath = [];
String sysKey;
List orderDetailData = [];
var userSysKey;
String transId;
String brandOwnerSysKey;
String brandOwnerName1;
String orderSyskey;
String cashAmount;
String discountAmount;
String taxPercent;
String taxSyskey;
String taxAmount;
List brandOwnerName = [];
List returnStockData = [];
String userID;
String userName;
String brandOwnerCode1;
List stockByBrandDel = [];
List stockDataOrder = [];
List stockReturnData = [];
List stockAllList = [];
List stockAllList1 = [];
List taskList = [];
String merchandizingSts;
String orderdetailSts;
String invoiceSts;
String invoiceCompleteSts;
List getinvoiceOrderlist = [];
List getdeliverylist = [];
List stockImage = [];
List getDelAmtSummary = [];
List voidList = [];
List voidListData = [];
String deliveryDate;
String deliverySyskey;
List merchandizingImage = [];
String date;
String shopCheck;
double getshopallBytes = 0.0;
double getstockimgBytes = 0.0;
double getorderstockBytes = 0.0;
double getreturnstockBytes = 0.0;
var getrecommendedlist;
List recommendedOrderList = [];
List recommendedReturnList = [];
List discountStockList = [];
var discountPercentList;
List discountDataList = [];
List disCategoryList = [];
List newStockList = [];
List promoItemDetailList = [];
var getInvDisCalculationList;
List invDisDownloadList = [];
List accountGetBalanceList = [];
double cashReceivedAmt = 0.0;
String dicountExpiredDate = "";
List getPriceZoneDownloadList = [];

// id
// 09988424735
// 09989917746
// 09695211764

// ------- SP GO Live
// String domain = 'http://54.255.17.88:8084/madbrepository/';
// ------- Pepsi Go Live
// String domain = 'http://18.136.44.90:8084/madbrepository/';
// ------- CU Testing
String domain = 'http://52.253.88.71:8084/madbrepository/';
// ------- QC Testing
// String domain = 'http://52.255.142.115:8084/madbrepository/'; // 09695211764  111 || 09750361796 123 || 959691456576

// String domain = 'http://52.255.142.115:8084/madbrepositorydev/';

// MultiGift Testing Link
// String domain = 'http://52.253.88.71:8084/madbrepositorydev/'; // 959783141456

Future checkUrl() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  if (preferences.getString('URL') != null) {
    domain = preferences.getString('URL').toString();
  } else {
    domain = 'http://52.253.88.71:8084/madbrepository/';
  }
}

void datetime() {
  DateTime dateTime = DateTime.now();
  String year = dateTime.toString().substring(0, 4);
  String month = dateTime.toString().substring(5, 7);
  String day = dateTime.toString().substring(8, 10);
  date = year + month + day;
}

Future getStockImg() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  var check;

  stockImage = [];

  final url = '$domain' + 'stock/getstockall';
  var param = jsonEncode({
    "code": "",
    "desc": "",
    "vendorSyskey": "",
    "brandSyskey": "",
    "categorySyskey": "",
    "packTypeSyskey": "0",
    "packSizeSyskey": "0",
    "flavorSyskey": "0",
    "barcode": [""]
  });

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": '${preferences.getString("OrgId")}',
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      getstockimgBytes =
          (response.bodyBytes.length / response.contentLength) * 100;
      var result = json.decode(response.body);
      // print(result);
      if (result['list'].length == 0) {
        preferences.setString("StockImageList", null);
        check = "success";
        getstockimgBytes = 100.0;
      } else {
        for (var i = 0; i < result['list'].length; i++) {
          // List approveType = result['list'][i]["details"].where((element) => element["uomType"].toString() == "Approve").toList();
          List confirmType = result['list'][i]["details"].where((element) => element["uomType"].toString() == "Confirm").toList();

          stockImage.add({
            "stockCode": result['list'][i]["code"],
            "stockName": result['list'][i]["desc"],
            "image": result['list'][i]["img"],
            "stockPrice": confirmType[0]["price"],
            "returnStockPrice": confirmType[0]["price"]
          });

          if (i == result['list'].length - 1) {
            preferences.setString("StockImageList", json.encode(stockImage));
            check = "success";
          }
        }
      }
      
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }

  return check;
}

Future getOrderStock() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  var check;

  stockAllList = [];

  final url = '$domain' + 'stock/getstockall';
  var param = jsonEncode({
    "code": "",
    "desc": "",
    "vendorSyskey": "",
    "brandSyskey": "",
    "categorySyskey": "",
    "packTypeSyskey": "0",
    "packSizeSyskey": "0",
    "flavorSyskey": "0",
    "barcode": [""]
  });
  print("test Param");
  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": '${preferences.getString("OrgId")}',
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
      // print(response);
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");

      getorderstockBytes = (response.bodyBytes.length / response.contentLength) * 100;
      var result = json.decode(response.body);
      if (result['list'].length == 0) {
        preferences.setString("AddOrder", null);
        check = "success";
        getorderstockBytes = 100.0;
      } else {
        for (var i = 0; i < result['list'].length; i++) {
        List details = [];

        stockAllList1 = [];

        if (result['list'][i]['details'].length == 0) {
          preferences.setString("AddOrder", null);
          check = "success";
        }

        for (var a = 0; a < result['list'][i]['details'].length; a++) {
          details.add({
            "u31Syskey": result['list'][i]['details'][a]["u31Syskey"],
            "uomSyskey": result['list'][i]['details'][a]["uomSyskey"],
            "barcode": result['list'][i]['details'][a]["barcode"],
            "price": result['list'][i]['details'][a]["price"],
            "uomType": result['list'][i]['details'][a]["uomType"],
            "priceType": result['list'][i]['details'][a]["priceType"],
            "ratio": result['list'][i]['details'][a]["ratio"],
          });

          if (a == result['list'][i]['details'].length - 1) {
            stockAllList.add({
              "syskey": result['list'][i]['syskey'],
              "code": result['list'][i]['code'],
              "desc": result['list'][i]['desc'],
              "img": result['list'][i]['img'],
              "packSizeDescription": result['list'][i]['packSizeDescription'],
              "packTypeCode": result['list'][i]['packTypeCode'],
              "packSizeCode": result['list'][i]['packSizeCode'],
              "floverCode": result['list'][i]['floverCode'],
              "brandCode": result['list'][i]['brandCode'],
              "brandOwnerCode": result['list'][i]['brandOwnerCode'],
              "brandOwnerName": result['list'][i]['brandOwnerName'],
              "brandOwnerSyskey": result['list'][i]['brandOwnerSyskey'],
              "vendorCode": result['list'][i]['vendorCode'],
              "categoryCode": result['list'][i]['categoryCode'],
              "subCategoryCode": result['list'][i]['subCategoryCode'],
              "categoryCodeDesc": result['list'][i]['categoryCodeDesc'],
              "subCategoryCodeDesc": result['list'][i]['subCategoryCodeDesc'],
              "whCode": result['list'][i]['whCode'],
              "whSyskey": result['list'][i]['whSyskey'],
              // "details": details.where((element) => element["uomType"] == "Approve").toList()
              "details": details.where((element) => element["uomType"] == "Confirm").toList()
            });

            if (i == result['list'].length - 1) {
              preferences.setString("AddOrder", json.encode(stockAllList));
              preferences.setString("AddOrderOriginal", json.encode(stockAllList));
              check = "success";
            }
          }
        }
      }
      }
      
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }

  return check;
}

Future getReturnStocks() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  var check;

  stockAllList1 = [];

  final url = '$domain' + 'stock/getstockall';
  var param = jsonEncode({
    "code": "",
    "desc": "",
    "vendorSyskey": "",
    "brandSyskey": "",
    "categorySyskey": "",
    "packTypeSyskey": "0",
    "packSizeSyskey": "0",
    "flavorSyskey": "0",
    "barcode": [""]
  });

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": '${preferences.getString("OrgId")}',
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");

      getreturnstockBytes =
          (response.bodyBytes.length / response.contentLength) * 100;
      var result = json.decode(response.body);
      if (result['list'].length == 0) {
        preferences.setString("AddReturn", null);
        check = "success";
        getreturnstockBytes = 100.0;
      } else {
        for (var i = 0; i < result['list'].length; i++) {
        List details = [];

        stockAllList = [];

        if (result['list'][i]['details'].length == 0) {
          preferences.setString("AddReturn", null);
          check = "success";
        }

        for (var a = 0; a < result['list'][i]['details'].length; a++) {
          details.add({
            "u31Syskey": result['list'][i]['details'][a]["u31Syskey"],
            "uomSyskey": result['list'][i]['details'][a]["uomSyskey"],
            "barcode": result['list'][i]['details'][a]["barcode"],
            "price": result['list'][i]['details'][a]["price"],
            "uomType": result['list'][i]['details'][a]["uomType"],
            "priceType": result['list'][i]['details'][a]["priceType"],
            "ratio": result['list'][i]['details'][a]["ratio"],
          });

          if (a == result['list'][i]['details'].length - 1) {
            stockAllList1.add({
              "syskey": result['list'][i]['syskey'],
              "code": result['list'][i]['code'],
              "desc": result['list'][i]['desc'],
              "img": result['list'][i]['img'],
              "packTypeCode": result['list'][i]['packTypeCode'],
              "packSizeDescription": result['list'][i]['packSizeDescription'],
              "packSizeCode": result['list'][i]['packSizeCode'],
              "floverCode": result['list'][i]['floverCode'],
              "brandCode": result['list'][i]['brandCode'],
              "brandOwnerCode": result['list'][i]['brandOwnerCode'],
              "brandOwnerName": result['list'][i]['brandOwnerName'],
              "brandOwnerSyskey": result['list'][i]['brandOwnerSyskey'],
              "vendorCode": result['list'][i]['vendorCode'],
              "categoryCode": result['list'][i]['categoryCode'],
              "subCategoryCode": result['list'][i]['subCategoryCode'],
              "categoryCodeDesc": result['list'][i]['categoryCodeDesc'],
              "subCategoryCodeDesc": result['list'][i]['subCategoryCodeDesc'],
              "whCode": result['list'][i]['whCode'],
              "whSyskey": result['list'][i]['whSyskey'],
              "details": details
                  .where((element) => element["uomType"] == "Confirm")
                  .toList()
            });

            if (i == result['list'].length - 1) {
              preferences.setString("AddReturn", json.encode(stockAllList1));
              check = "success";
            }
          }
        }
      }
      }
      
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }

  return check;
}

Future getAllShop() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  DateTime dateTime = DateTime.now();
  String year = dateTime.toString().substring(0, 4);
  String month = dateTime.toString().substring(5, 7);
  String day = dateTime.toString().substring(8, 10);
  String date = year + month + day;

  print(preferences.getString('spsyskey'));
  print(preferences.getString("OrgId"));
  var check;

  shopCheck = null;

  final url = '$domain' + 'shop/getshopall';
  var param = jsonEncode({
    "spsyskey": "${preferences.getString('spsyskey')}",
    "teamsyskey": "",
    "usertype": "delivery",
    "date": "$date"
    // "date": "20201217"
  });
  print(url);
  print(param);
  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": '${preferences.getString("OrgId")}',
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      getshopallBytes = (response.bodyBytes.length / response.contentLength) * 100;
      var result = json.decode(response.body);
      Future<int> sbuDataLength = shopbyUser.getCount();

      if (result['data']['shopsByUser'].length == 0) {
        check = "success";
      }

      sbuDataLength.then((value) async {
        if (value == 0) {
          print(result['status']);
          print(result['data']);
          // print(result);
          // if(result['data']["shopsByUser"].toString() == "[]") {
          //   check = "success";
          // }
          for (var i = 0; i < result['data']['shopsByUser'].length; i++) {
            _shopbyUsersave(ShopByUserNote(
                result['data']['shopsByUser'][i]['isSaleOrderLessRouteShop']
                    .toString(),
                result['data']['shopsByUser'][i]['address'].toString(),
                result['data']['shopsByUser'][i]['shopnamemm'].toString(),
                result['data']['shopsByUser'][i]['shopsyskey'].toString(),
                result['data']['shopsByUser'][i]['long'].toString(),
                result['data']['shopsByUser'][i]['phoneno'].toString(),
                result['data']['shopsByUser'][i]['zonecode'].toString(),
                result['data']['shopsByUser'][i]['shopcode'].toString(),
                result['data']['shopsByUser'][i]['shopname'].toString(),
                result['data']['shopsByUser'][i]['teamcode'].toString(),
                result['data']['shopsByUser'][i]['location'].toString(),
                result['data']['shopsByUser'][i]['comment'].toString(),
                result['data']['shopsByUser'][i]['usercode'].toString(),
                result['data']['shopsByUser'][i]['user'].toString(),
                result['data']['shopsByUser'][i]['lat'].toString(),
                result['data']['shopsByUser'][i]['email'].toString(),
                result['data']['shopsByUser'][i]['username'].toString(),
                result['data']['shopsByUser'][i]["status"]["currentType"]));

            if (i == result['data']['shopsByUser'].length - 1) {
              check = "success";
            }
          }
        } else {
          final Future<Database> db = shopbyUser.initializedDatabase();
          await db.then((database) {
            Future<List<ShopByUserNote>> noteListFuture =
                shopbyUser.getNoteList();
            noteListFuture.then((note) {
              for (var a = 0; a < note.length; a++) {
                for (var i = 0; i < result['data']['shopsByUser'].length; i++) {
                  _shopbyUsersave(ShopByUserNote(
                      result['data']['shopsByUser']
                          .where((val) => result['data']['shopsByUser'][i]['isSaleOrderLessRouteShop'] != note[a].address)[i]
                              ['isSaleOrderLessRouteShop']
                          .toString(),
                      result['data']['shopsByUser']
                          .where((val) => result['data']['shopsByUser'][i]['address'] != note[a].address)[i]
                              ['address']
                          .toString(),
                      result['data']['shopsByUser']
                          .where((val) => result['data']['shopsByUser'][i]['shopnamemm'] != note[a].shopnamemm)[i]
                              ['shopnamemm']
                          .toString(),
                      result['data']['shopsByUser']
                          .where((val) => result['data']['shopsByUser'][i]['shopsyskey'] != note[a].shopsyskey)[i]
                              ['shopsyskey']
                          .toString(),
                      result['data']['shopsByUser']
                          .where((val) => result['data']['shopsByUser'][i]['long'] != note[a].long)[i]
                              ['long']
                          .toString(),
                      result['data']['shopsByUser']
                          .where((val) => result['data']['shopsByUser'][i]['phoneno'] != note[a].phoneno)[i]
                              ['phoneno']
                          .toString(),
                      result['data']['shopsByUser']
                          .where((val) => result['data']['shopsByUser'][i]['zonecode'] != note[a].zonecode)[i]
                              ['zonecode']
                          .toString(),
                      result['data']['shopsByUser'].where((val) => result['data']['shopsByUser'][i]['shopcode'] != note[a].shopcode)[i]['shopcode'].toString(),
                      result['data']['shopsByUser'].where((val) => result['data']['shopsByUser'][i]['shopname'] != note[a].shopname)['shopname'].toString(),
                      result['data']['shopsByUser'].where((val) => result['data']['shopsByUser'][i]['teamcode'] != note[a].teamcode)[i]['teamcode'].toString(),
                      result['data']['shopsByUser'].where((val) => result['data']['shopsByUser'][i]['location'] != note[a].location)[i]['location'].toString(),
                      result['data']['shopsByUser'].where((val) => result['data']['shopsByUser'][i]['comment'] != note[a].comment)[i]['comment'].toString(),
                      result['data']['shopsByUser'].where((val) => result['data']['shopsByUser'][i]['usercode'] != note[a].usercode)[i]['usercode'].toString(),
                      result['data']['shopsByUser'].where((val) => result['data']['shopsByUser'][i]['user'] != note[a].user)[i]['user'].toString(),
                      result['data']['shopsByUser'].where((val) => result['data']['shopsByUser'][i]['lat'] != note[a].lat)[i]['lat'].toString(),
                      result['data']['shopsByUser'].where((val) => result['data']['shopsByUser'][i]['email'] != note[a].email)[i]['email'].toString(),
                      result['data']['shopsByUser'].where((val) => result['data']['shopsByUser'][i]['username'] != note[a].username)[i]['username'].toString(),
                      ""));
                }

                if (a == note.length - 1) {
                  check = "success";
                }
              }
            });
          });
        }
      });

      Future<int> sbtDataLength = shopbyTeam.getCount();

      sbtDataLength.then((value) async {
        if (value == 0) {
          for (var i = 0; i < result['data']['shopsByTeam'].length; i++) {
            _shopbyTeamsave(ShopByTeamNote(
                result['data']['shopsByTeam'][i]['address'].toString(),
                result['data']['shopsByTeam'][i]['shopnamemm'].toString(),
                result['data']['shopsByTeam'][i]['shopsyskey'].toString(),
                result['data']['shopsByTeam'][i]['long'].toString(),
                result['data']['shopsByTeam'][i]['phoneno'].toString(),
                result['data']['shopsByTeam'][i]['zonecode'].toString(),
                result['data']['shopsByTeam'][i]['shopcode'].toString(),
                result['data']['shopsByTeam'][i]['shopname'].toString(),
                result['data']['shopsByTeam'][i]['teamcode'].toString(),
                result['data']['shopsByTeam'][i]['location'].toString(),
                result['data']['shopsByTeam'][i]['usercode'].toString(),
                result['data']['shopsByTeam'][i]['user'].toString(),
                result['data']['shopsByTeam'][i]['lat'].toString(),
                result['data']['shopsByTeam'][i]['email'].toString(),
                result['data']['shopsByTeam'][i]['username'].toString()));

            if (i == result['data']['shopsByTeam'].length - 1) {
              check = "success";
            }
          }
        } else {
          final Future<Database> db = shopbyUser.initializedDatabase();
          await db.then((database) {
            Future<List<ShopByUserNote>> noteListFuture =
                shopbyUser.getNoteList();
            noteListFuture.then((note) {
              for (var a = 0; a < note.length; a++) {
                for (var i = 0; i < result['data']['shopsByTeam'].length; i++) {
                  _shopbyUsersave(ShopByUserNote(
                      result['data']['shopsByTeam']
                          .where((val) => result['data']['shopsByTeam'][i]['isSaleOrderLessRouteShop'] != note[a].address)[i]
                              ['isSaleOrderLessRouteShop']
                          .toString(),
                      result['data']['shopsByTeam']
                          .where((val) => result['data']['shopsByTeam'][i]['address'] != note[a].address)[i]
                              ['address']
                          .toString(),
                      result['data']['shopsByTeam']
                          .where((val) => result['data']['shopsByTeam'][i]['shopnamemm'] != note[a].shopnamemm)[i]
                              ['shopnamemm']
                          .toString(),
                      result['data']['shopsByTeam']
                          .where((val) => result['data']['shopsByTeam'][i]['shopsyskey'] != note[a].shopsyskey)[i]
                              ['shopsyskey']
                          .toString(),
                      result['data']['shopsByTeam']
                          .where((val) => result['data']['shopsByTeam'][i]['long'] != note[a].long)[i]
                              ['long']
                          .toString(),
                      result['data']['shopsByTeam']
                          .where((val) => result['data']['shopsByTeam'][i]['phoneno'] != note[a].phoneno)[i]
                              ['phoneno']
                          .toString(),
                      result['data']['shopsByTeam']
                          .where((val) => result['data']['shopsByTeam'][i]['zonecode'] != note[a].zonecode)[i]
                              ['zonecode']
                          .toString(),
                      result['data']['shopsByTeam'].where((val) => result['data']['shopsByTeam'][i]['shopcode'] != note[a].shopcode)[i]['shopcode'].toString(),
                      result['data']['shopsByTeam'].where((val) => result['data']['shopsByTeam'][i]['shopname'] != note[a].shopname)[i]['shopname'].toString(),
                      result['data']['shopsByTeam'].where((val) => result['data']['shopsByTeam'][i]['teamcode'] != note[a].teamcode)[i]['teamcode'].toString(),
                      result['data']['shopsByTeam'].where((val) => result['data']['shopsByTeam'][i]['location'] != note[a].location)[i]['location'].toString(),
                      result['data']['shopsByTeam'].where((val) => result['data']['shopsByTeam'][i]['comment'] != note[a].comment)[i]['comment'].toString(),
                      result['data']['shopsByTeam'].where((val) => result['data']['shopsByTeam'][i]['usercode'] != note[a].usercode)[i]['usercode'].toString(),
                      result['data']['shopsByTeam'].where((val) => result['data']['shopsByTeam'][i]['user'] != note[a].user)[i]['user'].toString(),
                      result['data']['shopsByTeam'].where((val) => result['data']['shopsByTeam'][i]['lat'] != note[a].lat)[i]['lat'].toString(),
                      result['data']['shopsByTeam'].where((val) => result['data']['shopsByTeam'][i]['email'] != note[a].email)[i]['email'].toString(),
                      result['data']['shopsByTeam'].where((val) => result['data']['shopsByTeam'][i]['username'] != note[a].username)[i]['username'].toString(),
                      ""));
                }

                if (a == note.length - 1) {
                  check = "success";
                }
              }
            });
          });
        }
      });
      check = 'success';
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }

  return check;
}

void _shopbyUsersave(note) async {
  if (note.id != null) {
    await shopbyUser.updateNote(note);
    print('update');
  } else {
    print('insert');
    await shopbyUser.insertNote(note).then((value) {
      shopCheck = "success";
    });
  }
  updateList();
}

void _shopbyTeamsave(note) async {
  if (note.id != null) {
    await shopbyTeam.updateNote(note);
    print('update');
  } else {
    print('insert');
    await shopbyTeam.insertNote(note).then((value) {
      shopCheck = "success";
    });
  }
  updateList();
}

void updateList() async {
  final Future<Database> db = helper.initializedDatabase();
  await db.then((database) {
    Future<List<Note>> noteListFuture = helper.getNoteList();
    noteListFuture.then((note) {
      noteList = note;
    });
  });
}

Future getOrgId(phNo, password) async {
  var check;
  final url = '$domain' + 'main/logindebug/mit';
  var param = jsonEncode({"userId": phNo, "password": "$password"});
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'fail';
      });
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      if (extdata['orgId'] != "" && extdata['orgId'] != null) {
        if (extdata['userId'].substring(3) != preferences.getString("userId")) {
          shopbyUser.deleteAllNote();
          shopbyTeam.deleteAllNote();
          dbOrder.deleteAllNote();
        }
        print(extdata);
        orgId1 = extdata['orgId'];
        if (extdata['orgId'] != '' &&
            extdata['userId'] != '' &&
            extdata['userType'] == "delivery") {
          login(extdata['orgId'], extdata['userId'], extdata['userName'],
              extdata['merchandizer'], extdata['userType'], extdata['syskey']);
          check = 'success';
        } else {
          check = 'fail';
        }
      } else {
        check = 'fail';
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }

  print("check ---- " + check);
  return check;
}

Future<Null> login(
    orgId, userId, userName, merchandizer, userType, syskey) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString('OrgId', orgId);
  preferences.setString('userId', userId.substring(3));
  preferences.setString('userName', userName);
  preferences.setString('merchandizer', merchandizer);
  preferences.setString('userType', userType);
  preferences.setString('spsyskey', syskey);
}

Future signUp(phno, userName, password) async {
  var check;
  final url = "$domain" + "main/signup/mit";
  var param = jsonEncode(
      {"userId": "$phno", "userName": "$userName", "password": "$password"});

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  print(json.decode(response.body));
  if (response != null) {
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      if (extdata["message"].toString() == "SUCCESS") {
        check = 'success';
      } else {
        check = extdata["message"];
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future changePassword(oldpassword, newpassword) async {
  var check;
  var phNo;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  phNo = preferences.getString('userId');
  final url = '$domain' + 'main/reset/mit';
  var param = jsonEncode(
      {"id": phNo, "oldpass": oldpassword, "newpass": "$newpassword"});
  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'fail';
      });
  if (response != null) {
    if (response.statusCode == 200) {
      var extdata = json.decode(response.body);
      if (extdata['status'] != "FAIL" && extdata['status'] != "") {
        preferences.setString("OrgId", "");
        preferences.setString("userId", "");
        preferences.setString("userName", "");
        preferences.setString("merchandizer", "");
        preferences.setString("latitude", "");
        preferences.setString("longitude", "");
        preferences.setString("date", "");
        preferences.setString("address", "");
        preferences.setString("shopname", "");
        preferences.setString("merchandiserSts", "");
        preferences.setString("OrderDetailSts", "");
        preferences.setString("InvoiceSts", "");
        preferences.setString("checkMerchandizing", "");
        preferences.setString('phNo', "");
        preferences.setString('email', "");
        preferences.setString("printerName", "");
        preferences.setString("subTotal", "");
        preferences.setString("returnTotal", "");
        preferences.setString("DateTime", "");
        preferences.setString("saveImageSts", "");
        preferences.setString("DeliveryDate", "");
        preferences.setString("orderdetailSyskey", "");
        shopbyUser.deleteAllNote();
        shopbyTeam.deleteAllNote();
        dbOrder.deleteAllNote();
        check = 'success';
      } else {
        check = extdata['cause'];
      }
    } else {
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future checkIn(
    double lati,
    double longi,
    String shopName,
    String shopCode,
    String shopNamemm,
    String address,
    String phNo,
    String email,
    var shopsyskey,
    String checkinType,
    String merchandize,
    String orderdetail,
    String invoice) async {
  final df = new DateFormat('dd-MM-yyyy hh:mm a');
  var nowDate = df.format(new DateTime.now());
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'route/checkin';
  var check;
  var param = jsonEncode({
    "lat": "$lati",
    "lon": "$longi",
    "address": "$address",
    "shopsyskey": "$shopsyskey",
    "usersyskey": "${preferences.getString("spsyskey")}",
    "checkInType": "$checkinType",
    "register": false,
    "task": {
      "merchandize": "$merchandize",
      "orderDetail": "$orderdetail",
      "invoice": "$invoice",
    }
  });

  print(param);
  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": '${preferences.getString("OrgId")}',
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(param);
      print(extdata);
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      if (extdata["data"]["sessionid"] == "") {
      } else {
        preferences.setString('sessionId', extdata["data"]["sessionid"]);
      }
      saveCheckinInfo(
          lati, longi, nowDate, shopName, shopCode, shopNamemm, address, phNo, email);

      if (extdata["status"] == "SUCCESS") {
        check = 'success';
      } else {
        check = 'fail';
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future saveCheckinInfo(
    double lati,
    double longi,
    String nowDate,
    String shopName,
    String shopCode,
    String shopNamemm,
    String address,
    String phNo,
    String email) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  preferences.setString('latitude', lati.toString());
  preferences.setString('longitude', longi.toString());
  preferences.setString('date', nowDate);
  preferences.setString('address', address);
  preferences.setString('shopname', shopName);
  preferences.setString('shopCode', shopCode);
  preferences.setString("shopnamemm", shopNamemm);
  preferences.setString('phNo', phNo);
  preferences.setString('email', email);

  getdata = preferences.getString('latitude');
}

Future setTask(String merchandize, String orderdetail, String invoice) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'route/settask';

  var param = jsonEncode({
    "sessionId": "${preferences.getString("sessionId")}",
    "task": {
      "merchandize": merchandize,
      "orderDetail": orderdetail,
      "invoice": invoice
    }
  });

  print(url);
  print(param);

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  print(preferences.getString("sessionId"));
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(param);
      print(extdata);
      if (extdata["status"] == "SUCCESS") {
        check = "success";
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getStoreSts(String usersyskey, String shopsyskey) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'route/storestatus';
  var param =
      jsonEncode({"usersyskey": "$usersyskey", "shopsyskey": "$shopsyskey"});

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  print(json.decode(response.body));
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      if (extdata["status"] == "SUCCESS") {
        merchandizingSts = extdata["data"]["task"]["merchandize"];
        orderdetailSts = extdata["data"]["task"]["orderDetail"];
        invoiceSts = extdata["data"]["task"]["invoice"];
        invoiceCompleteSts = extdata["data"]["currentType"];
        check = 'success';
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getMerchandiserData(String sysKey) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  merchandiserList = [];
  tasktoDo = [];

  var check;
  final url = '$domain' + 'campaign/getshopKey';
  var param = jsonEncode({
    "shopSysKey": "$sysKey",
    "userType": "${preferences.getString("userType")}"
  });
  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  if (response != null) {
    print("1");
    print(param);
    print(json.decode(response.body));
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      if (extdata["status"].toString() == "SUCCESS!") {
        List mcdSyskeyList = [];
        if (extdata["list"].length == 0) {
          check = 'success';
        }
        for (var i = 0; i < extdata["list"].length; i++) {
          brandName = extdata["list"][i]["brandOwnerName"];
          task = extdata["list"][i]["t2"];
          taskId = extdata["list"][i]["taskId"];
          brandOwnerCode = extdata["list"][i]["brandOwnerId"];
          campaignsyskey = extdata["list"][i]["campaignsyskey"];
          campaignId = extdata["list"][i]["campaignId"];
          brandOwnerId = extdata["list"][i]["brandOwnerId"];
          userSysKey = extdata["list"][i]["userSysKey"];
          merT1 = extdata["list"][i]["t1"];
          merT2 = extdata["list"][i]["t2"];
          merT3 = extdata["list"][i]["t3"];
          merchandisingSts = extdata["status"];

          taskList = extdata["list"][i]["taskList"];

          print(brandName);

          for (var a = 0; a < extdata["list"][i]["taskList"].length; a++) {
            tasktoDo.add({
              "syskey": extdata["list"][i]["taskList"][a]["syskey"],
              "t1": extdata["list"][i]["taskList"][a]["taskCode"],
              "t2": extdata["list"][i]["taskList"][a]["taskName"],
            });

            mcdSyskeyList.add(extdata["list"][i]["taskList"][a]["syskey"]);
          }

          merchandiserList
              .add({"brand": "$brandName", "task": tasktoDo, "check": true});

          if (i == extdata["list"].length - 1) {
            for (var m = 0; m < tasktoDo.length; m++) {
              MerchandizerDatabase().insertNote(MerchandizerNote(
                  preferences.getString("userId"),
                  "",
                  "",
                  tasktoDo[m]["syskey"],
                  sysKey,
                  campaignId,
                  brandOwnerId,
                  "",
                  json.encode(tasktoDo),
                  "",
                  ""));

              if (m == tasktoDo.length - 1) {
                for (var n = 0; n < mcdSyskeyList.length; n++) {
                  _merchandizing(McdNote(mcdSyskeyList[n].toString(), ""));

                  if (n == mcdSyskeyList.length - 1) {
                    check = 'success';
                  }
                }
              }
            }
          }
        }
      } else {
        preferences.setString("checkMerchandizing", "fail");
        check = 'fail';
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getMerchandiserData1(String sysKey) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  merchandiserList = [];
  tasktoDo = [];

  var check;
  final url = '$domain' + 'campaign/getshopKey';
  var param = jsonEncode({
    "shopSysKey": "$sysKey",
    "userType": "${preferences.getString("userType")}"
  });
  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      if (extdata["status"].toString() == "SUCCESS!") {
        List mcdSyskeyList = [];
        if (extdata["list"].length == 0) {
          check = 'success';
        }
        for (var i = 0; i < extdata["list"].length; i++) {
          brandName = extdata["list"][i]["brandOwnerName"];
          task = extdata["list"][i]["t2"];
          taskId = extdata["list"][i]["taskId"];
          brandOwnerCode = extdata["list"][i]["brandOwnerId"];
          campaignsyskey = extdata["list"][i]["campaignsyskey"];
          campaignId = extdata["list"][i]["campaignId"];
          brandOwnerId = extdata["list"][i]["brandOwnerId"];
          userSysKey = extdata["list"][i]["userSysKey"];
          merT1 = extdata["list"][i]["t1"];
          merT2 = extdata["list"][i]["t2"];
          merT3 = extdata["list"][i]["t3"];
          merchandisingSts = extdata["status"];

          taskList = extdata["list"][i]["taskList"];

          print(brandName);

          for (var a = 0; a < extdata["list"][i]["taskList"].length; a++) {
            tasktoDo.add({
              "syskey": extdata["list"][i]["taskList"][a]["syskey"],
              "t1": extdata["list"][i]["taskList"][a]["taskCode"],
              "t2": extdata["list"][i]["taskList"][a]["taskName"],
            });

            mcdSyskeyList.add(extdata["list"][i]["taskList"][a]["syskey"]);

            if (a == extdata["list"][i]["taskList"].length - 1) {
              merchandiserList.add(
                  {"brand": "$brandName", "task": tasktoDo, "check": true});

              if (i == extdata["list"].length - 1) {
                check = 'success';
              }
            }
          }
        }
      } else {
        preferences.setString("checkMerchandizing", "fail");
        check = 'fail';
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

void _merchandizing(note) async {
  if (note.id != null) {
    await McdDatabase().updateNote(note);
    print('update');
  } else {
    print('insert');
    await McdDatabase().insertNote(note);
  }
  updateList();
}

Future getsolist(String getShopCode) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'order/getsolist';

  shopCode = getShopCode;

  var check;

  datetime();

  var param = jsonEncode(
      {"shopcode": "$shopCode", "date": "$date", "trantype": "SalesOrder"}
      // {"shopcode": "$shopCode", "date": "20210215", "trantype": "SalesOrder"}
      );
  print(param);
  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      if (extdata["status"].toString() == "SUCCESS!") {
        if (extdata["list"].length == 0) {
          check = 'success';
        }
        for (var i = 0; i < extdata["list"].length; i++) {
          if (extdata["list"][i]["stockByBrand"].length == 0) {
            check = 'success';
          }
          sysKey = extdata["list"][i]["syskey"];

          orderDetailData.add({
            "syskey": extdata["list"][i]["syskey"],
            "date": extdata["list"][i]["docummentDate"]
          });

          print(orderDetailData);

          for (var a = 0; a < extdata["list"][i]["stockByBrand"].length; a++) {
            print(extdata["list"][i]["stockByBrand"][a]["stockData"]);

            transId = extdata["list"][i]["stockByBrand"][a]["transId"];
            brandOwnerSysKey =
                extdata["list"][i]["stockByBrand"][a]["brandOwnerSyskey"];
            brandOwnerName1 =
                extdata["list"][i]["stockByBrand"][a]["brandOwnerName"];
            userID = extdata["list"][i]["stockByBrand"][a]["userid"];
            userName = extdata["list"][i]["stockByBrand"][a]["username"];
            brandOwnerCode1 =
                extdata["list"][i]["stockByBrand"][a]["brandOwnerCode"];
            orderSyskey = extdata["list"][i]["stockByBrand"][a]["orderSyskey"];
            cashAmount =
                extdata["list"][i]["stockByBrand"][a]["cashamount"].toString();
            discountAmount = extdata["list"][i]["stockByBrand"][a]
                    ["discountamount"]
                .toString();
            taxSyskey = extdata["list"][i]["stockByBrand"][a]["taxSyskey"];
            taxPercent =
                extdata["list"][i]["stockByBrand"][a]["taxPercent"].toString();
            taxAmount =
                extdata["list"][i]["stockByBrand"][a]["taxAmount"].toString();

            print(extdata["list"][i]["syskey"]);

            if (i == extdata["list"].length - 1) {
              if (a == extdata["list"][i]["stockByBrand"].length - 1) {
                check = 'success';
              }
            }
          }
        }
      } else {
        check = 'fail';
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getStock(String getShopCode, String sysKey) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'order/getsolist';

  shopCode = getShopCode;

  brandOwnerName = [];
  stockDataOrder = [];
  stockReturnData = [];

  var check;

  datetime();

  var param = jsonEncode(
      {"shopcode": "$shopCode", "date": "$date", "trantype": "SalesOrder"}
      // {"shopcode": "$shopCode", "date": "20210215", "trantype": "SalesOrder"}
      );
  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  print(url);
  print(param);
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      if (extdata["status"].toString() == "SUCCESS!") {
        if (extdata["list"].length == 0) {
          check = 'success';
        } else {
          List data = [];

          data = extdata["list"].where((val) => val["syskey"] == sysKey).toList();

          if (data.length == 0) {
            check = 'success';
          } else {
          stockByBrandDel = [];
          getdeliverylist = [];
          stockData = [];
          returnStockData = [];

          // for (var a = 0; a < data.length; a++) {
          if (data[0]["stockByBrand"].length == 0) {
            // check = 'success';
          } else {
            brandOwnerName.add(data[0]["stockByBrand"]);

            for (var b = 0; b < data[0]["stockByBrand"].length; b++) {
              if (data[0]["stockByBrand"][b]["stockData"].length == 0) {
                // check = 'success';
              } else {
                stockData = [];
                returnStockData = [];
                for (var i = 0; i < data[0]["stockByBrand"][b]["stockData"].length; i++) {
                  print(data[0]["stockByBrand"][b]["stockData"][i]);
                  stockData.add({
                    "stockCode": data[0]["stockByBrand"][b]["stockData"][i]
                        ["stockCode"],
                    "stockName": data[0]["stockByBrand"][b]["stockData"][i]
                        ["stockName"],
                    "recordStatus": data[0]["stockByBrand"][b]["stockData"][i]
                        ["recordStatus"],
                    "saleCurrCode": data[0]["stockByBrand"][b]["stockData"][i]
                        ["saleCurrCode"],
                    "stockSyskey": data[0]["stockByBrand"][b]["stockData"][i]
                        ["stockSyskey"],
                    "n1": data[0]["stockByBrand"][b]["stockData"][i]["n1"],
                    "wareHouseSyskey": data[0]["stockByBrand"][b]["stockData"]
                        [i]["wareHouseSyskey"],
                    "binSyskey": data[0]["stockByBrand"][b]["stockData"][i]
                        ["binSyskey"],
                    "qty": int.parse(data[0]["stockByBrand"][b]["stockData"][i]
                            ["qty"]
                        .toString()
                        .substring(
                            0,
                            data[0]["stockByBrand"][b]["stockData"][i]["qty"]
                                .toString()
                                .lastIndexOf("."))),
                    "lvlSyskey": data[0]["stockByBrand"][b]["stockData"][i]
                        ["lvlSyskey"],
                    "lvlQty": data[0]["stockByBrand"][b]["stockData"][i]
                        ["lvlQty"],
                    "n8": data[0]["stockByBrand"][b]["stockData"][i]["n8"],
                    "price": data[0]["stockByBrand"][b]["stockData"][i]
                        ["price"],
                    "normalPrice" : data[0]["stockByBrand"][b]["stockData"][i]
                        ["normalPrice"],
                    "n9": data[0]["stockByBrand"][b]["stockData"][i]["n9"],
                    "taxAmount": data[0]["stockByBrand"][b]["stockData"][i]
                        ["taxAmount"],
                    "totalAmount": data[0]["stockByBrand"][b]["stockData"][i]
                        ["totalAmount"],
                    "taxCodeSK": data[0]["stockByBrand"][b]["stockData"][i]
                        ["taxCodeSK"],
                    "isTaxInclusice": data[0]["stockByBrand"][b]["stockData"][i]
                        ["isTaxInclusice"],
                    "taxPercent": data[0]["stockByBrand"][b]["stockData"][i]
                        ["taxPercent"],
                    "discountAmount": data[0]["stockByBrand"][b]["stockData"][i]
                        ["discountAmount"],
                    "discountPercent": data[0]["stockByBrand"][b]["stockData"][i]
                        ["discountPercent"],
                    "discountStock": false,
                    "invoiceSyskey": data[0]["stockByBrand"][b]["stockData"][i]
                        ["invoiceSyskey"],
                    "invoiceDate": data[0]["stockByBrand"][b]["stockData"][i]
                        ["invoiceDate"],
                    "appliedDate": data[0]["stockByBrand"][b]["stockData"][i]
                        ["appliedDate"],
                    "promoDetailSyskey": data[0]["stockByBrand"][b]["stockData"][i]
                        ["promoDetailSyskey"],
                    "promotionStockList" : data[0]["stockByBrand"][b]["stockData"][i]
                        ["promotionStockList"]
                  });
                }

                // print("Two");
              }

              if (data[0]["stockByBrand"][b]["stockReturnData"].length == 0) {
                // check = 'success';
              } else {
                for (var i = 0;
                    i < data[0]["stockByBrand"][b]["stockReturnData"].length;
                    i++) {
                  returnStockData.add({
                    "stockCode": data[0]["stockByBrand"][b]["stockReturnData"]
                        [i]["stockCode"],
                    "stockName": data[0]["stockByBrand"][b]["stockReturnData"]
                        [i]["stockName"],
                    "saleCurrCode": data[0]["stockByBrand"][b]
                        ["stockReturnData"][i]["saleCurrCode"],
                    "stockSyskey": data[0]["stockByBrand"][b]["stockReturnData"][i]
                        ["stockSyskey"],
                    "n1": data[0]["stockByBrand"][b]["stockReturnData"][i]
                        ["n1"],
                    "wareHouseSyskey": data[0]["stockByBrand"][b]
                        ["stockReturnData"][i]["wareHouseSyskey"],
                    "binSyskey": data[0]["stockByBrand"][b]["stockReturnData"]
                        [i]["binSyskey"],
                    "qty": int.parse(data[0]["stockByBrand"][b]
                            ["stockReturnData"][i]["qty"]
                        .toString()
                        .substring(
                            0,
                            data[0]["stockByBrand"][b]["stockReturnData"][i]
                                    ["qty"]
                                .toString()
                                .lastIndexOf("."))),
                    "lvlSyskey": data[0]["stockByBrand"][b]["stockReturnData"]
                        [i]["lvlSyskey"],
                    "lvlQty": data[0]["stockByBrand"][b]["stockReturnData"][i]
                        ["lvlQty"],
                    "n8": data[0]["stockByBrand"][b]["stockReturnData"][i]
                        ["n8"],
                    "price": data[0]["stockByBrand"][b]["stockReturnData"][i]
                        ["price"],
                    "normalPrice" : data[0]["stockByBrand"][b]["stockReturnData"][i]
                        ["normalPrice"],
                    "n9": data[0]["stockByBrand"][b]["stockReturnData"][i]
                        ["n9"],
                    "taxAmount": data[0]["stockByBrand"][b]["stockReturnData"]
                        [i]["taxAmount"],
                    "totalAmount": data[0]["stockByBrand"][b]["stockReturnData"]
                        [i]["totalAmount"],
                    "taxCodeSK": data[0]["stockByBrand"][b]["stockReturnData"]
                        [i]["taxCodeSK"],
                    "isTaxInclusice": data[0]["stockByBrand"][b]
                        ["stockReturnData"][i]["isTaxInclusice"],
                    "taxPercent": data[0]["stockByBrand"][b]["stockReturnData"]
                        [i]["taxPercent"],
                  });
                }
              }

              stockByBrandDel.add({
                "autokey": data[0]["stockByBrand"][b]["autokey"],
                "createddate": data[0]["stockByBrand"][b]["createddate"],
                "modifieddate": data[0]["stockByBrand"][b]["modifieddate"],
                "userid": data[0]["stockByBrand"][b]["userid"],
                "username": data[0]["stockByBrand"][b]["username"],
                "saveStatus": data[0]["stockByBrand"][b]["saveStatus"],
                "recordStatus": data[0]["stockByBrand"][b]["recordStatus"],
                "syncStatus": data[0]["stockByBrand"][b]["syncStatus"],
                "syncBatch": data[0]["stockByBrand"][b]["syncBatch"],
                "transType": "DeliveryOrder",
                "transId": data[0]["stockByBrand"][b]["transId"],
                "docummentDate": "$date",
                "brandOwnerCode": data[0]["stockByBrand"][b]["brandOwnerCode"],
                "brandOwnerName": data[0]["stockByBrand"][b]["brandOwnerName"],
                "brandOwnerSyskey": data[0]["stockByBrand"][b]
                    ["brandOwnerSyskey"],
                "orderSyskey": data[0]["stockByBrand"][b]["orderSyskey"],
                "totalamount": data[0]["stockByBrand"][b]["totalamount"],
                "orderTotalAmount": 0.0,
                "returnTotalAmount": 0.0,
                "discountamount": data[0]["stockByBrand"][b]["discountamount"],
                "taxSyskey": data[0]["stockByBrand"][b]["taxSyskey"],
                "taxPercent": data[0]["stockByBrand"][b]["taxPercent"],
                "taxAmount": data[0]["stockByBrand"][b]["taxAmount"],
                "orderDiscountPercent": 0.0,
                "returnDiscountPercent": 0.0,
                "orderDiscountAmount": 0.0,
                "returnDiscountAmount": 0.0,
                "payment1": 0.0,
                "payment2": 0.0,
                "cashamount": 0.0,
                "creditAmount": 0.0,
                "promotionList" : [],
                "stockData": stockData,
                "stockReturnData": returnStockData
              });

              // if(a == data.length-1) {
              if (b == data[0]["stockByBrand"].length - 1) {
                for (var i = 0; i < extdata["list"].length; i++) {
                  // stockByBrandDel.removeWhere((element) =>
                  //     element["stockData"].length == 0 &&
                  //     element["stockReturnData"].length == 0);
                  sysKey = extdata["list"][i]["syskey"];

                  if (i == extdata["list"].length - 1) {
                    check = 'success';
                    
                  }
                }
              }
            }
          }
          }

          
        }

      } else {
        check = 'fail';
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

List addReturnProductList = [];

Future getReturnProduct(String shopSyskey) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'order/get-return-product';

  var check;
  var param;

  datetime();

  addReturnProductList = [];

  param = jsonEncode({
    "count":10,
    "brandownerSyskey":"0",
    "storeSyskey":"$shopSyskey",
    "date":"$date"
  });

  print(url);
  print(param);

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);

      if(extdata["list"].length == 0) {
        check = "success";
      } else {
        List brandOwnerList = [];
        for(var a = 0; a < extdata["list"].length; a++) {
          if(addReturnProductList.length == 0) {
            addReturnProductList.add({
              "invoiceDate" : "${extdata["list"][a]["createddate"]}",
              "visible" : false,
              "brandOwnerList" : []
            });
          } else {
            if(addReturnProductList.where((element) => element["createddate"] == extdata["list"][a]["createddate"]).toList().length == 0) {
              addReturnProductList.add({
                "invoiceDate" : "${extdata["list"][a]["createddate"]}",
                "visible" : false,
                "brandOwnerList" : []
              });
            }
          }

          for(var g = 0; g < extdata["list"][a]["stockByBrand"].length; g++) {
            if(brandOwnerList.length == 0) {
              brandOwnerList.add({
                "brandOwnerName" : "${extdata["list"][a]["stockByBrand"][g]["brandOwnerName"]}",
                "brandOwnerSyskey" : "${extdata["list"][a]["stockByBrand"][g]["brandOwnerSyskey"]}",
                "invoiceDate" : "${extdata["list"][a]["createddate"]}",
                "visible" : false,
                "stockData" : extdata["list"][a]["stockByBrand"][g]["stockData"]
              });
            } else {
              if(brandOwnerList.where((element) => element["brandOwnerSyskey"] == extdata["list"][a]["stockByBrand"][g]["brandOwnerSyskey"] && element["invoiceDate"] == extdata["list"][a]["stockByBrand"][g]["createddate"]).toList().length == 0) {
                brandOwnerList.add({
                  "brandOwnerName" : "${extdata["list"][a]["stockByBrand"][g]["brandOwnerName"]}",
                  "brandOwnerSyskey" : "${extdata["list"][a]["stockByBrand"][g]["brandOwnerSyskey"]}",
                  "invoiceDate" : "${extdata["list"][a]["createddate"]}",
                  "visible" : false,
                  "stockData" : extdata["list"][a]["stockByBrand"][g]["stockData"]
                });
              }
            }

            if(a == extdata["list"].length -1 && g == extdata["list"][a]["stockByBrand"].length-1) {
              for(var b = 0; b < addReturnProductList.length; b++) {
                addReturnProductList[b]["brandOwnerList"] = brandOwnerList.where((element) => element["invoiceDate"] == addReturnProductList[b]["invoiceDate"]).toList();

                if(b == addReturnProductList.length-1) {
                  if(getdeliverylist.length != 0) {
                    for(var x = 0; x < addReturnProductList.length; x++) {
                      for(var c = 0; c < getdeliverylist.length; c++) {
                        if(getdeliverylist[c]["invoiceDate"] == addReturnProductList[x]["invoiceDate"]) {
                          print("One");
                          for(var y = 0; y < addReturnProductList[x]["brandOwnerList"].length; y++) {
                            if(getdeliverylist[c]["brandOwnerSyskey"] == addReturnProductList[x]["brandOwnerList"][y]["brandOwnerSyskey"]) {
                              print("Two");
                              if(getdeliverylist[c]["stockReturnData"].length != 0) {
                                for(var d = 0; d < getdeliverylist[c]["stockReturnData"].length; d++) {
                                  for(var z = 0; z < addReturnProductList[x]["brandOwnerList"][y]["stockData"].length; z++) {
                                    if(addReturnProductList[x]["brandOwnerList"][y]["stockData"][z]["stockSyskey"].toString() == getdeliverylist[c]["stockReturnData"][d]["stockSyskey"].toString() &&
                                    addReturnProductList[x]["brandOwnerList"][y]["stockData"][z]["syskey"].toString() == getdeliverylist[c]["stockReturnData"][d]["invoiceSyskey"].toString()) {

                                      addReturnProductList[x]["brandOwnerList"][y]["stockData"][z]["returnQty"] = addReturnProductList[x]["brandOwnerList"][y]["stockData"][z]["returnQty"] + getdeliverylist[c]["stockReturnData"][d]["qty"].toInt();
                                      preferences.setString("AddReturnProductList", json.encode(addReturnProductList));
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                  preferences.setString("AddReturnProductList", json.encode(addReturnProductList));
                  check = "success";
                }
              }
            }
          }
        }
      }
      
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getInvoiceList(String getShopCode) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'order/getinvoicelist';

  var check;
  var param;

  datetime();

  getinvoiceOrderlist = [];

  param = jsonEncode({
    "shopcode": "$getShopCode",
    "date": "$date",
    "trantype": "InvoiceOrder",
    "syskey": ""
  });

  print(param);

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);

      print(extdata);

      if (extdata["status"] == "SUCCESS") {
        if (extdata["list"].length == 0) {
          check = "success";
        }
        for (var i = 0; i < extdata["list"].length; i++) {
          getinvoiceOrderlist = extdata["list"][i]["stockByBrand"];

          deliveryDate = extdata["list"][i]["time"];

          preferences.setString(
              "orderdetailSyskey", extdata["list"][i]["previousId"]);

          if (i == extdata["list"].length - 1) {
            check = "success";
            
          }
        }
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future updateSaleOrder(double totalAmount, var shopCode, var cashAmt, var discountAmt) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'order/save';

  var check;

  datetime();

  print("updateSaleOrder");

  for(var a = 0; a < getdeliverylist.where((element) => element["stockData"].length == 0 && element["stockReturnData"].length == 0).toList().length; a++) {
    getdeliverylist.where((element) => element["stockData"].length == 0 && element["stockReturnData"].length == 0).toList()[a]["recordStatus"] = 4;
    print("Sts Code 4 ==> ${getdeliverylist.where((element) => element["stockData"].length == 0 && element["stockReturnData"].length == 0).toList()}");
  }

  List value = await _checkarray(getdeliverylist);
  print("unique data >>>> $value");

  var param = jsonEncode({
    "syskey": "${preferences.getString("orderdetailSyskey")}",
    "autokey": "0",
    "createddate": "$date",
    "modifieddate": "$date",
    "userid": "${preferences.getString("userId")}",
    "username": "${preferences.getString("userName")}",
    "saveStatus": 1,
    "recordStatus": 1,
    "syncStatus": 1,
    "syncBatch": "",
    "transType": "DeliveryOrder",
    "manualRef": "TBA",
    "docummentDate": "$date",
    "shopCode": "$shopCode",
    "currRate": 1.0,
    "totalamount": totalAmount,
    "cashamount": cashAmt,
    "discountamount": discountAmt,
    "taxSyskey": "0",
    "taxPercent": 1.0,
    "taxAmount": 1.0,
    "stockByBrand": value
  });

  print("The Update Sale Order List is ====================>");

  print(param);

  print("DeliveryList length is ==>   " + getdeliverylist.length.toString());

  for (var a = 0; a < getdeliverylist.length; a++) {
    print("DeliveryList ==>  ");
    print(getdeliverylist[a]);
    for (var v = 0; v < getdeliverylist[a]["stockData"].length; v++) {
      print(getdeliverylist[a]["stockData"][v]);
    }
  }

  for (var a = 0; a < getdeliverylist.length; a++) {
    for (var v = 0; v < getdeliverylist[a]["stockReturnData"].length; v++) {
      print(getdeliverylist[a]["stockReturnData"][v]);
    }
  }

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      if (extdata["status"] == "SUCCESS") {
        check = "success";
        preferences.setString("orderdetailSyskey", extdata["data"]["syskey"]);
      } else {
        print("fail");
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getDeliveryList(String getShopCode) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'order/getdeliverylist';

  var check;

  var param;

  datetime();

  param = jsonEncode({
    "shopcode": "$getShopCode",
    "date": "$date",
    // "date": "20201120",
    "trantype": "DeliveryOrder",
    "syskey": ""
  });

  print(url);

  print(param);

  getdeliverylist = [];

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print("The ExtData is ==> $extdata");

      if (extdata["status"] == "SUCCESS") {
        if (extdata["list"].length == 0) {
          return check = "success";
        } else {
          for (var i = 0; i < extdata["list"].length; i++) {
            getdeliverylist = extdata["list"][i]["stockByBrand"];

            deliverySyskey = extdata["list"][i]["syskey"];

            sysKey = extdata["list"][i]["previousId"];

            preferences.setString("orderdetailSyskey", deliverySyskey);

            deliveryDate = extdata["list"][i]["time"];

            if (i == extdata["list"].length - 1) {
              return check = "success";
            }
          }
        }
      } else {
        return check = "fail";
      }
    } else {
      print(response.statusCode);
      return check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    return check = 'Connection Fail!';
  }
}

Future deliveryOrder(var totalAmount, var shopCode) async {
  print("22222");
  final url = '$domain' + 'order/save';
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  var check;

  var param;

  datetime();

  print("Delivery Order");
  print(sysKey);
  if(sysKey == "" || sysKey == null) {
    sysKey = "0";
  }

  for (var v = 0; v < stockByBrandDel.length; v++) {
    for (var n = 0; n < stockByBrandDel.length; n++) {
      if ((stockByBrandDel[v]["brandOwnerSyskey"].toString() ==
              stockByBrandDel[n]["brandOwnerSyskey"].toString()) &&
          (stockByBrandDel[v]["stockData"].toString() !=
              stockByBrandDel[n]["stockData"].toString()) &&
          (stockByBrandDel[v]["stockReturnData"].toString() !=
              stockByBrandDel[n]["stockReturnData"].toString())) {
        if (stockByBrandDel[n]["stockData"].length == 0) {
          stockByBrandDel[v]["stockReturnData"] =
              stockByBrandDel[n]["stockReturnData"];
        } else if (stockByBrandDel[n]["stockReturnData"].length == 0) {
          stockByBrandDel[v]["stockData"] = stockByBrandDel[n]["stockData"];
        } else {
          stockByBrandDel[v]["stockData"] =
              stockByBrandDel[v]["stockData"] + stockByBrandDel[n]["stockData"];
          stockByBrandDel[v]["stockReturnData"] = stockByBrandDel[v]
                  ["stockReturnData"] +
              stockByBrandDel[n]["stockReturnData"];
        }

        stockByBrandDel[n]["stockData"] = [];
        stockByBrandDel[n]["stockReturnData"] = [];
      }
    }

    stockByBrandDel.removeWhere((element) =>
        element["stockData"].length == 0 &&
        element["stockReturnData"].length == 0);

  }


  List value = await _checkarray(stockByBrandDel);
  print("unique data >>>> $value");

  param = jsonEncode({
    "syskey": "0",
    "autokey": "0",
    "createddate": "$date",
    "modifieddate": "$date",
    "userid": "${preferences.getString("userId")}",
    "username": "${preferences.getString("userName")}",
    "saveStatus": 1,
    "recordStatus": 1,
    "syncStatus": 1,
    "syncBatch": "",
    "transType": "DeliveryOrder",
    "manualRef": "TBA",
    "docummentDate": "$date",
    "shopCode": "$shopCode",
    "currRate": 1,
    "totalamount": totalAmount,
    "cashamount": 1,
    "discountamount": 1,
    "taxSyskey": "0",
    "taxPercent": 1,
    "taxAmount": 1,
    "previousId": "$sysKey",
    "stockByBrand": value
  });

  print(param);

  print("StockbyBrand List length ==>  " + stockByBrandDel.length.toString());

  for (var i = 0; i < stockByBrandDel.length; i++) {
    print("StockbyBrand List ==>    ");
    print(stockByBrandDel[i]);
    print("111111111");
    for (var v = 0; v < stockByBrandDel[i]["stockData"].length; v++) {
      print(stockByBrandDel[i]["stockData"][v]);
    }
    print("2222222");
    for (var v = 0; v < stockByBrandDel[i]["stockReturnData"].length; v++) {
      print(stockByBrandDel[i]["stockReturnData"][v]);
    }
    print("3333333333");
  }

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      print(extdata["status"]);

      orderDetailSts = extdata["status"];
      if (orderDetailSts == "SUCCESS") {
        orderdetailSyskey = extdata["data"]["syskey"];

        print(extdata["data"]["syskey"]);

        preferences.setString("orderdetailSyskey", orderdetailSyskey);

        preferences.setString('OrderDetailSts', orderDetailSts);

        print(check);

        return check = 'success';
      } else {
        return check = 'fail';
      }
    } else {
      print(response.statusCode);
      return check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    return check = 'Connection Fail!';
  }
}

Future inVoice(String shopCode, String brandOwnerName, var totalAmount,
    var discountAmount, var cashAmt) async {
  final url = '$domain' + 'order/save';
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  var check;

  var param;

  for (var a = 0; a < getdeliverylist.length; a++) {
    getdeliverylist[a]["syskey"] = "0";
    getdeliverylist[a]["transType"] = "SaleInvoice";
    for (var b = 0; b < getdeliverylist[a]["stockData"].length; b++) {
      getdeliverylist[a]["stockData"][b]["syskey"] = "0";
    }
    for (var b = 0; b < getdeliverylist[a]["stockReturnData"].length; b++) {
      getdeliverylist[a]["stockReturnData"][b]["syskey"] = "0";
    }
  }

  datetime();

  List value = await _checkarray(getdeliverylist);
  print("unique data >>>> $value");

  param = jsonEncode({
    "syskey": "0",
    "autokey": "0",
    "createddate": "$date",
    "modifieddate": "$date",
    "userid": "${preferences.getString('userId')}",
    "username": "${preferences.getString('userName')}",
    "saveStatus": 1,
    "recordStatus": 1,
    "syncStatus": 0,
    "syncBatch": "",
    "transType": "SaleInvoice",
    "manualRef": "SO",
    "docummentDate": "$date",
    "shopCode": "$shopCode",
    "currRate": 1.0,
    "totalamount": totalAmount,
    "cashamount": cashAmt,
    "discountamount": discountAmount,
    "taxSyskey": "0",
    "taxPercent": 1.0,
    "taxAmount": 1.0,
    "previousId": "${preferences.getString("orderdetailSyskey")}",
    "stockByBrand": value
  });

  print("Invoice Param ==> ");

  print(param);

  print(value);

  for (var a = 0; a < value.length; a++) {
    print(value[a]);

    for (var b = 0; b < value[a]["stockData"].length; b++) {
      print(value[a]["stockData"][b]);
    }

    for (var b = 0; b < value[a]["stockReturnData"].length; b++) {
      print(value[a]["stockReturnData"][b]);
    }
  }
  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  print(json.decode(response.body));
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      inVoiceSts = extdata["status"];

      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      preferences.setString('InvoiceSts', inVoiceSts);

      print(inVoiceSts.toString() + "  ????");

      if (inVoiceSts == "SUCCESS") {
        check = 'success';
      } else {
        check = 'fail';
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future merchandiser(String shopSysKey, var tasktoDo, var campaignId,
    var brandOwnerId, List remark, List imageFilePath) async {
  final url = '$domain' + 'campaign/saveCampaign';

  final SharedPreferences preferences = await SharedPreferences.getInstance();

  var check;

  List pictureData = [];
  List mc003 = [];
  var param;

  for (var i = 0; i < tasktoDo.length; i++) {
    List imagePath = [];
    pictureData = [];
    imagePath = imageFilePath
        .where((element) =>
            element['imagePath']
                .toString()
                .contains("${tasktoDo[i]["syskey"]}") ==
            true)
        .toList();

    for (var a = 0; a < imagePath.length; a++) {
      pictureData.add({
        "t1": "$campaignId",
        "t2": "${imagePath[a]['imageName']}",
        "t3": "${imagePath[a]['imagePath']}"
      });
    }

    mc003.add({
      "n2": "${tasktoDo[i]["syskey"]}",
      "t1": "${remark[i]}",
      "t2": "${tasktoDo[i]["t1"]}",
      "t3": "${tasktoDo[i]["t2"]}",
      "pictureData": pictureData
    });
  }

  param = jsonEncode({
    "shopSysKey": "$shopSysKey",
    "campaignsyskey": "1000000001",
    "lmc002": [
      {
        "campaignId": "$campaignId",
        "brandOwnerId": "$brandOwnerId",
        "userKey": "30001",
        "mc003": mc003
      }
    ]
  });

  print(param.toString());
  print(pictureData);
  print(mc003);
  final response = await http.post(Uri.encodeFull(url), body: param, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Content-Over": "${preferences.getString('OrgId')}"
  });
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      merchandiserSts = extdata["status"];

      print(extdata["status"]);

      if (merchandiserSts == 'SUCCESS') {
        preferences.setString('merchandiserSts', merchandiserSts);

        check = 'success';
      } else {
        check = 'fail';
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getRecommendedList(String shopSyskey) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = domain + "order/getrecommendedlist";

  var param = jsonEncode({"shopsyskey": "$shopSyskey"});
  // var param = jsonEncode({"shopsyskey": "2006241929024700089"});

  datetime();

  var check;

  print(param);

  stockData = [];
  returnStockData = [];
  stockByBrandDel = [];
  recommendedOrderList = [];
  recommendedReturnList = [];
  getrecommendedlist = null;
  getdeliverylist = [];

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var result = json.decode(response.body);
      print(result);
      if (result["status"] == "SUCCESS!") {
        sysKey = "0";
        if (result["list"].length == 0) {
          check = "success";
        }
        for (var i = 0; i < result["list"].length; i++) {
          getrecommendedlist = result["list"][i]["stock"];
          recommendedOrderList.add({
            "syskey": "0",
            "recordStatus": 1,
            "stockCode": "${result["list"][i]["stock"]["code"]}",
            "stockName": "${result["list"][i]["stock"]["desc"]}",
            "stockSyskey": "${result["list"][i]["stockSyskey"]}",
            "saleCurrCode": "MMK",
            "n1": "0",
            "wareHouseSyskey": "${result["list"][i]["stock"]["whSyskey"]}",
            "binSyskey": "0",
            "qty": double.parse("${result["list"][i]["avgQty"]}.0"),
            "lvlSyskey": "",
            "lvlQty": 1.0,
            "n8": 1.0,
            "n9": 0.0,
            "taxAmount": 0.0,
            "totalAmount": result["list"][i]["stock"]["details"].length == 0 ? 0.0 : result["list"][i]["stock"]["details"][0]["price"] * result["list"][i]["avgQty"],
            "price": result["list"][i]["stock"]["details"].length == 0 ? 0.0 : result["list"][i]["stock"]["details"][0]["price"],
            "normalPrice" : result["list"][i]["stock"]["details"].length == 0 ? 0.0 : result["list"][i]["stock"]["details"][0]["price"],
            "taxCodeSK": "0",
            "isTaxInclusice": 0,
            "taxPercent": 0.0,
            "discountAmount": 0.0,
            "discountPercent": 0.0,
            "discountStock": false,
            "promotionStockList" : [],
            "brandOwnerSyskey":
                "${result["list"][i]["stock"]["brandOwnerSyskey"]}",
            "stockType": "NORMAL"
          });
          
          if(getPriceZoneDownloadList.length != 0) {
            for(var a = 0; a < getPriceZoneDownloadList.length; a++) {
              print("${getPriceZoneDownloadList[a]["StockSyskey"]} = ${result["list"][i]["stockSyskey"]}");
              if(getPriceZoneDownloadList[a]["StockSyskey"] == result["list"][i]["stockSyskey"]) {
              recommendedOrderList.add({
                "syskey": "0",
                "recordStatus": 1,
                "stockCode": "${result["list"][i]["stock"]["code"]}",
                "stockName": "${result["list"][i]["stock"]["desc"]}",
                "stockSyskey": "${result["list"][i]["stockSyskey"]}",
                "saleCurrCode": "MMK",
                "n1": "0",
                "wareHouseSyskey": "${result["list"][i]["stock"]["whSyskey"]}",
                "binSyskey": "0",
                "qty": double.parse("${result["list"][i]["avgQty"]}.0"),
                "lvlSyskey": "",
                "lvlQty": 1.0,
                "n8": 1.0,
                "n9": 0.0,
                "taxAmount": 0.0,
                "totalAmount": double.parse(getPriceZoneDownloadList[a]["ChangedPrice"]) * result["list"][i]["avgQty"],
                "price": double.parse(getPriceZoneDownloadList[a]["ChangedPrice"]),
                "normalPrice" : double.parse(getPriceZoneDownloadList[a]["ChangedPrice"]),
                "taxCodeSK": "0",
                "isTaxInclusice": 0,
                "taxPercent": 0.0,
                "discountAmount": 0.0,
                "discountPercent": 0.0,
                "discountStock": false,
                "promotionStockList" : [],
                "brandOwnerSyskey":
                    "${result["list"][i]["stock"]["brandOwnerSyskey"]}",
                "stockType": "NORMAL"
              });
              }
            }
          }

          recommendedReturnList = [];
          stockData.add({
            "stockCode": "${result["list"][i]["stock"]["code"]}",
            "stockName": "${result["list"][i]["stock"]["desc"]}",
            "recordStatus": 1,
            "saleCurrCode": "MMK",
            "stockSyskey" : "${result["list"][i]["stockSyskey"]}",
            "n1": "0",
            "wareHouseSyskey": "${result["list"][i]["stock"]["whSyskey"]}",
            "binSyskey": "0",
            "qty": result["list"][i]["avgQty"],
            "lvlSyskey": "0",
            "lvlQty": 0.0,
            "n8": 0.0,
            "price": result["list"][i]["stock"]["details"].length == 0 ? 0.0 : result["list"][i]["stock"]["details"][0]["price"],
            "normalPrice" : result["list"][i]["stock"]["details"].length == 0 ? 0.0 : result["list"][i]["stock"]["details"][0]["price"],
            "n9": 0.0,
            "taxAmount": 0.0,
            "totalAmount": result["list"][i]["stock"]["details"].length == 0 ? 0.0 : result["list"][i]["stock"]["details"][0]["price"] * result["list"][i]["avgQty"],
            "taxCodeSK": "0",
            "isTaxInclusice": 0,
            "taxPercent": 0.0,
            "discountAmount": 0.0,
            "discountPercent": 0.0,
            "promotionList" : [],
            "discountStock": false,
            "promotionStockList" : []
          });

          if(getPriceZoneDownloadList.length != 0) {
            for(var a = 0; a < getPriceZoneDownloadList.length; a++) {
              if(getPriceZoneDownloadList[a]["StockSyskey"] == result["list"][i]["stockSyskey"]) {
                stockData.add({
                  "stockCode": "${result["list"][i]["stock"]["code"]}",
                  "stockName": "${result["list"][i]["stock"]["desc"]}",
                  "recordStatus": 1,
                  "saleCurrCode": "MMK",
                  "stockSyskey" : "${result["list"][i]["stockSyskey"]}",
                  "n1": "0",
                  "wareHouseSyskey": "${result["list"][i]["stock"]["whSyskey"]}",
                  "binSyskey": "0",
                  "qty": result["list"][i]["avgQty"],
                  "lvlSyskey": "0",
                  "lvlQty": 0.0,
                  "n8": 0.0,
                  "price": double.parse(getPriceZoneDownloadList[a]["ChangedPrice"]),
                  "normalPrice" : double.parse(getPriceZoneDownloadList[a]["ChangedPrice"]),
                  "n9": 0.0,
                  "taxAmount": 0.0,
                  "totalAmount": double.parse(getPriceZoneDownloadList[a]["ChangedPrice"]) * result["list"][i]["avgQty"],
                  "taxCodeSK": "0",
                  "isTaxInclusice": 0,
                  "taxPercent": 0.0,
                  "discountAmount": 0.0,
                  "discountPercent": 0.0,
                  "promotionList" : [],
                  "discountStock": false,
                  "promotionStockList" : []
                });
              }
            }
          }
          returnStockData = [];

          stockByBrandDel = [
            {
              "autokey": "",
              "createddate": "$date",
              "modifieddate": "$date",
              "userid": preferences.getString("userId"),
              "username": preferences.getString("userName"),
              "saveStatus": 1,
              "recordStatus": 1,
              "syncStatus": "",
              "syncBatch": "",
              "transType": "DeliveryOrder",
              "transId": "",
              "docummentDate": "$date",
              "brandOwnerCode": getrecommendedlist["brandOwnerCode"],
              "brandOwnerName": getrecommendedlist["brandOwnerName"],
              "brandOwnerSyskey": getrecommendedlist["brandOwnerSyskey"],
              "orderSyskey": "",
              "totalamount": 0.0,
              "orderTotalAmount": 0.0,
              "returnTotalAmount": 0.0,
              "discountamount": 0,
              "taxSyskey": 0,
              "taxPercent": 0,
              "taxAmount": 0,
              "orderDiscountPercent": 0.0,
              "returnDiscountPercent": 0.0,
              "orderDiscountAmount": 0.0,
              "returnDiscountAmount": 0.0,
              "payment1": 0.0,
              "payment2": 0.0,
              "cashamount": 0.0,
              "creditAmount": 0.0,
              "promotionList" : [],
              "stockData": stockData,
              "stockReturnData": returnStockData
            }
          ];

          if (i == result["list"].length - 1) {
            check = "success";
          }
        }
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }

  return check;
}

Future getDelAmountSummary() async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'deleveryAmount/getDelAmountSummary';

  getDelAmtSummary = [];

  var param = jsonEncode(
      {"userSysKey": "${preferences.getString("spsyskey").toString()}"});

  print(param);

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      if (extdata["status"] == "SUCCESS") {
        getDelAmtSummary = extdata["list"];
        check = "success";
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future voidDelivery() async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url =
      '$domain' + 'order/void/${preferences.getString("orderdetailSyskey")}';

  print(url);

  final response = await http
      .get(Uri.encodeFull(url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      print(json.decode(response.body));
      var extdata = json.decode(response.body);
      if (extdata["status"] == "SUCCESS") {
        return check = "success";
      } else if (extdata["status"] == "invalid order"){
        return check = "success";
      }else {
        return check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
    print(check);
  }
  return check;
}

Future getvoidlist(var shopCode) async {
  datetime();
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'order/getvoidlist';

  var param =
      jsonEncode({"shopcode": "$shopCode", "date": "$date", "syskey": ""});

  print(param);

  voidList = [];

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      if (extdata["status"] == "SUCCESS") {
        // getinvoiceOrderlist = extdata["list"][i]["stockByBrand"];

        if (extdata["list"].length == 0) {
          check = "success";
        }

        for (var i = 0; i < extdata["list"].length; i++) {
          deliveryDate = extdata["list"][i]["time"];
          sysKey = extdata["list"][i]["syskey"];
          voidList.add({
            "syskey": extdata["list"][i]["syskey"],
            "date": extdata["list"][i]["docummentDate"]
          });

          if (i == extdata["list"].length - 1) {
            check = "success";
            
          }
        }
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getvoidlistData(var shopCode, String sysKey) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'order/getvoidlist';

  datetime();

  var param =
      jsonEncode({"shopcode": "$shopCode", "date": "$date", "syskey": ""});

  voidList = [];

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      if (extdata["status"] == "SUCCESS") {
        List data = [];

        if (extdata["list"].length == 0) {
          check = "success";
        }

        data = extdata["list"].where((val) => val["syskey"] == sysKey).toList();

        if (data.length == 0) {
          check = "success";
        }

        for (var i = 0; i < data.length; i++) {
          voidListData = data[i]["stockByBrand"];

          if (i == data.length - 1) {
            check = "success";
            
          }
        }
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getMerchandizingImageOnline(var shopCode) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'campaign/getMerchandising';

  datetime();

  merchandizingImage = [];

  var param = jsonEncode({
    "shopSyskey": "$shopCode",
    "userSyskey": "${preferences.getString("spsyskey").toString()}",
    "date": "$date"
  });

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      if (extdata["status"] == "SUCCESS") {
        if (extdata["list"].length == 0) {
          check = "success";
        }
        for (var a = 0; a < extdata["list"].length; a++) {
          if (extdata["list"][a]["mc002"].length == 0) {
            check = "success";
          }
          for (var b = 0; b < extdata["list"][a]["mc002"].length; b++) {
            if (extdata["list"][a]["mc002"][b]["mc003"].length == 0) {
              check = "success";
            }
            for (var c = 0;
                c < extdata["list"][a]["mc002"][b]["mc003"].length;
                c++) {
              if (extdata["list"][a]["mc002"][b]["mc003"][c]["pictureData"]
                      .length ==
                  0) {
                check = "success";
              }
              for (var d = 0;
                  d <
                      extdata["list"][a]["mc002"][b]["mc003"][c]["pictureData"]
                          .length;
                  d++) {
                merchandizingImage.add({
                  "taskSyskey": extdata["list"][a]["mc002"][b]["mc003"][c]
                      ["taskSyskey"],
                  "imagePath":
                      "${domain.substring(0, domain.lastIndexOf("madbrepository/"))}${extdata["list"][a]["mc002"][b]["mc003"][c]["pictureData"][d]["filePath"]}"
                });

                if (a == extdata["list"].length - 1) {
                  if (b == extdata["list"][a]["mc002"].length - 1) {
                    if (c ==
                        extdata["list"][a]["mc002"][b]["mc003"].length - 1) {
                      if (d ==
                          extdata["list"][a]["mc002"][b]["mc003"][c]
                                      ["pictureData"]
                                  .length -
                              1) {
                        check = "success";
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getVolDisDataForMobile(String shopSyskey) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'PromoAndDiscount/getVolDisDataForMobile';
  datetime();

  var param = jsonEncode({"shopSyskey": "$shopSyskey"});

  discountDataList = [];

  discountStockList = [];
  disCategoryList = [];

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      if (extdata["status"] == "SUCCESS") {
        if (extdata["list"].length == 0) {
          check = "success";
        } else {
          if (extdata["list"].length == 0) {
            check = "success";
          } else {
            List volDisDtlDataList = extdata["list"];

            List disData = [];

            List disCategory = [];

            for (var i = 0; i < volDisDtlDataList.length; i++) {
              disCategory.add({
                "categoryCode" : volDisDtlDataList[i]["code"],
                "categoryCodeDesc" : volDisDtlDataList[i]["description"],
                "hdrSyskey" : volDisDtlDataList[i]["syskey"],
                "choose" : false,
                "list" : volDisDtlDataList[i]["volDisDtlDataList"]
              });
              if(volDisDtlDataList[i]["volDisDtlDataList"].length == 0) {
                check = "success";
              }
              for(var a = 0 ; a < volDisDtlDataList[i]["volDisDtlDataList"].length; a++) {
                if(disData.length == 0) {
                  disData.add({
                    "stockSyskey": volDisDtlDataList[i]["volDisDtlDataList"][a]["promoItemSyskey"],
                    "createddate" : date
                  });
                } else {
                  if(disData.where((element) => element["stockSyskey"] == volDisDtlDataList[i]["volDisDtlDataList"][a]["promoItemSyskey"]).toList().length == 0) {
                    disData.add({
                      "stockSyskey": volDisDtlDataList[i]["volDisDtlDataList"][a]["promoItemSyskey"],
                      "createddate" : date
                    });
                  }
                }
                
                
                if (i == volDisDtlDataList.length - 1) {
                  if(a == volDisDtlDataList[i]["volDisDtlDataList"].length-1) {
                    check = "success";
                    discountStockList = disData.toSet().toList();
                    disCategoryList = disCategory.toSet().toList();
                    print(discountStockList);
                  }
                }
              }
              
            }
          }
        }
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

List discountStockListDate = [];

Future getVolDisDataForMobileDate(String shopSyskey, String createddate) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'PromoAndDiscount/getVolDisDataForMobile';
  datetime();

  var param = jsonEncode({"shopSyskey": "$shopSyskey", "date" : "$createddate"});

  discountStockListDate = [];

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      if (extdata["status"] == "SUCCESS") {
        if (extdata["list"].length == 0) {
          check = "success";
        } else {
          if (extdata["list"].length == 0) {
            check = "success";
          } else {
            List volDisDtlDataList = extdata["list"];

            List disData = [];

            for (var i = 0; i < volDisDtlDataList.length; i++) {
              if(volDisDtlDataList[i]["volDisDtlDataList"].length == 0) {
                check = "success";
              }
              for(var a = 0 ; a < volDisDtlDataList[i]["volDisDtlDataList"].length; a++) {
                if(disData.length == 0) {
                  disData.add({
                    "stockSyskey": volDisDtlDataList[i]["volDisDtlDataList"][a]["promoItemSyskey"],
                    "createddate" : createddate
                  });
                } else {
                  if(disData.where((element) => element["stockSyskey"] == volDisDtlDataList[i]["volDisDtlDataList"][a]["promoItemSyskey"]).toList().length == 0) {
                    disData.add({
                      "stockSyskey": volDisDtlDataList[i]["volDisDtlDataList"][a]["promoItemSyskey"],
                      "createddate" : createddate
                    });
                  }
                }
                
                if (i == volDisDtlDataList.length - 1) {
                  if(a == volDisDtlDataList[i]["volDisDtlDataList"].length-1) {
                    discountStockListDate = disData;
                    check = "success";
                    print(discountStockListDate);
                  }
                }
              }
            }
          }
        }
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getVolDisCalculation(var param, var stockList, context, bool singleRuleOneMoreStock) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'PromoAndDiscount/getVolDisCalculation';

  // final url = 'http://52.255.142.115:8084/madbrepositorydev/PromoAndDiscount/getVolDisCalculation';

  datetime();

  print(param);

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      if (extdata["status"] == "Promotion Available") {
        if(extdata["data"] == "") {
          check = "success";
        }else if(stockList.length == 0) {
          check = "success";
        }else {
          discountDataList = [];
          // if(discountDataList.length == 0) {
            discountDataList.add(extdata["data"]);
          // }else {
          //   if(discountDataList.where((element) => element["itemSyskey"] == extdata["data"]["itemSyskey"]).toList().length != 0) {
          //     discountDataList.removeWhere((element) => element["itemSyskey"].toString() == extdata["data"]["itemSyskey"].toString());
          //   }
          //   discountDataList.add(extdata["data"]);
          // }

          // print("savedList ==> ${json.decode(preferences.getString("discountDataList"))}");

          if(singleRuleOneMoreStock == true) {
            if(preferences.getString("discountDataList") != null) {
              discountDataList = discountDataList + json.decode(preferences.getString("discountDataList"));
            }
            preferences.setString("discountDataList", json.encode(discountDataList));
          } else {
            preferences.setString("discountDataList", null);
          }

          List multiGiftList = [];
          List multiStockList = [];

          print("discountDataList ==> ${discountDataList.toString()}");

          if(singleRuleOneMoreStock == false) {

          for(var i = 0; i < discountDataList.length; i++) {

      if(discountDataList[i]["giftList"].length == 0) {
        if(getdeliverylist == [] || getdeliverylist.length == 0) {
          for(var a = 0; a < stockByBrandDel.length; a++) {
            for(var b = 0; b < stockByBrandDel[a]["stockData"].length; b++) {
              if(stockByBrandDel[a]["stockData"][b]["stockSyskey"] == discountDataList[i]["itemSyskey"]) {
                if(stockByBrandDel[a]["stockData"][b]["promotionStockList"].length != 0) {
                  for(var c = 0; c < stockByBrandDel[a]["stockData"][b]["promotionStockList"].length; c++) {
                    stockByBrandDel[a]["stockData"][b]["promotionStockList"][c]["recordStatus"] = 4;
                  }
                }
              }
            }
          }
        } else {
          for(var a = 0; a < getdeliverylist.length; a++) {
            for(var b = 0; b < getdeliverylist[a]["stockData"].length; b++) {
              if(getdeliverylist[a]["stockData"][b]["stockSyskey"] == discountDataList[i]["itemSyskey"]) {
                if(getdeliverylist[a]["stockData"][b]["promotionStockList"].length != 0) {
                  for(var c = 0; c < getdeliverylist[a]["stockData"][b]["promotionStockList"].length; c++) {
                    getdeliverylist[a]["stockData"][b]["promotionStockList"][c]["recordStatus"] = 4;
                  }
                }
              }
            }
          }
        }

        for(var a = 0; a < stockList.length; a++) {
          if(stockList[a]["stockSyskey"] == discountDataList[i]["itemSyskey"]) {
            if(stockList[a]["promotionStockList"].length != 0) {
              for(var c = 0; c < stockList[a]["promotionStockList"].length; c++) {
                stockList[a]["promotionStockList"][c]["recordStatus"] = 4;
              }
            }
          }
        }
      }

      if(discountDataList[i]["giftList"].length != 0) {

        if(discountDataList[i]["giftList"].where((element) => element.length != 1).toList().length != 0) {
          print("multiGift ===============================>");
          multiGiftList.add(
            {
              "giftInfoList" : discountDataList[i]["giftList"],
              "stockList" : ["${discountDataList[i]["itemSyskey"]}"],
              "discountDetailSyskey" : discountDataList[i]["discountDetailSyskey"],
              "giftQty" : 0.0
            }
          );
          multiStockList.add(
            {
              "itemSyskey" : discountDataList[i]["itemSyskey"],
              "itemDesc" : discountDataList[i]["itemDesc"]
            }
          );
          if(i == discountDataList.length-1) {

            print("multiGiftList ==> ${multiGiftList.length}");

            final rtnMultiGiftList = await showMultiGiftDialog(multiGiftList, multiStockList, context);

            print("rtnMultiGiftList ==> $rtnMultiGiftList");

              for(var n = 0; n < rtnMultiGiftList.length; n++) {
                List promotionStockList = [];
                for(var j = 0; j < rtnMultiGiftList[n]["giftInfoList"].length; j++) {
                  promotionStockList.add({
                    "syskey" : '0',
	                  "recordStatus": 1,
	                  "stockCode": rtnMultiGiftList[n]["giftInfoList"][j][0]["discountStockCode"].toString() == "null" || rtnMultiGiftList[n]["giftInfoList"][j][0]["discountStockCode"].toString() == "" ? "0" :
                                   '${rtnMultiGiftList[n]["giftInfoList"][j][0]["discountStockCode"]}',
	                  "stockName": '${rtnMultiGiftList[n]["giftInfoList"][j][0]["discountItemDesc"]}',
	                  "stockSyskey": rtnMultiGiftList[n]["giftInfoList"][j][0]["discountStockSyskey"] == null || rtnMultiGiftList[n]["giftInfoList"][j][0]["discountStockSyskey"] == "" ? "0" : '${rtnMultiGiftList[n]["giftInfoList"][j][0]["discountStockSyskey"]}',
	                  "promoStockSyskey": rtnMultiGiftList[n]["giftInfoList"][j][0]["discountItemSyskey"] == null || rtnMultiGiftList[n]["giftInfoList"][j][0]["discountItemSyskey"] == "" ? "0" : '${rtnMultiGiftList[n]["giftInfoList"][j][0]["discountItemSyskey"]}',
	                  "qty": rtnMultiGiftList[n]["giftInfoList"][j][0]["discountItemQty"],
	                  "promoStockType": '${rtnMultiGiftList[n]["giftInfoList"][j][0]["discountItemType"]}'
                  });

                  // if(n == rtnMultiGiftList.length -1) {

                  if(j == rtnMultiGiftList[n]["giftInfoList"].length-1) {

                    print("promotionStockList ==> $promotionStockList");

                    if(getdeliverylist == [] || getdeliverylist.length == 0) {
                      for(var a = 0; a < stockByBrandDel.length; a++) {
                        for(var b = 0; b < stockByBrandDel[a]["stockData"].length; b++) {

                          if(stockByBrandDel[a]["stockData"][b]["stockSyskey"] == rtnMultiGiftList[n]["stockList"][0]) {
                            if(stockByBrandDel[a]["stockData"][b]["promotionStockList"].length != 0) {
                              // change recordStatus to 4
                              for(var c = 0; c < stockByBrandDel[a]["stockData"][b]["promotionStockList"].length; c++) {
                                stockByBrandDel[a]["stockData"][b]["promotionStockList"][c]["recordStatus"] = 4;
                              }
                            }

                            for(var l = 0; l < promotionStockList.length; l++) {
                            promotionStockList[l]["recordStatus"] = 1;
                            if(stockByBrandDel[a]["stockData"][b]["promotionStockList"].where((element) => element["promoStockSyskey"] == promotionStockList[l]["promoStockSyskey"] && element["recordStatus"] == 1).toList().length != 0) {
                              // when return same gift, removewhere data from list and add new gift data
                              stockByBrandDel[a]["stockData"][b]["promotionStockList"].removeWhere((element) => element["promoStockSyskey"] == promotionStockList[l]["promoStockSyskey"] && element["recordStatus"] == 1);
                              stockByBrandDel[a]["stockData"][b]["promotionStockList"].add(promotionStockList[l]);
                            
                            }else {
                            // return different gift
                              stockByBrandDel[a]["stockData"][b]["promotionStockList"].add(promotionStockList[l]);
                            }
                          }
                        }
                      }
                    }
                  }else {
                    for(var a = 0; a < getdeliverylist.length; a++) {
                      for(var b = 0; b < getdeliverylist[a]["stockData"].length; b++) {
                        
                        if(getdeliverylist[a]["stockData"][b]["stockSyskey"] == rtnMultiGiftList[n]["stockList"][0]) {
                          if(getdeliverylist[a]["stockData"][b]["promotionStockList"].length != 0) {
                            // change recordStatus to 4
                            for(var c = 0; c < getdeliverylist[a]["stockData"][b]["promotionStockList"].length; c++) {
                              getdeliverylist[a]["stockData"][b]["promotionStockList"][c]["recordStatus"] = 4;
                            }
                          }

                          for(var l = 0; l < promotionStockList.length; l++) {
                            promotionStockList[l]["recordStatus"] = 1;
                            if(getdeliverylist[a]["stockData"][b]["promotionStockList"].where((element) => element["promoStockSyskey"] == promotionStockList[l]["promoStockSyskey"] && element["recordStatus"] == 1).toList().length == 0) {
                              // return different gift
                              getdeliverylist[a]["stockData"][b]["promotionStockList"].add(promotionStockList[l]);
                            } else {
                              // when return same gift, removewhere data from list and add new gift data
                              getdeliverylist[a]["stockData"][b]["promotionStockList"].removeWhere((element) => element["promoStockSyskey"] == promotionStockList[l]["promoStockSyskey"] && element["recordStatus"] == 1);
                              getdeliverylist[a]["stockData"][b]["promotionStockList"].add(promotionStockList[l]);
                            }
                          }
                        }
                      }
                    }
                  }

                  

                  for(var a = 0; a < stockList.length; a++) {

                    if(stockList[a]["stockSyskey"] == rtnMultiGiftList[n]["stockList"][0]) {

                      if(stockList[a]["promotionStockList"].length != 0) {
                        // change recordStatus to 4
                        for(var c = 0; c < stockList[a]["promotionStockList"].length; c++) {
                          stockList[a]["promotionStockList"][c]["recordStatus"] = 4;
                        }
                      }

                      for(var l = 0; l < promotionStockList.length; l++) {
                        promotionStockList[l]["recordStatus"] = 1;
                        if(stockList[a]["promotionStockList"].where((element) => element["promoStockSyskey"] == promotionStockList[l]["promoStockSyskey"] && element["recordStatus"] == 1).toList().length == 0) {
                          // return different gift
                          stockList[a]["promotionStockList"].add(promotionStockList[l]);
                        }else {
                          // when return same gift, removewhere data from list and add new gift data
                          stockList[a]["promotionStockList"].removeWhere((element) => element["promoStockSyskey"] == promotionStockList[l]["promoStockSyskey"] && element["recordStatus"] == 1);
                          stockList[a]["promotionStockList"].add(promotionStockList[l]);
                        }
                      }

                    if(a == stockList.length-1) {
                      if(n == rtnMultiGiftList.length -1) {
                        newStockList = stockList;
                        print("newStockList ==> ${newStockList[0]["promotionStockList"].length}");
                        for(var xiao = 0; xiao < newStockList[0]["promotionStockList"].length; xiao++) {
                          print(newStockList[0]["promotionStockList"][xiao]);
                        }
                        check = "success";
                      }
                    }
                  }

                }

              }
                 
            }
          }
        }
      } else {
        for(var j = 0; j < discountDataList[i]["giftList"].length; j++) {
          for(var k = 0; k < discountDataList[i]["giftList"][j].length; k++) {

            if(getdeliverylist == [] || getdeliverylist.length == 0) {
              for(var a = 0; a < stockByBrandDel.length; a++) {
                for(var b = 0; b < stockByBrandDel[a]["stockData"].length; b++) {

                  if(stockByBrandDel[a]["stockData"][b]["stockSyskey"] == discountDataList[i]["itemSyskey"]) {
                    if(stockByBrandDel[a]["stockData"][b]["promotionStockList"].length != 0) {
                      // change recordStatus to 4
                      for(var c = 0; c < stockByBrandDel[a]["stockData"][b]["promotionStockList"].length; c++) {
                        stockByBrandDel[a]["stockData"][b]["promotionStockList"][c]["recordStatus"] = 4;
                      }
                          
                    }
                    if(stockByBrandDel[a]["stockData"][b]["promotionStockList"].where((element) => element["promoStockSyskey"] == discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] && element["recordStatus"] == 1).toList().length != 0) {
                      // when return same gift, removewhere data from list and add new gift data
                      stockByBrandDel[a]["stockData"][b]["promotionStockList"].removeWhere((element) => element["promoStockSyskey"] == discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] && element["recordStatus"] == 1);
                      stockByBrandDel[a]["stockData"][b]["promotionStockList"].add({
                        "syskey" : '0',
	                      "recordStatus": 1,
	                      "stockCode": discountDataList[i]["giftList"][j][k]["discountStockCode"].toString() == "null" || discountDataList[i]["giftList"][j][k]["discountStockCode"].toString() == "" ? "0" :
                                       '${discountDataList[i]["giftList"][j][k]["discountStockCode"]}',
	                      "stockName": '${discountDataList[i]["giftList"][j][k]["discountItemDesc"]}',
	                      "stockSyskey": discountDataList[i]["giftList"][j][k]["discountStockSyskey"] == null || discountDataList[i]["giftList"][j][k]["discountStockSyskey"] == "" ? "0" : '${discountDataList[i]["giftList"][j][k]["discountStockSyskey"]}',
	                      "promoStockSyskey": discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] == null || discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] == "" ? "0" : '${discountDataList[i]["giftList"][j][k]["discountDetailSyskey"]}',
	                      "qty": discountDataList[i]["giftList"][j][k]["discountItemQty"],
	                      "promoStockType": '${discountDataList[i]["giftList"][j][k]["discountItemType"]}'
                      });
                    }else {
                      // return different gift
                      stockByBrandDel[a]["stockData"][b]["promotionStockList"].add({
                        // "syskey" : '${discountDataList[i]["itemSyskey"]}',
                        "syskey" : '0',
	                      "recordStatus": 1,
	                      "stockCode": discountDataList[i]["giftList"][j][k]["discountStockCode"].toString() == "null" || discountDataList[i]["giftList"][j][k]["discountStockCode"] == "" ? "0" :
                                       '${discountDataList[i]["giftList"][j][k]["discountStockCode"]}',
	                      "stockName": '${discountDataList[i]["giftList"][j][k]["discountItemDesc"]}',
	                      "stockSyskey": discountDataList[i]["giftList"][j][k]["discountStockSyskey"] == null || discountDataList[i]["giftList"][j][k]["discountStockSyskey"] == "" ? "0" : '${discountDataList[i]["giftList"][j][k]["discountStockSyskey"]}',
	                      "promoStockSyskey": discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] == null || discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] == "" ? "0" : '${discountDataList[i]["giftList"][j][k]["discountDetailSyskey"]}',
	                      "qty": discountDataList[i]["giftList"][j][k]["discountItemQty"],
	                      "promoStockType": '${discountDataList[i]["giftList"][j][k]["discountItemType"]}'
                      });
                    }
                  }
                }
              }
            }else {
              for(var a = 0; a < getdeliverylist.length; a++) {
                for(var b = 0; b < getdeliverylist[a]["stockData"].length; b++) {

                  if(getdeliverylist[a]["stockData"][b]["stockSyskey"] == discountDataList[i]["itemSyskey"]) {
                    if(getdeliverylist[a]["stockData"][b]["promotionStockList"].length != 0) {
                      // change recordStatus to 4
                      for(var c = 0; c < getdeliverylist[a]["stockData"][b]["promotionStockList"].length; c++) {
                        getdeliverylist[a]["stockData"][b]["promotionStockList"][c]["recordStatus"] = 4;
                      }
                    }

                    if(getdeliverylist[a]["stockData"][b]["promotionStockList"].where((element) => element["promoStockSyskey"] == discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] && element["recordStatus"] == 1).toList().length == 0) {
                      // return different gift
                      getdeliverylist[a]["stockData"][b]["promotionStockList"].add({
                        // "syskey" : '${discountDataList[i]["itemSyskey"]}',
                        "syskey" : '0',
	                      "recordStatus": 1,
	                      "stockCode": discountDataList[i]["giftList"][j][k]["discountStockCode"].toString() == "null" || discountDataList[i]["giftList"][j][k]["discountStockCode"] == "" ? "0" :
                                       '${discountDataList[i]["giftList"][j][k]["discountStockCode"]}',
	                      "stockName": '${discountDataList[i]["giftList"][j][k]["discountItemDesc"]}',
	                      "stockSyskey": discountDataList[i]["giftList"][j][k]["discountStockSyskey"] == null || discountDataList[i]["giftList"][j][k]["discountStockSyskey"] == "" ? "0" : '${discountDataList[i]["giftList"][j][k]["discountStockSyskey"]}',
	                      "promoStockSyskey": discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] == null || discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] == "" ? "0" : '${discountDataList[i]["giftList"][j][k]["discountDetailSyskey"]}',
	                      "qty": discountDataList[i]["giftList"][j][k]["discountItemQty"],
	                      "promoStockType": '${discountDataList[i]["giftList"][j][k]["discountItemType"]}'
                      });
                    } else {
                      // when return same gift, removewhere data from list and add new gift data
                      getdeliverylist[a]["stockData"][b]["promotionStockList"].removeWhere((element) => element["promoStockSyskey"] == discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] && element["recordStatus"] == 1);
                      getdeliverylist[a]["stockData"][b]["promotionStockList"].add({
                        // "syskey" : '${discountDataList[i]["itemSyskey"]}',
                        "syskey" : '0',
	                      "recordStatus": 1,
	                      "stockCode": discountDataList[i]["giftList"][j][k]["discountStockCode"].toString() == "null" || discountDataList[i]["giftList"][j][k]["discountStockCode"] == "" ? "0" :
                                       '${discountDataList[i]["giftList"][j][k]["discountStockCode"]}',
	                      "stockName": '${discountDataList[i]["giftList"][j][k]["discountItemDesc"]}',
	                      "stockSyskey": discountDataList[i]["giftList"][j][k]["discountStockSyskey"] == null || discountDataList[i]["giftList"][j][k]["discountStockSyskey"] == "" ? "0" : '${discountDataList[i]["giftList"][j][k]["discountStockSyskey"]}',
	                      "promoStockSyskey": discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] == null || discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] == "" ? "0" : '${discountDataList[i]["giftList"][j][k]["discountDetailSyskey"]}',
	                      "qty": discountDataList[i]["giftList"][j][k]["discountItemQty"],
	                      "promoStockType": '${discountDataList[i]["giftList"][j][k]["discountItemType"]}'
                      });
                    }
                        
                  }
                }
              }
            }

                

            for(var a = 0; a < stockList.length; a++) {

              if(stockList[a]["stockSyskey"] == discountDataList[i]["itemSyskey"]) {
                if(stockList[a]["promotionStockList"].length != 0) {
                  // change recordStatus to 4
                  for(var c = 0; c < stockList[a]["promotionStockList"].length; c++) {
                    stockList[a]["promotionStockList"][c]["recordStatus"] = 4;
                  }
                }
                if(stockList[a]["promotionStockList"].where((element) => element["promoStockSyskey"] == discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] && element["recordStatus"] == 1).toList().length == 0) {
                  // return different gift
                  stockList[a]["promotionStockList"].add({
                    // "syskey" : '${discountDataList[i]["itemSyskey"]}',
                    "syskey" : '0',
	                  "recordStatus": 1,
	                  "stockCode": discountDataList[i]["giftList"][j][k]["discountStockCode"].toString() == "null" || discountDataList[i]["giftList"][j][k]["discountStockCode"] == "" ? "0" :
                                   '${discountDataList[i]["giftList"][j][k]["discountStockCode"]}',
	                  "stockName": '${discountDataList[i]["giftList"][j][k]["discountItemDesc"]}',
	                  "stockSyskey": discountDataList[i]["giftList"][j][k]["discountStockSyskey"] == null || discountDataList[i]["giftList"][j][k]["discountStockSyskey"] == "" ? "0" : '${discountDataList[i]["giftList"][j][k]["discountStockSyskey"]}',
	                  "promoStockSyskey": discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] ==null || discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] == "" ? "0" : '${discountDataList[i]["giftList"][j][k]["discountDetailSyskey"]}',
	                  "qty": discountDataList[i]["giftList"][j][k]["discountItemQty"],
	                  "promoStockType": '${discountDataList[i]["giftList"][j][k]["discountItemType"]}'
                  });
                }else {
                  // when return same gift, removewhere data from list and add new gift data
                  stockList[a]["promotionStockList"].removeWhere((element) => element["promoStockSyskey"] == discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] && element["recordStatus"] == 1);
                  stockList[a]["promotionStockList"].add({
                    // "syskey" : '${discountDataList[i]["itemSyskey"]}',
                    "syskey" : '0',
	                  "recordStatus": 1,
	                  "stockCode": discountDataList[i]["giftList"][j][k]["discountStockCode"].toString() == "null" || discountDataList[i]["giftList"][j][k]["discountStockCode"] == "" ? "0" :
                                   '${discountDataList[i]["giftList"][j][k]["discountStockCode"]}',
	                  "stockName": '${discountDataList[i]["giftList"][j][k]["discountItemDesc"]}',
	                  "stockSyskey": discountDataList[i]["giftList"][j][k]["discountStockSyskey"] == null || discountDataList[i]["giftList"][j][k]["discountStockSyskey"] == "" ? "0" : '${discountDataList[i]["giftList"][j][k]["discountStockSyskey"]}',
	                  "promoStockSyskey": discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] ==null || discountDataList[i]["giftList"][j][k]["discountDetailSyskey"] == "" ? "0" : '${discountDataList[i]["giftList"][j][k]["discountDetailSyskey"]}',
	                  "qty": discountDataList[i]["giftList"][j][k]["discountItemQty"],
	                  "promoStockType": '${discountDataList[i]["giftList"][j][k]["discountItemType"]}'
                  });
                }
                      
              }

              if(a == stockList.length-1) {
                if(j == discountDataList[i]["giftList"].length-1) {
                  if(k == discountDataList[i]["giftList"][j].length) {
                    if(i == discountDataList.length-1) {
                      newStockList = stockList;
                      check = "success";
                    }
                  }
                }
              }
            }
          }
        }
      }

              
    }
    // gift list is empty or return discount
    print("One");
    if(getdeliverylist == [] || getdeliverylist.length == 0) {
      for(var a = 0; a < stockByBrandDel.length; a++) {
        for(var b = 0; b < stockByBrandDel[a]["stockData"].length; b++) {

          if(stockByBrandDel[a]["stockData"][b]["stockSyskey"] == discountDataList[i]["itemSyskey"]) {
            stockByBrandDel[a]["stockData"][b]["discountAmount"] = discountDataList[i]["beforeDiscountTotal"] * (discountDataList[i]["discountPercent"] / 100.0);
            stockByBrandDel[a]["stockData"][b]["discountPercent"] = discountDataList[i]["discountPercent"];

            for(var c = 0; c < stockList.length; c++) {
              if(stockList[c]["stockSyskey"] == discountDataList[i]["itemSyskey"]) {
                stockByBrandDel[a]["stockData"][b]["qty"] = stockList[c]["qty"].toDouble();
              }
            }
                        
            stockByBrandDel[a]["stockData"][b]["discountAmount"] = stockByBrandDel[a]["stockData"][b]["discountAmount"].toInt();
            // stockByBrandDel[a]["stockData"][b]["qty"] = discountDataList[i]["qty"];

            if(discountDataList[i]["discountPercent"].toString() != "0.0") {
              stockByBrandDel[a]["stockData"][b]["totalAmount"] = (stockByBrandDel[a]["stockData"][b]["normalPrice"] * ((100 - discountDataList[i]["discountPercent"]) / 100)) * stockByBrandDel[a]["stockData"][b]["qty"];
              stockByBrandDel[a]["stockData"][b]["price"] = stockByBrandDel[a]["stockData"][b]["normalPrice"] * ((100 - discountDataList[i]["discountPercent"]) / 100);
              stockByBrandDel[a]["stockData"][b]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == stockByBrandDel[a]["stockData"][b]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];
            }

                        
          }
        }
      }

    }else {
      print("Two");
      for(var a = 0; a < getdeliverylist.length; a++) {
        print("Three");
        for(var b = 0; b < getdeliverylist[a]["stockData"].length; b++) {

          print('Four');

          if(getdeliverylist[a]["stockData"][b]["stockSyskey"] == discountDataList[i]["itemSyskey"]) {
            getdeliverylist[a]["stockData"][b]["discountAmount"] = discountDataList[i]["beforeDiscountTotal"] * (discountDataList[i]["discountPercent"] / 100.0);
            getdeliverylist[a]["stockData"][b]["discountPercent"] = discountDataList[i]["discountPercent"];

            getdeliverylist[a]["stockData"][b]["discountAmount"] = getdeliverylist[a]["stockData"][b]["discountAmount"].toInt();
            for(var c = 0; c < stockList.length; c++) {
              if(stockList[c]["stockSyskey"] == discountDataList[i]["itemSyskey"]) {
                getdeliverylist[a]["stockData"][b]["qty"] = stockList[c]["qty"].toDouble();

                print(getdeliverylist[a]["stockData"][b]["qty"]);
              }
            }
                        
            if(discountDataList[i]["discountPercent"].toString() != "0.0") {
              getdeliverylist[a]["stockData"][b]["totalAmount"] = (getdeliverylist[a]["stockData"][b]["normalPrice"] * ((100 - discountDataList[i]["discountPercent"]) / 100)) * getdeliverylist[a]["stockData"][b]["qty"];
              getdeliverylist[a]["stockData"][b]["price"] = getdeliverylist[a]["stockData"][b]["normalPrice"] * ((100 - discountDataList[i]["discountPercent"]) / 100);
              getdeliverylist[a]["stockData"][b]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == getdeliverylist[a]["stockData"][b]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];
            }
            
          }

        }

        print(getdeliverylist[a]["stockData"]);
      }

    }

    if(stockList.length == 0) {
      check = "success";
    }

    for(var a = 0; a < stockList.length; a++) {
      print("Five");
      if(stockList[a]["stockSyskey"] == discountDataList[i]["itemSyskey"]) {
        print("Six");
        stockList[a]["discountAmount"] = discountDataList[i]["beforeDiscountTotal"] * (discountDataList[i]["discountPercent"] / 100);
        stockList[a]["discountPercent"] = discountDataList[i]["discountPercent"];
        if(discountDataList[i]["discountPercent"].toString() != "0.0") {
          stockList[a]["totalAmount"] = (stockList[a]["normalPrice"] * ((100 - discountDataList[i]["discountPercent"]) / 100)) * stockList[a]["qty"];
          stockList[a]["price"] = stockList[a]["normalPrice"] * ((100 - discountDataList[i]["discountPercent"]) / 100);
          stockList[a]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == stockList[a]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];
        }
                      

        stockList[a]["discountAmount"] = stockList[a]["discountAmount"].toInt();

        print("Seven");
      }

      if(a == stockList.length-1) {
        if(i == discountDataList.length-1) {
          newStockList = stockList;
          check = "success";
        }
      }
    }
    }
          } else {
            check = "success";
          }
        }
        
      } else if(extdata["status"] == "FAIL") {
        check = "fail";
      }else {
        check = extdata["status"];
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future multiDiscountCalculation(var param, var stockList, context) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'PromoAndDiscount/getVolDisMultiRuleCalculation';
  // final url = 'http://52.253.88.71:8084/madbrepositorydev/PromoAndDiscount/getVolDisMultiRuleCalculation';
  datetime();
  print(param);

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      if (extdata["status"] == "SUCCESS") {
        if(extdata["data"] == "") {
          check = "success";
        }else {
          List discountStockList = extdata["data"]["getPromoStockList"];
          List giftList = extdata["data"]["giftList"];

          List itemInfoList = json.decode(param)["itemInfoList"];

          List itemList = [];

          for(var aa = 0; aa< itemInfoList.length; aa++) {
            if(itemList.length == 0) {
              itemList.add({
                "itemSyskey": itemInfoList[aa]["itemSyskey"],
                "itemDesc": itemInfoList[aa]["itemDesc"],
                "itemAmount": itemInfoList[aa]["itemAmount"],
                "itemTotalAmount": itemInfoList[aa]["itemTotalAmount"],
                "itemQty": itemInfoList[aa]["itemQty"]
              });
            } else if(itemList.where((element) => element["itemSyskey"] == itemInfoList[aa]["itemSyskey"]).toList().length == 0) {
              itemList.add({
                "itemSyskey": itemInfoList[aa]["itemSyskey"],
                "itemDesc": itemInfoList[aa]["itemDesc"],
                "itemAmount": itemInfoList[aa]["itemAmount"],
                "itemTotalAmount": itemInfoList[aa]["itemTotalAmount"],
                "itemQty": itemInfoList[aa]["itemQty"]
              });
            }
            
          }

          List changeList = [];

          for(var a = 0; a < itemList.length; a++) {
            if(getdeliverylist.length == 0) {
              for(var b = 0; b < stockByBrandDel.length; b++) {
                if(stockByBrandDel[b]["stockData"].where((element) => element["stockSyskey"] == itemList[a]["itemSyskey"]).toList().length != 0) {
                  changeList = changeList + stockByBrandDel[b]["stockData"].where((element) => element["stockSyskey"] == itemList[a]["itemSyskey"]).toList();
                }
              }
            } else {
              for(var b = 0; b < getdeliverylist.length; b++) {
                if(getdeliverylist[b]["stockData"].where((element) => element["stockSyskey"] == itemList[a]["itemSyskey"]).toList().length != 0) {
                  changeList = changeList + getdeliverylist[b]["stockData"].where((element) => element["stockSyskey"] == itemList[a]["itemSyskey"]).toList();
                }
              }
            }
          }

          for(var a = 0; a < changeList.length; a++) {
            changeList[a]["discountAmount"] = 0.0;
            changeList[a]["discountPercent"] = 0.0;
            changeList[a]["totalAmount"] = changeList[a]["normalPrice"] * changeList[a]["qty"];
            changeList[a]["price"] = changeList[a]["normalPrice"];
            changeList[a]["promoDetailSyskey"] = "0";
          }

          for(var a = 0; a < discountStockList.length; a++) {
            for(var b = 0; b < changeList.length; b++) {
              if(changeList[b]["stockSyskey"] == discountStockList[a]["itemSyskey"]) {
                changeList[b]["discountAmount"] = discountStockList[a]["beforeDiscountTotal"] * (discountStockList[a]["discountPercent"] / 100.0);
                changeList[b]["discountPercent"] = discountStockList[a]["discountPercent"];

                for(var d = 0; d < stockList.length; d++) {
                  if(stockList[d]["stockSyskey"] == discountStockList[a]["itemSyskey"]) {
                    changeList[b]["qty"] = stockList[d]["qty"].toDouble();
                  }
                }

                if(discountStockList[a]["discountPercent"].toString() != "0.0") {
                  changeList[b]["totalAmount"] = (changeList[b]["normalPrice"] * ((100 - discountStockList[a]["discountPercent"]) / 100)) * changeList[b]["qty"];
                  changeList[b]["price"] = changeList[b]["normalPrice"] * ((100 - discountStockList[a]["discountPercent"]) / 100);
                  changeList[b]["promoDetailSyskey"] = discountStockList.where((element) => element["itemSyskey"].toString() == changeList[b]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];
                }
              }
            }
          }

          for(var a = 0; a < changeList.length; a++) {
            for(var b = 0; b < changeList[a]["promotionStockList"].length; b++) {
              changeList[a]["promotionStockList"][b]["recordStatus"] = 4;
            }
          }


          print("aa");

          List multiGiftList = giftList.where((element) => element["giftInfoList"].where((element) => element.length != 1).toList().length != 0).toList();

          print("bb");
          
          List singleGiftList = giftList.where((element) => element["giftInfoList"].where((element) => element.length != 1).toList().length == 0).toList();
          
          print("cc");
          
          if (multiGiftList.length != 0) {
            preferences.setString("GiftList", json.encode(multiGiftList));

            print("dd");

            List arrangeList = [];
            for(var l = 0; l < multiGiftList.length; l++) {
              arrangeList.add({
                "giftInfoList" : multiGiftList[l]["giftInfoList"],
                "stockList" : multiGiftList[l]["stockList"],
                "discountDetailSyskey" : multiGiftList[l]["discountDetailSyskey"],
                "giftQty" : 0.0
              });

              for(var ab = 0; ab < multiGiftList[l]["stockList"].length;ab++) {
                for(var cd = 0; cd < changeList.length; cd++) {
                  if(multiGiftList[l]["stockList"][ab] == changeList[cd]["stockSyskey"]) {
                    changeList[cd]["promoDetailSyskey"] =  multiGiftList[l]["discountDetailSyskey"];
                  }
                }
              }

              // for(var qq = 0; qq < multiGiftList[l]["giftInfoList"][0].length; qq++) {
              //   print(multiGiftList[l]["giftInfoList"][0][qq]["discountItemQty"]);
              //   print(multiGiftList[l]["giftInfoList"][0][qq]["discountItemQty"].runtimeType);
              //   print(multiGiftList[l]["giftInfoList"][0][qq]["discountItemQty"].abs());
              //   multiGiftList[l]["giftInfoList"][0][qq]["discountItemQty"] = multiGiftList[l]["giftInfoList"][0][qq]["discountItemQty"].abs();
              // }

              if(l == multiGiftList.length -1) {
                multiGiftList = arrangeList;

                final rtnMultiGiftList = await showMultiGiftDialog(multiGiftList, discountStockList, context);
                multiGiftList = rtnMultiGiftList;
                
                for(var k = 0; k < multiGiftList.length; k++) {
                  
                  for(var j = 0; j < multiGiftList[k]["giftInfoList"].length; j++) {
                    for(var a = 0; a < changeList.length; a++) {
                      if(multiGiftList[k]["stockList"][0].toString() == changeList[a]["stockSyskey"].toString()) {
                        changeList[a]["promotionStockList"].add({
                          "syskey" : '0',
	                        "recordStatus": 1,
	                        "stockCode": multiGiftList[k]["giftInfoList"][j][0]["discountStockCode"].toString() == "null" || multiGiftList[k]["giftInfoList"][j][0]["discountStockCode"].toString() == "" ? "0" :
                                         '${multiGiftList[k]["giftInfoList"][j][0]["discountStockCode"]}',
	                        "stockName": '${multiGiftList[k]["giftInfoList"][j][0]["discountItemDesc"]}',
	                        "stockSyskey": multiGiftList[k]["giftInfoList"][j][0]["discountStockSyskey"].toString() == "null" || multiGiftList[k]["giftInfoList"][j][0]["discountStockSyskey"] == "" ? "0" : '${multiGiftList[k]["giftInfoList"][j][0]["discountStockSyskey"]}',
	                        "promoStockSyskey": multiGiftList[k]["giftInfoList"][j][0]["discountItemSyskey"].toString() == "null" || multiGiftList[k]["giftInfoList"][j][0]["discountItemSyskey"] == "" ? "0" : '${multiGiftList[k]["giftInfoList"][j][0]["discountItemSyskey"]}',
	                        "qty": multiGiftList[k]["giftInfoList"][j][0]["discountItemQty"],
	                        "promoStockType": '${multiGiftList[k]["giftInfoList"][j][0]["discountItemType"]}'
                        });
                      }
                    }
                  }
                }
              }
            }
            
          }

          if(singleGiftList.length != 0) {
            for(var k = 0; k < singleGiftList.length; k++) {
              for(var j = 0; j < singleGiftList[k]["giftInfoList"].length; j++) {
                for(var a = 0; a < changeList.length; a++) {
                  if(singleGiftList[k]["stockList"][0].toString() == changeList[a]["stockSyskey"].toString()) {
                    changeList[a]["promotionStockList"].add({
                      "syskey" : '0',
	                    "recordStatus": 1,
	                    "stockCode": singleGiftList[k]["giftInfoList"][j][0]["discountStockCode"].toString() == "null" || singleGiftList[k]["giftInfoList"][j][0]["discountStockCode"].toString() == "" ? "0" :
                                     '${singleGiftList[k]["giftInfoList"][j][0]["discountStockCode"]}',
	                    "stockName": '${singleGiftList[k]["giftInfoList"][j][0]["discountItemDesc"]}',
	                    "stockSyskey": singleGiftList[k]["giftInfoList"][j][0]["discountStockSyskey"].toString() == "null" || singleGiftList[k]["giftInfoList"][j][0]["discountStockSyskey"] == "" ? "0" : '${singleGiftList[k]["giftInfoList"][j][0]["discountStockSyskey"]}',
	                    "promoStockSyskey": singleGiftList[k]["giftInfoList"][j][0]["discountItemSyskey"].toString() == "null" || singleGiftList[k]["giftInfoList"][j][0]["discountItemSyskey"] == "" ? "0" : '${singleGiftList[k]["giftInfoList"][j][0]["discountItemSyskey"]}',
	                    "qty": singleGiftList[k]["giftInfoList"][j][0]["discountItemQty"],
	                    "promoStockType": '${singleGiftList[k]["giftInfoList"][j][0]["discountItemType"]}'
                    });
                  }
                }
              }
            }
          }

          if(getdeliverylist.length == 0) {
            for(var b = 0; b < stockByBrandDel.length; b++) {
              for(var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                for(var d = 0; d < changeList.length; d++) {
                  if(stockByBrandDel[b]["stockData"][c]["stockSyskey"] == changeList[d]["stockSyskey"]) {
                    stockByBrandDel[b]["stockData"][c] = changeList[d];
                  }
                }
              }
            }
          } else {
            for(var b = 0; b < getdeliverylist.length; b++) {
              for(var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                for(var d = 0; d < changeList.length; d++) {
                  if(getdeliverylist[b]["stockData"][c]["stockSyskey"] == changeList[d]["stockSyskey"]) {
                    getdeliverylist[b]["stockData"][c] = changeList[d];
                  }
                }
              }
            }
          }

          for(var c = 0; c < stockList.length; c++) {
            for(var d = 0; d < changeList.length; d++) {
              if(stockList[c]["stockSyskey"] == changeList[d]["stockSyskey"]) {
                stockList[c] = changeList[d];
              }
            }
          }

          for(var a = 0; a < stockList.length; a++) {
            List sameGiftStock = stockList.where((element) => element["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().toString() == stockList[a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().toString() && element["promotionStockList"].length != 0).toList();
            if(sameGiftStock.length > 1) {
              for(var b = 0; b < sameGiftStock.length; b++) {
                stockList.removeWhere((element) => element.toString() == sameGiftStock[b].toString());
                stockList.add(sameGiftStock[b]);
              }
            }
          }

          newStockList = stockList;

          check = "success";
        }
        
      } else if(extdata["status"] == "FAIL") {
        check = "fail";
      }else {
        check = extdata["status"];
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

  

List multiDiscountStockList = [];
List listtoCheckMultiDis = [];
Future multiDisDownload(String shopSyskey, String headerSyskey) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'PromoAndDiscount/getMultiRuleDownload';
  // final url = 'http://52.253.88.71:8084/madbrepositorydev/PromoAndDiscount/getMultiRuleDownload';
  datetime();

  listtoCheckMultiDis = [];

  var param = jsonEncode({"shopSyskey": "$shopSyskey", "headerSyskey" : "$headerSyskey"});
  // var param = jsonEncode({"shopSyskey": "", "headerSyskey" : "$headerSyskey"});

  discountStockListDate = [];

  print(url);
  print(param);

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      if (extdata["status"] == "SUCCESS") {
        if (extdata["list"].length == 0) {
          check = "success";
        } else {
          multiDiscountStockList = extdata["list"];

          for(var a = 0; a < multiDiscountStockList.length; a++) {
            for(var b = 0; b < multiDiscountStockList[a]["DetailList"].length; b++) {
              listtoCheckMultiDis.add({
                "HeaderSyskey": multiDiscountStockList[a]["HeaderSyskey"],
                "RulePriority": multiDiscountStockList[a]["DetailList"][b]["RulePriority"],
                "PromoItemSyskey": multiDiscountStockList[a]["DetailList"][b]["PromoItemSyskey"],
                "RuleNumber": multiDiscountStockList[a]["DetailList"][b]["RuleNumber"]
              });

              if(b == multiDiscountStockList[a]["DetailList"].length-1) {
                if(a == multiDiscountStockList.length-1) {
                  check = "success";
                }
              }
            }
          }
        }
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getPromoItemDetail(String shopSyskey, String headerSyskey, String promoItemSyskey, String boSyskey) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'PromoAndDiscount/getPromoItemDetail';
  datetime();

  var param = jsonEncode({
    "shopSyskey": "$shopSyskey",
    "headerSyskey":"$headerSyskey"
  });

  promoItemDetailList = [];
  dicountExpiredDate = "";

  print(url);
  print(param);


  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      if (extdata["status"] == "SUCCESS") {
        if (extdata["list"].length == 0) {
          check = "success";
        } else {
          List boGetList = extdata["list"].where((element) => element["boSyskey"] == boSyskey).toList();
          promoItemDetailList = boGetList[0]["itemList"].where((element) => element["PromoItemSyskey"].toString() == promoItemSyskey).toList();

          for(var a = 0; a < promoItemDetailList.length; a++) {
            for(var b = 0; b < promoItemDetailList[a]["HeaderList"].length; b++) {
              promoItemDetailList[a]["HeaderList"][b]["DetailList"] = promoItemDetailList[a]["HeaderList"][b]["DetailList"].where((element) => element["PromoItemSyskey"] == promoItemSyskey).toList();
            }
          }

          dicountExpiredDate = boGetList[0]["itemList"].where((element) => element["PromoItemSyskey"] == promoItemSyskey).toList()[0]["HeaderList"][0]["ToDate"];

          check = "success";
        }
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getInvDisCalculation(String shopSyskey, String total) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'PromoAndDiscount/getInvDisCalculation';
  datetime();

  getInvDisCalculationList = null;

  var param = jsonEncode({
	"shopSyskey": "$shopSyskey",
	"Total": "$total"
  });

  print(url);
  print(param);

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print("invDisCalculation==> " + extdata.toString());
      if(extdata["data"] == "") {
        check = "fail";
      } else {
        if(extdata["status"] == "Promo Available") {
          getInvDisCalculationList = extdata["data"];
          check = "success";
          
        } else {
          check = extdata["status"];
        }
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getInvoiceDiscountDownload(String shopSyskey, String boSyskey) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'PromoAndDiscount/getInvoiceDiscountDownload';
  // final url = 'http://52.255.142.115:8084/madbrepository/PromoAndDiscount/getInvoiceDiscountDownload';
  datetime();

  invDisDownloadList = [];
  
  var param = jsonEncode({
    "shopSyskey": "$shopSyskey",
    "boSyskey": "$boSyskey"
  });

  print(url);
  print(param);

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      if (extdata["status"].toString() == "SUCCESS") {
        if(extdata["list"].length == 0) {
          check = "success";
        }else {
          List firstHeaderList = [];
          List secondHeaderList = [];
          for(var a = 0; a < extdata["list"].length; a++) {
            // This function is to get unique BrandOwner
            if(firstHeaderList.length == 0) {
              firstHeaderList.add({
                "InvoiceDiscountHeader" : [],
                "BrandOwnerSyskey" : extdata["list"][a]["BrandOwnerSyskey"],
                "BrandOwnerDesc" : extdata["list"][a]["BrandOwnerDesc"],
                "Boolean" : true
              });
            } else {
              if(firstHeaderList.where((element) => element["BrandOwnerSyskey"] == extdata["list"][a]["BrandOwnerSyskey"]).toList().length == 0) {
                firstHeaderList.add({
                  "InvoiceDiscountHeader" : [],
                  "BrandOwnerSyskey" : extdata["list"][a]["BrandOwnerSyskey"],
                  "BrandOwnerDesc" : extdata["list"][a]["BrandOwnerDesc"],
                  "Boolean" : true
                });
              }
            }
            ///////////////////////////////////////////

            for(var b = 0; b < extdata["list"][a]["InvoiceDiscountHeader"].length; b++) {
              // This function is to get unique HeaderCode and HeaderDesc
              if(secondHeaderList.length == 0) {
                secondHeaderList.add({
                  "BrandOwnerSyskey" : extdata["list"][a]["BrandOwnerSyskey"],
                  "BrandOwnerDesc" : extdata["list"][a]["BrandOwnerDesc"],
                  "HeaderCode" : extdata["list"][a]["InvoiceDiscountHeader"][b]["HeaderCode"],
                  "HeaderDesc" : extdata["list"][a]["InvoiceDiscountHeader"][b]["HeaderDesc"],
                  "Boolean" : true,
                  "InvoiceDiscountHeader" : extdata["list"][a]["InvoiceDiscountHeader"].where((element) => element["HeaderCode"] == extdata["list"][a]["InvoiceDiscountHeader"][b]["HeaderCode"]).toList()
                });
              } else {
                if(secondHeaderList.where((element) => element["HeaderCode"] == extdata["list"][a]["InvoiceDiscountHeader"][b]["HeaderCode"] && element["BrandOwnerSyskey"] == extdata["list"][a]["BrandOwnerSyskey"]).toList().length == 0) {
                  secondHeaderList.add({
                    "BrandOwnerSyskey" : extdata["list"][a]["BrandOwnerSyskey"],
                    "BrandOwnerDesc" : extdata["list"][a]["BrandOwnerDesc"],
                    "HeaderCode" : extdata["list"][a]["InvoiceDiscountHeader"][b]["HeaderCode"],
                    "HeaderDesc" : extdata["list"][a]["InvoiceDiscountHeader"][b]["HeaderDesc"],
                    "Boolean" : true,
                    "InvoiceDiscountHeader" : extdata["list"][a]["InvoiceDiscountHeader"].where((element) => element["HeaderCode"] == extdata["list"][a]["InvoiceDiscountHeader"][b]["HeaderCode"]).toList()
                  });
                }
              }
              /////////////////////////////////////////

              if(a == extdata["list"].length-1) {
                if(b == extdata["list"][a]["InvoiceDiscountHeader"].length-1) {
                  for(var c = 0; c < firstHeaderList.length; c++) {
                    // replace InvoiceDiscountHeader of 1stList to its InvoiceDiscountHeader(2ndList) by checking with BrandOwnerSyskey
                    firstHeaderList[c]["InvoiceDiscountHeader"] = secondHeaderList.where((element) => element["BrandOwnerSyskey"] == firstHeaderList[c]["BrandOwnerSyskey"]).toList();

                    if(c == firstHeaderList.length-1) {
                      invDisDownloadList = firstHeaderList;
                      check = "success";
                    }
                  }
                }
              }
            }
          }
        }
        
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}


Future accountGetBalance(String shopSyskey) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'account/account-get-balance/$shopSyskey';
  // final url = "http://52.255.142.115:8084/madbrepositorydev/account/account-get-balance/$shopSyskey";
  datetime();

  accountGetBalanceList = [];
  
  print(url);

  final response = await http
      .get(Uri.encodeFull(url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      if (extdata["status"].toString() == "SUCCESS") {
        if(extdata["data"]["detail"].length == 0) {
          check = "success";
        }else {
          accountGetBalanceList = extdata["data"]["detail"];
          check = "success";
        }
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}


Future cashAmountSave(String shopSyskey, double cashAmt) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'account/cashcollector-save/$shopSyskey';
  // final url = "http://52.255.142.115:8084/madbrepositorydev/account/cashcollector-save/$shopSyskey";
  datetime();
  
  var param = jsonEncode({
	  "receivedAmount": cashAmt
  });

  print(url);
  print(param);

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      if (extdata["status"].toString() == "SUCCESS") {
        check = "success";
      } else {
        check = extdata["status"];
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}



Future accountTodayCashReceived(String shopSyskey) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'account/cashcollector-get-todaycash-received/$shopSyskey';
  // final url = "http://52.255.142.115:8084/madbrepositorydev/account/cashcollector-get-todaycash-received/$shopSyskey";
  datetime();
  
  print(url);

  final response = await http
      .get(Uri.encodeFull(url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      if (extdata["status"].toString() == "SUCCESS") {
        if(extdata["data"].toString() == "") {
          check = "success";
        }else {
          cashReceivedAmt = extdata["data"]["receivedAmount"];
          check = "success";
        }
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

Future getPriceZoneDownload(String shopSyskey) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'PriceZone/getPriceZoneDownload';
  // final url = 'http://52.255.142.115:8084/madbrepositorydev/PriceZone/getPriceZoneDownload';
  datetime();
  
  getPriceZoneDownloadList = [];

  var param = jsonEncode(
    {"shopSyskey":"$shopSyskey"}
  );

  print(url);
  print(param);

  final response = await http
      .post(Uri.encodeFull(url), body: param, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });
  print("t");
  List originalOrderList = json.decode(preferences.getString("AddOrderOriginal"));
  preferences.setString("AddOrder", json.encode(originalOrderList));
  print("t22");
  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      if (extdata["status"].toString() == "SUCCESS") {
        if(extdata["list"].length == 0) {
          check = "success";
        } else {
          for(var a = 0; a < extdata["list"].length; a++) {
            getPriceZoneDownloadList = extdata["list"][a]["PriceZoneItemList"];
          }

          if(getPriceZoneDownloadList.length == 0) {
            check = "success";
          } else {
            List orderStockList = json.decode(preferences.getString("AddOrder"));
            if(orderStockList.length == 0) {
              check = "success";
            } else {
              for(var a = 0; a < orderStockList.length; a++) {
                for(var b = 0; b < getPriceZoneDownloadList.length; b++) {
                  if(orderStockList[a]["syskey"] == getPriceZoneDownloadList[b]["StockSyskey"]) {
                    for(var c = 0; c < orderStockList[a]["details"].length; c++) {
                      orderStockList[a]["details"][c]["price"] = double.parse(getPriceZoneDownloadList[b]["ChangedPrice"]);
                    }
                  }
                  if(b == getPriceZoneDownloadList.length-1) {
                    if(a == orderStockList.length-1) {
                      preferences.setString("AddOrder", json.encode(orderStockList));
                      check = "success";
                    }
                  }
                }
              }
            }
            
          }
          
        }
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      // check = "Server Error " + response.statusCode.toString() + " !";
      check = "success";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}

String preSellerName = "";

Future getPreSeller(String syskey, String tranType) async {
  var check;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final url = '$domain' + 'order/get-preseller/$syskey/$tranType';
  datetime();
  
  print(url);


  preSellerName = "";

  final response = await http
      .get(Uri.encodeFull(url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Content-Over": "${preferences.getString('OrgId')}"
      })
      .timeout(Duration(seconds: 30))
      .catchError((error) {
        check = 'Server Fail!';
      });

  if (response != null) {
    print("1");
    if (response.statusCode == 200) {
      print("2");
      var extdata = json.decode(response.body);
      print(extdata);
      if (extdata["status"].toString() == "SUCCESS") {
        if(extdata["data"].toString() == "") {
          check = "success";
        } else {
          preSellerName = extdata["data"]["username"];
          check = "success";
        }
      } else {
        check = "fail";
      }
    } else {
      print(response.statusCode);
      check = "Server Error " + response.statusCode.toString() + " !";
    }
  } else {
    check = 'Connection Fail!';
  }
  return check;
}


_checkarray(datalist) {
  List checkdeliveryOrderList = [];
  for (var i = 0; i < datalist.length; i++) {
    bool repeated = false;
    for (var j = 0; j < checkdeliveryOrderList.length; j++) {
      if (datalist[i]["brandOwnerSyskey"] ==
          checkdeliveryOrderList[j]["brandOwnerSyskey"]) {
        repeated = true;
      }
    }
    if (!repeated) {
      checkdeliveryOrderList.add(datalist[i]);
    }
  }
  for (var a = 0; a < checkdeliveryOrderList.length; a++) {
    List testnewdata = [];
    List testnewreturn = [];
    for (var i = 0; i < checkdeliveryOrderList[a]["stockData"].length; i++) {
      bool repeated = false;
      for (var j = 0; j < testnewdata.length; j++) {
        if (checkdeliveryOrderList[a]["stockData"][i]["stockSyskey"] ==
                testnewdata[j]["stockSyskey"] &&
            checkdeliveryOrderList[a]["stockData"][i]["price"] ==
                testnewdata[j]["price"]) {
          repeated = true;
        }
      }
      if (!repeated) {
        testnewdata.add(checkdeliveryOrderList[a]["stockData"][i]);
      }
    }
    // for (var i = 0;
    //     i < checkdeliveryOrderList[a]["stockReturnData"].length;
    //     i++) {
    //   bool repeated = false;
    //   for (var j = 0; j < testnewreturn.length; j++) {
    //     if (checkdeliveryOrderList[a]["stockReturnData"][i]["stockSyskey"] ==
    //             testnewreturn[j]["stockSyskey"] &&
    //         checkdeliveryOrderList[a]["stockReturnData"][i]["price"] ==
    //             testnewreturn[j]["price"]) {
    //       repeated = true;
    //     }
    //   }
    //   if (!repeated) {
    //     testnewreturn.add(checkdeliveryOrderList[a]["stockReturnData"][i]);
    //   }
    // }
    checkdeliveryOrderList[a]["stockData"] = testnewdata;
    // checkdeliveryOrderList[a]["stockReturnData"] = testnewreturn;

  }
  return checkdeliveryOrderList;
}

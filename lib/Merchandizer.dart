import 'dart:core';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import "package:flutter/material.dart";
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:delivery_2/Widgets/McdTast1.dart';
import 'package:delivery_2/database/McdDatabase.dart';
import 'package:delivery_2/database/McdNote.dart';
import 'package:delivery_2/database/MerchandizerDatabase.dart';
import 'package:delivery_2/database/MerchandizerNote.dart';
import 'package:delivery_2/database/shopByUserDatabase.dart';
import 'package:delivery_2/navigation_bar.dart';
import 'service.dart/AllService.dart';

class Merchandizer extends StatefulWidget {
  final String mcdCheck;
  final String userType;
  final String shopName;
  final String shopNameMm;
  final String address;
  final String phone;
  final List merchandiserList;
  Merchandizer(
      {Key key,
      this.mcdCheck,
      this.userType,
      this.shopName,
      @required this.shopNameMm,
      this.address,
      this.merchandiserList,
      this.phone})
      : super(key: key);
  @override
  _MerchandizerState createState() => _MerchandizerState();
}

class _MerchandizerState extends State<Merchandizer> {
  bool forBrand1 = false;

  ShopsbyUser helperShopsbyUser = ShopsbyUser();

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  List<MerchandizerNote> merchandizerNote;

  McdDatabase mcdDatabase = McdDatabase();
  List<McdNote> mcdNote;

  List<FileSystemEntity> _images;

  List complete = [];

  bool loading = true;

  String completeCheck = "";

  List<MerchandizerNote> completetask = [];

  @override
  void initState() {
    super.initState();

    if (widget.merchandiserList != null) {
      setState(() {
        merchandiserList = widget.merchandiserList;
      });
    } else {
      merchandiserList = merchandiserList;
    }

    getStatus();
  }

  String merchandizingStatus;
  String orderdetailStatus;
  String invoiceStatus;

  String storeID = "";

  Future<void> getStatus() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var getSysKey =
        helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));

    storeID = preferences.getString("shopCode");
    
    getSysKey.then((val) {
      // for (var i = 0; i < val.length; i++) {
        getStoreSts(preferences.getString("spsyskey"), val[0]["shopsyskey"])
            .then((value) {
          if (value == "success") {
            setState(() {
              merchandizingStatus = merchandizingSts;
              orderdetailStatus = orderdetailSts;
              invoiceStatus = invoiceSts;
            });
          }else {
            setState(() {
              merchandizingStatus = "";
              orderdetailStatus = "";
              invoiceStatus = "";
            });
          }
        });
      // }
    });
  }

  Future viewData(String taskCode, String t2, String t1, String syskey) async {
    var dir = await getExternalStorageDirectory();

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    print("The taskSyskey is  $taskCode");

    var knockDir;

    var getSysKey =
        helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));

    String completeOrNot;
    String remark;

    datetime();

    getSysKey.then((val) async {
      knockDir = await new Directory(
              "${dir.path}/${val[0]["shopsyskey"]}/$date/$campaignId/$taskCode")
          .create(recursive: true);

      _images = knockDir.listSync(recursive: true, followLinks: false);
      print(knockDir);

      final Future<Database> db = MerchandizerDatabase().initializedDatabase();
      await db.then((database) {
        Future<List<MerchandizerNote>> noteListFuture =
            MerchandizerDatabase().getNoteList();
        noteListFuture.then((note) async {
          this.merchandizerNote = note;

          // for(var v = 0; v < merchandizerNote.length; v++) {
          //   print(merchandizerNote[v].imgPath);
          // }

          List<MerchandizerNote> shopList = [];

          shopList = merchandizerNote
              .where((element) =>
                  element.imgPath.toString() ==
                  "${dir.path}/${val[0]["shopsyskey"]}/$date/$campaignId/$taskCode")
              .toList();
          for (var v = 0; v < shopList.length; v++) {
            setState(() {
              completeOrNot = shopList[v].completeCheck;

              print(completeOrNot);

              remark = shopList[v].remark;

              print(remark);

              print(shopList[v].taskKey);
            });
          }

          print(knockDir);

          print(_images);

          Navigator.pop(context);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Tast1(
                        task: taskId,
                        mcdCheck: widget.mcdCheck,
                        userType: widget.userType,
                        shopName: widget.shopName,
                        shopNameMm: widget.shopNameMm,
                        address: widget.address,
                        phone: widget.phone,
                        savedImage: _images == [] ? [] : _images,
                        merchandiserList: merchandiserList,
                        tasktoDo: t2,
                        taskCode: t1,
                        mcdSyskey: syskey,
                        completeOrNot: completeCheck,
                        remark: remark,
                        taskSyskey: taskCode,
                      )));
        });
      });
    });
  }

  Future<void> getMerchandizingCheck() async {
    final Future<Database> db = MerchandizerDatabase().initializedDatabase();
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await db.then((database) {
      Future<List<MerchandizerNote>> noteListFuture =
          MerchandizerDatabase().getNoteList();
      noteListFuture.then((note) {
        setState(() {
          this.merchandizerNote = note;

          List<MerchandizerNote> shopList = [];

          var getSysKey = helperShopsbyUser
              .getShopSyskey(preferences.getString('shopname'));

          getSysKey.then((val) async {
            for (var v = 0; v < val.length; v++) {
              shopList = merchandizerNote
                  .where(
                      (element) => element.shopSyskey == val[v]["shopsyskey"])
                  .toList();
            }

            complete = [];

            if(shopList.length == 0) {
              loading = false;
            }else {
              for (var j = 0; j < shopList.length; j++) {
                complete.add(shopList[j].imgPath);

                completeCheck = shopList[j].completeCheck;

                if(j == shopList.length-1) {
                  loading = false;
                }
              }
            }
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getMerchandizingCheck();

    Widget body = Container(
      height: MediaQuery.of(context).size.height - 390,
      child: merchandiserList.length == 0 || merchandiserList == []
          ? Center(
              child: Text(
                "No Data",
                style: TextStyle(fontSize: 25, color: Colors.grey[400]),
              ),
            )
          : ListView.builder(
              itemCount: merchandiserList.length,
              itemBuilder: (context, i) {
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 3),
                      child: GestureDetector(
                        onTap: () {
                          // getMerchandizingCheck();
                          if (merchandiserList[i]["check"] == false) {
                            setState(() {
                              merchandiserList[i]["check"] = true;
                            });
                          } else if (merchandiserList[i]["check"] == true) {
                            setState(() {
                              merchandiserList[i]["check"] = false;
                            });
                          }
                        },
                        child: Card(
                          elevation: 0,
                          color: Color(0xffef5350),
                          child: Container(
                            height: 50,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "${merchandiserList[i]["brand"]}",
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.white),
                                  ),
                                  Icon(
                                    merchandiserList[i]["check"]
                                        ? Icons.keyboard_arrow_down
                                        : Icons.keyboard_arrow_right,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: merchandiserList[i]["check"],
                      child: Container(
                        height: 70.0 * merchandiserList[i]["task"].length,
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: merchandiserList[i]["task"].length,
                            itemBuilder: (context, a) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 3),
                                child: GestureDetector(
                                  onTap: () {
                                    _handleSubmit(context);
                                    String task1 =
                                        merchandiserList[i]["task"][a]["t1"];
                                    String task2 =
                                        merchandiserList[i]["task"][a]["t2"];
                                    String mcdSyskey = merchandiserList[i]
                                        ["task"][a]["syskey"];
                                    List list = taskList
                                        .where((element) =>
                                            element["syskey"] ==
                                            merchandiserList[i]["task"][a]
                                                ["syskey"])
                                        .toList();
                                    for (var a = 0; a < list.length; a++) {
                                      viewData(list[a]["syskey"], task2, task1,
                                          mcdSyskey);
                                    }
                                  },
                                  child: Card(
                                    child: Container(
                                      height: 50,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            height: 50,
                                            width: 5,
                                            decoration: BoxDecoration(
                                                color: complete[a] == "" ||
                                                        complete[a] == null
                                                    ? Colors.white
                                                    : Colors.greenAccent,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(5),
                                                  bottomLeft:
                                                      Radius.circular(5),
                                                )),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15, right: 20),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  88,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "${merchandiserList[i]["task"][a]["t1"]}",
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        color:
                                                            Color(0xffef5350)),
                                                  ),
                                                  Icon(
                                                    Icons.keyboard_arrow_right,
                                                    size: 30,
                                                    color: Color(0xffef5350),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                );
              }),
    );

    var loadProgress = new Container(
        child: new Stack(children: <Widget>[
      // body,
      Container(
        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 0.5)),
        width: MediaQuery.of(context).size.width * 0.99,
        height: MediaQuery.of(context).size.height - 390,
        child: Center(
            child: CircularProgressIndicator(
          backgroundColor: Colors.red,
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )),
      ),
    ]));

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          title: Text("Merchandizing"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () async {
                final SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return NavigationBar("", widget.mcdCheck, widget.userType,
                      preferences.getString("DateTime"));
                }));
              }),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 17, vertical: 0),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400])),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListView(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text('Store ID',
                                        textAlign: TextAlign.start,
                                        style: TextStyle()),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 150,
                                  child: Text(
                                      "  - $storeID",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text('Shop',
                                        textAlign: TextAlign.start,
                                        style: TextStyle()),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 150,
                                  child: Text(
                                      widget.shopNameMm == null ||
                                              widget.shopNameMm == ""
                                          ? "  - ${widget.shopName}"
                                          : '  - ${widget.shopName} (${widget.shopNameMm})',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  child: Text('Phone',
                                      textAlign: TextAlign.start,
                                      style: TextStyle()),
                                ),
                                Text('  - ${widget.phone}',
                                    textAlign: TextAlign.start,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text('Address',
                                        textAlign: TextAlign.start,
                                        style: TextStyle()),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 150,
                                  child: Text("  - ${widget.address}",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                )),
            loading ? loadProgress : body,
          ],
        ),
        bottomNavigationBar: Visibility(
          visible: 
          // completeCheck == "McdCompleted" ||
                  invoiceCompleteSts == "CHECKOUT"
              ? false
              : true,
          child: Padding(
            padding: EdgeInsets.only(left: 5, right: 5, bottom: 15),
            child: GestureDetector(
              onTap: () async {

                _handleSubmit(context);
                
                if (complete.contains("") != true && complete.length != 0 &&
                    merchandiserList.length != 0) {

                  var connectivityResult =
                      await (Connectivity().checkConnectivity());

                  if (connectivityResult == ConnectivityResult.mobile ||
                      connectivityResult == ConnectivityResult.wifi) {
                    var loading = false;
                    final SharedPreferences preferences =
                        await SharedPreferences.getInstance();

                    var getSysKey = helperShopsbyUser
                        .getShopSyskey(preferences.getString('shopname'));
                    getSysKey.then((val) async {
                      setState(() {
                        loading = true;
                      });

                      print(loading);

                        setState(() {
                          loading = false;
                        });

                        // MerchandizerDatabase().updateComplete(
                        //     val[0]["shopsyskey"],
                        //     "McdCompleted"); // uncommand this function so we don't need to do transaction completed

                        // uploadImage().then((imageReturnList) { // save extdata from upload image(server) to Local Storage
                            preferences.setString("MerchandizingCheck", "");
                            setTask("COMPLETED", orderdetailStatus,
                                    invoiceStatus)
                                .then((value) {
                              snackbarmethod1("SUCCESS");
                              Future.delayed(Duration(seconds: 2), () {
                                Navigator.pop(context);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return NavigationBar(
                                      "",
                                      widget.mcdCheck,
                                      widget.userType,
                                      preferences.getString("DateTime"));
                                }));
                              });
                            });
                    });
                  } else {
                    snackbarmethod("Check your connection!");
                    Navigator.pop(context);
                  }
                } else {
                  snackbarmethod("Need to do all task!");
                  Navigator.pop(context);
                }
              },
              child: Card(
                color: Color(0xffef5350),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Text(
                    "Save",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  
  snackbarmethod1(name) {
    _scaffoldkey.currentState.showSnackBar(new SnackBar(
      content: new Text(name, textAlign: TextAlign.center),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ));
  }

  snackbarmethod(name) {
    _scaffoldkey.currentState.showSnackBar(new SnackBar(
      content: new Text(name, textAlign: TextAlign.center),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ));
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  void _handleSubmit(BuildContext context) {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader);
    } catch (error) {
      print(error);
    }
  }
}

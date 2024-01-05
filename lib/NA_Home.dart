import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:delivery_2/CompleteInvoice.dart';
import 'package:delivery_2/Invoice.dart';
import 'package:delivery_2/Login.dart';
import 'package:delivery_2/OrderDetail.dart';
import 'package:delivery_2/OrderDetailData.dart';
import 'package:delivery_2/ShopList.dart';
import 'package:delivery_2/database/MerchandizerDatabase.dart';
import 'package:delivery_2/navigation_bar.dart';
import 'package:delivery_2/service.dart/AllService.dart';
import 'Merchandizer.dart';
import 'Widgets/InvoiceDiscount.dart';
import 'database/McdDatabase.dart';
import 'database/MerchandizerNote.dart';
import 'database/ReturnDatabase.dart';
import 'database/ReturnNote.dart';
import 'database/shopByUserDatabase.dart';
import 'database/shopByUserNote.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:http/http.dart' as http;

class NAHome extends StatefulWidget {
  final String mcdCheck;
  final String userType;
  final List<PrinterBluetooth> devices;
  NAHome({Key key, this.mcdCheck, this.userType, this.devices})
      : super(key: key);
  @override
  _NAHomeState createState() => _NAHomeState();
}

class _NAHomeState extends State<NAHome> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  ShopsbyUser helperShopsbyUser = ShopsbyUser();
  List<ShopByUserNote> noteListShopByUserNote;
  List shopName = [];
  List dropDownShop = [];
  PermissionStatus _status;
  Geolocator geolocator = Geolocator();
  Position userLocation;
  List shopPhone = [];
  List shopAddress = [];
  List shopType = [];
  List<PrinterBluetooth> _devices = [];
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();

  ReturnDatabase returnDatabase = ReturnDatabase();
  List<ReturnNote> returnNote;

  List itemCode = [];
  List orderCode = [];
  List orderName = [];
  List orderQty = [];
  List orderTotalCount = [];
  List itemName = [];
  List itemQty = [];
  List itemTolCount = [];
  int totalCount = 0;
  List totalItem = [];
  String subTotal;
  List rtnItemCode = [];
  List rtnItemName = [];
  List rtnItemQty = [];
  List rtnItemTolCount = [];
  List subTotalItem = [];
  int returnTotal = 0;
  String merchandizingStatus;
  String orderdetailStatus;
  String invoiceStatus;
  double lati;
  double long;
  String completeShopName;
  String storeID = "";
  String shopNametoshow;
  String shopNameMm;
  String address;
  String phone;
  Timer timer;
  bool statusCheck = true;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.locationWhenInUse)
        .then(_updateStatus);
    getShopName();
    checkInOut();
    _startScanDevices();
    checkOrderDetailSts();
  }

  Future<void> checkOrderDetailSts() async {
    setState(() {
      statusCheck = true;
    });
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var getSysKey =
        helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));

    getSysKey.then((val) {
      getStoreSts(preferences.getString("spsyskey"), val[0]["shopsyskey"])
          .then((value) {
        if (value == "success") {
          setState(() {
            merchandizingStatus = merchandizingSts;
            orderdetailStatus = orderdetailSts;
            invoiceStatus = invoiceSts;
          });

          getDeliveryList(val[0]["shopcode"]).then((value) {
            if(getdeliverylist.length != 0) {
              getInvoiceList(val[0]["shopcode"]).then((value) {
                if(getinvoiceOrderlist.length == 0) {
                  setTask(merchandizingStatus, "COMPLETED", "PENDING").then((settaskValue) {
                    getStatus();
                  });
                } else {
                  setTask(merchandizingStatus, "COMPLETED", "COMPLETED").then((settaskValue) {
                    getStatus();
                  });
                }
              });
            } else {
              getStatus();
            }
          });

        }else {
          setState(() {
            merchandizingStatus = "";
            orderdetailStatus = "";
            invoiceStatus = "";
          });
        }
      });
      
    });
  }

  Future<void> getStatus() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var getSysKey =
        helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));

    getSysKey.then((val) {
      getStoreSts(preferences.getString("spsyskey"), val[0]["shopsyskey"])
          .then((value) {

        setState(() {
          statusCheck = false;
        });
            
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

      getInvoiceDiscountDownload(val[0]["shopsyskey"], "").then((value) {
        setState(() {
          print(invDisDownloadList);
        });
      });
    });
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
  }

  void _updateStatus(PermissionStatus status) {
    if (status != _status) {
      setState(() {
        _status = status;
      });
    }
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
  Future<void> _handleSubmit(BuildContext context) async {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader);
    } catch (error) {
      print(error);
    }
  }

  void getShopName() async {
    final Future<Database> db = helperShopsbyUser.initializedDatabase();
    await db.then((database) {
      Future<List<ShopByUserNote>> noteListFuture =
          helperShopsbyUser.getNoteList();
      noteListFuture.then((note) {
        setState(() {
          this.noteListShopByUserNote = note;

          noteListShopByUserNote.where((val) => val.type == "").toList();

          for (var i = 0; i < noteListShopByUserNote.length; i++) {
            shopName.add(noteListShopByUserNote[i].shopname);
            shopPhone.add(noteListShopByUserNote[i].phoneno);
            shopAddress.add(noteListShopByUserNote[i].address);
            shopType.add(noteListShopByUserNote[i].type);
          }

          for (var i = 0;
              i <
                  noteListShopByUserNote
                      .where((val) =>
                          val.type == "" ||
                          val.type == "TEMPCHECKOUT" ||
                          val.type == "STORECLOSED" ||
                          val.type == "CHECKIN")
                      .toList()
                      .length;
              i++) {
            dropDownShop.add(noteListShopByUserNote
                .where((val) =>
                    val.type == "" ||
                    val.type == "TEMPCHECKOUT" ||
                    val.type == "STORECLOSED" ||
                    val.type == "CHECKIN")
                .toList()[i]
                .shopname);
          }
        });
      });
    });
  }

  String merchandizing;

  Future checkInOut() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    getdata = preferences.getString('latitude');

    merchandizing = preferences.getString("merchandizer");

    storeID = preferences.getString("shopCode");
    shopNametoshow = preferences.getString("shopname");
    shopNameMm = preferences.getString("shopnamemm");
    address = preferences.getString("address");
    phone = preferences.getString("phNo");
  }

  @override
  Widget build(BuildContext context) {
    // getStatus();
    return Scaffold(
        key: _scaffoldkey,
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
                                      shopNameMm == null || shopNameMm == ""
                                          ? "  - $shopNametoshow"
                                          : '  - $shopNametoshow ($shopNameMm)',
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
                                Text('  - $phone',
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
                                  child: Text("  - $address",
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
            Container(
              height: MediaQuery.of(context).size.height - 375,
              // height: shopNameMm == null || shopNameMm == "" ? MediaQuery.of(context).size.height -
              //     ((('$address'.length / 30) * 20) + 303) : MediaQuery.of(context).size.height - ((('$address'.length / 30) * 20) + 323),
              child: ListView(
                children: <Widget>[
                  merchandizing != "Yes"
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              GestureDetector(
                                child: Container(
                                  height: 160,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  child: Card(
                                    child: Stack(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 115),
                                          child: Container(
                                            height: 40,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                20,
                                            decoration: BoxDecoration(
                                                color: Color(0xffef5350),
                                                borderRadius: BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(0),
                                                    bottomLeft:
                                                        Radius.circular(0))),
                                          ),
                                        ),
                                        Center(
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(25),
                                                child: Image.asset(
                                                  invoiceCompleteSts ==
                                                          "CHECKOUT"
                                                      ? "assets/task.png"
                                                      : "assets/checkin.png",
                                                  width: 60,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: getdata == null
                                                    ? Text(
                                                        invoiceCompleteSts ==
                                                                "CHECKOUT"
                                                            ? "Complete Visit"
                                                            : "1.Check In",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Pyidaungsu",
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15),
                                                      )
                                                    : getdata == ''
                                                        ? Text(
                                                            invoiceCompleteSts ==
                                                                    "CHECKOUT"
                                                                ? "Complete Visit"
                                                                : "1.Check In",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Pyidaungsu",
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15),
                                                          )
                                                        : Text(
                                                            invoiceCompleteSts ==
                                                                    "CHECKOUT"
                                                                ? "Complete Visit"
                                                                : "1.Check Out",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Pyidaungsu",
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15),
                                                          ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    elevation: 7,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                ),
                                onTap: statusCheck == true
                                    ? null
                                    : () async {
                                        if (invoiceCompleteSts == "CHECKOUT") {
                                          final SharedPreferences preferences =
                                              await SharedPreferences
                                                  .getInstance();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ShopList(
                                                      date:
                                                          preferences.getString(
                                                              "DateTime"))));
                                        } else {
                                          showCheckOutCard();
                                        }
                                      },
                              ),
                              GestureDetector(
                                child: Container(
                                  height: 160,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  child: Card(
                                    child: Stack(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 115),
                                          child: Container(
                                            height: 40,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                20,
                                            decoration: BoxDecoration(
                                                color: Color(0xffef5350),
                                                borderRadius: BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(0),
                                                    bottomLeft:
                                                        Radius.circular(0))),
                                          ),
                                        ),
                                        Center(
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(25),
                                                child: Image.asset(
                                                  "assets/orderdetail.png",
                                                  width: 60,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: Text(
                                                  invoiceCompleteSts ==
                                                          "CHECKOUT"
                                                      ? "Order Detail"
                                                      : "2.Order Detail",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: statusCheck == true
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                        color: Color.fromRGBO(
                                                            255,
                                                            255,
                                                            255,
                                                            0.5)),
                                                    width: 17,
                                                    height: 17,
                                                    child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                      backgroundColor:
                                                          Colors.red,
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.white),
                                                    )),
                                                  )
                                                : Container(
                                                    alignment: Alignment.center,
                                                    height: 17,
                                                    width: 17,
                                                    decoration: BoxDecoration(
                                                      color: orderdetailStatus ==
                                                              "INCOMPLETE"
                                                          ? Colors.white
                                                          : orderdetailStatus ==
                                                                  "PENDING"
                                                              ? Colors
                                                                  .orangeAccent
                                                              : orderdetailStatus ==
                                                                      "COMPLETED"
                                                                  ? Colors.greenAccent[
                                                                      700]
                                                                  : Colors
                                                                      .white,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color:
                                                              Colors.grey[300],
                                                          width: 2),
                                                    )),
                                          ),
                                        ),
                                      ],
                                    ),
                                    elevation: 7,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                ),
                                onTap: statusCheck == true
                                    ? null
                                    : () async {
                                        ontapOrderDetail();
                                      },
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              GestureDetector(
                                child: Container(
                                  height: 160,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  child: Card(
                                    child: Stack(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 115),
                                          child: Container(
                                            height: 40,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                20,
                                            decoration: BoxDecoration(
                                                color: Color(0xffef5350),
                                                borderRadius: BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(0),
                                                    bottomLeft:
                                                        Radius.circular(0))),
                                          ),
                                        ),
                                        Center(
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(25),
                                                child: Image.asset(
                                                  invoiceCompleteSts ==
                                                          "CHECKOUT"
                                                      ? "assets/task.png"
                                                      : "assets/checkin.png",
                                                  width: 60,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: getdata == null
                                                    ? Text(
                                                        invoiceCompleteSts ==
                                                                "CHECKOUT"
                                                            ? "Complete Visit"
                                                            : "1.Check In",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Pyidaungsu",
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15),
                                                      )
                                                    : getdata == ''
                                                        ? Text(
                                                            invoiceCompleteSts ==
                                                                    "CHECKOUT"
                                                                ? "Complete Visit"
                                                                : "1.Check In",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Pyidaungsu",
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15),
                                                          )
                                                        : Text(
                                                            invoiceCompleteSts ==
                                                                    "CHECKOUT"
                                                                ? "Complete Visit"
                                                                : "1.Check Out",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Pyidaungsu",
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15),
                                                          ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    elevation: 7,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                ),
                                onTap: statusCheck == true
                                    ? null
                                    : () async {
                                        if (invoiceCompleteSts == "CHECKOUT") {
                                          final SharedPreferences preferences =
                                              await SharedPreferences
                                                  .getInstance();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ShopList(
                                                      date:
                                                          preferences.getString(
                                                              "DateTime"))));
                                        } else {
                                          showCheckOutCard();
                                        }
                                      },
                              ),
                              GestureDetector(
                                child: Container(
                                  height: 160,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  child: Card(
                                    child: Stack(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 115),
                                          child: Container(
                                            height: 40,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                20,
                                            decoration: BoxDecoration(
                                              color: Color(0xffef5350),
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(0),
                                                  bottomLeft:
                                                      Radius.circular(0)),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(25),
                                                child: Image.asset(
                                                  "assets/merchandising.png",
                                                  width: 60,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: Text(
                                                  invoiceCompleteSts ==
                                                          "CHECKOUT"
                                                      ? "Merchandizing"
                                                      : "2.Merchandizing",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: statusCheck == true
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                        color: Color.fromRGBO(
                                                            255,
                                                            255,
                                                            255,
                                                            0.5)),
                                                    width: 17,
                                                    height: 17,
                                                    child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                      backgroundColor:
                                                          Colors.red,
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.white),
                                                    )),
                                                  )
                                                : Container(
                                                    alignment: Alignment.center,
                                                    height: 17,
                                                    width: 17,
                                                    decoration: BoxDecoration(
                                                      color: merchandizingStatus ==
                                                              "INCOMPLETE"
                                                          ? Colors.white
                                                          : merchandizingStatus ==
                                                                  "PENDING"
                                                              ? Colors
                                                                  .orangeAccent
                                                              : merchandizingStatus ==
                                                                      "COMPLETED"
                                                                  ? Colors.greenAccent[
                                                                      700]
                                                                  : Colors
                                                                      .white,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color:
                                                              Colors.grey[300],
                                                          width: 2),
                                                    )),
                                          ),
                                        ),
                                      ],
                                    ),
                                    elevation: 7,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                ),
                                onTap: statusCheck == true
                                    ? null
                                    : () {
                                        ontapMerchandizing();
                                      },
                              ),
                            ],
                          ),
                        ),
                  merchandizing != "Yes"
                      ? Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Stack(
                                children: <Widget>[
                                  GestureDetector(
                                    child: Container(
                                      height: 160,
                                      width: MediaQuery.of(context).size.width / 2 -
                                          20,
                                      child: Stack(
                                        children: <Widget>[
                                          Card(
                                            child: Stack(
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(top: 115),
                                                  child: Container(
                                                    height: 40,
                                                    width: MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2 -
                                                        20,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffef5350),
                                                      borderRadius: BorderRadius.only(
                                                          bottomRight:
                                                              Radius.circular(0),
                                                          bottomLeft:
                                                              Radius.circular(0)),
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.all(25),
                                                        child: Image.asset(
                                                          "assets/invoice.png",
                                                          width: 60,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                            top: 10),
                                                        child: Text(
                                                          invoiceCompleteSts ==
                                                                  "CHECKOUT"
                                                              ? "Invoice"
                                                              : "3.Invoice",
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 15),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: Align(
                                                    alignment: Alignment.topLeft,
                                                    child: statusCheck == true
                                                        ? Container(
                                                            decoration: BoxDecoration(
                                                                color: Color.fromRGBO(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    0.5)),
                                                            width: 17,
                                                            height: 17,
                                                            child: Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              strokeWidth: 2,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors.white),
                                                            )),
                                                          )
                                                        : Container(
                                                            alignment: Alignment.center,
                                                            height: 17,
                                                            width: 17,
                                                            decoration: BoxDecoration(
                                                              color: invoiceStatus ==
                                                                      "INCOMPLETE"
                                                                  ? Colors.white
                                                                  : invoiceStatus ==
                                                                          "PENDING"
                                                                      ? Colors
                                                                          .orangeAccent
                                                                      : invoiceStatus ==
                                                                              "COMPLETED"
                                                                          ? Colors.greenAccent[
                                                                              700]
                                                                          : Colors
                                                                              .white,
                                                              shape: BoxShape.circle,
                                                              border: Border.all(
                                                                  color:
                                                                      Colors.grey[300],
                                                                  width: 2),
                                                            )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            elevation: 7,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(0.0),
                                            ),
                                          ),
                                          Visibility(
                                            visible: invDisDownloadList.length == 0 ? false : true,
                                            child: Align(
                                        alignment: Alignment.topRight,
                                        child: GestureDetector(
                                            onTap: () async {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => InvoiceDiscount()));
                                            },
                                            child: Image.asset("assets/discount.png", width: 27,))),
                                          )
                                        ],
                                      ),
                                    ),
                                    onTap: statusCheck == true
                                        ? null
                                        : () async {
                                            final SharedPreferences preferences = await SharedPreferences.getInstance();

                                            if (preferences.getString("orderdetailSyskey") == "" && orderdetailStatus != "COMPLETED") {
                                              snackbarmethod("Need to do 3(Order Detail)!");
                                            } else {
                                              if (invoiceCompleteSts == "CHECKOUT") {
                                                _handleSubmit(context);
                                                Navigator.push(context, MaterialPageRoute(
                                                  builder: (context) => CompleteInvoice(
                                                      mcdCheck: widget.mcdCheck,
                                                      userType: widget.userType,
                                                      devices: widget.devices,
                                                      shopName: preferences.getString('shopname'),
                                                      shopNameMm: preferences.getString('shopnamemm'),
                                                      address: preferences.getString('address'),
                                                      phone: preferences.getString("phNo"),
                                                    )));
                                              } else {
                                                _handleSubmit(context);
                                                Navigator.push(context, MaterialPageRoute(
                                                  builder: (context) => InVoice(
                                                    mcdCheck: widget.mcdCheck,
                                                    userType: widget.userType,
                                                    devices: widget.devices,
                                                    shopName: preferences.getString('shopname'),
                                                    shopNameMm: preferences.getString('shopnamemm'),
                                                    address: preferences.getString('address'),
                                                    phone: preferences.getString("phNo"),
                                                  )));
                                              }
                                            }
                                          },
                                  ),
                                  Icon(Icons.ac_unit, color: Colors.green,)
                                ],
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              GestureDetector(
                                child: Container(
                                  height: 160,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  child: Card(
                                    child: Stack(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 115),
                                          child: Container(
                                            height: 40,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                20,
                                            decoration: BoxDecoration(
                                                color: Color(0xffef5350),
                                                borderRadius: BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(0),
                                                    bottomLeft:
                                                        Radius.circular(0))),
                                          ),
                                        ),
                                        Center(
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(25),
                                                child: Image.asset(
                                                  "assets/orderdetail.png",
                                                  width: 60,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: Text(
                                                  invoiceCompleteSts ==
                                                          "CHECKOUT"
                                                      ? "Order Detail"
                                                      : "3.Order Detail",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: statusCheck == true
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                        color: Color.fromRGBO(
                                                            255,
                                                            255,
                                                            255,
                                                            0.5)),
                                                    width: 17,
                                                    height: 17,
                                                    child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                      backgroundColor:
                                                          Colors.red,
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.white),
                                                    )),
                                                  )
                                                : Container(
                                                    alignment: Alignment.center,
                                                    height: 17,
                                                    width: 17,
                                                    decoration: BoxDecoration(
                                                      color: orderdetailStatus ==
                                                              "INCOMPLETE"
                                                          ? Colors.white
                                                          : orderdetailStatus ==
                                                                  "PENDING"
                                                              ? Colors
                                                                  .orangeAccent
                                                              : orderdetailStatus ==
                                                                      "COMPLETED"
                                                                  ? Colors.greenAccent[
                                                                      700]
                                                                  : Colors
                                                                      .white,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color:
                                                              Colors.grey[300],
                                                          width: 2),
                                                    )),
                                          ),
                                        ),
                                      ],
                                    ),
                                    elevation: 7,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                ),
                                onTap: statusCheck == true
                                    ? null
                                    : () async {
                                        ontapOrderDetail();
                                      },
                              ),
                              GestureDetector(
                                child: Container(
                                  height: 160,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  child: Stack(
                                    children: <Widget>[
                                      Card(
                                        child: Stack(
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 115),
                                              child: Container(
                                                height: 40,
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    20,
                                                decoration: BoxDecoration(
                                                  color: Color(0xffef5350),
                                                  borderRadius: BorderRadius.only(
                                                      bottomRight:
                                                          Radius.circular(0),
                                                      bottomLeft:
                                                          Radius.circular(0)),
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: Column(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(25),
                                                    child: Image.asset(
                                                      "assets/invoice.png",
                                                      width: 60,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        top: 10),
                                                    child: Text(
                                                      invoiceCompleteSts ==
                                                              "CHECKOUT"
                                                          ? "Invoice"
                                                          : "4.Invoice",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: statusCheck == true
                                                    ? Container(
                                                        decoration: BoxDecoration(
                                                            color: Color.fromRGBO(
                                                                255,
                                                                255,
                                                                255,
                                                                0.5)),
                                                        width: 17,
                                                        height: 17,
                                                        child: Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                          backgroundColor:
                                                              Colors.red,
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.white),
                                                        )),
                                                      )
                                                    : Container(
                                                        alignment: Alignment.center,
                                                        height: 17,
                                                        width: 17,
                                                        decoration: BoxDecoration(
                                                          color: invoiceStatus ==
                                                                  "INCOMPLETE"
                                                              ? Colors.white
                                                              : invoiceStatus ==
                                                                      "PENDING"
                                                                  ? Colors
                                                                      .orangeAccent
                                                                  : invoiceStatus ==
                                                                          "COMPLETED"
                                                                      ? Colors.greenAccent[
                                                                          700]
                                                                      : Colors
                                                                          .white,
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey[300],
                                                              width: 2),
                                                        )),
                                              ),
                                            ),
                                          ],
                                        ),
                                        elevation: 7,
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(0.0),
                                        ),
                                      ),
                                      Visibility(
                                        visible: invDisDownloadList.length == 0 ? false : true,
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: GestureDetector(
                                            onTap: () async {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => InvoiceDiscount()));
                                            },
                                            child: Image.asset("assets/discount.png", width: 27,))),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: statusCheck == true ? null :
                                orderdetailStatus != "COMPLETED"
                                    ? () {
                                        snackbarmethod(
                                            "Need to do 3(Order Detail)!");
                                      }
                                    : 
                                    () {
                                        ontapInvoice();
                                      },
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            )
          ],
        ));
  }

  Future _startScanDevices() async {
    // _devices = widget.devices;
    printerManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;

        print(_devices);
      });
    });
    printerManager.startScan(Duration(seconds: 3));
  }

  Future<void> showMessageAlert(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
          // title: Center(child: Text('Message')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(
                  "$message",
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              color: Color(0xffe53935),
              child: Row(
                children: <Widget>[
                  Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(
              width: 10,
            ),
          ],
        );
      },
    );
  }

  Future<void> ontapInvoice() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    if (preferences.getString("orderdetailSyskey") == "" &&
        orderdetailStatus != "COMPLETED") {
      snackbarmethod("Need to do 3(Order Detail)!");
    } else {
      if (invoiceCompleteSts == "CHECKOUT") {
        // _handleSubmit(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CompleteInvoice(
                      mcdCheck: widget.mcdCheck,
                      userType: widget.userType,
                      devices: widget.devices,
                      shopName: preferences.getString('shopname'),
                      shopNameMm: preferences.getString('shopnamemm'),
                      address: preferences.getString('address'),
                      phone: preferences.getString("phNo"),
                    )));
      } else {
        _handleSubmit(context);
        if (invoiceStatus == "COMPLETED") {
          setTask(merchandizingStatus, "COMPLETED", "COMPLETED")
              .then((settaskValue) {
            if (settaskValue == "success") {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InVoice(
                            mcdCheck: widget.mcdCheck,
                            userType: widget.userType,
                            devices: widget.devices,
                            shopName: preferences.getString('shopname'),
                            shopNameMm: preferences.getString('shopnamemm'),
                            address: preferences.getString('address'),
                            phone: preferences.getString("phNo"),
                          )));
            } else if (settaskValue == "fail") {
              Navigator.pop(context);
              snackbarmethod("FAIL!");
            } else {
              Navigator.pop(context);
              ontapInvoiceDialog(settaskValue.toString());
            }
          });
        } else {
          _handleSubmit(context);
          setTask(merchandizingStatus, "COMPLETED", "PENDING")
              .then((settaskValue) {
                
            if (settaskValue == "success") {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InVoice(
                            mcdCheck: widget.mcdCheck,
                            userType: widget.userType,
                            devices: widget.devices,
                            shopName: preferences.getString('shopname'),
                            shopNameMm: preferences.getString('shopnamemm'),
                            address: preferences.getString('address'),
                            phone: preferences.getString("phNo"),
                          )));
            } else if (settaskValue == "fail") {
              Navigator.pop(context);
              snackbarmethod("FAIL!");
            } else {
              Navigator.pop(context);
              ontapInvoiceDialog(settaskValue.toString());
            }
          });
        }
      }
    }
  }

  Future<void> ontapInvoiceDialog(String title) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    "$title",
                    style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Try again',
                  style: TextStyle(color: Color(0xffe53935)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  ontapInvoice();
                },
              ),
              SizedBox(
                width: 50,
              ),
              FlatButton(
                child:
                    Text('Cancel', style: TextStyle(color: Color(0xffe53935))),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> ontapMerchandizing() async {
    _handleSubmit(context);
    bool loading = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      final SharedPreferences preferences = await SharedPreferences.getInstance();

      if (preferences.getString("shopname").toString() == "" ||
          preferences.getString("shopname") == null) {
        snackbarmethod("Need to do 1(Check in)");
      } else {
        var getSysKey =
            helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));

        getSysKey.then((val) {
          MerchandizerDatabase()
              .getRow(val[0]["shopsyskey"])
              .then((databaseValue) {
            print(databaseValue);
            if (databaseValue == 0 || databaseValue == null) {
              print("object");
              getMerchandiserData(val[0]["shopsyskey"].toString())
                  .then((mcdValue) async {
                if (mcdValue == "success") {
                  preferences.setBool("checkMerchandizing", true);

                  if (merchandizingStatus == "COMPLETED") {
                  } else {
                    print(merchandizingStatus);
                    setTask("PENDING", orderdetailStatus, invoiceStatus)
                        .then((settaskValue) {
                      if (settaskValue == "success") {
                        print("object");
                      } else if (settaskValue == "fail") {
                        setState(() {
                          loading = false;
                        });
                        Navigator.pop(context);
                        snackbarmethod("FAIL!");
                      } else {
                        setState(() {
                          loading = false;
                        });
                        Navigator.pop(context);
                        ontapMerchandizingDialog(settaskValue.toString());
                      }
                    });
                  }

                  setState(() {
                    loading = false;
                  });

                  preferences.setString("MerchandizingCheck", "pending");

                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Merchandizer(
                                  mcdCheck: widget.mcdCheck,
                                  userType: widget.userType,
                                  shopName: preferences.getString('shopname'),
                                  shopNameMm:
                                      preferences.getString('shopnamemm'),
                                  address: val[0]["address"].toString(),
                                  phone: val[0]["phoneno"].toString(),
                                )));
                  });
                } else if (mcdValue == "fail") {
                  setState(() {
                    loading = false;
                  });
                  Navigator.pop(context);
                  snackbarmethod(
                      "Need to assign campaign data for merchandizing!");
                } else {
                  setState(() {
                    loading = false;
                  });
                  Navigator.pop(context);
                  ontapMerchandizingDialog(mcdValue.toString());
                }
              });
            } else {
              // print("object1");
              preferences.setBool("checkMerchandizing", true);

              var getSysKey = helperShopsbyUser
                  .getShopSyskey(preferences.getString('shopname'));

              getSysKey.then((val) {
                getMerchandiserData1(val[0]["shopsyskey"].toString())
                    .then((mcdValue) async {
                  if (mcdValue == "success") {
                    if (merchandizingStatus == "COMPLETED") {
                    } else {
                      print(merchandizingStatus);
                      setTask("PENDING", orderdetailStatus, invoiceStatus)
                          .then((settaskValue) {
                        if (settaskValue == "success") {
                          print("object");
                        } else if (settaskValue == "fail") {
                          setState(() {
                            loading = false;
                          });
                          Navigator.pop(context);
                          snackbarmethod("FAIL!");
                        } else {
                          setState(() {
                            loading = false;
                          });
                          Navigator.pop(context);
                          ontapMerchandizingDialog(settaskValue.toString());
                        }
                      });
                    }

                    List shopList = [];

                    final Future<Database> db =
                        MerchandizerDatabase().initializedDatabase();
                    final SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    await db.then((database) {
                      Future<List<MerchandizerNote>> noteListFuture =
                          MerchandizerDatabase().getNoteList();
                      noteListFuture.then((note) async {
                        shopList = note
                            .where((element) =>
                                element.shopSyskey == val[0]["shopsyskey"])
                            .toList();

                        print(tasktoDo.length.toString() + " /////////");

                        if (shopList.length == tasktoDo.length) {
                          setState(() {
                            loading = false;

                            print(loading);
                          });

                          preferences.setString(
                              "MerchandizingCheck", "pending");

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Merchandizer(
                                        mcdCheck: widget.mcdCheck,
                                        userType: widget.userType,
                                        shopName:
                                            preferences.getString('shopname'),
                                        shopNameMm:
                                            preferences.getString('shopnamemm'),
                                        address: val[0]["address"].toString(),
                                        phone: val[0]["phoneno"].toString(),
                                      )));
                        } else {
                          MerchandizerDatabase()
                              .deleteCompleteRow(val[0]["shopsyskey"])
                              .then((databaseValue) {
                            getMerchandiserData(val[0]["shopsyskey"].toString())
                                .then((mcdValue) {
                              if (mcdValue == "success") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Merchandizer(
                                              mcdCheck: widget.mcdCheck,
                                              userType: widget.userType,
                                              shopName: preferences
                                                  .getString('shopname'),
                                              shopNameMm: preferences
                                                  .getString('shopnamemm'),
                                              address:
                                                  val[0]["address"].toString(),
                                              phone:
                                                  val[0]["phoneno"].toString(),
                                            )));
                              } else if (mcdValue == "fail") {
                                setState(() {
                                  loading = false;
                                });
                                Navigator.pop(context);
                                snackbarmethod(
                                    "Need to assign campaign data for merchandizing!");
                              } else {
                                setState(() {
                                  loading = false;
                                });
                                Navigator.pop(context);
                                ontapMerchandizingDialog(mcdValue.toString());
                              }
                            });
                          });
                        }
                      });
                    });
                  }
                });
              });
            }
          });
        });
      }
    } else {
      snackbarmethod("Check your connection!");
    }
  }

  Future<void> ontapMerchandizingDialog(String title) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    "$title",
                    style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Try again',
                  style: TextStyle(color: Color(0xffe53935)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  ontapMerchandizing();
                },
              ),
              SizedBox(
                width: 50,
              ),
              FlatButton(
                child:
                    Text('Cancel', style: TextStyle(color: Color(0xffe53935))),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> toOrderDetailData() async {
    final SharedPreferences preferences =
            await SharedPreferences.getInstance();
    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderDetailData(
                                  orderDate: "",
                                  deliveryDate: "$date",
                                  mcdCheck: widget.mcdCheck,
                                  userType: widget.userType,
                                  shopName: preferences.getString('shopname'),
                                  shopNameMm:
                                      preferences.getString('shopnamemm'),
                                  address: preferences.getString('address'),
                                  phone: preferences.getString("phNo"),
                                  orderDeleted: [],
                                  returnDeleted: [],
                                  isSaleOrderLessRouteShop: "false",
                                )));
  }

  Future<void> ontapOrderDetail() async {
    if (invoiceCompleteSts == "CHECKOUT") {
      snackbarmethod("Already Invoice");
    } else if (invoiceStatus == "COMPLETED") {
      snackbarmethod("Already Invoice");
    } else {
      _handleSubmit(context);
      DateTime dateTime = DateTime.now();
      String year = dateTime.toString().substring(0, 4);
      String month = dateTime.toString().substring(5, 7);
      String day = dateTime.toString().substring(8, 10);
      String date = "$year$month$day";

      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        bool loading = false;
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();

        if (preferences.getString('shopname') == "" ||
            preferences.getString('shopname') == null) {
          snackbarmethod("Need to do 1(CheckIn)");
        } else {
          // setState(() {
          //   orderdetailStatus = "COMPLETED";
          // }); ////////// 
          if (orderdetailStatus == "COMPLETED") {
            var getSysKey = helperShopsbyUser
                .getShopSyskey(preferences.getString('shopname'));

            getSysKey.then((val) {
              for (var i = 0; i < val.length; i++) {
                getDeliveryList(val[i]["shopcode"]).then((deliveryValue) {
                  setState(() {
                    loading = false;
                  });
                  if (deliveryValue == "success") {
                    getPreSeller(sysKey, "421").then((value) {
                    getVolDisDataForMobileDate(val[0]["shopsyskey"], getdeliverylist[0]["createddate"]).then((disValue) {
                  if (disValue == "success") {
                if (discountStockListDate.length == 0) {
                  toOrderDetailData();
                } else {
                  List sameSyskeyList = [];
                  for (var i = 0; i < getdeliverylist.length; i++) {
                    if(getdeliverylist[i]["stockData"].length == 0) {
                      toOrderDetailData();
                    } else {
                      for (var j = 0;
                        j < getdeliverylist[i]["stockData"].length;
                        j++) {
                      for (var k = 0; k < discountStockListDate.length; k++) {
                        if (getdeliverylist[i]["stockData"][j]["stockSyskey"]
                                .toString() ==
                            discountStockListDate[k]["stockSyskey"]
                                .toString()) {
                          sameSyskeyList.add(discountStockListDate[k]);
                        }
                        if (k == discountStockListDate.length - 1) {
                          if (j == getdeliverylist[i]["stockData"].length - 1) {
                            if (i == getdeliverylist.length - 1) {
                              discountStockListDate = sameSyskeyList;
                              toOrderDetailData();
                            }
                          }
                        }
                      }
                    }
                    }
                    
                  }
                }
              } else if (disValue == "fail") {
                setState(() {
                  loading = false;
                });
                Navigator.pop(context);
                snackbarmethod("FAIL!");
              } else {
                setState(() {
                  loading = false;
                });
                Navigator.pop(context);
                snackbarmethod(disValue);
              }
                });
                  });
                  } else if (deliveryValue == "fail") {
                    setState(() {
                      loading = false;
                    });
                    Navigator.pop(context);
                    snackbarmethod("FAIL!");
                  } else {
                    setState(() {
                      loading = false;
                    });
                    Navigator.pop(context);
                    orderDetailDialog(deliveryValue.toString());
                  }
                });
              }
            });
          } else {
            var getSysKey = helperShopsbyUser
                .getShopSyskey(preferences.getString('shopname'));

            getSysKey.then((val) {
              // for (var i = 0; i < val.length; i++) {
              print(val[0]["isSaleOrderLessRouteShop"]);
              // setState(() {
              //   val[0]["isSaleOrderLessRouteShop"] = "true";
              // }); //////////////////////////////////
              if (val[0]["isSaleOrderLessRouteShop"] == "true") {
                getRecommendedList(val[0]["shopsyskey"])
                    .then((recommendedValue) {
                  if (recommendedValue == 'success') {
                    setState(() {
                      loading = false;
                    });
                    setTask(merchandizingStatus, "PENDING", "INCOMPLETE")
                        .then((settaskValue) {
                      if (settaskValue == "success") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderDetailData(
                                      orderDate: "",
                                      deliveryDate: "$date",
                                      mcdCheck: widget.mcdCheck,
                                      userType: widget.userType,
                                      shopName:
                                          preferences.getString('shopname'),
                                      shopNameMm:
                                          preferences.getString('shopnamemm'),
                                      address: preferences.getString('address'),
                                      phone: preferences.getString("phNo"),
                                      orderDeleted: [],
                                      returnDeleted: [],
                                      isSaleOrderLessRouteShop: "true",
                                    )));
                      } else if (settaskValue == "fail") {
                        setState(() {
                          loading = false;
                        });
                        Navigator.pop(context);
                        snackbarmethod("FAIL!");
                      } else {
                        setState(() {
                          loading = false;
                        });
                        Navigator.pop(context);
                        orderDetailDialog(settaskValue.toString());
                      }
                    });
                  } else if (recommendedValue == "fail") {
                    setState(() {
                      loading = false;
                    });
                    Navigator.pop(context);
                    snackbarmethod("FAIL!");
                  } else {
                    setState(() {
                      loading = false;
                    });
                    Navigator.pop(context);
                    orderDetailDialog(recommendedValue.toString());
                  }
                });
              } else {
                getsolist(val[0]["shopcode"]).then((solistValue) {
                  if (solistValue == 'success') {
                    setState(() {
                      loading = false;
                    });
                    getPreSeller(sysKey, "421").then((value) {
                    setTask(merchandizingStatus, "PENDING", "INCOMPLETE")
                        .then((settaskValue) {
                      if (settaskValue == "success") {
                        if (loading == false) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrderDetail(
                                        shopName:
                                            preferences.getString('shopname'),
                                        shopNameMm:
                                            preferences.getString('shopnamemm'),
                                        address:
                                            preferences.getString('address'),
                                        phone: val[0]["phoneno"].toString(),
                                        mcdCheck: widget.mcdCheck,
                                        userType: widget.userType,
                                      )));
                        }
                      } else if (settaskValue == "fail") {
                        setState(() {
                          loading = false;
                        });
                        Navigator.pop(context);
                        snackbarmethod("FAIL!");
                      } else {
                        setState(() {
                          loading = false;
                        });
                        Navigator.pop(context);
                        orderDetailDialog(settaskValue.toString());
                      }
                    });
                    });
                    
                  } else if (solistValue == "fail") {
                    setState(() {
                      loading = false;
                    });
                    Navigator.pop(context);
                    snackbarmethod("FAIL!");
                  } else {
                    setState(() {
                      loading = false;
                    });
                    Navigator.pop(context);
                    orderDetailDialog(solistValue.toString());
                  }
                });
              }
              // }
            });
          }
        }
      } else {
        snackbarmethod("Check your connection!");
      }
    }
  }

  Future<void> orderDetailDialog(String title) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    "$title",
                    style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Try again',
                  style: TextStyle(color: Color(0xffe53935)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  ontapOrderDetail();
                },
              ),
              SizedBox(
                width: 50,
              ),
              FlatButton(
                child:
                    Text('Cancel', style: TextStyle(color: Color(0xffe53935))),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showCheckOutCard() async {
    double width = MediaQuery.of(context).size.width * 0.5;
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String location;
    String shopName;
    String shopNameMm;
    String checkoutDateTime;
    double lati;
    double long;
    List pendingShop = [];
    pendingShop = noteListShopByUserNote
        .where((element) => element.type == "CHECKIN")
        .toList();

    print(preferences.getString("shopname"));

    print(pendingShop);

    userName = preferences.getString("userName");
    shopName = preferences.getString("shopname");
    shopNameMm = preferences.getString("shopnamemm");
    location = preferences.getString("latitude") +
        " / " +
        preferences.getString("longitude");
    checkoutDateTime = preferences.getString("date");
    address = preferences.getString("address");
    lati = double.parse(preferences.getString("latitude"));
    long = double.parse(preferences.getString("longitude"));
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
          title: Text('Check Out'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Image.asset(
                    "assets/shop.png",
                    width: 25,
                    color: Color(0xffef5350),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Container(
                        width: width, child: Text("$shopName ($shopNameMm)")),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.access_time,
                    size: 25,
                    color: Color(0xffef5350),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text("$checkoutDateTime"),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.location_searching,
                    size: 25,
                    color: Color(0xffef5350),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "$location",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    size: 25,
                    color: Color(0xffef5350),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Container(
                      width: width,
                      // child: Text("$address"),
                      child: Text("Unregister"),
                    ),
                  )
                ],
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Row(
                children: <Widget>[
                  Icon(Icons.cancel, color: Color(0xffe53935)),
                  Text('Cancel', style: TextStyle(color: Color(0xffe53935))),
                ],
              ),
              onPressed: () {
                // Navigator.pop(context, true);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return NavigationBar(orgId, widget.mcdCheck, widget.userType,
                      preferences.getString("DateTime"));
                }));
              },
            ),
            // SizedBox(
            //   width: 50,
            // ),
            FlatButton(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.location_off,
                    color: Color(0xffe53935),
                  ),
                  Text(
                    'Check Out',
                    style: TextStyle(color: Color(0xffe53935)),
                  ),
                ],
              ),
              onPressed: () async {
                bool loading = false;
                var check;
                final SharedPreferences preferences =
                    await SharedPreferences.getInstance();

                if (orderdetailStatus == "COMPLETED" &&
                    invoiceStatus == "COMPLETED") {
                  setState(() {
                    loading = true;
                  });

                  if (loading == true) {
                    _handleSubmit(context);
                  }
                  var getSysKey = helperShopsbyUser.getShopSyskey(shopName);

                  getSysKey.then((val) {
                    checkIn(
                            lati,
                            long,
                            shopName,
                            val[0]["shopcode"],
                            shopNameMm,
                            val[0]["address"],
                            val[0]["phoneno"],
                            val[0]["email"],
                            val[0]["shopsyskey"],
                            "TEMPCHECKOUT",
                            merchandizingStatus,
                            "COMPLETED",
                            "COMPLETED")
                        .then((value) async {
                      if (value == 'success') {
                        setState(() {
                          loading = false;
                        });
                        preferences.setString('latitude', "");
                        preferences.setString('longitude', "");
                        preferences.setString('date', "");
                        preferences.setString('address', "");
                        preferences.setString('shopname', "");
                        preferences.setString("shopnamemm", "");
                        preferences.setString('merchandiserSts', "");
                        preferences.setString('saveImageSts', "");
                        preferences.setString('InvoiceSts', "");
                        preferences.setString('phNo', "");
                        preferences.setString('email', "");
                        preferences.setString("subTotal", "");
                        preferences.setString("returnTotal", "");
                        preferences.setString("orderdetailSyskey", "");
                        preferences.setString("OriginalStockList", "");
                        preferences.setString("ReturnStockList", "");

                        datetime();

                        // var dir = await getExternalStorageDirectory();
                        // var knockDir = await new Directory(
                        //         '${dir.path}/$date/$brandOwnerCode/$campaignsyskey/$task')
                        //     .create(recursive: true);

                        // await knockDir.delete(recursive: true);

                        shopbyUser.deleteAllNote();
                        shopbyTeam.deleteAllNote();
                        McdDatabase().deleteAllNote();
                        final url = '$domain' + 'shop/getshopall';
                        var param = jsonEncode({
                          "spsyskey": "${preferences.getString('spsyskey')}",
                          "teamsyskey": "",
                          "usertype": "delivery",
                          "date": "$date"
                          // "date": "20201217"
                        });
                        print(param);
                        final response = await http
                            .post(Uri.encodeFull(url), body: param, headers: {
                              "Accept": "application/json",
                              "Content-Type": "application/json",
                              "Content-Over": '${preferences.getString("OrgId")}',
                            })
                            .timeout(Duration(seconds: 20))
                            .catchError((error) {
                              check = 'Server Fail!';

                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                  msg: "$check",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIos: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            });

                        if (response != null) {
                          print("1");
                          if (response.statusCode == 200) {
                            print("2");
                            var result = json.decode(response.body);
                            print(result['status']);
                            print(result['data']);
                            if (result['data']["shopsByUser"].toString() ==
                                "[]") {
                              check = "success";
                              Fluttertoast.showToast(
                                  msg: "Incomplete Transaction",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIos: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);

                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ShopList(
                                    date: preferences.getString("DateTime"));
                              }));
                            }
                            for (var i = 0;
                                i < result['data']['shopsByUser'].length;
                                i++) {
                              shopbyUser
                                  .insertNote(ShopByUserNote(
                                      result['data']['shopsByUser'][i]
                                              ['isSaleOrderLessRouteShop']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['address']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['shopnamemm']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['shopsyskey']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['long']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['phoneno']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['zonecode']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['shopcode']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['shopname']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['teamcode']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['location']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['comment'].toString(),
                                      result['data']['shopsByUser'][i]['usercode'].toString(),
                                      result['data']['shopsByUser'][i]['user'].toString(),
                                      result['data']['shopsByUser'][i]['lat'].toString(),
                                      result['data']['shopsByUser'][i]['email'].toString(),
                                      result['data']['shopsByUser'][i]['username'].toString(),
                                      result['data']['shopsByUser'][i]["status"]["currentType"]))
                                  .then((value) {
                                if (i ==
                                    result['data']['shopsByUser'].length - 1) {
                                  Fluttertoast.showToast(
                                      msg: "Incomplete Transaction",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);

                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ShopList(
                                        date:
                                            preferences.getString("DateTime"));
                                  }));
                                }
                              });
                            }
                            check = 'success';
                          } else {
                            print(response.statusCode);
                            check = "Server Error " +
                                response.statusCode.toString() +
                                " !";
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                                msg: "$check",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIos: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        } else {
                          check = 'Connection Fail!';

                          Navigator.pop(context);
                          Fluttertoast.showToast(
                              msg: "$check",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIos: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      } else if (value == "fail") {
                        setState(() {
                          loading = false;
                        });
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                            msg: "CheckOut Fail!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      } else {
                        setState(() {
                          loading = false;
                        });
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                            msg: value,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    });
                  });
                } else {
                  setState(() {
                    loading = true;
                  });

                  if (loading == true) {
                    _handleSubmit(context);
                  }
                  var getSysKey = helperShopsbyUser.getShopSyskey(shopName);

                  getSysKey.then((val) {
                    checkIn(
                            lati,
                            long,
                            shopName,
                            val[0]["shopcode"],
                            shopNameMm,
                            val[0]["address"],
                            val[0]["phoneno"],
                            val[0]["email"],
                            val[0]["shopsyskey"],
                            "TEMPCHECKOUT",
                            merchandizingStatus,
                            orderdetailStatus,
                            invoiceStatus)
                        .then((checkinvalue) async {
                      if (checkinvalue == 'success') {
                        setState(() {
                          loading = false;
                        });
                        preferences.setString('latitude', "");
                        preferences.setString('longitude', "");
                        preferences.setString('date', "");
                        preferences.setString('address', "");
                        preferences.setString('shopname', "");
                        preferences.setString("shopnamemm", "");
                        preferences.setString('merchandiserSts', "");
                        preferences.setString('saveImageSts', "");
                        preferences.setString('InvoiceSts', "");
                        preferences.setString('phNo', "");
                        preferences.setString('email', "");
                        preferences.setString("subTotal", "");
                        preferences.setString("returnTotal", "");
                        preferences.setString("orderdetailSyskey", "");
                        preferences.setString("OriginalStockList", "");
                        preferences.setString("ReturnStockList", "");

                        // var dir = await getExternalStorageDirectory();
                        // var knockDir = await new Directory(
                        //         '${dir.path}/$date/$brandOwnerCode/$campaignsyskey/$task')
                        //     .create(recursive: true);

                        // await knockDir.delete(recursive: true);

                        datetime();

                        shopbyUser.deleteAllNote();
                        shopbyTeam.deleteAllNote();
                        McdDatabase().deleteAllNote();
                        final url = '$domain' + 'shop/getshopall';
                        var param = jsonEncode({
                          "spsyskey": "${preferences.getString('spsyskey')}",
                          "teamsyskey": "",
                          "usertype": "delivery",
                          "date": "$date"
                          // "date": "20201217"
                        });
                        print(param);
                        final response = await http
                            .post(Uri.encodeFull(url), body: param, headers: {
                              "Accept": "application/json",
                              "Content-Type": "application/json",
                              "Content-Over":
                                  '${preferences.getString("OrgId")}',
                            })
                            .timeout(Duration(seconds: 20))
                            .catchError((error) {
                              check = 'Server Fail!';

                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                  msg: "$check",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIos: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            });

                        if (response != null) {
                          print("1");
                          if (response.statusCode == 200) {
                            print("2");
                            var result = json.decode(response.body);
                            print(result['status']);
                            print(result['data']);
                            if (result['data']["shopsByUser"].toString() ==
                                "[]") {
                              check = "success";
                              Fluttertoast.showToast(
                                  msg: "Incomplete Transaction",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIos: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);

                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ShopList(
                                    date: preferences.getString("DateTime"));
                              }));
                            }
                            for (var i = 0;
                                i < result['data']['shopsByUser'].length;
                                i++) {
                              shopbyUser
                                  .insertNote(ShopByUserNote(
                                      result['data']['shopsByUser'][i]
                                              ['isSaleOrderLessRouteShop']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['address']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['shopnamemm']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['shopsyskey']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['long']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['phoneno']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['zonecode']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['shopcode']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['shopname']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['teamcode']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['location']
                                          .toString(),
                                      result['data']['shopsByUser'][i]['comment'].toString(),
                                      result['data']['shopsByUser'][i]['usercode'].toString(),
                                      result['data']['shopsByUser'][i]['user'].toString(),
                                      result['data']['shopsByUser'][i]['lat'].toString(),
                                      result['data']['shopsByUser'][i]['email'].toString(),
                                      result['data']['shopsByUser'][i]['username'].toString(),
                                      result['data']['shopsByUser'][i]["status"]["currentType"]))
                                  .then((value) {
                                if (i ==
                                    result['data']['shopsByUser'].length - 1) {
                                  Fluttertoast.showToast(
                                      msg: "Incomplete Transaction",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);

                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ShopList(
                                        date:
                                            preferences.getString("DateTime"));
                                  }));
                                }
                              });
                            }
                            check = 'success';
                          } else {
                            print(response.statusCode);
                            check = "Server Error " +
                                response.statusCode.toString() +
                                " !";

                            Navigator.pop(context);
                            Fluttertoast.showToast(
                                msg: "$check",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIos: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        } else {
                          check = 'Connection Fail!';
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                              msg: "$check",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIos: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      } else if (checkinvalue == "fail") {
                        setState(() {
                          loading = false;
                        });
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                            msg: "CheckOut Fail!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      } else {
                        setState(() {
                          loading = false;
                        });
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                            msg: checkinvalue,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    });
                  });
                }
              },
            ),
            SizedBox(
              width: 10,
            ),
          ],
        );
      },
    );
  }
}

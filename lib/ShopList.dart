import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:delivery_2/Widgets/drawer.dart';
import 'package:delivery_2/service.dart/AllService.dart';
import 'package:http/http.dart' as http;
import 'package:app_settings/app_settings.dart';
import 'package:connectivity/connectivity.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'ChangePassword.dart';
import 'Login.dart';
import 'database/McdDatabase.dart';
import 'database/MerchandizerDatabase.dart';
import 'database/MerchandizerNote.dart';
import 'database/ReturnDatabase.dart';
import 'database/shopByUserDatabase.dart';
import 'database/shopByUserNote.dart';
import 'navigation_bar.dart';
import 'package:screen_state/screen_state.dart';
import 'package:flutter/services.dart';
import 'package:delivery_2/Widgets/printer.dart';

class ShopList extends StatefulWidget {
  var date;
  ShopList({Key key, @required this.date}) : super(key: key);
  @override
  _ShopListState createState() => _ShopListState();
}

enum PopupMenuChoice { changePassowrd, printerSetting, logout }

class _ShopListState extends State<ShopList> {
  ShopsbyUser helperShopsbyUser = ShopsbyUser();
  List<ShopByUserNote> noteListShopByUserNote;
  List shopName = [];
  List shopNameMm = [];
  List dropDownShop = [];
  PermissionStatus _status;
  Geolocator geolocator = Geolocator();
  Position userLocation;
  List shopPhone = [];
  List shopAddress = [];
  List shopType = [];
  List comment = [];
  String _checkInType;
  String _selectType = "All";
  List complete = [];
  String merchandizingStatus;
  String orderdetailStatus;
  String invoiceStatus;
  List<MerchandizerNote> merchandizerNote;
  String _printerCtrl;
  
  List<PrinterBluetooth> _devices = [];
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  String date;
  int shoplength = 0;
  int mcdShopList = 0;
  int mcdUploadedList = 0;
  var checkData = 0;
  var checkshoplength = 0;

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  bool shopLoading = true;

  Future<void> getShopName() async {
    final Future<Database> db = helperShopsbyUser.initializedDatabase();
    await db.then((database) {
      Future<List<ShopByUserNote>> noteListFuture =
          helperShopsbyUser.getNoteList();
      noteListFuture.then((note) {
        setState(() {
          this.noteListShopByUserNote = note;

          if (noteListShopByUserNote.length == 0) {
            shopLoading = false;
          }

          for (var i = 0; i < noteListShopByUserNote.length; i++) {
            shopName.add(noteListShopByUserNote[i].shopname);
            shopPhone.add(noteListShopByUserNote[i].phoneno);
            shopAddress.add(noteListShopByUserNote[i].address);
            shopNameMm.add(noteListShopByUserNote[i].shopnamemm);
            shopType.add(noteListShopByUserNote[i].type);
            comment.add(noteListShopByUserNote[i].comment);

            if (i == noteListShopByUserNote.length - 1) {
              shoplength = noteListShopByUserNote.length;

              if (noteListShopByUserNote
                      .where((val) =>
                          val.type == "" ||
                          val.type == "TEMPCHECKOUT" ||
                          val.type == "STORECLOSED")
                      .toList()
                      .length ==
                  0) {
                Future<List<MerchandizerNote>> noteListFuture =
                    MerchandizerDatabase().getNoteList();
                noteListFuture.then((note) async {
                  this.merchandizerNote = note;

                  final SharedPreferences preferences =
                      await SharedPreferences.getInstance();

                  List<MerchandizerNote> allshop = merchandizerNote
                      .where((element) =>
                          element.completeCheck == "McdCompleted" &&
                          element.userSyskey == preferences.getString("userId"))
                      .toList();

                  if (allshop.length == 0) {
                    setState(() {
                      shopLoading = false;
                    });
                  } else {
                    List allshopList = [];
                    for (var m = 0; m < allshop.length; m++) {
                      allshopList.add(allshop[m].shopSyskey);

                      if (m == allshop.length - 1) {
                        mcdShopList = allshopList.toSet().toList().length;
                        List<MerchandizerNote> uploaded = merchandizerNote
                            .where((element) =>
                                element.shopComplete == "ShopCompleted" &&
                                element.userSyskey ==
                                    preferences.getString("userId"))
                            .toList();

                        if (uploaded.length == 0) {
                          setState(() {
                            shopLoading = false;
                          });
                        } else {
                          List uploadedList = [];

                          for (var n = 0; n < uploaded.length; n++) {
                            uploadedList.add(uploaded[n].shopSyskey);

                            if (n == uploaded.length - 1) {
                              setState(() {
                                mcdUploadedList =
                                    uploadedList.toSet().toList().length;
                                shopLoading = false;
                              });
                            }
                          }
                        }
                      }
                    }
                  }
                });
              } else {
                for (var v = 0;
                    v <
                        noteListShopByUserNote
                            .where((val) =>
                                val.type == "" ||
                                val.type == "TEMPCHECKOUT" ||
                                val.type == "STORECLOSED")
                            .toList()
                            .length;
                    v++) {
                  dropDownShop.add(noteListShopByUserNote
                      .where((val) =>
                          val.type == "" ||
                          val.type == "TEMPCHECKOUT" ||
                          val.type == "STORECLOSED")
                      .toList()[v]
                      .shopname);

                  if (v ==
                      noteListShopByUserNote
                              .where((val) =>
                                  val.type == "" ||
                                  val.type == "TEMPCHECKOUT" ||
                                  val.type == "STORECLOSED")
                              .toList()
                              .length -
                          1) {
                    Future<List<MerchandizerNote>> noteListFuture =
                        MerchandizerDatabase().getNoteList();
                    noteListFuture.then((note) async {
                      this.merchandizerNote = note;

                      final SharedPreferences preferences =
                          await SharedPreferences.getInstance();

                      List<MerchandizerNote> allshop = merchandizerNote
                          .where((element) =>
                              element.completeCheck == "McdCompleted" &&
                              element.userSyskey ==
                                  preferences.getString("userId"))
                          .toList();

                      print(allshop.length);

                      if (allshop.length == 0) {
                        setState(() {
                          shopLoading = false;
                        });
                      } else {
                        List allshopList = [];
                        for (var m = 0; m < allshop.length; m++) {
                          allshopList.add(allshop[m].shopSyskey);

                          if (m == allshop.length - 1) {
                            mcdShopList = allshopList.toSet().toList().length;
                            List<MerchandizerNote> uploaded = merchandizerNote
                                .where((element) =>
                                    element.shopComplete == "ShopCompleted" &&
                                    element.userSyskey ==
                                        preferences.getString("userId"))
                                .toList();

                            if (uploaded.length == 0) {
                              setState(() {
                                shopLoading = false;
                              });
                            } else {
                              List uploadedList = [];

                              for (var n = 0; n < uploaded.length; n++) {
                                uploadedList.add(uploaded[n].shopSyskey);

                                if (n == uploaded.length - 1) {
                                  setState(() {
                                    mcdUploadedList =
                                        uploadedList.toSet().toList().length;
                                    shopLoading = false;
                                  });
                                }
                              }
                            }
                          }
                        }
                      }
                    });
                  }
                }
              }
            }
          }
        });
      }).catchError((error) {
        snackbarmethod("Getting Shop List Error ==> $error");
      });
    });
  }

  Timer checkCurloctimer;

  Screen _screen;
  StreamSubscription<ScreenStateEvent> _subscription;

  @override
  void initState() {
    super.initState();

    const oneSecond = const Duration(seconds: 5);
    checkCurloctimer = Timer.periodic(
        oneSecond,
        (Timer t) => setState(() {
              if (widget.date != date) {
                sessionExpired();
                t.cancel();
                print("expired");
              } else {}
            }));
    getShopName();
    initPlatformState(mounted);
  }

  @override
  void dispose() {
    checkCurloctimer.cancel();
    super.dispose();
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

  Future<void> sessionExpired() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0))),
            content: Container(
              height: 52,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10),
                  Text("Session has expired please login again.",
                      style: TextStyle(fontSize: 16)),
                ],
              ),
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
                onPressed: () async {
                  final SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  preferences.setString("OrgId", "");
                  preferences.setString("userId", "");
                  preferences.setString("userName", "");
                  preferences.setString("merchandizer", "");
                  preferences.setString("latitude", "");
                  preferences.setString("longitude", "");
                  preferences.setString("date", "");
                  preferences.setString("address", "");
                  preferences.setString("shopname", "");
                  preferences.setString("shopCode", "");
                  preferences.setString("merchandiserSts", "");
                  preferences.setString("OrderDetailSts", "");
                  preferences.setString("InvoiceSts", "");
                  preferences.setString("checkMerchandizing", "");
                  preferences.setString('phNo', "");
                  preferences.setString('email', "");
                  preferences.setString("printerName", "");
                  preferences.setString("PrintType", "");
                  preferences.setString("subTotal", "");
                  preferences.setString("returnTotal", "");
                  preferences.setString("saveImageSts", "");
                  preferences.setString("DeliveryDate", "");
                  preferences.setString("orderdetailSyskey", "");
                  preferences.setString("OriginalStockList", "");
                  preferences.setString("ReturnStockList", "");
                  print(preferences.getString("OrgId"));
                  ReturnDatabase().deleteAllNote();
                  MerchandizerDatabase().deleteAllNote();
                  dbOrder.deleteAllNote();
                  shopbyUser.deleteAllNote();
                  shopbyTeam.deleteAllNote();
                  McdDatabase().deleteAllNote();
                  var dir = await getExternalStorageDirectory();
                  var knockDir = await new Directory('${dir.path}')
                      .create(recursive: true);

                  await knockDir.delete(recursive: true);

                  imageCache.clear();

                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login()));
                },
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  Future _startScanDevices() async {
    printerManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;

        print("Draw Picture Format ==> $_devices");
      });
    });
    printerManager.startScan(Duration(seconds: 4));
  }

  Future<void> showPrinterCard() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    String _printerType = 'Direct Print';

    print(preferences.getString("printerName"));

    if (preferences.getString("printerName") != null &&
        preferences.getString("printerName") != "") {
      _printerCtrl = preferences.getString("printerName");
    }

    if(preferences.getString("PrintType") == "Java") {
      _printerType = "Draw Picture Format";
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0.0))),
                title: Text('Printer'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Print Options", style: TextStyle(fontSize: 12, color: Colors.grey),),
                    SizedBox(height: 7),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]),
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButtonFormField<String>(
                          value: _printerType,
                          items: <String>['Draw Picture Format', 'Direct Print'].map<DropdownMenuItem<String>>((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: InputDecoration.collapsed(hintText: ''),
                          onChanged: (value) {
                            if(_printerType == value) {
                              //
                            } else {
                              if(value == 'Draw Picture Format') {
                                _handleSubmit(context);
                                _startScanDevices().then((scanValue) {
                                  Future.delayed(Duration(seconds: 4), () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _devices = _devices;
                                    });
                                  });
                                  
                                  setState(() {
                                    _printerType = value;
                                    _printerCtrl = null;
                                  });
                                });
                              } else {
                                _handleSubmit(context);
                                initPlatformState(mounted).then((scanValue) {
                                  Navigator.pop(context);
                                  setState(() {
                                    _printerType = value;
                                    _printerCtrl = null;
                                  });
                                });
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.print,
                          size: 25,
                          color: Color(0xffef5350),
                        ),
                        Container(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            value: _printerCtrl,
                            items: _printerType == 'Draw Picture Format' ? 
                            _devices.map<DropdownMenuItem<String>>((value) {
                              return DropdownMenuItem<String>(
                                value: value.name,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 14),
                                  child: Container(
                                      width: 150, child: Text(value.name)),
                                ),
                              );
                            }).toList() : 
                            devices.map<DropdownMenuItem<String>>((value) {
                              return DropdownMenuItem<String>(
                                value: value.name,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 14),
                                  child: Container(
                                      width: 150, child: Text(value.name)),
                                ),
                              );
                            }).toList(),
                            decoration: InputDecoration.collapsed(hintText: ''),
                            hint: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 14),
                                  child: Text('Select Printer'),
                                ),
                              ],
                            ),
                            onChanged: (value) {
                              setState(() {
                                _printerCtrl = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.cancel, color: Color(0xffe53935)),
                        Text('Close', style: TextStyle(color: Color(0xffe53935))),
                      ],
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  FlatButton(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.check,
                          color: Color(0xffe53935),
                        ),
                        Text(
                          'Connect',
                          style: TextStyle(color: Color(0xffe53935)),
                        ),
                      ],
                    ),
                    onPressed: () {
                      if (_printerCtrl == null || _printerCtrl == '') {
                        failToast("Please Choose Device!");
                      } else {
                        Navigator.pop(context);
                        if(_printerType == "Draw Picture Format") {
                          javafilePrinter();
                        } else {
                          blueThermalPrinter();
                        }
                      }
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
      },
    );
  }

  void blueThermalPrinter() {
    for (var index = 0; index < devices.length; index++) {
      if (devices[index].name == _printerCtrl) {
        connect(context, devices[index]);
      }
    }
  }

  String prefReadAddress;
  Future<void> javafilePrinter() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("printerName",_printerCtrl);
    for (var index = 0; index < _devices.length; index++) {
      if (_devices[index].name == _printerCtrl) {
        prefReadAddress = _devices[index].address;
        startScanNative(prefReadAddress);
      }
    }
  }

  static const platform = const MethodChannel('flutter.native/helper');
  Future<void> startScanNative(String macAddress) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      preferences.setString("PrintType", "Java");
      print("1111111122222222222");
      final String result = await platform.invokeMethod('startScan', {
        "macAddress": macAddress,
      });
      print("55555555555555");
      print('start scan >>$result');
    } on PlatformException catch (e) {
      print('Failed to Invoke: ${e.message}');
    }
  }

  Future<void> blueToothAlert(String title) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
          // title: Text(""),
          content: Container(
            height: 33,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10),
                Text(title, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              color: Color(0xffe53935),
              child: Text('OK', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(width: 10)
          ],
        );
      },
    );
  }

  onMenuSelection(PopupMenuChoice value) async {
    switch (value) {
      case PopupMenuChoice.printerSetting:
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        if(preferences.getString("PrintType") == "Java" && _devices.length == 0) {
          _handleSubmit(context);
          _startScanDevices().then((scanValue) {
            Future.delayed(Duration(seconds: 4), () {
              Navigator.pop(context);
              setState(() {
                _devices = _devices;
                showPrinterCard();
              });
            });
          });
        } else {
          showPrinterCard();
        }
        break;
      case PopupMenuChoice.changePassowrd:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChangePassword()));
        break;
      // case PopupMenuChoice.profile:
      //   Navigator.push(
      //       context, MaterialPageRoute(builder: (context) => NAProfile()));
      //   break;
      case PopupMenuChoice.logout:
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        preferences.setString("OrgId", "");
        preferences.setString("userId", "");
        preferences.setString("userName", "");
        preferences.setString("merchandizer", "");
        preferences.setString("latitude", "");
        preferences.setString("longitude", "");
        preferences.setString("date", "");
        preferences.setString("address", "");
        preferences.setString("shopname", "");
        preferences.setString("shopCode", "");
        preferences.setString("merchandiserSts", "");
        preferences.setString("OrderDetailSts", "");
        preferences.setString("InvoiceSts", "");
        preferences.setString("checkMerchandizing", "");
        preferences.setString('phNo', "");
        preferences.setString('email', "");
        preferences.setString("printerName", "");
        preferences.setString("PrintType", "");
        preferences.setString("subTotal", "");
        preferences.setString("returnTotal", "");
        preferences.setString("saveImageSts", "");
        preferences.setString("DeliveryDate", "");
        preferences.setString("orderdetailSyskey", "");
        ReturnDatabase().deleteAllNote();
        dbOrder.deleteAllNote();
        shopbyUser.deleteAllNote();
        shopbyTeam.deleteAllNote();
        // imageCache.clear();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
        break;

      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.now();
    String year = dateTime.toString().substring(0, 4);
    String month = dateTime.toString().substring(5, 7);
    String day = dateTime.toString().substring(8, 10);
    date = year + month + day;
    Widget body = SingleChildScrollView(
        child: Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.only(left: 5, right: 5, bottom: 7, top: 7),
        child: GestureDetector(
          onTap: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LoadingDialog(
                          date: widget.date,
                        )));
          },
          child: Card(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE57373), Color(0xFFB71C1C)],
                  ),
                  borderRadius: BorderRadius.circular(6.0),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xFFB71C1C).withOpacity(.3),
                        offset: Offset(0.0, 8.0),
                        blurRadius: 8.0),
                  ]),
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(""),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.sync, color: Colors.white),
                      Text(
                        "  Upload Merchandizing Data",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    "$mcdUploadedList / $mcdShopList",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 5, right: 5, bottom: 7, top: 7),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: <Widget>[
              Card(
                child: Container(
                    height: 50,
                    width: (MediaQuery.of(context).size.width * (2 / 3)) - 10,
                    child: TextField(
                        textAlign: TextAlign.start,
                        cursorColor: Colors.black54,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) {
                          setState(() {
                            _selectType = "All";
                            shopName = [];
                            shopPhone = [];
                            shopAddress = [];
                            shopNameMm = [];
                            shopType = [];
                            comment = [];
                            List<ShopByUserNote> shopList = [];

                            shoplength = noteListShopByUserNote.length;

                            shopList = noteListShopByUserNote
                                .where((element) =>
                                    element.shopname
                                        .toString()
                                        .toLowerCase()
                                        .contains(
                                            value.toString().toLowerCase()) ||
                                    element.shopnamemm
                                        .toString()
                                        .toLowerCase()
                                        .contains(
                                            value.toString().toLowerCase()))
                                .toList();

                            for (var i = 0; i < shopList.length; i++) {
                              shopName.add(shopList[i].shopname);
                              shopPhone.add(shopList[i].phoneno);
                              shopAddress.add(shopList[i].address);
                              shopNameMm.add(shopList[i].shopnamemm);
                              shopType.add(shopList[i].type);
                              comment.add(shopList[i].comment);
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle:
                              TextStyle(color: Colors.black.withOpacity(0.2)),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 9, vertical: 16),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.black45,
                          ),
                        ))),
              ),
              Container(
                width: (MediaQuery.of(context).size.width * (1 / 3)) - 10,
                height: 65,
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectType,
                  icon: Padding(
                      padding: const EdgeInsets.only(top: 10, right: 10),
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            "assets/filter.png",
                            width: 15,
                            color: _selectType == "To Deliver"
                                ? Colors.redAccent
                                : _selectType == "Completed"
                                    ? Colors.greenAccent
                                    : _selectType == "Store Closed"
                                        ? Colors.redAccent
                                        : _selectType == "Pending"
                                            ? Colors.orangeAccent
                                            : _selectType == "Temp Checkout"
                                                ? Colors.orangeAccent
                                                : Colors.black,
                          ),
                          SizedBox(width: 7),
                          Text(
                            "$shoplength",
                            style: TextStyle(
                                color: _selectType == "To Deliver"
                                    ? Colors.redAccent
                                    : _selectType == "Completed"
                                        ? Colors.greenAccent
                                        : _selectType == "Store Closed"
                                            ? Colors.redAccent
                                            : _selectType == "Pending"
                                                ? Colors.orangeAccent
                                                : _selectType == "Temp Checkout"
                                                    ? Colors.orangeAccent
                                                    : Colors.black),
                          ),
                        ],
                      )),
                  items: [
                    "All",
                    "To Deliver",
                    "Completed",
                    "Store Closed",
                    "Pending",
                    "Temp Checkout"
                  ].map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Center(
                          child: Container(
                            width: 400,
                            child: Container(
                                width: 70,
                                child: Text(value,
                                    style: TextStyle(fontSize: 13))),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectType = value;

                      shopName = [];
                      shopPhone = [];
                      shopAddress = [];
                      shopNameMm = [];
                      shopType = [];
                      comment = [];
                      List<ShopByUserNote> shopList = [];
                      if (_selectType == "All") {
                        shopList = noteListShopByUserNote;
                      } else if (_selectType == "To Deliver") {
                        shopList = noteListShopByUserNote
                            .where((element) => element.type.toString() == "")
                            .toList();
                      } else if (_selectType == "Completed") {
                        shopList = noteListShopByUserNote
                            .where((element) =>
                                element.type.toString() == "CHECKOUT")
                            .toList();
                      } else if (_selectType == "Store Closed") {
                        shopList = noteListShopByUserNote
                            .where((element) =>
                                element.type.toString() == "STORECLOSED")
                            .toList();
                      } else if (_selectType == "Pending") {
                        shopList = noteListShopByUserNote
                            .where((element) =>
                                element.type.toString() == "CHECKIN")
                            .toList();
                      } else if (_selectType == "Temp Checkout") {
                        shopList = noteListShopByUserNote
                            .where((element) =>
                                element.type.toString() == "TEMPCHECKOUT")
                            .toList();
                      }

                      shoplength = shopList.length;

                      for (var i = 0; i < shopList.length; i++) {
                        shopName.add(shopList[i].shopname);
                        shopPhone.add(shopList[i].phoneno);
                        shopAddress.add(shopList[i].address);
                        shopNameMm.add(shopList[i].shopnamemm);
                        shopType.add(shopList[i].type);
                        comment.add(shopList[i].comment);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      Container(
        height: MediaQuery.of(context).size.height - 231,
        child: shopName.length == 0 || shopName == []
            ? Center(
                child: Text(
                  "No Data",
                  style: TextStyle(fontSize: 25, color: Colors.grey[400]),
                ),
              )
            : ListView.builder(
                // physics: NeverScrollableScrollPhysics(),
                itemCount: shopName.length,
                itemBuilder: (BuildContext context, int index) {
                  return shopType[index] == "" || shopType[index] == null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          child: Stack(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: GestureDetector(
                                  onLongPress: comment[index] == '' ||
                                          comment[index] == null
                                      ? null
                                      : () {
                                          showMessageAlert(comment[index]);
                                        },
                                  onTap: () async {
                                    shopCheckinOntap(index);
                                  },
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                118,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            150,
                                                    child: Text(
                                                      "${shopName[index]}",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Color(
                                                              0xffe53935)),
                                                    ),
                                                  ),
                                                  Visibility(
                                                      visible: shopNameMm[
                                                                      index] ==
                                                                  null ||
                                                              shopNameMm[
                                                                      index] ==
                                                                  ""
                                                          ? false
                                                          : true,
                                                      child:
                                                          SizedBox(height: 10)),
                                                  Visibility(
                                                    visible: shopNameMm[
                                                                    index] ==
                                                                null ||
                                                            shopNameMm[index] ==
                                                                ""
                                                        ? false
                                                        : true,
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              150,
                                                      child: Text(
                                                        "${shopNameMm[index]}",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: Color(
                                                                0xffe53935)),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    "${shopPhone[index]}",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            Color(0xffe53935)),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    // height:
                                                    //     (("${shopAddress[index]}"
                                                    //                     .length /
                                                    //                 30) *
                                                    //             20) +
                                                    //         10,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            150,
                                                    child: Text(
                                                      "${shopAddress[index]}",
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20),
                                            child: GestureDetector(
                                              onLongPress:
                                                  comment[index] == "" ||
                                                          comment[index] == null
                                                      ? null
                                                      : () {
                                                          showMessageAlert(
                                                              comment[index]);
                                                        },
                                              onTap: () async {
                                                shopCheckinOntap(index);
                                              },
                                              child: Container(
                                                height: 40,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                    color: Color(0xffe53935),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Center(
                                                    child: Text(
                                                  "Start",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                )),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Visibility(
                                        visible: comment[index] == '' ||
                                                comment[index] == null
                                            ? false
                                            : true,
                                        child: GestureDetector(
                                          onTap: () {
                                            showMessageAlert(comment[index]);
                                          }, //
                                          child: Image.asset("assets/email.png",
                                              width: 30),
                                          // child: Icon(Icons.notification_important, color: Colors.redAccent,),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Container(
                                        // width: 90,
                                        height: 25,
                                        color: Colors.redAccent,
                                        child:
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 7),
                                              child: Center(child: Text("To Deliver")),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      : shopType[index] == "CHECKOUT"
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              child: Stack(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: GestureDetector(
                                      onLongPress: comment[index] == '' ||
                                              comment[index] == null
                                          ? null
                                          : () {
                                              showMessageAlert(comment[index]);
                                            },
                                      onTap: () {
                                        completeShopOnTap(index);
                                      },
                                      child: Card(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          // height: 63 +
                                          //     (("${shopAddress[index]}".length / 30) *
                                          //         20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Stack(
                                                children: <Widget>[
                                                  Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                150,
                                                            child: Text(
                                                              "${shopName[index]}",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  color: Color(
                                                                      0xffe53935)),
                                                            ),
                                                          ),
                                                          Visibility(
                                                              visible: shopNameMm[
                                                                              index] ==
                                                                          null ||
                                                                      shopNameMm[
                                                                              index] ==
                                                                          ""
                                                                  ? false
                                                                  : true,
                                                              child: SizedBox(
                                                                  height: 10)),
                                                          Visibility(
                                                            visible: shopNameMm[
                                                                            index] ==
                                                                        null ||
                                                                    shopNameMm[
                                                                            index] ==
                                                                        ""
                                                                ? false
                                                                : true,
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  150,
                                                              child: Text(
                                                                "${shopNameMm[index]}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: Color(
                                                                        0xffe53935)),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Text(
                                                            "${shopPhone[index]}",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Color(
                                                                    0xffe53935)),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Container(
                                                            // height:
                                                            //     (("${shopAddress[index]}"
                                                            //                     .length /
                                                            //                 30) *
                                                            //             20) +
                                                            //         10,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                150,
                                                            child: Text(
                                                              "${shopAddress[index]}",
                                                              style: TextStyle(
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 20),
                                                child: GestureDetector(
                                                  onLongPress: comment[index] ==
                                                              '' ||
                                                          comment[index] == null
                                                      ? null
                                                      : () {
                                                          showMessageAlert(
                                                              comment[index]);
                                                        },
                                                  onTap: () async {
                                                    _handleSubmit(context);
                                                    final SharedPreferences
                                                        preferences =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    String getOrgId =
                                                        preferences
                                                            .getString("OrgId")
                                                            .toString();
                                                    String merchandizer =
                                                        preferences.getString(
                                                            "merchandizer");
                                                    String userType =
                                                        preferences.getString(
                                                            "userType");

                                                    preferences.setString(
                                                        'address',
                                                        shopAddress[index]);
                                                    preferences.setString(
                                                        'shopname',
                                                        shopName[index]);
                                                    preferences.setString(
                                                        "shopnamemm",
                                                        shopNameMm[index]);
                                                    preferences.setString(
                                                        "phNo",
                                                        shopPhone[index]);

                                                    orgId = preferences
                                                        .getString("OrgId")
                                                        .toString();

                                                    var getSysKey =
                                                        helperShopsbyUser
                                                            .getShopSyskey(
                                                                shopName[
                                                                    index]);

                                                    getSysKey.then((val) {
                                                      getVolDisDataForMobile(val[0]["shopsyskey"]).then((volDisData) {
                                                        multiDisDownload(val[0]["shopsyskey"], "").then((multiDisValue) {
                                                          Navigator.pop(context);
                                                          Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationBar(getOrgId, merchandizer, userType, preferences.getString("DateTime"))));
                                                        });
                                                      });
                                                        
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 40,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xffe53935),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Center(
                                                        child: Text(
                                                      "View",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16),
                                                    )),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Visibility(
                                            visible: comment[index] == '' ||
                                                    comment[index] == null
                                                ? false
                                                : true,
                                            child: GestureDetector(
                                              onTap: () {
                                                showMessageAlert(
                                                    comment[index]);
                                              },
                                              child: Image.asset(
                                                  "assets/email.png",
                                                  width: 30),
                                              // child: Icon(Icons.notification_important, color: Colors.redAccent,),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Container(
                                            width: 90,
                                            height: 25,
                                            color: Colors.greenAccent,
                                            child: Center(
                                                child: Text("Completed")),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              child: Stack(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: GestureDetector(
                                      onLongPress: comment[index] == '' ||
                                              comment[index] == null
                                          ? null
                                          : () {
                                              showMessageAlert(comment[index]);
                                            },
                                      onTap: () async {
                                        shopCheckinOntap(index);
                                      },
                                      child: Card(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          // height: 63 +
                                          //     (("${shopAddress[index]}".length / 30) *
                                          //         20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            150,
                                                        child: Text(
                                                          "${shopName[index]}",
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: Color(
                                                                  0xffe53935)),
                                                        ),
                                                      ),
                                                      Visibility(
                                                          visible: shopNameMm[
                                                                          index] ==
                                                                      null ||
                                                                  shopNameMm[
                                                                          index] ==
                                                                      ""
                                                              ? false
                                                              : true,
                                                          child: SizedBox(
                                                              height: 10)),
                                                      Visibility(
                                                        visible: shopNameMm[
                                                                        index] ==
                                                                    null ||
                                                                shopNameMm[
                                                                        index] ==
                                                                    ""
                                                            ? false
                                                            : true,
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              150,
                                                          child: Text(
                                                            "${shopNameMm[index]}",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Color(
                                                                    0xffe53935)),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Text(
                                                        "${shopPhone[index]}",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: Color(
                                                                0xffe53935)),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            150,
                                                        child: Text(
                                                          "${shopAddress[index]}",
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              shopType[index] == "CHECKOUT"
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 20),
                                                      child: GestureDetector(
                                                        onLongPress: comment[
                                                                        index] ==
                                                                    '' ||
                                                                comment[index] ==
                                                                    null
                                                            ? null
                                                            : () {
                                                                showMessageAlert(
                                                                    comment[
                                                                        index]);
                                                              },
                                                        onTap: () async {
                                                          _handleSubmit(
                                                              context);
                                                          final SharedPreferences
                                                              preferences =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          String getOrgId =
                                                              preferences
                                                                  .getString(
                                                                      "OrgId")
                                                                  .toString();
                                                          String merchandizer =
                                                              preferences.getString(
                                                                  "merchandizer");
                                                          String userType =
                                                              preferences
                                                                  .getString(
                                                                      "userType");

                                                          preferences.setString(
                                                              'address',
                                                              shopAddress[
                                                                  index]);
                                                          preferences.setString(
                                                              'shopname',
                                                              shopName[index]);
                                                          preferences.setString(
                                                              "shopnamemm",
                                                              shopNameMm[
                                                                  index]);
                                                          preferences.setString(
                                                              "phNo",
                                                              shopPhone[index]);

                                                          orgId = preferences
                                                              .getString(
                                                                  "OrgId")
                                                              .toString();

                                                          var getSysKey =
                                                              helperShopsbyUser
                                                                  .getShopSyskey(
                                                                      shopName[
                                                                          index]);

                                                          getSysKey.then((val) {
                                                            getVolDisDataForMobile(val[0]["shopsyskey"]).then((volDisData) {
                                                              multiDisDownload(val[0]["shopsyskey"], "").then((multiDisValue) {
                                                                Navigator.pop(
                                                                    context);
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => NavigationBar(
                                                                              getOrgId,
                                                                              merchandizer,
                                                                              userType,
                                                                              preferences.getString("DateTime"))));
                                                              });
                                                            });
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 40,
                                                          width: 80,
                                                          decoration: BoxDecoration(
                                                              color: Color(
                                                                  0xffe53935),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: Center(
                                                              child: Text(
                                                            "View",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16),
                                                          )),
                                                        ),
                                                      ),
                                                    )
                                                  : shopType[index] ==
                                                              "TEMPCHECKOUT" ||
                                                          shopType[index] ==
                                                              "CHECKIN" ||
                                                          shopType[index] ==
                                                              "CHECKIN"
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 20),
                                                          child:
                                                              GestureDetector(
                                                            onLongPress:
                                                                comment[index] ==
                                                                            '' ||
                                                                        comment[index] ==
                                                                            null
                                                                    ? null
                                                                    : () {
                                                                        showMessageAlert(
                                                                            comment[index]);
                                                                      },
                                                            onTap: () async {
                                                              shopCheckinOntap(index);
                                                            },
                                                            child: Container(
                                                              height: 40,
                                                              width: 80,
                                                              decoration: BoxDecoration(
                                                                  color: Color(
                                                                      0xffe53935),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5)),
                                                              child: Center(
                                                                  child: Text(
                                                                "Next",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        16),
                                                              )),
                                                            ),
                                                          ),
                                                        )
                                                      : shopType[index] ==
                                                              "STORECLOSED"
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          20),
                                                              child:
                                                                  GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  shopCheckinOntap(index);
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  width: 80,
                                                                  decoration: BoxDecoration(
                                                                      color: Color(
                                                                          0xffe53935),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    "Start",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16),
                                                                  )),
                                                                ),
                                                              ),
                                                            )
                                                          : Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          20),
                                                              child:
                                                                  GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  shopCheckinOntap(index);
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  width: 80,
                                                                  decoration: BoxDecoration(
                                                                      color: Color(
                                                                          0xffe53935),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    "Next",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16),
                                                                  )),
                                                                ),
                                                              ),
                                                            )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Visibility(
                                            visible: comment[index] == '' ||
                                                    comment[index] == null
                                                ? false
                                                : true,
                                            child: GestureDetector(
                                              onTap: () {
                                                showMessageAlert(
                                                    comment[index]);
                                              },
                                              child: Image.asset(
                                                  "assets/email.png",
                                                  width: 30),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Container(
                                            // width: shopType[index] ==
                                            //         'TEMPCHECKOUT'
                                            //     ? 150
                                            //     : 90,
                                            height: 25,
                                            color: shopType[index] == 'CHECKIN'
                                                ? Colors.orangeAccent
                                                : shopType[index] ==
                                                        'TEMPCHECKOUT'
                                                    ? Colors.orangeAccent
                                                    : shopType[index] ==
                                                            'CHECKOUT'
                                                        ? Colors.greenAccent
                                                        : shopType[index] ==
                                                                'STORECLOSED'
                                                            ? Colors
                                                                .orangeAccent
                                                            : Colors.redAccent,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 7),
                                              child: Center(
                                                  child: Text(shopType[index] ==
                                                          'CHECKIN'
                                                      ? "Pending"
                                                      : shopType[index] ==
                                                              'TEMPCHECKOUT'
                                                          ? "Temporary Check Out"
                                                          : shopType[index] ==
                                                                  'CHECKOUT'
                                                              ? "Completed"
                                                              : shopType[index] ==
                                                                      'STORECLOSED'
                                                                  ? "Store Closed"
                                                                  : "Incomplete")),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                },
              ),
      ),
    ]));

    var loadProgress = new Container(
        child: new Stack(children: <Widget>[
      body,
      Container(
        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 0.5)),
        width: MediaQuery.of(context).size.width * 0.99,
        height: MediaQuery.of(context).size.height * 0.9,
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
        drawer: MyDrawer(devices: _devices),
        key: _scaffoldkey,
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          centerTitle: true,
          title: new Center(
              child: Text(
            "Shop List",
            textAlign: TextAlign.center,
            style: new TextStyle(
                fontSize: 20,
                letterSpacing: 1.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          )),
          actions: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: PopupMenuButton<dynamic>(
                      onSelected: (value) => onMenuSelection(value),
                      icon: Icon(Icons.more_vert, color: Colors.white),
                      itemBuilder: (BuildContext contex) {
                        return [
                          PopupMenuItem<PopupMenuChoice>(
                            child: Center(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 10),
                                  Text("Settings",
                                      style: TextStyle(
                                          color: Color(0xffff0800)
                                              .withOpacity(0.6),
                                          fontSize: 18,
                                          fontFamily: "Abel-Regular")),
                                  SizedBox(height: 10),
                                  Divider(color: Colors.grey)
                                ],
                              ),
                            ),
                          ),
                          PopupMenuItem<PopupMenuChoice>(
                            value: PopupMenuChoice.printerSetting,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.settings_applications,
                                    color: Color(0xffe53935)),
                                SizedBox(width: 10),
                                Text("Printer Setting",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xffe53935),
                                        fontFamily: "Abel-Regular")),
                              ],
                            ),
                          ),
                          PopupMenuItem<PopupMenuChoice>(
                            value: PopupMenuChoice.changePassowrd,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.lock, color: Color(0xffe53935)),
                                SizedBox(width: 10),
                                Text("Change Password",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xffe53935),
                                        fontFamily: "Abel-Regular")),
                              ],
                            ),
                          ),
                          PopupMenuItem<PopupMenuChoice>(
                            value: PopupMenuChoice.logout,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.exit_to_app,
                                    color: Color(0xffe53935)),
                                SizedBox(width: 10),
                                Text("Logout",
                                    style: TextStyle(
                                        color: Color(0xffe53935),
                                        fontFamily: "Abel-Regular")),
                              ],
                            ),
                          ),
                        ];
                      },
                    ))
              ],
            ),
          ],
        ),
        body: shopLoading ? loadProgress : body,
      ),
    );
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  Future<void> _handleSubmit(BuildContext context) async {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader);
    } catch (error) {
      print(error);
    }
  }

  void _askPermission1(String shopName, String shopNameMM) {
    PermissionHandler()
        .requestPermissions([PermissionGroup.locationWhenInUse]).then((val) {
      _onStatusRequested1(val, shopName, shopNameMM);
    });
  }

  void _askPermission2(String shopName, String shopNameMM) {
    PermissionHandler()
        .requestPermissions([PermissionGroup.locationWhenInUse]).then((val) {
      _onStatusRequested2(val, shopName, shopNameMM);
    });
  }

  void _updateStatus(PermissionStatus status) {
    if (status != _status) {
      setState(() {
        _status = status;
      });
    }
  }

  void _onStatusRequested1(Map<PermissionGroup, PermissionStatus> statuses,
      String shopName, String shopNameMM) {
    final status = statuses[PermissionGroup.locationWhenInUse];
    if (status != PermissionStatus.granted) {
      AppSettings.openLocationSettings();
    } else {
      _handleSubmit(context);

      _updateStatus(status);
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) {
        setState(() {
          userLocation = position;
          if (userLocation == null) {
            Navigator.pop(context);
            snackbarmethod("Getting Location Error!");
          } else {
            final df = new DateFormat('dd-MM-yyyy hh:mm a');
            var nowDate = df.format(new DateTime.now());
            if (userLocation.latitude != null &&
                userLocation.longitude != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShopList(date: widget.date)));
            } else {
              Navigator.pop(context);
            }
            shopCheckIn(userLocation.latitude, userLocation.longitude, nowDate,
                shopName, shopNameMM);
          }
        });
      }).catchError((e) {
        Navigator.pop(context);
        snackbarmethod(e);
      });
    }
  }

  void _onStatusRequested2(Map<PermissionGroup, PermissionStatus> statuses,
      String shopName, String shopNameMM) {
    final status = statuses[PermissionGroup.locationWhenInUse];
    if (status != PermissionStatus.granted) {
      AppSettings.openLocationSettings();
    } else {
      _handleSubmit(context);

      _updateStatus(status);

      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) {
        setState(() {
          userLocation = position;
          if (userLocation == null) {
            Navigator.pop(context);
            snackbarmethod("Getting Location Error!");
          } else {
            final df = new DateFormat('dd-MM-yyyy hh:mm a');
            var nowDate = df.format(new DateTime.now());
            if (userLocation.latitude != null &&
                userLocation.longitude != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShopList(date: widget.date)));
            } else {
              Navigator.pop(context);
            }
            pendingCheckin(userLocation.latitude, userLocation.longitude,
                nowDate, shopName, shopNameMM);
          }
        });
      }).catchError((e) {
        Navigator.pop(context);
        snackbarmethod(e);
      });
    }
  }

  void _update(String type, int id) async {
    await helperShopsbyUser.updateType(type, id);
  }

  
  void shopCheckinOntap(index) async {
    var connectivityResult =
        await Connectivity()
            .checkConnectivity();
    if (connectivityResult ==
            ConnectivityResult.mobile ||
        connectivityResult ==
            ConnectivityResult.wifi) {
      if (shopType[index] == "") {
        // _askPermission1(
        //     shopName[index], shopNameMm[index]);
        final df = new DateFormat(
            'dd-MM-yyyy hh:mm a');
        var nowDate =
            df.format(new DateTime.now());
        shopCheckIn(0.0, 0.0, nowDate,
            shopName[index], shopNameMm[index]);
      } else {
        // _askPermission2(
        //     shopName[index], shopNameMm[index]);
        final df = new DateFormat(
            'dd-MM-yyyy hh:mm a');
        var nowDate =
            df.format(new DateTime.now());
        pendingCheckin(0.0, 0.0, nowDate,
            shopName[index], shopNameMm[index]);
      }
    } else {
      snackbarmethod("Check your connection!");
    }
  }


  Future<void> shopCheckIn(double lati, double longi, var checkinDate,
      String shopName, String shopNamemm) async {
    double width = MediaQuery.of(context).size.width * 0.5;

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
          title: Text('Check In'),
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
                        width: width, child: Text("$shopName ($shopNamemm)")),
                  )
                ],
              ),
              SizedBox(
                height: 18,
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
                    child: Text("$checkinDate"),
                  )
                ],
              ),
              SizedBox(
                height: 18,
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
                          "$lati / $longi",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 18,
              ),
              Row(
                children: <Widget>[
                  Image.asset(
                    "assets/four.png",
                    width: 24,
                    color: Color(0xffef5350),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Container(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: _checkInType,
                        items: ["Check In", "Store Closed"]
                            .map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: Text(value),
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration.collapsed(hintText: ''),
                        hint: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: Text('Select Type'),
                              // child: Text(_checkInType),
                            ),
                          ],
                        ),
                        onChanged: (value) {
                          setState(() {
                            _checkInType = value;
                            print(value);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 18,
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
                      child: Text("Unregister"),
                    ),
                  )
                ],
              ),
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
                getShopName().then((val) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ShopList(date: widget.date);
                  }));
                });
              },
            ),
            // SizedBox(
            //   width: 50,
            // ),
            FlatButton(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.check,
                    color: Color(0xffe53935),
                  ),
                  Text(
                    'Next',
                    style: TextStyle(color: Color(0xffe53935)),
                  ),
                ],
              ),
              onPressed: () async {
                bool loading = false;

                var connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult == ConnectivityResult.mobile ||
                    connectivityResult == ConnectivityResult.wifi) {
                  if (_checkInType == null || _checkInType == '') {
                    Fluttertoast.showToast(
                        msg: "Please select type",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else {
                    var getSysKey = helperShopsbyUser.getShopSyskey(shopName);

                    setState(() {
                      loading = true;
                    });

                    if (loading == true) {
                      _handleSubmit(context);
                    }

                    getSysKey.then((val) {
                      // for (var i = 0; i < val.length; i++) {
                      getStoreSts(preferences.getString("spsyskey"),
                              val[0]["shopsyskey"])
                          .then((storestsValues) {
                        if (storestsValues == "success") {
                          setState(() {
                            merchandizingStatus = merchandizingSts;
                            orderdetailStatus = orderdetailSts;
                            invoiceStatus = invoiceSts;

                            if (_checkInType == "Check In") {
                              getVolDisDataForMobile(val[0]["shopsyskey"])
                                  .then((getDisVal) {
                                multiDisDownload(val[0]["shopsyskey"], "").then((multiDisValue) {
                                  getPriceZoneDownload(val[0]["shopsyskey"]).then((priceZoneDownloadVal) {
                                if(priceZoneDownloadVal == "success") {
                                    checkIn(
                                          lati,
                                          longi,
                                          shopName,
                                          val[0]["shopcode"],
                                          shopNamemm,
                                          val[0]["address"],
                                          val[0]["phoneno"],
                                          val[0]["email"],
                                          val[0]["shopsyskey"],
                                          "CHECKIN",
                                          merchandizingStatus,
                                          orderdetailStatus,
                                          invoiceStatus)
                                      .then((checkinValue) async {
                                    print(checkinValue);
                                    if (checkinValue == 'success') {
                                          setState(() {
                                            loading = false;
                                          });

                                          if (preferences
                                                  .getString("merchandizer") ==
                                              "Yes") {
                                            // getAllItems(shopName);

                                            // _update("CHECKIN", val[i]["id"]);
                                            if (loading == false) {
                                              // showCompleteAlert("SUCCESS");
                                              Fluttertoast.showToast(
                                                  msg: "Checkin Successfully",
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIos: 1,
                                                  backgroundColor: Colors.green,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0);

                                              final SharedPreferences
                                                  preferences =
                                                  await SharedPreferences
                                                      .getInstance();
                                              String getOrgId = preferences
                                                  .getString("OrgId")
                                                  .toString();
                                              String merchandizer = preferences
                                                  .getString("merchandizer");
                                              String userType = preferences
                                                  .getString("userType");

                                              orgId = preferences
                                                  .getString("OrgId")
                                                  .toString();

                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          NavigationBar(
                                                              getOrgId,
                                                              merchandizer,
                                                              userType,
                                                              preferences.getString(
                                                                  "DateTime"))));
                                            }
                                          } else {
                                            setState(() {
                                              loading = false;
                                            });
                                            if (loading == false) {
                                              Fluttertoast.showToast(
                                                  msg: "Checkin Successfully",
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIos: 1,
                                                  backgroundColor: Colors.green,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0);

                                              final SharedPreferences
                                                  preferences =
                                                  await SharedPreferences
                                                      .getInstance();
                                              String getOrgId = preferences
                                                  .getString("OrgId")
                                                  .toString();
                                              String merchandizer = preferences
                                                  .getString("merchandizer");
                                              String userType = preferences
                                                  .getString("userType");

                                              orgId = preferences
                                                  .getString("OrgId")
                                                  .toString();

                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          NavigationBar(
                                                              getOrgId,
                                                              merchandizer,
                                                              userType,
                                                              preferences.getString(
                                                                  "DateTime"))));
                                            }
                                          }
                                    } else if (checkinValue == "fail") {
                                      setState(() {
                                        loading = false;
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ShopList(date: widget.date)));
                                      Fluttertoast.showToast(
                                          msg: "Store Closed Fail!",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIos: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    } else {
                                      setState(() {
                                        loading = false;
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ShopList(date: widget.date)));
                                      Fluttertoast.showToast(
                                          msg: checkinValue,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIos: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    }
                                  });
                                  } else if(priceZoneDownloadVal == "fail") {
                                  setState(() {
                                    loading = false;
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ShopList(date: widget.date)));
                                  Fluttertoast.showToast(
                                      msg: "FAIL!",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {
                                  setState(() {
                                    loading = false;
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ShopList(date: widget.date)));
                                  Fluttertoast.showToast(
                                      msg: priceZoneDownloadVal,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              });
                                  });
                              });
                            } else if (_checkInType == "Store Closed") {
                              getVolDisDataForMobile(val[0]["shopsyskey"])
                                  .then((getDisVal) {
                                multiDisDownload(val[0]["shopsyskey"], "").then((multiDisValue) {
                                    checkIn(
                                          lati,
                                          longi,
                                          shopName,
                                          val[0]["shopcode"],
                                          shopNamemm,
                                          val[0]["address"],
                                          val[0]["phoneno"],
                                          val[0]["email"],
                                          val[0]["shopsyskey"],
                                          "STORECLOSED",
                                          merchandizingStatus,
                                          orderdetailStatus,
                                          invoiceStatus)
                                      .then((checkinValue) async {
                                    if (checkinValue == 'success') {
                                      // getAllItems(shopName);

                                      // _update("STORECLOSED", val[i]["id"]);
                                      preferences.setString('latitude', "");
                                      preferences.setString('longitude', "");
                                      preferences.setString('date', "");
                                      preferences.setString('address', "");
                                      preferences.setString('shopname', "");
                                      preferences.setString("shopnamemm", "");

                                      // setState(() {
                                      //   loading = false;
                                      // });
                                      shopbyUser.deleteAllNote();
                                      shopbyTeam.deleteAllNote();

                                      datetime();

                                      var check;

                                      final url = '$domain' + 'shop/getshopall';
                                      var param = jsonEncode({
                                        "spsyskey":
                                            "${preferences.getString('spsyskey')}",
                                        "teamsyskey": "",
                                        "usertype": "delivery",
                                        "date": "$date"
                                        // "date": "20201127"
                                      });
                                      print(param);
                                      final response = await http
                                          .post(Uri.encodeFull(url),
                                              body: param,
                                              headers: {
                                                "Accept": "application/json",
                                                "Content-Type":
                                                    "application/json",
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
                                          var result =
                                              json.decode(response.body);
                                          print(result['status']);
                                          print(result['data']);
                                          if (result['data']["shopsByUser"]
                                                  .toString() ==
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
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return ShopList(
                                                  date: preferences
                                                      .getString("DateTime"));
                                            }));
                                          }
                                          for (var i = 0;
                                              i <
                                                  result['data']['shopsByUser']
                                                      .length;
                                              i++) {
                                            shopbyUser
                                                .insertNote(ShopByUserNote(
                                                    result['data']['shopsByUser'][i]['isSaleOrderLessRouteShop']
                                                        .toString(),
                                                    result['data']['shopsByUser']
                                                            [i]['address']
                                                        .toString(),
                                                    result['data']['shopsByUser']
                                                            [i]['shopnamemm']
                                                        .toString(),
                                                    result['data']['shopsByUser']
                                                            [i]['shopsyskey']
                                                        .toString(),
                                                    result['data']['shopsByUser'][i]['long']
                                                        .toString(),
                                                    result['data']['shopsByUser']
                                                            [i]['phoneno']
                                                        .toString(),
                                                    result['data']['shopsByUser']
                                                            [i]['zonecode']
                                                        .toString(),
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
                                                    result['data']['shopsByUser'][i]["status"]["currentType"]))
                                                .then((insertValue) {
                                              if (i ==
                                                  result['data']['shopsByUser']
                                                          .length -
                                                      1) {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Store Closed Successfully",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    timeInSecForIos: 1,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);

                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return ShopList(
                                                      date:
                                                          preferences.getString(
                                                              "DateTime"));
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
                                    } else if (checkinValue == "fail") {
                                      Fluttertoast.showToast(
                                          msg: "Checkin Fail",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIos: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0);

                                      setState(() {
                                        loading = false;
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ShopList(date: widget.date)));
                                    } else {
                                      setState(() {
                                        loading = false;
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ShopList(date: widget.date)));
                                      Fluttertoast.showToast(
                                          msg: checkinValue,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIos: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    }
                                  });
                                  });
                              });
                            }
                          });
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ShopList(date: widget.date)));
                          Fluttertoast.showToast(
                              msg: "Checkin Fail!",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIos: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      });
                      // }
                    });
                  }
                } else {
                  Fluttertoast.showToast(
                      msg: "Check your connection!",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
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

  Future<void> pendingCheckin(double lati, double longi, var date,
      String shopName, String shopNamemm) async {
    double width = MediaQuery.of(context).size.width * 0.4;

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
          title: Text('Check In'),
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
                        width: width, child: Text("$shopName ($shopNamemm)")),
                  )
                ],
              ),
              SizedBox(
                height: 18,
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
                    child: Text("$date"),
                  )
                ],
              ),
              SizedBox(
                height: 18,
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
                          "$lati / $longi",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 18,
              ),
              Row(
                children: <Widget>[
                  Image.asset(
                    "assets/four.png",
                    width: 24,
                    color: Color(0xffef5350),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text("Check In"),
                  )
                ],
              ),
              SizedBox(
                height: 18,
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
                      child: Text("Unregister"),
                    ),
                  )
                ],
              ),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ShopList(date: widget.date);
                }));
              },
            ),
            FlatButton(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.check,
                    color: Color(0xffe53935),
                  ),
                  Text(
                    'Next',
                    style: TextStyle(color: Color(0xffe53935)),
                  ),
                ],
              ),
              onPressed: () async {
                bool loading = false;

                var connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult == ConnectivityResult.mobile ||
                    connectivityResult == ConnectivityResult.wifi) {
                  var getSysKey = helperShopsbyUser.getShopSyskey(shopName);

                  setState(() {
                    loading = true;
                  });

                  if (loading == true) {
                    _handleSubmit(context);
                  }

                  getSysKey.then((val) {
                    // for (var i = 0; i < val.length; i++) {
                    getStoreSts(preferences.getString("spsyskey"),
                            val[0]["shopsyskey"])
                        .then((storestsValue) async {
                      if (storestsValue == "success") {
                        setState(() {
                          merchandizingStatus = merchandizingSts;
                          orderdetailStatus = orderdetailSts;
                          invoiceStatus = invoiceSts;

                          getVolDisDataForMobile(val[0]["shopsyskey"])
                              .then((getDisVal) {
                            multiDisDownload(val[0]["shopsyskey"], "").then((multiDisValue) {
                              getPriceZoneDownload(val[0]["shopsyskey"]).then((priceZoneDownloadVal) {
                                if(priceZoneDownloadVal == "success") {
                                checkIn(
                                      lati,
                                      longi,
                                      shopName,
                                      val[0]["shopcode"],
                                      shopNamemm,
                                      val[0]["address"],
                                      val[0]["phoneno"],
                                      val[0]["email"],
                                      val[0]["shopsyskey"],
                                      "CHECKIN",
                                      merchandizingStatus,
                                      orderdetailStatus,
                                      invoiceStatus)
                                  .then((checkinValue) async {
                                if (checkinValue == 'success') {
                                      if (preferences
                                              .getString("merchandizer") ==
                                          "Yes") {
                                        setState(() {
                                          loading = false;
                                        });
                                        if (loading == false) {
                                          Fluttertoast.showToast(
                                              msg: "Checkin Successfully",
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIos: 1,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                              fontSize: 16.0);

                                          final SharedPreferences preferences =
                                              await SharedPreferences
                                                  .getInstance();
                                          String getOrgId = preferences
                                              .getString("OrgId")
                                              .toString();
                                          String merchandizer = preferences
                                              .getString("merchandizer");
                                          String userType =
                                              preferences.getString("userType");

                                          orgId = preferences
                                              .getString("OrgId")
                                              .toString();

                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NavigationBar(
                                                          getOrgId,
                                                          merchandizer,
                                                          userType,
                                                          preferences.getString(
                                                              "DateTime"))));
                                        }
                                      } else {
                                        setState(() {
                                          loading = false;
                                        });
                                        if (loading == false) {
                                          // showCompleteAlert("SUCCESS");
                                          Fluttertoast.showToast(
                                              msg: "Checkin Successfully",
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIos: 1,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                              fontSize: 16.0);

                                          final SharedPreferences preferences =
                                              await SharedPreferences
                                                  .getInstance();
                                          String getOrgId = preferences
                                              .getString("OrgId")
                                              .toString();
                                          String merchandizer = preferences
                                              .getString("merchandizer");
                                          String userType =
                                              preferences.getString("userType");

                                          orgId = preferences
                                              .getString("OrgId")
                                              .toString();

                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NavigationBar(
                                                          getOrgId,
                                                          merchandizer,
                                                          userType,
                                                          preferences.getString(
                                                              "DateTime"))));
                                        }
                                      }
                                } else if (checkinValue == "fail") {
                                  setState(() {
                                    loading = false;
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ShopList(date: widget.date)));
                                  Fluttertoast.showToast(
                                      msg: "Checkin Fail!",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {
                                  setState(() {
                                    loading = false;
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ShopList(date: widget.date)));
                                  Fluttertoast.showToast(
                                      msg: checkinValue,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              });
                              } else if(priceZoneDownloadVal == "fail") {
                                  setState(() {
                                    loading = false;
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ShopList(date: widget.date)));
                                  Fluttertoast.showToast(
                                      msg: "FAIL!",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {
                                  setState(() {
                                    loading = false;
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ShopList(date: widget.date)));
                                  Fluttertoast.showToast(
                                      msg: priceZoneDownloadVal,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              });
                              });
                          });
                        });
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ShopList(date: widget.date)));
                        Fluttertoast.showToast(
                            msg: "Checkin Fail!",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    });
                    // }
                  });
                } else {
                  Fluttertoast.showToast(
                      msg: "Check your connection!",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
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

  Future<void> completeShopOnTap(int index) async {
    _handleSubmit(context);
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String getOrgId = preferences.getString("OrgId").toString();
    String merchandizer = preferences.getString("merchandizer");
    String userType = preferences.getString("userType");

    orgId = preferences.getString("OrgId").toString();

    preferences.setString('address', shopAddress[index]);
    preferences.setString('shopname', shopName[index]);

    preferences.setString("shopnamemm", shopNameMm[index]);

    preferences.setString("phNo", shopPhone[index]);

    var getSysKey = helperShopsbyUser.getShopSyskey(shopName[index]);

    getSysKey.then((val) {
      getVolDisDataForMobile(val[0]["shopsyskey"]).then((volDisData) {
        multiDisDownload(val[0]["shopsyskey"], "").then((multiDisValue) {
            Navigator.pop(context);
              Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NavigationBar(getOrgId, merchandizer,
                      userType, preferences.getString("DateTime"))));
          });
      });
    });
  }

  Future<void> deliveryOrderDialog(int index, String title) async {
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
                  completeShopOnTap(index);
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

  Future<void> showCheckOutCard() async {
    double width = MediaQuery.of(context).size.width * 0.5;
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String location = preferences.getString("latitude").toString() +
        " / " +
        preferences.getString("longitude");
    String shopName = preferences.getString("shopname");
    String datetime = preferences.getString("date");
    String address = preferences.getString("address");
    String userName = preferences.getString('userName');
    // getdata = preferences.getString("latitude").toString();
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
                  Icon(
                    Icons.account_circle,
                    size: 25,
                    color: Color(0xffef5350),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text("$userName"),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Image.asset(
                    "assets/shop.png",
                    width: 25,
                    color: Color(0xffef5350),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text("$shopName"),
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
                    child: Text("$datetime"),
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
                      child: Text("$address"),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShopList(date: widget.date)));
              },
            ),
            SizedBox(
              width: 50,
            ),
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
                final SharedPreferences preferences =
                    await SharedPreferences.getInstance();

                if (preferences.getString("InvoiceSts") == "SUCCESS") {
                  _handleSubmit(context);

                  Future.delayed(Duration(milliseconds: 100), () async {
                    var getSysKey = helperShopsbyUser
                        .getShopSyskey(preferences.getString('shopname'));

                    getSysKey.then((val) {
                      for (var i = 0; i < val.length; i++) {
                        _update("3", val[i]["id"]);
                      }
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
                    preferences.setString("OrderDetailSts", "");
                    preferences.setString('phNo', "");
                    preferences.setString('email', "");
                    preferences.setString("subTotal", "");
                    preferences.setString("returnTotal", "");
                    preferences.setString("orderdetailSyskey", "");

                    // var dir = await getExternalStorageDirectory();
                    // var knockDir = await new Directory(
                    //         '${dir.path}/$date/$brandOwnerCode/$campaignsyskey/$task')
                    //     .create(recursive: true);

                    // await knockDir.delete(recursive: true);

                    Fluttertoast.showToast(
                        msg: "Transaction Complete",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ShopList(date: widget.date);
                    }));
                  });
                } else {
                  var getSysKey = helperShopsbyUser
                      .getShopSyskey(preferences.getString('shopname'));

                  getSysKey.then((val) {
                    for (var i = 0; i < val.length; i++) {
                      _update("2", val[i]["id"]);
                    }
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

                  // var dir = await getExternalStorageDirectory();
                  // var knockDir = await new Directory(
                  //         '${dir.path}/$date/$brandOwnerCode/$campaignsyskey/$task')
                  //     .create(recursive: true);

                  // await knockDir.delete(recursive: true);

                  Fluttertoast.showToast(
                      msg: "Incomplete Transaction",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);

                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ShopList(date: widget.date);
                  }));
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

  loadDialog() async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setSate) {
                return SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(
                              backgroundColor: Color(0xffe53935),
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            Text("    Uploading..... ",
                                style: TextStyle(color: Color(0xffe53935))),
                            checkshoplength != 0
                                ? Text(
                                    "( " +
                                        "$checkData" +
                                        " / " +
                                        "$checkshoplength" +
                                        " )",
                                    style: TextStyle(color: Color(0xffe53935)))
                                : Container(),
                          ],
                        ),
                      )
                    ]));
              })));
        });
  }
// }
}

class LoadingDialog extends StatefulWidget {
  final String date;
  LoadingDialog({Key key, @required this.date}) : super(key: key);
  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  int checkshoplength = 0;
  int checkData = 0;
  List<MerchandizerNote> merchandizerNote;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  var loading = true;
  Timer timer;

  snackbarmethod(name) {
    _scaffoldkey.currentState.showSnackBar(new SnackBar(
      content: new Text(name, textAlign: TextAlign.center),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ));
  }

  snackbarmethod1(name) {
    _scaffoldkey.currentState.showSnackBar(new SnackBar(
      content: new Text(name, textAlign: TextAlign.center),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ));
  }

  void initState() {
    super.initState();
    loadingDialog();
  }

  Future<void> merchandizedShopList() async {
    final Future<Database> db = MerchandizerDatabase().initializedDatabase();
    await db.then((database) {
      Future<List<MerchandizerNote>> noteListFuture =
          MerchandizerDatabase().getNoteList();
      noteListFuture.then((note) async {
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        this.merchandizerNote = note;

        List merchandizedShop = [];
        List sysKeyList = [];
        List syskey = [];

        merchandizedShop = merchandizerNote
            .where((element) =>
                element.completeCheck == "McdCompleted" &&
                element.shopComplete == "ShopCompleted" &&
                element.userSyskey == preferences.getString("userId"))
            .toList();

        for (var a = 0; a < merchandizedShop.length; a++) {
          sysKeyList.add(merchandizedShop[a].shopSyskey);
        }

        setState(() {
          syskey = sysKeyList.toSet().toList();
          checkData = syskey.length;
        });
      });
    });
  }

  Future<void> loadingDialog() async {
    final Future<Database> db = MerchandizerDatabase().initializedDatabase();
    await db.then((database) {
      Future<List<MerchandizerNote>> noteListFuture =
          MerchandizerDatabase().getNoteList();
      noteListFuture.then((note) async {
        this.merchandizerNote = note;

        final SharedPreferences preferences =
            await SharedPreferences.getInstance();

        List<MerchandizerNote> shopList = [];

        shopList = merchandizerNote
            .where((element) =>
                element.completeCheck == "McdCompleted" &&
                element.shopComplete != "ShopCompleted" &&
                element.userSyskey == preferences.getString("userId"))
            .toList();

        if (shopList == [] || shopList.length == 0) {
          // Navigator.pop(context);
          snackbarmethod("No Merchandizing Data!");
          Future.delayed(Duration(seconds: 1), () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ShopList(date: widget.date)));
          });
        } else {
          List<MerchandizerNote> merchandize = [];
          List remarkList = [];
          List syskey = [];
          List<MerchandizerNote> taskList = [];
          List sysKeyList = [];
          var shop = 0;
          var v = 0;

          for (var a = 0; a < shopList.length; a++) {
            merchandize.add(shopList[a]);
            sysKeyList.add(shopList[a].shopSyskey);
          }

          setState(() {
            syskey = sysKeyList.toSet().toList();
            checkshoplength = syskey.length;
          });

          for (var b = 0; b < syskey.length; b++) {
            // var shopsyskey = syskey[b];
            setState(() {
              taskList = [];
              imageFilePath = [];
              remarkList = [];
            });
            print(
                "before imagefile path ----" + imageFilePath.length.toString());

            for (var c = 0; c < merchandize.length; c++) {
              if (syskey[b] == merchandize[c].shopSyskey) {
                print("merchandize image ---- " + merchandize[c].shopSyskey);

                taskList.add(merchandize[c]);

                remarkList.add(merchandize[c].remark);

                print(merchandize[c].imgPath);
              }
            }
            print("task list length ---- " + taskList.length.toString());
            for (var d = 0; d < taskList.length; d++) {
              var knockDir = await new Directory(taskList[d].imgPath)
                  .create(recursive: true);

              List _images =
                  knockDir.listSync(recursive: true, followLinks: false);
              final url = '$domain' + 'upload/save';
              var check = taskList[d].pathForServer;
              var param;
              List list = [];
              List extdataList = [];
              for (var i = 0; i < _images.length; i++) {
                String imageName = _images[i].toString().substring(
                    _images[i].toString().lastIndexOf("/") + 1,
                    _images[i].toString().length - 1);
                List<int> imageBytes = _images[i].readAsBytesSync();
                String base64Image =
                    "data:image/jpg;base64," + base64Encode(imageBytes);
                list.add(
                  {
                    "path": "$check/$imageName.jpg",
                    "name": "$imageName",
                    "img": "$base64Image"
                  },
                );
              }
              param = jsonEncode({"list": list});
              final response =
                  await http.post(Uri.encodeFull(url), body: param, headers: {
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Content-Over": "${preferences.getString('OrgId')}"
              });

              if (response != null) {
                if (response.statusCode == 200) {
                  var extdata = json.decode(response.body);
                  if (extdata["status"] == 'SUCCESS!') {
                    v = v + 1;
                    extdataList = extdata["list"];
                    for (var i = 0; i < extdataList.length; i++) {
                      imageFilePath.add({
                        "shopSyskey": taskList[d].shopSyskey,
                        "imageName": extdataList[i]["name"].toString(),
                        "imagePath": extdataList[i]["path"].toString()
                      });
                    }
                    print(v);
                    print(taskList.length);
                    if (v == taskList.length) {
                      v = 0;
                      print("////////");
                      print(imageFilePath.length);
                      print("shop syskey ----- " + syskey[b].toString());

                      List merchandizeList = shopList
                          .where((element) =>
                              element.shopSyskey.toString() ==
                              syskey[b].toString())
                          .toList();

                      print(merchandizeList.length);

                      merchandiser(
                              merchandizeList[0].shopSyskey,
                              json.decode(merchandizeList[0].taskToDo),
                              merchandizeList[0].campaignId,
                              merchandizeList[0].brandOwnerId,
                              remarkList,
                              imageFilePath)
                          .then((mcdValue) {
                        if (mcdValue == "success") {
                          shop = shop + 1;
                          setState(() {
                            checkData = checkData + 1;
                          });
                          preferences.setString("imageFilePath", null);
                          MerchandizerDatabase()
                              .updateShopComplete(merchandizeList[0].shopSyskey)
                              .then((value) {
                            print(shop);
                            print(syskey.length);
                            if (checkData == checkshoplength) {
                              // Navigator.pop(context);
                              // Navigator.of(context).pop();
                              print("object");
                              snackbarmethod1("SUCCESS");
                              Future.delayed(Duration(seconds: 1), () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ShopList(date: widget.date)));
                              });
                            }
                          });
                        } else if (mcdValue == "fail") {
                          snackbarmethod("FAIL!");
                          setState(() {
                            loading = false;
                          });
                        } else {
                          setState(() {
                            loading = false;
                          });
                          uploadMerchandizingDialog(mcdValue.toString());
                        }
                      });
                    }
                  } else if (extdata["status"] == 'FAIL!') {
                    snackbarmethod("FAIL!");
                    setState(() {
                      loading = false;
                    });
                  } else {
                    setState(() {
                      loading = false;
                    });
                    uploadMerchandizingDialog(extdata["status"].toString());
                  }
                } else {
                  setState(() {
                    loading = false;
                  });
                  uploadMerchandizingDialog(response.statusCode.toString());
                }
              } else {
                setState(() {
                  loading = false;
                });
                uploadMerchandizingDialog(response.toString());
              }
            }
          }
          if (loading == false) {
            Navigator.of(context).pop();
          }
        }
      }).catchError((error) {
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
        uploadMerchandizingDialog(error.toString());
      });
    }).catchError((error) {
      setState(() {
        loading = false;
      });
      Navigator.pop(context);
      uploadMerchandizingDialog(error.toString());
    });
  }

  Future<void> uploadMerchandizingDialog(String title) async {
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
                  loadingDialog();
                },
              ),
              SizedBox(
                width: 50,
              ),
              FlatButton(
                child:
                    Text('Cancel', style: TextStyle(color: Color(0xffe53935))),
                onPressed: () async {
                  setState(() {
                    loading = false;
                  });
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

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: _scaffoldkey,
          backgroundColor: Colors.transparent,
          body: Stack(
            children: <Widget>[
              ShopList(date: widget.date),
              AlertDialog(content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setSate) {
                return SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(
                              backgroundColor: Color(0xffe53935),
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            Text("    Uploading..... ",
                                style: TextStyle(color: Color(0xffe53935))),
                            checkshoplength != 0
                                ? Text(
                                    "( " +
                                        "$checkData" +
                                        " / " +
                                        "$checkshoplength" +
                                        " )",
                                    style: TextStyle(color: Color(0xffe53935)))
                                : Container(),
                          ],
                        ),
                      )
                    ]));
              })),
            ],
          ),
        ));
  }
}

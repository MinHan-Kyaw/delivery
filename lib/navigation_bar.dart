import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_2/ChangePassword.dart';
import 'package:delivery_2/Login.dart';
import 'package:delivery_2/NA_Home.dart';
import 'package:delivery_2/Widgets/HomeDrawer.dart';
import 'package:delivery_2/database/shopByTeamDatabase.dart';
import 'package:delivery_2/map.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';

import 'database/McdDatabase.dart';
import 'database/MerchandizerDatabase.dart';
import 'database/ReturnDatabase.dart';
import 'database/databasehelper.dart';
import 'database/shopByUserDatabase.dart';
import 'package:delivery_2/Widgets/printer.dart';

class NavigationBar extends StatefulWidget {
  final String getOrgId;
  final String mcdCheck;
  final String userType;
  final String savedDate;
  NavigationBar(this.getOrgId, this.mcdCheck, this.userType, this.savedDate);
  @override
  State<StatefulWidget> createState() {
    return _NavigationBarState(this.getOrgId, this.mcdCheck, this.userType, this.savedDate);
  }
}

enum PopupMenuChoice { changePassowrd, printerSetting, logout }

class _NavigationBarState extends State<NavigationBar>
    with SingleTickerProviderStateMixin {
  String getOrgId;
  String mcdCheck;
  String userType;
  String savedDate;
  ShopsbyUser shopbyUser = ShopsbyUser();
  ShopsbyTeam shopbyTeam = ShopsbyTeam();
  _NavigationBarState(this.getOrgId, this.mcdCheck, this.userType, this.savedDate);
  int _page = 0;
  TabController tabController;
  double longi;
  double lati;
  DbOrder dbOrder = DbOrder();
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  ShopsbyUser helperShopsbyUser = ShopsbyUser();
  ShopsbyTeam helperShopsbyTeam = ShopsbyTeam();
  // List _devices = [];
  String _printerCtrl;
  String _printerType = 'Direct Print';
  Timer checkCurloctimer;
  String date;
  @override
  void initState() {
    super.initState();
    const oneSecond = const Duration(seconds: 5);
    checkCurloctimer = Timer.periodic(
        oneSecond,
        (Timer t) => setState(() {
              if (savedDate != date) {
                sessionExpired();
                t.cancel();
                print("expired");
              } else {
                
              }
            }));
    initPlatformState(mounted);
  }

  
  @override
  void dispose() {
    checkCurloctimer.cancel();
    super.dispose();
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

                  Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
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
        preferences.setString("shopnamemm", "");
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
        ReturnDatabase().deleteAllNote();
        dbOrder.deleteAllNote();
        helperShopsbyUser.deleteAllNote();
        helperShopsbyTeam.deleteAllNote();
        // imageCache.clear();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
        break;

      default:
    }
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  Future<void> _handleSubmit(BuildContext context) async {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader);
    } catch (error) {
      print(error);
    }
  }

  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.now();
    String year = dateTime.toString().substring(0, 4);
    String month = dateTime.toString().substring(5, 7);
    String day = dateTime.toString().substring(8, 10);
    date = year + month + day;
    if (tabController == null) {
      tabController =
          new TabController(length: 2, vsync: this, initialIndex: 0);
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        drawer: HomeDrawer(devices: _devices),
          appBar: AppBar(
            elevation: _page == 2 ? 0 : 2,
            backgroundColor: Color(0xffe53935),
            // automaticallyImplyLeading: false,
            centerTitle: true,
            title: new Center(
                child: userType == "delivery"
                    ? Text(
                        "Delivery",
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontFamily: "Pyidaungsu",
                            fontSize: 25,
                            letterSpacing: 1.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )
                    : new Text(
                        "Survey",
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontFamily: "Pyidaungsu",
                            fontSize: 25,
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
                                          fontSize: 15,
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
          bottomNavigationBar: SizedBox(
              height: 57,
              child: Material(
                child: new TabBar(
                  tabs: <Tab>[
                    new Tab(
                        text: "Home",
                        icon: new Icon(
                          Icons.home,
                          size: 24,
                        )),
                    new Tab(
                        text: "Map",
                        icon: new Icon(
                          Icons.location_on,
                          size: 24,
                        )),
                  ],
                  labelColor: Colors.white,
                  controller: tabController,
                  unselectedLabelColor: Colors.white,
                  indicatorColor: Colors.white,
                ),
                color: Color(0xffe53935),
              )),
          body: new TabBarView(
            children: <Widget>[
              NAHome(
                mcdCheck: mcdCheck,
                userType: userType,
                devices: _devices,
              ),
              GetLocationPage(),
            ],
            controller: tabController,
          )),
    );
  }

  Future<void> showPrinterCard() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    String _printerType = 'Direct Print';

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

  void blueThermalPrinter() {
    for (var index = 0; index < devices.length; index++) {
      if (devices[index].name == _printerCtrl) {
        connect(context, devices[index]);
      }
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

  Future _startScanDevices() async {
    printerManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;
      });
    });
    printerManager.startScan(Duration(seconds: 3));
  }
}

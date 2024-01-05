import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_2/ShopList.dart';
import 'package:delivery_2/Url.dart';
import 'package:delivery_2/database/MerchandizerDatabase.dart';
import 'package:delivery_2/database/ReturnDatabase.dart';
import 'package:delivery_2/service.dart/AllService.dart';
import 'package:delivery_2/sync.dart';
import 'Widgets/FormCard.dart';
import 'database/McdDatabase.dart';
import 'database/databasehelper.dart';
import 'database/shopByUserDatabase.dart';
import 'database/shopByUserNote.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

String phoneController;
String passwordController;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum PopupMenuChoices { url, version }

class _LoginState extends State<Login> {
  var phoneNo = FormCard.phonenoController;
  var passCode = FormCard.passcodeController;
  bool loading = true;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  // static const snackBarDuration = Duration(seconds: 3);
  // DateTime backButtonPressTime;

  List<ShopByUserNote> noteListShopByUserNote;
  // List shopType = [];

  // int back = 0;

  ShopsbyUser helperShopsbyUser = ShopsbyUser();

  
  @override
  void initState() {
    super.initState();
    askPermission1();
  }

  void askPermission1() {
    PermissionHandler().requestPermissions(
      [
        PermissionGroup.camera,
        PermissionGroup.location,
        PermissionGroup.storage
      ]
    ).then((value) {
      checkDate();
    });
  }

  DbOrder dbOrder = DbOrder();
  Future<void> checkDate() async {
    DateTime dateTime = DateTime.now();
    String year = dateTime.toString().substring(0, 4);
    String month = dateTime.toString().substring(5, 7);
    String day = dateTime.toString().substring(8, 10);
    String date = year + month + day;
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    print(preferences.getString("OrgId"));
    print(preferences.getString("spsyskey"));
    print(date);
    if (preferences.getString("OrgId") == "" ||
        preferences.getString("OrgId") == null) {
          setState(() {
            loading = false;
          });
    } else {
      if (preferences.getString("DateTime") != date) {
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
        preferences.setString("subTotal", "");
        preferences.setString("returnTotal", "");
        preferences.setString("DateTime", "");
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
        var knockDir =
            await new Directory('${dir.path}').create(recursive: true);

        await knockDir.delete(recursive: true);

        imageCache.clear();

        setState(() {
          loading = false;
        });
      } else {
        autoLoginGetShop();
      }
    }
  }

  Future<void> autoLoginGetShop() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("latitude", "");
        preferences.setString("longitude", "");
        preferences.setString("date", "");
        preferences.setString("address", "");
        preferences.setString("shopname", "");
        preferences.setString("shopCode", "");
        preferences.setString("merchandiserSts", "");
        preferences.setString("OrderDetailSts", "");
        preferences.setString("checkMerchandizing", "");
        preferences.setString('phNo', "");
        preferences.setString('email', "");
        preferences.setString("printerName", "");
        preferences.setString("subTotal", "");
        preferences.setString("returnTotal", "");
        preferences.setString("saveImageSts", "");
        preferences.setString("OriginalStockList", "");
        preferences.setString("ReturnStockList", "");
        shopbyUser.deleteAllNote();
        shopbyTeam.deleteAllNote();

        
        _handleSubmit(context);

        var check;

        datetime();

        final url = '$domain' + 'shop/getshopall';
        var param = jsonEncode({
          "spsyskey": "${preferences.getString('spsyskey')}",
          "teamsyskey": "",
          "usertype": "delivery",
          "date": "$date"
          // "date": "20210322"
        });
        print(param);
        // final response = null;
        final response = await http
            .post(Uri.encodeFull(url), body: param, headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Content-Over": '${preferences.getString("OrgId")}',
            })
            .timeout(Duration(minutes: 1))
            .catchError((error) {
              check = 'Server Fail!';
              Navigator.pop(context);
              snackbarmethod1(check);
            });

        if (response != null) {
          print("1");
          if (response.statusCode == 200) {
            print("2");
            var result = json.decode(response.body);
                print(result['status']);
                print(result['data']);
                if (result['data']["shopsByUser"].toString() == "[]") {
                  check = "success";

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShopList(
                              date: preferences.getString("DateTime"))));
                }
                for (var i = 0; i < result['data']['shopsByUser'].length; i++) {
                  print(result['data']['shopsByUser'][i]['shopsyskey']);
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
                          result['data']['shopsByUser'][i]['long'].toString(),
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
                          result['data']['shopsByUser'][i]['comment']
                              .toString(),
                          result['data']['shopsByUser'][i]['usercode']
                              .toString(),
                          result['data']['shopsByUser'][i]['user'].toString(),
                          result['data']['shopsByUser'][i]['lat'].toString(),
                          result['data']['shopsByUser'][i]['email'].toString(),
                          result['data']['shopsByUser'][i]['username']
                              .toString(),
                          result['data']['shopsByUser'][i]["status"]
                              ["currentType"]))
                      .then((value) {
                    if (i == result['data']['shopsByUser'].length - 1) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShopList(
                                  date: preferences.getString("DateTime"))));
                    }
                  });
                }
            check = 'success';
          } else {
            print(response.statusCode);
            check = "Server Error " + response.statusCode.toString() + " !";
            setState(() {
              loading = false;
            });
            Navigator.pop(context);
            snackbarmethod1(check);
          }
        } else {
          setState(() {
            loading = false;
          });
          check = 'Connection Fail!';
          autologinGetShopAllDialog(check);
        }
  }

  
  Future<void> autologinGetShopAllDialog(title) async {
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
                  autoLoginGetShop();
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

  onMenuSelection(PopupMenuChoices value) async {
    switch (value) {
      case PopupMenuChoices.url:
        checkUrl().then((value) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => URL()));
        });
        break;
      case PopupMenuChoices.version:
        print("to version");
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);

    var mBody = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Image.asset(
                "assets/login.gif",
                height: ScreenUtil().setHeight(500),
                width: ScreenUtil().setWidth(750),
              ),
            ),
          ],
        ),
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(28.0, 170.0, 28.0, 0.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: ScreenUtil().setHeight(180),
                ),
                FormCard(),
                SizedBox(
                  height: ScreenUtil().setHeight(40),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        width: ScreenUtil().setWidth(330),
                        height: ScreenUtil().setHeight(100),
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
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              phoneController = phoneNo.text;
                              passwordController = passCode.text;

                              var connectivityResult =
                                  await (Connectivity().checkConnectivity());
                              if (connectivityResult ==
                                      ConnectivityResult.mobile ||
                                  connectivityResult ==
                                      ConnectivityResult.wifi) {
                                getLogin();
                              } else {
                                snackbarmethod1("Check your connection!");
                              }

                              

                            },
                            child: Center(
                              child: Text(
                                "SIGN IN",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Pyidaungsu",
                                    fontSize: 18,
                                    letterSpacing: 1.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30, right: 10),
          child: Align(
              alignment: Alignment.topRight,
              child: PopupMenuButton<dynamic>(
                onSelected: (value) => onMenuSelection(value),
                icon: Icon(Icons.more_vert, size: 40, color: Color(0xffe53935)),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<PopupMenuChoice>(
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 10),
                            Text("Domain Settings",
                                style: TextStyle(
                                    color: Color(0xffff0800).withOpacity(0.6),
                                    fontSize: 18,
                                    fontFamily: "Abel-Regular")),
                            SizedBox(height: 10),
                            Divider(color: Colors.grey)
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem<PopupMenuChoices>(
                      value: PopupMenuChoices.url,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.cloud_circle, color: Color(0xffe53935)),
                          SizedBox(width: 10),
                          Text("URL",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xffe53935),
                                  fontFamily: "Abel-Regular")),
                        ],
                      ),
                    ),
                    PopupMenuItem<PopupMenuChoices>(
                      value: PopupMenuChoices.version,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.info, color: Color(0xffe53935)),
                          SizedBox(width: 10),
                          Text("Version 1.2.58",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xffe53935),
                                  fontFamily: "Abel-Regular")),
                        ],
                      ),
                    )
                  ];
                },
              )),
        ),
      ],
    );

    var loadProgress = new Container(
        child: new Stack(children: <Widget>[
      mBody,
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
          backgroundColor: Colors.deepOrange[100],
          key: _scaffoldkey,
          resizeToAvoidBottomPadding: true,
          body: loading ? loadProgress : mBody),
    );
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  void _handleSubmit(BuildContext context) {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader);
    } catch (error) {
      print(error);
    }
  }

  snackbarmethod1(name) {
    _scaffoldkey.currentState.showSnackBar(new SnackBar(
      content: new Text(name, textAlign: TextAlign.center),
      backgroundColor: Color(0xffe53935),
      duration: Duration(seconds: 3),
    ));
  }

  void getLogin() async {
    checkUrl();
    print(domain);
    if (phoneController == '') {
      snackbarmethod1("Please fill one or more Fields!");
    } else {
      setState(() {
        loading = true;
      });

      var ph;
      if (phoneController.substring(0, 2) == '09') {
        ph = '+959' + phoneController.substring(2);
      } else if (phoneController.substring(0, 2) == '+9') {
        ph = phoneController;
      } else if (phoneController.substring(0, 2) == '95') {
        ph = '+959' + phoneController.substring(3);
      } else {
        ph = '+959' + phoneController;
      }
      

      getOrgId(ph, passwordController).then((value) async {
        if (value == 'success') {
          setState(() {
            loading = false;
          });
          DateTime dateTime = DateTime.now();
          String year = dateTime.toString().substring(0, 4);
          String month = dateTime.toString().substring(5, 7);
          String day = dateTime.toString().substring(8, 10);
          String date = year + month + day;
          phoneNo.text = '';
          passCode.text = '';
          final SharedPreferences preferences =
              await SharedPreferences.getInstance();
          preferences.setString("DateTime", date);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Sync();
          }));
        } else if (value == 'fail') {
          setState(() {
            loading = false;
          });
          phoneNo.text = '';
          passCode.text = '';
          snackbarmethod1("Invalid User");
        } else {
          setState(() {
            loading = false;
          });
          getLoginDialog(value);
        }
      });
    }
  }
  
  
  
  Future<void> getLoginDialog(title) async {
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
                  getLogin();
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
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  elevation: 0,
                  key: key,
                  backgroundColor: Colors.transparent,
                  children: <Widget>[
                    Center(
                        child: CircularProgressIndicator(
                      backgroundColor: Color(0xffe53935),
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ))
                  ]));
        });
  }
}

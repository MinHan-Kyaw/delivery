import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_2/Login.dart';
import 'package:delivery_2/Widgets/ChangePasswordCard.dart';
import 'package:delivery_2/service.dart/AllService.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

String oldPasswordCtrl;
String passwordCtrl;
String confirmpasswordCtrl;

class _ChangePasswordState extends State<ChangePassword> {
  var oldPassword = ChangePasswordCard.oldpasswordCtrl;
  var password = ChangePasswordCard.passwordCtrl;
  var confirmPassword = ChangePasswordCard.confirmpasswordCtrl;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  snackbarmethod1(name) {
    _scaffoldkey.currentState.showSnackBar(new SnackBar(
      content: new Text(name),
      backgroundColor: Color(0xffe53935),
      duration: Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.deepOrange[100],
        resizeToAvoidBottomPadding: true,
        key: _scaffoldkey,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xffe53935),
          title: Text(
            "Change Password",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(40),
                fontFamily: "Pyidaungsu",
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                ChangePasswordCard.oldpasswordCtrl.text = '';
                ChangePasswordCard.passwordCtrl.text = '';
                ChangePasswordCard.confirmpasswordCtrl.text = '';
                Navigator.pop(context);
              }),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(28.0, 28.0, 28.0, 0.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: ScreenUtil()
                          .setHeight(MediaQuery.of(context).size.height / 4),
                    ),
                    Center(child: ChangePasswordCard()),
                    SizedBox(
                      height: ScreenUtil().setHeight(60),
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
                                  colors: [
                                    Color(0xFFE57373),
                                    Color(0xFFB71C1C)
                                  ],
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
                                  var connectivityResult = await (Connectivity()
                                      .checkConnectivity());
                                  oldPasswordCtrl = oldPassword.text;
                                  passwordCtrl = password.text;
                                  confirmpasswordCtrl = confirmPassword.text;
                                  if (passwordCtrl != confirmpasswordCtrl) {
                                    ChangePasswordCard
                                        .confirmpasswordCtrl.text = '';
                                    snackbarmethod1("Password does not match!");
                                  } else {
                                    if (connectivityResult ==
                                        ConnectivityResult.mobile) {
                                      changePassword(
                                              oldPasswordCtrl, passwordCtrl)
                                          .then((value) {
                                        if (value == "success") {
                                          ChangePasswordCard
                                              .oldpasswordCtrl.text = '';
                                          ChangePasswordCard.passwordCtrl.text =
                                              '';
                                          ChangePasswordCard
                                              .confirmpasswordCtrl.text = '';
                                          showAlert("SUCCESS!");
                                        } else if (value == "fail") {
                                          failAlert("FAIL!");
                                        } else {
                                          failAlert(value);
                                        }
                                      });
                                    } else if (connectivityResult ==
                                        ConnectivityResult.wifi) {
                                      changePassword(
                                              oldPasswordCtrl, passwordCtrl)
                                          .then((value) {
                                        if (value == "success") {
                                          ChangePasswordCard
                                              .oldpasswordCtrl.text = '';
                                          ChangePasswordCard.passwordCtrl.text =
                                              '';
                                          ChangePasswordCard
                                              .confirmpasswordCtrl.text = '';
                                          showAlert("SUCCESS!");
                                        } else if (value == "fail") {
                                          failAlert("FAIL!");
                                        } else {
                                          failAlert(value);
                                        }
                                      });
                                    } else {
                                      failAlert("Check your connection!");
                                    }
                                  }
                                },
                                child: Center(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Pyidaungsu",
                                        fontSize: 18,
                                        letterSpacing: 1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(
                    //   height: ScreenUtil().setHeight(40),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> failAlert(String title) async {
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

  Future<void> showAlert(String title) async {
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
                imageCache.clear();
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Login()));
              },
            ),
            SizedBox(width: 10)
          ],
        );
      },
    );
  }
}

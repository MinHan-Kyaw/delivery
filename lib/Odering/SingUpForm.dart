import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_2/Login.dart';
import 'package:delivery_2/Widgets/SingupCard.dart';
import 'package:delivery_2/service.dart/AllService.dart';

String nameCtrl;
String phoneCtrl;
String emailCtrl;
String passwordCtrl;
String confirmpasswordCtrl;
String passcodeCtrl;
String confirmpasscodeCtrl;

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var name = SignupCard.nameCtrl;
  var phone = SignupCard.phoneCtrl;
  var password = SignupCard.passwordCtrl;
  var confirmPassword = SignupCard.confirmpasswordCtrl;
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

  snackbarmethod(name) {
    _scaffoldkey.currentState.showSnackBar(new SnackBar(
      content: new Text(name),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ));
  }

  void getLogin() async {
    if (phoneCtrl == '') {
      snackbarmethod1("Please fill one or more Fields!");
    } else {
      var ph;
      if (phoneCtrl.substring(0, 2) == '09') {
        ph = '+959' + phoneCtrl.substring(2);
      } else if (phoneCtrl.substring(0, 2) == '+9') {
        ph = phoneCtrl;
      } else if (phoneCtrl.substring(0, 2) == '95') {
        ph = '+959' + phoneCtrl.substring(3);
      } else {
        ph = '+959' + phoneCtrl;
      }

      name.text = "";
      phone.text = "";
      password.text = "";
      confirmPassword.text = "";
      // print(await signUp(ph));
      signUp(ph, nameCtrl, passwordCtrl).then((val) {
        if (val == 'success') {
          snackbarmethod("SUCCESS");
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Login();
          }));
          });
        } else {
          snackbarmethod1("Sign up fail! ($val)");
        }
      });
    }
  }

  Future<void> showAlert(String title) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
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
            "Create Account",
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
                name.text = "";
                phone.text = "";
                password.text = "";
                confirmPassword.text = "";
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
                      height: ScreenUtil().setHeight(100),
                    ),
                    SignupCard(),
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
                                onTap: () {
                                  nameCtrl = name.text;
                                  phoneCtrl = phone.text;
                                  passwordCtrl = password.text;
                                  confirmpasswordCtrl = confirmPassword.text;
                                  if (passwordCtrl != confirmpasswordCtrl) {
                                    snackbarmethod1("Password does not match!");
                                  } else {
                                    getLogin();
                                  }
                                },
                                child: Center(
                                  child: Text(
                                    "SIGN UP",
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
                    SizedBox(
                      height: ScreenUtil().setHeight(40),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

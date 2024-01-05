import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_2/Login.dart';

class SignupCard extends StatefulWidget {
  static TextEditingController nameCtrl = TextEditingController();
  static TextEditingController phoneCtrl = TextEditingController();
  static TextEditingController emailCtrl = TextEditingController();
  static TextEditingController passwordCtrl = TextEditingController();
  static TextEditingController confirmpasswordCtrl = TextEditingController();
  static TextEditingController passcodeCtrl = TextEditingController();
  static TextEditingController confirmpasscodeCtrl = TextEditingController();

  @override
  _SignupCardState createState() => _SignupCardState();
}

class _SignupCardState extends State<SignupCard> {
  bool inActive = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ScreenUtil().setHeight(700),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              offset: Offset(0.0, 15.0),
              blurRadius: 15.0),
          BoxShadow(
              color: Colors.black12,
              offset: Offset(0.0, -10.0),
              blurRadius: 10.0),
        ],
      ),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: ScreenUtil().setHeight(40),
                ),
                TextField(
                  controller: SignupCard.nameCtrl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 25,
                    ),
                    labelText: "Name",
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 15.0),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                TextField(                  
                  controller: SignupCard.phoneCtrl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.account_box,
                      color: Colors.grey,
                      size: 25,
                    ),
                    labelText: "Phone number",
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 15.0),
                  ),
                  keyboardType: TextInputType.number,
                ),
                // SizedBox(
                //   height: ScreenUtil().setHeight(30),
                // ),
                // TextField(
                //   controller: SignupCard.emailCtrl,
                //   decoration: InputDecoration(
                //     prefixIcon: Icon(
                //       Icons.email,
                //       color: Colors.grey,
                //       size: 25,
                //     ),
                //     labelText: "Email",
                //     labelStyle: TextStyle(color: Colors.grey, fontSize: 15.0),
                //   ),
                // ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                TextField(
                  obscureText: true,
                  controller: SignupCard.passwordCtrl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: 25,
                    ),
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 15.0),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                TextField(
                  obscureText: true,
                  controller: SignupCard.confirmpasswordCtrl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: 25,
                    ),
                    labelText: "Confirm Password",
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 15.0),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(45),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Already have an account?"),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()));
                          },
                          child: Text(
                            " Login now",
                            style: TextStyle(color: Colors.blue),
                          ))
                    ],
                  ),
                SizedBox(
                  height: ScreenUtil().setHeight(35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




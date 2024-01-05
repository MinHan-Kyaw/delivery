import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChangePasswordCard extends StatefulWidget {
  static TextEditingController oldpasswordCtrl = TextEditingController();
  static TextEditingController passwordCtrl = TextEditingController();
  static TextEditingController confirmpasswordCtrl = TextEditingController();

  @override
  _ChangePasswordCardState createState() => _ChangePasswordCardState();
}

class _ChangePasswordCardState extends State<ChangePasswordCard> {
  bool inActive = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ScreenUtil().setHeight(500),
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
                  obscureText: true,
                  controller: ChangePasswordCard.oldpasswordCtrl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: 25,
                    ),
                    labelText: "Old Password",
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 15.0),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                TextField(
                  obscureText: true,
                  controller: ChangePasswordCard.passwordCtrl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: 25,
                    ),
                    labelText: "New Password",
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 15.0),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                TextField(
                  obscureText: true,
                  controller: ChangePasswordCard.confirmpasswordCtrl,
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




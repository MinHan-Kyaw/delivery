import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_2/Odering/SingUpForm.dart';

class FormCard extends StatelessWidget {
  static TextEditingController phonenoController = TextEditingController();
  static TextEditingController passcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ScreenUtil().setHeight(560),
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
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Login",
                  style: TextStyle(
                      fontSize: 25,
                      fontFamily: "Pyidaungsu",
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                TextField(
                  keyboardType: TextInputType.phone,
                  controller: phonenoController,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                      Icons.phone,
                      color: Colors.grey,
                      size: 25,
                    ),
                    labelText: "Phone Number",
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 15.0),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                TextField(
                  
                  obscureText: true,
                  controller: passcodeController,
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
                  height: ScreenUtil().setHeight(35),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: <Widget>[
                //     Text(
                //       "Forgot Password?",
                //       style: TextStyle(
                //         color: Colors.blue,
                //         fontSize: 15,
                //         fontFamily: "Pyidaungsu",
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(
                  height: ScreenUtil().setHeight(35),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Don't have an account?", style: TextStyle(fontSize: 14),),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                      },
                      child: Text(" Sign up", style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontFamily: "Pyidaungsu",
                      ),))
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
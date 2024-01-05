import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_2/NA_Profile.dart';
import 'package:delivery_2/Widgets/salesummary.dart';
import 'package:delivery_2/database/shopByUserDatabase.dart';

String _userName = "";
String _userId = "";
String _newuserId = '';

class MyDrawer extends StatefulWidget {
  List<PrinterBluetooth> devices = [];
  MyDrawer({
    Key key,
    @required this.devices,
  }) : super(key: key);
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  ShopsbyUser helperShopsbyUser = ShopsbyUser();

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future getData() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _userName = preferences.getString("userName");
      _userId = preferences.getString("userId");

      if (_userId != '' && _userId != null) {
        _newuserId = "09" + _userId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: <Widget>[
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            color: Color(0xffe53935),
          ),
          accountName: Text(
            "$_userName",
            style: TextStyle(fontSize: ScreenUtil().setHeight(30), fontWeight: FontWeight.bold),
          ),
          accountEmail: Text(
            "$_newuserId",
            style: TextStyle(fontSize: ScreenUtil().setHeight(25), fontWeight: FontWeight.w400),
          ),
          currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                  ? Colors.red
                  : Colors.white,
              backgroundImage: AssetImage(
                'assets/coca.png',
              )),
        ),
        InkWell(
          onTap: () async {
            Navigator.pop(context);

            Navigator.push(
                context, MaterialPageRoute(builder: (context) => NAProfile()));
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 15, top: 15),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.account_circle,
                  color: Color(0xffe53935),
                  size: ScreenUtil().setHeight(45),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('Profile',
                      style: TextStyle(
                          fontSize: 15,
                          color: Color(0xffe53935),
                          fontFamily: "Abel-Regular")),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Divider(color: Colors.grey),
        ),
        InkWell(
          onTap: () async {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SaleSummary()));
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 15, top: 15),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.description,
                  color: Color(0xffe53935),
                  size: ScreenUtil().setHeight(45),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('Sale Summary',
                      style: TextStyle(
                          fontSize: 15,
                          color: Color(0xffe53935),
                          fontFamily: "Abel-Regular")),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Divider(color: Colors.grey),
        ),
      ],
    ));
  }
}

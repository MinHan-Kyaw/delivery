import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_2/Widgets/UserShop.dart';

String _userName = "";
String _userId = "";

String _newuserId = '';

class NAProfile extends StatefulWidget {
  @override
  _NAProfileState createState() => _NAProfileState();
}

class _NAProfileState extends State<NAProfile>
    with SingleTickerProviderStateMixin {
  int tabIndex = 0;
  TabController tabController;

  @override
  void initState() {
    getData();
    super.initState();
    tabController = new TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
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
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          title: Text("Profile"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              height: 150,
              color: Color(0xffe53935),
              child: Row(
                children: <Widget>[
                  Container(
                    width: size.width / 2,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: new Container(
                            width: 110,
                            height: 110,
                            decoration: new BoxDecoration(
                              // color: const Color(0xff7c94b6),
                              color: Colors.white,
                              image: new DecorationImage(
                                image: new AssetImage("assets/coca.png"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: new BorderRadius.all(
                                  new Radius.circular(75.0)),
                              border: new Border.all(
                                color: Colors.white,
                                width: 4.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // SizedBox(height: 10),
                        Text(
                          "$_userName",
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.white,
                            fontFamily: "Pyidaungsu",
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "$_newuserId",
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.white,
                            fontFamily: "Pyidaungsu",
                          ),
                        ),
                        // SizedBox(height: 10),
                        // Container(
                        //   width: size.width / 2,
                        //   child: Text(
                        //     "Pa/2 - 270,Panma Qtr Kyatpyin, Shan State, Burma, 05092",
                        //     style: TextStyle(
                        //       fontSize: 19,
                        //       color: Colors.white,
                        //       fontFamily: "Pyidaungsu",
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: size.height - 260,
              child: DefaultTabController(
                length: 1,
                child: Scaffold(
                  body: McdTabBar(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class McdTabBar extends StatefulWidget {
  @override
  _McdTabBarState createState() => _McdTabBarState();
}

class _McdTabBarState extends State<McdTabBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 1.5, color: Color(0xffe53935)),
          insets: EdgeInsets.symmetric(horizontal: 26.0),
        ),
        unselectedLabelColor: Colors.grey,
        labelColor: Color(0xffe53935),
        tabs: [
          Tab(
            child: Text(
              "User Shop",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      body: TabBarView(
        children: [
          UserShop(),
        ],
      ),
    );
  }
}

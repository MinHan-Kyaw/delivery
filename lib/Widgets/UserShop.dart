import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:delivery_2/database/shopByUserDatabase.dart';
import 'package:delivery_2/database/shopByUserNote.dart';

class UserShop extends StatefulWidget {
  @override
  _UserShopState createState() => _UserShopState();
}

class _UserShopState extends State<UserShop> {
  ShopsbyUser helperShopsbyUser = ShopsbyUser();
  List<ShopByUserNote> noteListShopByUserNote;
  List shopName = [];
  List shopNamemm = [];
  String phone;
  String email;
  String location;

  void getShopName() async {
    final Future<Database> db = helperShopsbyUser.initializedDatabase();
    await db.then((database) {
      Future<List<ShopByUserNote>> noteListFuture =
          helperShopsbyUser.getNoteList();
      noteListFuture.then((note) {
        setState(() {
          this.noteListShopByUserNote = note;

          for (var i = 0; i < noteListShopByUserNote.length; i++) {
            shopName.add(noteListShopByUserNote[i].shopname);
            shopNamemm.add(noteListShopByUserNote[i].shopnamemm);
          }
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getShopName();
  }

  Future<void> shopDetailCard(String shopName, String shopNameMm) async {
    double width = MediaQuery.of(context).size.width * 0.5;

    var getSysKey = helperShopsbyUser.getShopSyskey(shopName);

    getSysKey.then((val) {
      for (var i = 0; i < val.length; i++) {
        setState(() {
          phone = val[i]["phoneno"];
          email = val[i]["email"];
          location = val[i]["address"];
        });
      }

      return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
          title: Center(child: Text('Shop Detail')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Divider(color: Colors.grey),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.shopping_cart,
                    color: Color(0xffe53935),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text("$shopName ($shopNameMm)",style: TextStyle(fontWeight: FontWeight.w300),),
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.phone,
                    color: Color(0xffe53935),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text("$phone",style: TextStyle(fontWeight: FontWeight.w300)),
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.email,
                    color: Color(0xffe53935),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text("$email",style: TextStyle(fontWeight: FontWeight.w300)),
                  )
                ],
              ),
              SizedBox(
                height: 15,
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
                      child: Text("$location",style: TextStyle(fontWeight: FontWeight.w300)),
                    ),
                  )
                ],
              ),
              // SizedBox(
              //   height: 15,
              // ),
              // Divider(color: Colors.grey),
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
    });

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: shopName.length,
          itemBuilder: (context, int val) {
            return GestureDetector(
              onTap: () {
                shopDetailCard(shopName[val], shopNamemm[val]);
              },
              child: Container(
                // height: 70,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Text(
                      "${shopName[val]} (${shopNamemm[val]})",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontFamily: "Pyidaungsu",
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}

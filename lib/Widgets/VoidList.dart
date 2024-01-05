import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_2/Widgets/VoidListData.dart';
import 'package:delivery_2/database/shopByUserDatabase.dart';
import 'package:delivery_2/service.dart/AllService.dart';
import 'package:delivery_2/Login.dart';

class VoidList extends StatefulWidget {
  List<PrinterBluetooth> devices = [];
  VoidList({Key key, @required this.devices}) : super(key: key);
  @override
  _VoidListState createState() => _VoidListState();
}

class _VoidListState extends State<VoidList> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  List data = [];
  ShopsbyUser helperShopsbyUser = ShopsbyUser();
  String dateformat;

  List orderData = voidList;

  bool loading = true;

  String shopName;
  String shopNameMM;
  String address;
  String phone;

  @override
  @override
  void initState() {
    super.initState();
    getData();
  }

  String storeID = "";

  Future<void> getData() async {
    
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var getSysKey =
        helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));

    storeID = preferences.getString("shopCode");
    
    setState(() {
      loading = true;
      shopName = preferences.getString("shopname");
      shopNameMM = preferences.getString("shopnamemm");
      address = preferences.getString("address");
      phone = preferences.getString("phNo");
    });
    getSysKey.then((val) {
      getvoidlist(val[0]["shopcode"]).then((value) {
        if (value == "success") {
          getPreSeller(sysKey, "231").then((value) {
          setState(() {
            data = voidList.toSet().toList();

            loading = false;
          });
          });
          
        } else if (value == "fail") {
          setState(() {
            loading = false;
          });
        } else {
          voidListDialog(value.toString());
        }
      });
    });
  }

  Future<void> voidListDialog(String title) async {
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
                  getData();
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

  @override
  Widget build(BuildContext context) {
    Widget body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        height: MediaQuery.of(context).size.height - 317,
        child: data.length == 0 || data == []
            ? Center(
                child: Text(
                  "No Data",
                  style: TextStyle(fontSize: 25, color: Colors.grey[400]),
                ),
              )
            : ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int i) {
                  return Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          ontapVoidListData(data[i]["syskey"]);
                        },
                        child: Card(
                          child: Container(
                            height: 50,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("${data[i]["syskey"]}"),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                          "${data[i]["date"].toString().substring(6, 8)}/${data[i]["date"].toString().substring(4, 6)}/${data[i]["date"].toString().substring(0, 4)}"),
                                      Icon(Icons.keyboard_arrow_right)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
      ),
    );

    var loadProgress = new Container(
        child: new Stack(children: <Widget>[
      body,
      Container(
        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 0.5)),
        width: MediaQuery.of(context).size.width * 0.99,
        height: MediaQuery.of(context).size.height - 317,
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
        key: _scaffoldkey,
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          title: Text("Void List"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () async {
                voidList = [];
                stockData.clear();
                brandOwnerName.clear();
                Navigator.pop(context);
              }),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 17, vertical: 0),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400])),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListView(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text('Store ID',
                                        textAlign: TextAlign.start,
                                        style: TextStyle()),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 150,
                                  child: Text(
                                      "  - $storeID",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text('Shop',
                                        textAlign: TextAlign.start,
                                        style: TextStyle()),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 150,
                                  child: Text(
                                      shopNameMM == null || shopNameMM == ""
                                          ? "  - $shopName"
                                          : '  - $shopName ($shopNameMM)',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  child: Text('Phone',
                                      textAlign: TextAlign.start,
                                      style: TextStyle()),
                                ),
                                Text('  - $phone',
                                    textAlign: TextAlign.start,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  child: Text('Preseller',
                                      textAlign: TextAlign.start,
                                      style: TextStyle()),
                                ),
                                Text('  - $preSellerName',
                                    textAlign: TextAlign.start,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text('Address',
                                        textAlign: TextAlign.start,
                                        style: TextStyle()),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 150,
                                  child: Text("  - $address",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                )),
            loading ? loadProgress : body,
          ],
        ),
      ),
    );
  }

  Future<void> ontapVoidListData(String syskey) async {
    bool loading = false;
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var getSysKey =
        helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));

    setState(() {
      loading = true;
    });

    if (loading == true) {
      _handleSubmit(context);
    }

    getSysKey.then((val) {
      // for (var a = 0; a < val.length; a++) {
      setState(() {
        getvoidlistData(val[0]["shopcode"], syskey).then((getstockValue) {
          print(syskey);
          if (getstockValue == "success") {
            getPreSeller(sysKey, "231").then((value) {
            setState(() {
              loading = false;
            });
            getStockImg().then((stockimgValue) {
              print(stockimgValue);
              if (stockimgValue == "success") {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VoidListData(
                              mcdCheck: preferences.getString("merchandizer"),
                              userType: preferences.getString("userType"),
                              devices: widget.devices,
                              shopName: preferences.getString('shopname'),
                              shopNameMm: preferences.getString('shopnamemm'),
                              address: preferences.getString('address'),
                              phone: preferences.getString("phNo"),
                              sysKey: syskey,
                            )));
              } else if (stockimgValue == "fail") {
                setState(() {
                  loading = false;
                });
                Navigator.pop(context);
                snackbarmethod("FAIL!");
              } else {
                setState(() {
                  loading = false;
                });
                Navigator.pop(context);
                voidListDataDialog(syskey, stockimgValue.toString());
              }
            });
            });
          } else if (getstockValue == "fail") {
            setState(() {
              loading = false;
            });
            Navigator.pop(context);
            snackbarmethod("FAIL!");
          } else {
            setState(() {
              loading = false;
            });
            Navigator.pop(context);
            voidListDataDialog(syskey, getstockValue.toString());
          }
        });
      });
    });
  }

  Future<void> voidListDataDialog(String syskey, String title) async {
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
                  ontapVoidListData(syskey);
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

  snackbarmethod1(name) {
    _scaffoldkey.currentState.showSnackBar(new SnackBar(
      content: new Text(name, textAlign: TextAlign.center),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ));
  }

  snackbarmethod(name) {
    _scaffoldkey.currentState.showSnackBar(new SnackBar(
      content: new Text(name, textAlign: TextAlign.center),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ));
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  Future<void> _handleSubmit(BuildContext context) async {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader);
    } catch (error) {
      print(error);
    }
  }
}

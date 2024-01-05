import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './navigation_bar.dart';
import './service.dart/AllService.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'Login.dart';
import 'Widgets/DiscountDetail.dart';
import 'Widgets/ShowImage.dart';
import 'Widgets/giftBanner.dart';
import 'database/shopByUserDatabase.dart';
import 'package:delivery_2/Widgets/printer.dart';

String printer;

class CompleteInvoice extends StatefulWidget {
  final String mcdCheck;
  final String userType;
  final List<PrinterBluetooth> devices;
  final String shopName;
  final String shopNameMm;
  final String address;
  final String phone;
  final List orderStock;
  final List returnStock;
  CompleteInvoice(
      {Key key,
      @required this.mcdCheck,
      @required this.userType,
      @required this.phone,
      this.devices,
      this.shopName,
      @required this.shopNameMm,
      this.address,
      this.orderStock,
      this.returnStock})
      : super(key: key);
  @override
  _CompleteInvoiceState createState() => _CompleteInvoiceState();
}

// List itemm = [];

class _CompleteInvoiceState extends State<CompleteInvoice> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  ShopsbyUser helperShopsbyUser = ShopsbyUser();
  List itemCode = [];
  List itemName = [];
  List itemQty = [];
  List itemTolCount = [];
  List rtnItemCode = [];
  List rtnItemName = [];
  List rtnItemQty = [];
  List rtnItemTolCount = [];
  int totalCount = 0;
  List totalItem = [];
  List subTotalItem = [];
  bool visible = true;
  int subTotal;
  int returnTotal = 0;
  List orderCode = [];
  List orderName = [];
  List orderQty = [];
  List orderTotalCount = [];
  List printAmt = [];
  List printDiscount = [];
  List orderStock = [];
  List returnStock = [];
  List invPromotionList = [];
  List orderProducts = [];
  List returnProducts = [];

  List orderPrice = [];
  List returnPrice = [];

  String merchandizingStatus;
  String orderdetailStatus;
  String invoiceStatus;
  String invoiceComplete;
  int abAccount = 0;
  int spAccount = 0;
  TextEditingController abAccountCtrl = TextEditingController();
  TextEditingController spAccountCtrl = TextEditingController();
  TextEditingController cashReceivedCtrl = TextEditingController();
  TextEditingController cashAmtCtrl = TextEditingController(text: "0");
  int cashReceived = 0;

  List<PrinterBluetooth> _devices = [];
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  String _printerCtrl;
  TextEditingController specialDisCtrl = TextEditingController();
  int specialAmount = 0;

  int specialDiscountAmt = 0;

  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';

  String storeID = "";

  void _getprinter() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getString("printerName") != null &&
        preferences.getString("printerName") != "") {
      printer = preferences.getString("printerName");
    }

    invoiceComplete = preferences.getString("InvoiceSts");
    storeID = preferences.getString("shopCode");
  }

  var discountPercent = 0.0;

  @override
  void initState() {
    super.initState();

    abAccountCtrl = TextEditingController(text: "0");
    spAccountCtrl = TextEditingController(text: "0");
    cashReceivedCtrl = TextEditingController(text: "0");

    // getAllItems();
    // getData();
    _getprinter();
    _startScanDevices();

    specialDisCtrl.text = "0";
  }

  bool loading = true;

  getList() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    var getSysKey =
        helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));

    setState(() {
      loading = true;
    });

    getSysKey.then((val) {
      accountGetBalance(val[0]["shopsyskey"]).then((accBalanceVal) {
      getStoreSts(preferences.getString("spsyskey"), val[0]["shopsyskey"])
          .then((value) {
        if (value == "success") {
          setState(() {
            merchandizingStatus = merchandizingSts;
            orderdetailStatus = orderdetailSts;
            invoiceStatus = invoiceSts;

            stockImage = json.decode(preferences.getString("StockImageList"));

            for (var i = 0; i < val.length; i++) {
              print(val[i]["shopcode"]);

              getInvoiceList(val[i]["shopcode"]).then((value) {
                if (value == "success") {
                  getPreSeller(preferences.getString("orderdetailSyskey"), "231").then((value) {
                    getAccountDetail(val);
                  });
                } else if (value == "fail") {
                  setState(() {
                    loading = false;
                  });
                  snackbarmethod("FAIL!");
                } else {
                  setState(() {
                    loading = false;
                  });
                  getDeliveryListDialog("$value");
                }
              });
            }
          });
        } else {
          setState(() {
            loading = false;
          });
          merchandizingStatus = "";
          orderdetailStatus = "";
          invoiceStatus = "";
        }
      });
      });
    });
  }

  Future<void> getDeliveryListDialog(String title) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

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
                  getList();
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return NavigationBar(orgId, widget.mcdCheck,
                        widget.userType, preferences.getString("DateTime"));
                  }));
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

  Future<void> getData() async {
    setState(() {
      orderStock = [];
      returnStock = [];
      specialDiscountAmt = 0;
    });
    if (getinvoiceOrderlist.length == 0) {
      setState(() {
        loading = false;
      });
    } else {
      for (var b = 0; b < getinvoiceOrderlist.length; b++) {
        orderStock.add({
          "brandOwnerName": getinvoiceOrderlist[b]["brandOwnerName"],
          "brandOwnerSyskey": getinvoiceOrderlist[b]["brandOwnerSyskey"],
          "visible": true,
          "stockData": getinvoiceOrderlist[b]["stockData"]
        });

        abAccount = getinvoiceOrderlist[b]["payment1"].toInt();
        spAccount = getinvoiceOrderlist[b]["payment2"].toInt();
        abAccountCtrl = TextEditingController(text: "$abAccount");
        spAccountCtrl = TextEditingController(text: "$spAccount");
        discountPercent = getinvoiceOrderlist[b]["orderDiscountPercent"];

        if(getinvoiceOrderlist[b]["promotionList"].toString() != "null") {
          invPromotionList = getinvoiceOrderlist[b]["promotionList"];
        }
        

        returnStock.add({
          "brandOwnerName": getinvoiceOrderlist[b]["brandOwnerName"],
          "brandOwnerSyskey": getinvoiceOrderlist[b]["brandOwnerSyskey"],
          "visible": true,
          "stockData": getinvoiceOrderlist[b]["stockReturnData"]
        });

        if (b == getinvoiceOrderlist.length - 1) {
          setState(() {
            specialDiscountAmt = int.parse(
                "${getinvoiceOrderlist[b]["discountamount"]}".substring(
                    0,
                    "${getinvoiceOrderlist[b]["discountamount"]}"
                        .lastIndexOf(".")));
            loading = false;
            
          });
        }
      }
    }
  }
  
  void getAccountDetail(val) {
        accountTodayCashReceived(val[0]["shopsyskey"]).then((cashReceivedVal) {
          if(cashReceivedVal == "success") {
            setState(() {
              getData();
              cashReceived = cashReceivedAmt.toInt();
              cashReceivedCtrl = TextEditingController(text: "$cashReceived");
            });
          } else if(cashReceivedVal == "fail") {
            getData();
          } else {
            getData();
          }
        });
      
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

  Future<void> blueToothAlert(String title) async {
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

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  Future<void> _handleSubmit(BuildContext context) async {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader);
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(orderStock);
    print(returnStock);
    orderPrice = [];
    returnPrice = [];
    for (var i = 0; i < orderStock.length; i++) {
      for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
        orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"].toInt());
      }
    }

    print("order price Ready");

    for (var i = 0; i < returnStock.length; i++) {
      for (var a = 0; a < returnStock[i]["stockData"].length; a++) {
        returnPrice.add(returnStock[i]["stockData"][a]["totalAmount"].toInt());
      }
    }

    print("return Price Ready");

    List getStock = [];
    List getReturnStock = [];
    List getStockData = [];
    List getReturnStockData = [];
    getStock =
        orderStock.where((element) => element["visible"] == true).toList();
    getReturnStock =
        returnStock.where((element) => element["visible"] == true).toList();
    for (var b = 0; b < getStock.length; b++) {
      for (var i = 0; i < getStock[b]["stockData"].length; i++) {
        getStockData.add(getStock[b]["stockData"][i]);
      }
    }
    for (var b = 0; b < getReturnStock.length; b++) {
      for (var i = 0; i < getReturnStock[b]["stockData"].length; i++) {
        getReturnStockData.add(getReturnStock[b]["stockData"][i]);
      }
    }

    totalCount = 0;
    returnTotal = 0;
    
    if(orderPrice.length == 0) {
      totalCount = 0;
    }else {
      totalCount = int.parse("${orderPrice.reduce((value, element) => value + element)}");
    }

    if(returnPrice.length == 0) {
      returnTotal = 0;
    }else {
      returnTotal = int.parse("${returnPrice.reduce((value, element) => value + element)}");
    }


    Widget body = Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldkey,
      appBar: new AppBar(
        backgroundColor: Color(0xffe53935),
        title: new Text(
          'Invoice',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () async {
              final SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              print(itemName);
              itemCode.clear();
              itemName.clear();
              itemQty.clear();
              itemTolCount.clear();
              itemTolCount.clear();
              rtnItemCode.clear();
              rtnItemName.clear();
              rtnItemQty.clear();
              rtnItemTolCount.clear();
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return NavigationBar(orgId, widget.mcdCheck, widget.userType,
                    preferences.getString("DateTime"));
              }));
            }),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                                      widget.shopNameMm == null ||
                                              widget.shopNameMm == ""
                                          ? "  - ${widget.shopName}"
                                          : '  - ${widget.shopName} (${widget.shopNameMm})',
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
                                Text('  - ${widget.phone}',
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
                                  child: Text("  - ${widget.address}",
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
            orderStock == [] || orderStock.length == 0
                ? Container(
                    height: MediaQuery.of(context).size.height - 320,
                    child: Center(
                      child: Text(
                        "No Data",
                        style: TextStyle(fontSize: 25, color: Colors.grey[400]),
                      ),
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height - 320,
                    child: ListView(
                      children: <Widget>[
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                              color: Colors.red[100],
                              child: Center(
                                  child: Text(
                                "Order Products",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17),
                              ))),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Container(
                            // height: stockLength,
                            child: Column(children: <Widget>[
                              for (var i = 0; i < orderStock.length; i++)
                                // ListView.builder(
                                //     physics: NeverScrollableScrollPhysics(),
                                //     itemCount: orderStock.length,
                                //     itemBuilder: (context, i) {
                                //       return
                                Visibility(
                                  visible:
                                      orderStock[i]["stockData"].length == 0
                                          ? false
                                          : true,
                                  child: Column(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          if (orderStock[i]["visible"] ==
                                              false) {
                                            setState(() {
                                              orderStock[i]["visible"] = true;
                                            });
                                          } else if (orderStock[i]["visible"] ==
                                              true) {
                                            setState(() {
                                              orderStock[i]["visible"] = false;
                                            });
                                          }
                                        },
                                        child: Container(
                                          height: 50,
                                          child: Card(
                                              color: Color(0xffe53935),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      orderStock[i][
                                                                  "brandOwnerName"] ==
                                                              null
                                                          ? ""
                                                          : orderStock[i][
                                                              "brandOwnerName"],
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.white),
                                                    ),
                                                    Icon(
                                                      orderStock[i]["visible"]
                                                          ? Icons
                                                              .keyboard_arrow_down
                                                          : Icons
                                                              .keyboard_arrow_right,
                                                      color: Colors.white,
                                                    )
                                                  ],
                                                ),
                                              )),
                                        ),
                                      ),
                                      Visibility(
                                        visible: orderStock[i]["visible"],
                                        child: Container(
                                          child: Column(
                                            children: <Widget>[
                                              for(var a = 0; a< orderStock[i]["stockData"].length;a ++)
                                                    Column(
                                                      children: <Widget>[
                                                        Stack(
                                                          children: <Widget>[
                                                            Container(
                                                              child: Card(
                                                                elevation: 3,
                                                                child: Column(
                                                                  children: <Widget>[
                                                                    Row(
                                                                      children: <Widget>[
                                                                        GestureDetector(
                                                                          onTap: () {
                                                                            print(stockImage
                                                                                .where((element) =>
                                                                                    element[
                                                                                        "stockCode"] ==
                                                                                    orderStock[i]
                                                                                            [
                                                                                            "stockData"][a]
                                                                                        [
                                                                                        "stockCode"])
                                                                                .toList());
                                                                          },
                                                                          child: ConstrainedBox(
                                                                            constraints:
                                                                                BoxConstraints(
                                                                              maxWidth: 64,
                                                                              maxHeight: 80,
                                                                            ),
                                                                            child: stockImage ==
                                                                                        [] ||
                                                                                    stockImage
                                                                                            .length ==
                                                                                        0
                                                                                ? GestureDetector(
                                                                                    onTap: () {
                                                                                      Navigator.push(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                              builder: (context) => ShowImage(image: Image.asset("assets/coca.png"))));
                                                                                    },
                                                                                    child: Image.asset(
                                                                                        "assets/coca.png",
                                                                                        fit: BoxFit
                                                                                            .cover),
                                                                                  )
                                                                                : Stack(
                                                                                    children: <
                                                                                        Widget>[
                                                                                      GestureDetector(
                                                                                        onTap:
                                                                                            () {
                                                                                          Navigator.push(
                                                                                              context,
                                                                                              MaterialPageRoute(builder: (context) => ShowImage(image: Image.asset("assets/coca.png"))));
                                                                                        },
                                                                                        child: Image.asset(
                                                                                            "assets/coca.png",
                                                                                            fit:
                                                                                                BoxFit.cover),
                                                                                      ),
                                                                                      stockImage.where((element) => element["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]).toList().toString() ==
                                                                                              '[]'
                                                                                          ? GestureDetector(
                                                                                              onTap: () {
                                                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => ShowImage(image: Image.asset("assets/coca.png"))));
                                                                                              },
                                                                                              child: Image.asset("assets/coca.png", fit: BoxFit.cover),
                                                                                            )
                                                                                          : GestureDetector(
                                                                                              onTap: () {
                                                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => ShowImage(image: CachedNetworkImage(imageUrl: "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}"))));
                                                                                              },
                                                                                              // child:
                                                                                              //     Image.network(
                                                                                              //   "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
                                                                                              //   fit: BoxFit.cover,
                                                                                              // ),
                                                                                              child: CachedNetworkImage(
                                                                                                imageUrl: "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
                                                                                              ),
                                                                                            )
                                                                                    ],
                                                                                  ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width: MediaQuery.of(
                                                                                      context)
                                                                                  .size
                                                                                  .width -
                                                                              82,
                                                                          child: Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                        .only(
                                                                                    right: 3,
                                                                                    top: 20,
                                                                                    bottom: 10,
                                                                                    left: 10),
                                                                            child: Column(
                                                                              crossAxisAlignment:
                                                                                  CrossAxisAlignment
                                                                                      .start,
                                                                              children: <
                                                                                  Widget>[
                                                                                Row(
                                                                                  mainAxisAlignment:
                                                                                      MainAxisAlignment
                                                                                          .spaceBetween,
                                                                                  children: <
                                                                                      Widget>[
                                                                                    Container(
                                                                                      width: MediaQuery.of(context)
                                                                                              .size
                                                                                              .width -
                                                                                          100,
                                                                                      // height: 20,
                                                                                      margin: EdgeInsets
                                                                                          .only(
                                                                                              top: 5),
                                                                                      child:
                                                                                          Text(
                                                                                        "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding:
                                                                                      EdgeInsets
                                                                                          .only(
                                                                                              top: 5),
                                                                                  child: Row(
                                                                                    mainAxisAlignment:
                                                                                        MainAxisAlignment
                                                                                            .spaceBetween,
                                                                                    children: <
                                                                                        Widget>[
                                                                                      Row(
                                                                                        children: <
                                                                                            Widget>[
                                                                                          Text(
                                                                                              "Qty : "),
                                                                                          Text("${orderStock[i]["stockData"][a]["qty"]}".substring(
                                                                                              0,
                                                                                              "${orderStock[i]["stockData"][a]["qty"]}".lastIndexOf("."))),
                                                                                        ],
                                                                                      ),
                                                                                      Container(
                                                                                        width:
                                                                                            150,
                                                                                        child:
                                                                                            Row(
                                                                                          mainAxisAlignment:
                                                                                              MainAxisAlignment.spaceBetween,
                                                                                          children: <
                                                                                              Widget>[
                                                                                            Text("${orderStock[i]["stockData"][a]["normalPrice"].toInt()}" == "0" ? "${orderStock[i]["stockData"][a]["price"].toInt()}" : "${orderStock[i]["stockData"][a]["normalPrice"].toInt()}"),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(right: 15),
                                                                                              child: Text(
                                                                                                orderStock[i]["stockData"][a]["totalAmount"].toString().substring(orderStock[i]["stockData"][a]["totalAmount"].toString().lastIndexOf("."), orderStock[i]["stockData"][a]["totalAmount"].toString().length).length > 3 ?
                                                                                                "${orderStock[i]["stockData"][a]["totalAmount"].toStringAsFixed(2)}" :
                                                                                                double.parse(orderStock[i]["stockData"][a]["totalAmount"].toString().substring(orderStock[i]["stockData"][a]["totalAmount"].toString().lastIndexOf("."), orderStock[i]["stockData"][a]["totalAmount"].toString().length)) == 0.0 ?
                                                                                                  "${orderStock[i]["stockData"][a]["totalAmount"].toInt()}" :
                                                                                                  "${orderStock[i]["stockData"][a]["totalAmount"]}"),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                orderStock[i]["stockData"][a]["discountAmount"] == "" || orderStock[i]["stockData"][a]["discountPercent"] == "" ?
                                                                          Container() :
                                                                          Visibility(
                                                                            visible: orderStock[i]["stockData"][a]["discountAmount"] == "" || orderStock[i]["stockData"][a]["discountPercent"] == "" ? false : true,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.only(right: 15),
                                                                              child: Container(
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: <Widget>[
                                                                                    Container(),
                                                                                    Row(
                                                                                      children: <Widget>[
                                                                                        Text(
                                                                                          orderStock[i]["stockData"][a]["discountAmount"] == "" || orderStock[i]["stockData"][a]["discountAmount"].toString() == "0.0" || orderStock[i]["stockData"][a]["discountPercent"] == "" || orderStock[i]["stockData"][a]["discountPercent"].toString() == "0.0" ?
                                                                                          "" :
                                                                                          orderStock[i]["stockData"][a]["discountPercent"].toString() == "0.0" &&
                                                                                          orderStock[i]["stockData"][a]["discountAmount"].toString() == "0.0" ? "" :
                                                                                          "${orderStock[i]["stockData"][a]["normalPrice"].toInt() * orderStock[i]["stockData"][a]["qty"].toInt()}", style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12),),
                                                                                        orderStock[i]["stockData"][a]["discountAmount"] == "" || orderStock[i]["stockData"][a]["discountAmount"].toString() == "0.0" || orderStock[i]["stockData"][a]["discountPercent"] == "" || orderStock[i]["stockData"][a]["discountPercent"].toString() == "0.0" ?
                                                                                        Text("") :
                                                                                        Text(
                                                                                          orderStock[i]["stockData"][a]["discountPercent"].toString() != "0.0" ?
                                                                                          "  -${orderStock[i]["stockData"][a]["discountPercent"]}%" :
                                                                                          orderStock[i]["stockData"][a]["discountAmount"].toString() != "0.0" ?
                                                                                          "  -${orderStock[i]["stockData"][a]["discountAmount"].toInt()}" : ""
                                                                                          , style: TextStyle(color: Colors.red, fontSize: 12),),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    Visibility(
                                                                      visible: orderStock[i]["stockData"][a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().length == 0 ? false : true,
                                                                      child: Stack(
                                                                        children: <Widget>[
                                                                          Padding(
                                                                            padding: const EdgeInsets.only(top: 9),
                                                                            child: Container(
                                                                              height: 1,
                                                                              color: Colors.red[200],
                                                                            ),
                                                                          ),
                                                                          Center(
                                                                            child: Container(
                                                                              color: Colors.white,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                                child: Text("Gift", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 15),),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Column(
                                                                      children: <Widget>[
                                                                        for(var k = 0; k < orderStock[i]["stockData"][a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().length; k++)
                                                                        Padding(
                                                                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                                                                          child: Column(
                                                                            children: <Widget>[
                                                                              Visibility(
                                                                                visible: k == 0 ? false : true,
                                                                                child: Divider(),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: <Widget>[
                                                                                    Text("${orderStock[i]["stockData"][a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList()[k]["stockName"]}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300)),
                                                                                    Text("Qty : ${orderStock[i]["stockData"][a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList()[k]["qty"].toInt()}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300))
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 10,)
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            if(discountStockList.contains(orderStock[i]["stockData"][a]["stockSyskey"].toString()) == true ||
                                                            listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0)
                                                            GestureDetector(
                                                              onTap: () async {
                                                                if(listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0) {
                                                                      List detailList = [];
                                                                      List sameDetailList = [];
                                                                      String headerSyskey = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["HeaderSyskey"];
                                                                      String ruleNumber = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["RuleNumber"];
                                                                      String rulePriority = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["RulePriority"];
                                                                      for(var j = 0; j < multiDiscountStockList.length; j++) {
                                                                        if(multiDiscountStockList[j]["HeaderSyskey"] == headerSyskey) {
                                                                          // sameDetailList = multiDiscountStockList[j]["DetailList"].where((element) => element["PromoItemSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"] && element["RuleNumber"] == ruleNumber && element["RulePriority"] == rulePriority).toList();
                                                                          sameDetailList = multiDiscountStockList[j]["DetailList"].where((element) => element["RuleNumber"] == ruleNumber && element["RulePriority"] == rulePriority).toList();
                                                                        }
                                                                      }
                                                                      detailList.add({
                                                                        "PromoItemSyskey" : orderStock[i]["stockData"][a]["stockSyskey"],
                                                                        "PromoItemDesc" : orderStock[i]["stockData"][a]["stockName"],
                                                                        "HeaderList" : [
                                                                          {
                                                                            "DetailList": sameDetailList,
                                                                            "ToDate" : multiDiscountStockList.where((element) => element["HeaderSyskey"] == headerSyskey).toList()[0]["ToDate"]
                                                                          }
                                                                        ]
                                                                      });
                                                                      print(detailList);
                                                                      Navigator.push(context, MaterialPageRoute(builder: (context) => DiscountDetail(detail: detailList, stockDetail: orderStock[i]["stockData"][a],)));
                                                                    } else {
                                                                _handleSubmit(context);
                                                                final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                String headerSyskey = "";
                                                                if(disCategoryList.where((element) => element["list"].where((value) => value["promoItemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0).toList().length != 0) {
                                                                  headerSyskey = disCategoryList.where((element) => element["list"].where((value) => value["promoItemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0).toList()[0]["hdrSyskey"];
                                                                }
                                                                getSysKey.then((val) {
                                                                  getPromoItemDetail("${val[0]["shopsyskey"]}", "", orderStock[i]["stockData"][a]["stockSyskey"], orderStock[i]["brandOwnerSyskey"]).then((promoDetailVal) {
                                                                    Navigator.pop(context);
                                                                    if(promoDetailVal == "success") {
                                                                      setState(() {
                                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => DiscountDetail(detail: promoItemDetailList, stockDetail: orderStock[i]["stockData"][a],)));
                                                                      });
                                                                    }else {
                                                                      snackbarmethod("FAIL!");
                                                                    }
                                                                  });
                                                                });
                                                                    }
                                                              },
                                                              child: Stack(
                                                                children: <Widget>[
                                                                  Padding(
                                                              padding: const EdgeInsets.only(left: 10),
                                                              child: ClipPath(
                                                                clipper: GiftBanner(),
                                                                child: Container(
                                                                  width: 40,
                                                                  height: 18,
                                                                  color: Colors.red,
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                                                                    child: Text(""),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment: Alignment.centerLeft,
                                                              child: Container(
                                                                width: 30,
                                                                height: 18,
                                                                decoration: BoxDecoration(
                                                                  color: Colors.red,
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(left: 5, top: 1, bottom: 1),
                                                                  child: Text("pro", style: TextStyle(color: Colors.white, letterSpacing: 1, fontSize: 12)),
                                                                ),
                                                              ),
                                                            )
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                            ]),
                          ),
                        ),
                        for(var b = 0; b < invPromotionList.length; b++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      child: Card(
                        elevation: 3,
                        // color: Colors.red[100],
                        color: Colors.white,
                        child: Stack(
                          children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("${invPromotionList[b]["stockName"]}", style: TextStyle(fontSize: 15)),
                                Text("Qty : ${invPromotionList[b]["qty"].toInt()}", style: TextStyle(fontSize: 13))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 70),
                            child: ClipPath(
                              clipper: GiftBanner(),
                              child: Container(
                                width: 40,
                                height: 18,
                                color: Colors.red,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                                  child: Text(""),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 90,
                              height: 18,
                            decoration: BoxDecoration(
                              color: Colors.red,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 3, top: 1, bottom: 1),
                              child: Text("Invoice Gift", style: TextStyle(color: Colors.white, letterSpacing: 1,fontSize: 12)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                              color: Colors.red[100],
                              child: Center(
                                  child: Text(
                                "Return Products",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17),
                              ))),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Container(
                            // height: returnStockLength,
                            child: Column(children: <Widget>[
                              for (var i = 0; i < returnStock.length; i++)
                                // ListView.builder(
                                //     physics: NeverScrollableScrollPhysics(),
                                //     itemCount: returnStock.length,
                                //     itemBuilder: (context, i) {
                                //       return
                                Visibility(
                                  visible:
                                      returnStock[i]["stockData"].length == 0
                                          ? false
                                          : true,
                                  child: Column(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          if (returnStock[i]["visible"] ==
                                              false) {
                                            setState(() {
                                              returnStock[i]["visible"] = true;
                                            });
                                          } else if (returnStock[i]
                                                  ["visible"] ==
                                              true) {
                                            setState(() {
                                              returnStock[i]["visible"] = false;
                                            });
                                          }
                                        },
                                        child: Container(
                                          height: 50,
                                          child: Card(
                                              color: Color(0xffe53935),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      returnStock[i][
                                                                  "brandOwnerName"] ==
                                                              null
                                                          ? ""
                                                          : returnStock[i][
                                                              "brandOwnerName"],
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.white),
                                                    ),
                                                    Icon(
                                                      returnStock[i]["visible"]
                                                          ? Icons
                                                              .keyboard_arrow_down
                                                          : Icons
                                                              .keyboard_arrow_right,
                                                      color: Colors.white,
                                                    )
                                                  ],
                                                ),
                                              )),
                                        ),
                                      ),
                                      Visibility(
                                        visible: returnStock[i]["visible"],
                                        child: Container(
                                          // height: 100.0 *
                                          //     returnStock[i]["stockData"]
                                          //         .length,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: returnStock[i]
                                                      ["stockData"]
                                                  .length,
                                              itemBuilder: (context, a) {
                                                return Container(
                                                  // height: 100,
                                                  child: Card(
                                                    elevation: 3,
                                                    child: Row(
                                                      children: <Widget>[
                                                        ConstrainedBox(
                                                          constraints:
                                                              BoxConstraints(
                                                            maxWidth: 64,
                                                            maxHeight: 80,
                                                          ),
                                                          child: stockImage ==
                                                                      [] ||
                                                                  stockImage
                                                                          .length ==
                                                                      0
                                                              ? GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ShowImage(image: Image.asset("assets/coca.png"))));
                                                                  },
                                                                  child: Image.asset(
                                                                      "assets/coca.png",
                                                                      fit: BoxFit
                                                                          .cover),
                                                                )
                                                              : Stack(
                                                                  children: <
                                                                      Widget>[
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => ShowImage(image: Image.asset("assets/coca.png"))));
                                                                      },
                                                                      child: Image.asset(
                                                                          "assets/coca.png",
                                                                          fit: BoxFit
                                                                              .cover),
                                                                    ),
                                                                    stockImage.where((element) => element["stockCode"] == returnStock[i]["stockData"][a]["stockCode"]).toList().toString() ==
                                                                            '[]'
                                                                        ? GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ShowImage(image: Image.asset("assets/coca.png"))));
                                                                            },
                                                                            child:
                                                                                Image.asset("assets/coca.png", fit: BoxFit.cover),
                                                                          )
                                                                        : GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ShowImage(image: CachedNetworkImage(imageUrl: "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == returnStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}"))));
                                                                            },
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              imageUrl: "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == returnStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
                                                                            ),
                                                                            // child: Image.network(
                                                                            //   "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == returnStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
                                                                            //   fit: BoxFit.cover,
                                                                            // ),
                                                                          )
                                                                  ],
                                                                ),
                                                        ),
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              82,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 3,
                                                                    top: 20,
                                                                    bottom: 10,
                                                                    left: 10),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: <
                                                                      Widget>[
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width -
                                                                          100,
                                                                      // height: 20,
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                              top: 5),
                                                                      child:
                                                                          Text(
                                                                        "${returnStock[i]["stockData"][a]["stockName"]}",
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
                                                                              top: 5),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: <
                                                                        Widget>[
                                                                      Row(
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                              "Qty : "),
                                                                          Text("${returnStock[i]["stockData"][a]["qty"]}".substring(
                                                                              0,
                                                                              "${returnStock[i]["stockData"][a]["qty"]}".lastIndexOf("."))),
                                                                        ],
                                                                      ),
                                                                      Container(
                                                                        width:
                                                                            150,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: <
                                                                              Widget>[
                                                                            Text("${returnStock[i]["stockData"][a]["normalPrice"].toInt()}" == "0" ? "${returnStock[i]["stockData"][a]["price"].toInt()}" : "${returnStock[i]["stockData"][a]["normalPrice"].toInt()}"),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(right: 15),
                                                                              child: Text(
                                                                                returnStock[i]["stockData"][a]["totalAmount"].toString().substring(returnStock[i]["stockData"][a]["totalAmount"].toString().lastIndexOf("."), returnStock[i]["stockData"][a]["totalAmount"].toString().length).length > 3 ?
                                                                                "${returnStock[i]["stockData"][a]["totalAmount"].toStringAsFixed(2)}" :
                                                                                double.parse(returnStock[i]["stockData"][a]["totalAmount"].toString().substring(returnStock[i]["stockData"][a]["totalAmount"].toString().lastIndexOf("."), returnStock[i]["stockData"][a]["totalAmount"].toString().length)) == 0.0 ?
                                                                                  "${returnStock[i]["stockData"][a]["totalAmount"].toInt()}" :
                                                                                  "${returnStock[i]["stockData"][a]["totalAmount"]}"),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                              padding: const EdgeInsets.only(top: 5, right: 15),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: <Widget>[
                                                                  Text("Max Qty (${returnStock[i]["stockData"][a]["returnQty"]})",
                                                                  style: TextStyle(fontSize: 12, color: Color(0xffef5350)),),
                                                                  Text(
                                                                    returnStock[i]["stockData"][a]["invoiceDate"] == "" || returnStock[i]["stockData"][a]["invoiceDate"] == null ? "" :
                                                                    "${returnStock[i]["stockData"][a]["invoiceDate"].substring(6, 8)}/${returnStock[i]["stockData"][a]["invoiceDate"].substring(4, 6)}/${returnStock[i]["stockData"][a]["invoiceDate"].substring(0, 4)}",
                                                                  style: TextStyle(fontSize: 12, color: Color(0xffef5350)),),
                                                                ],
                                                              ),
                                                            ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                            ]),
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Card(
                                color: Colors.grey[50],
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        getRow(
                                          "Sub Total :",
                                          getinvoiceOrderlist.length == 0 ?
                                          "0" :
                                            getinvoiceOrderlist[0]["orderTotalAmount"].toString().substring(getinvoiceOrderlist[0]["orderTotalAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["orderTotalAmount"].toString().length).length > 3 ?
                                            "${getinvoiceOrderlist[0]["orderTotalAmount"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
                                            double.parse(getinvoiceOrderlist[0]["orderTotalAmount"].toString().substring(getinvoiceOrderlist[0]["orderTotalAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["orderTotalAmount"].toString().length)) == 0.0 ?
                                            "${getinvoiceOrderlist[0]["orderTotalAmount"].toInt()}".replaceAllMapped(reg, mathFunc) :
                                            "${getinvoiceOrderlist[0]["orderTotalAmount"]}"
                                          .replaceAllMapped(reg, mathFunc)),
                                        getRow(
                                            "Special Discount Amount :",
                                            specialDiscountAmt == null
                                                ? "0"
                                                : "$specialDiscountAmt"
                                                    .replaceAllMapped(
                                                        reg, mathFunc)),
                                        getRow(
                                            "Expired Amount :",
                                            "$returnTotal".replaceAllMapped(
                                                reg, mathFunc)),
                                        // getRow("Discount ( 10% )", "${((totalCount - returnTotal) * 0.9).toString().substring(0, ((totalCount - returnTotal) * 0.9).toString().lastIndexOf("."))}"),
                                        getinvoiceOrderlist.length == 0 ?
                                        Container() :
                                        
                                        getRow(
                                          getinvoiceOrderlist[0]["orderDiscountAmount"].toString() == "0.0" && getinvoiceOrderlist[0]["orderDiscountPercent"].toString() == "0.0" ?
                                            "Total Amount :" : "Total Amount (${getinvoiceOrderlist[0]["orderDiscountPercent"]}%) :",
                                            getinvoiceOrderlist[0]["totalamount"].toString().substring(getinvoiceOrderlist[0]["totalamount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["totalamount"].toString().length).length > 3 ?
                                            "${getinvoiceOrderlist[0]["totalamount"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
                                            double.parse(getinvoiceOrderlist[0]["totalamount"].toString().substring(getinvoiceOrderlist[0]["totalamount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["totalamount"].toString().length)) == 0.0 ?
                                      "${getinvoiceOrderlist[0]["totalamount"].toInt()}".replaceAllMapped(reg, mathFunc) :
                                      "${getinvoiceOrderlist[0]["totalamount"]}"
                                          .replaceAllMapped(reg, mathFunc))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Card(
                          color: Colors.grey[50],
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  if(accountGetBalanceList.length != 0)
                                  if(accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == "0").toList().length != 0)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 5, left: 15, right: 15, top: 15),
                                    child: Row(
                                      children: <Widget>[
                                        Text(accountGetBalanceList.length == 0 || getinvoiceOrderlist.length == 0 ? "AB Account :" : "${accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == "0").toList()[0]["brandOwnerName"]} :",
                                          style: TextStyle(fontSize: 15)),
                                        Spacer(),
                                            Text(
                                                "$abAccount".replaceAllMapped(reg, mathFunc),
                                                style: TextStyle(
                                                    color: Color(0xffe53935),
                                                    fontSize: 17),
                                              )
                                      ],
                                    ),
                                  ),
                                  if(accountGetBalanceList.length != 0)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 5, left: 15, right: 15, top: 5),
                                    child: (Row(
                                      children: <Widget>[
                                        Text(accountGetBalanceList.length == 0 || getinvoiceOrderlist.length == 0 ? "SP Account :" : "${accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == getinvoiceOrderlist[0]["brandOwnerSyskey"].toString()).toList()[0]["brandOwnerName"]} :",
                                          style: TextStyle(fontSize: 15)),
                                        Spacer(),
                                        Text(
                                                "$spAccount".replaceAllMapped(reg, mathFunc),
                                                style: TextStyle(
                                                    color: Color(0xffe53935),
                                                    fontSize: 17),
                                              )
                                      ],
                                    )),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 5, left: 15, right: 15, top: accountGetBalanceList.length == 0 ? 15 : 5),
                                    child: (Row(
                                      children: <Widget>[
                                        Text("Cash Amount :",
                                            style: TextStyle(fontSize: 15)),
                                        Spacer(),
                                        Text(
                                          getinvoiceOrderlist.length == 0 ?
                                          "0" :
                                          getinvoiceOrderlist[0]["cashamount"].toString().substring(getinvoiceOrderlist[0]["cashamount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["cashamount"].toString().length).length > 3 ?
                                          "${getinvoiceOrderlist[0]["cashamount"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
                                          double.parse(getinvoiceOrderlist[0]["cashamount"].toString().substring(getinvoiceOrderlist[0]["cashamount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["cashamount"].toString().length)) == 0.0 ?
                                          "${getinvoiceOrderlist[0]["cashamount"].toInt()}".replaceAllMapped(reg, mathFunc) :
                                                "${getinvoiceOrderlist[0]["cashamount"]}".replaceAllMapped(reg, mathFunc),
                                                style: TextStyle(
                                                    color: Color(0xffe53935),
                                                    fontSize: 17),
                                              )
                                      ],
                                    )),
                                  ),
                                  getRow(
                                      "Credit Amount :",
                                      getinvoiceOrderlist.length == 0 ?
                                      "0" :
                                      getinvoiceOrderlist[0]["creditAmount"].toString().substring(getinvoiceOrderlist[0]["creditAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["creditAmount"].toString().length).length > 3 ? 
                                      "${getinvoiceOrderlist[0]["creditAmount"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
                                      double.parse(getinvoiceOrderlist[0]["creditAmount"].toString().substring(getinvoiceOrderlist[0]["creditAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["creditAmount"].toString().length)) == 0.0 ?
                                          "${getinvoiceOrderlist[0]["creditAmount"].toInt()}".replaceAllMapped(reg, mathFunc) :
                                      "${getinvoiceOrderlist[0]["creditAmount"]}"
                                          .replaceAllMapped(reg, mathFunc)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
                        child: Card(
                          color: Color(0xffef5350),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("Additional Cash :", style: TextStyle(color: Colors.white, fontSize: 15),),
                                  Text("$cashReceived".replaceAllMapped(reg, mathFunc), style: TextStyle(color: Colors.white, fontSize: 15),)
                                ],
                              )
                            ),
                          ),
                        ),
                      ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 5, right: 5, bottom: 15),
                              child: GestureDetector(
                                onTap: () async {
                                  final SharedPreferences preferences = await SharedPreferences.getInstance();
                                    if(preferences.getString("PrintType") == "Java") {
                                      javafilePrinter();
                                    } else if(preferences.getString("PrintType") == "Thermal") {
                                      blueThermalPrinter();
                                    } else {
                                      snackbarmethod("Please select printer!");
                                    }
                                },
                                child: Card(
                                  color: Color(0xffef5350),
                                  child: Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    child: Center(
                                        child: Text(
                                      "Print",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
          ],
        ),
      ),
      backgroundColor: Colors.blueGrey[50],
    );

    // 1131950

    var loadProgress = new Container(
        child: new Stack(children: <Widget>[
      body,
      Container(
        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 0.5)),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
      child: loading ? loadProgress : body,
    );
  }

  Future<void> javafilePrinter() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    orderName = [];
    orderQty = [];
    orderTotalCount = [];
    rtnItemName = [];
    rtnItemQty = [];
    rtnItemTolCount = [];
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy HH:mm');
    final String timestamp = formatter.format(now);

    List accountList = [];
    List totalCashList = [];
    String totalAmountPercent = '';
    String printOrderTotalAmt = "0";
    String printCashAmt = "0";
    String printCreditAmt = "0";
    String printTotalAmt = "0";
                                      

    if(getinvoiceOrderlist[0]["orderTotalAmount"].toString().substring(getinvoiceOrderlist[0]["orderTotalAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["orderTotalAmount"].toString().length).length > 3) {
      printOrderTotalAmt = "${getinvoiceOrderlist[0]["orderTotalAmount"].toStringAsFixed(2)}";
    }else if(double.parse(getinvoiceOrderlist[0]["orderTotalAmount"].toString().substring(getinvoiceOrderlist[0]["orderTotalAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["orderTotalAmount"].toString().length)) == 0.0) {
      printOrderTotalAmt = "${getinvoiceOrderlist[0]["orderTotalAmount"].toInt()}";
    } else {
      printOrderTotalAmt = "${getinvoiceOrderlist[0]["orderTotalAmount"]}";
    }

    if(getinvoiceOrderlist[0]["cashamount"].toString().substring(getinvoiceOrderlist[0]["cashamount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["cashamount"].toString().length).length > 3) {
      printCashAmt = "${getinvoiceOrderlist[0]["cashamount"].toStringAsFixed(2)}";
    }else if(double.parse(getinvoiceOrderlist[0]["cashamount"].toString().substring(getinvoiceOrderlist[0]["cashamount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["cashamount"].toString().length)) == 0.0) {
      printCashAmt = "${getinvoiceOrderlist[0]["cashamount"].toInt()}";
    } else {
      printCashAmt = "${getinvoiceOrderlist[0]["cashamount"]}";
    }

    if(getinvoiceOrderlist[0]["creditAmount"].toString().substring(getinvoiceOrderlist[0]["creditAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["creditAmount"].toString().length).length > 3) {
      printCreditAmt = "${getinvoiceOrderlist[0]["creditAmount"].toStringAsFixed(2)}";
    } else if(double.parse(getinvoiceOrderlist[0]["creditAmount"].toString().substring(getinvoiceOrderlist[0]["creditAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["creditAmount"].toString().length)) == 0.0) {
      printCreditAmt = "${getinvoiceOrderlist[0]["creditAmount"].toInt()}";
    } else {
      printCreditAmt = "${getinvoiceOrderlist[0]["creditAmount"]}";
    }

    printTotalAmt = "${getinvoiceOrderlist[0]["totalamount"]}";
    if(printTotalAmt.toString().substring(printTotalAmt.toString().lastIndexOf("."), printTotalAmt.toString().length).length > 3) {
      printTotalAmt = double.parse(printTotalAmt).toStringAsFixed(2);
    }else if(double.parse(printTotalAmt.toString().substring(printTotalAmt.toString().lastIndexOf("."), printTotalAmt.toString().length)) == 0.0) {
      printTotalAmt = "${double.parse(printTotalAmt).toInt()}";
    }

    if(accountGetBalanceList.length != 0) {
      if(accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == "0").toList().length != 0) {
          
        accountList.add({
          "AccountName" : '${accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == "0").toList()[0]["brandOwnerName"]}',
          "AccountValue" : "$abAccount".replaceAllMapped(reg, mathFunc)
        });

      }

      if(accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == getinvoiceOrderlist[0]["brandOwnerSyskey"].toString()).toList().length != 0) {
                                            
        accountList.add({
          "AccountName" : '${accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == getinvoiceOrderlist[0]["brandOwnerSyskey"].toString()).toList()[0]["brandOwnerName"]}',
          "AccountValue" : "$spAccount".replaceAllMapped(reg, mathFunc)
        });

      }
    }

    if(getInvDisCalculationList.toString() != "" && getInvDisCalculationList.toString() != "null") {
      if(getInvDisCalculationList["DiscountAmount"].toString() == "0" && getInvDisCalculationList["DiscountPercent"].toString() == "0") {
        totalAmountPercent = '';
      } else {
        totalAmountPercent = "(${getinvoiceOrderlist[0]["orderDiscountPercent"].toInt()}%)";
      }
    }

    if(cashReceived != 0) {
      totalCashList.add({
        "value" : "$cashReceived".replaceAllMapped(reg, mathFunc)
      });
    }

    List header = [
      {
        "Store": "${preferences.getString('shopname')}",
        "Store_ID": "${preferences.getString('shopCode')}",
        "StoreNameMM" : "${preferences.getString("shopnamemm")}",
        "Tel": "${preferences.getString('phNo')}",
        "Preseller": "$preSellerName",
        "User_Name": "${preferences.getString('userName')}",
        "Invoice_No": "1",
        "Print_Date": "$timestamp",
        "Invoice_Date": "${deliveryDate.substring(4, 6)}/${deliveryDate.substring(6, 8)}/${deliveryDate.substring(0, 4)} ${deliveryDate.substring(8, 10)}:${deliveryDate.substring(10, 12)}",
        "Sub_Total": "$printOrderTotalAmt".replaceAllMapped(reg, mathFunc),
        "Special_Discount_Amount": "$specialAmount".replaceAllMapped(reg, mathFunc),
        "Expired_Amount": "$returnTotal".replaceAllMapped(reg, mathFunc),
        "AccountList" : accountList,
        "Cash_Amount":"$printCashAmt".replaceAllMapped(reg, mathFunc),
        "Credit_Amount":"$printCreditAmt".replaceAllMapped(reg, mathFunc),
        "Total_Amount": "$printTotalAmt".replaceAllMapped(reg, mathFunc),
        "Total_Amount_Percent" : '$totalAmountPercent'.replaceAllMapped(reg, mathFunc),
        "Additional_Cash": totalCashList,
        "Street":"${preferences.getString("address")}"
      }
    ];

    print(header);

    List detail = [];

    for (var a = 0; a < getinvoiceOrderlist.length; a++) {
      for (var b = 0; b < getinvoiceOrderlist[a]["stockData"].length; b++) {

        String printerDis = "${getinvoiceOrderlist[a]["stockData"][b]["discountPercent"]}";

        if(printerDis == "0.0") {
          // printerDis = "0";
          printerDis = "";
        }

        if(printerDis != "") {
          if(printerDis.substring(printerDis.lastIndexOf("."), printerDis.length).length > 3) {
            print("aa");
            printerDis = double.parse(printerDis).toStringAsFixed(2);
          } else if(double.parse(printerDis.substring(printerDis.lastIndexOf("."), printerDis.length)).toString() == "0.0") {
            print("bb");
            printerDis = double.parse(printerDis).toInt().toString();
          }
          printerDis = "@$printerDis%";
        }

        detail.add({
          "stkDesc": "${getinvoiceOrderlist[a]["stockData"][b]["stockName"]}$printerDis",
          "totalqty": "${getinvoiceOrderlist[a]["stockData"][b]["qty"].toInt()}",

          "standardPrice": getinvoiceOrderlist[a]["stockData"][b]["normalPrice"].toString().substring(getinvoiceOrderlist[a]["stockData"][b]["normalPrice"].toString().lastIndexOf("."), getinvoiceOrderlist[a]["stockData"][b]["normalPrice"].toString().length).length > 3 ?
            "${getinvoiceOrderlist[a]["stockData"][b]["normalPrice"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
            double.parse(getinvoiceOrderlist[a]["stockData"][b]["normalPrice"].toString().substring(getinvoiceOrderlist[a]["stockData"][b]["normalPrice"].toString().lastIndexOf("."), getinvoiceOrderlist[a]["stockData"][b]["normalPrice"].toString().length)) == 0.0 ?
            "${getinvoiceOrderlist[a]["stockData"][b]["normalPrice"].toInt()}".replaceAllMapped(reg, mathFunc) :
            "${getinvoiceOrderlist[a]["stockData"][b]["normalPrice"]}".replaceAllMapped(reg, mathFunc),

          "sellingPrice": getinvoiceOrderlist[a]["stockData"][b]["price"].toString().substring(getinvoiceOrderlist[a]["stockData"][b]["price"].toString().lastIndexOf("."), getinvoiceOrderlist[a]["stockData"][b]["price"].toString().length).length > 3 ?
            "${getinvoiceOrderlist[a]["stockData"][b]["price"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
            double.parse(getinvoiceOrderlist[a]["stockData"][b]["price"].toString().substring(getinvoiceOrderlist[a]["stockData"][b]["price"].toString().lastIndexOf("."), getinvoiceOrderlist[a]["stockData"][b]["price"].toString().length)) == 0.0 ?
            "${getinvoiceOrderlist[a]["stockData"][b]["price"].toInt()}".replaceAllMapped(reg, mathFunc) :
            "${getinvoiceOrderlist[a]["stockData"][b]["price"]}".replaceAllMapped(reg, mathFunc),

          "totalAmount": getinvoiceOrderlist[a]["stockData"][b]["totalAmount"].toString().substring(getinvoiceOrderlist[a]["stockData"][b]["totalAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[a]["stockData"][b]["totalAmount"].toString().length).length > 3 ?
            "${getinvoiceOrderlist[a]["stockData"][b]["totalAmount"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
            double.parse(getinvoiceOrderlist[a]["stockData"][b]["totalAmount"].toString().substring(getinvoiceOrderlist[a]["stockData"][b]["totalAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[a]["stockData"][b]["totalAmount"].toString().length)) == 0.0 ?
            "${getinvoiceOrderlist[a]["stockData"][b]["totalAmount"].toInt()}".replaceAllMapped(reg, mathFunc) :
            "${getinvoiceOrderlist[a]["stockData"][b]["totalAmount"]}".replaceAllMapped(reg, mathFunc)
        });

        if(getinvoiceOrderlist[a]["stockData"][b]["promotionStockList"].length != 0) {
          for(var c = 0; c < getinvoiceOrderlist[a]["stockData"][b]["promotionStockList"].length; c++) {
            detail.add({
              "stkDesc": "${getinvoiceOrderlist[a]["stockData"][b]["promotionStockList"][c]["stockName"]}",
              "totalqty": "${getinvoiceOrderlist[a]["stockData"][b]["promotionStockList"][c]["qty"].toInt()}",
              "standardPrice": "0",
              "sellingPrice":"0",
              "totalAmount": "0"
            });
          }
        }
      }

      for (var b = 0; b < getinvoiceOrderlist[a]["stockReturnData"].length; b++) {

        String printerDis = "${getinvoiceOrderlist[a]["stockReturnData"][b]["discountPercent"]}";

        if(printerDis == "0.0") {
          // printerDis = "0";
          printerDis = "";
        }

        if(printerDis != "") {
          if(printerDis.substring(printerDis.lastIndexOf("."), printerDis.length).length > 3) {
            print("aa");
            printerDis = double.parse(printerDis).toStringAsFixed(2);
          } else if(double.parse(printerDis.substring(printerDis.lastIndexOf("."), printerDis.length)).toString() == "0.0") {
            print("bb");
            printerDis = double.parse(printerDis).toInt().toString();
          }
          printerDis = "@$printerDis%";
        }

        detail.add({
          "stkDesc": "${getinvoiceOrderlist[a]["stockReturnData"][b]["stockName"]}$printerDis",
          "totalqty": "-${getinvoiceOrderlist[a]["stockReturnData"][b]["qty"].toInt()}",

          "standardPrice": getinvoiceOrderlist[a]["stockReturnData"][b]["normalPrice"].toString().substring(getinvoiceOrderlist[a]["stockReturnData"][b]["normalPrice"].toString().lastIndexOf("."), getinvoiceOrderlist[a]["stockReturnData"][b]["normalPrice"].toString().length).length > 3 ?
            "-${getinvoiceOrderlist[a]["stockReturnData"][b]["normalPrice"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
            double.parse(getinvoiceOrderlist[a]["stockReturnData"][b]["normalPrice"].toString().substring(getinvoiceOrderlist[a]["stockReturnData"][b]["normalPrice"].toString().lastIndexOf("."), getinvoiceOrderlist[a]["stockReturnData"][b]["normalPrice"].toString().length)) == 0.0 ?
            "-${getinvoiceOrderlist[a]["stockReturnData"][b]["normalPrice"].toInt()}".replaceAllMapped(reg, mathFunc) :
            "-${getinvoiceOrderlist[a]["stockReturnData"][b]["normalPrice"]}".replaceAllMapped(reg, mathFunc),

          "sellingPrice": getinvoiceOrderlist[a]["stockReturnData"][b]["price"].toString().substring(getinvoiceOrderlist[a]["stockReturnData"][b]["price"].toString().lastIndexOf("."), getinvoiceOrderlist[a]["stockReturnData"][b]["price"].toString().length).length > 3 ?
            "-${getinvoiceOrderlist[a]["stockReturnData"][b]["price"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
            double.parse(getinvoiceOrderlist[a]["stockReturnData"][b]["price"].toString().substring(getinvoiceOrderlist[a]["stockReturnData"][b]["price"].toString().lastIndexOf("."), getinvoiceOrderlist[a]["stockReturnData"][b]["price"].toString().length)) == 0.0 ?
            "-${getinvoiceOrderlist[a]["stockReturnData"][b]["price"].toInt()}".replaceAllMapped(reg, mathFunc) :
            "-${getinvoiceOrderlist[a]["stockReturnData"][b]["price"]}".replaceAllMapped(reg, mathFunc),

          "totalAmount": getinvoiceOrderlist[a]["stockReturnData"][b]["totalAmount"].toString().substring(getinvoiceOrderlist[a]["stockReturnData"][b]["totalAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[a]["stockReturnData"][b]["totalAmount"].toString().length).length > 3 ?
            "-${getinvoiceOrderlist[a]["stockReturnData"][b]["totalAmount"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
            double.parse(getinvoiceOrderlist[a]["stockReturnData"][b]["totalAmount"].toString().substring(getinvoiceOrderlist[a]["stockReturnData"][b]["totalAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[a]["stockReturnData"][b]["totalAmount"].toString().length)) == 0.0 ?
            "-${getinvoiceOrderlist[a]["stockReturnData"][b]["totalAmount"].toInt()}".replaceAllMapped(reg, mathFunc) :
            "-${getinvoiceOrderlist[a]["stockReturnData"][b]["totalAmount"]}".replaceAllMapped(reg, mathFunc)
        });

        

      }
    }

    print(detail);

    List invDetail = [];

    for (var i = 0; i < invPromotionList.length; i++) {
      invDetail.add({
        "stkDesc": "${invPromotionList[i]["stockName"]}@GIFT",
        "totalqty": "${invPromotionList[i]["qty"].toInt()}",
        "standardPrice": "0",
        "sellingPrice":"0",
        "totalAmount": "0"
      });
    }

    print(invDetail);

    String bName = "${getinvoiceOrderlist[0]["brandOwnerName"]}";

    var stringname = preferences.getString("printerName");

    if(stringname == "" || stringname == null) {
      Navigator.pop(context);
      snackbarmethod("Please select printer!");
    } else {
      Navigator.pop(context);
      printMultiLang(detail, invDetail, header, bName);
      printMultiLang(detail, invDetail, header, bName);
    }
  }

  static const platform = const MethodChannel('flutter.native/helper');

  Future<void> printMultiLang(
      List detailData, List invDetail, List headerData, String bName) async {
    try {
      final String result = await platform.invokeMethod('multi_lang_test',
          {"detail": detailData, "invDetail" : invDetail, "header": headerData, "bName": bName});
      print('start scan >>$result');
    } on PlatformException catch (e) {
      print('Failed to Invoke: ${e.message}');
    }
  }

  Future<void> blueThermalPrinter() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    List stockDetailList = [];
    String space = " ";

    String printerBrandOwnerName = '${getinvoiceOrderlist[0]["brandOwnerName"]}';
    String printerStoreName = 'Store : ${preferences.getString('shopname')}';
    String printerStoreID = 'Store ID : ${preferences.getString('shopCode')}';
    String printerTel = "Tel : ${preferences.getString('phNo')}";
    String printerPreseller = "Preseller : $preSellerName";
    String printerUserName = "User Name : ${preferences.getString('userName')}";
    String printerInvNo = "Invoice No : 1";
    String printerPrintDate = "Print Date : ${DateFormat('MM/dd/yyyy HH:mm').format(DateTime.now())}";
    String printerInvDate = "Invoice Date : ${"${deliveryDate.substring(4, 6)}/${deliveryDate.substring(6, 8)}/${deliveryDate.substring(0, 4)} ${deliveryDate.substring(8, 10)}:${deliveryDate.substring(10, 12)}"}";

    stockDetailList.add({
      "value" : "SKU${space * 31}Standard Normal${space * 2}Qty${space * 4}Amount"
    });

    stockDetailList.add({
      "value" : "${space * 37}Price${space * 2}Price${space * 14}"
    });
                                    
    for (var a = 0; a < getinvoiceOrderlist.length; a++) {
      for (var b = 0; b < getinvoiceOrderlist[a]["stockData"].length; b++) {
        String printerDis = "${getinvoiceOrderlist[a]["stockData"][b]["discountPercent"]}";
        if(printerDis == "0.0") {
          // printerDis = "0";
          printerDis = "";
        }

        if(printerDis != "") {
          if(printerDis.substring(printerDis.lastIndexOf("."), printerDis.length).length > 3) {
            print("aa");
            printerDis = double.parse(printerDis).toStringAsFixed(2);
          } else if(double.parse(printerDis.substring(printerDis.lastIndexOf("."), printerDis.length)).toString() == "0.0") {
            print("bb");
            printerDis = double.parse(printerDis).toInt().toString();
          }
          printerDis = "@$printerDis%";
        }

        String printerSku = getinvoiceOrderlist[a]["stockData"][b]["stockName"] + printerDis;
        String printerPrice = "${getinvoiceOrderlist[a]["stockData"][b]["price"]}";
        
        if(printerPrice.substring(printerPrice.lastIndexOf("."), printerPrice.length).length > 3) {
          printerPrice = double.parse(printerPrice).toStringAsFixed(2);
        } else if(double.parse(printerPrice.substring(printerPrice.lastIndexOf("."), printerPrice.length)).toString() == "0.0") {
          printerPrice = double.parse(printerPrice).toInt().toString();
        }

        String printerNormalPrice = "${getinvoiceOrderlist[a]["stockData"][b]["normalPrice"]}";
        if(printerNormalPrice.substring(printerNormalPrice.lastIndexOf("."), printerNormalPrice.length).length > 3) {
          printerNormalPrice = double.parse(printerNormalPrice).toStringAsFixed(2);
        } else if(double.parse(printerNormalPrice.substring(printerNormalPrice.lastIndexOf("."), printerNormalPrice.length)).toString() == "0.0") {
          printerNormalPrice = double.parse(printerNormalPrice).toInt().toString();
        }

        String printerQty = "${getinvoiceOrderlist[a]["stockData"][b]["qty"].toInt()}";
        String printerAmt = "${getinvoiceOrderlist[a]["stockData"][b]["totalAmount"]}";
        if(printerAmt.substring(printerAmt.lastIndexOf("."), printerAmt.length).length > 3) {
          printerAmt = double.parse(printerAmt).toStringAsFixed(2);
        } else if(double.parse(printerAmt.substring(printerAmt.lastIndexOf("."), printerAmt.length)).toString() == "0.0") {
          printerAmt = double.parse(printerAmt).toInt().toString();
        }
        if(printerSku.toString().length > 35) {
          stockDetailList.add({
            "value" : "${printerSku.substring(0, 35)}${space * (35-printerSku.substring(0, 35).length)} ${space * (6- printerNormalPrice.length)}$printerNormalPrice ${space * (6-printerPrice.length)}$printerPrice ${space * (4-printerQty.length)}$printerQty ${space * (9-printerAmt.length)}$printerAmt"
          });
          stockDetailList.add({
            "value" : "${printerSku.substring(35, printerSku.length)}"
          });
        } else {
          stockDetailList.add({
            "value" : "$printerSku${space * (35-printerSku.length)} ${space * (6- printerNormalPrice.length)}$printerNormalPrice ${space * (6-printerPrice.length)}$printerPrice ${space * (4-printerQty.length)}$printerQty ${space * (9-printerAmt.length)}$printerAmt"
          });
        }

        if(getinvoiceOrderlist[a]["stockData"][b]["promotionStockList"].length != 0) {
          for(var c = 0; c < getinvoiceOrderlist[a]["stockData"][b]["promotionStockList"].length; c++) {
            String printerPromoSku = "${getinvoiceOrderlist[a]["stockData"][b]["promotionStockList"][c]["stockName"]}";
            String printerPromoQty = "${getinvoiceOrderlist[a]["stockData"][b]["promotionStockList"][c]["qty"].toInt()}";
            if(printerPromoSku.length > 35) {
              stockDetailList.add({
                "value" : "${printerPromoSku.substring(0, 35)}${space * (35-printerPromoSku.substring(0, 35).length)}${space*6}0${space*6}0${space* (5-printerPromoQty.length)}$printerPromoQty ${space * 8}0"
              });
              stockDetailList.add({
                "value" : "${printerPromoSku.substring(35, printerPromoSku.length)}"
              });
            } else {
              stockDetailList.add({
                "value" : "$printerPromoSku${space * (35-printerPromoSku.length)}${space*6}0${space*6}0${space* (5-printerPromoQty.length)}$printerPromoQty ${space * 8}0"
              });
            }
            
          }
        }
      }

      for (var b = 0; b < getinvoiceOrderlist[a]["stockReturnData"].length; b++) {
        String printerSku = getinvoiceOrderlist[a]["stockReturnData"][b]["stockName"];
        String printerPrice = "-${getinvoiceOrderlist[a]["stockReturnData"][b]["price"]}";
        if(printerPrice.substring(printerPrice.lastIndexOf("."), printerPrice.length).length > 3) {
          printerPrice = double.parse(printerPrice).toStringAsFixed(2);
        } else if(double.parse(printerPrice.substring(printerPrice.lastIndexOf("."), printerPrice.length)).toString() == "0.0") {
          printerPrice = double.parse(printerPrice).toInt().toString();
        }

        String printerNormalPrice = "-${getinvoiceOrderlist[a]["stockReturnData"][b]["normalPrice"]}";
        if(printerNormalPrice.substring(printerNormalPrice.lastIndexOf("."), printerNormalPrice.length).length > 3) {
          printerNormalPrice = double.parse(printerNormalPrice).toStringAsFixed(2);
        } else if(double.parse(printerNormalPrice.substring(printerNormalPrice.lastIndexOf("."), printerNormalPrice.length)).toString() == "0.0") {
          printerNormalPrice = double.parse(printerNormalPrice).toInt().toString();
        }
        String printerDis = "${getinvoiceOrderlist[a]["stockReturnData"][b]["discountPercent"]}";
        if(printerDis == "0.0") {
          printerDis = "0";
        }
        String printerQty = "-${getinvoiceOrderlist[a]["stockReturnData"][b]["qty"].toInt()}";
        String printerAmt = "-${getinvoiceOrderlist[a]["stockReturnData"][b]["totalAmount"]}";
        if(printerAmt.substring(printerAmt.lastIndexOf("."), printerAmt.length).length > 3) {
          printerAmt = double.parse(printerAmt).toStringAsFixed(2);
        } else if(double.parse(printerAmt.substring(printerAmt.lastIndexOf("."), printerAmt.length)).toString() == "0.0") {
          printerAmt = double.parse(printerAmt).toInt().toString();
        }
        if(printerSku.toString().length > 35) {
          stockDetailList.add({
            "value" : "${printerSku.substring(0, 35)}${space * (35-printerSku.substring(0, 35).length)} ${space * (6- printerNormalPrice.length)}$printerNormalPrice ${space * (6-printerPrice.length)}$printerPrice ${space * (4-printerQty.length)}$printerQty ${space * (9-printerAmt.length)}$printerAmt"
          });
          stockDetailList.add({
            "value" : "${printerSku.substring(35, printerSku.length)}"
          });
        } else {
          stockDetailList.add({
            "value" : "$printerSku${space * (35-printerSku.length)} ${space * (6- printerNormalPrice.length)}$printerNormalPrice ${space * (6-printerPrice.length)}$printerPrice ${space * (4-printerQty.length)}$printerQty ${space * (9-printerAmt.length)}$printerAmt"
          });
        }
      }
    }

    for(var i = 0; i < stockDetailList.length; i++) {
      print(stockDetailList[i]["value"]);
    }

    List invPromoDetail = [];

    for (var i = 0; i < invPromotionList.length; i++) {
      String printerPromoSku = "${invPromotionList[i]["stockName"]}@GIFT";
      String printerPromoQty = "${invPromotionList[i]["qty"].toInt()}";
      if(printerPromoSku.length > 35) {
        invPromoDetail.add({
          "value" : "${printerPromoSku.substring(0, 35)}${space * (35-printerPromoSku.substring(0, 35).length)}${space*6}0${space*6}0${space* (5-printerPromoQty.length)}$printerPromoQty ${space * 8}0"
        });
        invPromoDetail.add({
          "value" : "${printerPromoSku.substring(35, printerPromoSku.length)}"
        });
      } else {
        invPromoDetail.add({
          "value" : "$printerPromoSku${space * (35-printerPromoSku.length)}${space*6}0${space*6}0${space* (5-printerPromoQty.length)}$printerPromoQty ${space * 8}0"
        });
      }
    }

    for(var i = 0; i < invPromoDetail.length; i++) {
      print(invPromoDetail[i]["value"]);
    }

    String printOrderTotalAmt = "0";

    if(getinvoiceOrderlist[0]["orderTotalAmount"].toString().substring(getinvoiceOrderlist[0]["orderTotalAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["orderTotalAmount"].toString().length).length > 3) {
      printOrderTotalAmt = "${getinvoiceOrderlist[0]["orderTotalAmount"].toStringAsFixed(2)}";
    }else if(double.parse(getinvoiceOrderlist[0]["orderTotalAmount"].toString().substring(getinvoiceOrderlist[0]["orderTotalAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["orderTotalAmount"].toString().length)) == 0.0) {
      printOrderTotalAmt = "${getinvoiceOrderlist[0]["orderTotalAmount"].toInt()}";
    } else {
      printOrderTotalAmt = "${getinvoiceOrderlist[0]["orderTotalAmount"]}";
    }

    String printerSubTotal = "Sub Total${space * (55 - printOrderTotalAmt.length)}$printOrderTotalAmt";

    print(printerSubTotal);

    specialAmount = getinvoiceOrderlist[0]["discountamount"].toInt();

    String printerSpecialDisAmt = "Special Discount Amount${space * (41- specialAmount.toString().length)}$specialAmount";

    print(printerSpecialDisAmt);

    String printerReturnTotalAmt = "0";

    if(getinvoiceOrderlist[0]["returnTotalAmount"].toString().substring(getinvoiceOrderlist[0]["returnTotalAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["returnTotalAmount"].toString().length).length > 3) {
      printerReturnTotalAmt = "${getinvoiceOrderlist[0]["returnTotalAmount"].toStringAsFixed(2)}";
    }else if(double.parse(getinvoiceOrderlist[0]["returnTotalAmount"].toString().substring(getinvoiceOrderlist[0]["returnTotalAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["returnTotalAmount"].toString().length)) == 0.0) {
      printerReturnTotalAmt = "${getinvoiceOrderlist[0]["returnTotalAmount"].toInt()}";
    } else {
      printerReturnTotalAmt = "${getinvoiceOrderlist[0]["returnTotalAmount"]}";
    }

    String printerExpAmt = "Expired Amount${space * (50 - printerReturnTotalAmt.length)}$printerReturnTotalAmt";

    print(printerExpAmt);

    List accountDetail = [];

    if(accountGetBalanceList.length != 0) {
      String accountName = "";
      String accountValue = "";
      if(accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == "0").toList().length != 0) {
          
        accountName = '${accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == "0").toList()[0]["brandOwnerName"]}';
        accountValue = "$abAccount".replaceAllMapped(reg, mathFunc);
                                          
        accountDetail.add({
          "value" : "$accountName${space * (64 - (accountName.length + accountValue.length))}$accountValue",
        });

      }

      if(accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == getinvoiceOrderlist[0]["brandOwnerSyskey"].toString()).toList().length != 0) {
                                            
        accountName = '${accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == getinvoiceOrderlist[0]["brandOwnerSyskey"].toString()).toList()[0]["brandOwnerName"]}';
        accountValue = "$spAccount".replaceAllMapped(reg, mathFunc);
                                          
        accountDetail.add({
          "value" : "$accountName${space * (64 - (accountName.length + accountValue.length))}$accountValue",
        });
      }
    }

    for(var i = 0; i < accountDetail.length; i++) {
      print(accountDetail[i]["value"]);
    }

    String printCashAmt = "0";

    if(getinvoiceOrderlist[0]["cashamount"].toString().substring(getinvoiceOrderlist[0]["cashamount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["cashamount"].toString().length).length > 3) {
      printCashAmt = "${getinvoiceOrderlist[0]["cashamount"].toStringAsFixed(2)}";
    }else if(double.parse(getinvoiceOrderlist[0]["cashamount"].toString().substring(getinvoiceOrderlist[0]["cashamount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["cashamount"].toString().length)) == 0.0) {
      printCashAmt = "${getinvoiceOrderlist[0]["cashamount"].toInt()}";
    } else {
      printCashAmt = "${getinvoiceOrderlist[0]["cashamount"]}";
    }

    String printerCashAmt = "Cash Amount${space * (53 - printCashAmt.length)}$printCashAmt";

    print(printerCashAmt);

    String printCreditAmt = "0";

    if(getinvoiceOrderlist[0]["creditAmount"].toString().substring(getinvoiceOrderlist[0]["creditAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["creditAmount"].toString().length).length > 3) {
      printCreditAmt = "${getinvoiceOrderlist[0]["creditAmount"].toStringAsFixed(2)}";
    } else if(double.parse(getinvoiceOrderlist[0]["creditAmount"].toString().substring(getinvoiceOrderlist[0]["creditAmount"].toString().lastIndexOf("."), getinvoiceOrderlist[0]["creditAmount"].toString().length)) == 0.0) {
      printCreditAmt = "${getinvoiceOrderlist[0]["creditAmount"].toInt()}";
    } else {
      printCreditAmt = "${getinvoiceOrderlist[0]["creditAmount"]}";
    }

    String printerCreditAmt = "Credit Amount${space * (51 - printCreditAmt.length)}$printCreditAmt";

    print(printerCreditAmt);

    String totalAmountPercent = "";

    if(getInvDisCalculationList.toString() != "" && getInvDisCalculationList.toString() != "null") {
      if(getInvDisCalculationList["DiscountAmount"].toString() == "0" && getInvDisCalculationList["DiscountPercent"].toString() == "0") {
        totalAmountPercent = '';
      } else {
        totalAmountPercent = "(${getinvoiceOrderlist[0]["orderDiscountPercent"].toInt()}%)";
      }
    }

    String printTotalAmt = "";

    printTotalAmt = "${getinvoiceOrderlist[0]["totalamount"] - specialDiscountAmt}";
    if(printTotalAmt.toString().substring(printTotalAmt.toString().lastIndexOf("."), printTotalAmt.toString().length).length > 3) {
      printTotalAmt = double.parse(printTotalAmt).toStringAsFixed(2);
    }else if(double.parse(printTotalAmt.toString().substring(printTotalAmt.toString().lastIndexOf("."), printTotalAmt.toString().length)) == 0.0) {
      printTotalAmt = double.parse(printTotalAmt).toInt().toString();
    }

    String printerTotalAmt = "Total Amount$totalAmountPercent${space * (52 - (totalAmountPercent.length + printTotalAmt.length))}$printTotalAmt";

    print(printerTotalAmt);

    List printerAdditionalCash = [];

    if(cashReceived != 0) {
      printerAdditionalCash.add({
        "value" : "Additional Cash${space * (45 - cashReceived.toString().length)}$cashReceived"
      });
    }

    for(var i = 0; i < printerAdditionalCash.length; i++) {
      print(printerAdditionalCash[i]["value"]);
    }

    var stringname = preferences.getString("printerName");

    if(stringname == "" || stringname == null) {
      Navigator.pop(context);
      snackbarmethod("Please select printer!");
    } else {
      Navigator.pop(context);
      tesPrint(printerBrandOwnerName, printerStoreName, printerStoreID, printerTel, printerPreseller, printerUserName, printerInvNo, printerPrintDate, printerInvDate, stockDetailList, invPromoDetail, printerSubTotal, printerSpecialDisAmt, printerExpAmt, accountDetail, printerCashAmt, printerCreditAmt, printerTotalAmt, printerAdditionalCash);
    }
  }

  Future _startScanDevices() async {
    // _devices = widget.devices;
    printerManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;
      });
    });
    printerManager.startScan(Duration(seconds: 2));

    Future.delayed(Duration(seconds: 2), () {
      getList();
    });
  }

}

Widget getRow(String title, String subTitle) {
  return Padding(
    padding: EdgeInsets.only(bottom: 5, left: 15, right: 15, top: 5),
    child: (Row(
      children: <Widget>[
        Text(title, style: TextStyle(fontSize: 15)),
        Spacer(),
        Text(
          subTitle,
          style: TextStyle(color: Color(0xffe53935), fontSize: 17),
        )
      ],
    )),
  );
}

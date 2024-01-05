import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_2/Invoice.dart';
import 'package:delivery_2/OrderDetail.dart';
import 'package:delivery_2/Widgets/AddOrderStock.dart';
import 'package:delivery_2/service.dart/AllService.dart';
import 'Login.dart';
import 'Widgets/AddReturnProduct.dart';
import 'Widgets/DiscountDetail.dart';
import 'Widgets/ShowImage.dart';
import 'Widgets/MultiGiftDialog.dart';
import 'database/shopByUserDatabase.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:delivery_2/database/shopByUserNote.dart';
import 'package:delivery_2/database/ReturnDatabase.dart';
import 'Widgets/giftBanner.dart';
import 'navigation_bar.dart';

class OrderDetailData extends StatefulWidget {
  final String shopName;
  final String shopNameMm;
  final String orderDate;
  final String deliveryDate;
  final String address;
  final String phone;
  final String shopSyskey;
  final String mcdCheck;
  final String userType;
  List stockList = [];
  final String ownerName;
  List returnList = [];
  String back;
  List orderDeleted = [];
  List returnDeleted = [];
  String rtn;
  String isSaleOrderLessRouteShop;
  OrderDetailData(
      {Key key,
      @required this.shopName,
      @required this.shopNameMm,
      @required this.address,
      @required this.phone,
      this.orderDate,
      @required this.deliveryDate,
      this.shopSyskey,
      this.mcdCheck,
      this.userType,
      this.stockList,
      this.ownerName,
      this.returnList,
      this.back,
      @required this.orderDeleted,
      @required this.returnDeleted,
      @required this.isSaleOrderLessRouteShop,
      this.rtn})
      : super(key: key);
  @override
  _OrderDetailDataState createState() => _OrderDetailDataState();
}

List itemm = [];
List returnItem = [];
List discountCheckList = discountStockListDate + discountStockList;

class _OrderDetailDataState extends State<OrderDetailData>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  ShopsbyUser helperShopsbyUser = ShopsbyUser();
  List<ShopByUserNote> noteListShopByUserNote;
  ReturnDatabase returnDatabase = ReturnDatabase();
  // List orderPrice = [];
  // List returnPrice = [];
  int totalCount = 0;
  List totalItem = [];
  int totalCountR = 0;
  List totalItemR = [];
  int subTotal = 0;
  double stockLength = 0;
  double returnStockLength = 0;
  TextEditingController returnPriceCtrl = TextEditingController();
  double returnPrice = 0.0;
  bool multiDisCalculate = false;

  var dropDownList = List.generate(100, (index) => index + 1);

  TabController tabController;

  List orderProducts = [];
  List returnProducts = [];
  List orderStockData = [];

  double percent = 1.0;

  final _controller = ScrollController();
  var discountPercent = 0.0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    getStatus();

    discountDataList = [];
  }

  

  String merchandizingStatus;
  String orderdetailStatus;
  String invoiceStatus;

  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';

  List orderList = [];
  List returnList = [];

  List stockImage = [];
  String storeID = "";

  Future<void> getStatus() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var getSysKey =
        helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));

    storeID = preferences.getString("shopCode");

    getSysKey.then((val) {
      getStoreSts(preferences.getString("spsyskey"), val[0]["shopsyskey"])
          .then((value) {
        if (value == "success") {
          setState(() {
            merchandizingStatus = merchandizingSts;
            orderdetailStatus = orderdetailSts;
            invoiceStatus = invoiceSts;
            getData(val);
          });
        }else {
          setState(() {
            loading = false;
            merchandizingStatus = "";
            orderdetailStatus = "";
            invoiceStatus = "";
          });
        }
      });
    });
  }

  Future<void> getData(val) async {
    // orderPrice = [];
    // returnPrice = [];

    if (discountPercentList.toString() != "null") {
      percent = 1 -
          (double.parse(discountPercentList["DisTypePercent"].toString()) /
              100);
      // discountPercent = int.parse(discountPercentList["DisTypePercent"].toString().substring(0, discountPercentList["DisTypePercent"].toString().lastIndexOf(".")));
      discountPercent = double.parse(
          double.parse(discountPercentList["DisTypePercent"].toString())
              .toStringAsFixed(3));
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    stockImage = json.decode(preferences.getString("StockImageList"));

    if (widget.stockList == null || widget.returnList == null) {
      widget.stockList = [];
      widget.returnList = [];
    }

    if (widget.rtn == "FromReturn") {
      Timer(
        Duration(milliseconds: 500),
        () => _controller.jumpTo(_controller.position.maxScrollExtent),
      );
    }

    if (widget.back == "WithBackButton") {
      orderProducts = json.decode(preferences.getString("OriginalStockList"));
      returnProducts = json.decode(preferences.getString("ReturnStockList"));
      setState(() {
        loading = false;
      });
    } else if (widget.back == "FromButton") {
      orderProducts = widget.stockList;
      returnProducts = widget.returnList;
      setState(() {
        loading = false;
      });
    } else {
      if (widget.isSaleOrderLessRouteShop.toString() == "true") {
        if (getrecommendedlist == null) {
          getReturnProduct(val[0]["shopsyskey"]).then((getreturnValue) {
            setState(() {
              loading = false;
            });
          });
        } else {
        

        orderProducts.add({
          "brandOwnerName": getrecommendedlist["brandOwnerName"],
          "brandOwnerSyskey": getrecommendedlist["brandOwnerSyskey"],
          "visible": true,
          "stockData": recommendedOrderList
        });

        returnProducts.add({
          "brandOwnerName": getrecommendedlist["brandOwnerName"],
          "brandOwnerSyskey": getrecommendedlist["brandOwnerSyskey"],
          "visible": true,
          "stockData": recommendedReturnList
        });

        for(var i = 0; i < orderProducts.length; i++) {
          for(var a = 0; a < orderProducts[i]["stockData"].length; a++) {
            if(discountCheckList.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0) {
              var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
              getSysKey.then((val) {
                var param;
                if(discountStockListDate.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString() && element["createddate"] == orderProducts[i]["stockData"][a]["appliedDate"].toString()).toList().length != 0) {
                  param = jsonEncode(
                    {
                      "itemSyskey": "${orderProducts[i]["stockData"][a]["stockSyskey"]}",
                      "itemDesc": "${orderProducts[i]["stockData"][a]["stockName"]}",
                      "itemAmount": orderProducts[i]["stockData"][a]["normalPrice"].toInt(),
                      "itemTotalAmount": orderProducts[i]["stockData"][a]["totalAmount"].toInt(),
                      "itemQty": orderProducts[i]["stockData"][a]["qty"].toInt(),
                      "shopSyskey": "${val[0]["shopsyskey"]}",
                      "date": "${discountStockListDate.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                    }
                  );
                } else {
                  datetime();
                  param = jsonEncode(
                    {
                      "itemSyskey": "${orderProducts[i]["stockData"][a]["stockSyskey"]}",
                      "itemDesc": "${orderProducts[i]["stockData"][a]["stockName"]}",
                      "itemAmount": orderProducts[i]["stockData"][a]["normalPrice"].toInt(),
                      "itemTotalAmount": orderProducts[i]["stockData"][a]["totalAmount"].toInt(),
                      "itemQty": orderProducts[i]["stockData"][a]["qty"].toInt(),
                      "shopSyskey": "${val[0]["shopsyskey"]}",
                      "date": "$date"
                    }
                  );
                }
                
                print("33333333");
                getVolDisCalculation(param, orderProducts[i]["stockData"], context, false).then((getVolDisCalculationValue) {
                  if(getVolDisCalculationValue == "success") {
                    setState(() {
                    print("11111111111");
                    
                    if(newStockList.length != 0) {
                      orderProducts[i]["stockData"] = newStockList;
                    }
                    if(discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList().length.toString() != "0") {
                      if(discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0.0") {
                        var discountpercent = discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"];
                        orderProducts[i]["stockData"][a]["totalAmount"] = (orderProducts[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100)) * orderProducts[i]["stockData"][a]["qty"];
                        orderProducts[i]["stockData"][a]["price"] = orderProducts[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100);
                        orderProducts[i]["stockData"][a]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];
 
                        for (var b = 0; b < stockByBrandDel.length; b++) {
                          if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                            for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                              if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]) {
                                stockByBrandDel[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a]["totalAmount"];
                                stockByBrandDel[b]["stockData"][c]["price"] = orderProducts[i]["stockData"][a]["price"];
                                stockByBrandDel[b]["stockData"][c]["promoDetailSyskey"] = orderProducts[i]["stockData"][a]["promoDetailSyskey"];
                              }
                            }
                          }
                        }                                                            
                      }
                    }
                    });
                  }
                  if(a == orderProducts[i]["stockData"].length-1) {
                    if(i == orderProducts.length -1) {
                      getReturnProduct(val[0]["shopsyskey"]).then((getreturnValue) {
                      setState(() {
                        print("2222222222");
                        loading = false;
                      });
                      });
                    }
                 }
                });
              });
            }
            else{
                if(a == orderProducts[i]["stockData"].length-1) {
                  if(i == orderProducts.length -1) {
                    getReturnProduct(val[0]["shopsyskey"]).then((getreturnValue) {
                    setState(() {
                      print("2222222222");
                      loading = false;
                    });
                    });
                  }
                }
            }
          }
        }


        }

        

      } else {
        if (getdeliverylist == [] || getdeliverylist.length == 0) {
          if (brandOwnerName.length == 0 && getdeliverylist.length == 0) {
            getReturnProduct(val[0]["shopsyskey"]).then((getreturnValue) {
            setState(() {
              loading = false;
            });
            });
          } else {
            for (var b = 0; b < brandOwnerName.length; b++) {
              for (var c = 0; c < brandOwnerName[b].length; c++) {
                orderProducts.add({
                  "brandOwnerName": brandOwnerName[b][c]["brandOwnerName"],
                  "brandOwnerSyskey": brandOwnerName[b][c]["brandOwnerSyskey"],
                  "visible": true,
                  "stockData": brandOwnerName[b][c]["stockData"]
                      .where((val) =>
                          val["brandOwnerSyskey"] ==
                          brandOwnerName[b][c]["brandOwnerSyskey"])
                      .toList()
                });

                returnProducts.add({
                  "brandOwnerName": brandOwnerName[b][c]["brandOwnerName"],
                  "brandOwnerSyskey": brandOwnerName[b][c]["brandOwnerSyskey"],
                  "visible": true,
                  "stockData": brandOwnerName[b][c]["stockReturnData"]
                      .where((val) =>
                          val["brandOwnerSyskey"] ==
                          brandOwnerName[b][c]["brandOwnerSyskey"])
                      .toList()
                });

                if (c == brandOwnerName[b].length - 1) {
                  if (b == brandOwnerName.length - 1) {
                    for (var v = 0; v < orderProducts.length; v++) {
                      for (var n = 0;
                          n < orderProducts[v]["stockData"].length;
                          n++) {
                        for (var m = 0; m < stockImage.length; m++) {
                          if (orderProducts[v]["stockData"][n]["stockCode"]
                                  .toString() ==
                              stockImage[m]["stockCode"].toString()) {
                            orderProducts[v]["stockData"][n]["price"] =
                                stockImage[m]["stockPrice"];
                          }

                          if (m == stockImage.length - 1) {
                            if (n == orderProducts[v]["stockData"].length - 1) {
                              if (v == orderProducts.length - 1) {
                                getReturnProduct(val[0]["shopsyskey"]).then((getreturnValue) {
                                setState(() {
                                  loading = false;
                                });
                                });
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        } else {
          for (var b = 0; b < getdeliverylist.length; b++) {
            orderProducts.add({
              "brandOwnerName": getdeliverylist[b]["brandOwnerName"],
              "brandOwnerSyskey": getdeliverylist[b]["brandOwnerSyskey"],
              "visible": true,
              "stockData": getdeliverylist[b]["stockData"]
            });

            returnProducts.add({
              "brandOwnerName": getdeliverylist[b]["brandOwnerName"],
              "brandOwnerSyskey": getdeliverylist[b]["brandOwnerSyskey"],
              "visible": true,
              "stockData": getdeliverylist[b]["stockReturnData"]
            });

            if (b == getdeliverylist.length - 1) {
              getReturnProduct(val[0]["shopsyskey"]).then((getreturnValue) {
                setState(() {
                  loading = false;
                });
              });
            }
          }
        }
      }
    }
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

  NumberPicker integerNumberPicker;

  Future _showIntDialog(var currentPrice) async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 1,
          maxValue: 99999,
          step: 1,
          initialIntegerValue: currentPrice,
        );
      },
    ).then((num value) {
      if (value != null) {
        setState(() {
          currentPrice = value;
        });
      }
    });
    return currentPrice;
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body =
        (orderProducts == [] || orderProducts.length == 0) &&
                widget.isSaleOrderLessRouteShop == "false"
            ? Container(
                height: MediaQuery.of(context).size.height - 350,
                child: Center(
                  child: Text(
                    "No Data",
                    style: TextStyle(fontSize: 25, color: Colors.grey[400]),
                  ),
                ),
              )
            : 
            Container(
                height: MediaQuery.of(context).size.height - 350,
                child: ListView(
                  controller: _controller,
                  children: <Widget>[
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                          color: Colors.red[100],
                          child: Center(
                              child: Text(
                            "Order Products",
                            style: TextStyle(color: Colors.black, fontSize: 17),
                          ))),
                    ),
                    if(multiDisCalculate == false)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        height: 50,
                        child: GestureDetector(
                          onTap: () async {
                            final SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            preferences.setString("OriginalStockList",
                                json.encode(orderProducts));
                            preferences.setString(
                                "ReturnStockList", json.encode(returnProducts));

                            if (widget.orderDeleted.toString() == "[]") {
                              setState(() {
                                orderList = orderList;
                              });
                            } else {
                              setState(() {
                                orderList = widget.orderDeleted;
                              });
                            }

                            if (widget.returnDeleted.toString() == "[]") {
                              setState(() {
                                returnList = returnList;
                              });
                            } else {
                              setState(() {
                                returnList = widget.returnDeleted;
                              });
                            }
                            newList = [];
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddOrderStock(
                                          shopName: widget.shopName,
                                          shopNameMm: widget.shopNameMm,
                                          address: widget.address,
                                          shopSyskey: widget.shopSyskey,
                                          date: widget.orderDate,
                                          mcdCheck: widget.mcdCheck,
                                          userType: widget.userType,
                                          title: "Order Stocks",
                                          phone: widget.phone,
                                          stockList1: orderProducts,
                                          returnList: returnProducts,
                                          orderDeleted: orderList,
                                          returnDeleted: returnList,
                                          isSaleOrderLessRouteShop:
                                              widget.isSaleOrderLessRouteShop,
                                        )));
                          },
                          child: Card(
                            color: Colors.red[100],
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Add Order Products",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        child: Column(children: <Widget>[
                          for (var i = 0; i < orderProducts.length; i++)
                            Visibility(
                              visible: orderProducts[i]["stockData"].length == 0
                                  ? false
                                  : true,
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      if (orderProducts[i]["visible"] ==
                                          false) {
                                        setState(() {
                                          orderProducts[i]["visible"] = true;
                                        });
                                      } else if (orderProducts[i]["visible"] ==
                                          true) {
                                        setState(() {
                                          orderProducts[i]["visible"] = false;
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: 50,
                                      child: Card(
                                          color: Color(0xffe53935),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  orderProducts[i][
                                                              "brandOwnerName"] ==
                                                          null
                                                      ? ""
                                                      : "${orderProducts[i]["brandOwnerName"]}",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white),
                                                ),
                                                Icon(
                                                  orderProducts[i]["visible"]
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
                                    visible: orderProducts[i]["visible"],
                                    child: Column(
                                          children: <Widget>[
                                            for(var a = 0; a < orderProducts[i]["stockData"].length; a++)
                                          Visibility(
                                            // visible: (a != 0 && orderProducts[i]["stockData"][a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().toString() == orderProducts[i]["stockData"][a-1]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().toString() && orderProducts[i]["stockData"][a]["promotionStockList"].length != 0) ? false : true,
                                            visible: true,
                                            child: Stack(
                                              children: <Widget>[
                                                Column(
                                                  children: <Widget>[
                                                    Card(
                                                      elevation: 3,
                                                      child: Column(
                                                        children: <Widget>[
                                                          Stack(
                                                            children: <Widget>[
                                                              
                                                              Row(
                                                                children: <Widget>[
                                                                  ConstrainedBox(
                                                                    constraints:
                                                                        BoxConstraints(
                                                                      maxWidth: 64,
                                                                      maxHeight: 80,
                                                                    ),
                                                                    child: stockImage == [] ||
                                                                            stockImage
                                                                                    .length ==
                                                                                0
                                                                        ? GestureDetector(
                                                                            onTap: () {
                                                                              Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                      builder:
                                                                                          (context) =>
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
                                                                              ),
                                                                              stockImage
                                                                                          .where((element) =>
                                                                                              element["stockCode"] ==
                                                                                              orderProducts[i]["stockData"][a]["stockCode"])
                                                                                          .toList()
                                                                                          .toString() ==
                                                                                      "[]"
                                                                                  ? GestureDetector(
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
                                                                                    )
                                                                                  : GestureDetector(
                                                                                      onTap:
                                                                                          () {
                                                                                        print("${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}");
                                                                                        Navigator.push(
                                                                                            context,
                                                                                            MaterialPageRoute(builder: (context) => ShowImage(image: CachedNetworkImage(imageUrl: "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}"))));
                                                                                      },
                                                                                      child:
                                                                                          CachedNetworkImage(
                                                                                        imageUrl:
                                                                                            "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
                                                                                      ),
                                                                                    )
                                                                            ],
                                                                          ),
                                                                  ),
                                                                  Container(
                                                                    width:
                                                                        MediaQuery.of(context)
                                                                                .size
                                                                                .width -
                                                                            82,
                                                                    child: Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                                  .only(
                                                                              right: 3,
                                                                              left: 10),
                                                                      child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .start,
                                                                        children: <Widget>[
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment
                                                                                    .spaceBetween,
                                                                            children: <
                                                                                Widget>[
                                                                              Container(
                                                                                width: MediaQuery.of(
                                                                                            context)
                                                                                        .size
                                                                                        .width -
                                                                                    170,
                                                                                margin: EdgeInsets
                                                                                    .only(
                                                                                        top:
                                                                                            5),
                                                                                child: Text(
                                                                                  "${orderProducts[i]["stockData"][a]["stockName"]}",
                                                                                ),
                                                                              ),
                                                                              IconButton(
                                                                                  icon: Icon(
                                                                                    Icons
                                                                                        .delete_outline,
                                                                                    color: multiDisCalculate == true ? Colors.white : Color(
                                                                                        0xffe53935),
                                                                                  ),
                                                                                  onPressed: multiDisCalculate == true ? null :
                                                                                      () {
                                                                                    setState(
                                                                                        () {
                                                                                      if (widget.orderDeleted.toString() ==
                                                                                          "[]") {
                                                                                        setState(
                                                                                            () {
                                                                                          orderList =
                                                                                              orderList;
                                                                                        });
                                                                                      } else {
                                                                                        setState(
                                                                                            () {
                                                                                          orderList =
                                                                                              widget.orderDeleted;
                                                                                        });
                                                                                      }

                                                                                      if (widget.returnDeleted.toString() ==
                                                                                          "[]") {
                                                                                        setState(
                                                                                            () {
                                                                                          returnList =
                                                                                              returnList;
                                                                                        });
                                                                                      } else {
                                                                                        setState(
                                                                                            () {
                                                                                          returnList =
                                                                                              widget.returnDeleted;
                                                                                        });
                                                                                      }
                                                                                      String orderDeleteSyskey = orderProducts[i]["stockData"][a]["stockSyskey"];
                                                                                      if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                        for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                          if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                            stockByBrandDel[b]["stockData"].removeWhere((element) => element["stockSyskey"] == orderDeleteSyskey);
                                                                                            orderProducts[i]["stockData"].removeWhere((element) => element["stockSyskey"] == orderDeleteSyskey);
                                                                                            if(discountDataList.length != 0) {
                                                                                              discountDataList.removeWhere((element) => element["itemSyskey"].toString() == orderDeleteSyskey);
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                        if (orderProducts[i]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                          if(discountDataList.length != 0) {
                                                                                            discountDataList.removeWhere((element) => element["itemSyskey"].toString() == orderDeleteSyskey);
                                                                                          }
                                                                                        }
                                                                                      } else {
                                                                                        
                                                                                        if (orderProducts[i]["stockData"][a]["syskey"] == "0") {
                                                                                          for (var v = 0;
                                                                                              v < getdeliverylist.length;
                                                                                              v++) {
                                                                                            if (getdeliverylist[v]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                              for(var w = 0; w < getdeliverylist[v]["stockData"].length; w++) {
                                                                                                getdeliverylist[v]["stockData"].removeWhere((element) => element["stockSyskey"] == orderDeleteSyskey);
                                                                                                orderProducts[i]["stockData"].removeWhere((element) => element["stockSyskey"] == orderDeleteSyskey);
                                                                                              }
                                                                                              if(discountDataList.length != 0) {
                                                                                                discountDataList.removeWhere((element) => element["itemSyskey"].toString() == orderDeleteSyskey);
                                                                                              }
                                                                                            }
                                                                                            print("UI List == > ${orderProducts[i]["stockData"].length}");
                                                                                            print("Background List == > ${getdeliverylist[v]["stockData"]}");
                                                                                          }
                                                                                        } else {
                                                                                          for (var v = 0;
                                                                                              v < getdeliverylist.length;
                                                                                              v++) {
                                                                                            if (getdeliverylist[v]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                              orderList.add({
                                                                                                "syskey": "${orderProducts[i]["stockData"][a]["syskey"]}",
                                                                                                "recordStatus": 4,
                                                                                                "stockCode": "${orderProducts[i]["stockData"][a]["stockCode"]}",
                                                                                                "stockName": "${orderProducts[i]["stockData"][a]["stockName"]}",
                                                                                                "saleCurrCode": "MMK",
                                                                                                "stockSyskey" : "${orderProducts[i]["stockData"][a]["stockSyskey"]}",
                                                                                                "n1": "0",
                                                                                                "wareHouseSyskey": "${orderProducts[i]["stockData"][a]["wareHouseSyskey"]}",
                                                                                                "binSyskey": "0",
                                                                                                "qty": "${orderProducts[i]["stockData"][a]["qty"]}",
                                                                                                "lvlSyskey": "${orderProducts[i]["stockData"][a]["lvlSyskey"]}",
                                                                                                "lvlQty": 1.0,
                                                                                                "n8": 1.0,
                                                                                                "n9": 0.0,
                                                                                                "taxAmount": 0.0,
                                                                                                "totalAmount": "${orderProducts[i]["stockData"][a]["totalAmount"]}",
                                                                                                "price": "${orderProducts[i]["stockData"][a]["price"]}",
                                                                                                "normalPrice": "${orderProducts[i]["stockData"][a]["normalPrice"]}",
                                                                                                "taxCodeSK": "0",
                                                                                                "isTaxInclusice": 0,
                                                                                                "taxPercent": 0.0,
                                                                                                "brandOwnerSyskey": "${orderProducts[i]["stockData"][a]["brandOwnerSyskey"]}",
                                                                                                "stockType": "NORMAL"
                                                                                              });

                                                                                              orderProducts[i]["stockData"].removeWhere((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"]);

                                                                                              if(discountDataList.length != 0) {
                                                                                                discountDataList.removeWhere((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"]);
                                                                                              }

                                                                                              print(orderProducts[i]["stockData"]);

                                                                                              print(orderList);
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    });
                                                                                  })
                                                                            ],
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets
                                                                                .only(top: 1),
                                                                            child: Row(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment
                                                                                      .spaceBetween,
                                                                              children: <
                                                                                  Widget>[
                                                                                multiDisCalculate == true ?
                                                                                Row(
                                                                                  children: <Widget>[
                                                                                    Text("Qty : "),
                                                                                    Text("${orderProducts[i]["stockData"][a]["qty"].toInt()}"),
                                                                                  ],
                                                                                ) :
                                                                                Row(
                                                                                  crossAxisAlignment:
                                                                                      CrossAxisAlignment
                                                                                          .center,
                                                                                  children: <
                                                                                      Widget>[
                                                                                    Container(
                                                                                      child:
                                                                                          GestureDetector(
                                                                                        onTap:
                                                                                            () async {
                                                                                          final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                          if (orderProducts[i]["stockData"][a]["qty"] == 1 ||
                                                                                              orderProducts[i]["stockData"][a]["qty"] < 1) {
                                                                                          } else {
                                                                                            setState(() {
                                                                                              orderProducts[i]["stockData"][a]["qty"]--;

                                                                                              orderProducts[i]["stockData"][a]["totalAmount"] = orderProducts[i]["stockData"][a]["normalPrice"] * orderProducts[i]["stockData"][a]["qty"];

                                                                                              if(discountCheckList.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0) {
                                                                                                _handleSubmit(context);
                                                                                                var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                                getSysKey.then((val) {
                                                                                                  var param;
                                                                                                  if(discountStockListDate.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString() && element["createddate"] == orderProducts[i]["stockData"][a]["appliedDate"].toString()).toList().length != 0) {
                                                                                                    param = jsonEncode(
                                                                                                      {
                                                                                                        "itemSyskey": "${orderProducts[i]["stockData"][a]["stockSyskey"]}",
                                                                                                        "itemDesc": "${orderProducts[i]["stockData"][a]["stockName"]}",
                                                                                                        "itemAmount": orderProducts[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                        "itemTotalAmount": orderProducts[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                        "itemQty": orderProducts[i]["stockData"][a]["qty"].toInt(),
                                                                                                        "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                        "date": "${discountStockListDate.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                                                                                                      }
                                                                                                    );
                                                                                                  } else {
                                                                                                    datetime();
                                                                                                    param = jsonEncode(
                                                                                                      {
                                                                                                        "itemSyskey": "${orderProducts[i]["stockData"][a]["stockSyskey"]}",
                                                                                                        "itemDesc": "${orderProducts[i]["stockData"][a]["stockName"]}",
                                                                                                        "itemAmount": orderProducts[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                        "itemTotalAmount": orderProducts[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                        "itemQty": orderProducts[i]["stockData"][a]["qty"].toInt(),
                                                                                                        "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                        "date": "$date"
                                                                                                      }
                                                                                                    );
                                                                                                  }

                                                                                                  getVolDisCalculation(param, orderProducts[i]["stockData"], context, false).then((getVolDisCalculationValue) {
                                                                                                    if(getVolDisCalculationValue == "success") {
                                                                                                      print("111111111111111111>>>>>>");
                                                                                                      setState(() {
                                                                                                        if(newStockList.length != 0) {
                                                                                                          orderProducts[i]["stockData"] = newStockList;
                                                                                                        }
                                                                                                        
                                                                                                        if(discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0.0") {
                                                                                                          var discountpercent = discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"];
                                                                                                          orderProducts[i]["stockData"][a]["totalAmount"] = (orderProducts[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100)) * orderProducts[i]["stockData"][a]["qty"];
                                                                                                          orderProducts[i]["stockData"][a]["price"] = orderProducts[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100);
                                                                                                          orderProducts[i]["stockData"][a]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];
                                                                                                          
                                                                                                          if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                            for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                              if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                                for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                                  if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]) {
                                                                                                                    stockByBrandDel[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a]["totalAmount"];
                                                                                                                    stockByBrandDel[b]["stockData"][c]["price"] = orderProducts[i]["stockData"][a]["price"];
                                                                                                                    stockByBrandDel[b]["stockData"][c]["promoDetailSyskey"] = orderProducts[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          } else {
                                                                                                            for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                              if (getdeliverylist[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                                for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                                  if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]) {
                                                                                                                    getdeliverylist[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a]["totalAmount"];
                                                                                                                    getdeliverylist[b]["stockData"][c]["price"] = orderProducts[i]["stockData"][a]["price"];
                                                                                                                    getdeliverylist[b]["stockData"][c]["promoDetailSyskey"] = orderProducts[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                        Navigator.pop(context);
                                                                                                      });
                                                                                                    }else if(getVolDisCalculationValue == "fail") {
                                                                                                      Navigator.pop(context);
                                                                                                      snackbarmethod("FAIL!");
                                                                                                    }else {
                                                                                                      Navigator.pop(context);
                                                                                                      // getVolDisCalculationDialog(param, getVolDisCalculationValue.toString(), orderProducts[i]["stockData"][a]);
                                                                                                    }
                                                                                                  });
                                                                                                });
                                                                                                
                                                                                              }

                                                                                              if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                  if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                    for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                      if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]) {
                                                                                                        stockByBrandDel[b]["stockData"][c]["qty"] = orderProducts[i]["stockData"][a]["qty"];
                                                                                                        stockByBrandDel[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a]["totalAmount"];
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                              } else {
                                                                                                for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                  if (getdeliverylist[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                    for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                      if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]) {
                                                                                                        getdeliverylist[b]["stockData"][c]["qty"] = orderProducts[i]["stockData"][a]["qty"];
                                                                                                        getdeliverylist[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a]["totalAmount"];
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            });
                                                                                          }
                                                                                        },
                                                                                        child:
                                                                                            Center(
                                                                                          child:
                                                                                              Icon(
                                                                                            const IconData(0xe15b, fontFamily: 'MaterialIcons'),
                                                                                            color: Colors.white,
                                                                                            size: 19,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      decoration:
                                                                                          BoxDecoration(
                                                                                        color:
                                                                                            Color(0xffe53935),
                                                                                        borderRadius:
                                                                                            BorderRadius.circular(3),
                                                                                        border:
                                                                                            Border(
                                                                                          top:
                                                                                              BorderSide(width: 0.5, color: Colors.white),
                                                                                          bottom:
                                                                                              BorderSide(width: 0.5, color: Colors.white),
                                                                                          left:
                                                                                              BorderSide(width: 0.5, color: Colors.white),
                                                                                          right:
                                                                                              BorderSide(width: 0.5, color: Colors.white),
                                                                                        ),
                                                                                      ),
                                                                                      height:
                                                                                          27,
                                                                                      width:
                                                                                          27,
                                                                                    ),
                                                                                    GestureDetector(
                                                                                      onTap:
                                                                                          () async {
                                                                                        final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                        _showIntDialog(int.parse("${orderProducts[i]["stockData"][a]["qty"]}".substring(0, orderProducts[i]["stockData"][a]["qty"].toString().lastIndexOf("."))))
                                                                                            .then((value) {
                                                                                          setState(() {
                                                                                            orderProducts[i]["stockData"][a]["qty"] = value.toDouble();

                                                                                            orderProducts[i]["stockData"][a]["totalAmount"] = orderProducts[i]["stockData"][a]["normalPrice"] * orderProducts[i]["stockData"][a]["qty"];
                                                                                          });

                                                                                          if(discountCheckList.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0) {
                                                                                                _handleSubmit(context);
                                                                                                var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                                getSysKey.then((val) {
                                                                                                  var param;
                                                                                                  if(discountStockListDate.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString() && element["createddate"] == orderProducts[i]["stockData"][a]["appliedDate"].toString()).toList().length != 0) {
                                                                                                    param = jsonEncode(
                                                                                                      {
                                                                                                        "itemSyskey": "${orderProducts[i]["stockData"][a]["stockSyskey"]}",
                                                                                                        "itemDesc": "${orderProducts[i]["stockData"][a]["stockName"]}",
                                                                                                        "itemAmount": orderProducts[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                        "itemTotalAmount": orderProducts[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                        "itemQty": orderProducts[i]["stockData"][a]["qty"].toInt(),
                                                                                                        "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                        "date": "${discountStockListDate.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                                                                                                      }
                                                                                                    );
                                                                                                  } else {
                                                                                                    datetime();
                                                                                                    param = jsonEncode(
                                                                                                      {
                                                                                                        "itemSyskey": "${orderProducts[i]["stockData"][a]["stockSyskey"]}",
                                                                                                        "itemDesc": "${orderProducts[i]["stockData"][a]["stockName"]}",
                                                                                                        "itemAmount": orderProducts[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                        "itemTotalAmount": orderProducts[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                        "itemQty": orderProducts[i]["stockData"][a]["qty"].toInt(),
                                                                                                        "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                        "date": "$date"
                                                                                                      }
                                                                                                    );
                                                                                                  }

                                                                                                  // setState(() {
                                                                                                  getVolDisCalculation(param, orderProducts[i]["stockData"], context, false).then((getVolDisCalculationValue) {
                                                                                                    if(getVolDisCalculationValue == "success") {
                                                                                                      setState(() {
                                                                                                        if(newStockList.length != 0) {
                                                                                                          orderProducts[i]["stockData"] = newStockList;
                                                                                                        }
                                                                                                        if(discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0.0") {
                                                                                                          var discountpercent = discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"];
                                                                                                          orderProducts[i]["stockData"][a]["totalAmount"] = (orderProducts[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100)) * orderProducts[i]["stockData"][a]["qty"];
                                                                                                          orderProducts[i]["stockData"][a]["price"] = orderProducts[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100);
                                                                                                          orderProducts[i]["stockData"][a]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];

                                                                                                          if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                            for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                              if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                                for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                                  if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]) {
                                                                                                                    stockByBrandDel[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a]["totalAmount"];
                                                                                                                    stockByBrandDel[b]["stockData"][c]["price"] = orderProducts[i]["stockData"][a]["price"];
                                                                                                                    stockByBrandDel[b]["stockData"][c]["promoDetailSyskey"] = orderProducts[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          } else {
                                                                                                            for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                              if (getdeliverylist[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                                for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                                  if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]) {
                                                                                                                    getdeliverylist[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a]["totalAmount"];
                                                                                                                    getdeliverylist[b]["stockData"][c]["price"] = orderProducts[i]["stockData"][a]["price"];
                                                                                                                    getdeliverylist[b]["stockData"][c]["promoDetailSyskey"] = orderProducts[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                        Navigator.pop(context);
                                                                                                      });
                                                                                                    }else if(getVolDisCalculationValue == "fail") {
                                                                                                      Navigator.pop(context);
                                                                                                      snackbarmethod("FAIL!");
                                                                                                    }else {
                                                                                                      Navigator.pop(context);
                                                                                                      // getVolDisCalculationDialog(param, getVolDisCalculationValue.toString(), orderProducts[i]["stockData"][a]);
                                                                                                    }
                                                                                                  });
                                                                                                  // });
                                                                                                  
                                                                                                });
                                                                                                
                                                                                              }

                                                                                          if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                            for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                              if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                  if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]) {
                                                                                                    stockByBrandDel[b]["stockData"][c]["qty"] = orderProducts[i]["stockData"][a]["qty"];
                                                                                                    stockByBrandDel[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a]["totalAmount"];
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          } else {
                                                                                            for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                              if (getdeliverylist[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                  if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]) {
                                                                                                    getdeliverylist[b]["stockData"][c]["qty"] = orderProducts[i]["stockData"][a]["qty"];
                                                                                                    getdeliverylist[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a]["totalAmount"];
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        });

                                                                                        
                                                                                      },
                                                                                      child:
                                                                                          Container(
                                                                                        child:
                                                                                            Center(child: Text("${orderProducts[i]["stockData"][a]["qty"]}".substring(0, orderProducts[i]["stockData"][a]["qty"].toString().lastIndexOf(".")))),
                                                                                        decoration:
                                                                                            BoxDecoration(
                                                                                          border:
                                                                                              Border(
                                                                                            top: BorderSide(width: 0.5, color: Colors.grey),
                                                                                            bottom: BorderSide(width: 0.5, color: Colors.grey),
                                                                                            left: BorderSide(width: 0.5, color: Colors.white),
                                                                                            right: BorderSide(width: 0.5, color: Colors.white),
                                                                                          ),
                                                                                        ),
                                                                                        height:
                                                                                            27,
                                                                                        width:
                                                                                            45,
                                                                                      ),
                                                                                    ),
                                                                                    Container(
                                                                                      child:
                                                                                          GestureDetector(
                                                                                        onTap:
                                                                                            () async {
                                                                                          final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                          if (orderProducts[i]["stockData"][a]["qty"] == 99999 ||
                                                                                              orderProducts[i]["stockData"][a]["qty"] > 99999) {
                                                                                          } else {
                                                                                            setState(() {
                                                                                              orderProducts[i]["stockData"][a]["qty"]++;

                                                                                              orderProducts[i]["stockData"][a]["totalAmount"] = orderProducts[i]["stockData"][a]["normalPrice"] * orderProducts[i]["stockData"][a]["qty"];

                                                                                              var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                              print(orderProducts[i]["stockData"][a]["stockSyskey"]);

                                                                                                  if(discountCheckList.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0) {
                                                                                                _handleSubmit(context);
                                                                                                
                                                                                                getSysKey.then((val) {
                                                                                                  var param;
                                                                                                  if(discountStockListDate.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString() && element["createddate"] == orderProducts[i]["stockData"][a]["appliedDate"].toString()).toList().length != 0) {
                                                                                                    param = jsonEncode(
                                                                                                      {
                                                                                                        "itemSyskey": "${orderProducts[i]["stockData"][a]["stockSyskey"]}",
                                                                                                        "itemDesc": "${orderProducts[i]["stockData"][a]["stockName"]}",
                                                                                                        "itemAmount": orderProducts[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                        "itemTotalAmount": orderProducts[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                        "itemQty": orderProducts[i]["stockData"][a]["qty"].toInt(),
                                                                                                        "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                        "date": "${discountStockListDate.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                                                                                                      }
                                                                                                    );
                                                                                                  } else {
                                                                                                    datetime();
                                                                                                    param = jsonEncode(
                                                                                                      {
                                                                                                        "itemSyskey": "${orderProducts[i]["stockData"][a]["stockSyskey"]}",
                                                                                                        "itemDesc": "${orderProducts[i]["stockData"][a]["stockName"]}",
                                                                                                        "itemAmount": orderProducts[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                        "itemTotalAmount": orderProducts[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                        "itemQty": orderProducts[i]["stockData"][a]["qty"].toInt(),
                                                                                                        "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                        "date": "$date"
                                                                                                      }
                                                                                                    );
                                                                                                  }

                                                                                                  getVolDisCalculation(param, orderProducts[i]["stockData"], context, false).then((getVolDisCalculationValue) {
                                                                                                    if(getVolDisCalculationValue == "success") {
                                                                                                      print("33333333333333333333>>>>>>");
                                                                                                      setState(() {
                                                                                                        if(newStockList.length != 0) {
                                                                                                          orderProducts[i]["stockData"] = newStockList;
                                                                                                        }
                                                                                                        if(discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList().length.toString() != "0") {
                                                                                                          if(discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0.0") {
                                                                                                            var discountpercent = discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"];
                                                                                                            orderProducts[i]["stockData"][a]["totalAmount"] = (orderProducts[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100)) * orderProducts[i]["stockData"][a]["qty"];
                                                                                                            orderProducts[i]["stockData"][a]["price"] = orderProducts[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100);
                                                                                                            orderProducts[i]["stockData"][a]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];

                                                                                                            if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                            for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                              if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                                for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                                  if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]) {
                                                                                                                    stockByBrandDel[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a]["totalAmount"];
                                                                                                                    stockByBrandDel[b]["stockData"][c]["price"] = orderProducts[i]["stockData"][a]["price"];
                                                                                                                    stockByBrandDel[b]["stockData"][c]["promoDetailSyskey"] = orderProducts[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          } else {
                                                                                                            for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                              if (getdeliverylist[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                                for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                                  if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]) {
                                                                                                                    getdeliverylist[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a]["totalAmount"];
                                                                                                                    getdeliverylist[b]["stockData"][c]["price"] = orderProducts[i]["stockData"][a]["price"];
                                                                                                                    getdeliverylist[b]["stockData"][c]["promoDetailSyskey"] = orderProducts[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                          }
                                                                                                        }
                                                                                                        Navigator.pop(context);
                                                                                                      });
                                                                                                    }else if(getVolDisCalculationValue == "fail") {
                                                                                                      Navigator.pop(context);
                                                                                                      snackbarmethod("FAIL!");
                                                                                                    }else {
                                                                                                      Navigator.pop(context);
                                                                                                      // getVolDisCalculationDialog(param, getVolDisCalculationValue.toString(), orderProducts[i]["stockData"][a]);
                                                                                                    }
                                                                                                  });
                                                                                                  
                                                                                                });
                                                                                                
                                                                                              }
                                                                                              
                                                                                              if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                  if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                    for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                      if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]) {
                                                                                                        stockByBrandDel[b]["stockData"][c]["qty"] = orderProducts[i]["stockData"][a]["qty"];
                                                                                                        stockByBrandDel[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a]["totalAmount"];
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                              } else {
                                                                                                for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                  if (getdeliverylist[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                    for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                      if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a]["stockCode"]) {
                                                                                                        getdeliverylist[b]["stockData"][c]["qty"] = orderProducts[i]["stockData"][a]["qty"];
                                                                                                        getdeliverylist[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a]["totalAmount"];
                                                                                                      }

                                                                                                      print(getdeliverylist[b]["stockData"][c]);
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            });
                                                                                          }
                                                                                        },
                                                                                        child:
                                                                                            Center(child: Icon(Icons.add, size: 19, color: Colors.white)),
                                                                                      ),
                                                                                      decoration:
                                                                                          BoxDecoration(
                                                                                        borderRadius:
                                                                                            BorderRadius.circular(3),
                                                                                        color:
                                                                                            Color(0xffe53935),
                                                                                        border:
                                                                                            Border(
                                                                                          top:
                                                                                              BorderSide(width: 0.5, color: Colors.white),
                                                                                          bottom:
                                                                                              BorderSide(width: 0.5, color: Colors.white),
                                                                                          left:
                                                                                              BorderSide(width: 0.5, color: Colors.white),
                                                                                          right:
                                                                                              BorderSide(width: 0.5, color: Colors.white),
                                                                                        ),
                                                                                      ),
                                                                                      height:
                                                                                          27,
                                                                                      width:
                                                                                          27,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Container(
                                                                                  width: 150,
                                                                                  child: Row(
                                                                                    mainAxisAlignment:
                                                                                        MainAxisAlignment
                                                                                            .spaceBetween,
                                                                                    children: <
                                                                                        Widget>[
                                                                                      
                                                                                      Text("${orderProducts[i]["stockData"][a]["normalPrice"]}".substring(
                                                                                          0,
                                                                                          orderProducts[i]["stockData"][a]["normalPrice"].toString().lastIndexOf("."))),
                                                                                      // Text("0"),
                                                                                      Padding(
                                                                                        padding:
                                                                                            const EdgeInsets.only(right: 15),
                                                                                        child: Text(
                                                                                          orderProducts[i]["stockData"][a]["totalAmount"].toString().substring(orderProducts[i]["stockData"][a]["totalAmount"].toString().lastIndexOf("."), orderProducts[i]["stockData"][a]["totalAmount"].toString().length).length > 3 ?
                                                                                          "${orderProducts[i]["stockData"][a]["totalAmount"].toStringAsFixed(2)}" :
                                                                                          double.parse(orderProducts[i]["stockData"][a]["totalAmount"].toString().substring(orderProducts[i]["stockData"][a]["totalAmount"].toString().lastIndexOf("."), orderProducts[i]["stockData"][a]["totalAmount"].toString().length)) == 0.0 ?
                                                                                            "${orderProducts[i]["stockData"][a]["totalAmount"].toInt()}" :
                                                                                            "${orderProducts[i]["stockData"][a]["totalAmount"]}"
                                                                                            ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          orderProducts[i]["stockData"][a]["discountAmount"] == "" || orderProducts[i]["stockData"][a]["discountPercent"] == "" || orderProducts[i]["stockData"][a]["discountAmount"] == null || orderProducts[i]["stockData"][a]["discountPercent"] == null ?
                                                                          Container() :
                                                                          Visibility(
                                                                            visible: orderProducts[i]["stockData"][a]["discountAmount"] == "" || orderProducts[i]["stockData"][a]["discountPercent"] == "" ? false : true,
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
                                                                                          orderProducts[i]["stockData"][a]["discountAmount"] == "" || orderProducts[i]["stockData"][a]["discountAmount"].toString() == "0.0" || orderProducts[i]["stockData"][a]["discountPercent"] == "" || orderProducts[i]["stockData"][a]["discountPercent"].toString() == "0.0" ?
                                                                                          "" :
                                                                                          orderProducts[i]["stockData"][a]["discountPercent"].toString() == "0.0" &&
                                                                                          orderProducts[i]["stockData"][a]["discountAmount"].toString() == "0.0" ? "" :
                                                                                          "${orderProducts[i]["stockData"][a]["normalPrice"].toInt() * orderProducts[i]["stockData"][a]["qty"].toInt()}", style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12),),
                                                                                        orderProducts[i]["stockData"][a]["discountAmount"] == "" || orderProducts[i]["stockData"][a]["discountAmount"].toString() == "0.0" || orderProducts[i]["stockData"][a]["discountPercent"] == "" || orderProducts[i]["stockData"][a]["discountPercent"].toString() == "0.0" ?
                                                                                        Text("") :
                                                                                        Text(
                                                                                          orderProducts[i]["stockData"][a]["discountPercent"].toString() != "0.0" ?
                                                                                          "  -${orderProducts[i]["stockData"][a]["discountPercent"]}%" :
                                                                                          orderProducts[i]["stockData"][a]["discountAmount"].toString() != "0.0" ?
                                                                                          "  -${orderProducts[i]["stockData"][a]["discountAmount"].toInt()}" : ""
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
                                                              if(discountCheckList.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0 || 
                                                                listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0)
                                                                GestureDetector(
                                                                  onTap: () async {
                                                                    if(listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0) {
                                                                      List detailList = [];
                                                                      List sameDetailList = [];
                                                                      String headerSyskey = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["HeaderSyskey"];
                                                                      String ruleNumber = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["RuleNumber"];
                                                                      String rulePriority = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["RulePriority"];
                                                                      for(var j = 0; j < multiDiscountStockList.length; j++) {
                                                                        if(multiDiscountStockList[j]["HeaderSyskey"] == headerSyskey) {
                                                                          // sameDetailList = multiDiscountStockList[j]["DetailList"].where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a]["stockSyskey"] && element["RuleNumber"] == ruleNumber && element["RulePriority"] == rulePriority).toList();
                                                                          sameDetailList = multiDiscountStockList[j]["DetailList"].where((element) => element["RuleNumber"] == ruleNumber && element["RulePriority"] == rulePriority).toList();
                                                                        }
                                                                      }

                                                                      sameDetailList = multiDiscountStockList[0]["DetailList"];
                                                                      detailList.add({
                                                                        "PromoItemSyskey" : orderProducts[i]["stockData"][a]["stockSyskey"],
                                                                        "PromoItemDesc" : orderProducts[i]["stockData"][a]["stockName"],
                                                                        "HeaderList" : [
                                                                          {
                                                                            "DetailList": sameDetailList,
                                                                            "ToDate" : multiDiscountStockList.where((element) => element["HeaderSyskey"] == headerSyskey).toList()[0]["ToDate"]
                                                                          }
                                                                        ]
                                                                      });
                                                                      print(detailList);
                                                                      Navigator.push(context, MaterialPageRoute(builder: (context) => DiscountDetail(detail: detailList, stockDetail: orderProducts[i]["stockData"][a],)));
                                                                    } else {
                                                                      _handleSubmit(context);
                                                                      final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                      var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                      getSysKey.then((val) {
                                                                        getPromoItemDetail("${val[0]["shopsyskey"]}", "", orderProducts[i]["stockData"][a]["stockSyskey"], orderProducts[i]["brandOwnerSyskey"]).then((promoDetailVal) {
                                                                          Navigator.pop(context);
                                                                          if(promoDetailVal == "success") {
                                                                            setState(() {
                                                                              Navigator.push(context, MaterialPageRoute(builder: (context) => DiscountDetail(detail: promoItemDetailList, stockDetail: orderProducts[i]["stockData"][a],)));
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
                                                          if(a != orderProducts[i]["stockData"].length-1)
                                                          if(orderProducts[i]["stockData"][a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().toString() == orderProducts[i]["stockData"][a+1]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().toString() && orderProducts[i]["stockData"][a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().length != 0 && orderProducts[i]["stockData"][a]["promotionStockList"].length != 0)
                                                          Column(
                                                            children: <Widget>[
                                                              Divider(color: Color(0xffe53935)),
                                                              Stack(
                                                                children: <Widget>[
                                                                  Row(
                                                                    children: <Widget>[
                                                                      ConstrainedBox(
                                                                        constraints:
                                                                            BoxConstraints(
                                                                          maxWidth: 64,
                                                                          maxHeight: 80,
                                                                        ),
                                                                        child: stockImage == [] ||
                                                                                stockImage
                                                                                        .length ==
                                                                                    0
                                                                            ? GestureDetector(
                                                                                onTap: () {
                                                                                  Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                          builder:
                                                                                              (context) =>
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
                                                                                  ),
                                                                                  stockImage
                                                                                              .where((element) =>
                                                                                                  element["stockCode"] ==
                                                                                                  orderProducts[i]["stockData"][a+1]["stockCode"])
                                                                                              .toList()
                                                                                              .toString() ==
                                                                                          "[]"
                                                                                      ? GestureDetector(
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
                                                                                        )
                                                                                      : GestureDetector(
                                                                                          onTap:
                                                                                              () {
                                                                                            print("${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]).toList()[0]["image"]}");
                                                                                            Navigator.push(
                                                                                                context,
                                                                                                MaterialPageRoute(builder: (context) => ShowImage(image: CachedNetworkImage(imageUrl: "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]).toList()[0]["image"]}"))));
                                                                                          },
                                                                                          child:
                                                                                              CachedNetworkImage(
                                                                                            imageUrl:
                                                                                                "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]).toList()[0]["image"]}",
                                                                                          ),
                                                                                        )
                                                                                ],
                                                                              ),
                                                                      ),
                                                                      Container(
                                                                        width:
                                                                            MediaQuery.of(context)
                                                                                    .size
                                                                                    .width -
                                                                                82,
                                                                        child: Padding(
                                                                          padding:
                                                                              const EdgeInsets
                                                                                      .only(
                                                                                  right: 3,
                                                                                  left: 10),
                                                                          child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment
                                                                                    .start,
                                                                            children: <Widget>[
                                                                              Row(
                                                                                mainAxisAlignment:
                                                                                    MainAxisAlignment
                                                                                        .spaceBetween,
                                                                                children: <
                                                                                    Widget>[
                                                                                  Container(
                                                                                    width: MediaQuery.of(
                                                                                                context)
                                                                                            .size
                                                                                            .width -
                                                                                        170,
                                                                                    margin: EdgeInsets
                                                                                        .only(
                                                                                            top:
                                                                                                5),
                                                                                    child: Text(
                                                                                      "${orderProducts[i]["stockData"][a+1]["stockName"]}",
                                                                                    ),
                                                                                  ),
                                                                                  IconButton(
                                                                                      icon: Icon(
                                                                                        Icons
                                                                                            .delete_outline,
                                                                                        color: multiDisCalculate == true ? Colors.white : Color(0xffe53935),
                                                                                      ),
                                                                                      onPressed: multiDisCalculate == true ? null :
                                                                                          () {
                                                                                        setState(
                                                                                            () {
                                                                                          if (widget.orderDeleted.toString() ==
                                                                                              "[]") {
                                                                                            setState(
                                                                                                () {
                                                                                              orderList =
                                                                                                  orderList;
                                                                                            });
                                                                                          } else {
                                                                                            setState(
                                                                                                () {
                                                                                              orderList =
                                                                                                  widget.orderDeleted;
                                                                                            });
                                                                                          }

                                                                                          if (widget.returnDeleted.toString() ==
                                                                                              "[]") {
                                                                                            setState(
                                                                                                () {
                                                                                              returnList =
                                                                                                  returnList;
                                                                                            });
                                                                                          } else {
                                                                                            setState(
                                                                                                () {
                                                                                              returnList =
                                                                                                  widget.returnDeleted;
                                                                                            });
                                                                                          }
                                                                                          String orderDeleteSyskey = orderProducts[i]["stockData"][a+1]["stockSyskey"];
                                                                                          if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                            for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                              if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                stockByBrandDel[b]["stockData"].removeWhere((element) => element["stockSyskey"] == orderDeleteSyskey);
                                                                                                orderProducts[i]["stockData"].removeWhere((element) => element["stockSyskey"] == orderDeleteSyskey);
                                                                                                if(discountDataList.length != 0) {
                                                                                                  discountDataList.removeWhere((element) => element["itemSyskey"].toString() == orderDeleteSyskey);
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                            if (orderProducts[i]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                              if(discountDataList.length != 0) {
                                                                                                discountDataList.removeWhere((element) => element["itemSyskey"].toString() == orderDeleteSyskey);
                                                                                              }
                                                                                            }
                                                                                          } else {
                                                                                            
                                                                                            if (orderProducts[i]["stockData"][a+1]["syskey"] == "0") {
                                                                                              for (var v = 0;
                                                                                                  v < getdeliverylist.length;
                                                                                                  v++) {
                                                                                                if (getdeliverylist[v]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                  for(var w = 0; w < getdeliverylist[v]["stockData"].length; w++) {
                                                                                                    getdeliverylist[v]["stockData"].removeWhere((element) => element["stockSyskey"] == orderDeleteSyskey);
                                                                                                    orderProducts[i]["stockData"].removeWhere((element) => element["stockSyskey"] == orderDeleteSyskey);
                                                                                                  }
                                                                                                  if(discountDataList.length != 0) {
                                                                                                    discountDataList.removeWhere((element) => element["itemSyskey"].toString() == orderDeleteSyskey);
                                                                                                  }
                                                                                                }
                                                                                                print("UI List == > ${orderProducts[i]["stockData"].length}");
                                                                                                print("Background List == > ${getdeliverylist[v]["stockData"]}");
                                                                                              }
                                                                                            } else {
                                                                                              for (var v = 0;
                                                                                                  v < getdeliverylist.length;
                                                                                                  v++) {
                                                                                                if (getdeliverylist[v]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                  orderList.add({
                                                                                                    "syskey": "${orderProducts[i]["stockData"][a+1]["syskey"]}",
                                                                                                    "recordStatus": 4,
                                                                                                    "stockCode": "${orderProducts[i]["stockData"][a+1]["stockCode"]}",
                                                                                                    "stockName": "${orderProducts[i]["stockData"][a+1]["stockName"]}",
                                                                                                    "saleCurrCode": "MMK",
                                                                                                    "stockSyskey" : "${orderProducts[i]["stockData"][a+1]["stockSyskey"]}",
                                                                                                    "n1": "0",
                                                                                                    "wareHouseSyskey": "${orderProducts[i]["stockData"][a+1]["wareHouseSyskey"]}",
                                                                                                    "binSyskey": "0",
                                                                                                    "qty": "${orderProducts[i]["stockData"][a+1]["qty"]}",
                                                                                                    "lvlSyskey": "${orderProducts[i]["stockData"][a+1]["lvlSyskey"]}",
                                                                                                    "lvlQty": 1.0,
                                                                                                    "n8": 1.0,
                                                                                                    "n9": 0.0,
                                                                                                    "taxAmount": 0.0,
                                                                                                    "totalAmount": "${orderProducts[i]["stockData"][a+1]["totalAmount"]}",
                                                                                                    "price": "${orderProducts[i]["stockData"][a+1]["price"]}",
                                                                                                    "normalPrice": "${orderProducts[i]["stockData"][a+1]["normalPrice"]}",
                                                                                                    "taxCodeSK": "0",
                                                                                                    "isTaxInclusice": 0,
                                                                                                    "taxPercent": 0.0,
                                                                                                    "brandOwnerSyskey": "${orderProducts[i]["stockData"][a+1]["brandOwnerSyskey"]}",
                                                                                                    "stockType": "NORMAL"
                                                                                                  });

                                                                                                  orderProducts[i]["stockData"].removeWhere((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"]);

                                                                                                  if(discountDataList.length != 0) {
                                                                                                    discountDataList.removeWhere((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a+1]["stockSyskey"]);
                                                                                                  }

                                                                                                  print(orderProducts[i]["stockData"]);

                                                                                                  print(orderList);
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        });
                                                                                      })
                                                                                ],
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsets
                                                                                    .only(top: 1),
                                                                                child: Row(
                                                                                  mainAxisAlignment:
                                                                                      MainAxisAlignment
                                                                                          .spaceBetween,
                                                                                  children: <
                                                                                      Widget>[
                                                                                    multiDisCalculate == true ?
                                                                                    Row(
                                                                                      children: <Widget>[
                                                                                        Text("Qty : "),
                                                                                        Text("${orderProducts[i]["stockData"][a+1]["qty"].toInt()}"),
                                                                                      ],
                                                                                    ) :
                                                                                    Row(
                                                                                      crossAxisAlignment:
                                                                                          CrossAxisAlignment
                                                                                              .center,
                                                                                      children: <
                                                                                          Widget>[
                                                                                        Container(
                                                                                          child:
                                                                                              GestureDetector(
                                                                                            onTap:
                                                                                                () async {
                                                                                              final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                              if (orderProducts[i]["stockData"][a+1]["qty"] == 1 ||
                                                                                                  orderProducts[i]["stockData"][a+1]["qty"] < 1) {
                                                                                              } else {
                                                                                                setState(() {
                                                                                                  orderProducts[i]["stockData"][a+1]["qty"]--;

                                                                                                  orderProducts[i]["stockData"][a+1]["totalAmount"] = orderProducts[i]["stockData"][a+1]["normalPrice"] * orderProducts[i]["stockData"][a+1]["qty"];

                                                                                                  if(discountCheckList.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList().length != 0) {
                                                                                                    _handleSubmit(context);
                                                                                                    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                                    getSysKey.then((val) {
                                                                                                      var param;
                                                                                                      if(discountStockListDate.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString() && element["createddate"] == orderProducts[i]["stockData"][a+1]["appliedDate"].toString()).toList().length != 0) {
                                                                                                        param = jsonEncode(
                                                                                                          {
                                                                                                            "itemSyskey": "${orderProducts[i]["stockData"][a+1]["stockSyskey"]}",
                                                                                                            "itemDesc": "${orderProducts[i]["stockData"][a+1]["stockName"]}",
                                                                                                            "itemAmount": orderProducts[i]["stockData"][a+1]["normalPrice"].toInt(),
                                                                                                            "itemTotalAmount": orderProducts[i]["stockData"][a+1]["totalAmount"].toInt(),
                                                                                                            "itemQty": orderProducts[i]["stockData"][a+1]["qty"].toInt(),
                                                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                            "date": "${discountStockListDate.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                                                                                                          }
                                                                                                        );
                                                                                                      } else {
                                                                                                        datetime();
                                                                                                        param = jsonEncode(
                                                                                                          {
                                                                                                            "itemSyskey": "${orderProducts[i]["stockData"][a+1]["stockSyskey"]}",
                                                                                                            "itemDesc": "${orderProducts[i]["stockData"][a+1]["stockName"]}",
                                                                                                            "itemAmount": orderProducts[i]["stockData"][a+1]["normalPrice"].toInt(),
                                                                                                            "itemTotalAmount": orderProducts[i]["stockData"][a+1]["totalAmount"].toInt(),
                                                                                                            "itemQty": orderProducts[i]["stockData"][a+1]["qty"].toInt(),
                                                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                            "date": "$date"
                                                                                                          }
                                                                                                        );
                                                                                                      }

                                                                                                      getVolDisCalculation(param, orderProducts[i]["stockData"], context, false).then((getVolDisCalculationValue) {
                                                                                                        if(getVolDisCalculationValue == "success") {
                                                                                                          print("111111111111111111>>>>>>");
                                                                                                          setState(() {
                                                                                                            if(newStockList.length != 0) {
                                                                                                              orderProducts[i]["stockData"] = newStockList;
                                                                                                            }
                                                                                                            
                                                                                                            if(discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0.0") {
                                                                                                              var discountpercent = discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["discountPercent"];
                                                                                                              orderProducts[i]["stockData"][a+1]["totalAmount"] = (orderProducts[i]["stockData"][a+1]["normalPrice"] * ((100 - discountpercent) / 100)) * orderProducts[i]["stockData"][a+1]["qty"];
                                                                                                              orderProducts[i]["stockData"][a+1]["price"] = orderProducts[i]["stockData"][a+1]["normalPrice"] * ((100 - discountpercent) / 100);
                                                                                                              orderProducts[i]["stockData"][a+1]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];
                                                                                                              
                                                                                                              if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                                for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                                  if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                                    for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                                      if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]) {
                                                                                                                        stockByBrandDel[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a+1]["totalAmount"];
                                                                                                                        stockByBrandDel[b]["stockData"][c]["price"] = orderProducts[i]["stockData"][a+1]["price"];
                                                                                                                        stockByBrandDel[b]["stockData"][c]["promoDetailSyskey"] = orderProducts[i]["stockData"][a+1]["promoDetailSyskey"];
                                                                                                                      }
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                              } else {
                                                                                                                for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                                  if (getdeliverylist[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                                    for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                                      if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]) {
                                                                                                                        getdeliverylist[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a+1]["totalAmount"];
                                                                                                                        getdeliverylist[b]["stockData"][c]["price"] = orderProducts[i]["stockData"][a+1]["price"];
                                                                                                                        getdeliverylist[b]["stockData"][c]["promoDetailSyskey"] = orderProducts[i]["stockData"][a+1]["promoDetailSyskey"];
                                                                                                                      }
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                            Navigator.pop(context);
                                                                                                          });
                                                                                                        }else if(getVolDisCalculationValue == "fail") {
                                                                                                          Navigator.pop(context);
                                                                                                          snackbarmethod("FAIL!");
                                                                                                        }else {
                                                                                                          Navigator.pop(context);
                                                                                                          // getVolDisCalculationDialog(param, getVolDisCalculationValue.toString(), orderProducts[i]["stockData"][a+1]);
                                                                                                        }
                                                                                                      });
                                                                                                    });
                                                                                                    
                                                                                                  }

                                                                                                  if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                    for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                      if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                        for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                          if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]) {
                                                                                                            stockByBrandDel[b]["stockData"][c]["qty"] = orderProducts[i]["stockData"][a+1]["qty"];
                                                                                                            stockByBrandDel[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a+1]["totalAmount"];
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                  } else {
                                                                                                    for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                      if (getdeliverylist[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                        for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                          if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]) {
                                                                                                            getdeliverylist[b]["stockData"][c]["qty"] = orderProducts[i]["stockData"][a+1]["qty"];
                                                                                                            getdeliverylist[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a+1]["totalAmount"];
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                });
                                                                                              }
                                                                                            },
                                                                                            child:
                                                                                                Center(
                                                                                              child:
                                                                                                  Icon(
                                                                                                const IconData(0xe15b, fontFamily: 'MaterialIcons'),
                                                                                                color: Colors.white,
                                                                                                size: 19,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          decoration:
                                                                                              BoxDecoration(
                                                                                            color:
                                                                                                Color(0xffe53935),
                                                                                            borderRadius:
                                                                                                BorderRadius.circular(3),
                                                                                            border:
                                                                                                Border(
                                                                                              top:
                                                                                                  BorderSide(width: 0.5, color: Colors.white),
                                                                                              bottom:
                                                                                                  BorderSide(width: 0.5, color: Colors.white),
                                                                                              left:
                                                                                                  BorderSide(width: 0.5, color: Colors.white),
                                                                                              right:
                                                                                                  BorderSide(width: 0.5, color: Colors.white),
                                                                                            ),
                                                                                          ),
                                                                                          height:
                                                                                              27,
                                                                                          width:
                                                                                              27,
                                                                                        ),
                                                                                        GestureDetector(
                                                                                          onTap:
                                                                                              () async {
                                                                                            final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                            _showIntDialog(int.parse("${orderProducts[i]["stockData"][a+1]["qty"]}".substring(0, orderProducts[i]["stockData"][a+1]["qty"].toString().lastIndexOf("."))))
                                                                                                .then((value) {
                                                                                              setState(() {
                                                                                                orderProducts[i]["stockData"][a+1]["qty"] = value.toDouble();

                                                                                                orderProducts[i]["stockData"][a+1]["totalAmount"] = orderProducts[i]["stockData"][a+1]["normalPrice"] * orderProducts[i]["stockData"][a+1]["qty"];
                                                                                              });

                                                                                              if(discountCheckList.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList().length != 0) {
                                                                                                    _handleSubmit(context);
                                                                                                    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                                    getSysKey.then((val) {
                                                                                                      var param;
                                                                                                      if(discountStockListDate.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString() && element["createddate"] == orderProducts[i]["stockData"][a+1]["appliedDate"].toString()).toList().length != 0) {
                                                                                                        param = jsonEncode(
                                                                                                          {
                                                                                                            "itemSyskey": "${orderProducts[i]["stockData"][a+1]["stockSyskey"]}",
                                                                                                            "itemDesc": "${orderProducts[i]["stockData"][a+1]["stockName"]}",
                                                                                                            "itemAmount": orderProducts[i]["stockData"][a+1]["normalPrice"].toInt(),
                                                                                                            "itemTotalAmount": orderProducts[i]["stockData"][a+1]["totalAmount"].toInt(),
                                                                                                            "itemQty": orderProducts[i]["stockData"][a+1]["qty"].toInt(),
                                                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                            "date": "${discountStockListDate.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                                                                                                          }
                                                                                                        );
                                                                                                      } else {
                                                                                                        datetime();
                                                                                                        param = jsonEncode(
                                                                                                          {
                                                                                                            "itemSyskey": "${orderProducts[i]["stockData"][a+1]["stockSyskey"]}",
                                                                                                            "itemDesc": "${orderProducts[i]["stockData"][a+1]["stockName"]}",
                                                                                                            "itemAmount": orderProducts[i]["stockData"][a+1]["normalPrice"].toInt(),
                                                                                                            "itemTotalAmount": orderProducts[i]["stockData"][a+1]["totalAmount"].toInt(),
                                                                                                            "itemQty": orderProducts[i]["stockData"][a+1]["qty"].toInt(),
                                                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                            "date": "$date"
                                                                                                          }
                                                                                                        );
                                                                                                      }

                                                                                                      // setState(() {
                                                                                                      getVolDisCalculation(param, orderProducts[i]["stockData"], context, false).then((getVolDisCalculationValue) {
                                                                                                        if(getVolDisCalculationValue == "success") {
                                                                                                          setState(() {
                                                                                                            if(newStockList.length != 0) {
                                                                                                              orderProducts[i]["stockData"] = newStockList;
                                                                                                            }
                                                                                                            if(discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0.0") {
                                                                                                              var discountpercent = discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["discountPercent"];
                                                                                                              orderProducts[i]["stockData"][a+1]["totalAmount"] = (orderProducts[i]["stockData"][a+1]["normalPrice"] * ((100 - discountpercent) / 100)) * orderProducts[i]["stockData"][a+1]["qty"];
                                                                                                              orderProducts[i]["stockData"][a+1]["price"] = orderProducts[i]["stockData"][a+1]["normalPrice"] * ((100 - discountpercent) / 100);
                                                                                                              orderProducts[i]["stockData"][a+1]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];

                                                                                                              if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                                for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                                  if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                                    for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                                      if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]) {
                                                                                                                        stockByBrandDel[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a+1]["totalAmount"];
                                                                                                                        stockByBrandDel[b]["stockData"][c]["price"] = orderProducts[i]["stockData"][a+1]["price"];
                                                                                                                        stockByBrandDel[b]["stockData"][c]["promoDetailSyskey"] = orderProducts[i]["stockData"][a+1]["promoDetailSyskey"];
                                                                                                                      }
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                              } else {
                                                                                                                for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                                  if (getdeliverylist[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                                    for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                                      if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]) {
                                                                                                                        getdeliverylist[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a+1]["totalAmount"];
                                                                                                                        getdeliverylist[b]["stockData"][c]["price"] = orderProducts[i]["stockData"][a+1]["price"];
                                                                                                                        getdeliverylist[b]["stockData"][c]["promoDetailSyskey"] = orderProducts[i]["stockData"][a+1]["promoDetailSyskey"];
                                                                                                                      }
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                            Navigator.pop(context);
                                                                                                          });
                                                                                                        }else if(getVolDisCalculationValue == "fail") {
                                                                                                          Navigator.pop(context);
                                                                                                          snackbarmethod("FAIL!");
                                                                                                        }else {
                                                                                                          Navigator.pop(context);
                                                                                                          // getVolDisCalculationDialog(param, getVolDisCalculationValue.toString(), orderProducts[i]["stockData"][a+1]);
                                                                                                        }
                                                                                                      });
                                                                                                      // });
                                                                                                      
                                                                                                    });
                                                                                                    
                                                                                                  }

                                                                                              if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                  if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                    for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                      if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]) {
                                                                                                        stockByBrandDel[b]["stockData"][c]["qty"] = orderProducts[i]["stockData"][a+1]["qty"];
                                                                                                        stockByBrandDel[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a+1]["totalAmount"];
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                              } else {
                                                                                                for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                  if (getdeliverylist[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                    for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                      if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]) {
                                                                                                        getdeliverylist[b]["stockData"][c]["qty"] = orderProducts[i]["stockData"][a+1]["qty"];
                                                                                                        getdeliverylist[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a+1]["totalAmount"];
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            });
                                                                                          },
                                                                                          child:
                                                                                              Container(
                                                                                            child:
                                                                                                Center(child: Text("${orderProducts[i]["stockData"][a+1]["qty"]}".substring(0, orderProducts[i]["stockData"][a+1]["qty"].toString().lastIndexOf(".")))),
                                                                                            decoration:
                                                                                                BoxDecoration(
                                                                                              border:
                                                                                                  Border(
                                                                                                top: BorderSide(width: 0.5, color: Colors.grey),
                                                                                                bottom: BorderSide(width: 0.5, color: Colors.grey),
                                                                                                left: BorderSide(width: 0.5, color: Colors.white),
                                                                                                right: BorderSide(width: 0.5, color: Colors.white),
                                                                                              ),
                                                                                            ),
                                                                                            height:
                                                                                                27,
                                                                                            width:
                                                                                                45,
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          child:
                                                                                              GestureDetector(
                                                                                            onTap:
                                                                                                () async {
                                                                                              final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                              if (orderProducts[i]["stockData"][a+1]["qty"] == 99999 ||
                                                                                                  orderProducts[i]["stockData"][a+1]["qty"] > 99999) {
                                                                                              } else {
                                                                                                setState(() {
                                                                                                  orderProducts[i]["stockData"][a+1]["qty"]++;

                                                                                                  orderProducts[i]["stockData"][a+1]["totalAmount"] = orderProducts[i]["stockData"][a+1]["normalPrice"] * orderProducts[i]["stockData"][a+1]["qty"];

                                                                                                  var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                                  print(orderProducts[i]["stockData"][a+1]["stockSyskey"]);

                                                                                                  if(listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList().length != 0) {
                                                                                                    var param;
                                                                                                    // _handleSubmit(context);
                                                                                                    getSysKey.then((val) {
                                                                                                        String headerSyskey = "";
                                                                                                        String ruleNumber = "";
                                                                                                        String rulePriority = "";
                                                                                                        List multiStockList = [];
                                                                                                        List itemInfoList = [];

                                                                                                        headerSyskey = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"]).toList()[0]["HeaderSyskey"];
                                                                                                        ruleNumber = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"]).toList()[0]["RuleNumber"];
                                                                                                        rulePriority = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"]).toList()[0]["RulePriority"];

                                                                                                        multiStockList = multiDiscountStockList.where((element) => element["HeaderSyskey"] == headerSyskey).toList()[0]["DetailList"].where((element) => element["RuleNumber"] == ruleNumber && element["RulePriority"] == rulePriority).toList();

                                                                                                        for(var y = 0 ; y < multiStockList.length; y++) {
                                                                                                          for(var z = 0; z < orderProducts[i]["stockData"].length; z++) {
                                                                                                            if(itemInfoList.where((element) => element["itemSyskey"] == multiStockList[y]["PromoItemSyskey"]).toList().length == 0) {
                                                                                                            if(multiStockList[y]["PromoItemSyskey"] == orderProducts[i]["stockData"][z]["stockSyskey"]) {
                                                                                                              itemInfoList.add({
                                                                                                                "itemSyskey" : orderProducts[i]["stockData"][z]["stockSyskey"],
                                                                                                                "itemDesc" : orderProducts[i]["stockData"][z]["stockName"],
                                                                                                                "itemAmount": orderProducts[i]["stockData"][z]["normalPrice"],
                                                                                                                "itemTotalAmount": orderProducts[i]["stockData"][z]["totalAmount"],
                                                                                                                "itemQty": orderProducts[i]["stockData"][z]["qty"].toInt(),
                                                                                                              });
                                                                                                            }
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                        param = jsonEncode({
                                                                                                          "itemInfoList" : itemInfoList,
                                                                                                          "shopSyskey" : "${val[0]["shopsyskey"]}",
                                                                                                          "date" : "$date"
                                                                                                        });

                                                                                                        multiDiscountCalculation(param, orderProducts[i]["stockData"], context).then((value) {
                                                                                                          // Navigator.pop(context);
                                                                                                        });
                                                                                                    });
                                                                                                      } else {
                                                                                                      if(discountCheckList.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList().length != 0) {
                                                                                                    _handleSubmit(context);
                                                                                                    
                                                                                                    getSysKey.then((val) {
                                                                                                      var param;
                                                                                                      if(discountStockListDate.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString() && element["createddate"] == orderProducts[i]["stockData"][a+1]["appliedDate"].toString()).toList().length != 0) {
                                                                                                        param = jsonEncode(
                                                                                                          {
                                                                                                            "itemSyskey": "${orderProducts[i]["stockData"][a+1]["stockSyskey"]}",
                                                                                                            "itemDesc": "${orderProducts[i]["stockData"][a+1]["stockName"]}",
                                                                                                            "itemAmount": orderProducts[i]["stockData"][a+1]["normalPrice"].toInt(),
                                                                                                            "itemTotalAmount": orderProducts[i]["stockData"][a+1]["totalAmount"].toInt(),
                                                                                                            "itemQty": orderProducts[i]["stockData"][a+1]["qty"].toInt(),
                                                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                            "date": "${discountStockListDate.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                                                                                                          }
                                                                                                        );
                                                                                                      } else {
                                                                                                        datetime();
                                                                                                        param = jsonEncode(
                                                                                                          {
                                                                                                            "itemSyskey": "${orderProducts[i]["stockData"][a+1]["stockSyskey"]}",
                                                                                                            "itemDesc": "${orderProducts[i]["stockData"][a+1]["stockName"]}",
                                                                                                            "itemAmount": orderProducts[i]["stockData"][a+1]["normalPrice"].toInt(),
                                                                                                            "itemTotalAmount": orderProducts[i]["stockData"][a+1]["totalAmount"].toInt(),
                                                                                                            "itemQty": orderProducts[i]["stockData"][a+1]["qty"].toInt(),
                                                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                            "date": "$date"
                                                                                                          }
                                                                                                        );
                                                                                                      }

                                                                                                      getVolDisCalculation(param, orderProducts[i]["stockData"], context, false).then((getVolDisCalculationValue) {
                                                                                                        if(getVolDisCalculationValue == "success") {
                                                                                                          print("33333333333333333333>>>>>>");
                                                                                                          setState(() {
                                                                                                            if(newStockList.length != 0) {
                                                                                                              orderProducts[i]["stockData"] = newStockList;
                                                                                                            }
                                                                                                            if(discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList().length.toString() != "0") {
                                                                                                              if(discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0.0") {
                                                                                                                var discountpercent = discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["discountPercent"];
                                                                                                                orderProducts[i]["stockData"][a+1]["totalAmount"] = (orderProducts[i]["stockData"][a+1]["normalPrice"] * ((100 - discountpercent) / 100)) * orderProducts[i]["stockData"][a+1]["qty"];
                                                                                                                orderProducts[i]["stockData"][a+1]["price"] = orderProducts[i]["stockData"][a+1]["normalPrice"] * ((100 - discountpercent) / 100);
                                                                                                                orderProducts[i]["stockData"][a+1]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];

                                                                                                                if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                                for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                                  if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                                    for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                                      if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]) {
                                                                                                                        stockByBrandDel[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a+1]["totalAmount"];
                                                                                                                        stockByBrandDel[b]["stockData"][c]["price"] = orderProducts[i]["stockData"][a+1]["price"];
                                                                                                                        stockByBrandDel[b]["stockData"][c]["promoDetailSyskey"] = orderProducts[i]["stockData"][a+1]["promoDetailSyskey"];
                                                                                                                      }
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                              } else {
                                                                                                                for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                                  if (getdeliverylist[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                                    for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                                      if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]) {
                                                                                                                        getdeliverylist[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a+1]["totalAmount"];
                                                                                                                        getdeliverylist[b]["stockData"][c]["price"] = orderProducts[i]["stockData"][a+1]["price"];
                                                                                                                        getdeliverylist[b]["stockData"][c]["promoDetailSyskey"] = orderProducts[i]["stockData"][a+1]["promoDetailSyskey"];
                                                                                                                      }
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                              }
                                                                                                            }
                                                                                                            Navigator.pop(context);
                                                                                                          });
                                                                                                        }else if(getVolDisCalculationValue == "fail") {
                                                                                                          Navigator.pop(context);
                                                                                                          snackbarmethod("FAIL!");
                                                                                                        }else {
                                                                                                          Navigator.pop(context);
                                                                                                          // getVolDisCalculationDialog(param, getVolDisCalculationValue.toString(), orderProducts[i]["stockData"][a+1]);
                                                                                                        }
                                                                                                      });
                                                                                                      
                                                                                                    });
                                                                                                    
                                                                                                  }
                                                                                                  
                                                                                                  if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                    for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                      if (stockByBrandDel[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                        for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                          if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]) {
                                                                                                            stockByBrandDel[b]["stockData"][c]["qty"] = orderProducts[i]["stockData"][a+1]["qty"];
                                                                                                            stockByBrandDel[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a+1]["totalAmount"];
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                  } else {
                                                                                                    for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                      if (getdeliverylist[b]["brandOwnerSyskey"] == orderProducts[i]["brandOwnerSyskey"]) {
                                                                                                        for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                          if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderProducts[i]["stockData"][a+1]["stockCode"]) {
                                                                                                            getdeliverylist[b]["stockData"][c]["qty"] = orderProducts[i]["stockData"][a+1]["qty"];
                                                                                                            getdeliverylist[b]["stockData"][c]["totalAmount"] = orderProducts[i]["stockData"][a+1]["totalAmount"];
                                                                                                          }

                                                                                                          print(getdeliverylist[b]["stockData"][c]);
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                      }

                                                                                                  
                                                                                                });
                                                                                              }
                                                                                            },
                                                                                            child:
                                                                                                Center(child: Icon(Icons.add, size: 19, color: Colors.white)),
                                                                                          ),
                                                                                          decoration:
                                                                                              BoxDecoration(
                                                                                            borderRadius:
                                                                                                BorderRadius.circular(3),
                                                                                            color:
                                                                                                Color(0xffe53935),
                                                                                            border:
                                                                                                Border(
                                                                                              top:
                                                                                                  BorderSide(width: 0.5, color: Colors.white),
                                                                                              bottom:
                                                                                                  BorderSide(width: 0.5, color: Colors.white),
                                                                                              left:
                                                                                                  BorderSide(width: 0.5, color: Colors.white),
                                                                                              right:
                                                                                                  BorderSide(width: 0.5, color: Colors.white),
                                                                                            ),
                                                                                          ),
                                                                                          height:
                                                                                              27,
                                                                                          width:
                                                                                              27,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Container(
                                                                                      width: 150,
                                                                                      child: Row(
                                                                                        mainAxisAlignment:
                                                                                            MainAxisAlignment
                                                                                                .spaceBetween,
                                                                                        children: <
                                                                                            Widget>[
                                                                                          
                                                                                          Text("${orderProducts[i]["stockData"][a]["normalPrice"].toInt()}" == "0" ? "${orderProducts[i]["stockData"][a]["price"].toInt()}" : "${orderProducts[i]["stockData"][a]["normalPrice"].toInt()}"),
                                                                                          // Text("0"),
                                                                                          Padding(
                                                                                            padding:
                                                                                                const EdgeInsets.only(right: 15),
                                                                                            child: Text(
                                                                                              orderProducts[i]["stockData"][a+1]["totalAmount"].toString().substring(orderProducts[i]["stockData"][a+1]["totalAmount"].toString().lastIndexOf("."), orderProducts[i]["stockData"][a+1]["totalAmount"].toString().length).length > 3 ?
                                                                                              "${orderProducts[i]["stockData"][a+1]["totalAmount"].toStringAsFixed(2)}" :
                                                                                              double.parse(orderProducts[i]["stockData"][a+1]["totalAmount"].toString().substring(orderProducts[i]["stockData"][a+1]["totalAmount"].toString().lastIndexOf("."), orderProducts[i]["stockData"][a+1]["totalAmount"].toString().length)) == 0.0 ?
                                                                                                "${orderProducts[i]["stockData"][a+1]["totalAmount"].toInt()}" :
                                                                                                "${orderProducts[i]["stockData"][a+1]["totalAmount"]}"
                                                                                                ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              orderProducts[i]["stockData"][a+1]["discountAmount"] == "" || orderProducts[i]["stockData"][a+1]["discountPercent"] == "" || orderProducts[i]["stockData"][a+1]["discountAmount"] == null || orderProducts[i]["stockData"][a+1]["discountPercent"] == null ?
                                                                              Container() :
                                                                              Visibility(
                                                                                visible: orderProducts[i]["stockData"][a+1]["discountAmount"] == "" || orderProducts[i]["stockData"][a+1]["discountPercent"] == "" ? false : true,
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
                                                                                              orderProducts[i]["stockData"][a+1]["discountAmount"] == "" || orderProducts[i]["stockData"][a+1]["discountAmount"].toString() == "0.0" || orderProducts[i]["stockData"][a+1]["discountPercent"] == "" || orderProducts[i]["stockData"][a+1]["discountPercent"].toString() == "0.0" ?
                                                                                              "" :
                                                                                              orderProducts[i]["stockData"][a+1]["discountPercent"].toString() == "0.0" &&
                                                                                              orderProducts[i]["stockData"][a+1]["discountAmount"].toString() == "0.0" ? "" :
                                                                                              "${orderProducts[i]["stockData"][a+1]["normalPrice"].toInt() * orderProducts[i]["stockData"][a+1]["qty"].toInt()}", style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12),),
                                                                                            orderProducts[i]["stockData"][a+1]["discountAmount"] == "" || orderProducts[i]["stockData"][a+1]["discountAmount"].toString() == "0.0" || orderProducts[i]["stockData"][a+1]["discountPercent"] == "" || orderProducts[i]["stockData"][a+1]["discountPercent"].toString() == "0.0" ?
                                                                                            Text("") :
                                                                                            Text(
                                                                                              orderProducts[i]["stockData"][a+1]["discountPercent"].toString() != "0.0" ?
                                                                                              "  -${orderProducts[i]["stockData"][a+1]["discountPercent"]}%" :
                                                                                              orderProducts[i]["stockData"][a+1]["discountAmount"].toString() != "0.0" ?
                                                                                              "  -${orderProducts[i]["stockData"][a+1]["discountAmount"].toInt()}" : ""
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
                                                                  if(discountCheckList.where((element) => element["stockSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList().length != 0 || 
                                                                    listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList().length != 0)
                                                                    GestureDetector(
                                                                      onTap: () async {
                                                                        if(listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList().length != 0) {
                                                                          List detailList = [];
                                                                          List sameDetailList = [];
                                                                          String headerSyskey = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["HeaderSyskey"];
                                                                          String ruleNumber = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["RuleNumber"];
                                                                          String rulePriority = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["RulePriority"];
                                                                          for(var j = 0; j < multiDiscountStockList.length; j++) {
                                                                            if(multiDiscountStockList[j]["HeaderSyskey"] == headerSyskey) {
                                                                              // sameDetailList = multiDiscountStockList[j]["DetailList"].where((element) => element["PromoItemSyskey"] == orderProducts[i]["stockData"][a+1]["stockSyskey"] && element["RuleNumber"] == ruleNumber && element["RulePriority"] == rulePriority).toList();
                                                                              sameDetailList = multiDiscountStockList[j]["DetailList"].where((element) => element["RuleNumber"] == ruleNumber && element["RulePriority"] == rulePriority).toList();
                                                                            }
                                                                          }
                                                                          detailList.add({
                                                                            "PromoItemSyskey" : orderProducts[i]["stockData"][a+1]["stockSyskey"],
                                                                            "PromoItemDesc" : orderProducts[i]["stockData"][a+1]["stockName"],
                                                                            "HeaderList" : [
                                                                              {
                                                                                "DetailList": sameDetailList,
                                                                                "ToDate" : multiDiscountStockList.where((element) => element["HeaderSyskey"] == headerSyskey).toList()[0]["ToDate"]
                                                                              }
                                                                            ]
                                                                          });
                                                                          print(detailList);
                                                                          Navigator.push(context, MaterialPageRoute(builder: (context) => DiscountDetail(detail: detailList, stockDetail: orderProducts[i]["stockData"][a+1],)));
                                                                        } else {
                                                                          _handleSubmit(context);
                                                                          final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                          var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                          getSysKey.then((val) {
                                                                            getPromoItemDetail("${val[0]["shopsyskey"]}", "", orderProducts[i]["stockData"][a+1]["stockSyskey"], orderProducts[i]["brandOwnerSyskey"]).then((promoDetailVal) {
                                                                              Navigator.pop(context);
                                                                              if(promoDetailVal == "success") {
                                                                                setState(() {
                                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => DiscountDetail(detail: promoItemDetailList, stockDetail: orderProducts[i]["stockData"][a+1],)));
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
                                                          Visibility(
                                                            visible: orderProducts[i]["stockData"][a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().length == 0 ? false : true,
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
                                                              for(var k = 0; k < orderProducts[i]["stockData"][a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().length; k++)
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
                                                                          Text("${orderProducts[i]["stockData"][a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList()[k]["stockName"]}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300)),
                                                                          Text("Qty : ${orderProducts[i]["stockData"][a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList()[k]["qty"].toInt()}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300))
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
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ]),
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
                            style: TextStyle(color: Colors.black, fontSize: 17),
                          ))),
                    ),
                    if(multiDisCalculate == false)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        height: 50,
                        child: GestureDetector(
                          onTap: () async {
                            final SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            preferences.setString("OriginalStockList",
                                json.encode(orderProducts));
                            preferences.setString(
                                "ReturnStockList", json.encode(returnProducts));

                            if (widget.orderDeleted.toString() == "[]") {
                              setState(() {
                                orderList = orderList;
                              });
                            } else {
                              setState(() {
                                orderList = widget.orderDeleted;
                              });
                            }

                            if (widget.returnDeleted.toString() == "[]") {
                              setState(() {
                                returnList = returnList;
                              });
                            } else {
                              setState(() {
                                returnList = widget.returnDeleted;
                              });
                            }

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddReturnProduct(
                                          shopName: widget.shopName,
                                          shopNameMm: widget.shopNameMm,
                                          address: widget.address,
                                          shopSyskey: widget.shopSyskey,
                                          date: widget.orderDate,
                                          mcdCheck: widget.mcdCheck,
                                          userType: widget.userType,
                                          title: "Return Stocks",
                                          phone: widget.phone,
                                          stockList1: returnProducts,
                                          returnList: orderProducts,
                                          orderDeleted: orderList,
                                          returnDeleted: returnList,
                                          isSaleOrderLessRouteShop:
                                              widget.isSaleOrderLessRouteShop,
                                        )));
                          },
                          child: Card(
                            color: Colors.red[100],
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Add Return Products",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        // height: returnStockLength,
                        child: Column(children: <Widget>[
                          for (var i = 0; i < returnProducts.length; i++)
                            // ListView.builder(
                            //     physics: NeverScrollableScrollPhysics(),
                            //     itemCount: returnProducts.length,
                            //     itemBuilder: (context, i) {
                            //       return
                            Visibility(
                              visible:
                                  returnProducts[i]["stockData"].length == 0
                                      ? false
                                      : true,
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      if (returnProducts[i]["visible"] ==
                                          false) {
                                        setState(() {
                                          returnProducts[i]["visible"] = true;
                                        });
                                      } else if (returnProducts[i]["visible"] ==
                                          true) {
                                        setState(() {
                                          returnProducts[i]["visible"] = false;
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: 50,
                                      child: Card(
                                          color: Color(0xffe53935),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  returnProducts[i][
                                                              "brandOwnerName"] ==
                                                          null
                                                      ? ""
                                                      : "${returnProducts[i]["brandOwnerName"]}",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white),
                                                ),
                                                Icon(
                                                  returnProducts[i]["visible"]
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
                                    visible: returnProducts[i]["visible"],
                                    child: Container(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: returnProducts[i]
                                                  ["stockData"]
                                              .length,
                                          itemBuilder: (context, a) {
                                            return Container(
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
                                                      child: stockImage == [] ||
                                                              stockImage
                                                                      .length ==
                                                                  0
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
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
                                                                ),
                                                                stockImage.where((element) => element["stockCode"] == returnProducts[i]["stockData"][a]["stockCode"]).toList().toString() == "[]"
                                                                    ? GestureDetector(
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
                                                                      )
                                                                    : GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => ShowImage(image: CachedNetworkImage(imageUrl: "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == returnProducts[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}"))));
                                                                        },
                                                                        // child: Image.network(
                                                                        //     "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == returnProducts[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
                                                                        //     fit: BoxFit
                                                                        //         .cover),
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          imageUrl:
                                                                              "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == returnProducts[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
                                                                        ),
                                                                      ),
                                                              ],
                                                            ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              82,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 3,
                                                                left: 10),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      170,
                                                                  // height: 20,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              5),
                                                                  child: Text(
                                                                    "${returnProducts[i]["stockData"][a]["stockName"]}",
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                    icon: Icon(
                                                                      Icons
                                                                          .delete_outline,
                                                                      color: multiDisCalculate == true ? Colors.white : Color(
                                                                          0xffe53935),
                                                                    ),
                                                                    onPressed: multiDisCalculate == true ? null :
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        if (widget.orderDeleted.toString() ==
                                                                            "[]") {
                                                                          setState(
                                                                              () {
                                                                            orderList =
                                                                                orderList;
                                                                          });
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            orderList =
                                                                                widget.orderDeleted;
                                                                          });
                                                                        }

                                                                        if (widget.returnDeleted.toString() == "[]") {
                                                                          setState(() {
                                                                            returnList = returnList;
                                                                          });
                                                                        } else {
                                                                          setState(() {
                                                                            returnList = widget.returnDeleted;
                                                                          });
                                                                        }
                                                                        String returnDeleteSyskey = returnProducts[i]["stockData"][a]["stockSyskey"];
                                                                        if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                          for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                            if (stockByBrandDel[b]["brandOwnerSyskey"] == returnProducts[i]["brandOwnerSyskey"]) {
                                                                              stockByBrandDel[b]["stockReturnData"].removeWhere((element) => element["stockSyskey"] == returnDeleteSyskey);
                                                                              returnProducts[i]["stockData"].removeWhere((element) => element["stockSyskey"] == returnDeleteSyskey);
                                                                            }
                                                                          }

                                                                          // returnProducts[i]["stockData"].removeWhere((element) => element["stockCode"] == returnProducts[i]["stockData"][a]["stockCode"]);
                                                                        } else {
                                                                          
                                                                          if (returnProducts[i]["stockData"][a]["syskey"] == "0") {
                                                                            for (var v = 0; v < getdeliverylist.length; v++) {
                                                                              if (getdeliverylist[v]["brandOwnerSyskey"] == returnProducts[i]["brandOwnerSyskey"]) {
                                                                                getdeliverylist[v]["stockReturnData"].removeWhere((element) => element["stockSyskey"] == returnDeleteSyskey);
                                                                                returnProducts[i]["stockData"].removeWhere((element) => element["stockSyskey"] == returnDeleteSyskey);
                                                                              }
                                                                            }
                                                                            
                                                                          } else {
                                                                            for (var v = 0;
                                                                                v < getdeliverylist.length;
                                                                                v++) {
                                                                              if (getdeliverylist[v]["brandOwnerSyskey"] == returnProducts[i]["brandOwnerSyskey"]) {
                                                                                returnList.add({
                                                                                  "syskey": "${returnProducts[i]["stockData"][a]["syskey"]}",
                                                                                  "recordStatus": 4,
                                                                                  "stockCode": "${returnProducts[i]["stockData"][a]["stockCode"]}",
                                                                                  "stockName": "${returnProducts[i]["stockData"][a]["stockName"]}",
                                                                                  "saleCurrCode": "MMK",
                                                                                  "stockSyskey": "${returnProducts[i]["stockData"][a]["stockSyskey"]}",
                                                                                  "n1": "0",
                                                                                  "wareHouseSyskey": "${returnProducts[i]["stockData"][a]["wareHouseSyskey"]}",
                                                                                  "binSyskey": "0",
                                                                                  "qty": "${returnProducts[i]["stockData"][a]["qty"]}",
                                                                                  "lvlSyskey": "${returnProducts[i]["stockData"][a]["lvlSyskey"]}",
                                                                                  "lvlQty": 1.0,
                                                                                  "n8": 1.0,
                                                                                  "n9": 0.0,
                                                                                  "taxAmount": 0.0,
                                                                                  "totalAmount": "${returnProducts[i]["stockData"][a]["totalAmount"]}",
                                                                                  "price": "${returnProducts[i]["stockData"][a]["price"]}",
                                                                                  "normalPrice": "${returnProducts[i]["stockData"][a]["normalPrice"]}",
                                                                                  "taxCodeSK": "0",
                                                                                  "isTaxInclusice": 0,
                                                                                  "taxPercent": 0.0,
                                                                                  "brandOwnerSyskey": "${returnProducts[i]["stockData"][a]["brandOwnerSyskey"]}",
                                                                                  "stockType": "RETURN"
                                                                                });
                                                                                // getdeliverylist[v]["stockReturnData"].removeWhere((element) => element == returnProducts[i]["stockData"][a]);

                                                                                returnProducts[i]["stockData"].removeWhere((element) => element == returnProducts[i]["stockData"][a]);

                                                                                print(returnList);
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      });
                                                                    })
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(top: 1),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: <
                                                                    Widget>[
                                                                  multiDisCalculate == true ?
                                                                  Row(
                                                                    children: <Widget>[
                                                                      Text("Qty : "),
                                                                      Text("${returnProducts[i]["stockData"][a]["qty"].toInt()}"),
                                                                    ],
                                                                  ) :
                                                                  Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            if (returnProducts[i]["stockData"][a]["qty"] == 1 ||
                                                                                returnProducts[i]["stockData"][a]["qty"] < 1) {
                                                                            } else {
                                                                              setState(() {
                                                                                returnProducts[i]["stockData"][a]["qty"]--;

                                                                                returnProducts[i]["stockData"][a]["totalAmount"] = returnProducts[i]["stockData"][a]["price"] * returnProducts[i]["stockData"][a]["qty"];

                                                                                if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                  for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                    if (stockByBrandDel[b]["brandOwnerSyskey"] == returnProducts[i]["brandOwnerSyskey"]) {
                                                                                      for (var c = 0; c < stockByBrandDel[b]["stockReturnData"].length; c++) {
                                                                                        if (stockByBrandDel[b]["stockReturnData"][c]["stockCode"] == returnProducts[i]["stockData"][a]["stockCode"]) {
                                                                                          stockByBrandDel[b]["stockReturnData"][c]["qty"] = returnProducts[i]["stockData"][a]["qty"];
                                                                                          stockByBrandDel[b]["stockReturnData"][c]["totalAmount"] = returnProducts[i]["stockData"][a]["totalAmount"];
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                } else {
                                                                                  for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                    if (getdeliverylist[b]["brandOwnerSyskey"] == returnProducts[i]["brandOwnerSyskey"]) {
                                                                                      for (var c = 0; c < getdeliverylist[b]["stockReturnData"].length; c++) {
                                                                                        if (getdeliverylist[b]["stockReturnData"][c]["stockCode"] == returnProducts[i]["stockData"][a]["stockCode"]) {
                                                                                          getdeliverylist[b]["stockReturnData"][c]["qty"] = returnProducts[i]["stockData"][a]["qty"];
                                                                                          getdeliverylist[b]["stockReturnData"][c]["totalAmount"] = returnProducts[i]["stockData"][a]["totalAmount"];
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              });
                                                                            }
                                                                          },
                                                                          child: Center(
                                                                              child: Icon(
                                                                            const IconData(0xe15b,
                                                                                fontFamily: 'MaterialIcons'),
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                19,
                                                                          )),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Color(0xffe53935),
                                                                          borderRadius:
                                                                              BorderRadius.circular(3),
                                                                          border:
                                                                              Border(
                                                                            top:
                                                                                BorderSide(width: 0.5, color: Colors.white),
                                                                            bottom:
                                                                                BorderSide(width: 0.5, color: Colors.white),
                                                                            left:
                                                                                BorderSide(width: 0.5, color: Colors.white),
                                                                            right:
                                                                                BorderSide(width: 0.5, color: Colors.white),
                                                                          ),
                                                                        ),
                                                                        height:
                                                                            27,
                                                                        width:
                                                                            27,
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          _showIntDialog(int.parse("${returnProducts[i]["stockData"][a]["qty"]}".substring(0, returnProducts[i]["stockData"][a]["qty"].toString().lastIndexOf("."))))
                                                                              .then((value) {
                                                                            setState(() {
                                                                              returnProducts[i]["stockData"][a]["qty"] = value.toDouble();

                                                                              returnProducts[i]["stockData"][a]["totalAmount"] = returnProducts[i]["stockData"][a]["price"] * returnProducts[i]["stockData"][a]["qty"];
                                                                            });

                                                                            if (getdeliverylist == [] ||
                                                                                getdeliverylist == null ||
                                                                                getdeliverylist.length == 0) {
                                                                              for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                if (stockByBrandDel[b]["brandOwnerSyskey"] == returnProducts[i]["brandOwnerSyskey"]) {
                                                                                  for (var c = 0; c < stockByBrandDel[b]["stockReturnData"].length; c++) {
                                                                                    if (stockByBrandDel[b]["stockReturnData"][c]["stockCode"] == returnProducts[i]["stockData"][a]["stockCode"]) {
                                                                                      stockByBrandDel[b]["stockReturnData"][c]["qty"] = returnProducts[i]["stockData"][a]["qty"];
                                                                                      stockByBrandDel[b]["stockReturnData"][c]["totalAmount"] = returnProducts[i]["stockData"][a]["totalAmount"];
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            } else {
                                                                              for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                if (getdeliverylist[b]["brandOwnerSyskey"] == returnProducts[i]["brandOwnerSyskey"]) {
                                                                                  for (var c = 0; c < getdeliverylist[b]["stockReturnData"].length; c++) {
                                                                                    if (getdeliverylist[b]["stockReturnData"][c]["stockCode"] == returnProducts[i]["stockData"][a]["stockCode"]) {
                                                                                      getdeliverylist[b]["stockReturnData"][c]["qty"] = returnProducts[i]["stockData"][a]["qty"];
                                                                                      getdeliverylist[b]["stockReturnData"][c]["totalAmount"] = returnProducts[i]["stockData"][a]["totalAmount"];
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text("${returnProducts[i]["stockData"][a]["qty"]}".substring(0, returnProducts[i]["stockData"][a]["qty"].toString().lastIndexOf("."))),
                                                                          ),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border(
                                                                              top: BorderSide(width: 0.5, color: Colors.grey),
                                                                              bottom: BorderSide(width: 0.5, color: Colors.grey),
                                                                              left: BorderSide(width: 0.5, color: Colors.white),
                                                                              right: BorderSide(width: 0.5, color: Colors.white),
                                                                            ),
                                                                          ),
                                                                          height:
                                                                              27,
                                                                          width:
                                                                              45,
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            if (returnProducts[i]["stockData"][a]["qty"] == 99999 ||
                                                                                returnProducts[i]["stockData"][a]["qty"] > 99999) {
                                                                            } else {
                                                                              setState(() {
                                                                                returnProducts[i]["stockData"][a]["qty"]++;

                                                                                print(returnProducts[i]["stockData"][a]["qty"].runtimeType);

                                                                                returnProducts[i]["stockData"][a]["totalAmount"] = returnProducts[i]["stockData"][a]["price"] * returnProducts[i]["stockData"][a]["qty"];

                                                                                if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                  for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                    if (stockByBrandDel[b]["brandOwnerSyskey"] == returnProducts[i]["brandOwnerSyskey"]) {
                                                                                      for (var c = 0; c < stockByBrandDel[b]["stockReturnData"].length; c++) {
                                                                                        if (stockByBrandDel[b]["stockReturnData"][c]["stockCode"] == returnProducts[i]["stockData"][a]["stockCode"]) {
                                                                                          stockByBrandDel[b]["stockReturnData"][c]["qty"] = returnProducts[i]["stockData"][a]["qty"];
                                                                                          stockByBrandDel[b]["stockReturnData"][c]["totalAmount"] = returnProducts[i]["stockData"][a]["totalAmount"];
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                } else {
                                                                                  for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                    if (getdeliverylist[b]["brandOwnerSyskey"] == returnProducts[i]["brandOwnerSyskey"]) {
                                                                                      for (var c = 0; c < getdeliverylist[b]["stockReturnData"].length; c++) {
                                                                                        if (getdeliverylist[b]["stockReturnData"][c]["stockCode"] == returnProducts[i]["stockData"][a]["stockCode"]) {
                                                                                          getdeliverylist[b]["stockReturnData"][c]["qty"] = returnProducts[i]["stockData"][a]["qty"];
                                                                                          getdeliverylist[b]["stockReturnData"][c]["totalAmount"] = returnProducts[i]["stockData"][a]["totalAmount"];
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              });
                                                                            }
                                                                          },
                                                                          child:
                                                                              Center(child: Icon(Icons.add, size: 19, color: Colors.white)),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(3),
                                                                          color:
                                                                              Color(0xffe53935),
                                                                          border:
                                                                              Border(
                                                                            top:
                                                                                BorderSide(width: 0.5, color: Colors.white),
                                                                            bottom:
                                                                                BorderSide(width: 0.5, color: Colors.white),
                                                                            left:
                                                                                BorderSide(width: 0.5, color: Colors.white),
                                                                            right:
                                                                                BorderSide(width: 0.5, color: Colors.white),
                                                                          ),
                                                                        ),
                                                                        height:
                                                                            27,
                                                                        width:
                                                                            27,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  // GestureDetector(
                                                                  //   onTap: () {
                                                                  //     setState(() {
                                                                  //       returnPriceCtrl = TextEditingController(text: "${returnProducts[i]["stockData"][a]["price"].toInt()}");
                                                                  //       returnPrice = returnProducts[i]["stockData"][a]["price"];
                                                                  //     });
                                                                  //     _showReturnPriceDialog().then((value) {
                                                                  //       setState(() {
                                                                  //         returnProducts[i]["stockData"][a]["normalPrice"] = returnPrice;
                                                                  //         returnProducts[i]["stockData"][a]["price"] = returnPrice;
                                                                  //         returnProducts[i]["stockData"][a]["totalAmount"] = returnProducts[i]["stockData"][a]["price"] * returnProducts[i]["stockData"][a]["qty"];

                                                                  //         if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                  //           for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                  //             if (stockByBrandDel[b]["brandOwnerSyskey"] == returnProducts[i]["brandOwnerSyskey"]) {
                                                                  //               for (var c = 0; c < stockByBrandDel[b]["stockReturnData"].length; c++) {
                                                                  //                 if (stockByBrandDel[b]["stockReturnData"][c]["stockCode"] == returnProducts[i]["stockData"][a]["stockCode"]) {
                                                                  //                   stockByBrandDel[b]["stockReturnData"][c]["normalPrice"] = returnProducts[i]["stockData"][a]["normalPrice"];
                                                                  //                   stockByBrandDel[b]["stockReturnData"][c]["price"] = returnProducts[i]["stockData"][a]["price"];
                                                                  //                   stockByBrandDel[b]["stockReturnData"][c]["totalAmount"] = returnProducts[i]["stockData"][a]["totalAmount"];
                                                                  //                 }
                                                                  //               }
                                                                  //             }
                                                                  //           }
                                                                  //         } else {
                                                                  //           for (var b = 0; b < getdeliverylist.length; b++) {
                                                                  //             if (getdeliverylist[b]["brandOwnerSyskey"] == returnProducts[i]["brandOwnerSyskey"]) {
                                                                  //               for (var c = 0; c < getdeliverylist[b]["stockReturnData"].length; c++) {
                                                                  //                 if (getdeliverylist[b]["stockReturnData"][c]["stockCode"] == returnProducts[i]["stockData"][a]["stockCode"]) {
                                                                  //                   getdeliverylist[b]["stockReturnData"][c]["normalPrice"] = returnProducts[i]["stockData"][a]["normalPrice"];
                                                                  //                   getdeliverylist[b]["stockReturnData"][c]["price"] = returnProducts[i]["stockData"][a]["price"];
                                                                  //                   getdeliverylist[b]["stockReturnData"][c]["totalAmount"] = returnProducts[i]["stockData"][a]["totalAmount"];
                                                                  //                 }
                                                                  //               }
                                                                  //             }
                                                                  //           }
                                                                  //         }
                                                                  //       });
                                                                  //     });
                                                                  //   },
                                                                  //   child: Column(
                                                                  //     mainAxisAlignment: MainAxisAlignment.end,
                                                                  //     crossAxisAlignment: CrossAxisAlignment.end,
                                                                  //     children: <Widget>[
                                                                  //       Text("${returnProducts[i]["stockData"][a]["price"].toInt()}"),
                                                                  //       Container(
                                                                  //         height: 1.5,
                                                                  //         width: 50,
                                                                  //         color: Colors.red,
                                                                  //       )
                                                                  //     ],
                                                                  //   )),
                                                                    Text("${returnProducts[i]["stockData"][a]["normalPrice"].toInt()}"),
                                                                    Padding(
                                                                          padding: const EdgeInsets.only(right: 15),
                                                                          child: Text(
                                                                            returnProducts[i]["stockData"][a]["totalAmount"].toString().substring(returnProducts[i]["stockData"][a]["totalAmount"].toString().lastIndexOf("."), returnProducts[i]["stockData"][a]["totalAmount"].toString().length).length > 3 ?
                                                                            "${returnProducts[i]["stockData"][a]["totalAmount"].toStringAsFixed(2)}" :
                                                                            double.parse(returnProducts[i]["stockData"][a]["totalAmount"].toString().substring(returnProducts[i]["stockData"][a]["totalAmount"].toString().lastIndexOf("."), returnProducts[i]["stockData"][a]["totalAmount"].toString().length)) == 0.0 ?
                                                                              "${returnProducts[i]["stockData"][a]["totalAmount"].toInt()}" :
                                                                              "${returnProducts[i]["stockData"][a]["totalAmount"]}"),
                                                                        ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(top: 5, right: 15),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: <Widget>[
                                                                  Text("Max Qty (${returnProducts[i]["stockData"][a]["returnQty"]})",
                                                                  style: TextStyle(fontSize: 12, color: Color(0xffef5350)),),
                                                                  Text(
                                                                    returnProducts[i]["stockData"][a]["invoiceDate"] == "" || returnProducts[i]["stockData"][a]["invoiceDate"] == null ? "" :
                                                                    "${returnProducts[i]["stockData"][a]["invoiceDate"].substring(6, 8)}/${returnProducts[i]["stockData"][a]["invoiceDate"].substring(4, 6)}/${returnProducts[i]["stockData"][a]["invoiceDate"].substring(0, 4)}",
                                                                  style: TextStyle(fontSize: 12, color: Color(0xffef5350)),),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(height: 10)
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
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 0),
                      child: GestureDetector(
                        onTap: () async {
                          multiDisCalculation();
                          // testingDialog(context);
                          // final SharedPreferences preferences = await SharedPreferences.getInstance();
                          // List multiGiftList = json.decode(preferences.getString("multiGiftList"));
                          // List multiStockList = json.decode(preferences.getString("multiStockList"));
                          // showMultiGiftDialog(multiGiftList, multiStockList, context);
                        },
                        child: Card(
                          color: Color(0xffef5350),
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                                child: Text(
                              "Calculate",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                        ),
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: GestureDetector(
                        onTap: () {
                          ontapDeliveryOrder();
                        },
                        child: Card(
                          color: Color(0xffef5350),
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                                child: Text(
                              "Next",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );

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
      child: Scaffold(
        key: _scaffoldkey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          title: Text("Order Detail"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: orderdetailStatus == null
                  ? null
                  : () async {
                      itemm.clear();
                      returnItem.clear();
                      returnStockData = [];
                      // orderPrice.clear();
                      // returnPrice.clear();
                      orderProducts.clear();
                      returnProducts.clear();
                      stockData.clear();
                      brandOwnerName = [];
                      stockDataOrder = [];
                      stockReturnData = [];
                      final SharedPreferences preferences =
                          await SharedPreferences.getInstance();

                      if (orderdetailStatus == "COMPLETED" ||
                          widget.isSaleOrderLessRouteShop == "true") {
                        orderDetailData = [];
                        // Navigator.pop(context);
                        stockData.clear();
                        brandOwnerName.clear();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NavigationBar(
                                    "",
                                    widget.mcdCheck,
                                    widget.userType,
                                    preferences.getString("DateTime"))));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderDetail(
                                      shopName:
                                          preferences.getString('shopname'),
                                      shopNameMm:
                                          preferences.getString('shopnamemm'),
                                      address: preferences.getString('address'),
                                      phone: preferences.getString('phNo'),
                                      mcdCheck: widget.mcdCheck,
                                      userType: widget.userType,
                                    )));
                      }
                    }),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 17, right: 17, top: 20),
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
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: <Widget>[
                    //     Text("Order No. 1"),
                    //     Text("Brand 1"),
                    //   ],
                    // ),
                    // SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(widget.orderDate == ''
                            ? ""
                            : "Order Date : ${widget.orderDate}", style: TextStyle(fontSize: 13),),
                        Text(
                            "Deli Date : ${widget.deliveryDate.substring(6, 8)}/${widget.deliveryDate.substring(4, 6)}/${widget.deliveryDate.substring(0, 4)}", style: TextStyle(fontSize: 13),),
                      ],
                    ),
                    // SizedBox(height: 10),
                    Divider(color: Colors.grey),
                  ],
                ),
              ),
              loading == true ? loadProgress : body
            ],
          ),
        ),
      ),
    );
  }

  
  Future _showReturnPriceDialog() async {
    await showDialog<String>(
      context: context,
      child: new _SystemPadding(child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                autofocus: true,
                decoration: InputDecoration(
                  enabledBorder:
                      UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.red),
                  ),
                  focusedBorder:
                      UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.red),
                  ),
                  border:
                      UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.red),
                  ),
                ),
                cursorColor: Colors.red,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                controller: returnPriceCtrl,
                onChanged: (value) {
                  value = returnPriceCtrl.text;
                  
                },
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('Save', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                if(returnPriceCtrl.text == "" || returnPriceCtrl.text == null) {
                  returnPrice = 0.0;
                }else {
                  returnPrice = double.parse(returnPriceCtrl.text);
                }
                Navigator.pop(context);
              })
        ],
      ),),
    );
  }


  
  // Future<void> getVolDisCalculationDialog(var param, String title, var discountStock) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return WillPopScope(
  //         onWillPop: () async => false,
  //         child: AlertDialog(
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(0.0))),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: <Widget>[
  //               Padding(
  //                 padding: const EdgeInsets.only(top: 14),
  //                 child: Text(
  //                   "$title",
  //                   style: TextStyle(fontWeight: FontWeight.w300),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           actions: <Widget>[
  //             FlatButton(
  //               child: Text(
  //                 'Try again',
  //                 style: TextStyle(color: Color(0xffe53935)),
  //               ),
  //               onPressed: () async {
  //                 Navigator.pop(context);
  //                 reGetVolDisCalculationFunction(param, discountStock);
  //               },
  //             ),
  //             SizedBox(
  //               width: 50,
  //             ),
  //             FlatButton(
  //               child:
  //                   Text('Cancel', style: TextStyle(color: Color(0xffe53935))),
  //               onPressed: () async {
  //                 Navigator.pop(context);
  //               },
  //             ),
  //             SizedBox(
  //               width: 10,
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void reGetVolDisCalculationFunction(param, discountStock) {
    _handleSubmit(context);
    getVolDisCalculation(param, discountStock, context, false).then((getVolDisCalculationValue) {
      Navigator.pop(context);
      if(getVolDisCalculationValue == "success") {
        print("4444444444444444444>>>>>>");
      }else if(getVolDisCalculationValue == "fail") {
        snackbarmethod("FAIL!");
      }else {
        // getVolDisCalculationDialog(param, getVolDisCalculationValue.toString(), discountStock);
      }
    });
  }


  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  Future<void> _handleSubmit(BuildContext context) async {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader);
    } catch (error) {
      print(error);
    }
  }

  Future<void> toInvoice() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0))),
            // title: Text(""),
            content: Container(
              height: 33,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10),
                  Text("Do you want to Invoice?",
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.cancel, color: Color(0xffe53935)),
                    Text('No', style: TextStyle(color: Color(0xffe53935))),
                  ],
                ),
                onPressed: () async {
                  final SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  orderDetailData = [];
                  itemm.clear();
                  returnItem.clear();
                  returnStockData = [];
                  // orderPrice.clear();
                  // returnPrice.clear();
                  orderProducts.clear();
                  returnProducts.clear();
                  stockData.clear();
                  brandOwnerName = [];
                  stockDataOrder = [];
                  stockReturnData = [];
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return NavigationBar(orgId, widget.mcdCheck,
                        widget.userType, preferences.getString("DateTime"));
                  }));
                },
              ),
              SizedBox(
                width: 50,
              ),
              FlatButton(
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.check,
                      color: Color(0xffe53935),
                    ),
                    Text(
                      'Yes',
                      style: TextStyle(color: Color(0xffe53935)),
                    ),
                  ],
                ),
                onPressed: () async {
                  toInvoiceSettask();
                },
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  void toInvoiceSettask() {
    orderDetailData = [];
    itemm.clear();
    returnItem.clear();
    stockData.clear();
    brandOwnerName = [];
    stockDataOrder = [];
    stockReturnData = [];

    setTask(merchandizingStatus, "COMPLETED", "PENDING").then((setTask2) {
      if (setTask2 == "success") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InVoice(
                      mcdCheck: widget.mcdCheck,
                      userType: widget.userType,
                      shopName: widget.shopName,
                      shopNameMm: widget.shopNameMm,
                      address: widget.address,
                      orderStock: orderProducts,
                      returnStock: returnProducts,
                      phone: widget.phone,
                    )));
      } else if (setTask2 == "fail") {
        Navigator.pop(context);
        snackbarmethod("$setTask2");
      } else {
        toinvoicesettaskDialog(setTask2.toString());
      }
    });
  }

  Future<void> toinvoicesettaskDialog(String title) async {
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
                  toInvoiceSettask();
                },
              ),
              SizedBox(
                width: 50,
              ),
              FlatButton(
                child:
                    Text('Cancel', style: TextStyle(color: Color(0xffe53935))),
                onPressed: () async {
                  Navigator.pop(context);
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

  

  Future<void> multiDisCalculation() async {
    _handleSubmit(context);
    datetime();
    var param;
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
    getSysKey.then((val) {
      String headerSyskey = "";
      String ruleNumber = "";
      String rulePriority = "";
      List allMultiList = [];
      List multiStockList = [];
      
      List multiListforCheck = [];

      if(listtoCheckMultiDis.length == 0) {
        setState(() {
          multiDisCalculate = true;
          Navigator.pop(context);
        });
      } else {
      if(listtoCheckMultiDis.length != 0)
      for(var i = 0; i < orderProducts.length; i++) {
        for(var a = 0; a < orderProducts[i]["stockData"].length; a++) {
          var check = false;
          for(var b = 0; b < listtoCheckMultiDis.length; b++) {
            if(orderProducts[i]["stockData"][a]["stockSyskey"] == listtoCheckMultiDis[b]["PromoItemSyskey"]) {
              check = true;
            }
          }

          if(check == true) {
            allMultiList.add(orderProducts[i]["stockData"][a]);
          }
        }
      }

      for(var a = 0; a < listtoCheckMultiDis.length; a++) {
        List multiStockListforCheck = [];
        List list = listtoCheckMultiDis.where((element) => element["HeaderSyskey"] == listtoCheckMultiDis[a]["HeaderSyskey"] && element["RuleNumber"] == listtoCheckMultiDis[a]["RuleNumber"] && element["RulePriority"] == listtoCheckMultiDis[a]["RulePriority"]).toList();

        for(var b = 0; b < list.length; b++) {
          multiStockListforCheck.add(list[b]["PromoItemSyskey"]);
        }

        if(multiListforCheck.length == 0) {
          multiListforCheck.add({
            "HeaderSyskey" : listtoCheckMultiDis[a]["HeaderSyskey"],
            "RuleNumber" : listtoCheckMultiDis[a]["RuleNumber"],
            "RulePriority" : listtoCheckMultiDis[a]["RulePriority"],
            "StockList" : multiStockListforCheck
          });
        } else {
          if(multiListforCheck.where((element) => element["HeaderSyskey"] == listtoCheckMultiDis[a]["HeaderSyskey"] && element["RuleNumber"] == listtoCheckMultiDis[a]["RuleNumber"] && element["RulePriority"] == listtoCheckMultiDis[a]["RulePriority"]).toList().length == 0) {
            multiListforCheck.add({
              "HeaderSyskey" : listtoCheckMultiDis[a]["HeaderSyskey"],
              "RuleNumber" : listtoCheckMultiDis[a]["RuleNumber"],
              "RulePriority" : listtoCheckMultiDis[a]["RulePriority"],
              "StockList" : multiStockListforCheck
            });
          }
        }
      }

      if(allMultiList.length == 0) {
        setState(() {
          multiDisCalculate = true;
          Navigator.pop(context);
        });
      } else {
        List itemInfoList = [];
        for(var a = 0; a < multiListforCheck.length; a++) {
          for(var b = 0; b < multiListforCheck[a]["StockList"].length; b++) {
            for(var c = 0; c < allMultiList.length; c++) {
              if(itemInfoList.where((element) => element["itemSyskey"] == allMultiList[c]["stockSyskey"]).toList().length == 0) {
              if(multiListforCheck[a]["StockList"][b].toString() == allMultiList[c]["stockSyskey"]) {
                itemInfoList.add({
                  "itemSyskey" : allMultiList[c]["stockSyskey"],
                  "itemDesc" : allMultiList[c]["stockName"],
                  "itemAmount": allMultiList[c]["normalPrice"],
                  "itemTotalAmount": allMultiList[c]["totalAmount"],
                  "itemQty": allMultiList[c]["qty"].toInt(),
                });
              }
              }

              if(c == allMultiList.length - 1) {
                if(b == multiListforCheck[a]["StockList"].length-1) {
                  if(a == multiListforCheck.length-1) {
                    param = jsonEncode({
                      "itemInfoList" : itemInfoList,
                      "shopSyskey" : "${val[0]["shopsyskey"]}",
                      "date" : "$date"
                    });

                    multiDiscountCalculation(param, orderProducts[0]["stockData"], context).then((value) {
                      Navigator.pop(context);
                      if(value == "success") {
                        setState(() {
                          for(var j = 0; j < orderProducts.length; j++) {
                            if(orderProducts[j]["brandOwnerSyskey"] == newStockList[0]["brandOwnerSyskey"]) {
                              orderProducts[j]["stockData"] = newStockList;
                            }
                          }
                          multiDisCalculate = true;
                        });
                      } else if(value == "fail") {
                        snackbarmethod("FAIL!");
                      } else {
                      }
                    });
                  }
                }
              }
            }
          }
        }
      }
      }

      
    });
  }

  Future<void> ontapDeliveryOrder() async {
    print(orderProducts);
    double orderTotal = 0.0;
    double returnTotal = 0.0;
    double resultTotal = 0;
    List orderPriceList = [];
    for (var i = 0; i < orderProducts.length; i++) {
      for (var a = 0; a < orderProducts[i]["stockData"].length; a++) {
        orderPriceList.add(orderProducts[i]["stockData"][a]["totalAmount"]);
      }
    }

    for (var i = 0; i < orderPriceList.length; i++) {
      orderTotal = orderTotal + orderPriceList[i];
    }

    List returnPriceList = [];
    for (var i = 0; i < returnProducts.length; i++) {
      for (var a = 0; a < returnProducts[i]["stockData"].length; a++) {
        returnPriceList.add(returnProducts[i]["stockData"][a]["qty"] * returnProducts[i]["stockData"][a]["normalPrice"]);
      }
    }

    for (var i = 0; i < returnPriceList.length; i++) {
      returnTotal = returnTotal + returnPriceList[i];
    }
    resultTotal = (orderTotal * (1-(discountPercent / 100))) - returnTotal.toDouble();

    bool loading = false;

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setString("DeliveryDate", widget.orderDate);

    print("3-> $returnList");
    print("44->$getdeliverylist");

    if (widget.orderDeleted.toString() == "[]") {
      setState(() {
        orderList = orderList;
      });
    } else {
      setState(() {
        orderList = widget.orderDeleted;
      });
    }

    if (widget.returnDeleted.toString() == "[]") {
      setState(() {
        returnList = returnList;
      });
    } else {
      setState(() {
        returnList = widget.returnDeleted;
      });
    }

    for (var i = 0; i < orderList.length; i++) {
      for (var a = 0; a < getdeliverylist.length; a++) {
        getdeliverylist[a]["stockData"].add(orderList[i]);
      }
    }
    for (var i = 0; i < returnList.length; i++) {
      for (var a = 0; a < getdeliverylist.length; a++) {
        getdeliverylist[a]["stockReturnData"].add(returnList[i]);
      }
    }

    for (var v = 0; v < orderProducts.length; v++) {
      orderProducts[v]["stockData"] = orderProducts[v]["stockData"]
          .where((element) => element["recordStatus"] != 4)
          .toList();
    }

    for (var v = 0; v < returnProducts.length; v++) {
      returnProducts[v]["stockData"] = returnProducts[v]["stockData"]
          .where((element) => element["recordStatus"] != 4)
          .toList();
    }

    for (var v = 0; v < getdeliverylist.length; v++) {
      getdeliverylist[v]["totalamount"] = resultTotal;
      getdeliverylist[v]["orderTotalAmount"] = orderTotal;
      getdeliverylist[v]["returnTotalAmount"] = returnTotal;
      getdeliverylist[v]["orderDiscountPercent"] = discountPercent;
      getdeliverylist[v]["returnDiscountPercent"] = 0.0;
      getdeliverylist[v]["orderDiscountAmount"] =
          orderTotal * (discountPercent / 100);
      getdeliverylist[v]["returnDiscountAmount"] = 0.0;
      getdeliverylist[v]["payment1"] = 0.0;
      getdeliverylist[v]["payment2"] = 0.0;
      getdeliverylist[v]["cashamount"] = 0.0;
      getdeliverylist[v]["creditAmount"] = 0.0;
      getdeliverylist[v]["promotionList"] = [];
    }

    print("1 ==> $getdeliverylist");

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      if (orderdetailStatus == "COMPLETED") {
        // print("2 ==> $getdeliverylist");
        setState(() {
          loading = true;
        });
        if (loading == true) {
          _handleSubmit(context);
        }
        for(var a = 0; a < getdeliverylist.length;a++){
          // print("Order detail data page list" + getdeliverylist[a].toString());

          for(var b = 0; b < getdeliverylist[a]["stockData"].length; b++) {
            print("StockData => "+ getdeliverylist[a]["stockData"][b].toString());
            print("Gift List ==> " + getdeliverylist[a]["stockData"][b]["promotionStockList"].toString());
          }

          for(var b = 0; b < getdeliverylist[a]["stockReturnData"].length; b++) {
            print("stockReturnData => "+ getdeliverylist[a]["stockReturnData"][b].toString());
          }
        }
        var getSysKey =
            helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
        getSysKey.then((val) {
          print("3 ==> $getdeliverylist");
          updateSaleOrder(resultTotal, val[0]["shopcode"], 0.0, 0.0)
              .then((updateSaleOrder) {
            if (updateSaleOrder == "success") {
              setState(() {
                loading = false;
              });
              Navigator.pop(context);
              snackbarmethod1("SUCCESS");
              Future.delayed(Duration(seconds: 1), () {
                toInvoice();
              });
            } else if (updateSaleOrder == "fail") {
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
              deliveryOrderDialog(updateSaleOrder.toString());
            }
          });
        });
      } else {
        var getSysKey =
            helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));

        _handleSubmit(context);

        for (var v = 0; v < stockByBrandDel.length; v++) {
          for (var k = 0; k < stockByBrandDel[v]["stockData"].length; k++) {
            for (var a = 0; a < orderProducts.length; a++) {
              for (var b = 0; b < orderProducts[a]["stockData"].length; b++) {
                if (stockByBrandDel[v]["stockData"][k]["stockCode"] ==
                    orderProducts[a]["stockData"][b]["stockCode"]) {
                  stockByBrandDel[v]["stockData"][k]["qty"] =
                      orderProducts[a]["stockData"][b]["qty"];
                  stockByBrandDel[v]["stockData"][k]["totalAmount"] =
                      orderPriceList[b];
                }
              }
            }
          }
        }
        print("111111111111111111");
        for (var v = 0; v < stockByBrandDel.length; v++) {
          for (var k = 0;
              k < stockByBrandDel[v]["stockReturnData"].length;
              k++) {
            for (var a = 0; a < returnProducts.length; a++) {
              for (var b = 0; b < returnProducts[a]["stockData"].length; b++) {
                if (stockByBrandDel[v]["stockReturnData"][k]["stockCode"] ==
                    returnProducts[a]["stockData"][b]["stockCode"]) {
                  stockByBrandDel[v]["stockReturnData"][k]["qty"] =
                      returnProducts[a]["stockData"][b]["qty"];
                  stockByBrandDel[v]["stockReturnData"][k]["totalAmount"] =
                      returnPriceList[b];
                  stockByBrandDel[v]["stockReturnData"][k]["price"] =
                      returnProducts[a]["stockData"][b]["price"];
                }
              }
            }
          }
        }
        resultTotal = (orderTotal * (1-(discountPercent / 100))) - returnTotal.toDouble();
        
        for (var v = 0; v < stockByBrandDel.length; v++) {
          stockByBrandDel[v]["totalamount"] = resultTotal;
          stockByBrandDel[v]["orderTotalAmount"] = orderTotal.toDouble();
          stockByBrandDel[v]["returnTotalAmount"] = returnTotal.toDouble();
          stockByBrandDel[v]["orderDiscountPercent"] = discountPercent;
          stockByBrandDel[v]["returnDiscountPercent"] = 0.0;
          stockByBrandDel[v]["orderDiscountAmount"] =
              orderTotal * (discountPercent / 100);
          stockByBrandDel[v]["returnDiscountAmount"] =
              0.0;
        }
        for (var i = 0; i < orderList.length; i++) {
          for (var a = 0; a < stockByBrandDel.length; a++) {
            if (widget.isSaleOrderLessRouteShop != "true") {
              stockByBrandDel[a]["stockData"].add(orderList[i]);
            }
          }
        }

        for (var i = 0; i < returnList.length; i++) {
          for (var a = 0; a < stockByBrandDel.length; a++) {
            if (widget.isSaleOrderLessRouteShop != "true") {
              stockByBrandDel[a]["stockReturnData"].add(returnList[i]);
            }
          }
        }

        print(stockByBrandDel);
        print("/////////////////");

        for (var v = 0; v < stockByBrandDel.length; v++) {
          for(var k = 0; k < stockByBrandDel[v]["stockData"].length; k++) {
            print(stockByBrandDel[v]["stockData"][k]);
            // for(var l=0; l < stockByBrandDel[v]["stockData"][k]["promotionStockList"].length; l++) {
            //   print(stockByBrandDel[v]["stockData"][k]["promotionStockList"][l]);
            // }
          }
          for (var k = 0; k < stockByBrandDel[v]["stockReturnData"].length; k++) {
            print(stockByBrandDel[v]["stockReturnData"][k]);
          }
        }

        getSysKey.then((val) {
          print("sssss");
          deliveryOrder(resultTotal, val[0]["shopcode"])
              .then((deliveryOrderValue) {
            if (deliveryOrderValue == 'success') {
              deliverySetTask();
            } else if (deliveryOrderValue == "fail") {
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
              deliveryOrderDialog(deliveryOrderValue.toString());
            }
          });
        });
      }
    } else {
      snackbarmethod("Check your connection!");
    }
  }

  Future<void> deliverySetTask() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    setTask(merchandizingStatus, "COMPLETED", "INCOMPLETE")
        .then((setTaskValue) {
      if (setTaskValue == "success") {
        setState(() {
          loading = false;
        });
        preferences.setString("subTotal", subTotal.toString());
        preferences.setString("returnTotal", totalCountR.toString());
        Navigator.pop(context);
        snackbarmethod1("SUCCESS");
        Future.delayed(Duration(seconds: 1), () {
          toInvoice();
        });
      } else if (setTaskValue == "fail") {
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
        snackbarmethod("$setTaskValue");
      } else {
        setState(() {
          loading = false;
        });
        deliveryOrdersetTaskDialog(setTaskValue.toString());
      }
    });
  }

  Future<void> deliveryOrdersetTaskDialog(String title) {
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
                  ontapDeliveryOrder();
                },
              ),
              SizedBox(
                width: 50,
              ),
              FlatButton(
                child:
                    Text('Cancel', style: TextStyle(color: Color(0xffe53935))),
                onPressed: () async {
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

  Future<void> deliveryOrderDialog(String title) async {
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
                  ontapDeliveryOrder();
                },
              ),
              SizedBox(
                width: 50,
              ),
              FlatButton(
                child:
                    Text('Cancel', style: TextStyle(color: Color(0xffe53935))),
                onPressed: () async {
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

  // Future<void> multiDisCalculateDialog(String title) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return WillPopScope(
  //         onWillPop: () async => false,
  //         child: AlertDialog(
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(0.0))),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: <Widget>[
  //               Padding(
  //                 padding: const EdgeInsets.only(top: 14),
  //                 child: Text(
  //                   "$title",
  //                   style: TextStyle(fontWeight: FontWeight.w300),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           actions: <Widget>[
  //             FlatButton(
  //               child: Text(
  //                 'Try again',
  //                 style: TextStyle(color: Color(0xffe53935)),
  //               ),
  //               onPressed: () async {
  //                 Navigator.pop(context);
  //                 multiDisCalculation();
  //               },
  //             ),
  //             SizedBox(
  //               width: 50,
  //             ),
  //             FlatButton(
  //               child:
  //                   Text('Cancel', style: TextStyle(color: Color(0xffe53935))),
  //               onPressed: () async {
  //                 Navigator.pop(context);
  //               },
  //             ),
  //             SizedBox(
  //               width: 10,
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}


class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.viewPadding,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
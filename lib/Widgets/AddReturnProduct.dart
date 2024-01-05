import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_2/OrderDetailData.dart';
import 'package:delivery_2/service.dart/AllService.dart';
import 'ShowImage.dart';

class AddReturnProduct extends StatefulWidget {
  final String shopName;
  final String shopNameMm;
  final String address;
  final String shopSyskey;
  final String date;
  final String mcdCheck;
  final String userType;
  final String title;
  final String phone;
  final List stockList1;
  final List returnList;
  final List orderDeleted;
  final List returnDeleted;
  final String isSaleOrderLessRouteShop;
  AddReturnProduct(
      {Key key,
      @required this.shopName,
      @required this.shopNameMm,
      @required this.address,
      @required this.phone,
      this.shopSyskey,
      this.date,
      this.mcdCheck,
      this.userType,
      this.title,
      this.stockList1,
      this.returnList,
      @required this.orderDeleted,
      @required this.returnDeleted,
      @required this.isSaleOrderLessRouteShop})
      : super(key: key);
  @override
  _AddReturnProductState createState() => _AddReturnProductState();
}

class _AddReturnProductState extends State<AddReturnProduct> {
  List newList = [];
  String ownerName;
  List originalList = [];
  List originalQty = [];
  List originalStockList = [];

  @override
  void initState() {
    super.initState();
    rebuildList();
    getImage();
  }

  Future<void> getImage() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    stockImage = json.decode(preferences.getString("StockImageList"));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          title: Text("Add Return"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () async {
                datetime();
                for (var i = 0; i < addReturnProductList.length; i++) {
                  if (getdeliverylist == [] || getdeliverylist.length == 0) {
                    // print(stockByBrandDel.length);
                    for (var a = 0; a < stockByBrandDel.length; a++) {
                      if (addReturnProductList[i]["createddate"] ==
                          stockByBrandDel[a]["createddate"]) {
                        for (var i1 = 0;
                            i1 < addReturnProductList[i]["brandOwnerList"].length;
                            i1++) {
                          if (addReturnProductList[i]["brandOwnerList"][i1]
                                  ["brandOwnerSyskey"] ==
                              stockByBrandDel[a]["brandOwnerSyskey"]) {
                            List checkList = addReturnProductList[i]["brandOwnerList"]
                                    [i1]["stockData"]
                                .where((element) => element["check"] == true)
                                .toList();
                            // print(stockByBrandDel[a]["stockReturnData"]);
                            for (var b = 0;
                                b <
                                    stockByBrandDel[a]["stockReturnData"]
                                        .length;
                                b++) {
                              for (var c = 0; c < checkList.length; c++) {
                                if (stockByBrandDel[a]["stockReturnData"][b]["stockCode"] == checkList[c]["stockCode"] &&
                                stockByBrandDel[a]["stockReturnData"][b]["invoiceSyskey"] == checkList[c]["syskey"]) {
                                  stockByBrandDel[a]["stockReturnData"][b]["qty"] = stockByBrandDel[a]
                                          ["stockReturnData"][b]["qty"] -
                                      checkList[c]["qty"];

                                  stockByBrandDel[a]["stockReturnData"][b]["totalAmount"] = double.parse("${stockByBrandDel[a]["stockReturnData"][b]["qty"] * stockByBrandDel[a]["stockReturnData"][b]["normalPrice"]}");
                                }
                              }
                            }
                          }
                        }
                      }
                      stockByBrandDel[a]["stockReturnData"].removeWhere(
                          (element) =>
                              element["qty"] == 0.0 || element["qty"] < 0);
                      // print(stockByBrandDel[a]["stockReturnData"]);
                    }
                  } else {
                    for (var a = 0; a < getdeliverylist.length; a++) {
                      if (addReturnProductList[i]["createddate"] ==
                          getdeliverylist[a]["createddate"]) {
                        for (var i1 = 0;
                            i1 < addReturnProductList[i]["brandOwnerList"].length;
                            i1++) {
                          if (addReturnProductList[i]["brandOwnerList"][i1]
                                  ["brandOwnerSyskey"] ==
                              getdeliverylist[a]["brandOwnerSyskey"]) {
                            List checkList = addReturnProductList[i]["brandOwnerList"]
                                    [i1]["stockData"]
                                .where((element) => element["check"] == true)
                                .toList();
                            for (var b = 0;
                                b <
                                    getdeliverylist[a]["stockReturnData"]
                                        .length;
                                b++) {
                              for (var c = 0; c < checkList.length; c++) {
                                if (getdeliverylist[a]["stockReturnData"][b]["stockCode"] == checkList[c]["stockCode"] && 
                                getdeliverylist[a]["stockReturnData"][b]["invoiceSyskey"] == checkList[c]["syskey"]) {
                                  getdeliverylist[a]["stockReturnData"][b]
                                      ["qty"] = getdeliverylist[a]
                                          ["stockReturnData"][b]["qty"] -
                                      checkList[c]["qty"];

                                  getdeliverylist[a]["stockReturnData"][b]["totalAmount"] = double.parse("${getdeliverylist[a]["stockReturnData"][b]["qty"] * getdeliverylist[a]["stockReturnData"][b]["normalPrice"]}");
                                }
                              }
                            }
                          }
                        }
                      }
                      getdeliverylist[a]["stockReturnData"].removeWhere(
                          (element) =>
                              element["qty"] == 0.0 || element["qty"] < 0);
                    }
                  }
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderDetailData(
                              shopName: widget.shopName,
                              shopNameMm: widget.shopNameMm,
                              address: widget.address,
                              shopSyskey: widget.shopSyskey,
                              orderDate: widget.date,
                              deliveryDate: date,
                              mcdCheck: widget.mcdCheck,
                              userType: widget.userType,
                              ownerName: ownerName,
                              phone: widget.phone,
                              stockList: widget.returnList,
                              returnList: originalList,
                              back: "WithBackButton",
                              orderDeleted: widget.orderDeleted,
                              returnDeleted: widget.returnDeleted,
                              rtn: "FromReturn",
                              isSaleOrderLessRouteShop:
                                  widget.isSaleOrderLessRouteShop,
                            )));
              }),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height - 160,
                child: ListView(
                  children: <Widget>[
                    for (var a = 0; a < addReturnProductList.length; a++)
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  addReturnProductList[a]["visible"] =
                                      !addReturnProductList[a]["visible"];
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Color(0xffe53935)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Invoice Date - ${addReturnProductList[a]["invoiceDate"].toString().substring(6, 8)}/${addReturnProductList[a]["invoiceDate"].toString().substring(4, 6)}/${addReturnProductList[a]["invoiceDate"].toString().substring(0, 4)}",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                      Icon(
                                        addReturnProductList[a]["visible"]
                                            ? Icons.keyboard_arrow_down
                                            : Icons.keyboard_arrow_right,
                                        color: Colors.white,
                                        size: 25,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: addReturnProductList[a]["visible"],
                            child: Column(
                              children: <Widget>[
                                for (var b = 0;
                                    b <
                                        addReturnProductList[a]["brandOwnerList"]
                                            .length;
                                    b++)
                                  Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              addReturnProductList[a]
                                                          ["brandOwnerList"][b]
                                                      ["visible"] =
                                                  !addReturnProductList[a]
                                                          ["brandOwnerList"][b]
                                                      ["visible"];
                                              print(addReturnProductList[a]
                                                  ["brandOwnerList"][b]["visible"]);
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Color(0xffe53935)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "${addReturnProductList[a]["brandOwnerList"][b]["brandOwnerName"]}",
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.white),
                                                  ),
                                                  Icon(
                                                    addReturnProductList[a]
                                                                ["brandOwnerList"][b]
                                                            ["visible"]
                                                        ? Icons
                                                            .keyboard_arrow_down
                                                        : Icons
                                                            .keyboard_arrow_right,
                                                    color: Colors.white,
                                                    size: 25,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                          visible: addReturnProductList[a]
                                              ["brandOwnerList"][b]["visible"],
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: addReturnProductList[a]
                                                          ["brandOwnerList"][b]
                                                      ["stockData"]
                                                  .length,
                                              itemBuilder: (context, c) {
                                                return Card(
                                                  child: Container(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 10),
                                                      child: ListTile(
                                                        leading: ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                              maxWidth: 64,
                                                              maxHeight: 80,
                                                            ),
                                                            child: Stack(
                                                              children: [
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
                                                                if(stockImage.where((element) => element["stockCode"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"]).toList().length != 0)
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ShowImage(image: CachedNetworkImage(imageUrl: "${domain.substring(0, domain.lastIndexOf("8084/"))}8084${stockImage.where((element) => element["stockCode"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"]).toList()[0]["image"]}"))));
                                                                  },
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl:
                                                                        "${domain.substring(0, domain.lastIndexOf("8084/"))}8084${stockImage.where((element) => element["stockCode"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"]).toList()[0]["image"]}",
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        title: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 13, top: 10),
                                                                  child: SizedBox(
                                                                    height: 24,
                                                                    width: 24,
                                                                    child: Checkbox(
                                                                      activeColor:
                                                                          Color(
                                                                              0xffe53935),
                                                                      value: addReturnProductList[a]["brandOwnerList"]
                                                                                  [b]["stockData"][c]["check"],
                                                                      onChanged:
                                                                          (val) async {
                                                                        final SharedPreferences
                                                                            preferences =
                                                                            await SharedPreferences
                                                                                .getInstance();
                                                                        setState(
                                                                            () {
                                                                          if(addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"] > 0) {
                                                                            
                                                                          
                                                                          addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["check"] = val;

                                                                          var check = "";

                                                                          if (addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]
                                                                                  [
                                                                                  "check"] ==
                                                                              true) {
                                                                            List
                                                                                sameBrandownerKey =
                                                                                [];
                                                                            if (widget.stockList1.length ==
                                                                                    0 ||
                                                                                widget.stockList1 ==
                                                                                    []) {
                                                                              print(
                                                                                  "no stock to add");
                                                                              newList
                                                                                  .add({
                                                                                "brandOwnerName":
                                                                                    addReturnProductList[a]["brandOwnerList"][b]["brandOwnerName"],
                                                                                "brandOwnerSyskey":
                                                                                    addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"],
                                                                                "visible":
                                                                                    true,
                                                                                "stockData":
                                                                                    [
                                                                                  {
                                                                                    "syskey": "0",
                                                                                    "recordStatus": 1,
                                                                                    "createdDate" : addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                    "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                    "stockCode": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"]}",
                                                                                    "stockName": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"]}",
                                                                                    "saleCurrCode": "MMK",
                                                                                    "stockSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]}",
                                                                                    "n1": "0",
                                                                                    "wareHouseSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"]}",
                                                                                    "binSyskey": "0",
                                                                                    "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                    "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                    "lvlSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"]}",
                                                                                    "lvlQty": 1.0,
                                                                                    "n8": 1.0,
                                                                                    "n9": 0.0,
                                                                                    "taxAmount": 0.0,
                                                                                    "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                    "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                    "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                    "taxCodeSK": "0",
                                                                                    "isTaxInclusice": 0,
                                                                                    "taxPercent": 0.0,
                                                                                    "brandOwnerSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]}",
                                                                                    "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                    "stockType": "RETURN"
                                                                                  }
                                                                                ]
                                                                              });

                                                                              print(stockByBrandDel.length);

                                                                              if (getdeliverylist.length !=
                                                                                  0) {
                                                                                var checkValue =
                                                                                    0;
                                                                                for (var l = 0;
                                                                                    l < getdeliverylist.length;
                                                                                    l++) {
                                                                                  if (getdeliverylist[l]["brandOwnerSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]) {
                                                                                    checkValue = 1;
                                                                                    var r = {
                                                                                      "stockCode": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"],
                                                                                      "stockName": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"],
                                                                                      "recordStatus": 1,
                                                                                      "saleCurrCode": "MMK",
                                                                                      "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                      "stockSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]}",
                                                                                      "n1": "0",
                                                                                      "wareHouseSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"],
                                                                                      "binSyskey": "0",
                                                                                      "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                      "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                      "lvlSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"],
                                                                                      "lvlQty": 0.0,
                                                                                      "n8": 0.0,
                                                                                      "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                      "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                      "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                      "n9": 0.0,
                                                                                      "taxAmount": 0.0,
                                                                                      "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                      "taxCodeSK": "0",
                                                                                      "isTaxInclusice": 0,
                                                                                      "taxPercent": 0.0,
                                                                                    };
                                                                                    getdeliverylist[l]["stockReturnData"].add(r);
                                                                                  }
                                                                                }
                                                                                if (checkValue ==
                                                                                    0) {
                                                                                  getdeliverylist.add({
                                                                                    "syskey": "0",
                                                                                    "autokey": "0",
                                                                                    "createddate": date,
                                                                                    "modifieddate": date,
                                                                                    "userid": preferences.getString("userId"),
                                                                                    "username": preferences.getString("userName"),
                                                                                    "saveStatus": 1,
                                                                                    "recordStatus": 1,
                                                                                    "syncStatus": 0,
                                                                                    "syncBatch": "",
                                                                                    "transType": "DeliveryOrder",
                                                                                    "docummentDate": date,
                                                                                    "brandOwnerCode": "001",
                                                                                    "brandOwnerName": addReturnProductList[a]["brandOwnerList"][b]["brandOwnerName"],
                                                                                    "brandOwnerSyskey": addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"],
                                                                                    "orderSyskey": "0",
                                                                                    "totalamount": 0.0,
                                                                                    "orderTotalAmount": 0.0,
                                                                                    "returnTotalAmount": 0.0,
                                                                                    "cashamount": 0.0,
                                                                                    "discountamount": 0.0,
                                                                                    "taxSyskey": "0",
                                                                                    "taxPercent": 0.0,
                                                                                    "taxAmount": 0.0,
                                                                                    "orderDiscountPercent": 0.0,
                                                                                    "returnDiscountPercent": 0.0,
                                                                                    "stockData": [],
                                                                                    "stockReturnData": [
                                                                                      {
                                                                                        "stockCode": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"],
                                                                                        "stockName": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"],
                                                                                        "recordStatus": 1,
                                                                                        "saleCurrCode": "MMK",
                                                                                        "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                        "stockSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]}",
                                                                                        "n1": "0",
                                                                                        "wareHouseSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"],
                                                                                        "binSyskey": "0",
                                                                                        "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                        "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                        "lvlSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"],
                                                                                        "lvlQty": 0.0,
                                                                                        "n8": 0.0,
                                                                                        "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                        "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                        "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                        "n9": 0.0,
                                                                                        "taxAmount": 0.0,
                                                                                        "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                        "taxCodeSK": "0",
                                                                                        "isTaxInclusice": 0,
                                                                                        "taxPercent": 0.0,
                                                                                      }
                                                                                    ]
                                                                                  });
                                                                                }
                                                                              } else {
                                                                                var checkValue =
                                                                                    0;
                                                                                for (var l = 0;
                                                                                    l < stockByBrandDel.length;
                                                                                    l++) {
                                                                                  if (stockByBrandDel[l]["brandOwnerSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]) {
                                                                                    checkValue = 1;
                                                                                    var r = {
                                                                                      "stockCode": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"],
                                                                                      "stockName": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"],
                                                                                      "recordStatus": 1,
                                                                                      "saleCurrCode": "MMK",
                                                                                      "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                      "stockSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]}",
                                                                                      "n1": "0",
                                                                                      "wareHouseSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"],
                                                                                      "binSyskey": "0",
                                                                                      "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                      "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                      "lvlSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"],
                                                                                      "lvlQty": 0.0,
                                                                                      "n8": 0.0,
                                                                                      "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                      "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                      "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                      "n9": 0.0,
                                                                                      "taxAmount": 0.0,
                                                                                      "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                      "taxCodeSK": "0",
                                                                                      "isTaxInclusice": 0,
                                                                                      "taxPercent": 0.0,
                                                                                    };
                                                                                    stockByBrandDel[l]["stockReturnData"].add(r);
                                                                                  }
                                                                                }
                                                                                if (checkValue ==
                                                                                    0) {
                                                                                  stockByBrandDel.add({
                                                                                    "syskey": "0",
                                                                                    "autokey": "0",
                                                                                    "createddate": date,
                                                                                    "modifieddate": date,
                                                                                    "userid": preferences.getString("userId"),
                                                                                    "username": preferences.getString("userName"),
                                                                                    "saveStatus": 1,
                                                                                    "recordStatus": 1,
                                                                                    "syncStatus": 0,
                                                                                    "syncBatch": "",
                                                                                    "transType": "DeliveryOrder",
                                                                                    "docummentDate": date,
                                                                                    "brandOwnerCode": "001",
                                                                                    "brandOwnerName": addReturnProductList[a]["brandOwnerList"][b]["brandOwnerName"],
                                                                                    "brandOwnerSyskey": addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"],
                                                                                    "orderSyskey": "0",
                                                                                    "totalamount": 0.0,
                                                                                    "orderTotalAmount": 0.0,
                                                                                    "returnTotalAmount": 0.0,
                                                                                    "cashamount": 0.0,
                                                                                    "discountamount": 0.0,
                                                                                    "taxSyskey": "0",
                                                                                    "taxPercent": 0.0,
                                                                                    "taxAmount": 0.0,
                                                                                    "orderDiscountPercent": 0.0,
                                                                                    "returnDiscountPercent": 0.0,
                                                                                    "stockData": [],
                                                                                    "stockReturnData": [
                                                                                      {
                                                                                        "stockCode": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"],
                                                                                        "stockName": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"],
                                                                                        "recordStatus": 1,
                                                                                        "saleCurrCode": "MMK",
                                                                                        "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                        "stockSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]}",
                                                                                        "n1": "0",
                                                                                        "wareHouseSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"],
                                                                                        "binSyskey": "0",
                                                                                        "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                        "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                        "lvlSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"],
                                                                                        "lvlQty": 0.0,
                                                                                        "n8": 0.0,
                                                                                        "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                        "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                        "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                        "n9": 0.0,
                                                                                        "taxAmount": 0.0,
                                                                                        "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                        "taxCodeSK": "0",
                                                                                        "isTaxInclusice": 0,
                                                                                        "taxPercent": 0.0,
                                                                                      }
                                                                                    ]
                                                                                  });
                                                                                }
                                                                              }
                                                                            } else {
                                                                              sameBrandownerKey = newList
                                                                                  .where((element) => element["brandOwnerSyskey"].toString() == addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"].toString())
                                                                                  .toList();
                                                                              if (sameBrandownerKey.toString() ==
                                                                                  "[]") {
                                                                                print("add new brandname");
                                                                                newList.add({
                                                                                  "brandOwnerName": addReturnProductList[a]["brandOwnerList"][b]["brandOwnerName"],
                                                                                  "brandOwnerSyskey": addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"],
                                                                                  "visible": true,
                                                                                  "stockData": [
                                                                                    {
                                                                                      "syskey": "0",
                                                                                      "recordStatus": 1,
                                                                                      "createdDate" : addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                      "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                      "stockCode": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"]}",
                                                                                      "stockName": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"]}",
                                                                                      "saleCurrCode": "MMK",
                                                                                      "stockSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]}",
                                                                                      "n1": "0",
                                                                                      "wareHouseSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"]}",
                                                                                      "binSyskey": "0",
                                                                                      "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                      "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                      "lvlSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"]}",
                                                                                      "lvlQty": 1.0,
                                                                                      "n8": 1.0,
                                                                                      "n9": 0.0,
                                                                                      "taxAmount": 0.0,
                                                                                      "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                      "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                      "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                      "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                      "taxCodeSK": "0",
                                                                                      "isTaxInclusice": 0,
                                                                                      "taxPercent": 0.0,
                                                                                      "brandOwnerSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]}",
                                                                                      "stockType": "RETURN"
                                                                                    }
                                                                                  ]
                                                                                });

                                                                                if (getdeliverylist.length !=
                                                                                    0) {
                                                                                  var checkValue = 0;
                                                                                  for (var l = 0; l < getdeliverylist.length; l++) {
                                                                                    if (getdeliverylist[l]["brandOwnerSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]) {
                                                                                      checkValue = 1;
                                                                                      var r = {
                                                                                        "stockCode": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"],
                                                                                        "stockName": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"],
                                                                                        "recordStatus": 1,
                                                                                        "saleCurrCode": "MMK",
                                                                                        "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                        "stockSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]}",
                                                                                        "n1": "0",
                                                                                        "wareHouseSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"],
                                                                                        "binSyskey": "0",
                                                                                        "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                        "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                        "lvlSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"],
                                                                                        "lvlQty": 0.0,
                                                                                        "n8": 0.0,
                                                                                        "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                        "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                        "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                        "n9": 0.0,
                                                                                        "taxAmount": 0.0,
                                                                                        "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                        "taxCodeSK": "0",
                                                                                        "isTaxInclusice": 0,
                                                                                        "taxPercent": 0.0,
                                                                                      };
                                                                                      getdeliverylist[l]["stockReturnData"].add(r);
                                                                                    }
                                                                                  }
                                                                                  if (checkValue == 0) {
                                                                                    getdeliverylist.add({
                                                                                      "syskey": "0",
                                                                                      "autokey": "0",
                                                                                      "createddate": date,
                                                                                      "modifieddate": date,
                                                                                      "userid": preferences.getString("userId"),
                                                                                      "username": preferences.getString("userName"),
                                                                                      "saveStatus": 1,
                                                                                      "recordStatus": 1,
                                                                                      "syncStatus": 0,
                                                                                      "syncBatch": "",
                                                                                      "transType": "DeliveryOrder",
                                                                                      "docummentDate": date,
                                                                                      "brandOwnerCode": "001",
                                                                                      "brandOwnerName": addReturnProductList[a]["brandOwnerList"][b]["brandOwnerName"],
                                                                                      "brandOwnerSyskey": addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"],
                                                                                      "orderSyskey": "0",
                                                                                      "totalamount": 0.0,
                                                                                      "orderTotalAmount": 0.0,
                                                                                      "returnTotalAmount": 0.0,
                                                                                      "cashamount": 0.0,
                                                                                      "discountamount": 0.0,
                                                                                      "taxSyskey": "0",
                                                                                      "taxPercent": 0.0,
                                                                                      "taxAmount": 0.0,
                                                                                      "orderDiscountPercent": 0.0,
                                                                                      "returnDiscountPercent": 0.0,
                                                                                      "stockData": [],
                                                                                      "stockReturnData": [
                                                                                        {
                                                                                          "stockCode": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"],
                                                                                          "stockName": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"],
                                                                                          "recordStatus": 1,
                                                                                          "saleCurrCode": "MMK",
                                                                                          "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                          "stockSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]}",
                                                                                          "n1": "0",
                                                                                          "wareHouseSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"],
                                                                                          "binSyskey": "0",
                                                                                          "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                          "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                          "lvlSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"],
                                                                                          "lvlQty": 0.0,
                                                                                          "n8": 0.0,
                                                                                          "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                          "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                          "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                          "n9": 0.0,
                                                                                          "taxAmount": 0.0,
                                                                                          "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                          "taxCodeSK": "0",
                                                                                          "isTaxInclusice": 0,
                                                                                          "taxPercent": 0.0,
                                                                                        }
                                                                                      ]
                                                                                    });
                                                                                  }
                                                                                } else {
                                                                                  stockByBrandDel.add({
                                                                                    "syskey": "0",
                                                                                    "autokey": "0",
                                                                                    "createddate": date,
                                                                                    "modifieddate": date,
                                                                                    "userid": preferences.getString("userId"),
                                                                                    "username": preferences.getString("userName"),
                                                                                    "saveStatus": 1,
                                                                                    "recordStatus": 1,
                                                                                    "syncStatus": 0,
                                                                                    "syncBatch": "",
                                                                                    "transType": "DeliveryOrder",
                                                                                    "docummentDate": date,
                                                                                    "brandOwnerCode": "001",
                                                                                    "brandOwnerName": addReturnProductList[a]["brandOwnerList"][b]["brandOwnerName"],
                                                                                    "brandOwnerSyskey": addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"],
                                                                                    "orderSyskey": "0",
                                                                                    "totalamount": 0.0,
                                                                                    "orderTotalAmount": 0.0,
                                                                                    "returnTotalAmount": 0.0,
                                                                                    "cashamount": 0.0,
                                                                                    "discountamount": 0.0,
                                                                                    "taxSyskey": "0",
                                                                                    "taxPercent": 0.0,
                                                                                    "taxAmount": 0.0,
                                                                                    "orderDiscountPercent": 0.0,
                                                                                    "returnDiscountPercent": 0.0,
                                                                                    "stockData": [],
                                                                                    "stockReturnData": [
                                                                                      {
                                                                                        "stockCode": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"],
                                                                                        "stockName": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"],
                                                                                        "recordStatus": 1,
                                                                                        "saleCurrCode": "MMK",
                                                                                        "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                        "stockSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]}",
                                                                                        "n1": "0",
                                                                                        "wareHouseSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"],
                                                                                        "binSyskey": "0",
                                                                                        "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                        "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                        "lvlSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"],
                                                                                        "lvlQty": 0.0,
                                                                                        "n8": 0.0,
                                                                                        "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                        "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                        "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                        "n9": 0.0,
                                                                                        "taxAmount": 0.0,
                                                                                        "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                        "taxCodeSK": "0",
                                                                                        "isTaxInclusice": 0,
                                                                                        "taxPercent": 0.0,
                                                                                      }
                                                                                    ]
                                                                                  });
                                                                                }
                                                                              } else {
                                                                                print("add stock to the same brandname");
                                                                                for (var x = 0;
                                                                                    x < sameBrandownerKey.length;
                                                                                    x++) {
                                                                                  if (sameBrandownerKey[x]["stockData"].length == 0) {
                                                                                    print("same brandname but no stock");
                                                                                    var r = [{
                                                                                      "syskey": "0",
                                                                                      "recordStatus": 1,
                                                                                      "createdDate" : addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                      "stockCode": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"]}",
                                                                                      "stockName": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"]}",
                                                                                      "saleCurrCode": "MMK",
                                                                                      "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                      "stockSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]}",
                                                                                      "n1": "0",
                                                                                      "wareHouseSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"]}",
                                                                                      "binSyskey": "0",
                                                                                      "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                      "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                      "lvlSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"]}",
                                                                                      "lvlQty": 1.0,
                                                                                      "n8": 1.0,
                                                                                      "n9": 0.0,
                                                                                      "taxAmount": 0.0,
                                                                                      "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                      "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                      "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                      "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                      "taxCodeSK": "0",
                                                                                      "isTaxInclusice": 0,
                                                                                      "taxPercent": 0.0,
                                                                                      "brandOwnerSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]}",
                                                                                      "stockType": "RETURN"
                                                                                    }];
                                                                                    // Solving duplicate Stock Error
                                                                                    sameBrandownerKey[x]["stockData"] = sameBrandownerKey[x]["stockData"] + r;

                                                                                    if (getdeliverylist.length == 0) {
                                                                                      for (var j = 0; j < stockByBrandDel.length; j++) {
                                                                                        if (stockByBrandDel[j]["brandOwnerSyskey"].toString() == sameBrandownerKey[x]["brandOwnerSyskey"].toString()) {
                                                                                          stockByBrandDel[j]["stockReturnData"].add({
                                                                                            "stockCode": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"],
                                                                                            "stockName": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"],
                                                                                            "recordStatus": 1,
                                                                                            "saleCurrCode": "MMK",
                                                                                            "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                            "stockSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]}",
                                                                                            "n1": "0",
                                                                                            "wareHouseSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"],
                                                                                            "binSyskey": "0",
                                                                                            "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                            "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                            "lvlSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"],
                                                                                            "lvlQty": 0.0,
                                                                                            "n8": 0.0,
                                                                                            "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                            "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                            "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                            "n9": 0.0,
                                                                                            "taxAmount": 0.0,
                                                                                            "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                            "taxCodeSK": "0",
                                                                                            "isTaxInclusice": 0,
                                                                                            "taxPercent": 0.0,
                                                                                          });
                                                                                        }

                                                                                        // print(stockByBrandDel[j]["stockReturnData"]);
                                                                                      }
                                                                                    } else {
                                                                                      for (var j = 0; j < getdeliverylist.length; j++) {
                                                                                        if (getdeliverylist[j]["brandOwnerSyskey"].toString() == sameBrandownerKey[x]["brandOwnerSyskey"].toString()) {
                                                                                          getdeliverylist[j]["stockReturnData"].add({
                                                                                            "stockCode": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"],
                                                                                            "stockName": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"],
                                                                                            "recordStatus": 1,
                                                                                            "saleCurrCode": "MMK",
                                                                                            "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                            "stockSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]}",
                                                                                            "n1": "0",
                                                                                            "wareHouseSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"],
                                                                                            "binSyskey": "0",
                                                                                            "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                            "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                            "lvlSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"],
                                                                                            "lvlQty": 0.0,
                                                                                            "n8": 0.0,
                                                                                            "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                            "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                            "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                            "n9": 0.0,
                                                                                            "taxAmount": 0.0,
                                                                                            "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                            "taxCodeSK": "0",
                                                                                            "isTaxInclusice": 0,
                                                                                            "taxPercent": 0.0,
                                                                                          });
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                    // print(sameBrandownerKey[x]["stockData"].length);
                                                                                  } else {
                                                                                    // print(sameBrandownerKey[x]["stockData"]);
                                                                                    if (sameBrandownerKey[x]["stockData"].where((element) => element["stockCode"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"] && element["invoiceSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]).toList().toString() == "[]") {
                                                                                      check = "true";
                                                                                    } else {
                                                                                      check = "";
                                                                                    }
                                                                                    if (check == "true") {
                                                                                      print("add new stock to the same brandname");
                                                                                      for (var p = 0; p < newList.length; p++) {
                                                                                        if (newList[p]["brandOwnerSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]) {
                                                                                          // print("3newList ==> ${newList[0]["stockData"]}");
                                                                                          // print("Before UI List Add - Delivery List (${getdeliverylist[0]["stockReturnData"]})");
                                                                                          var r = [{
                                                                                            "syskey": "0",
                                                                                            "recordStatus": 1,
                                                                                            "createdDate" : addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                            "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                            "stockCode": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"]}",
                                                                                            "stockName": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"]}",
                                                                                            "saleCurrCode": "MMK",
                                                                                            "stockSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]}",
                                                                                            "n1": "0",
                                                                                            "wareHouseSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"]}",
                                                                                            "binSyskey": "0",
                                                                                            "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                            "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                            "lvlSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"]}",
                                                                                            "lvlQty": 1.0,
                                                                                            "n8": 1.0,
                                                                                            "n9": 0.0,
                                                                                            "taxAmount": 0.0,
                                                                                            "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                            "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                            "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                            "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                            "taxCodeSK": "0",
                                                                                            "isTaxInclusice": 0,
                                                                                            "taxPercent": 0.0,
                                                                                            "discountAmount": 0.0,
                                                                                            "discountPercent": 0.0,
                                                                                            "promotionStockList": [],
                                                                                            "brandOwnerSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]}",
                                                                                            "stockType": "RETURN"
                                                                                          }];
                                                                                          // Solving duplicate Stock Error
                                                                                          newList[p]["stockData"] = newList[p]["stockData"] + r;

                                                                                          if (newList[p]["stockData"].where((element) => element["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]).toList().length != 0) {
                                                                                            newList[p]["stockData"].removeWhere((element) => element["qty"].runtimeType.toString() == "int");
                                                                                          }

                                                                                        }
                                                                                      }

                                                                                        
                                                                                          if (getdeliverylist.toString() != "[]") {
                                                                                            for (var j = 0; j < getdeliverylist.length; j++) {
                                                                                              if (getdeliverylist[j]["brandOwnerSyskey"].toString() == addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"].toString()) {
                                                                                                getdeliverylist[j]["stockReturnData"].add({
                                                                                                  "stockCode": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"],
                                                                                                  "stockName": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"],
                                                                                                  "recordStatus": 1,
                                                                                                  "saleCurrCode": "MMK",
                                                                                                  "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                                  "stockSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"],
                                                                                                  "n1": "0",
                                                                                                  "wareHouseSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"],
                                                                                                  "binSyskey": "0",
                                                                                                  "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                                  "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                                  "lvlSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"],
                                                                                                  "lvlQty": 0.0,
                                                                                                  "n8": 0.0,
                                                                                                  "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                                  "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                                  "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                                  "n9": 0.0,
                                                                                                  "taxAmount": 0.0,
                                                                                                  "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                                  "taxCodeSK": "0",
                                                                                                  "isTaxInclusice": 0,
                                                                                                  "taxPercent": 0.0,
                                                                                                  "discountAmount": 0.0,
                                                                                                  "discountPercent": 0.0,
                                                                                                  "discountStock": false,
                                                                                                  "promotionStockList": []
                                                                                                });
                                                                                              }

                                                                                              for (var m = 0; m < getdeliverylist[j]["stockReturnData"].length; m++) {
                                                                                                print("stockReturnData ==> " + getdeliverylist[j]["stockReturnData"][m].toString());
                                                                                              }

                                                                                              // print("After Add - Delivery List (${getdeliverylist[j]["stockReturnData"].length})");

                                                                                              
                                                                                            }

                                                                                            // print("After UI List Add - UI List (${newList[0]["stockData"].length})");
                                                                                          } else {
                                                                                            print(stockByBrandDel.length);
                                                                                            for (var j = 0; j < stockByBrandDel.length; j++) {
                                                                                              for (var m = 0; m < stockByBrandDel[j]["stockReturnData"].length; m++) {
                                                                                                print(stockByBrandDel[j]["stockReturnData"][m]);
                                                                                              }
                                                                                              print("///////////");
                                                                                              if (stockByBrandDel[j]["brandOwnerSyskey"].toString() == addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"].toString()) {
                                                                                                stockByBrandDel[j]["stockReturnData"].add({
                                                                                                  "stockCode": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"],
                                                                                                  "stockName": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"],
                                                                                                  "recordStatus": 1,
                                                                                                  "saleCurrCode": "MMK",
                                                                                                  "invoiceDate": addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"],
                                                                                                  "stockSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"],
                                                                                                  "n1": "0",
                                                                                                  "wareHouseSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"],
                                                                                                  "binSyskey": "0",
                                                                                                  "qty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"],
                                                                                                  "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toInt(),
                                                                                                  "lvlSyskey": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"],
                                                                                                  "lvlQty": 0.0,
                                                                                                  "n8": 0.0,
                                                                                                  "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                                  "invoiceSyskey": "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
                                                                                                  "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                                  "n9": 0.0,
                                                                                                  "taxAmount": 0.0,
                                                                                                  "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"],
                                                                                                  "taxCodeSK": "0",
                                                                                                  "isTaxInclusice": 0,
                                                                                                  "taxPercent": 0.0,
                                                                                                  "discountAmount": 0.0,
                                                                                                  "discountPercent": 0.0,
                                                                                                  "discountStock": false,
                                                                                                  "promotionStockList": []
                                                                                                });
                                                                                              }

                                                                                              for (var m = 0; m < stockByBrandDel[j]["stockReturnData"].length; m++) {
                                                                                                print(stockByBrandDel[j]["stockReturnData"][m]);
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        
                                                                                      
                                                                                    } else if (check == "") {
                                                                                      print("add stockQty with same stock and same brandname");
                                                                                      for (var n = 0; n < sameBrandownerKey[x]["stockData"].length; n++) {
                                                                                        if (sameBrandownerKey[x]["stockData"][n]["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"] && 
                                                                                        sameBrandownerKey[x]["stockData"][n]["invoiceSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]) {
                                                                                          if(addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"] - sameBrandownerKey[x]["stockData"][n]["qty"].toInt() <= 0) {
                                                                                            addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["check"] = false;
                                                                                            print(sameBrandownerKey[x]["stockData"][n]["qty"]);
                                                                                          }else if((addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] + sameBrandownerKey[x]["stockData"][n]["qty"]) < sameBrandownerKey[x]["stockData"][n]["returnQty"].toDouble()) {
                                                                                            sameBrandownerKey[x]["stockData"][n]["qty"] = addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] + sameBrandownerKey[x]["stockData"][n]["qty"];
                                                                                            sameBrandownerKey[x]["stockData"][n]["totalAmount"] = addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"] * sameBrandownerKey[x]["stockData"][n]["qty"];
                                                                                            print(sameBrandownerKey[x]["stockData"][n]["qty"]);
                                                                                          } else {
                                                                                            sameBrandownerKey[x]["stockData"][n]["qty"] = addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] + sameBrandownerKey[x]["stockData"][n]["qty"];
                                                                                            sameBrandownerKey[x]["stockData"][n]["totalAmount"] = addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"] * sameBrandownerKey[x]["stockData"][n]["qty"];
                                                                                            print(sameBrandownerKey[x]["stockData"][n]["qty"].toString());
                                                                                          }
                                                                                        }

                                                                                        if (getdeliverylist == [] || getdeliverylist.length == 0) {
                                                                                          for (var q = 0; q < stockByBrandDel.length; q++) {
                                                                                            for (var p = 0; p < stockByBrandDel[q]["stockReturnData"].length; p++) {
                                                                                              if (stockByBrandDel[q]["stockReturnData"][p]["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"] && 
                                                                                              stockByBrandDel[q]["stockReturnData"][p]["invoiceSyskey"] == sameBrandownerKey[x]["stockData"][n]["invoiceSyskey"]) {
                                                                                                stockByBrandDel[q]["stockReturnData"][p]["qty"] = sameBrandownerKey[x]["stockData"][n]["qty"];
                                                                                                stockByBrandDel[q]["stockReturnData"][p]["totalAmount"] = sameBrandownerKey[x]["stockData"][n]["totalAmount"];
                                                                                              }
                                                                                            }

                                                                                            stockByBrandDel[q]["stockReturnData"].removeWhere((element) => element["qty"] == 0.0 || element["qty"] < 0);
                                                                                          }
                                                                                        } else {
                                                                                          for (var q = 0; q < getdeliverylist.length; q++) {
                                                                                            for (var p = 0; p < getdeliverylist[q]["stockReturnData"].length; p++) {
                                                                                              if (getdeliverylist[q]["stockReturnData"][p]["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"] && 
                                                                                              getdeliverylist[q]["stockReturnData"][p]["invoiceSyskey"] == sameBrandownerKey[x]["stockData"][n]["invoiceSyskey"]) {
                                                                                                getdeliverylist[q]["stockReturnData"][p]["qty"] = sameBrandownerKey[x]["stockData"][n]["qty"];
                                                                                                getdeliverylist[q]["stockReturnData"][p]["totalAmount"] = sameBrandownerKey[x]["stockData"][n]["totalAmount"];
                                                                                              }
    
                                                                                              print("getdeliverylist[a]['stockReturnData'] ==> " + getdeliverylist[q]["stockReturnData"][p].toString());
                                                                                            }
    
                                                                                            getdeliverylist[q]["stockReturnData"].removeWhere((element) => element["qty"].toString() == "0.0" || element["qty"] < 0);
                                                                                          }
                                                                                        }
                                                                                        
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          } else if (addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["check"] ==
                                                                              false) {
                                                                            for (var x =
                                                                                    0;
                                                                                x < newList.length;
                                                                                x++) {
                                                                              if (newList[x]["brandOwnerSyskey"] ==
                                                                                  addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]) {
                                                                                for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                                  if (newList[x]["stockData"][y]["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"] && newList[x]["stockData"][y]["createdDate"] == addReturnProductList[a]["brandOwnerList"][b]["invoiceDate"]) {
                                                                                    newList[x]["stockData"][y]["qty"] = newList[x]["stockData"][y]["qty"] - addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"];

                                                                                    newList[x]["stockData"][y]["totalAmount"] = double.parse("${newList[x]["stockData"][y]["qty"] * newList[x]["stockData"][y]["normalPrice"]}");

                                                                                    if (getdeliverylist == [] || getdeliverylist.length == 0) {
                                                                                      for (var q = 0; q < stockByBrandDel.length; q++) {
                                                                                        for (var p = 0; p < stockByBrandDel[q]["stockReturnData"].length; p++) {
                                                                                          if (stockByBrandDel[q]["stockReturnData"][p]["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"] && 
                                                                                          stockByBrandDel[q]["stockReturnData"][p]["invoiceSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]) {
                                                                                            stockByBrandDel[q]["stockReturnData"][p]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                                          }
                                                                                        }

                                                                                        stockByBrandDel[q]["stockReturnData"].removeWhere((element) => element["qty"] == 0.0 || element["qty"] < 0);
                                                                                      }
                                                                                    } else {
                                                                                      for (var q = 0; q < getdeliverylist.length; q++) {
                                                                                        for (var p = 0; p < getdeliverylist[q]["stockReturnData"].length; p++) {
                                                                                          if (getdeliverylist[q]["stockReturnData"][p]["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"] && 
                                                                                          getdeliverylist[q]["stockReturnData"][p]["invoiceSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]) {
                                                                                            getdeliverylist[q]["stockReturnData"][p]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                                          }

                                                                                          print("getdeliverylist[a]['stockReturnData'] ==> " + getdeliverylist[q]["stockReturnData"][p].toString());
                                                                                        }

                                                                                        getdeliverylist[q]["stockReturnData"].removeWhere((element) => element["qty"].toString() == "0.0" || element["qty"] < 0);
                                                                                      }
                                                                                    }

                                                                                    if (newList[x]["stockData"].length != 0) {
                                                                                      if (newList[x]["stockData"][y]["qty"].toString() == "0.0") {
                                                                                        newList[x]["stockData"].removeWhere((element) => element["qty"].toString() == "0.0" || element["qty"] < 0);
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                            }
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(width: 10),
                                                                Container(
                                                                    width: MediaQuery.of(context).size.width - 191,
                                                                    height: 40,
                                                                    child: Align(
                                                                      alignment: Alignment.centerLeft,
                                                                      child: Text(
                                                                        "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"]}",
                                                                        style: TextStyle(
                                                                            fontSize: 15),
                                                                      ),
                                                                    ))
                                                              ],
                                                            ),
                                                            SizedBox(height: 5),
                                                            Row(
                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: <Widget>[
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 15),
                                                                  child: Row(
                                                                    children: <Widget>[
                                                                      Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: <Widget>[
                                                                          Container(
                                                                            child: GestureDetector(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  if(addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] <= 1) {
                                                                                    //
                                                                                  } else {
                                                                                    setState(() {
                                                                                      addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"]--;
                                                                                    });

                                                                                    if(addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["check"] == true) {
                                                                                      for (var x = 0; x < newList.length; x++) {
                                                                                        if (newList[x]["brandOwnerSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]) {
                                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                                            if (newList[x]["stockData"][y]["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"] && 
                                                                                            newList[x]["stockData"][y]["invoiceSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]) {
                                                                                              newList[x]["stockData"][y]["qty"] = newList[x]["stockData"][y]["qty"] - 1;

                                                                                              newList[x]["stockData"][y]["totalAmount"] = addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"] * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"];
                                                                                              
                                                                                              for(var v = 0; v < returnStockData.length; v++) {
                                                                                                if(returnStockData[v]["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"] && 
                                                                                                returnStockData[v]["invoiceSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]) {
                                                                                                  returnStockData[v]["qty"] = newList[x]["stockData"][y]["qty"];

                                                                                                  returnStockData[v]["totalAmount"] = newList[x]["stockData"][y]["qty"] * newList[x]["stockData"][y]["price"];
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      }

                                                                                      if(getdeliverylist.length == 0) {
                                                                                        for(var m = 0; m < stockByBrandDel.length; m++) {
                                                                                          for (var x = 0; x < newList.length; x++) {
                                                                                            if(stockByBrandDel[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                                              for(var n = 0; n < stockByBrandDel[m]["stockReturnData"].length; n++) {
                                                                                                for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                                                  if(stockByBrandDel[m]["stockReturnData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"] &&
                                                                                                  stockByBrandDel[m]["stockReturnData"][n]["invoiceSyskey"] == newList[x]["stockData"][y]["invoiceSyskey"]) {
                                                                                                    stockByBrandDel[m]["stockReturnData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                                                    stockByBrandDel[m]["stockReturnData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      } else {
                                                                                        for(var m = 0; m < getdeliverylist.length; m++) {
                                                                                          for (var x = 0; x < newList.length; x++) {
                                                                                            if(getdeliverylist[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                                              for(var n = 0; n < getdeliverylist[m]["stockReturnData"].length; n++) {
                                                                                                for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                                                  if(getdeliverylist[m]["stockReturnData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"] &&
                                                                                                  getdeliverylist[m]["stockReturnData"][n]["invoiceSyskey"] == newList[x]["stockData"][y]["invoiceSyskey"]) {
                                                                                                    getdeliverylist[m]["stockReturnData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                                                    getdeliverylist[m]["stockReturnData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    }else {
                                                                                      //
                                                                                    }
                                                                                  }
                                                                                });
                                                                              },
                                                                              child: Center(
                                                                                child: Icon(
                                                                                  const IconData(0xe15b, fontFamily: 'MaterialIcons'),
                                                                                  color: Colors.white,
                                                                                  size: 19,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                              color: Color(0xffe53935),
                                                                              borderRadius: BorderRadius.circular(3),
                                                                              border: Border(
                                                                                top: BorderSide(width: 0.5, color: Colors.white),
                                                                                bottom: BorderSide(width: 0.5, color: Colors.white),
                                                                                left: BorderSide(width: 0.5, color: Colors.white),
                                                                                right: BorderSide(width: 0.5, color: Colors.white),
                                                                              ),
                                                                            ),
                                                                            height: 23,
                                                                            width: 25,
                                                                          ),
                                                                          GestureDetector(
                                                                            onTap: () {
                                                                              _showIntDialog(addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"].toInt()).then((value) {
                                                                                setState(() {
                                                                                    addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] = value.toDouble();

                                                                                    if (addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["check"] == true) {

                                                                                      List dropdown = [];

                                                                                      print(newList);
                                                                                      if(newList.length == 0) {
                                                                                        dropdown = [];
                                                                                      } else {
                                                                                        dropdown = originalQty.where((element) => element["stockCode"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"] && element["invoiceSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]).toList();
                                                                                      }

                                                                                      print(dropdown);

                                                                                      if(dropdown == [] || dropdown.length == 0) {
                                                                                        addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] = value.toDouble();
                                                                                        for (var x = 0; x < newList.length; x++) {
                                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                                            if(newList[x]["stockData"][y]["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"] && newList[x]["stockData"][y]["invoiceSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]) {
                                                                                              
                                                                                              if(value >= addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"]) {
                                                                                                addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] = addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"].toDouble();
                                                                                              }

                                                                                              newList[x]["stockData"][y]["qty"] = addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"];

                                                                                              newList[x]["stockData"][y]["totalAmount"] = newList[x]["stockData"][y]["price"] * newList[x]["stockData"][y]["qty"];

                                                                                              

                                                                                              for(var v = 0; v < returnStockData.length; v++) {
                                                                                                if(returnStockData[v]["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"] && returnStockData[v]["invoiceSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]) {
                                                                                                  returnStockData[v]["qty"] = newList[x]["stockData"][y]["qty"];

                                                                                                  print(returnStockData[v]["qty"]);

                                                                                                  returnStockData[v]["totalAmount"] = newList[x]["stockData"][y]["qty"] * newList[x]["stockData"][y]["price"];
                                                                                                }
                                                                                              }
                                                                                            }

                                                                                            print("List == >");
                                                                                            print(newList[x]["stockData"][y]);
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                      if(dropdown != [] || dropdown.length != 0) {
                                                                                        for(var v = 0; v < dropdown.length; v++) {
                                                                                          for (var x = 0; x < newList.length; x++) {
                                                                                            for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                                              if(newList[x]["stockData"][y]["stockCode"] == dropdown[v]["stockCode"] && newList[x]["stockData"][y]["invoiceSyskey"] == dropdown[v]["invoiceSyskey"]) {
                                                                                                if(dropdown[v]["qty"] + value >= addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"] - dropdown[v]["qty"]) {
                                                                                                  addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] = addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"] - dropdown[v]["qty"];
                                                                                                } else {
                                                                                                  addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] = value;
                                                                                                }
                                                                                                newList[x]["stockData"][y]["qty"] = addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] + dropdown[v]["qty"];

                                                                                                newList[x]["stockData"][y]["totalAmount"] = newList[x]["stockData"][y]["price"] * newList[x]["stockData"][y]["qty"];

                                                                                                for(var v = 0; v < returnStockData.length; v++) {
                                                                                                  if(returnStockData[v]["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]) {
                                                                                                    
                                                                                                    returnStockData[v]["qty"] = newList[x]["stockData"][y]["qty"];

                                                                                                    returnStockData[v]["totalAmount"] = newList[x]["stockData"][y]["qty"] * newList[x]["stockData"][y]["price"];
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      }

                                                                                      if(getdeliverylist.length == 0) {
                                                                                        for(var m = 0; m < stockByBrandDel.length; m++) {
                                                                                          for (var x = 0; x < newList.length; x++) {
                                                                                            if(stockByBrandDel[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                                              for(var n = 0; n < stockByBrandDel[m]["stockReturnData"].length; n++) {
                                                                                                for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                                                  if(stockByBrandDel[m]["stockReturnData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"] &&
                                                                                                  stockByBrandDel[m]["stockReturnData"][n]["invoiceSyskey"] == newList[x]["stockData"][y]["invoiceSyskey"]) {
                                                                                                    stockByBrandDel[m]["stockReturnData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                                                    stockByBrandDel[m]["stockReturnData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      } else {
                                                                                        for(var m = 0; m < getdeliverylist.length; m++) {
                                                                                          for (var x = 0; x < newList.length; x++) {
                                                                                            if(getdeliverylist[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                                              for(var n = 0; n < getdeliverylist[m]["stockReturnData"].length; n++) {
                                                                                                for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                                                  if(getdeliverylist[m]["stockReturnData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"] &&
                                                                                                  getdeliverylist[m]["stockReturnData"][n]["invoiceSyskey"] == newList[x]["stockData"][y]["invoiceSyskey"]) {
                                                                                                    getdeliverylist[m]["stockReturnData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                                                    getdeliverylist[m]["stockReturnData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    } else {
                                                                                      //
                                                                                    }
                                                                                  // }
                                                                                });
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              child: Center(child: Text("${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"].toInt()}")),
                                                                              decoration: BoxDecoration(
                                                                                border: Border(
                                                                                  top: BorderSide(width: 0.5, color: Colors.grey),
                                                                                  bottom: BorderSide(width: 0.5, color: Colors.grey),
                                                                                  left: BorderSide(width: 0.5, color: Colors.white),
                                                                                  right: BorderSide(width: 0.5, color: Colors.white),
                                                                                ),
                                                                              ),
                                                                              height: 27,
                                                                              width: 45,
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            child:
                                                                                GestureDetector(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  if(addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"] >= addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"]) {
                                                                                    //
                                                                                  } else {
                                                                                    if(addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["check"] == true) {
                                                                                      for (var x = 0; x < newList.length; x++) {
                                                                                        if (newList[x]["brandOwnerSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]) {
                                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                                            if (newList[x]["stockData"][y]["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"] && 
                                                                                            newList[x]["stockData"][y]["invoiceSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]) {
                                                                                              if(newList[x]["stockData"][y]["qty"] >= addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"]) {
                                                                                                //
                                                                                              } else {
                                                                                                setState(() {
                                                                                                  addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"]++;
                                                                                                });
                                                                                                newList[x]["stockData"][y]["qty"] = newList[x]["stockData"][y]["qty"] + 1;

                                                                                                newList[x]["stockData"][y]["totalAmount"] = newList[x]["stockData"][y]["price"] * newList[x]["stockData"][y]["qty"];
                                                                                              
                                                                                                for(var v = 0; v < returnStockData.length; v++) {
                                                                                                  if(returnStockData[v]["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"] && 
                                                                                                  returnStockData[v]["invoiceSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]) {
                                                                                                    returnStockData[v]["qty"] = newList[x]["stockData"][y]["qty"];

                                                                                                    returnStockData[v]["totalAmount"] = newList[x]["stockData"][y]["qty"] * newList[x]["stockData"][y]["price"];
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                              
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      }

                                                                                      if(getdeliverylist.length == 0) {
                                                                                        for(var m = 0; m < stockByBrandDel.length; m++) {
                                                                                          for (var x = 0; x < newList.length; x++) {
                                                                                            if(stockByBrandDel[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                                              for(var n = 0; n < stockByBrandDel[m]["stockReturnData"].length; n++) {
                                                                                                for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                                                  if(stockByBrandDel[m]["stockReturnData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"] &&
                                                                                                  stockByBrandDel[m]["stockReturnData"][n]["invoiceSyskey"] == newList[x]["stockData"][y]["invoiceSyskey"]) {
                                                                                                    stockByBrandDel[m]["stockReturnData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                                                    stockByBrandDel[m]["stockReturnData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      } else {
                                                                                        for(var m = 0; m < getdeliverylist.length; m++) {
                                                                                          for (var x = 0; x < newList.length; x++) {
                                                                                            if(getdeliverylist[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                                              for(var n = 0; n < getdeliverylist[m]["stockReturnData"].length; n++) {
                                                                                                for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                                                  if(getdeliverylist[m]["stockReturnData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"] &&
                                                                                                  getdeliverylist[m]["stockReturnData"][n]["invoiceSyskey"] == newList[x]["stockData"][y]["invoiceSyskey"]) {
                                                                                                    getdeliverylist[m]["stockReturnData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                                                    getdeliverylist[m]["stockReturnData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    }else {
                                                                                      setState(() {
                                                                                        addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"]++;
                                                                                      });
                                                                                    }
                                                                                  }
                                                                                });
                                                                              },
                                                                              child: Center(child: Icon(Icons.add, size: 19, color: Colors.white)),
                                                                            ),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(3),
                                                                              color: Color(0xffe53935),
                                                                              border: Border(
                                                                                top: BorderSide(width: 0.5, color: Colors.white),
                                                                                bottom: BorderSide(width: 0.5, color: Colors.white),
                                                                                left: BorderSide(width: 0.5, color: Colors.white),
                                                                                right: BorderSide(width: 0.5, color: Colors.white),
                                                                              ),
                                                                            ),
                                                                            height:
                                                                                23,
                                                                            width:
                                                                                25,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          15),
                                                                  child: Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                          "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"].toInt()}"),
                                                                      SizedBox(
                                                                          width:
                                                                              40),
                                                                      Text(
                                                                          "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["price"].toInt() * addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["qty"].toInt()}"),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            SizedBox(height: 5,),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 15),
                                                              child: Text(
                                                                originalStockList.length == 0 ?
                                                                "Max Qty (${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"]})" :
                                                                originalStockList.where((element) => element["brandOwnerSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]).toList().length == 0 ?
                                                                "Max Qty (${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"]})" :
                                                                originalStockList.where((element) => element["brandOwnerSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]).toList()[0]["stockData"].where((element) => element["invoiceSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"] && element["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]).toList().length == 0 ?
                                                                "Max Qty (${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"]})" :
                                                                "Max Qty (${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"] - originalStockList.where((element) => element["brandOwnerSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]).toList()[0]["stockData"].where((element) => element["invoiceSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"] && element["stockSyskey"] == addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]).toList()[0]["qty"].toInt()})",
                                                                style: TextStyle(fontSize: 12, color: Color(0xffef5350)),),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }))
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  datetime();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderDetailData(
                                shopName: widget.shopName,
                                shopNameMm: widget.shopNameMm,
                                address: widget.address,
                                shopSyskey: widget.shopSyskey,
                                orderDate: widget.date,
                                deliveryDate: date,
                                mcdCheck: widget.mcdCheck,
                                userType: widget.userType,
                                stockList: widget.returnList,
                                ownerName: ownerName,
                                phone: widget.phone,
                                returnList: newList,
                                back: "FromButton",
                                orderDeleted: widget.orderDeleted,
                                returnDeleted: widget.returnDeleted,
                                rtn: "FromReturn",
                                isSaleOrderLessRouteShop:
                                    widget.isSaleOrderLessRouteShop,
                              )));
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xffe53935),
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Center(
                      child: Text(
                        "Add Product",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

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

  Future<void> rebuildList() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    
    addReturnProductList = json.decode(preferences.getString("AddReturnProductList"));
    originalStockList = json.decode(preferences.getString("ReturnStockList"));
    newList = widget.stockList1;
    originalList = widget.stockList1;
    for(var v = 0; v < newList.length; v++) {
      for(var j = 0; j < newList[v]["stockData"].length; j++) {
        originalQty.add({
          "stockCode" : "${newList[v]["stockData"][j]["stockCode"]}",
          "invoiceSyskey" : "${newList[v]["stockData"][j]["invoiceSyskey"]}",
          "qty" : newList[v]["stockData"][j]["qty"]
        });
      }
    }

    
    
    for (var a = 0; a < addReturnProductList.length; a++) {
      for (var b = 0; b < addReturnProductList[a]["brandOwnerList"].length; b++) {
        for (var c = 0;
            c < addReturnProductList[a]["brandOwnerList"][b]["stockData"].length;
            c++) {
              setState(() {
              
          addReturnProductList[a]["brandOwnerList"][b]["stockData"][c] = {
            "check": false,
            "syskey":
                "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["syskey"]}",
            "recordStatus": addReturnProductList[a]["brandOwnerList"][b]["stockData"]
                [c]["recordStatus"],
            "stockCode":
                "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockCode"]}",
            "stockName":
                "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockName"]}",
            "saleCurrCode":
                "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["saleCurrCode"]}",
            "n1":
                "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["n1"]}",
            "stockSyskey":
                "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockSyskey"]}",
            "wareHouseSyskey":
                "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["wareHouseSyskey"]}",
            "binSyskey":
                "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["binSyskey"]}",
            "qty": 1.0,
            "returnQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["returnQty"],
            "lvlSyskey":
                "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["lvlSyskey"]}",
            "lvlQty": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]
                ["lvlQty"],
            "n8": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["n8"],
            "n9": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["n9"],
            "taxAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]
                ["taxAmount"],
            "totalAmount": addReturnProductList[a]["brandOwnerList"][b]["stockData"]
                [c]["totalAmount"],
            "price": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]
                ["price"],
            "normalPrice": addReturnProductList[a]["brandOwnerList"][b]["stockData"]
                [c]["normalPrice"],
            "discountAmount": addReturnProductList[a]["brandOwnerList"][b]
                ["stockData"][c]["discountAmount"],
            "discountPercent": addReturnProductList[a]["brandOwnerList"][b]
                ["stockData"][c]["discountPercent"],
            "taxCodeSK":
                "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["taxCodeSK"]}",
            "isTaxInclusice": addReturnProductList[a]["brandOwnerList"][b]
                ["stockData"][c]["isTaxInclusice"],
            "taxPercent": addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]
                ["taxPercent"],
            "brandOwnerSyskey":
                "${addReturnProductList[a]["brandOwnerList"][b]["brandOwnerSyskey"]}",
            "stockType":
                "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["stockType"]}",
            "discountStock": addReturnProductList[a]["brandOwnerList"][b]["stockData"]
                [c]["discountStock"],
            "invoiceSyskey":
                "${addReturnProductList[a]["brandOwnerList"][b]["stockData"][c]["invoiceSyskey"]}",
            "promotionStockList": addReturnProductList[a]["brandOwnerList"][b]
                ["stockData"][c]["promotionStockList"]
          };

          });
        }
      }
    }
  }
}

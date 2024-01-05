import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/shopByUserDatabase.dart';
import '../Login.dart';
import '../service.dart/AllService.dart';
import 'package:delivery_2/OrderDetailData.dart';

import 'AddOrderStock.dart';
import 'DiscountDetail.dart';
import 'ShowImage.dart';

class DiscountStock extends StatefulWidget {
  final List disItemList;
  DiscountStock({Key key, @required this.disItemList}) : super(key: key);
  @override
  _DiscountStockState createState() => _DiscountStockState();
}

class _DiscountStockState extends State<DiscountStock> {
  bool searchVisible = false;
  TextEditingController searchCtrl = TextEditingController();
  List discountStockList = [];
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  ShopsbyUser helperShopsbyUser = ShopsbyUser();
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  List listForNewList = [];
  List categoryList = [];

  @override
  void initState() {
    super.initState();
    discountStockList = widget.disItemList;
    listForNewList = newList;
    getImage();
    getCategoryList();
    print("newList ==> $newList");
  }

  Future<void> getImage() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    stockImage = json.decode(preferences.getString("StockImageList"));
    preferences.setString("disItemList", json.encode(widget.disItemList));
  }

  void getCategoryList() {
    categoryList.add({
      "categoryCode" : "All",
      "categoryCodeDesc" : "All",
      "stockList" : listtoCheckMultiDis,
      "choose" : true
    });
    for(var a = 0; a < multiDiscountStockList.length; a++) {
      categoryList.add({
        "categoryCode" : multiDiscountStockList[a]["HeaderSyskey"],
        "categoryCodeDesc" : multiDiscountStockList[a]["HeaderDesc"],
        "stockList" : listtoCheckMultiDis.where((element) => element["HeaderSyskey"] == multiDiscountStockList[a]["HeaderSyskey"]).toList(),
        "choose" : false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    newList = listForNewList;
    print("newList ==> $newList");
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldkey,
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          title: Text("Discount Items"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, stockList);
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                print(newList);
                if (searchVisible == false) {
                  setState(() {
                    searchVisible = true;
                  });
                } else if (searchVisible == true) {
                  setState(() {
                    searchVisible = false;
                    searchCtrl.text = "";
                    discountStockList = widget.disItemList;
                  });
                }

              },
            ),
            SizedBox(width: 15)
          ],
        ),
        body: ListView(
          children: <Widget>[
            Visibility(
              visible: searchVisible,
              child: Container(
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextField(
                    controller: searchCtrl,
                    cursorColor: Color(0xffe53935),
                    decoration: InputDecoration(
                      labelText: "Search",
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 15.0),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffe53935)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffe53935)),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffe53935)),
                      ),
                    ),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
            if(categoryList.length != 0)
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryList.length,
                itemBuilder: (context, a) {
                  return GestureDetector(
                    onTap: () async {
                      final SharedPreferences preferences = await SharedPreferences.getInstance();
                      List originalList = json.decode(preferences.getString("disItemList"));
                      setState(() {
                        categoryList.where((element) => element["choose"] == true).toList()[0]["choose"] = false;
                        categoryList[a]["choose"] = true;

                        discountStockList = originalList;

                        if(categoryList[a]["categoryCode"] == "All") {
                          discountStockList = originalList;
                        } else {
                          for(var c = 0; c < discountStockList.length; c++) {
                            discountStockList[c]["StockList"] = [];
                            originalList = json.decode(preferences.getString("disItemList"));
                            for(var b = 0; b < categoryList[a]["stockList"].length; b++) {
                              if(originalList[c]["StockList"].where((element) => element["stockSyskey"] == categoryList[a]["stockList"][b]["PromoItemSyskey"]).toList().length == 0) {
                                //
                              } else {
                                discountStockList[c]["StockList"].add(originalList[c]["StockList"].where((element) => element["stockSyskey"] == categoryList[a]["stockList"][b]["PromoItemSyskey"]).toList()[0]);
                              }
                            }
                          }

                          discountStockList.removeWhere((element) => element["StockList"].length == 0);
                        }
                      });
                    },
                    child: Card(
                      color: categoryList[a]["choose"] ? Color(0xffe53935) : Colors.red[100],
                      child: Container(
                        height: 50,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Center(child: Text("${categoryList[a]["categoryCodeDesc"]}", style: TextStyle(fontSize: 15, color: categoryList[a]["choose"] ? Colors.white : Colors.black),)),
                        ),
                      ),
                    ),
                  );
              }),
            ),
            for (var a = 0; a < discountStockList.length; a++)
              Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (discountStockList[a]["choose"] == true) {
                          discountStockList[a]["choose"] = false;
                        } else if (discountStockList[a]["choose"] == false) {
                          discountStockList[a]["choose"] = true;
                        }
                      });
                    },
                    child: Container(
                      // height: 50,
                      child: Card(
                          color: Color(0xffe53935),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width - 70,
                                  child: Text(
                                    discountStockList[a]["categoryCodeDesc"] == null
                                        ? ""
                                        : "${discountStockList[a]["categoryCodeDesc"]}",
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.white),
                                  ),
                                ),
                                Icon(
                                  discountStockList[a]["choose"]
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_right,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          )),
                    ),
                  ),
                  Visibility(
                    visible: discountStockList[a]["choose"],
                    child: Column(
                      children: <Widget>[
                        for (var b = 0; b < discountStockList[a]["StockList"].length; b++)
                          Stack(
                        children: <Widget>[
                          Card(
                            child: Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  leading: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: 64,
                                      maxHeight: 80,
                                    ),
                                    child: stockImage == [] ||
                                            stockImage.length == 0
                                        ? GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ShowImage(
                                                              image: Image.asset(
                                                                  "assets/coca.png"))));
                                            },
                                            child: Image.asset(
                                                "assets/coca.png",
                                                fit: BoxFit.cover),
                                          )
                                        : Stack(
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ShowImage(
                                                                  image: Image
                                                                      .asset(
                                                                          "assets/coca.png"))));
                                                },
                                                child: Image.asset(
                                                    "assets/coca.png",
                                                    fit: BoxFit.cover),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ShowImage(
                                                                  image: CachedNetworkImage(
                                                                      imageUrl:
                                                                          "${domain.substring(0, domain.lastIndexOf("8084/"))}8084${stockImage.where((element) => element["stockCode"] == discountStockList[a]["StockList"][b]["stockCode"]).toList()[0]["image"]}"))));
                                                },
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      "${domain.substring(0, domain.lastIndexOf("8084/"))}8084${stockImage.where((element) => element["stockCode"] == discountStockList[a]["StockList"][b]["stockCode"]).toList()[0]["image"]}",
                                                ),
                                              )
                                            ],
                                          ),
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Checkbox(
                                              activeColor: Color(0xffe53935),
                                              value: discountStockList[a]["StockList"][b]["check"],
                                              onChanged: (val) async {
                                                final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                print(discountStockList[a]["StockList"][b]["stockSyskey"]);
                                                setState(() {
                                                  discountStockList[a]["StockList"][b]["check"] = val;

                                                  var check = "";

                                                  if (discountStockList[a]["StockList"][b]["check"] == true) {
                                                    stockList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["check"] = true;
                                                    List sameBrandownerKey = [];
                                                    print("newList ==> $newList");
                                                    if (newList.length == 0 || newList == []) {
                                                      print("no stock to add");
                                                      newList.add({
                                                        "brandOwnerName": discountStockList[a]["StockList"][b]["brandOwnerName"],
                                                        "brandOwnerSyskey": discountStockList[a]["StockList"][b]["brandOwnerSyskey"],
                                                        "visible": true,
                                                        "stockData": [
                                                          {
                                                            "syskey": "0",
                                                            "recordStatus": 1,
                                                            "stockCode": "${discountStockList[a]["StockList"][b]["stockCode"]}",
                                                            "stockName": "${discountStockList[a]["StockList"][b]["stockName"]}",
                                                            "saleCurrCode": "MMK",
                                                            "stockSyskey" : "${discountStockList[a]["StockList"][b]["stockSyskey"]}",
                                                            "n1": "0",
                                                            "wareHouseSyskey": "${discountStockList[a]["StockList"][b]["wareHouseSyskey"]}",
                                                            "binSyskey": "0",
                                                            "qty": double.parse("${discountStockList[a]["StockList"][b]["qty"]}.0"),
                                                            "lvlSyskey": "${discountStockList[a]["StockList"][b]["lvlSyskey"]}",
                                                            "lvlQty": 1.0,
                                                            "n8": 1.0,
                                                            "n9": 0.0,
                                                            "taxAmount": 0.0,
                                                            "totalAmount": double.parse("${discountStockList[a]["StockList"][b]["qty"] * discountStockList[a]["StockList"][b]["totalAmount"]}.0"),
                                                            "price": double.parse("${discountStockList[a]["StockList"][b]["totalAmount"]}.0"),
                                                            "normalPrice" : double.parse("${discountStockList[a]["StockList"][b]["totalAmount"]}.0"),
                                                            "taxCodeSK": "0",
                                                            "isTaxInclusice": 0,
                                                            "taxPercent": 0.0,
                                                            "discountAmount": 0.0,
                                                            "discountPercent": 0.0,
                                                            "promotionStockList" : [],
                                                            "brandOwnerSyskey": "${discountStockList[a]["StockList"][b]["brandOwnerSyskey"]}",
                                                            "stockType": "NORMAL",
                                                            "invoiceSyskey": "0",
                                                            "invoiceDate": date,
                                                            "appliedDate": date,
                                                            "promoDetailSyskey": "0",
                                                          }
                                                        ]
                                                      });
                                                      if (getdeliverylist.length.toString() != "0") {
                                                        print("add to deliveryList");
                                                        var check = 0;
                                                        for(var l = 0; l < getdeliverylist.length;l++){
                                                          if(getdeliverylist[l]["brandOwnerSyskey"] == discountStockList[a]["StockList"][b]["brandOwnerSyskey"]){
                                                            check = 1;
                                                            List deletedList = getdeliverylist[l]["stockData"].where((element) => element["recordStatus"] == 4).toList();
                                                            String invSyskey = "0";
                                                            String invoiceDate = "";
                                                            String appliedDate = "";
                                                            String promoDetailSyskey = "0";
                                                            if(deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList().length != 0) {
                                                              invSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceSyskey"];
                                                              invoiceDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceDate"];
                                                              appliedDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["appliedDate"];
                                                              promoDetailSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["promoDetailSyskey"];
                                                            }
                                                            var r = {
                                                              "stockCode": discountStockList[a]["StockList"][b]["stockCode"],
                                                              "stockName": discountStockList[a]["StockList"][b]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : discountStockList[a]["StockList"][b]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": discountStockList[a]["StockList"][b]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": discountStockList[a]["StockList"][b]["qty"],
                                                              "lvlSyskey": discountStockList[a]["StockList"][b]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "normalPrice" : discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": discountStockList[a]["StockList"][b]["qty"] * discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "invoiceSyskey": invSyskey,
                                                              "invoiceDate": invoiceDate,
                                                              "appliedDate": appliedDate,
                                                              "promoDetailSyskey": promoDetailSyskey,
                                                              "promotionStockList" : []
                                                            };
                                                           getdeliverylist[l]["stockData"].add(r);
                                                          }
                                                        }
                                                        if(check == 0){
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
                                                          "brandOwnerName": discountStockList[a]["StockList"][b]["brandOwnerName"],
                                                          "brandOwnerSyskey": discountStockList[a]["StockList"][b]["brandOwnerSyskey"],
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
                                                          "stockData": [
                                                            {
                                                              "stockCode": discountStockList[a]["StockList"][b]["stockCode"],
                                                              "stockName": discountStockList[a]["StockList"][b]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : discountStockList[a]["StockList"][b]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": discountStockList[a]["StockList"][b]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": discountStockList[a]["StockList"][b]["qty"],
                                                              "lvlSyskey": discountStockList[a]["StockList"][b]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "normalPrice" : discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": discountStockList[a]["StockList"][b]["qty"] * discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "invoiceSyskey": "0",
                                                              "invoiceDate": date,
                                                              "appliedDate": date,
                                                              "promoDetailSyskey": "0",
                                                              "promotionStockList" : []
                                                            }
                                                          ],
                                                          "stockReturnData": []
                                                        });
                                                        }
                                                      } else {
                                                        print(
                                                            "add to delivery list stockbybrandDelivery");
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
                                                          "brandOwnerName": discountStockList[a]["StockList"][b]["brandOwnerName"],
                                                          "brandOwnerSyskey": discountStockList[a]["StockList"][b]["brandOwnerSyskey"],
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
                                                          "stockData": [
                                                            {
                                                              "stockCode": discountStockList[a]["StockList"][b]["stockCode"],
                                                              "stockName": discountStockList[a]["StockList"][b]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : discountStockList[a]["StockList"][b]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": discountStockList[a]["StockList"][b]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": discountStockList[a]["StockList"][b]["qty"],
                                                              "lvlSyskey": discountStockList[a]["StockList"][b]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "normalPrice" : discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": discountStockList[a]["StockList"][b]["qty"] * discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "invoiceSyskey": "0",
                                                              "invoiceDate": date,
                                                              "appliedDate": date,
                                                              "promoDetailSyskey": "0",
                                                              "promotionStockList" : []
                                                            }
                                                          ],
                                                          "stockReturnData": []
                                                        });
                                                      }
                                                    } else {
                                                      sameBrandownerKey = newList.where((element) => element["brandOwnerSyskey"].toString() == discountStockList[a]["StockList"][b]["brandOwnerSyskey"].toString()).toList();

                                                      // print(sameBrandownerKey);
                                                      if (sameBrandownerKey.toString() == "[]") {
                                                        print("add new brandname");
                                                        newList.add({
                                                          "brandOwnerName": discountStockList[a]["StockList"][b]["brandOwnerName"],
                                                          "brandOwnerSyskey": discountStockList[a]["StockList"][b]["brandOwnerSyskey"],
                                                          "visible": true,
                                                          "stockData": [
                                                            {
                                                              "syskey": "0",
                                                              "recordStatus": 1,
                                                              "stockCode": "${discountStockList[a]["StockList"][b]["stockCode"]}",
                                                              "stockName": "${discountStockList[a]["StockList"][b]["stockName"]}",
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : "${discountStockList[a]["StockList"][b]["stockSyskey"]}",
                                                              "n1": "0",
                                                              "wareHouseSyskey": "${discountStockList[a]["StockList"][b]["wareHouseSyskey"]}",
                                                              "binSyskey": "0",
                                                              "qty": double.parse("${discountStockList[a]["StockList"][b]["qty"]}.0"),
                                                              "lvlSyskey": "${discountStockList[a]["StockList"][b]["lvlSyskey"]}",
                                                              "lvlQty": 1.0,
                                                              "n8": 1.0,
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": double.parse("${discountStockList[a]["StockList"][b]["qty"] * discountStockList[a]["StockList"][b]["totalAmount"]}.0"),
                                                              "price": double.parse("${discountStockList[a]["StockList"][b]["totalAmount"]}.0"),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "promotionStockList" : [],
                                                              "brandOwnerSyskey": "${discountStockList[a]["StockList"][b]["brandOwnerSyskey"]}",
                                                              "stockType": "NORMAL",
                                                              "invoiceSyskey": "0",
                                                              "invoiceDate": date,
                                                              "appliedDate": date,
                                                              "promoDetailSyskey": "0",
                                                            }
                                                          ]
                                                        });

                                                        if (getdeliverylist.length.toString() != "0") {
                                                          var check = 0;
                                                        for(var l = 0; l < getdeliverylist.length;l++){
                                                          if(getdeliverylist[l]["brandOwnerSyskey"] == discountStockList[a]["StockList"][b]["brandOwnerSyskey"]){
                                                            check = 1;
                                                            List deletedList = getdeliverylist[l]["stockData"].where((element) => element["recordStatus"] == 4).toList();
                                                            String invSyskey = "0";
                                                            String invoiceDate = "";
                                                            String appliedDate = "";
                                                            String promoDetailSyskey = "0";
                                                            if(deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList().length != 0) {
                                                              invSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceSyskey"];
                                                              invoiceDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceDate"];
                                                              appliedDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["appliedDate"];
                                                              promoDetailSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["promoDetailSyskey"];
                                                            }
                                                            var r = {
                                                              "stockCode": discountStockList[a]["StockList"][b]["stockCode"],
                                                              "stockName": discountStockList[a]["StockList"][b]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : discountStockList[a]["StockList"][b]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": discountStockList[a]["StockList"][b]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": discountStockList[a]["StockList"][b]["qty"],
                                                              "lvlSyskey": discountStockList[a]["StockList"][b]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "normalPrice" : discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": discountStockList[a]["StockList"][b]["qty"] * discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "invoiceSyskey": invSyskey,
                                                              "invoiceDate": invoiceDate,
                                                              "appliedDate": appliedDate,
                                                              "promoDetailSyskey": promoDetailSyskey,
                                                              "promotionStockList" : []
                                                            };
                                                           getdeliverylist[l]["stockData"].add(r);
                                                          }
                                                        }
                                                        if(check == 0){
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
                                                          "brandOwnerName": discountStockList[a]["StockList"][b]["brandOwnerName"],
                                                          "brandOwnerSyskey": discountStockList[a]["StockList"][b]["brandOwnerSyskey"],
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
                                                          "stockData": [
                                                            {
                                                              "stockCode": discountStockList[a]["StockList"][b]["stockCode"],
                                                              "stockName": discountStockList[a]["StockList"][b]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : discountStockList[a]["StockList"][b]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": discountStockList[a]["StockList"][b]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": discountStockList[a]["StockList"][b]["qty"],
                                                              "lvlSyskey": discountStockList[a]["StockList"][b]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "normalPrice" : discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": discountStockList[a]["StockList"][b]["qty"] * discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "invoiceSyskey": "0",
                                                              "invoiceDate": date,
                                                              "appliedDate": date,
                                                              "promoDetailSyskey": "0",
                                                              "promotionStockList" : []
                                                            }
                                                          ],
                                                          "stockReturnData": []
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
                                                            "brandOwnerName": discountStockList[a]["StockList"][b]["brandOwnerName"],
                                                            "brandOwnerSyskey": discountStockList[a]["StockList"][b]["brandOwnerSyskey"],
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
                                                            "stockData": [
                                                              {
                                                                "stockCode": discountStockList[a]["StockList"][b]["stockCode"],
                                                                "stockName": discountStockList[a]["StockList"][b]["stockName"],
                                                                "recordStatus": 1,
                                                                "saleCurrCode": "MMK",
                                                                "stockSyskey" : discountStockList[a]["StockList"][b]["stockSyskey"],
                                                                "n1": "0",
                                                                "wareHouseSyskey": discountStockList[a]["StockList"][b]["wareHouseSyskey"],
                                                                "binSyskey": "0",
                                                                "qty": discountStockList[a]["StockList"][b]["qty"],
                                                                "lvlSyskey": discountStockList[a]["StockList"][b]["lvlSyskey"],
                                                                "lvlQty": 0.0,
                                                                "n8": 0.0,
                                                                "price": discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                                "normalPrice" : discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                                "n9": 0.0,
                                                                "taxAmount": 0.0,
                                                                "totalAmount": discountStockList[a]["StockList"][b]["qty"] * discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                                "taxCodeSK": "0",
                                                                "isTaxInclusice": 0,
                                                                "taxPercent": 0.0,
                                                                "discountAmount": 0.0,
                                                                "discountPercent": 0.0,
                                                                "discountStock": false,
                                                                "invoiceSyskey": "0",
                                                                "invoiceDate": date,
                                                                "appliedDate": date,
                                                                "promoDetailSyskey": "0",
                                                                "promotionStockList" : []
                                                              }
                                                            ],
                                                            "stockReturnData": []
                                                          });
                                                          // print(stockByBrandDel);

                                                        }
                                                      } else {
                                                        print("add stock to the same brandname");
                                                        for (var x = 0; x < sameBrandownerKey.length; x++) {
                                                          if (sameBrandownerKey[x]["stockData"].length == 0) {
                                                            print("same brandname but no stock");
                                                            List deletedList = sameBrandownerKey[x]["stockData"].where((element) => element["recordStatus"] == 4).toList();
                                                            String invSyskey = "0";
                                                            String invoiceDate = "";
                                                            String appliedDate = "";
                                                            String promoDetailSyskey = "0";
                                                            if(deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList().length != 0) {
                                                              invSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceSyskey"];
                                                              invoiceDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceDate"];
                                                              appliedDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["appliedDate"];
                                                              promoDetailSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["promoDetailSyskey"];
                                                            }
                                                            sameBrandownerKey[x]["stockData"].add({
                                                              "syskey": "0",
                                                              "recordStatus": 1,
                                                              "stockCode": "${discountStockList[a]["StockList"][b]["stockCode"]}",
                                                              "stockName": "${discountStockList[a]["StockList"][b]["stockName"]}",
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : "${discountStockList[a]["StockList"][b]["stockSyskey"]}",
                                                              "n1": "0",
                                                              "wareHouseSyskey": "${discountStockList[a]["StockList"][b]["wareHouseSyskey"]}",
                                                              "binSyskey": "0",
                                                              "qty": double.parse("${discountStockList[a]["StockList"][b]["qty"]}.0"),
                                                              "lvlSyskey": "${discountStockList[a]["StockList"][b]["lvlSyskey"]}",
                                                              "lvlQty": 1.0,
                                                              "n8": 1.0,
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": double.parse("${discountStockList[a]["StockList"][b]["qty"] * discountStockList[a]["StockList"][b]["totalAmount"]}.0"),
                                                              "price": double.parse("${discountStockList[a]["StockList"][b]["totalAmount"]}.0"),
                                                              "normalPrice" : double.parse("${discountStockList[a]["StockList"][b]["totalAmount"]}.0"),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "promotionStockList" : [],
                                                              "brandOwnerSyskey": "${discountStockList[a]["StockList"][b]["brandOwnerSyskey"]}",
                                                              "stockType": "NORMAL",
                                                              "invoiceSyskey": invSyskey,
                                                              "invoiceDate": invoiceDate,
                                                              "appliedDate": appliedDate,
                                                              "promoDetailSyskey": promoDetailSyskey,
                                                            });

                                                            if(getdeliverylist.length == 0) {
                                                            for (var j = 0; j < stockByBrandDel.length; j++) {
                                                              if (stockByBrandDel[j]["brandOwnerSyskey"].toString() == sameBrandownerKey[x]["brandOwnerSyskey"].toString()) {
                                                                List deletedList = stockByBrandDel[j]["stockData"].where((element) => element["recordStatus"] == 4).toList();
                                                                String invSyskey = "0";
                                                                String invoiceDate = "";
                                                                String appliedDate = "";
                                                                String promoDetailSyskey = "0";
                                                                if(deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList().length != 0) {
                                                                  invSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceSyskey"];
                                                                  invoiceDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceDate"];
                                                                  appliedDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["appliedDate"];
                                                                  promoDetailSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["promoDetailSyskey"];
                                                                }
                                                                stockByBrandDel[j]["stockData"].add({
                                                                  "stockCode": discountStockList[a]["StockList"][b]["stockCode"],
                                                                  "stockName": discountStockList[a]["StockList"][b]["stockName"],
                                                                  "recordStatus": 1,
                                                                  "saleCurrCode": "MMK",
                                                                  "stockSyskey" : discountStockList[a]["StockList"][b]["stockSyskey"],
                                                                  "n1": "0",
                                                                  "wareHouseSyskey": discountStockList[a]["StockList"][b]["wareHouseSyskey"],
                                                                  "binSyskey": "0",
                                                                  "qty": discountStockList[a]["StockList"][b]["qty"],
                                                                  "lvlSyskey": discountStockList[a]["StockList"][b]["lvlSyskey"],
                                                                  "lvlQty": 0.0,
                                                                  "n8": 0.0,
                                                                  "price": discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                                  "normalPrice" : discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                                  "n9": 0.0,
                                                                  "taxAmount":
                                                                      0.0,
                                                                  "totalAmount": discountStockList[a]["StockList"][b]["qty"] * discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                                  "taxCodeSK":
                                                                      "0",
                                                                  "isTaxInclusice":
                                                                      0,
                                                                  "taxPercent":
                                                                      0.0,
                                                                  "discountAmount": 0.0,
                                                                  "discountPercent": 0.0,
                                                                  "discountStock": false,
                                                                  "invoiceSyskey": invSyskey,
                                                                  "invoiceDate": invoiceDate,
                                                                  "appliedDate": appliedDate,
                                                                  "promoDetailSyskey": promoDetailSyskey,
                                                                  "promotionStockList" : []
                                                                });
                                                              }
                                                            }
                                                            }else {
                                                            for (var j = 0; j < getdeliverylist.length; j++) {
                                                              if (getdeliverylist[j]["brandOwnerSyskey"].toString() == sameBrandownerKey[x]["brandOwnerSyskey"].toString()) {
                                                                List deletedList = getdeliverylist[j]["stockData"].where((element) => element["recordStatus"] == 4).toList();
                                                                String invSyskey = "0";
                                                                String invoiceDate = "";
                                                                String appliedDate = "";
                                                                String promoDetailSyskey = "0";
                                                                if(deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList().length != 0) {
                                                                  invSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceSyskey"];
                                                                  invoiceDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceDate"];
                                                                  appliedDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["appliedDate"];
                                                                  promoDetailSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["promoDetailSyskey"];
                                                                }
                                                                getdeliverylist[j]["stockData"].add({
                                                                  "stockCode": discountStockList[a]["StockList"][b]["stockCode"],
                                                                  "stockName": discountStockList[a]["StockList"][b]["stockName"],
                                                                  "recordStatus": 1,
                                                                  "saleCurrCode": "MMK",
                                                                  "stockSyskey" : discountStockList[a]["StockList"][b]["stockSyskey"],
                                                                  "n1": "0",
                                                                  "wareHouseSyskey": discountStockList[a]["StockList"][b]["wareHouseSyskey"],
                                                                  "binSyskey": "0",
                                                                  "qty": discountStockList[a]["StockList"][b]["qty"],
                                                                  "lvlSyskey": discountStockList[a]["StockList"][b]["lvlSyskey"],
                                                                  "lvlQty": 0.0,
                                                                  "n8": 0.0,
                                                                  "price": discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                                  "normalPrice" : discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                                  "n9": 0.0,
                                                                  "taxAmount":
                                                                      0.0,
                                                                  "totalAmount": discountStockList[a]["StockList"][b]["qty"] * discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                                  "taxCodeSK":
                                                                      "0",
                                                                  "isTaxInclusice":
                                                                      0,
                                                                  "taxPercent":
                                                                      0.0,
                                                                  "discountAmount": 0.0,
                                                                  "discountPercent": 0.0,
                                                                  "discountStock": false,
                                                                  "invoiceSyskey": invSyskey,
                                                                  "invoiceDate": invoiceDate,
                                                                  "appliedDate": appliedDate,
                                                                  "promoDetailSyskey": promoDetailSyskey,
                                                                  "promotionStockList" : []
                                                                });
                                                              }
                                                            }
                                                            }
                                                            
                                                          } else {
                                                            if (sameBrandownerKey[x]["stockData"].where((element) => element["stockCode"].toString() == discountStockList[a]["StockList"][b]["stockCode"].toString()).toList().length == 0) {
                                                              check = "true";
                                                            } else {
                                                              check = "";
                                                              print(sameBrandownerKey[x]["stockData"].where((element) => element["stockCode"].toString() == discountStockList[a]["StockList"][b]["stockCode"].toString()).toList());
                                                            }
                                                            if (check == "true") {
                                                              print(
                                                                  "add new stock to the same brandname");
                                                              for(var p = 0; p < newList.length; p++) {
                                                                if(newList[p]["brandOwnerSyskey"] == discountStockList[a]["StockList"][b]["brandOwnerSyskey"]) {
                                                                  print("3newList ==> ${newList[0]["stockData"]}");

                                                                  List deletedList = newList[p]["stockData"].where((element) => element["recordStatus"] == 4).toList();
                                                                  String invSyskey = "0";
                                                                  String invoiceDate = "";
                                                                  String appliedDate = "";
                                                                  String promoDetailSyskey = "0";
                                                                  if(deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList().length != 0) {
                                                                    invSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceSyskey"];
                                                                    invoiceDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceDate"];
                                                                    appliedDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["appliedDate"];
                                                                    promoDetailSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["promoDetailSyskey"];
                                                                  }
                                                                  newList[p]["stockData"].add({
                                                                "syskey": "0",
                                                                "recordStatus":
                                                                    1,
                                                                "stockCode":
                                                                    "${discountStockList[a]["StockList"][b]["stockCode"]}",
                                                                "stockName":
                                                                    "${discountStockList[a]["StockList"][b]["stockName"]}",
                                                                "saleCurrCode":
                                                                    "MMK",
                                                                "stockSyskey" : "${discountStockList[a]["StockList"][b]["stockSyskey"]}",
                                                                "n1": "0",
                                                                "wareHouseSyskey":
                                                                    "${discountStockList[a]["StockList"][b]["wareHouseSyskey"]}",
                                                                "binSyskey":
                                                                    "0",
                                                                "qty": double.parse(
                                                                    "${discountStockList[a]["StockList"][b]["qty"]}.0"),
                                                                "lvlSyskey":
                                                                    "${discountStockList[a]["StockList"][b]["lvlSyskey"]}",
                                                                "lvlQty": 1.0,
                                                                "n8": 1.0,
                                                                "n9": 0.0,
                                                                "taxAmount":
                                                                    0.0,
                                                                "totalAmount":
                                                                    double.parse(
                                                                        "${discountStockList[a]["StockList"][b]["totalAmount"] * discountStockList[a]["StockList"][b]["qty"]}.0"),
                                                                "price": double.parse("${discountStockList[a]["StockList"][b]["totalAmount"]}.0"),
                                                                "normalPrice" : double.parse("${discountStockList[a]["StockList"][b]["totalAmount"]}.0"),
                                                                "taxCodeSK":
                                                                    "0",
                                                                "isTaxInclusice":
                                                                    0,
                                                                "taxPercent":
                                                                    0.0,
                                                                "discountAmount": 0.0,
                                                                "discountPercent": 0.0,
                                                                "promotionStockList" : [],
                                                                "brandOwnerSyskey":
                                                                    "${discountStockList[a]["StockList"][b]["brandOwnerSyskey"]}",
                                                                "stockType":
                                                                    "NORMAL",
                                                                "invoiceSyskey": invSyskey,
                                                                "invoiceDate": invoiceDate,
                                                                "appliedDate": appliedDate,
                                                                "promoDetailSyskey": promoDetailSyskey,
                                                              });
                                                              if (getdeliverylist
                                                                      .toString() !=
                                                                  "[]") {
                                                                for (var j = 0;
                                                                    j <
                                                                        getdeliverylist
                                                                            .length;
                                                                    j++) {
                                                                  if (getdeliverylist[j]["brandOwnerSyskey"].toString() ==
                                                                      discountStockList[a]["StockList"][b]["brandOwnerSyskey"].toString()) {
                                                                    
                                                                    List deletedList = getdeliverylist[j]["stockData"].where((element) => element["recordStatus"] == 4).toList();
                                                                    String invSyskey = "0";
                                                                    String invoiceDate = "";
                                                                    String appliedDate = "";
                                                                    String promoDetailSyskey = "0";
                                                                    if(deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList().length != 0) {
                                                                      invSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceSyskey"];
                                                                      invoiceDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceDate"];
                                                                      appliedDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["appliedDate"];
                                                                      promoDetailSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["promoDetailSyskey"];
                                                                    }
                                                                    
                                                                    getdeliverylist[j]
                                                                            [
                                                                            "stockData"]
                                                                        .add({
                                                                      "stockCode":
                                                                          discountStockList[a]["StockList"][b]
                                                                              [
                                                                              "stockCode"],
                                                                      "stockName":
                                                                          discountStockList[a]["StockList"][b]
                                                                              [
                                                                              "stockName"],
                                                                      "recordStatus":
                                                                          1,
                                                                      "saleCurrCode":
                                                                          "MMK",
                                                                      "stockSyskey" : discountStockList[a]["StockList"][b]
                                                                              [
                                                                              "stockSyskey"],
                                                                      "n1": "0",
                                                                      "wareHouseSyskey":
                                                                          discountStockList[a]["StockList"][b]
                                                                              [
                                                                              "wareHouseSyskey"],
                                                                      "binSyskey":
                                                                          "0",
                                                                      "qty": discountStockList[a]["StockList"][b]["qty"],
                                                                      "lvlSyskey":
                                                                          discountStockList[a]["StockList"][b]
                                                                              [
                                                                              "lvlSyskey"],
                                                                      "lvlQty":
                                                                          0.0,
                                                                      "n8": 0.0,
                                                                      "price": discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                                      "normalPrice" : discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                                      "n9": 0.0,
                                                                      "taxAmount":
                                                                          0.0,
                                                                      "totalAmount": discountStockList[a]["StockList"][b]["qty"] * discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                                      "taxCodeSK":
                                                                          "0",
                                                                      "isTaxInclusice":
                                                                          0,
                                                                      "taxPercent":
                                                                          0.0,
                                                                      "discountAmount": 0.0,
                                                                      "discountPercent": 0.0,
                                                                      "discountStock": false,
                                                                      "invoiceSyskey": invSyskey,
                                                                      "invoiceDate": invoiceDate,
                                                                      "appliedDate": appliedDate,
                                                                      "promoDetailSyskey": promoDetailSyskey,
                                                                      "promotionStockList" : []
                                                                    });
                                                                  }

                                                                  for (var m =
                                                                          0;
                                                                      m <
                                                                          getdeliverylist[j]["stockData"]
                                                                              .length;
                                                                      m++) {
                                                                    print(getdeliverylist[
                                                                            j][
                                                                        "stockData"][m]);
                                                                  }

                                                                  if(newList[p]["stockData"].where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList().length != 0) {
                                                                    newList[p]["stockData"].removeWhere((element) => element["qty"].runtimeType.toString() == "int");
                                                                  }
                                                                }
                                                              } else {
                                                                for (var j = 0;
                                                                    j <
                                                                        stockByBrandDel
                                                                            .length;
                                                                    j++) {
                                                                  if (stockByBrandDel[j]
                                                                              [
                                                                              "brandOwnerSyskey"]
                                                                          .toString() ==
                                                                      sameBrandownerKey[x]
                                                                              [
                                                                              "brandOwnerSyskey"]
                                                                          .toString()) {
                                                                    List deletedList = stockByBrandDel[j]["stockData"].where((element) => element["recordStatus"] == 4).toList();
                                                                    String invSyskey = "0";
                                                                    String invoiceDate = "";
                                                                    String appliedDate = "";
                                                                    String promoDetailSyskey = "0";
                                                                    if(deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList().length != 0) {
                                                                      invSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceSyskey"];
                                                                      invoiceDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["invoiceDate"];
                                                                      appliedDate = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["appliedDate"];
                                                                      promoDetailSyskey = deletedList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["promoDetailSyskey"];
                                                                    }
                                                                    
                                                                    stockByBrandDel[j]
                                                                            [
                                                                            "stockData"]
                                                                        .add({
                                                                      "stockCode":
                                                                          discountStockList[a]["StockList"][b][
                                                                              "stockCode"],
                                                                      "stockName":
                                                                          discountStockList[a]["StockList"][b][
                                                                              "stockName"],
                                                                      "recordStatus":
                                                                          1,
                                                                      "saleCurrCode":
                                                                          "MMK",
                                                                      "stockSyskey" : discountStockList[a]["StockList"][b][
                                                                              "stockSyskey"],
                                                                      "n1": "0",
                                                                      "wareHouseSyskey":
                                                                          discountStockList[a]["StockList"][b][
                                                                              "wareHouseSyskey"],
                                                                      "binSyskey":
                                                                          "0",
                                                                      "qty": discountStockList[a]["StockList"][b][
                                                                          "qty"],
                                                                      "lvlSyskey":
                                                                          discountStockList[a]["StockList"][b][
                                                                              "lvlSyskey"],
                                                                      "lvlQty":
                                                                          0.0,
                                                                      "n8": 0.0,
                                                                      "price": discountStockList[a]["StockList"][b][
                                                                          "totalAmount"].toDouble(),
                                                                      "normalPrice" : discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                                      "n9": 0.0,
                                                                      "taxAmount":
                                                                          0.0,
                                                                      "totalAmount": discountStockList[a]["StockList"][b]["qty"] * discountStockList[a]["StockList"][b]["totalAmount"].toDouble(),
                                                                      "taxCodeSK":
                                                                          "0",
                                                                      "isTaxInclusice":
                                                                          0,
                                                                      "taxPercent":
                                                                          0.0,
                                                                      "discountAmount": 0.0,
                                                                      "discountPercent": 0.0,
                                                                      "discountStock": false,
                                                                      "invoiceSyskey": invSyskey,
                                                                      "invoiceDate": invoiceDate,
                                                                      "appliedDate": appliedDate,
                                                                      "promoDetailSyskey": promoDetailSyskey,
                                                                      "promotionStockList" : []
                                                                    });
                                                                  }

                                                                  for (var m =
                                                                          0;
                                                                      m <
                                                                          stockByBrandDel[j]["stockData"]
                                                                              .length;
                                                                      m++) {
                                                                    print(stockByBrandDel[
                                                                            j][
                                                                        "stockData"][m]);
                                                                  }
                                                                }
                                                              }

                                                              

                                                                }

                                                              }
                                                            } else if (check ==
                                                                "") {
                                                              print("add stockQty with same stock and same brandname");
                                                              for (var n = 0; n < sameBrandownerKey[x]["stockData"].length; n++) {
                                                                if (sameBrandownerKey[x]["stockData"][n]["stockCode"] == discountStockList[a]["StockList"][b]["stockCode"]) {
                                                                  sameBrandownerKey[x]["stockData"][n]["qty"] =
                                                                      double.parse(
                                                                          "${discountStockList[a]["StockList"][b]["qty"] + sameBrandownerKey[x]["stockData"][n]["qty"]}");

                                                                  // sameBrandownerKey[x]["stockData"][n]["totalAmount"] = sameBrandownerKey[x]["stockData"][n]["price"] * sameBrandownerKey[x]["stockData"][n]["qty"];

                                                                  if(discountCheckList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"].toString()).toList().length != 0) {
                                                                    
                                                                    _handleSubmit(context);
                                                                    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                    getSysKey.then((val) {
                                                                      var param;
                                                                      if(discountStockListDate.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"].toString() && element["createddate"] == discountStockList[a]["StockList"][b]["appliedDate"].toString()).toList().length != 0) {
                                                                        param = jsonEncode(
                                                                          {
                                                                            "itemSyskey": "${discountStockList[a]["StockList"][b]["stockSyskey"]}",
	                                                                          "itemDesc": "${discountStockList[a]["StockList"][b]["stockName"]}",
	                                                                          "itemAmount": discountStockList[a]["StockList"][b]["totalAmount"].toInt(),
	                                                                          "itemTotalAmount": sameBrandownerKey[x]["stockData"][n]["qty"].toInt() * discountStockList[a]["StockList"][b]["totalAmount"].toInt(),
	                                                                          "itemQty": sameBrandownerKey[x]["stockData"][n]["qty"].toInt(),
                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                            "date": "${discountStockListDate.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                                                                          }
                                                                        );
                                                                      } else {
                                                                        datetime();
                                                                        param = jsonEncode(
                                                                          {
                                                                            "itemSyskey": "${discountStockList[a]["StockList"][b]["stockSyskey"]}",
	                                                                          "itemDesc": "${discountStockList[a]["StockList"][b]["stockName"]}",
	                                                                          "itemAmount": discountStockList[a]["StockList"][b]["totalAmount"].toInt(),
	                                                                          "itemTotalAmount": sameBrandownerKey[x]["stockData"][n]["qty"].toInt() * discountStockList[a]["StockList"][b]["totalAmount"].toInt(),
	                                                                          "itemQty": sameBrandownerKey[x]["stockData"][n]["qty"].toInt(),
                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                            "date": "$date"
                                                                          }
                                                                        );
                                                                      }

                                                                      getVolDisCalculation(param, sameBrandownerKey[x]["stockData"], context, false).then((getVolDisCalculationValue) {
                                                                        if(getVolDisCalculationValue == "success") {
                                                                          if(newStockList.length != 0) {
                                                                            sameBrandownerKey[x]["stockData"] = newStockList;
                                                                            newList[x]["stockData"] = newStockList;

                                                                            print(newList[x]["stockData"]);
                                                                          }
                                                                          Navigator.pop(context);
                                                                          
                                                                        }else if(getVolDisCalculationValue == "fail") {
                                                                          Navigator.pop(context);
                                                                          snackbarmethod("FAIL!");
                                                                        }else {
                                                                          Navigator.pop(context);
                                                                          getVolDisCalculationDialog(param, getVolDisCalculationValue.toString());
                                                                        }
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
                                                  } else if (discountStockList[a]["StockList"][b]["check"] == false) {
                                                    stockList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"]).toList()[0]["check"] = false;
                                                    for (var x = 0; x < newList.length; x++) {
                                                      if (newList[x]["brandOwnerSyskey"] == discountStockList[a]["StockList"][b]["brandOwnerSyskey"]) {
                                                        for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                          if (newList[x]["stockData"][y]["stockCode"] == discountStockList[a]["StockList"][b]["stockCode"]) {
                                                            newList[x]["stockData"][y]["qty"] = double.parse("${newList[x]["stockData"][y]["qty"] - discountStockList[a]["StockList"][b]["qty"]}");

                                                            if(discountCheckList.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"].toString()).toList().length != 0) {
                                                              
                                                              if(newList[x]["stockData"][y]["qty"].toString() != "0.0") {
                                                                    ShopsbyUser helperShopsbyUser = ShopsbyUser();
                                                                    _handleSubmit(context);
                                                                    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                    getSysKey.then((val) {
                                                                      var param;
                                                                      if(discountStockListDate.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"].toString() && element["createddate"] == discountStockList[a]["StockList"][b]["appliedDate"].toString()).toList().length != 0) {
                                                                        param = jsonEncode(
                                                                          {
                                                                            "itemSyskey": "${discountStockList[a]["StockList"][b]["stockSyskey"]}",
	                                                                          "itemDesc": "${discountStockList[a]["StockList"][b]["stockName"]}",
	                                                                          "itemAmount": newList[x]["stockData"][y]["totalAmount"].toInt(),
	                                                                          "itemTotalAmount": newList[x]["stockData"][y]["qty"].toInt() * newList[x]["stockData"][y]["totalAmount"].toInt(),
	                                                                          "itemQty": newList[x]["stockData"][y]["qty"].toInt(),
                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                            "date": "${discountStockListDate.where((element) => element["stockSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                                                                          }
                                                                        );
                                                                      } else {
                                                                        datetime();
                                                                        param = jsonEncode(
                                                                          {
                                                                            "itemSyskey": "${discountStockList[a]["StockList"][b]["stockSyskey"]}",
	                                                                          "itemDesc": "${discountStockList[a]["StockList"][b]["stockName"]}",
	                                                                          "itemAmount": newList[x]["stockData"][y]["totalAmount"].toInt(),
	                                                                          "itemTotalAmount": newList[x]["stockData"][y]["qty"].toInt() * newList[x]["stockData"][y]["totalAmount"].toInt(),
	                                                                          "itemQty": newList[x]["stockData"][y]["qty"].toInt(),
                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                            "date": "$date"
                                                                          }
                                                                        );
                                                                      }

                                                                      getVolDisCalculation(param, newList[x]["stockData"], context, false).then((getVolDisCalculationValue) {
                                                                        if(getVolDisCalculationValue == "success") {
                                                                          if(newStockList.length != 0) {
                                                                            newList[x]["stockData"] = newStockList;
                                                                          }
                                                                          Navigator.pop(context);
                                                                          
                                                                        }else if(getVolDisCalculationValue == "fail") {
                                                                          Navigator.pop(context);
                                                                          snackbarmethod("FAIL!");
                                                                        }else {
                                                                          Navigator.pop(context);
                                                                          getVolDisCalculationDialog(param, getVolDisCalculationValue.toString());
                                                                        }
                                                                      });
                                                                    });
                                                              }
                                                                  }

                                                            print(getdeliverylist);
                                                            if (getdeliverylist == [] || getdeliverylist.length == 0) {
                                                              for (var j = 0; j < stockByBrandDel.length; j++) {
                                                                for (var k = 0; k < stockByBrandDel[j]["stockData"].length; k++) {
                                                                  if (stockByBrandDel[j]["stockData"][k]["stockCode"] == discountStockList[a]["StockList"][b]["stockCode"]) {
                                                                    stockByBrandDel[j]["stockData"][k]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                  }
                                                                }

                                                                stockByBrandDel[j]["stockData"].removeWhere((element) => element["qty"] == 0.0 || element["qty"] < 0);
                                                              }
                                                              
                                                            } else {
                                                              for (var j = 0; j < getdeliverylist.length; j++) {
                                                                for (var k = 0; k < getdeliverylist[j]["stockData"].length; k++) {
                                                                    if (getdeliverylist[j]["stockData"][k]["stockCode"] == discountStockList[a]["StockList"][b]["stockCode"]) {
                                                                      getdeliverylist[j]["stockData"][k]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                    }

                                                                  print(getdeliverylist[j]["stockData"][k]);
                                                                }

                                                                getdeliverylist[j]["stockData"]
                                                                    .removeWhere((element) => element["qty"] <= 0.0 || element["qty"] < 0);
                                                              }
                                                            }
                                                            
                                                            for (var v = 0; v < stockData.length; v++) {
                                                              if (stockData[v]["stockCode"] == discountStockList[a]["StockList"][b]["stockCode"]) {
                                                                stockData[v]["qty"] = newList[x]["stockData"][y]["qty"];
                                                              }
                                                            }

                                                            if (newList[x]["stockData"][y]["qty"] == 0.0) {
                                                              newList[x]["stockData"].removeWhere((element) => element["qty"] == 0.0);

                                                              stockData.removeWhere((element) => element["qty"] == 0.0);
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }

                                                  print(stockByBrandDel);

                                                  listForNewList = newList;
                                                });
                                              }),
                                          SizedBox(width: 10),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  171,
                                              height: 40,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 0),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "${discountStockList[a]["StockList"][b]["stockName"]}",
                                                    // overflow:
                                                    //     TextOverflow.ellipsis,
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                ),
                                              ))
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Row(
                                              children: <Widget>[
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            if (discountStockList[a]["StockList"][b]["qty"] == 1 || discountStockList[a]["StockList"][b]["qty"] < 1) {
                                                              //
                                                            } else {
                                                              setState(() {
                                                                discountStockList[a]["StockList"][b]["qty"]--;

                                                              });

                                                              if (discountStockList[a]["StockList"][b][
                                                                      "check"] ==
                                                                  true) {
                                                                for (var x = 0;
                                                                    x <
                                                                        newList
                                                                            .length;
                                                                    x++) {
                                                                  if (newList[x]
                                                                          [
                                                                          "brandOwnerSyskey"] ==
                                                                      discountStockList[a]["StockList"][b][
                                                                          "brandOwnerSyskey"]) {
                                                                    for (var y =
                                                                            0;
                                                                        y < newList[x]["stockData"].length;
                                                                        y++) {
                                                                      if (newList[x]["stockData"][y]
                                                                              [
                                                                              "stockCode"] ==
                                                                          discountStockList[a]["StockList"][b][
                                                                              "stockCode"]) {
                                                                        newList[x]["stockData"][y]["qty"] = newList[x]["stockData"][y]
                                                                                ["qty"] -
                                                                            1;
                                                                        newList[x]["stockData"][y]["totalAmount"] = discountStockList[a]["StockList"][b]["totalAmount"].toDouble() * discountStockList[a]["StockList"][b]["qty"];
                                                                        for (var v =
                                                                                0;
                                                                            v < stockData.length;
                                                                            v++) {
                                                                          if (stockData[v]["stockCode"] ==
                                                                              discountStockList[a]["StockList"][b]["stockCode"]) {
                                                                            stockData[v]["qty"] =
                                                                                newList[x]["stockData"][y]["qty"];
                                                                            stockData[v]["totalAmount"] = newList[x]["stockData"][y]["qty"] *
                                                                                newList[x]["stockData"][y]["totalAmount"];
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
                                                                        for(var n = 0; n < stockByBrandDel[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(stockByBrandDel[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              stockByBrandDel[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              stockByBrandDel[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
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
                                                                        for(var n = 0; n < getdeliverylist[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(getdeliverylist[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              getdeliverylist[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              getdeliverylist[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              } else {}
                                                              listForNewList = newList;
                                                            }
                                                          });
                                                        },
                                                        child: Center(
                                                            child: Icon(
                                                          const IconData(0xe15b,
                                                              fontFamily:
                                                                  'MaterialIcons'),
                                                          color: Colors.white,
                                                          size: 19,
                                                        )),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xffe53935),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                        border: Border(
                                                          top: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          bottom: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          left: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          right: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      height: 23,
                                                      width: 25,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _showIntDialog(discountStockList[a]["StockList"][b]["qty"]).then((value) {
                                                          setState(() {
                                                            discountStockList[a]["StockList"][b]["qty"] = value;

                                                            if (discountStockList[a]["StockList"][b]["check"] == true) {
                                                              List dropdown = [];

                                                              dropdown = originalQty.where((element) => element["stockCode"] == discountStockList[a]["StockList"][b]["stockCode"]).toList();

                                                              if (dropdown == [] || dropdown.length == 0) {
                                                                for (var x = 0; x < newList.length; x++) {
                                                                  for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                    if (newList[x]["stockData"][y]["stockCode"] == discountStockList[a]["StockList"][b]["stockCode"]) {
                                                                      newList[x]["stockData"][y]["qty"] = double.parse("$value");

                                                                      newList[x]["stockData"][y]["totalAmount"] = discountStockList[a]["StockList"][b]["totalAmount"].toDouble() * double.parse("$value");

                                                                      print(newList[x]["stockData"][y]["qty"]);

                                                                      // stockData[y]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                      for (var v = 0; v < stockData.length; v++) {
                                                                        if (stockData[v]["stockCode"] == discountStockList[a]["StockList"][b]["stockCode"]) {
                                                                          stockData[v]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                          stockData[v]["totalAmount"] = newList[x]["stockData"][y]["qty"] * newList[x]["stockData"][y]["totalAmount"];
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                              if (dropdown != [] || dropdown.length != 0) {
                                                                for (var v = 0; v < dropdown.length; v++) {
                                                                  for (var x = 0; x < newList.length; x++) {
                                                                    for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                      if (newList[x]["stockData"][y]["stockCode"] == dropdown[v]["stockCode"]) {
                                                                        newList[x]["stockData"][y]["qty"] = double.parse("${value + dropdown[v]["qty"]}");

                                                                        newList[x]["stockData"][y]["totalAmount"] = discountStockList[a]["StockList"][b]["totalAmount"].toDouble() * discountStockList[a]["StockList"][b]["qty"];

                                                                        print(newList[x]["stockData"][y]["qty"]);
                                                                        print("object");
                                                                        // stockData[y]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                        for (var v = 0; v < stockData.length; v++) {
                                                                          if (stockData[v]["stockCode"] == discountStockList[a]["StockList"][b]["stockCode"]) {
                                                                            stockData[v]["qty"] = newList[x]["stockData"][y]["qty"];

                                                                            stockData[v]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"] * newList[x]["stockData"][y]["qty"];
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
                                                                        for(var n = 0; n < stockByBrandDel[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(stockByBrandDel[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              stockByBrandDel[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              stockByBrandDel[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
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
                                                                        for(var n = 0; n < getdeliverylist[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(getdeliverylist[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              getdeliverylist[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              getdeliverylist[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                            } else {}

                                                            listForNewList = newList;

                                                          });
                                                        });
                                                      },
                                                      child: Container(
                                                        child: Center(
                                                            child: Text(
                                                                "${discountStockList[a]["StockList"][b]["qty"]}")),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border(
                                                            top: BorderSide(
                                                                width: 0.5,
                                                                color: Colors
                                                                    .grey),
                                                            bottom: BorderSide(
                                                                width: 0.5,
                                                                color: Colors
                                                                    .grey),
                                                            left: BorderSide(
                                                                width: 0.5,
                                                                color: Colors
                                                                    .white),
                                                            right: BorderSide(
                                                                width: 0.5,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                        height: 27,
                                                        width: 45,
                                                      ),
                                                    ),
                                                    Container(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (discountStockList[a]["StockList"][b]["qty"] >= 99999) {
                                                            //
                                                          } else {
                                                            setState(() {
                                                              discountStockList[a]["StockList"][b]["qty"]++;

                                                              if (discountStockList[a]["StockList"][b]["check"] == true) {
                                                                for (var x = 0; x < newList.length; x++) {
                                                                  if (newList[x]["brandOwnerSyskey"] == discountStockList[a]["StockList"][b]["brandOwnerSyskey"]) {
                                                                    for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                      if (newList[x]["stockData"][y]["stockCode"] == discountStockList[a]["StockList"][b]["stockCode"]) {
                                                                        newList[x]["stockData"][y]["qty"] = newList[x]["stockData"][y]["qty"] + 1;
                                                                        newList[x]["stockData"][y]["totalAmount"] = discountStockList[a]["StockList"][b]["totalAmount"].toDouble() * discountStockList[a]["StockList"][b]["qty"];
                                                                        for (var v = 0; v < stockData.length; v++) {
                                                                          if (stockData[v]["stockCode"] == discountStockList[a]["StockList"][b]["stockCode"]) {
                                                                            stockData[v]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                            stockData[v]["totalAmount"] = newList[x]["stockData"][y]["qty"] * newList[x]["stockData"][y]["totalAmount"];
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
                                                                        for(var n = 0; n < stockByBrandDel[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(stockByBrandDel[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              stockByBrandDel[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              stockByBrandDel[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
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
                                                                        for(var n = 0; n < getdeliverylist[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(getdeliverylist[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              getdeliverylist[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              getdeliverylist[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              } else {}
                                                              listForNewList = newList;

                                                            });
                                                          }
                                                        },
                                                        child: Center(
                                                            child: Icon(
                                                                Icons.add,
                                                                size: 19,
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                        color:
                                                            Color(0xffe53935),
                                                        border: Border(
                                                          top: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          bottom: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          left: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          right: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      height: 23,
                                                      width: 25,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15),
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                    "${discountStockList[a]["StockList"][b]["totalAmount"]}"),
                                                SizedBox(width: 40),
                                                Text(
                                                    "${discountStockList[a]["StockList"][b]["totalAmount"] * discountStockList[a]["StockList"][b]["qty"]}"),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () async {
                                  if(listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"].toString()).toList().length != 0) {
                                    List detailList = [];
                                    List sameDetailList = [];
                                    String headerSyskey = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"].toString()).toList()[0]["HeaderSyskey"];
                                    String ruleNumber = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"].toString()).toList()[0]["RuleNumber"];
                                    String rulePriority = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == discountStockList[a]["StockList"][b]["stockSyskey"].toString()).toList()[0]["RulePriority"];
                                    for(var j = 0; j < multiDiscountStockList.length; j++) {
                                      if(multiDiscountStockList[j]["HeaderSyskey"] == headerSyskey) {
                                        sameDetailList = multiDiscountStockList[j]["DetailList"].where((element) => element["RuleNumber"] == ruleNumber && element["RulePriority"] == rulePriority).toList();
                                      }
                                    }
                                    detailList.add({
                                      "PromoItemSyskey" : discountStockList[a]["StockList"][b]["stockSyskey"],
                                      "PromoItemDesc" : discountStockList[a]["StockList"][b]["stockName"],
                                      "HeaderList" : [
                                        {
                                          "DetailList": sameDetailList,
                                          "ToDate" : multiDiscountStockList.where((element) => element["HeaderSyskey"] == headerSyskey).toList()[0]["ToDate"]
                                        }
                                      ]
                                    });
                                    print(detailList);
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DiscountDetail(detail: detailList, stockDetail: discountStockList[a]["StockList"][b],)));
                                  } else {
                                  _handleSubmit(context);
                                  final SharedPreferences preferences = await SharedPreferences.getInstance();
                                  var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                  getSysKey.then((val) {
                                    getPromoItemDetail("${val[0]["shopsyskey"]}", "${discountStockList[a]["hdrSyskey"]}", discountStockList[a]["StockList"][b]["stockSyskey"], discountStockList[a]["StockList"][b]["brandOwnerSyskey"]).then((promoDetailVal) {
                                      Navigator.pop(context);
                                      if (promoDetailVal == "success") {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => DiscountDetail(detail: promoItemDetailList, stockDetail: discountStockList[a]["StockList"][b])));
                                      } else {
                                        snackbarmethod("FAIL!");
                                      }
                                    });
                                  });
                                  }
                                },
                                child: Image.asset("assets/discount.png", width: 27,)),
                            ),
                          )
                        ],
                      ),
                      ],
                    ),
                  )
                ],
              )
          ],
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
        // integerNumberPicker.animateInt(currentPrice);
      }
    });
    return currentPrice;
  }

  void onChanged(String value) {
    setState(() {
      if (value == null || value == '') {
        discountStockList = widget.disItemList;
      } else {
        setState(() {
          discountStockList = widget.disItemList
              .where((element) =>
                  element["StockList"]
                      .where((element1) => element1["stockName"]
                          .toString()
                          .toLowerCase()
                          .contains(value.toString().toLowerCase()))
                      .toList()
                      .length !=
                  0)
              .toList();
        });

        print(newList);
      }
    });
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

  Future<void> getVolDisCalculationDialog(var param, String title) async {
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
                  getVolDisCalculation(param, [], context, false);
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
}

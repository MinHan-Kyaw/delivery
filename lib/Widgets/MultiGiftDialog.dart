import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:numberpicker/numberpicker.dart';

Future showMultiGiftDialog(
    List giftList, List getPromoStockList, context) async {
      print(giftList);
      print(getPromoStockList);
  for (var a = 0; a < giftList.length; a++) {
    giftList[a]["stockList"] = giftList[a]["stockList"].toSet().toList();
    for (var ab = 0; ab < giftList[a]["giftInfoList"].length; ab++) {
      List<Map<String, Object>> list = [];
      
      for (var b = 0; b < giftList[a]["giftInfoList"][ab].length; b++) {

        if (giftList[a]["giftInfoList"][ab][b]["discountItemRuleType"] ==
            "Total Item") {

          List endTypeList = [];

          for(var d = 0; d < giftList[a]["giftInfoList"].length; d++) {
            endTypeList = giftList[a]["giftInfoList"][d].where((element) => element["discountItemEndType"] == "END").toList();
          }

          double discountTotalQty = endTypeList.where((element) => element["discountItemEndType"] == "END").toList()[0]["discountItemQty"];

          double qty = double.parse((discountTotalQty ~/ giftList[a]["giftInfoList"].length)
              .toInt()
              .toString());

          if (ab == giftList[a]["giftInfoList"].length - 1) {
            qty = double.parse((discountTotalQty ~/
                        giftList[a]["giftInfoList"].length)
                    .toInt()
                    .toString()) +
                discountTotalQty %
                    giftList[a]["giftInfoList"].length;
          }

          double orQty = 0.0;

          if (giftList[a]["giftInfoList"][ab][b]["discountItemEndType"] ==
              "OR") {
            orQty = double.parse((qty ~/ giftList[a]["giftInfoList"][ab].length)
                .toInt()
                .toString());
          } else {
            if (b - 1 > -1) {
              if (giftList[a]["giftInfoList"][ab][b - 1]
                      ["discountItemEndType"] ==
                  "OR") {
                orQty = double.parse(
                        (qty ~/ giftList[a]["giftInfoList"][ab].length)
                            .toInt()
                            .toString()) +
                    (qty % giftList[a]["giftInfoList"][ab].length);
              }
            }
          }

          list.add({
            "discountItemEndType": giftList[a]["giftInfoList"][ab][b]
                ["discountItemEndType"],
            "discountStockCode": giftList[a]["giftInfoList"][ab][b]
                ["discountStockCode"],
            "discountItemDesc": giftList[a]["giftInfoList"][ab][b]
                ["discountItemDesc"],
            "discountItemQty": giftList[a]["giftInfoList"][ab].length < 2 ? qty :
             giftList[a]["giftInfoList"][ab][b]
                            ["discountItemEndType"] ==
                        "OR" || 
                    giftList[a]["giftInfoList"][ab][b - 1]
                            ["discountItemEndType"] ==
                        "OR"
                ? orQty
                : qty,
            "discountItemType": giftList[a]["giftInfoList"][ab][b]
                ["discountItemType"],
            "discountItemRuleType": giftList[a]["giftInfoList"][ab][b]
                ["discountItemRuleType"],
            // "discountTotalQty": giftList[a]["giftInfoList"][ab][b]
            //     ["discountItemQty"],
            "discountTotalQty" : discountTotalQty,
            "discountStockSyskey": giftList[a]["giftInfoList"][ab][b]
                ["discountStockSyskey"],
            "discountItemSyskey": giftList[a]["giftInfoList"][ab][b]
                ["discountItemSyskey"],
            "discountGiftCode": giftList[a]["giftInfoList"][ab][b]
                ["discountGiftCode"],
            "checkValue": orQty == 0.0 || qty == 0.0 ? false : true
          });

        } else {
          list.add({
            "discountItemEndType": giftList[a]["giftInfoList"][ab][b]
                ["discountItemEndType"],
            "discountStockCode": giftList[a]["giftInfoList"][ab][b]
                ["discountStockCode"],
            "discountItemDesc": giftList[a]["giftInfoList"][ab][b]
                ["discountItemDesc"],
            "discountItemQty": giftList[a]["giftInfoList"][ab][b]
                ["discountItemQty"],
            "discountItemType": giftList[a]["giftInfoList"][ab][b]
                ["discountItemType"],
            "discountItemRuleType": giftList[a]["giftInfoList"][ab][b]
                ["discountItemRuleType"],
            "discountStockSyskey": giftList[a]["giftInfoList"][ab][b]
                ["discountStockSyskey"],
            "discountItemSyskey": giftList[a]["giftInfoList"][ab][b]
                ["discountItemSyskey"],
            "discountGiftCode": giftList[a]["giftInfoList"][ab][b]
                ["discountGiftCode"],
            "checkValue": true
          });
        }

        if (b == giftList[a]["giftInfoList"][ab].length - 1) {
          list.sort((a, b) {
            return a['discountItemDesc']
                .toString()
                .toLowerCase()
                .compareTo(b['discountItemDesc'].toString().toLowerCase());
          });

          giftList[a]["giftInfoList"][ab] = list;

          for (var c = 0; c < giftList[a]["giftInfoList"][ab].length; c++) {
            giftList[a]["giftQty"] = giftList[a]["giftQty"] +
                giftList[a]["giftInfoList"][ab][c]["discountItemQty"];
          }
        }
      }
    }
  }
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              content: Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Gift List",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffe53935)),
                      ),
                      for (var x = 0; x < giftList.length; x++)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                        color: Colors.grey[300],
                                      ),
                                      left: BorderSide(
                                        color: Colors.grey[300],
                                      ),
                                      right: BorderSide(
                                        color: Colors.grey[300],
                                      ),
                                      bottom: BorderSide.none)),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 10,
                                  ),
                                  for (var y = 0;
                                      y < giftList[x]["stockList"].length;
                                      y++)
                                    Column(
                                      children: <Widget>[
                                        if (y != 0)
                                          SizedBox(
                                            height: 5,
                                          ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Center(
                                            child: Text(
                                              getPromoStockList
                                                          .where((element) =>
                                                              element[
                                                                  "itemSyskey"] ==
                                                              giftList[x][
                                                                  "stockList"][y])
                                                          .toList()
                                                          .length ==
                                                      0
                                                  ? ""
                                                  : "${getPromoStockList.where((element) => element["itemSyskey"] == giftList[x]["stockList"][y]).toList()[0]["itemDesc"]}",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                  color: Color(0xffe53935)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                            if (giftList[x]["giftInfoList"].length != 0)
                              if (giftList[x]["giftInfoList"][0].length != 0)
                                if (giftList[x]["giftInfoList"][0][0].length != 0)
                                  if (giftList[x]["giftInfoList"][0][0]
                                          ["discountItemRuleType"] ==
                                      "Total Item")
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          border: Border(
                                              top: BorderSide(
                                                color: Colors.grey[300],
                                              ),
                                              left: BorderSide(
                                                color: Colors.grey[300],
                                              ),
                                              right: BorderSide(
                                                color: Colors.grey[300],
                                              ),
                                              bottom: BorderSide.none)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 10),
                                            child: Text(
                                              "Total Gift Qty (${giftList[x]["giftQty"].toInt()}/${giftList[x]["giftInfoList"][0][0]["discountTotalQty"].toInt()})",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xffe53935)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            Table(
                              border: TableBorder.all(
                                color: Colors.grey[300],
                                style: BorderStyle.solid,
                                width: 1,
                              ),
                              children: [
                                for (var a = 0;
                                    a < giftList[x]["giftInfoList"].length;
                                    a++)
                                  TableRow(children: [
                                    Column(
                                      children: <Widget>[
                                        if (giftList[x]["giftInfoList"][a]
                                                .length ==
                                            1)
                                          Column(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 12),
                                                      child: SizedBox(
                                                        height: 24.0,
                                                        width: 24.0,
                                                        child: Checkbox(
                                                          value: giftList[x]
                                                                  ["giftInfoList"]
                                                              [
                                                              a][0]["checkValue"],
                                                          activeColor:
                                                              Color(0xffe53935),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              print(value);
                                                              giftList[x]["giftInfoList"]
                                                                          [a][0][
                                                                      "checkValue"] =
                                                                  true;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                                .symmetric(
                                                            vertical: 5),
                                                        child: Text(
                                                          '${giftList[x]["giftInfoList"][a][0]["discountItemDesc"]}',
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (giftList[x]["giftInfoList"][a]
                                                          [0]
                                                      ["discountItemRuleType"] ==
                                                  "Total Item")
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 15, bottom: 10),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    children: <Widget>[
                                                      Container(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            setState(() {
                                                              if (giftList[x]["giftInfoList"]
                                                                          [a][0][
                                                                      "discountItemQty"] <=
                                                                  1) {
                                                                //
                                                              } else {
                                                                giftList[x]["giftInfoList"]
                                                                        [a][0][
                                                                    "discountItemQty"]--;
                                                                giftList[x]
                                                                    ["giftQty"]--;
                                                              }
                                                            });
                                                          },
                                                          child: Center(
                                                            child: Icon(
                                                              const IconData(
                                                                  0xe15b,
                                                                  fontFamily:
                                                                      'MaterialIcons'),
                                                              color: Colors.white,
                                                              size: 19,
                                                            ),
                                                          ),
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
                                                        height: 27,
                                                        width: 27,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          _showIntDialog(
                                                                  giftList[x]["giftInfoList"]
                                                                              [
                                                                              a][0]
                                                                          [
                                                                          "discountItemQty"]
                                                                      .toInt(),
                                                                  context)
                                                              .then((value) {
                                                            setState(() {
                                                              giftList[x]["giftInfoList"]
                                                                          [a][0][
                                                                      "discountItemQty"] =
                                                                  0.0;
                                                              giftList[x][
                                                                      "giftQty"] =
                                                                  0.0;
                                                              for (var i = 0;
                                                                  i <
                                                                      giftList[x][
                                                                              "giftInfoList"]
                                                                          .length;
                                                                  i++) {
                                                                giftList[x][
                                                                    "giftQty"] = giftList[
                                                                            x][
                                                                        "giftQty"] +
                                                                    giftList[x]["giftInfoList"]
                                                                            [i][0]
                                                                        [
                                                                        "discountItemQty"];
                                                              }

                                                              if (value >=
                                                                  (giftList[x]["giftInfoList"]
                                                                              [
                                                                              a][0]
                                                                          [
                                                                          "discountTotalQty"] -
                                                                      giftList[x][
                                                                          "giftQty"])) {
                                                                value = (giftList[x]
                                                                                [
                                                                                "giftInfoList"]
                                                                            [a][0]
                                                                        [
                                                                        "discountTotalQty"] -
                                                                    giftList[x][
                                                                        "giftQty"]);
                                                              }

                                                              giftList[x]["giftInfoList"]
                                                                          [a][0][
                                                                      "discountItemQty"] =
                                                                  value;

                                                              giftList[x][
                                                                      "giftQty"] =
                                                                  0.0;

                                                              for (var i = 0;
                                                                  i <
                                                                      giftList[x][
                                                                              "giftInfoList"]
                                                                          .length;
                                                                  i++) {
                                                                giftList[x][
                                                                    "giftQty"] = giftList[
                                                                            x][
                                                                        "giftQty"] +
                                                                    giftList[x]["giftInfoList"]
                                                                            [i][0]
                                                                        [
                                                                        "discountItemQty"];
                                                              }
                                                            });
                                                          });
                                                        },
                                                        child: Container(
                                                          child: Center(
                                                              child: Text(
                                                                  "${giftList[x]["giftInfoList"][a][0]["discountItemQty"].toInt()}")),
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
                                                          onTap: () async {
                                                            setState(() {
                                                              if (giftList[x][
                                                                      "giftQty"] >=
                                                                  giftList[x]["giftInfoList"]
                                                                          [a][0][
                                                                      "discountTotalQty"]) {
                                                                //
                                                              } else {
                                                                giftList[x]["giftInfoList"]
                                                                        [a][0][
                                                                    "discountItemQty"]++;
                                                                giftList[x]
                                                                    ["giftQty"]++;
                                                              }
                                                            });
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
                                                        height: 27,
                                                        width: 27,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                            ],
                                          ),
                                        if (giftList[x]["giftInfoList"][a]
                                                .length >
                                            1)
                                          for (var b = 0;
                                              b <
                                                  giftList[x]["giftInfoList"][a]
                                                      .length;
                                              b++)
                                            Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 12,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      bottom: 12),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 12),
                                                        child: SizedBox(
                                                          height: 24.0,
                                                          width: 24.0,
                                                          child: Checkbox(
                                                            value: giftList[x][
                                                                    "giftInfoList"]
                                                                [
                                                                a][b]["checkValue"],
                                                            activeColor:
                                                                Color(0xffe53935),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                print(value);
                                                                giftList[x]["giftInfoList"][a][b]["checkValue"] = value;
                                                                // if (value == false) {
                                                                //   if (giftList[x]["giftInfoList"][a][b]["discountItemEndType"] == "OR") {
                                                                //     if(b + 1 <= giftList[x]["giftInfoList"][a].length-1) {
                                                                //       if (giftList[x]["giftInfoList"][a][b + 1]["checkValue"] == false) {
                                                                //         print("aa");
                                                                //         giftList[x]["giftInfoList"][a][b]["checkValue"] = true;
                                                                //       }
                                                                //     }
                                                                //   } else {
                                                                //     if (b - 1 > -1) {
                                                                //       if (giftList[x]["giftInfoList"][a][b - 1]["discountItemEndType"] == "OR") {
                                                                //         if (giftList[x]["giftInfoList"][a][b - 1]["checkValue"] == false) {
                                                                //           print("bb");
                                                                //           giftList[x]["giftInfoList"][a][b]["checkValue"] = true;
                                                                //         }
                                                                //       }
                                                                //     }
                                                                //   }
                                                                // }

                                                                if(giftList[x]["giftInfoList"][a].where((element) => element["checkValue"] == true).toList().length == 0) {
                                                                  giftList[x]["giftInfoList"][a][b]["checkValue"] = true;
                                                                } else {
                                                                  
                                                                if (giftList[x]["giftInfoList"][a][b]["checkValue"] == false) {
                                                                  giftList[x]["giftQty"] = giftList[x]["giftQty"] - giftList[x]["giftInfoList"][a][b]["discountItemQty"];
                                                                } else {
                                                                  if(giftList[x]["giftQty"] + giftList[x]["giftInfoList"][a][b]["discountItemQty"] > giftList[x]["giftInfoList"][a][b]["discountTotalQty"]) {
                                                                    giftList[x]["giftInfoList"][a][b]["discountItemQty"] = giftList[x]["giftQty"] - giftList[x]["giftInfoList"][a][b]["discountTotalQty"];
                                                                  }
                                                                  giftList[x]["giftQty"] = giftList[x]["giftQty"] + giftList[x]["giftInfoList"][a][b]["discountItemQty"];
                                                                }
                                                                }
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 5),
                                                          child: Text(
                                                            '${giftList[x]["giftInfoList"][a][b]["discountItemDesc"]}',
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (giftList[x]["giftInfoList"][a]
                                                            [0][
                                                        "discountItemRuleType"] ==
                                                    "Total Item")
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15, bottom: 10),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Container(
                                                          child: GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                if (giftList[x]["giftInfoList"]
                                                                            [a][b]
                                                                        [
                                                                        "discountItemQty"] <=
                                                                    1) {
                                                                  //
                                                                } else if (giftList[x]
                                                                                [
                                                                                "giftInfoList"]
                                                                            [a][b]
                                                                        [
                                                                        "checkValue"] ==
                                                                    false) {
                                                                  giftList[x]["giftInfoList"]
                                                                          [a][b][
                                                                      "discountItemQty"]--;
                                                                } else {
                                                                  giftList[x]["giftInfoList"]
                                                                          [a][b][
                                                                      "discountItemQty"]--;
                                                                  giftList[x][
                                                                      "giftQty"]--;
                                                                }
                                                              });
                                                            },
                                                            child: Center(
                                                              child: Icon(
                                                                const IconData(
                                                                    0xe15b,
                                                                    fontFamily:
                                                                        'MaterialIcons'),
                                                                color:
                                                                    Colors.white,
                                                                size: 19,
                                                              ),
                                                            ),
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Color(0xffe53935),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(3),
                                                            border: Border(
                                                              top: BorderSide(
                                                                  width: 0.5,
                                                                  color: Colors
                                                                      .white),
                                                              bottom: BorderSide(
                                                                  width: 0.5,
                                                                  color: Colors
                                                                      .white),
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
                                                          width: 27,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            _showIntDialog(
                                                                    giftList[x]["giftInfoList"][a]
                                                                                [
                                                                                b]
                                                                            [
                                                                            "discountItemQty"]
                                                                        .toInt(),
                                                                    context)
                                                                .then((value) {
                                                              setState(() {
                                                                if (giftList[x]["giftInfoList"]
                                                                            [a][b]
                                                                        [
                                                                        "checkValue"] ==
                                                                    false) {
                                                                  giftList[x]["giftInfoList"]
                                                                              [a][b]
                                                                          [
                                                                          "discountItemQty"] =
                                                                      value;
                                                                } else {
                                                                  giftList[x]["giftInfoList"]
                                                                          [a][b][
                                                                      "discountItemQty"] = 0.0;
                                                                  giftList[x][
                                                                          "giftQty"] =
                                                                      0.0;
                                                                  for (var i = 0;
                                                                      i <
                                                                          giftList[x]["giftInfoList"]
                                                                              .length;
                                                                      i++) {
                                                                    for (var j =
                                                                            0;
                                                                        j <
                                                                            giftList[x]["giftInfoList"][i]
                                                                                .length;
                                                                        j++) {
                                                                      giftList[x][
                                                                          "giftQty"] = giftList[x]
                                                                              [
                                                                              "giftQty"] +
                                                                          giftList[x]["giftInfoList"][i][j]
                                                                              [
                                                                              "discountItemQty"];
                                                                    }
                                                                  }

                                                                  if (value >=
                                                                      (giftList[x]["giftInfoList"][a][b]
                                                                              [
                                                                              "discountTotalQty"] -
                                                                          giftList[x]
                                                                              [
                                                                              "giftQty"])) {
                                                                    value = (giftList[x]["giftInfoList"][a]
                                                                                [
                                                                                b]
                                                                            [
                                                                            "discountTotalQty"] -
                                                                        giftList[
                                                                                x]
                                                                            [
                                                                            "giftQty"]);
                                                                  }

                                                                  giftList[x]["giftInfoList"]
                                                                              [a][b]
                                                                          [
                                                                          "discountItemQty"] =
                                                                      value;

                                                                  giftList[x][
                                                                          "giftQty"] =
                                                                      0.0;

                                                                  for (var i = 0;
                                                                      i <
                                                                          giftList[x]["giftInfoList"]
                                                                              .length;
                                                                      i++) {
                                                                    for (var j =
                                                                            0;
                                                                        j <
                                                                            giftList[x]["giftInfoList"][i]
                                                                                .length;
                                                                        j++) {
                                                                      giftList[x][
                                                                          "giftQty"] = giftList[x]
                                                                              [
                                                                              "giftQty"] +
                                                                          giftList[x]["giftInfoList"][i][j]
                                                                              [
                                                                              "discountItemQty"];
                                                                    }
                                                                  }
                                                                }
                                                              });
                                                            });
                                                          },
                                                          child: Container(
                                                            child: Center(
                                                                child: Text(
                                                                    "${giftList[x]["giftInfoList"][a][b]["discountItemQty"].toInt()}")),
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
                                                            onTap: () async {
                                                              setState(() {
                                                                if (giftList[x][
                                                                        "giftQty"] >=
                                                                    giftList[x]["giftInfoList"]
                                                                            [a][b]
                                                                        [
                                                                        "discountTotalQty"]) {
                                                                  //
                                                                } else if (giftList[x]
                                                                                [
                                                                                "giftInfoList"]
                                                                            [a][b]
                                                                        [
                                                                        "checkValue"] ==
                                                                    false) {
                                                                  giftList[x]["giftInfoList"]
                                                                          [a][b][
                                                                      "discountItemQty"]++;
                                                                } else {
                                                                  giftList[x]["giftInfoList"]
                                                                          [a][b][
                                                                      "discountItemQty"]++;
                                                                  giftList[x][
                                                                      "giftQty"]++;
                                                                }
                                                              });
                                                            },
                                                            child: Center(
                                                                child: Icon(
                                                                    Icons.add,
                                                                    size: 19,
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(3),
                                                            color:
                                                                Color(0xffe53935),
                                                            border: Border(
                                                              top: BorderSide(
                                                                  width: 0.5,
                                                                  color: Colors
                                                                      .white),
                                                              bottom: BorderSide(
                                                                  width: 0.5,
                                                                  color: Colors
                                                                      .white),
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
                                                          width: 27,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                              ],
                                            )
                                      ],
                                    )
                                  ]),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FlatButton(
                    color: Color(0xffe53935),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Center(
                          child: Text(
                            'OK',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      List arrangeList = [];
                      for (var a = 0; a < giftList.length; a++) {
                        if (giftList[a]["giftInfoList"][0][0]
                                ["discountItemRuleType"] ==
                            "Total Item") {
                          if ((giftList[a]["giftInfoList"][0][0]
                                          ["discountTotalQty"]
                                      .toInt() -
                                  giftList[a]["giftQty"].toInt()) !=
                              0) {
                            Fluttertoast.showToast(
                                msg:
                                    "Need ${giftList[a]["giftInfoList"][0][0]["discountTotalQty"].toInt() - giftList[a]["giftQty"].toInt()} more Gift!",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIos: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          } else {
                            // print(giftList[a]["giftInfoList"]);
                            List list = [];
                            for (var ab = 0;
                                ab < giftList[a]["giftInfoList"].length;
                                ab++) {
                                  
                              for (var b = 0;
                                  b < giftList[a]["giftInfoList"][ab].length;
                                  b++) {
                                List<Map<String, Object>> giftInfoList = [];
                                if (giftList[a]["giftInfoList"][ab][b]
                                        ["checkValue"] ==
                                    true && giftList[a]["giftInfoList"][ab][b]["discountItemQty"] > 0) {
                                  giftInfoList = [
                                    {
                                      "discountItemEndType": giftList[a]
                                              ["giftInfoList"][ab][b]
                                          ["discountItemEndType"],
                                      "discountStockCode": giftList[a]
                                              ["giftInfoList"][ab][b]
                                          ["discountStockCode"],
                                      "discountItemDesc": giftList[a]
                                              ["giftInfoList"][ab][b]
                                          ["discountItemDesc"],
                                      "discountItemQty": giftList[a]
                                              ["giftInfoList"][ab][b]
                                          ["discountItemQty"],
                                      "discountItemType": giftList[a]
                                              ["giftInfoList"][ab][b]
                                          ["discountItemType"],
                                      "discountStockSyskey": giftList[a]
                                              ["giftInfoList"][ab][b]
                                          ["discountStockSyskey"],
                                      "discountItemSyskey": giftList[a]
                                              ["giftInfoList"][ab][b]
                                          ["discountItemSyskey"],
                                      "discountGiftCode": giftList[a]
                                              ["giftInfoList"][ab][b]
                                          ["discountGiftCode"],
                                      "discountItemRuleType": giftList[a]
                                              ["giftInfoList"][ab][b]
                                          ["discountItemRuleType"]
                                    }
                                  ];

                                  list.add(giftInfoList);
                                }

                              }

                              if (ab == giftList[a]["giftInfoList"].length - 1) {
                                giftList[a]["giftInfoList"] = list;
                              }
                            }

                            if (a == giftList.length - 1) {
                              for (var dd = 0; dd < giftList.length; dd++) {
                                arrangeList.add({
                                  "giftInfoList": giftList[dd]["giftInfoList"],
                                  "stockList": giftList[dd]["stockList"],
                                  "discountDetailSyskey": giftList[dd]
                                      ["discountDetailSyskey"]
                                });

                                if (dd == giftList.length - 1) {
                                  giftList = arrangeList;

                                  print(giftList);
                                  Navigator.pop(context, giftList);
                                }
                              }
                            }
                          }
                        } else {
                          for (var ab = 0;
                              ab < giftList[a]["giftInfoList"].length;
                              ab++) {
                            List<Map<String, Object>> list = [];
                            for (var b = 0;
                                b < giftList[a]["giftInfoList"][ab].length;
                                b++) {
                              if (giftList[a]["giftInfoList"][ab][b]
                                      ["checkValue"] ==
                                  true) {
                                list.add({
                                  "discountItemEndType": giftList[a]
                                          ["giftInfoList"][ab][b]
                                      ["discountItemEndType"],
                                  "discountStockCode": giftList[a]["giftInfoList"]
                                      [ab][b]["discountStockCode"],
                                  "discountItemDesc": giftList[a]["giftInfoList"]
                                      [ab][b]["discountItemDesc"],
                                  "discountItemQty": giftList[a]["giftInfoList"]
                                      [ab][b]["discountItemQty"],
                                  "discountItemType": giftList[a]["giftInfoList"]
                                      [ab][b]["discountItemType"],
                                  "discountStockSyskey": giftList[a]
                                          ["giftInfoList"][ab][b]
                                      ["discountStockSyskey"],
                                  "discountItemSyskey": giftList[a]
                                          ["giftInfoList"][ab][b]
                                      ["discountItemSyskey"],
                                  "discountGiftCode": giftList[a]["giftInfoList"]
                                      [ab][b]["discountGiftCode"],
                                  "discountItemRuleType": giftList[a]
                                          ["giftInfoList"][ab][b]
                                      ["discountItemRuleType"]
                                });
                              }

                              if (b ==
                                  giftList[a]["giftInfoList"][ab].length - 1) {
                                giftList[a]["giftInfoList"][ab] = list;
                              }
                            }
                          }
                          if (a == giftList.length - 1) {
                            for (var dd = 0; dd < giftList.length; dd++) {
                              arrangeList.add({
                                "giftInfoList": giftList[dd]["giftInfoList"],
                                "stockList": giftList[dd]["stockList"],
                                "discountDetailSyskey": giftList[dd]
                                    ["discountDetailSyskey"]
                              });

                              if (dd == giftList.length - 1) {
                                giftList = arrangeList;
                                Navigator.pop(context, giftList);
                              }
                            }
                          }
                        }
                      }
                    },
                  ),
                )
              ],
            );
          },
        ),
      );
    },
  );
}

NumberPicker integerNumberPicker;

Future _showIntDialog(var currentPrice, context) async {
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
      currentPrice = value;
    }
  });
  return currentPrice;
}


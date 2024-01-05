import 'package:flutter/material.dart';
import 'package:delivery_2/service.dart/AllService.dart';

class InvoiceDiscount extends StatefulWidget {
  @override
  _InvoiceDiscountState createState() => _InvoiceDiscountState();
}

class _InvoiceDiscountState extends State<InvoiceDiscount> {
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          title: Text("Invoice Discount"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
              }),
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    for (var a = 0; a < invDisDownloadList.length; a++)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  invDisDownloadList[a]["Boolean"] =
                                      !invDisDownloadList[a]["Boolean"];
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: invDisDownloadList[a]["Boolean"]
                                        ? Color(0xffe53935)
                                        : Colors.white,
                                    border: Border.all(
                                      color: Color(0xffe53935),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "${invDisDownloadList[a]["BrandOwnerDesc"]}",
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: invDisDownloadList[a]
                                                      ["Boolean"]
                                                  ? Colors.white
                                                  : Colors.red),
                                        ),
                                        Icon(
                                          invDisDownloadList[a]["Boolean"]
                                              ? Icons.keyboard_arrow_down
                                              : Icons.keyboard_arrow_right,
                                          color: invDisDownloadList[a]
                                                  ["Boolean"]
                                              ? Colors.white
                                              : Colors.red,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                          for (var b = 0;
                              b <
                                  invDisDownloadList[a]["InvoiceDiscountHeader"]
                                      .length;
                              b++)
                            Visibility(
                              visible: invDisDownloadList[a]["Boolean"],
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color(0xffe53935), width: 1),
                                      borderRadius: BorderRadius.circular(0)),
                                  child: Column(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            invDisDownloadList[a][
                                                        "InvoiceDiscountHeader"]
                                                    [b]["Boolean"] =
                                                !invDisDownloadList[a][
                                                        "InvoiceDiscountHeader"]
                                                    [b]["Boolean"];
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: invDisDownloadList[a][
                                                        "InvoiceDiscountHeader"]
                                                    [b]["Boolean"]
                                                ? Color(0xffe53935)
                                                : Colors.white,
                                            border: Border.all(
                                              color: invDisDownloadList[a][
                                                          "InvoiceDiscountHeader"]
                                                      [b]["Boolean"]
                                                  ? Color(0xffe53935)
                                                  : Colors.white,
                                              width: 1,
                                            ),
                                            borderRadius: invDisDownloadList[a][
                                                        "InvoiceDiscountHeader"]
                                                    [b]["Boolean"]
                                                ? BorderRadius.circular(0)
                                                : BorderRadius.circular(0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  "${invDisDownloadList[a]["InvoiceDiscountHeader"][b]["HeaderDesc"]}",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: invDisDownloadList[
                                                                      a][
                                                                  "InvoiceDiscountHeader"]
                                                              [b]["Boolean"]
                                                          ? Colors.white
                                                          : Colors.red),
                                                ),
                                                Icon(
                                                  invDisDownloadList[a][
                                                              "InvoiceDiscountHeader"]
                                                          [b]["Boolean"]
                                                      ? Icons
                                                          .keyboard_arrow_down
                                                      : Icons
                                                          .keyboard_arrow_right,
                                                  color: invDisDownloadList[a][
                                                              "InvoiceDiscountHeader"]
                                                          [b]["Boolean"]
                                                      ? Colors.white
                                                      : Colors.red,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: invDisDownloadList[a]
                                                ["InvoiceDiscountHeader"][b]
                                            ["Boolean"],
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 10),
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text("Buy",
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xffe53935),
                                                        fontSize: 16,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      )),
                                                  Text("Get",
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xffe53935),
                                                        fontSize: 16,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      )),
                                                ],
                                              ),
                                              for (var c = 0;
                                                  c <
                                                      invDisDownloadList[a][
                                                                  "InvoiceDiscountHeader"][b]
                                                              [
                                                              "InvoiceDiscountHeader"]
                                                          .length;
                                                  c++)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          invDisDownloadList[a]
                                                                                  ["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c][
                                                                              "Operator"]
                                                                          .toString() ==
                                                                      "between" &&
                                                                  invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["DiscountType"]
                                                                          .toString() ==
                                                                      "Inkind" &&
                                                                  invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["DiscountPriceType"].toString() == ""
                                                              ? Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: <
                                                                      Widget>[
                                                                      Row(
                                                                        children: <
                                                                            Widget>[
                                                                          // Text(
                                                                          //     "${c + 1}. "),
                                                                          Text(
                                                                            "Between ",
                                                                            style:
                                                                                TextStyle(fontSize: 13),
                                                                          ),
                                                                          Text(
                                                                            "${invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["PromoAmount"]} ".replaceAllMapped(reg, mathFunc),
                                                                            style:
                                                                                TextStyle(fontSize: 13, color: Color(0xffe53935)),
                                                                          ),
                                                                          Text(
                                                                            "ks ",
                                                                            style:
                                                                                TextStyle(fontSize: 13),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                            "to ",
                                                                            style:
                                                                                TextStyle(fontSize: 13),
                                                                          ),
                                                                          Text(
                                                                            "${invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["PromoAmount2"]} ".replaceAllMapped(reg, mathFunc),
                                                                            style:
                                                                                TextStyle(fontSize: 13, color: Color(0xffe53935)),
                                                                          ),
                                                                          Text(
                                                                            "ks ",
                                                                            style:
                                                                                TextStyle(fontSize: 13),
                                                                          )
                                                                        ],
                                                                      )
                                                                    ])
                                                              : Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: <
                                                                      Widget>[
                                                                    // Text(
                                                                    //     "${c + 1}. "),
                                                                    if (invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["Operator"]
                                                                            .toString() ==
                                                                        "between")
                                                                      Text(
                                                                        "Between ",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                13),
                                                                      ),
                                                                    Text(
                                                                      "${invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["PromoAmount"]} ".replaceAllMapped(
                                                                          reg,
                                                                          mathFunc),
                                                                      style: TextStyle(
                                                                          color:
                                                                              Color(0xffe53935)),
                                                                    ),
                                                                    invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["DiscountType"].toString().length >
                                                                            2
                                                                        ? Text(
                                                                            "ks ")
                                                                        : Text(
                                                                            "( pcs )"),
                                                                    if (invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["Operator"]
                                                                            .toString() ==
                                                                        "less than")
                                                                      Text(
                                                                        " under",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Color(0xffe53935)),
                                                                      ),
                                                                    if (invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["Operator"].toString() == "end" ||
                                                                        invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["Operator"].toString() ==
                                                                            "equal" ||
                                                                        invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["Operator"].toString() ==
                                                                            "null")
                                                                      Text(""),
                                                                    if (invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["Operator"]
                                                                            .toString() ==
                                                                        "greater than")
                                                                      Text(
                                                                        " above",
                                                                        style: TextStyle(
                                                                            color: Color(0xffe53935)),
                                                                      ),
                                                                    if (invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["Operator"]
                                                                            .toString() ==
                                                                        "equal and greater than")
                                                                      Row(
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                              " and"),
                                                                          Text(
                                                                            " above",
                                                                            style:
                                                                                TextStyle(color: Color(0xffe53935)),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    if (invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["Operator"]
                                                                            .toString() ==
                                                                        "between")
                                                                      Row(
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                              " to"),
                                                                          Text(
                                                                            " ${invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["PromoAmount2"]} ".replaceAllMapped(reg, mathFunc),
                                                                            style:
                                                                                TextStyle(color: Color(0xffe53935)),
                                                                          ),
                                                                          Text(
                                                                            "ks",
                                                                            style:
                                                                                TextStyle(fontSize: 13),
                                                                          )
                                                                        ],
                                                                      )
                                                                  ],
                                                                ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              if (invDisDownloadList[a]["InvoiceDiscountHeader"]
                                                                              [
                                                                              b]
                                                                          [
                                                                          "InvoiceDiscountHeader"][c]
                                                                      [
                                                                      "DiscountType"] ==
                                                                  "Inkind")
                                                                Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Container(
                                                                      width: (MediaQuery.of(context).size.width /
                                                                              2) -
                                                                          35,
                                                                      child:
                                                                          Text(
                                                                        "${invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["DiscountItemDesc"]}",
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            10),
                                                                    Container(
                                                                        decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            border: Border.all(color: Color(0xffe53935))),
                                                                        child: Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(horizontal: 7),
                                                                          child:
                                                                              Text(
                                                                            "${invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["DiscountItemQty"]}",
                                                                            style:
                                                                                TextStyle(color: Color(0xffe53935)),
                                                                          ),
                                                                        ))
                                                                  ],
                                                                ),
                                                              if (invDisDownloadList[a]["InvoiceDiscountHeader"]
                                                                              [
                                                                              b]
                                                                          [
                                                                          "InvoiceDiscountHeader"][c]
                                                                      [
                                                                      "DiscountType"] ==
                                                                  "Price")
                                                                Row(
                                                                  children: <
                                                                      Widget>[
                                                                    if (invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]
                                                                            [
                                                                            "DiscountPriceType"] ==
                                                                        "Price")
                                                                      Row(
                                                                        children: <Widget>[
                                                                          Text(
                                                                            "${invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["DiscountAmount"]}".replaceAllMapped(reg, mathFunc),
                                                                            style: TextStyle(
                                                                                color:
                                                                                    Color(0xffe53935)),
                                                                          ),
                                                                          Text(
                                                                            " ks",
                                                                            style: TextStyle(
                                                                                color:
                                                                                    Color(0xffe53935)),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    if (invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]
                                                                            [
                                                                            "DiscountPriceType"] ==
                                                                        "Percentage")
                                                                      Text(
                                                                        "${invDisDownloadList[a]["InvoiceDiscountHeader"][b]["InvoiceDiscountHeader"][c]["DiscountAmount"]}%",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Color(0xffe53935)),
                                                                      ),
                                                                  ],
                                                                ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

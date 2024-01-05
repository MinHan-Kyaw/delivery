import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_2/service.dart/AllService.dart';
import 'ShowImage.dart';

class DiscountDetail extends StatefulWidget {
  final List detail;
  final stockDetail;
  DiscountDetail({Key key, @required this.detail, @required this.stockDetail})
      : super(key: key);
  @override
  _DiscountDetailState createState() => _DiscountDetailState();
}

class _DiscountDetailState extends State<DiscountDetail> {
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  bool loading = true;
  List getStockDetail = [];
  List otherMultiStock = [];
  Future<void> getImage() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    stockImage = json.decode(preferences.getString("StockImageList"));
    getStockDetail = json.decode(preferences.getString("AddOrder"));
    if (stockImage.length != 0) {
      setState(() {
        loading = false;
      });
    }

    String headerSyskey = "";
    String ruleNumber = "";
    String rulePriority = "";
    List multiStockList = [];

    List multiSameCheckList = [];

    multiSameCheckList = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == widget.detail[0]["PromoItemSyskey"]).toList();

    for(var a = 0; a < multiSameCheckList.length; a++) {
      headerSyskey = multiSameCheckList[a]["HeaderSyskey"];
      ruleNumber = multiSameCheckList[a]["RuleNumber"];
      rulePriority = multiSameCheckList[a]["RulePriority"];

      multiStockList = multiDiscountStockList.where((element) => element["HeaderSyskey"] == headerSyskey).toList()[0]["DetailList"].where((element) => element["RuleNumber"] == ruleNumber && element["RulePriority"] == rulePriority).toList();

      List otherMultiStock1 = [];
      otherMultiStock1 = multiStockList.where((element) => element["EndType"] == "AND").toList() +
        multiStockList.where((element) => element["EndType"] == "OR").toList() +
        multiStockList.where((element) => element["EndType"] == "END").toList();

      otherMultiStock.add(otherMultiStock1);
    }

  }

  @override
  void initState() {
    super.initState();
    getImage();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          title: Text("Discount Detail"),
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
            Stack(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowImage(
                                image: Image.asset("assets/coca.png"))));
                  },
                  child: Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Image.asset("assets/coca.png", fit: BoxFit.cover)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowImage(
                                image: CachedNetworkImage(
                                    imageUrl:
                                        "${domain.substring(0, domain.lastIndexOf("8084/"))}8084${stockImage.where((element) => element["stockCode"] == widget.stockDetail["stockCode"]).toList()[0]["image"]}"))));
                  },
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: loading == true
                        ? Container()
                        : CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl:
                                "${domain.substring(0, domain.lastIndexOf("8084/"))}8084${stockImage.where((element) => element["stockCode"] == widget.stockDetail["stockCode"]).toList()[0]["image"]}",
                          ),
                  ),
                ),
              ],
            ),
            // Text("${widget.detail}"),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${widget.detail[0]["PromoItemDesc"]}",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              color: Color(0xffe53935),
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Image.asset(
                                  "assets/price-tag.png",
                                  color: Colors.white,
                                  width: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "${getStockDetail.where((element) => element["syskey"] == widget.detail[0]["PromoItemSyskey"]).toList()[0]["categoryCodeDesc"]}",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Color(0xffe53935),
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Image.asset(
                                  "assets/price-tag.png",
                                  color: Colors.white,
                                  width: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "${getStockDetail.where((element) => element["syskey"] == widget.detail[0]["PromoItemSyskey"]).toList()[0]["subCategoryCodeDesc"]}",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Detail",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Pack size",
                                style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 10),
                            Text("Category",
                                style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 10),
                            Text("Subcategory",
                                style: TextStyle(color: Colors.grey))
                          ],
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                "${getStockDetail.where((element) => element["syskey"] == widget.detail[0]["PromoItemSyskey"]).toList()[0]["packSizeDescription"]}",
                                style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 10),
                            Text(
                                "${getStockDetail.where((element) => element["syskey"] == widget.detail[0]["PromoItemSyskey"]).toList()[0]["categoryCode"]}",
                                style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 10),
                            Text(
                                "${getStockDetail.where((element) => element["syskey"] == widget.detail[0]["PromoItemSyskey"]).toList()[0]["subCategoryCode"]}",
                                style: TextStyle(color: Colors.grey))
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Promotion",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: 20,
                  ),
                  if(otherMultiStock.length == 0)
                  for(var b = 0; b < widget.detail[0]["HeaderList"].length; b++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]),
                          borderRadius: BorderRadius.circular(0)),
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                // color: Color(0xffe53935),
                                borderRadius: BorderRadius.circular(0)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 7),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "${widget.detail[0]["HeaderList"][b]["DetailList"][0]["DiscountType"]}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        " Discount with ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        "${widget.detail[0]["HeaderList"][b]["DetailList"][0]["PromoType"]}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "Expired On : ${widget.detail[0]["HeaderList"][b]["ToDate"].toString().substring(6, 8)}/${widget.detail[0]["HeaderList"][b]["ToDate"].toString().substring(4, 6)}/${widget.detail[0]["HeaderList"][b]["ToDate"].toString().substring(0, 4)}",
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if(otherMultiStock.length == 0)
                  for(var b = 0; b < widget.detail[0]["HeaderList"].length; b++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                    children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]),
                    borderRadius: BorderRadius.circular(0)),
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 7),
                      child: Text("Buy",
                              style: TextStyle(
                                color: Color(0xffe53935),
                                fontSize: 17,
                                fontWeight: FontWeight.w400
                              )),
                    ),
                    Container(
                      height: 1,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey[400],
                    ),
                      Column(
                        children: <Widget>[
                          for (var a = 0; a < widget.detail[0]["HeaderList"][b]["DetailList"].length; a++)
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text("${a+1}.  "),
                                    widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"].toString() == "between" &&
                                    widget.detail[0]["HeaderList"][b]["DetailList"][a]["DiscountType"] =="Inkind" &&
                                    (widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoAmount"].toString().length > 2 ||
                                    widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoAmount2"].toString().length > 2)
                                        ? 
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Container(
                                            width: MediaQuery.of(context).size.width - 90,
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Text("Between ", style: TextStyle(fontSize: 13),),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                        "${widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoAmount"]} ".replaceAllMapped(reg, mathFunc),
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                            color:
                                                                Color(0xffe53935)),
                                                      ),
                                                          widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoType"] == "Qty" ?
                                                      Text("", style: TextStyle(fontSize: 13),) :
                                                      Text("ks ", style: TextStyle(fontSize: 13),)
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Text("to ", style: TextStyle(fontSize: 13),),
                                                      Text(
                                                        "${widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoAmount2"]} ".replaceAllMapped(reg, mathFunc),
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                            color:
                                                                Color(0xffe53935)),
                                                      ),
                                                      widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoType"] == "Qty" ?
                                                      Text("(pcs)", style: TextStyle(fontSize: 13),) :
                                                      Text("ks", style: TextStyle(fontSize: 13),)
                                                    ],
                                                  )
                                                ],
                                              ),
                                          ),
                                        )
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, bottom: 10, right: 5),
                                            child: Container(
                                              width: MediaQuery.of(context).size.width - 90,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                          .toString() ==
                                                      "between")
                                                    Text("Between ", style: TextStyle(fontSize: 13),),
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                    "${widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoAmount"]} "
                                                        .replaceAllMapped(
                                                            reg, mathFunc),
                                                    style: TextStyle(
                                                        color: Color(0xffe53935), fontSize: 13),
                                                  ),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]
                                                          ["PromoType"] ==
                                                      "Amount")
                                                    Text("ks "),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoType"] == "Qty" &&
                                                      widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                              .toString() !=
                                                          "between")
                                                    Text("( pcs )", style: TextStyle(fontSize: 13),),
                                                    if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                          .toString() ==
                                                      "equal and greater than")
                                                    Text(" and", style: TextStyle(fontSize: 13),),
                                                    ], 
                                                  ),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                          .toString() ==
                                                      "less than")
                                                    Text(
                                                      " under",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                          color:
                                                              Color(0xffe53935)),
                                                    ),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                              .toString() ==
                                                          "end" ||
                                                      widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                              .toString() ==
                                                          "equal" ||
                                                      widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                              .toString() ==
                                                          "null")
                                                    Text(""),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                          .toString() ==
                                                      "greater than")
                                                    Text(
                                                      " above",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                          color:
                                                              Color(0xffe53935)),
                                                    ),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                          .toString() ==
                                                      "equal and greater than")
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          " above",
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                              color: Color(
                                                                  0xffe53935)),
                                                        ),
                                                      ],
                                                    ),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                          .toString() ==
                                                      "between")
                                                    Row(
                                                      children: <Widget>[
                                                        Text(" to", style: TextStyle(fontSize: 13),),
                                                        Text(
                                                          " ${widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoAmount2"]} ".replaceAllMapped(reg, mathFunc),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                              color: Color(
                                                                  0xffe53935)),
                                                        ),
                                                        
                                                        widget.detail[0]["HeaderList"][b]["DetailList"][a]
                                                                ["PromoType"] ==
                                                            "Qty" ?
                                                          Text("(pcs)", style: TextStyle(fontSize: 13),) :
                                                          Text("ks ", style: TextStyle(fontSize: 13),),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              if(a != widget.detail[0]["HeaderList"][b]["DetailList"].length -1)
                              Container(
                                color: Colors.grey[400],
                                height: 1,
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                      ),
                    ),
                  // Text("${widget.detail[0]["HeaderList"][b]["DetailList"]}"),
                  if(otherMultiStock.length == 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]),
                      borderRadius: BorderRadius.circular(0)),
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 7),
                      child: Text("Get",
                              style: TextStyle(
                                color: Color(0xffe53935),
                                fontSize: 17,
                                fontWeight: FontWeight.w400
                              )),
                        ),
                        Container(
                      height: 1,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey[400],
                        ),
                        Column(
                            children: <Widget>[
                              if(widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList().length != 0)
                                if (widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["DiscountType"] == "Inkind")
                                if(widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"].length != 0)
                                  if(widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][0].length != 0)
                                  widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][0][0]["discountItemRuleType"] == "Total Item" ?
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(color: Colors.grey[400])
                                              ),
                                            ),
                                            child: Column(
                                              children: <Widget>[
                                                for(var a = 0; a < widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"].length; a++)
                                                Column(
                                                  children: <Widget>[
                                                    widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a].length == 1 ?
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
                                                      child: Container(
                                                        child: Text(
                                                          "${widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a][0]["DiscountItemDesc"]}",
                                                          style: TextStyle(fontSize: 13),
                                                        ),
                                                      ),
                                                    ) : 
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
                                                      child: Column(
                                                        children: <Widget>[
                                                          for(var q = 0; q < widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a].length; q++)
                                                          Column(
                                                            children: <Widget>[
                                                              Container(
                                                                width: MediaQuery.of(context).size.width - 120,
                                                                child: Text(
                                                                  "${widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a][q]["DiscountItemDesc"]}",
                                                                  style: TextStyle(fontSize: 13),
                                                                ),
                                                              ),
                                                              if(q != widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a].length-1)
                                                              Padding(
                                                                padding: const EdgeInsets.all(5),
                                                                child: Text("(OR)", style: TextStyle(color: Colors.grey[400], fontSize: 12),),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if(a != widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"].length-1)
                                                    Container(
                                                      height: 1,
                                                      width: (MediaQuery.of(context).size.width * (6/7)) - 43,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * (1/7),
                                            child: Center(
                                              child: Column(
                                                children: <Widget>[
                                                  Text(
                                                    "${widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][0][0]["DiscountItemQty"]}",
                                                    style: TextStyle(color: Color(0xffe53935)),
                                                  ),
                                                  Text(" pcs")
                                                ],
                                              ),
                                            )
                                          )
                                        ],
                                      ) :
                                      Column(
                                        children: <Widget>[
                                          for(var a = 0; a < widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"].length; a++)
                                          Column(
                                            children: <Widget>[
                                              widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a].length == 1 ?
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                      width: MediaQuery.of(context).size.width - 120,
                                                      child: Text(
                                                        "${widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a][0]["DiscountItemDesc"]}",
                                                        style: TextStyle(fontSize: 13),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          "${widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a][0]["DiscountItemQty"]}",
                                                          style: TextStyle(fontSize: 13, color: Color(0xffe53935)),
                                                        ),
                                                        Text(
                                                          " pcs",
                                                          style: TextStyle(fontSize: 13),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ) : 
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
                                                child: Column(
                                                  children: <Widget>[
                                                    for(var q = 0; q < widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a].length; q++)
                                                    Column(
                                                      children: <Widget>[
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: <Widget>[
                                                            Container(
                                                              width: MediaQuery.of(context).size.width - 120,
                                                              child: Text(
                                                                "${widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a][q]["DiscountItemDesc"]}",
                                                                style: TextStyle(fontSize: 13),
                                                              ),
                                                            ),
                                                            Row(
                                                              children: <Widget>[
                                                                Text(
                                                                  "${widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a][0]["DiscountItemQty"]}",
                                                                  style: TextStyle(fontSize: 13, color: Color(0xffe53935)),
                                                                ),
                                                                Text(
                                                                  " pcs",
                                                                  style: TextStyle(fontSize: 13),
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                        if(q != widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a].length-1)
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 7),
                                                          child: Stack(
                                                            alignment: Alignment.center,
                                                            children: <Widget>[
                                                              Container(
                                                                height: 1,
                                                                color: Colors.grey[300]
                                                              ),
                                                              Container(
                                                                color: Colors.grey[50],
                                                                child: Text(" (OR) ", style: TextStyle(color: Colors.grey[400], fontSize: 12),)),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if(a != widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["InkindList"].length-1)
                                              Container(
                                                height: 1,
                                                width: MediaQuery.of(context).size.width - 43,
                                                color: Colors.grey[400],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    if (widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]
                                            ["DiscountType"] ==
                                        "Price")
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
                                        child: Row(
                                          children: <Widget>[
                                            if (widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]
                                                    ["DiscountPriceType"] ==
                                                "Price")
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    "${widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["DiscountAmount"]}".replaceAllMapped(reg, mathFunc),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                        color:
                                                            Color(0xffe53935)),
                                                  ),
                                                  Text(
                                                    " ks",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                        color:
                                                            Color(0xffe53935)),
                                                  ),
                                                ],
                                              ),
                                            if (widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]
                                                    ["DiscountPriceType"] ==
                                                "Percentage")
                                              Text(
                                                "${widget.detail[0]["HeaderList"][b]["DetailList"].where((element) => element["EndType"] == "END").toList()[0]["DiscountAmount"]}%",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                    color:
                                                        Color(0xffe53935)),
                                              ),
                                            Text(" off", style: TextStyle(fontSize: 13),)
                                          ],
                                        ),
                                      ),
                            ],
                          ),
                      ],
                      ),
                    ),
                  )
                    ],
                  ),
                  ),
                  // for(var uu = 0; uu < multiDiscountStockList[0]["DetailList"].length; uu++)
                  // multiDiscountStockList[0]["DetailList"][uu]["InkindList"].length == 0 ?
                  // Container() :
                  // Text("--> ${multiDiscountStockList[0]["DetailList"][uu]}"),
                  // Text("${multiDiscountStockList[0]["DetailList"].where((element)=> element["InkindList"].length != 0).toList()}"),
                  // for(var uu = 0; uu < otherMultiStock.length; uu++)
                  // Text("--> ${otherMultiStock[uu]}"),
                  // Text("${listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == widget.detail[0]["PromoItemSyskey"]).toList()}"),
                  // otherMultiStock
                  if(otherMultiStock.length != 0)
                  Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]),
                          borderRadius: BorderRadius.circular(0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 7),
                            child: Text("Buy",
                                    style: TextStyle(
                                      color: Color(0xffe53935),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400
                                    )),
                          ),
                          Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey[400],
                          ),
                          Column(
                            children: <Widget>[
                              for(var ii = 0; ii <otherMultiStock.length; ii++)
                              Column(
                                children: <Widget>[
                                  if(ii != 0)
                                  Container(
                                    height: 1,
                                    width: MediaQuery.of(context).size.width,
                                    color: Colors.grey[400],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      otherMultiStock[ii][0]["RuleType"] == "Each Item" ?
                            Column(
                              children: <Widget>[
                                for(var p = 0; p < otherMultiStock[ii].length; p++)
                                Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Stack(
                                                children: <Widget>[
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => ShowImage(
                                                                  image: Image.asset("assets/coca.png"))));
                                                    },
                                                    child: Container(
                                                        height: 60,
                                                        width: 60,
                                                        child: Image.asset("assets/coca.png", fit: BoxFit.cover)),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => ShowImage(
                                                                  image: CachedNetworkImage(
                                                                      imageUrl:
                                                                          "${domain.substring(0, domain.lastIndexOf("8084/"))}8084${stockImage.where((element) => element["stockCode"] == getStockDetail.where((element) => element["syskey"] == otherMultiStock[ii][p]["PromoItemSyskey"]).toList()[0]["code"]).toList()[0]["image"]}"))));
                                                    },
                                                    child: Container(
                                                      height: 60,
                                                      width: 60,
                                                      child: loading == true
                                                          ? Container()
                                                          : CachedNetworkImage(
                                                              fit: BoxFit.cover,
                                                              imageUrl:
                                                                  "${domain.substring(0, domain.lastIndexOf("8084/"))}8084${stockImage.where((element) => element["stockCode"] == getStockDetail.where((element) => element["syskey"] == otherMultiStock[ii][p]["PromoItemSyskey"]).toList()[0]["code"]).toList()[0]["image"]}",
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: (MediaQuery.of(context).size.width * (0.48)),
                                              height: 60,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "${otherMultiStock[ii][p]["PromoItemDesc"]}",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        otherMultiStock[ii][p]["Operator"].toString() == "between" &&
                                        otherMultiStock[ii][p]["DiscountType"] =="Inkind" &&
                                        (otherMultiStock[ii][p]["PromoAmount"].toString().length > 2 ||
                                        otherMultiStock[ii][p]["PromoAmount2"].toString().length > 2)
                                            ? 
                                            Padding(
                                              padding: const EdgeInsets.only(right: 5),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Column(
                                                      children: <Widget>[
                                                        Row(
                                                          children: <Widget>[
                                                            Text("Between ", style: TextStyle(fontSize: 13),),
                                                        
                                                          ],
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            Text(
                                                          "${otherMultiStock[ii][p]["PromoAmount"]} ".replaceAllMapped(reg, mathFunc),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                              color:
                                                                  Color(0xffe53935)),
                                                        ),
                                                            otherMultiStock[ii][p]["PromoType"] == "Qty" ?
                                                        Text("", style: TextStyle(fontSize: 13),) :
                                                        Text("ks ", style: TextStyle(fontSize: 13),)
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text("to ", style: TextStyle(fontSize: 13),),
                                                        Text(
                                                          "${otherMultiStock[ii][p]["PromoAmount2"]} ".replaceAllMapped(reg, mathFunc),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                              color:
                                                                  Color(0xffe53935)),
                                                        ),
                                                        otherMultiStock[ii][p]["PromoType"] == "Qty" ?
                                                        Text("(pcs)", style: TextStyle(fontSize: 13),) :
                                                        Text("ks", style: TextStyle(fontSize: 13),)
                                                      ],
                                                    )
                                                  ],
                                                ),
                                            )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10, bottom: 10, right: 5),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    if (otherMultiStock[ii][p]["Operator"]
                                                            .toString() ==
                                                        "between")
                                                      Text("Between ", style: TextStyle(fontSize: 13),),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                      "${otherMultiStock[ii][p]["PromoAmount"]} "
                                                          .replaceAllMapped(
                                                              reg, mathFunc),
                                                      style: TextStyle(
                                                          color: Color(0xffe53935), fontSize: 13),
                                                    ),
                                                    if (otherMultiStock[ii][p]
                                                            ["PromoType"] ==
                                                        "Amount")
                                                      Text("ks "),
                                                    if (otherMultiStock[ii][p]["PromoType"] == "Qty" &&
                                                        otherMultiStock[ii][p]["Operator"]
                                                                .toString() !=
                                                            "between")
                                                      Text("( pcs )", style: TextStyle(fontSize: 13),),
                                                      if (otherMultiStock[ii][p]["Operator"]
                                                            .toString() ==
                                                        "equal and greater than")
                                                      Text(" and", style: TextStyle(fontSize: 13),),
                                                      ], 
                                                    ),
                                                    if (otherMultiStock[ii][p]["Operator"]
                                                            .toString() ==
                                                        "less than")
                                                      Text(
                                                        " under",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                            color:
                                                                Color(0xffe53935)),
                                                      ),
                                                    if (otherMultiStock[ii][p]["Operator"]
                                                                .toString() ==
                                                            "end" ||
                                                        otherMultiStock[ii][p]["Operator"]
                                                                .toString() ==
                                                            "equal" ||
                                                        otherMultiStock[ii][p]["Operator"]
                                                                .toString() ==
                                                            "null")
                                                      Text(""),
                                                    if (otherMultiStock[ii][p]["Operator"]
                                                            .toString() ==
                                                        "greater than")
                                                      Text(
                                                        " above",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                            color:
                                                                Color(0xffe53935)),
                                                      ),
                                                    if (otherMultiStock[ii][p]["Operator"]
                                                            .toString() ==
                                                        "equal and greater than")
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            " above",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                                color: Color(
                                                                    0xffe53935)),
                                                          ),
                                                        ],
                                                      ),
                                                    if (otherMultiStock[ii][p]["Operator"]
                                                            .toString() ==
                                                        "between")
                                                      Row(
                                                        children: <Widget>[
                                                          Text(" to", style: TextStyle(fontSize: 13),),
                                                          Text(
                                                            " ${otherMultiStock[ii][p]["PromoAmount2"]} ".replaceAllMapped(reg, mathFunc),
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                                color: Color(
                                                                    0xffe53935)),
                                                          ),
                                                          
                                                          otherMultiStock[ii][p]
                                                                  ["PromoType"] ==
                                                              "Qty" ?
                                                            Text("(pcs)", style: TextStyle(fontSize: 13),) :
                                                            Text("ks ", style: TextStyle(fontSize: 13),),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                      ],
                                    ),
                                    if(p != otherMultiStock[ii].length-1)
                                    otherMultiStock[ii][p]["EndType"] == "OR" ?
                                    Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        Container(
                                          height: 1,
                                          color: Colors.grey[400]
                                        ),
                                        Container(
                                          color: Colors.grey[50],
                                          child: Text(" (OR) ", style: TextStyle(color: Colors.grey[400], fontSize: 12),)),
                                      ],
                                    ) :
                                    Container(
                                      color: Colors.grey[400],
                                      height: 1,
                                    ),
                                  ],
                                ),
                              ],
                            ) :
                            Row(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(color: Colors.grey[400]),
                                      left: BorderSide.none,
                                      top: BorderSide.none,
                                      bottom: BorderSide.none
                                    ),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      for(var p = 0; p < otherMultiStock[ii].length; p++)
                                      Column(
                                        children: <Widget>[
                                              
                                          Row(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.all(5),
                                                    child: Stack(
                                                      children: <Widget>[
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => ShowImage(
                                                                        image: Image.asset("assets/coca.png"))));
                                                          },
                                                          child: Container(
                                                              height: 60,
                                                              width: 60,
                                                              child: Image.asset("assets/coca.png", fit: BoxFit.cover)),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => ShowImage(
                                                                        image: CachedNetworkImage(
                                                                            imageUrl:
                                                                                "${domain.substring(0, domain.lastIndexOf("8084/"))}8084${stockImage.where((element) => element["stockCode"] == getStockDetail.where((element) => element["syskey"] == otherMultiStock[ii][p]["PromoItemSyskey"]).toList()[0]["code"]).toList()[0]["image"]}"))));
                                                          },
                                                          child: Container(
                                                            height: 60,
                                                            width: 60,
                                                            child: loading == true
                                                                ? Container()
                                                                : CachedNetworkImage(
                                                                    fit: BoxFit.cover,
                                                                    imageUrl:
                                                                        "${domain.substring(0, domain.lastIndexOf("8084/"))}8084${stockImage.where((element) => element["stockCode"] == getStockDetail.where((element) => element["syskey"] == otherMultiStock[ii][p]["PromoItemSyskey"]).toList()[0]["code"]).toList()[0]["image"]}",
                                                                  ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width: (MediaQuery.of(context).size.width * (0.47)),
                                                    height: 60,
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text(
                                                        "${otherMultiStock[ii][p]["PromoItemDesc"]}",
                                                        style: TextStyle(
                                                          fontSize: 15, 
                                                          color: Colors.black
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                          if(otherMultiStock[ii][p]["EndType"] == "AND")
                                          if(p != otherMultiStock[ii].length-1)
                                          Container(
                                            color: Colors.grey[400],
                                            height: 1,
                                          ),
                                          if(otherMultiStock[ii][p]["EndType"] == "OR")
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                height: 1,
                                                width: 70,
                                                color: Colors.grey[400]
                                              ),
                                              Text(" (OR) ", style: TextStyle(color: Colors.grey[400], fontSize: 12),),
                                              Container(
                                                height: 1,
                                                width: 70,
                                                color: Colors.grey[400]
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["Operator"].toString() == "between" &&
                                        otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["DiscountType"] =="Inkind" &&
                                        (otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["PromoAmount"].toString().length > 2 ||
                                        otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["PromoAmount2"].toString().length > 2)
                                            ? 
                                            Padding(
                                              padding: const EdgeInsets.only(right: 5),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Column(
                                                      children: <Widget>[
                                                        Row(
                                                          children: <Widget>[
                                                            Text("Between ", style: TextStyle(fontSize: 13),),
                                                            
                                                          ],
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            Text(
                                                          "${otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["PromoAmount"]} ".replaceAllMapped(reg, mathFunc),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                              color:
                                                                  Color(0xffe53935)),
                                                        ),
                                                            otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["PromoType"] == "Qty" ?
                                                        Text("", style: TextStyle(fontSize: 13),) :
                                                        Text("ks ", style: TextStyle(fontSize: 13),)
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text("to ", style: TextStyle(fontSize: 13),),
                                                        Text(
                                                          "${otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["PromoAmount2"]} ".replaceAllMapped(reg, mathFunc),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                              color:
                                                                  Color(0xffe53935)),
                                                        ),
                                                        otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["PromoType"] == "Qty" ?
                                                        Text("(pcs)", style: TextStyle(fontSize: 13),) :
                                                        Text("ks", style: TextStyle(fontSize: 13),)
                                                      ],
                                                    )
                                                  ],
                                                ),
                                            )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10, bottom: 10, right: 5),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    if (otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["Operator"]
                                                            .toString() ==
                                                        "between")
                                                      Text("Between ", style: TextStyle(fontSize: 13),),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                      "${otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["PromoAmount"]} "
                                                          .replaceAllMapped(
                                                              reg, mathFunc),
                                                      style: TextStyle(
                                                          color: Color(0xffe53935), fontSize: 13),
                                                    ),
                                                    if (otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]
                                                            ["PromoType"] ==
                                                        "Amount")
                                                      Text("ks "),
                                                    if (otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["PromoType"] == "Qty" &&
                                                        otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["Operator"]
                                                                .toString() !=
                                                            "between")
                                                      Text("( pcs )", style: TextStyle(fontSize: 13),),
                                                      if (otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["Operator"]
                                                            .toString() ==
                                                        "equal and greater than")
                                                      Text(" and", style: TextStyle(fontSize: 13),),
                                                      ],
                                                    ),
                                                    if (otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["Operator"]
                                                            .toString() ==
                                                        "less than")
                                                      Text(
                                                        " under",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                            color:
                                                                Color(0xffe53935)),
                                                      ),
                                                    if (otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["Operator"]
                                                                .toString() ==
                                                            "end" ||
                                                        otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["Operator"]
                                                                .toString() ==
                                                            "equal" ||
                                                        otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["Operator"]
                                                                .toString() ==
                                                            "null")
                                                      Text(""),
                                                    if (otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["Operator"]
                                                            .toString() ==
                                                        "greater than")
                                                      Text(
                                                        " above",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                            color:
                                                                Color(0xffe53935)),
                                                      ),
                                                    if (otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["Operator"]
                                                            .toString() ==
                                                        "equal and greater than")
                                                      Row(
                                                        children: <Widget>[
                                                              
                                                          Text(
                                                            " above",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                                color: Color(
                                                                    0xffe53935)),
                                                          ),
                                                        ],
                                                      ),
                                                    if (otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["Operator"]
                                                            .toString() ==
                                                        "between")
                                                      Row(
                                                        children: <Widget>[
                                                          Text(" to", style: TextStyle(fontSize: 13),),
                                                          Text(
                                                            " ${otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["PromoAmount2"]} ".replaceAllMapped(reg, mathFunc),
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                                color: Color(
                                                                    0xffe53935)),
                                                          ),
                                                              
                                                          otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]
                                                                  ["PromoType"] ==
                                                              "Qty" ?
                                                            Text("(pcs)", style: TextStyle(fontSize: 13),) :
                                                            Text("ks ", style: TextStyle(fontSize: 13),),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                              ],
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
                      
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]),
                          borderRadius: BorderRadius.circular(0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 7),
                            child: Text("Get",
                                    style: TextStyle(
                                      color: Color(0xffe53935),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400
                                    )),
                          ),
                          Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey[400],
                          ),
                          Column(
                            children: <Widget>[
                              for(var ii =0; ii < otherMultiStock.length; ii++)
                              Column(
                                children: <Widget>[
                                  if(ii != 0)
                                  Container(
                                    height: 1,
                                    width: MediaQuery.of(context).size.width,
                                    color: Colors.grey[400],
                                  ),
                                  if(otherMultiStock[ii].where((element) => element["EndType"] == "END").toList().length != 0)
                                    if (otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["DiscountType"] == "Inkind")
                                    if(otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"].length != 0)
                                      if(otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][0].length != 0)
                                      otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][0][0]["discountItemRuleType"] == "Total Item" ?
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context).size.width * (5/7),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    right: BorderSide(color: Colors.grey[400])
                                                  ),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    for(var a = 0; a < otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"].length; a++)
                                                    Column(
                                                      children: <Widget>[
                                                        otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a].length == 1 ?
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
                                                          child: Container(
                                                            child: Text(
                                                              "${otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a][0]["DiscountItemDesc"]}",
                                                              style: TextStyle(fontSize: 13),
                                                            ),
                                                          ),
                                                        ) : 
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
                                                          child: Column(
                                                            children: <Widget>[
                                                              for(var b = 0; b < otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a].length; b++)
                                                              Column(
                                                                children: <Widget>[
                                                                  Container(
                                                                    child: Text(
                                                                      "${otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a][b]["DiscountItemDesc"]}",
                                                                      style: TextStyle(fontSize: 13),
                                                                    ),
                                                                  ),
                                                                  if(b != otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a].length-1)
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(5),
                                                                    child: Text("(OR)", style: TextStyle(color: Colors.grey[400], fontSize: 12),),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        if(a != otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"].length-1)
                                                        Container(
                                                          height: 1,
                                                          width: (MediaQuery.of(context).size.width * (6/7)) - 43,
                                                          color: Colors.grey[400],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context).size.width * (1/7),
                                                child: Center(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Text(
                                                        "${otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][0][0]["DiscountItemQty"]}",
                                                        style: TextStyle(color: Color(0xffe53935)),
                                                      ),
                                                      Text(" pcs")
                                                    ],
                                                  ),
                                                )
                                              )
                                            ],
                                          ) :
                                          Column(
                                            children: <Widget>[
                                              for(var a = 0; a < otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"].length; a++)
                                              Column(
                                                children: <Widget>[
                                                  otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a].length == 1 ?
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: <Widget>[
                                                        Container(
                                                          child: Text(
                                                            "${otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a][0]["DiscountItemDesc"]}",
                                                            style: TextStyle(fontSize: 13),
                                                          ),
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            Text(
                                                              "${otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a][0]["DiscountItemQty"]}",
                                                              style: TextStyle(fontSize: 13, color: Color(0xffe53935)),
                                                            ),
                                                            Text(
                                                              " pcs",
                                                              style: TextStyle(fontSize: 13),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ) : 
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
                                                    child: Column(
                                                      children: <Widget>[
                                                        for(var b = 0; b < otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a].length; b++)
                                                        Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: <Widget>[
                                                                Container(
                                                                  child: Text(
                                                                    "${otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a][b]["DiscountItemDesc"]}",
                                                                    style: TextStyle(fontSize: 13),
                                                                  ),
                                                                ),
                                                                Row(
                                                                  children: <Widget>[
                                                                    Text(
                                                                      "${otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a][0]["DiscountItemQty"]}",
                                                                      style: TextStyle(fontSize: 13, color: Color(0xffe53935)),
                                                                    ),
                                                                    Text(
                                                                      " pcs",
                                                                      style: TextStyle(fontSize: 13),
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                            if(b != otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"][a].length-1)
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 7),
                                                              child: Stack(
                                                                alignment: Alignment.center,
                                                                children: <Widget>[
                                                                  Container(
                                                                    height: 1,
                                                                    color: Colors.grey[300]
                                                                  ),
                                                                  Container(
                                                                    color: Colors.grey[50],
                                                                    child: Text(" (OR) ", style: TextStyle(color: Colors.grey[400], fontSize: 12),)),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if(a != otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["InkindList"].length-1)
                                                  Container(
                                                    height: 1,
                                                    width: MediaQuery.of(context).size.width - 43,
                                                    color: Colors.grey[400],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        if (otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]
                                                ["DiscountType"] ==
                                            "Price")
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
                                            child: Row(
                                              children: <Widget>[
                                                if (otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]
                                                        ["DiscountPriceType"] ==
                                                    "Price")
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        "${otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["DiscountAmount"]}".replaceAllMapped(reg, mathFunc),
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                            color:
                                                                Color(0xffe53935)),
                                                      ),
                                                      Text(
                                                        " ks",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                            color:
                                                                Color(0xffe53935)),
                                                      ),
                                                    ],
                                                  ),
                                                if (otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]
                                                        ["DiscountPriceType"] ==
                                                    "Percentage")
                                                  Text(
                                                    "${otherMultiStock[ii].where((element) => element["EndType"] == "END").toList()[0]["DiscountAmount"]}%",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                        color:
                                                            Color(0xffe53935)),
                                                  ),
                                                Text(" off", style: TextStyle(fontSize: 13),)
                                              ],
                                            ),
                                          ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

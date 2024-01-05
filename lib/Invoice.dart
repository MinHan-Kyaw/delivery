
import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './ShopList.dart';
import './database/MerchandizerDatabase.dart';
import './navigation_bar.dart';
import './service.dart/AllService.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'Login.dart';
import 'Widgets/DiscountDetail.dart';
import 'Widgets/InvoiceDiscount.dart';
import 'Widgets/ShowImage.dart';
import 'Widgets/giftBanner.dart';
import 'database/McdDatabase.dart';
import 'database/MerchandizerNote.dart';
import 'database/shopByUserDatabase.dart';
import 'database/shopByUserNote.dart';
import 'package:delivery_2/Widgets/printer.dart';
import 'package:http/http.dart' as http;

String printer;

class InVoice extends StatefulWidget {
  final String mcdCheck;
  final String userType;
  final List<PrinterBluetooth> devices;
  final String shopName;
  final String shopNameMm;
  final String address;
  final String phone;
  final List orderStock;
  final List returnStock;
  InVoice(
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
  _InVoiceState createState() => _InVoiceState();
}

// List itemm = [];

class _InVoiceState extends State<InVoice> {
  List discountCheckList = discountStockListDate + discountStockList;
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
  double totalCount = 0;
  int returnTotal = 0;
  List orderName = [];
  List orderQty = [];
  List orderTotalCount = [];
  List printAmt = [];
  List printDiscount = [];
  List orderStock = [];
  List returnStock = [];

  String merchandizingStatus;
  String orderdetailStatus;
  String invoiceStatus;
  String invoiceComplete;

  List<PrinterBluetooth> _devices = [];
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  String _printerCtrl;
  TextEditingController specialDisCtrl = TextEditingController();
  TextEditingController cashAmtCtrl = TextEditingController();
  double cashAmount = 0;
  double specialAmount = 0;
  double totalAmount = 0;
  double specialDiscountAmt;

  double abAccount = 0;
  double spAccount = 0;
  double originalAbAccount = 0;
  double originalSpAccount = 0;
  TextEditingController abAccountCtrl = TextEditingController();
  TextEditingController spAccountCtrl = TextEditingController();
  TextEditingController cashReceivedCtrl = TextEditingController();
  int cashReceived = 0;

  List orderPrice = [];
  List returnPrice = [];
  List invPromotionList = [];
  double creditAmount = 0;

  List<MerchandizerNote> merchandizerNote;
  bool multiDiscountCheck = false;

  bool accountBoolean = false;
  bool abAccBoolean = false;
  bool spAccBoolean = false;
  bool abAmtCheck = true;
  bool spAmtCheck = true;

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

  @override
  void initState() {
    super.initState();

    _getprinter();
    _startScanDevices();
    abAccountCtrl = TextEditingController(text: "0");
    spAccountCtrl = TextEditingController(text: "0");
    cashReceivedCtrl = TextEditingController(text: "0");
    discountDataList = [];
    specialDisCtrl.text = "0";
  }

  bool loading = true;

  
  
  getList() async {
    setState(() {
      loading = true;
      getInvDisCalculationList = null;
      
    });
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    var getSysKey =
        helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));

    getSysKey.then((val) {
      print(val[0]["shopsyskey"]);
      getStoreSts(preferences.getString("spsyskey"), val[0]["shopsyskey"])
          .then((value) {
        if (value == "success") {
          setState(() {
            merchandizingStatus = merchandizingSts;
            orderdetailStatus = orderdetailSts;
            invoiceStatus = invoiceSts;

            stockImage = json.decode(preferences.getString("StockImageList"));

           if(invoiceStatus == "COMPLETED") {
              getInvoiceList(val[0]["shopcode"]).then((value) {
              if (value == "success") {
                getdeliverylist = getinvoiceOrderlist;
                getPreSeller(preferences.getString("orderdetailSyskey"), "231").then((value) {
                prepareData(val);
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
                getDeliveryListDialog(value.toString());
              }
            });
            }
 
            else {
 
            getDeliveryList(val[0]["shopcode"]).then((value) {
              if (value == "success") {
                getPreSeller(sysKey, "421").then((value) {
                prepareData(val);
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
                getDeliveryListDialog(value.toString());
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
  }

  void prepareData(val) {
    getVolDisDataForMobileDate(val[0]["shopsyskey"], getdeliverylist[0]["createddate"]).then((disValue) {
                  if (disValue == "success") {
                if (discountStockListDate.length == 0) {
                  getData(val);
                } else {
                  List sameSyskeyList = [];
                  for (var i = 0; i < getdeliverylist.length; i++) {
                    if(getdeliverylist[i]["stockData"].length == 0) {
                      getData(val);
                    } else {
                      for (var j = 0;
                        j < getdeliverylist[i]["stockData"].length;
                        j++) {
                      for (var k = 0; k < discountStockListDate.length; k++) {
                        if (getdeliverylist[i]["stockData"][j]["stockSyskey"]
                                .toString() ==
                            discountStockListDate[k]["stockSyskey"]
                                .toString()) {
                          sameSyskeyList.add(discountStockListDate[k]);
                        }
                        if (k == discountStockListDate.length - 1) {
                          if (j == getdeliverylist[i]["stockData"].length - 1) {
                            print(i);
                            print(getdeliverylist.length);
                            if (i == getdeliverylist.length - 1) {
                              discountStockListDate = sameSyskeyList;
                              getData(val);
                            }
                          }
                        }
                      }
                    }
                    }
                    
                  }
                }
              } else if (disValue == "fail") {
                setState(() {
                  loading = false;
                });
                snackbarmethod("FAIL!");
              } else {
                setState(() {
                  loading = false;
                });
                snackbarmethod(disValue);
              }
                });
  }
  
  Future<void> getInvDisCalculationDialog(String title, val) async {
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
                  setState(() {
                    loading = true;
                  });
                  getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                  if(invDisCalVal == "success") {
                    setState(() {
                      loading = false;
                      totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                    });
                  }else if(invDisCalVal == "fail") {
                    setState(() {
                      loading = false;
                    });
                    snackbarmethod("FAIL!");
                  } else {
                    setState(() {
                      loading = false;
                    });
                    getInvDisCalculationDialog(invDisCalVal, val);
                  }
                });
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
        // integerNumberPicker.animateInt(currentPrice);
      }
    });
    return currentPrice;
  }

  Future<void> getData(val) async {
    setState(() {
      orderStock = [];
      returnStock = [];
      specialDiscountAmt = 0;
      specialDisCtrl.text = "0";
      specialAmount = 0;
      accountGetBalanceList = [];
    });
    if (getdeliverylist.length == 0) {
      setState(() {
        loading = false;
      });
    } else {
      for (var b = 0; b < getdeliverylist.length; b++) {
        orderStock.add({
          "brandOwnerName": getdeliverylist[b]["brandOwnerName"],
          "brandOwnerSyskey": getdeliverylist[b]["brandOwnerSyskey"],
          "visible": true,
          "stockData": getdeliverylist[b]["stockData"]
        });

        if(invoiceStatus == "COMPLETED") {
          cashAmount = getdeliverylist[b]["cashamount"];
          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
          } else if(totalAmount == 0.0) {
            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
          } else {
            cashAmtCtrl = TextEditingController(text: "$cashAmount");
          }
          creditAmount = getdeliverylist[b]["creditAmount"];
          abAccount = getdeliverylist[b]["payment2"];
          originalAbAccount = getdeliverylist[b]["payment2"];
          if(abAccount.toString().substring(abAccount.toString().lastIndexOf("."), abAccount.toString().length).length > 3) {
            abAccountCtrl = TextEditingController(text: "${abAccount.toStringAsFixed(2)}");
          } else if(double.parse(abAccount.toString().substring(abAccount.toString().lastIndexOf("."), abAccount.toString().length)) == 0.0) {
            abAccountCtrl = TextEditingController(text: "${abAccount.toInt()}");
          } else {
            abAccountCtrl = TextEditingController(text: "$abAccount");
          }
          spAccount = getdeliverylist[b]["payment1"];
          originalSpAccount = getdeliverylist[b]["payment1"];
          if(spAccount.toString().substring(spAccount.toString().lastIndexOf("."), spAccount.toString().length).length > 3) {
            spAccountCtrl = TextEditingController(text: "${spAccount.toStringAsFixed(2)}");
          } else if(double.parse(spAccount.toString().substring(spAccount.toString().lastIndexOf("."), spAccount.toString().length)) == 0.0) {
            spAccountCtrl = TextEditingController(text: "${spAccount.toInt()}");
          } else {
            spAccountCtrl = TextEditingController(text: "$spAccount");
          }
        }

        invPromotionList = getdeliverylist[b]["promotionList"];

        returnStock.add({
          "brandOwnerName": getdeliverylist[b]["brandOwnerName"],
          "brandOwnerSyskey": getdeliverylist[b]["brandOwnerSyskey"],
          "visible": true,
          "stockData": getdeliverylist[b]["stockReturnData"]
        });

        setState(() {
          specialDiscountAmt = double.parse(
              "${getdeliverylist[b]["discountamount"]}".substring(0,
                  "${getdeliverylist[b]["discountamount"]}".lastIndexOf(".")));
          specialDisCtrl.text = "$specialDiscountAmt";

          specialAmount = double.parse("${specialDisCtrl.text}");
          cashAmount = getdeliverylist[b]["cashamount"];
        });

        if (b == getdeliverylist.length - 1) {

          setState(() {
            orderPrice = [];
            for (var i = 0; i < orderStock.length; i++) {
              for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
              }
            }

            returnPrice = [];
            for (var i = 0; i < returnStock.length; i++) {
              for (var a = 0; a < returnStock[i]["stockData"].length; a++) {
                returnPrice.add(returnStock[i]["stockData"][a]["totalAmount"].toInt());
              }
            }

            if(orderPrice.length == 0) {
              totalCount = 0;
            }else {
              totalCount = orderPrice.reduce((value, element) => value + element);
              if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                totalCount = double.parse(totalCount.toStringAsFixed(2));
              }
            }

            
            returnTotal = 0;
    
            if(returnPrice.length == 0) {
              returnTotal = 0;
            } else {
              returnTotal = int.parse("${returnPrice.reduce((value, element) => value + element)}");
            }

            totalAmount = (totalCount - returnTotal) - specialAmount;

            if(invoiceStatus != "COMPLETED") {
              if(totalAmount.toString().substring(totalAmount.toString().lastIndexOf("."), totalAmount.toString().length).length > 3) {
                cashAmtCtrl = TextEditingController(text: "${totalAmount.toStringAsFixed(2)}");
              } else if(totalAmount == 0.0) {
                cashAmtCtrl = TextEditingController(text: "${totalAmount.toInt()}");
              } else {
                cashAmtCtrl = TextEditingController(text: "$totalAmount");
              }
              
              cashAmount = totalAmount;
            }

            getInvDisCalculation(val[0]["shopsyskey"], ((totalCount - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                  if(invDisCalVal == "success") {
                    setState(() {
                        totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                        
                        if(invoiceStatus != "COMPLETED") {
                          if(totalAmount.toString().substring(totalAmount.toString().lastIndexOf("."), totalAmount.toString().length).length > 3) {
                            cashAmtCtrl = TextEditingController(text: "${totalAmount.toStringAsFixed(2)}");
                          } else if(totalAmount == 0.0) {
                            cashAmtCtrl = TextEditingController(text: "${totalAmount.toInt()}");
                          } else {
                            cashAmtCtrl = TextEditingController(text: "$totalAmount");
                          }
                          cashAmount = totalAmount;
                        }
                      if(getInvDisCalculationList["GiftList"].length != 0) {
                        invPromotionList = [];
                        for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                          invPromotionList.add({
                            "syskey" : '0',
	                          "recordStatus": 1,
	                          "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                        '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                          "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                          "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" : 
                                          '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                          "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" : 
                                                '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                          "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                          "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                          });
                        }
                      }
                    });
                  }
                  getAccountDetail(val);
                });
            
            
          });
        }
      }
    }
  }

  void getAccountDetail(val) {
    accountGetBalance(val[0]["shopsyskey"]).then((accBalanceVal) {
      print(accBalanceVal);
      if(accBalanceVal == "success") {
        if(invoiceStatus != "COMPLETED") {
        setState(() {
          if(accountGetBalanceList.length != 0) {
            if(accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == getdeliverylist[0]["brandOwnerSyskey"].toString()).toList().length != 0) {
              spAccount = accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == getdeliverylist[0]["brandOwnerSyskey"].toString()).toList()[0]["balance"];
              originalSpAccount = accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == getdeliverylist[0]["brandOwnerSyskey"].toString()).toList()[0]["balance"];
            }
            if(accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == "0").toList().length != 0) {
              abAccount = accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == "0").toList()[0]["balance"];
              originalAbAccount = accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == "0").toList()[0]["balance"];
            }
            // spAccount = 10000;
            // abAccount = 10000;
            // originalSpAccount = 10000;
            // originalAbAccount = 10000;
            if(abAccount.toString().substring(abAccount.toString().lastIndexOf("."), abAccount.toString().length).length > 3) {
              abAccountCtrl = TextEditingController(text: "${abAccount.toStringAsFixed(2)}");
            } else if(double.parse(abAccount.toString().substring(abAccount.toString().lastIndexOf("."), abAccount.toString().length)) == 0.0) {
              abAccountCtrl = TextEditingController(text: "${abAccount.toInt()}");
            } else {
              abAccountCtrl = TextEditingController(text: "$abAccount");
            }

            if(spAccount.toString().substring(spAccount.toString().lastIndexOf("."), spAccount.toString().length).length > 3) {
              spAccountCtrl = TextEditingController(text: "${spAccount.toStringAsFixed(2)}");
            } else if(double.parse(spAccount.toString().substring(spAccount.toString().lastIndexOf("."), spAccount.toString().length)) == 0.0) {
              spAccountCtrl = TextEditingController(text: "${spAccount.toInt()}");
            } else {
              spAccountCtrl = TextEditingController(text: "$spAccount");
            }
          }
        });
        }
        accountTodayCashReceived(val[0]["shopsyskey"]).then((cashReceivedVal) {
          if(cashReceivedVal == "success") {
            setState(() {
              loading = false;
              cashReceived = cashReceivedAmt.toInt();
              cashReceivedCtrl = TextEditingController(text: "$cashReceived");

            });
          } else if(cashReceivedVal == "fail") {
            setState(() {
              loading = false;
            });
          } else {
            setState(() {
              loading = false;
            });
          }
        });
      } else if(accBalanceVal == "fail") {
        accountTodayCashReceived(val[0]["shopsyskey"]).then((cashReceivedVal) {
          if(cashReceivedVal == "success") {
            setState(() {
              loading = false;
              cashReceived = cashReceivedAmt.toInt();
              cashReceivedCtrl = TextEditingController(text: "$cashReceived");

            });
          } else if(cashReceivedVal == "fail") {
            setState(() {
              loading = false;
            });
          } else {
            setState(() {
              loading = false;
            });
          }
        });
      } else {
        accountTodayCashReceived(val[0]["shopsyskey"]).then((cashReceivedVal) {
          if(cashReceivedVal == "success") {
            setState(() {
              loading = false;
              cashReceived = cashReceivedAmt.toInt();
              cashReceivedCtrl = TextEditingController(text: "$cashReceived");

            });
          } else if(cashReceivedVal == "fail") {
            setState(() {
              loading = false;
            });
          } else {
            setState(() {
              loading = false;
            });
          }
        });
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
    orderPrice = [];
    for (var i = 0; i < orderStock.length; i++) {
      for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
        orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
      }
    }

    returnPrice = [];
    for (var i = 0; i < returnStock.length; i++) {
      for (var a = 0; a < returnStock[i]["stockData"].length; a++) {
        returnPrice.add(returnStock[i]["stockData"][a]["totalAmount"].toInt());
      }
    }

    returnTotal = 0;
    
    if(returnPrice.length == 0) {
      returnTotal = 0;
    }else {
      returnTotal = int.parse("${returnPrice.reduce((value, element) => value + element)}");
    }

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
        child: Stack(
          children: <Widget>[
            Column(
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
                Container(
                  height: MediaQuery.of(context).size.height - 310,
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
                              style: TextStyle(color: Colors.black, fontSize: 17),
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
                                visible: orderStock[i]["stockData"].length == 0
                                    ? false
                                    : true,
                                child: Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        if (orderStock[i]["visible"] == false) {
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
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 15),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    orderStock[i][
                                                                "brandOwnerName"] ==
                                                            null
                                                        ? ""
                                                        : orderStock[i]
                                                            ["brandOwnerName"],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white),
                                                  ),
                                                  Icon(
                                                    orderStock[i]["visible"]
                                                        ? Icons.keyboard_arrow_down
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
                                              Visibility(
                                                visible: (a != 0 && orderStock[i]["stockData"][a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().toString() == orderStock[i]["stockData"][a-1]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().toString() && orderStock[i]["stockData"][a]["promotionStockList"].length != 0) ? false : true,
                                                child: Column(
                                                  children: <Widget>[
                                                    Card(
                                                      elevation: 3,
                                                      child: Column(
                                                        children: <Widget>[
                                                          Stack(
                                                            children: <Widget>[
                                                              Row(
                                                                children: <Widget>[
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      print(stockImage
                                                                          .where((element) =>
                                                                              element[
                                                                                  "stockCode"] ==
                                                                              orderStock[i][
                                                                                      "stockData"]
                                                                                  [
                                                                                  a]["stockCode"])
                                                                          .toList());
                                                                    },
                                                                    child: ConstrainedBox(
                                                                      constraints:
                                                                          BoxConstraints(
                                                                        maxWidth: 64,
                                                                        maxHeight: 80,
                                                                      ),
                                                                      // child: stockImage
                                                                      //                 .where((element) =>
                                                                      //                     element[
                                                                      //                         "stockCode"] ==
                                                                      //                     orderStock[i]
                                                                      //                             ["stockData"][a]
                                                                      //                         [
                                                                      //                         "stockCode"])
                                                                      //                 .toList()[0]
                                                                      //             ["image"] !=
                                                                      //         null
                                                                      //     ? Image.network(
                                                                      //         "http://52.255.142.115:8084${stockImage.where((element) => element["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
                                                                      //         fit: BoxFit.cover,

                                                                      //       )
                                                                      //     : Image.asset(
                                                                      //         "assets/coca.png",
                                                                      //         fit: BoxFit.cover),
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
                                                                                                orderStock[i]["stockData"][a]["stockCode"])
                                                                                            .toList()
                                                                                            .toString() ==
                                                                                        '[]'
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
                                                                                              MaterialPageRoute(builder: (context) => ShowImage(image: CachedNetworkImage(imageUrl: "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}"))));
                                                                                        },
                                                                                        // child:
                                                                                        //     Image.network(
                                                                                        //   "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
                                                                                        //   fit: BoxFit.cover,
                                                                                        // ),
                                                                                        child:
                                                                                            CachedNetworkImage(
                                                                                          imageUrl:
                                                                                              "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
                                                                                        ),
                                                                                      )
                                                                              ],
                                                                            ),
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
                                                                          const EdgeInsets.only(
                                                                              right: 3,
                                                                              top: 20,
                                                                              bottom: 10,
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
                                                                            children: <Widget>[
                                                                              Container(
                                                                                width: MediaQuery.of(
                                                                                            context)
                                                                                        .size
                                                                                        .width -
                                                                                    100,
                                                                                // height: 20,
                                                                                margin: EdgeInsets
                                                                                    .only(
                                                                                        top: 5),
                                                                                child: Text(
                                                                                  "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(
                                                                                    top: 5),
                                                                            child: Row(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment
                                                                                      .spaceBetween,
                                                                              children: <
                                                                                  Widget>[
                                                                                invoiceStatus ==
                                                                                        "COMPLETED" || multiDiscountCheck == true
                                                                                    ? Row(
                                                                                        children: <
                                                                                            Widget>[
                                                                                          Text(
                                                                                              "Qty : "),
                                                                                          Text("${orderStock[i]["stockData"][a]["qty"]}".substring(
                                                                                              0,
                                                                                              "${orderStock[i]["stockData"][a]["qty"]}".lastIndexOf("."))),
                                                                                        ],
                                                                                      )
                                                                                    : Row(
                                                                                        crossAxisAlignment:
                                                                                            CrossAxisAlignment.center,
                                                                                        children: <
                                                                                            Widget>[
                                                                                          Container(
                                                                                            child:
                                                                                                GestureDetector(
                                                                                              onTap: () async {
                                                                                                final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                                if (orderStock[i]["stockData"][a]["qty"] == 1 || orderStock[i]["stockData"][a]["qty"] < 1) {
                                                                                                } else {
                                                                                                  setState(() {
                                                                                                    orderStock[i]["stockData"][a]["qty"]--;

                                                                                                    orderStock[i]["stockData"][a]["totalAmount"] = orderStock[i]["stockData"][a]["qty"] * orderStock[i]["stockData"][a]["normalPrice"];

                                                                                                    orderPrice = [];
                                                                                                    for (var m = 0; m < orderStock.length; m++) {
                                                                                                      for (var n = 0; n < orderStock[m]["stockData"].length; n++) {
                                                                                                        orderPrice.add(orderStock[m]["stockData"][n]["totalAmount"]);
                                                                                                      }
                                                                                                    }

                                                                                                    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                                      getSysKey.then((val) {

                                                                                                    

                                                                                                    if(discountCheckList.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0) {
                                                                                                      _handleSubmit(context);
                                                                                                      
                                                                                                      var param;
                                                                                                      if(discountStockListDate.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString() && element["createddate"] == orderStock[i]["stockData"][a]["appliedDate"].toString()).toList().length != 0) {
                                                                                                        param = jsonEncode(
                                                                                                          {
                                                                                                            "itemSyskey": "${orderStock[i]["stockData"][a]["stockSyskey"]}",
                                                                                                            "itemDesc": "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                                            "itemAmount": orderStock[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                            "itemTotalAmount": orderStock[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                            "itemQty": orderStock[i]["stockData"][a]["qty"].toInt(),
                                                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                            "date": "${discountStockListDate.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                                                                                                          }
                                                                                                        );
                                                                                                      } else {
                                                                                                        datetime();
                                                                                                        param = jsonEncode(
                                                                                                          {
                                                                                                            "itemSyskey": "${orderStock[i]["stockData"][a]["stockSyskey"]}",
                                                                                                            "itemDesc": "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                                            "itemAmount": orderStock[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                            "itemTotalAmount": orderStock[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                            "itemQty": orderStock[i]["stockData"][a]["qty"].toInt(),
                                                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                            "date": "$date"
                                                                                                          }
                                                                                                        );
                                                                                                      }

                                                                                                      getVolDisCalculation(param, orderStock[i]["stockData"], context, false).then((getVolDisCalculationValue) {
                                                                                                        if(getVolDisCalculationValue == "success") {
                                                                                                          setState(() {
                                                                                                            
                                                                                                            if(newStockList.length != 0) {
                                                                                                              orderStock[i]["stockData"] = newStockList;
                                                                                                            }
                                                                                                            
                                                                                                            if(discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0.0" ||
                                                                                                              discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0") {
                                                                                                              var discountpercent = discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"];
                                                                                                              orderStock[i]["stockData"][a]["totalAmount"] = (orderStock[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100)) * orderStock[i]["stockData"][a]["qty"];
                                                                                                              orderStock[i]["stockData"][a]["price"] = orderStock[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100);
                                                                                                              orderStock[i]["stockData"][a]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];
                                                                                                            }
                                                                                                            orderPrice = [];
                                                                                                            for (var i = 0; i < orderStock.length; i++) {
                                                                                                              for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                                orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                              }
                                                                                                            }
                                                                                                            totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                            if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                              totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                            }
                                                                                                            totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                            if(accountBoolean == true) {
                                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                            } else {
                                                                                                              cashAmount = totalAmount;
                                                                                                            }
                                                                                                            if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                            } else if(totalAmount == 0.0) {
                                                                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                            } else {
                                                                                                              cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                            }
                                                                                                            if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                      for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                        if (stockByBrandDel[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                          for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                            if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                              stockByBrandDel[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                              stockByBrandDel[b]["stockData"][c]["price"] = orderStock[i]["stockData"][a]["price"];
                                                                                                              stockByBrandDel[b]["stockData"][c]["promoDetailSyskey"] = orderStock[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    } else {
                                                                                                      for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                        if (getdeliverylist[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                          for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                            if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                              getdeliverylist[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                              getdeliverylist[b]["stockData"][c]["price"] = orderStock[i]["stockData"][a]["price"];
                                                                                                              getdeliverylist[b]["stockData"][c]["promoDetailSyskey"] = orderStock[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    }

                                                                                                    
                                                                                                    orderPrice = [];
                                                                                                    for (var i = 0; i < orderStock.length; i++) {
                                                                                                      for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                        orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                      }
                                                                                                    }
                                                                                                    totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                    if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                      totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                    }
                                                                                                    totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                    if(accountBoolean == true) {
                                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                        if(totalAmount < 0) {
                                                                                                          //
                                                                                                        } else {
                                                                                                          cashAmount = totalAmount;
                                                                                                        }
                                                                                                      }
                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                    getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                                                                                                      if(invDisCalVal == "success") {
                                                                                                      orderPrice = [];
                                                                                                      for (var i = 0; i < orderStock.length; i++) {
                                                                                                        for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                          orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                        }
                                                                                                      }
                                                                                                      totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                      if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                        totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                      }
                                                                                                      totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                      if(accountBoolean == true) {
                                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                          cashAmount = totalAmount;
                                                                                                      }
                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                      if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                                        //
                                                                                                      } else {
                                                                                                        if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                          setState(() {
                                                                                                            invPromotionList = [];
                                                                                                          });
                                                                                                        } else {
                                                                                                          invPromotionList = [];
                                                                                                          for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                            invPromotionList.add({
                                                                                                              "syskey" : '0',
	                                                                                                            "recordStatus": 1,
	                                                                                                            "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                          '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                            "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                            "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                             '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                            "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                                 '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                            "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                            "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                            });
                                                                                                          }
                                                                                                        }
                                                                                                        setState(() {
                                                                                                          totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                                        });
                                                                                                      }

                                                                                                      for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                                        getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                                      }

                                                                                                      if(accountBoolean == true) {
                                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                          cashAmount = totalAmount;
                                                                                                      }

                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                      }
                                                                                                      
                                                                                                    });
                                                                                                            Navigator.pop(context);
                                                                                                          });
                                                                                                        }else if(getVolDisCalculationValue == "fail") {
                                                                                                          Navigator.pop(context);
                                                                                                          snackbarmethod("FAIL!");
                                                                                                        }else {
                                                                                                          Navigator.pop(context);
                                                                                                          // getVolDisCalculationDialog(param, getVolDisCalculationValue.toString(), orderStock[i]["stockData"][a]);
                                                                                                        }
                                                                                                      });
                                                                                                
                                                                                                    }
                                                                                                    else{
                                                                                                      if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                      for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                        if (stockByBrandDel[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                          for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                            if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                              stockByBrandDel[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    } else {
                                                                                                      for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                        if (getdeliverylist[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                          for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                            if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                              getdeliverylist[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    }

                                                                                                    orderPrice = [];
                                                                                                    for (var i = 0; i < orderStock.length; i++) {
                                                                                                      for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                        orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                      }
                                                                                                    }
                                                                                                    totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                    if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                      totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                    }
                                                                                                    totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                    if(accountBoolean == true) {
                                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                          cashAmount = totalAmount;
                                                                                                      }

                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                    getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                                                                                                      if(invDisCalVal == "success") {
                                                                                                      orderPrice = [];
                                                                                                      for (var i = 0; i < orderStock.length; i++) {
                                                                                                        for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                          orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                        }
                                                                                                      }
                                                                                                      totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                      if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                        totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                      }
                                                                                                      totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                      if(accountBoolean == true) {
                                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                          cashAmount = totalAmount;
                                                                                                      }

                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                      if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                                        //
                                                                                                      } else {
                                                                                                        if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                          setState(() {
                                                                                                            invPromotionList = [];
                                                                                                          });
                                                                                                        } else {
                                                                                                          invPromotionList = [];
                                                                                                          for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                            invPromotionList.add({
                                                                                                              "syskey" : '0',
	                                                                                                            "recordStatus": 1,
	                                                                                                            "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                          '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                            "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                            "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                             '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                            "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                                 '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                            "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                            "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                            });
                                                                                                          }
                                                                                                        }
                                                                                                        setState(() {
                                                                                                          totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                                        });
                                                                                                      }

                                                                                                      for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                                        getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                                      }

                                                                                                      if(accountBoolean == true) {
                                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                          cashAmount = totalAmount;
                                                                                                      }

                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }

                                                                                                      }
                                                                                                    });
                                                                                                    }
                                                                                                    
                                                                                                  });
                                                                                                  });
                                                                                                }
                                                                                              },
                                                                                              child: Center(
                                                                                                  child: Icon(
                                                                                                const IconData(0xe15b, fontFamily: 'MaterialIcons'),
                                                                                                color: Colors.white,
                                                                                                size: 19,
                                                                                              )),
                                                                                            ),
                                                                                            decoration:
                                                                                                BoxDecoration(
                                                                                              color: Color(0xffe53935),
                                                                                              borderRadius: BorderRadius.circular(3),
                                                                                              border: Border(
                                                                                                top: BorderSide(width: 0.5, color: Colors.white),
                                                                                                bottom: BorderSide(width: 0.5, color: Colors.white),
                                                                                                left: BorderSide(width: 0.5, color: Colors.white),
                                                                                                right: BorderSide(width: 0.5, color: Colors.white),
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
                                                                                              _showIntDialog(int.parse("${orderStock[i]["stockData"][a]["qty"]}".substring(0, orderStock[i]["stockData"][a]["qty"].toString().lastIndexOf(".")))).then((value) {
                                                                                                setState(() {
                                                                                                  orderStock[i]["stockData"][a]["qty"] = value.toDouble();

                                                                                                  orderStock[i]["stockData"][a]["totalAmount"] = orderStock[i]["stockData"][a]["qty"] * orderStock[i]["stockData"][a]["normalPrice"];
                                                                                                });

                                                                                                orderPrice = [];
                                                                                                for (var m = 0; m < orderStock.length; m++) {
                                                                                                  for (var n = 0; n < orderStock[m]["stockData"].length; n++) {
                                                                                                    orderPrice.add(orderStock[m]["stockData"][n]["totalAmount"]);
                                                                                                  }
                                                                                                }

                                                                                                var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                                      getSysKey.then((val) {

                                                                                                

                                                                                                if(discountCheckList.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0) {
                                                                                                      _handleSubmit(context);
                                                                                                      
                                                                                                        var param;
                                                                                                      if(discountStockListDate.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString() && element["createddate"] == orderStock[i]["stockData"][a]["appliedDate"].toString()).toList().length != 0) {
                                                                                                        param = jsonEncode(
                                                                                                          {
                                                                                                            "itemSyskey": "${orderStock[i]["stockData"][a]["stockSyskey"]}",
                                                                                                            "itemDesc": "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                                            "itemAmount": orderStock[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                            "itemTotalAmount": orderStock[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                            "itemQty": orderStock[i]["stockData"][a]["qty"].toInt(),
                                                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                            "date": "${discountStockListDate.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                                                                                                          }
                                                                                                        );
                                                                                                      } else {
                                                                                                        datetime();
                                                                                                        param = jsonEncode(
                                                                                                          {
                                                                                                            "itemSyskey": "${orderStock[i]["stockData"][a]["stockSyskey"]}",
                                                                                                            "itemDesc": "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                                            "itemAmount": orderStock[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                            "itemTotalAmount": orderStock[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                            "itemQty": orderStock[i]["stockData"][a]["qty"].toInt(),
                                                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                            "date": "$date"
                                                                                                          }
                                                                                                        );
                                                                                                      }

                                                                                                      getVolDisCalculation(param, orderStock[i]["stockData"], context, false).then((getVolDisCalculationValue) {
                                                                                                        if(getVolDisCalculationValue == "success") {
                                                                                                          setState(() {
                                                                                                            if(newStockList.length != 0) {
                                                                                                              orderStock[i]["stockData"] = newStockList;
                                                                                                            }
                                                                                                            
                                                                                                            if(discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0.0" ||
                                                                                                              discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0") {
                                                                                                              var discountpercent = discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"];
                                                                                                              orderStock[i]["stockData"][a]["totalAmount"] = (orderStock[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100)) * orderStock[i]["stockData"][a]["qty"];
                                                                                                              orderStock[i]["stockData"][a]["price"] = orderStock[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100);
                                                                                                              orderStock[i]["stockData"][a]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];
                                                                                                            }

                                                                                                            orderPrice = [];
                                                                                                            for (var i = 0; i < orderStock.length; i++) {
                                                                                                              for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                                orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                              }
                                                                                                            }
                                                                                                            totalCount = orderPrice.reduce((value, element) => value + element);

                                                                                                            if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                              totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                            }

                                                                                                            if(accountBoolean == true) {
                                                                                                              if(((totalCount - returnTotal) - specialAmount) - (abAccount + spAccount) < 0) {
                                                                                                                //
                                                                                                              } else {
                                                                                                                cashAmount = ((totalCount - returnTotal) - specialAmount) - (abAccount + spAccount);
                                                                                                              }
                                                                                                            } else {
                                                                                                              if(((totalCount - returnTotal) - specialAmount) < 0) {
                                                                                                                //
                                                                                                              } else {
                                                                                                                cashAmount = ((totalCount - returnTotal) - specialAmount);
                                                                                                              }
                                                                                                            }

                                                                                                            if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                            } else if(totalAmount == 0.0) {
                                                                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                            } else {
                                                                                                              cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                            }
                                                                                                             if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                  for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                    if (stockByBrandDel[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                      for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                        if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                          stockByBrandDel[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                          stockByBrandDel[b]["stockData"][c]["price"] = orderStock[i]["stockData"][a]["price"];
                                                                                                          stockByBrandDel[b]["stockData"][c]["promoDetailSyskey"] = orderStock[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                } else {
                                                                                                  for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                    if (getdeliverylist[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                      for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                        if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                          getdeliverylist[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                          getdeliverylist[b]["stockData"][c]["price"] = orderStock[i]["stockData"][a]["price"];
                                                                                                          getdeliverylist[b]["stockData"][c]["promoDetailSyskey"] = orderStock[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                }

                                                                                                orderPrice = [];
                                                                                                for (var i = 0; i < orderStock.length; i++) {
                                                                                                  for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                    orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                  }
                                                                                                }
                                                                                                totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                  totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                }
                                                                                                totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                if(accountBoolean == true) {
                                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                          cashAmount = totalAmount;
                                                                                                      }
                                                                                                if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                                                                                                  if(invDisCalVal == "success") {
                                                                                                  setState(() {
                                                                                                    orderPrice = [];
                                                                                                    for (var i = 0; i < orderStock.length; i++) {
                                                                                                      for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                        orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                      }
                                                                                                    }
                                                                                                    totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                    if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                      totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                    }
                                                                                                  totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                  if(accountBoolean == true) {
                                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                          cashAmount = totalAmount;
                                                                                                      }
                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                  if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                                    //
                                                                                                  }else {
                                                                                                    if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                      setState(() {
                                                                                                        invPromotionList = [];
                                                                                                      });
                                                                                                    } else {
                                                                                                      invPromotionList = [];
                                                                                                      for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                        invPromotionList.add({
                                                                                                          "syskey" : '0',
	                                                                                                        "recordStatus": 1,
	                                                                                                        "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                      '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                        "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                        "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                         '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                        "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                             '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                        "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                        "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                        });
                                                                                                      }
                                                                                                    }
                                                                                                    setState(() {
                                                                                                      totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                                    });
                                                                                                  }

                                                                                                  for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                                    getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                                  }

                                                                                                  if(accountBoolean == true) {
                                                                                                      cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                  } else {
                                                                                                      cashAmount = totalAmount;
                                                                                                  }

                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                  });
                                                                                                  }
                                                                                                });
                                                                                                            Navigator.pop(context);
                                                                                                          });
                                                                                                        }else if(getVolDisCalculationValue == "fail") {
                                                                                                          Navigator.pop(context);
                                                                                                          snackbarmethod("FAIL!");
                                                                                                        }else {
                                                                                                          Navigator.pop(context);
                                                                                                          // getVolDisCalculationDialog(param, getVolDisCalculationValue.toString(), orderStock[i]["stockData"][a]);
                                                                                                        }
                                                                                                      });
                                                                                                    
                                                                                                
                                                                                                    }
                                                                                                    else{
                                                                                                       if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                  for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                    if (stockByBrandDel[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                      for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                        if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                          stockByBrandDel[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                } else {
                                                                                                  for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                    if (getdeliverylist[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                      for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                        if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                          getdeliverylist[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                }

                                                                                                orderPrice = [];
                                                                                                for (var i = 0; i < orderStock.length; i++) {
                                                                                                  for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                    orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                  }
                                                                                                }
                                                                                                totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                  totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                }
                                                                                                totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                if(accountBoolean == true) {
                                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                          cashAmount = totalAmount;
                                                                                                      }

                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                                                                                                  if(invDisCalVal == "success") {
                                                                                                  setState(() {
                                                                                                    orderPrice = [];
                                                                                                    for (var i = 0; i < orderStock.length; i++) {
                                                                                                      for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                        orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                      }
                                                                                                    }
                                                                                                    totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                    if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                      totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                    }
                                                                                                  totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                  if(accountBoolean == true) {
                                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                          cashAmount = totalAmount;
                                                                                                      }

                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                  if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                                    //
                                                                                                  }else {
                                                                                                    if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                      setState(() {
                                                                                                        invPromotionList = [];
                                                                                                      });
                                                                                                    } else {
                                                                                                      invPromotionList = [];
                                                                                                      for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                        invPromotionList.add({
                                                                                                          "syskey" : '0',
	                                                                                                        "recordStatus": 1,
	                                                                                                        "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                      '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                        "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                        "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                         '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                        "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                             '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                        "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                        "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                        });
                                                                                                      }
                                                                                                    }

                                                                                                    setState(() {
                                                                                                      totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                                    });
                                                                                                  }

                                                                                                  for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                                    getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                                  }

                                                                                                  if(accountBoolean == true) {
                                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                          cashAmount = totalAmount;
                                                                                                      }

                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                  });
                                                                                                  }
                                                                                                });
                                                                                                    }

                                                                                               
                                                                                              });
                                                                                              });
                                                                                            },
                                                                                            child:
                                                                                                Container(
                                                                                              child: Center(child: Text("${orderStock[i]["stockData"][a]["qty"]}".substring(0, orderStock[i]["stockData"][a]["qty"].toString().lastIndexOf(".")))),
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
                                                                                              onTap: () async {
                                                                                                final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                                if (orderStock[i]["stockData"][a]["qty"] == 99999 || orderStock[i]["stockData"][a]["qty"] > 99999) {
                                                                                                } else {
                                                                                                  setState(() {
                                                                                                    orderStock[i]["stockData"][a]["qty"]++;

                                                                                                    orderStock[i]["stockData"][a]["totalAmount"] = orderStock[i]["stockData"][a]["qty"] * orderStock[i]["stockData"][a]["normalPrice"];

                                                                                                    orderPrice = [];
                                                                                                    for (var m = 0; m < orderStock.length; m++) {
                                                                                                      for (var n = 0; n < orderStock[m]["stockData"].length; n++) {
                                                                                                        orderPrice.add(orderStock[m]["stockData"][n]["totalAmount"]);
                                                                                                      }
                                                                                                    }

                                                                                                    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                                      getSysKey.then((val) {

                                                                                                    

                                                                                                    if(discountCheckList.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0) {
                                                                                                      _handleSubmit(context);
                                                                                                      
                                                                                                        var param;
                                                                                                      if(discountStockListDate.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString() && element["createddate"] == orderStock[i]["stockData"][a]["appliedDate"].toString()).toList().length != 0) {
                                                                                                        param = jsonEncode(
                                                                                                          {
                                                                                                            "itemSyskey": "${orderStock[i]["stockData"][a]["stockSyskey"]}",
                                                                                                            "itemDesc": "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                                            "itemAmount": orderStock[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                            "itemTotalAmount": orderStock[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                            "itemQty": orderStock[i]["stockData"][a]["qty"].toInt(),
                                                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                            "date": "${discountStockListDate.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                                                                                                          }
                                                                                                        );
                                                                                                      } else {
                                                                                                        datetime();
                                                                                                        param = jsonEncode(
                                                                                                          {
                                                                                                            "itemSyskey": "${orderStock[i]["stockData"][a]["stockSyskey"]}",
                                                                                                            "itemDesc": "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                                            "itemAmount": orderStock[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                            "itemTotalAmount": orderStock[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                            "itemQty": orderStock[i]["stockData"][a]["qty"].toInt(),
                                                                                                            "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                            "date": "$date"
                                                                                                          }
                                                                                                        );
                                                                                                      }

                                                                                                      getVolDisCalculation(param, orderStock[i]["stockData"], context, false).then((getVolDisCalculationValue) {
                                                                                                        if(getVolDisCalculationValue == "success") {
                                                                                                          // print(newStockList);
                                                                                                          setState(() {

                                                                                                            print(discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["afterDiscountTotal"]);
                                                                                                            
                                                                                                            if(newStockList.length != 0) {
                                                                                                              orderStock[i]["stockData"] = newStockList;
                                                                                                            }
                                                                                                            if(discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() == "0.0" ||
                                                                                                            discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() == "0") {
                                                                                                              //
                                                                                                            } else {
                                                                                                              var discountpercent = discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"];
                                                                                                              orderStock[i]["stockData"][a]["totalAmount"] = (orderStock[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100)) * orderStock[i]["stockData"][a]["qty"];
                                                                                                              orderStock[i]["stockData"][a]["price"] = orderStock[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100);
                                                                                                              orderStock[i]["stockData"][a]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];
                                                                                                            }
                                                                                                            
                                                                                                            orderPrice = [];
                                                                                                            for (var i = 0; i < orderStock.length; i++) {
                                                                                                              for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                                orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                              }
                                                                                                            }
                                                                                                            totalCount = orderPrice.reduce((value, element) => value + element);

                                                                                                            if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                              totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                            }

                                                                                                            if(accountBoolean == true) {
                                                                                                              if(((totalCount - returnTotal) - specialAmount) - (abAccount + spAccount) < 0) {
                                                                                                                //
                                                                                                              } else {
                                                                                                                cashAmount = ((totalCount - returnTotal) - specialAmount) - (abAccount + spAccount);
                                                                                                              }
                                                                                                            } else {
                                                                                                              if(((totalCount - returnTotal) - specialAmount) < 0) {
                                                                                                                //
                                                                                                              } else {
                                                                                                                cashAmount = ((totalCount - returnTotal) - specialAmount);
                                                                                                              }
                                                                                                            }

                                                                                                            if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                            } else if(totalAmount == 0.0) {
                                                                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                            } else {
                                                                                                              cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                            }
                                                                                                            if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                              for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                                if (stockByBrandDel[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                                  for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                                    if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                                      stockByBrandDel[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                                      stockByBrandDel[b]["stockData"][c]["price"] = orderStock[i]["stockData"][a]["price"];
                                                                                                                      stockByBrandDel[b]["stockData"][c]["promoDetailSyskey"] = orderStock[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                            } else {
                                                                                                              for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                                if (getdeliverylist[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                                  for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                                    if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                                      getdeliverylist[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                                      getdeliverylist[b]["stockData"][c]["price"] = orderStock[i]["stockData"][a]["price"];
                                                                                                                      getdeliverylist[b]["stockData"][c]["promoDetailSyskey"] = orderStock[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                            }

                                                                                                            orderPrice = [];
                                                                                                            for (var i = 0; i < orderStock.length; i++) {
                                                                                                              for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                                orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                              }
                                                                                                            }
                                                                                                            totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                            if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                              totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                            }
                                                                                                            totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                            if(accountBoolean == true) {
                                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                          cashAmount = totalAmount;
                                                                                                      }

                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                            getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                                                                                                              if(invDisCalVal == "success") {
                                                                                                              orderPrice = [];
                                                                                                              for (var i = 0; i < orderStock.length; i++) {
                                                                                                                for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                                  orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                                }
                                                                                                              }
                                                                                                              totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                              if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                                totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                              }
                                                                                                              totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                              if(accountBoolean == true) {
                                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                          cashAmount = totalAmount;
                                                                                                      }

                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                              if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                                                //
                                                                                                              }else {
                                                                                                                if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                                  setState(() {
                                                                                                                    invPromotionList = [];
                                                                                                                  });
                                                                                                                } else {
                                                                                                                  invPromotionList = [];
                                                                                                                  for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                                    invPromotionList.add({
                                                                                                                      "syskey" : '0',
	                                                                                                                    "recordStatus": 1,
	                                                                                                                    "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                                  '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                                    "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                                    "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                                     '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                                    "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                                         '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                                    "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                                    "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                                    });
                                                                                                                  }
                                                                                                                }
                                                                                                                setState(() {
                                                                                                                  totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                                                });
                                                                                                              }

                                                                                                              for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                                                getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                                              }

                                                                                                              if(accountBoolean == true) {
                                                                                                                cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                              } else {
                                                                                                                cashAmount = totalAmount;
                                                                                                              }

                                                                                                              if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                                cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                              } else if(totalAmount == 0.0) {
                                                                                                                cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                              } else {
                                                                                                                cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                              }
                                                                                                              }
                                                                                                            });
                                                                                                            Navigator.pop(context);
                                                                                                          });
                                                                                                        }else if(getVolDisCalculationValue == "fail") {
                                                                                                          Navigator.pop(context);
                                                                                                          snackbarmethod("FAIL!");
                                                                                                        }else {
                                                                                                          Navigator.pop(context);
                                                                                                          // getVolDisCalculationDialog(param, getVolDisCalculationValue.toString(), orderStock[i]["stockData"][a]);
                                                                                                        }
                                                                                                      });
                                                                                                    }
                                                                                                    
                                                                                                    else{
                                                                                                      if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                      for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                        if (stockByBrandDel[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                          for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                            if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                              stockByBrandDel[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    } else {
                                                                                                      for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                        if (getdeliverylist[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                          for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                            if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                              getdeliverylist[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    }

                                                                                                    orderPrice = [];
                                                                                                    for (var i = 0; i < orderStock.length; i++) {
                                                                                                      for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                        orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                      }
                                                                                                    }
                                                                                                    totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                    if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                      totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                    }
                                                                                                    totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                    if(accountBoolean == true) {
                                                                                                      cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                    } else {
                                                                                                      cashAmount = totalAmount;
                                                                                                    }

                                                                                                    if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                      cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                    } else if(totalAmount == 0.0) {
                                                                                                      cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                    } else {
                                                                                                      cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                    }
                                                                                                    getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                                                                                                      if(invDisCalVal == "success") {
                                                                                                      orderPrice = [];
                                                                                                      for (var i = 0; i < orderStock.length; i++) {
                                                                                                        for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                          orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                        }
                                                                                                      }
                                                                                                      totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                      if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                        totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                      }
                                                                                                      totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                      if(accountBoolean == true) {
                                                                                                        cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                        cashAmount = totalAmount;
                                                                                                      }

                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                      if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                                        //
                                                                                                      }else {
                                                                                                        if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                          setState(() {
                                                                                                            invPromotionList = [];
                                                                                                          });
                                                                                                        } else {
                                                                                                          invPromotionList = [];
                                                                                                          for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                            invPromotionList.add({
                                                                                                              "syskey" : '0',
	                                                                                                            "recordStatus": 1,
	                                                                                                            "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                          '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                            "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                            "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                             '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                            "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                                 '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                            "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                            "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                            });
                                                                                                          }
                                                                                                        }
                                                                                                        setState(() {
                                                                                                          totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                                        });
                                                                                                      }

                                                                                                      for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                                        getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                                      }

                                                                                                      if(accountBoolean == true) {
                                                                                                        cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                        cashAmount = totalAmount;
                                                                                                      }

                                                                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                                      }
                                                                                                    });
                                                                                                    }
                                                                                                  });
                                                                                                  });
                                                                                                }
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
                                                                                      Text("${orderStock[i]["stockData"][a]["normalPrice"]}".substring(
                                                                                          0,
                                                                                          orderStock[i]["stockData"][a]["normalPrice"]
                                                                                              .toString()
                                                                                              .lastIndexOf("."))),
                                                                                      Padding(
                                                                                        padding:
                                                                                            const EdgeInsets.only(right: 15),
                                                                                        child: Text(
                                                                                          orderStock[i]["stockData"][a]["totalAmount"].toString().substring(orderStock[i]["stockData"][a]["totalAmount"].toString().lastIndexOf("."), orderStock[i]["stockData"][a]["totalAmount"].toString().length).length > 3 ?
                                                                                          "${orderStock[i]["stockData"][a]["totalAmount"].toStringAsFixed(2)}" :
                                                                                          double.parse(orderStock[i]["stockData"][a]["totalAmount"].toString().substring(orderStock[i]["stockData"][a]["totalAmount"].toString().lastIndexOf("."), orderStock[i]["stockData"][a]["totalAmount"].toString().length)) == 0.0 ?
                                                                                            "${orderStock[i]["stockData"][a]["totalAmount"].toInt()}" :
                                                                                            "${orderStock[i]["stockData"][a]["totalAmount"]}"
                                                                                            ),
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
                                                                                          orderStock[i]["stockData"][a]["discountAmount"] == "" || orderStock[i]["stockData"][a]["discountAmount"].toString() == "0.0" || orderStock[i]["stockData"][a]["discountAmount"].toString() == "0" || orderStock[i]["stockData"][a]["discountPercent"] == "" || orderStock[i]["stockData"][a]["discountPercent"].toString() == "0.0" || orderStock[i]["stockData"][a]["discountPercent"].toString() == "0" ?
                                                                                          "" :
                                                                                          (orderStock[i]["stockData"][a]["discountPercent"].toString() == "0.0" || orderStock[i]["stockData"][a]["discountPercent"].toString() == "0") &&
                                                                                          (orderStock[i]["stockData"][a]["discountAmount"].toString() == "0.0" || orderStock[i]["stockData"][a]["discountAmount"].toString() == "0") ? "" : 
                                                                                          "${orderStock[i]["stockData"][a]["normalPrice"].toInt() * orderStock[i]["stockData"][a]["qty"].toInt()}",
                                                                                          style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12),),
                                                                                        orderStock[i]["stockData"][a]["discountAmount"] == "" || orderStock[i]["stockData"][a]["discountAmount"].toString() == "0.0" || orderStock[i]["stockData"][a]["discountAmount"].toString() == "0" || orderStock[i]["stockData"][a]["discountPercent"] == "" || orderStock[i]["stockData"][a]["discountPercent"].toString() == "0.0" || orderStock[i]["stockData"][a]["discountPercent"].toString() == "0" ?
                                                                                        Text("") :
                                                                                        Text(
                                                                                          orderStock[i]["stockData"][a]["discountPercent"].toString() != "0.0" || orderStock[i]["stockData"][a]["discountPercent"].toString() != "0" ?
                                                                                          "  -${orderStock[i]["stockData"][a]["discountPercent"]}%" :
                                                                                          orderStock[i]["stockData"][a]["discountAmount"].toString() != "0.0" || orderStock[i]["stockData"][a]["discountAmount"].toString() != "0" ?
                                                                                          "  -${orderStock[i]["stockData"][a]["discountAmount"].toInt()}" : ""
                                                                                          , style: TextStyle(color: Colors.red, fontSize: 12),),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              if(discountCheckList.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0 ||
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
                                                          if(a != orderStock[i]["stockData"].length-1)
                                                          if(orderStock[i]["stockData"][a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().toString() == orderStock[i]["stockData"][a+1]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().toString() && orderStock[i]["stockData"][a]["promotionStockList"].where((element) => element["recordStatus"] == 1).toList().length != 0 && orderStock[i]["stockData"][a]["promotionStockList"].length != 0)
                                                          Column(
                                                            children: <Widget>[
                                                              Divider(color: Color(0xffe53935)),
                                                              Stack(
                                                                children: <Widget>[
                                                                  Row(
                                                                    children: <Widget>[
                                                                      GestureDetector(
                                                                        onTap: () {
                                                                          print(stockImage
                                                                              .where((element) =>
                                                                                  element[
                                                                                      "stockCode"] ==
                                                                                  orderStock[i][
                                                                                          "stockData"]
                                                                                      [
                                                                                      a]["stockCode"])
                                                                              .toList());
                                                                        },
                                                                        child: ConstrainedBox(
                                                                          constraints:
                                                                              BoxConstraints(
                                                                            maxWidth: 64,
                                                                            maxHeight: 80,
                                                                          ),
                                                                          // child: stockImage
                                                                          //                 .where((element) =>
                                                                          //                     element[
                                                                          //                         "stockCode"] ==
                                                                          //                     orderStock[i]
                                                                          //                             ["stockData"][a]
                                                                          //                         [
                                                                          //                         "stockCode"])
                                                                          //                 .toList()[0]
                                                                          //             ["image"] !=
                                                                          //         null
                                                                          //     ? Image.network(
                                                                          //         "http://52.255.142.115:8084${stockImage.where((element) => element["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
                                                                          //         fit: BoxFit.cover,

                                                                          //       )
                                                                          //     : Image.asset(
                                                                          //         "assets/coca.png",
                                                                          //         fit: BoxFit.cover),
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
                                                                                                    orderStock[i]["stockData"][a]["stockCode"])
                                                                                                .toList()
                                                                                                .toString() ==
                                                                                            '[]'
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
                                                                                                  MaterialPageRoute(builder: (context) => ShowImage(image: CachedNetworkImage(imageUrl: "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}"))));
                                                                                            },
                                                                                            // child:
                                                                                            //     Image.network(
                                                                                            //   "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
                                                                                            //   fit: BoxFit.cover,
                                                                                            // ),
                                                                                            child:
                                                                                                CachedNetworkImage(
                                                                                              imageUrl:
                                                                                                  "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
                                                                                            ),
                                                                                          )
                                                                                  ],
                                                                                ),
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
                                                                              const EdgeInsets.only(
                                                                                  right: 3,
                                                                                  top: 20,
                                                                                  bottom: 10,
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
                                                                                children: <Widget>[
                                                                                  Container(
                                                                                    width: MediaQuery.of(
                                                                                                context)
                                                                                            .size
                                                                                            .width -
                                                                                        100,
                                                                                    // height: 20,
                                                                                    margin: EdgeInsets
                                                                                        .only(
                                                                                            top: 5),
                                                                                    child: Text(
                                                                                      "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Padding(
                                                                                padding:
                                                                                    EdgeInsets.only(
                                                                                        top: 5),
                                                                                child: Row(
                                                                                  mainAxisAlignment:
                                                                                      MainAxisAlignment
                                                                                          .spaceBetween,
                                                                                  children: <
                                                                                      Widget>[
                                                                                    invoiceStatus ==
                                                                                            "COMPLETED" || multiDiscountCheck == true
                                                                                        ? Row(
                                                                                            children: <
                                                                                                Widget>[
                                                                                              Text(
                                                                                                  "Qty : "),
                                                                                              Text("${orderStock[i]["stockData"][a]["qty"]}".substring(
                                                                                                  0,
                                                                                                  "${orderStock[i]["stockData"][a]["qty"]}".lastIndexOf("."))),
                                                                                            ],
                                                                                          )
                                                                                        : Row(
                                                                                            crossAxisAlignment:
                                                                                                CrossAxisAlignment.center,
                                                                                            children: <
                                                                                                Widget>[
                                                                                              Container(
                                                                                                child:
                                                                                                    GestureDetector(
                                                                                                  onTap: () async {
                                                                                                    final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                                    if (orderStock[i]["stockData"][a]["qty"] == 1 || orderStock[i]["stockData"][a]["qty"] < 1) {
                                                                                                    } else {
                                                                                                      setState(() {
                                                                                                        orderStock[i]["stockData"][a]["qty"]--;

                                                                                                        orderStock[i]["stockData"][a]["totalAmount"] = orderStock[i]["stockData"][a]["qty"] * orderStock[i]["stockData"][a]["normalPrice"];

                                                                                                        orderPrice = [];
                                                                                                        for (var m = 0; m < orderStock.length; m++) {
                                                                                                          for (var n = 0; n < orderStock[m]["stockData"].length; n++) {
                                                                                                            orderPrice.add(orderStock[m]["stockData"][n]["totalAmount"]);
                                                                                                          }
                                                                                                        }

                                                                                                        var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                                          getSysKey.then((val) {

                                                                                                        

                                                                                                        if(discountCheckList.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0) {
                                                                                                          _handleSubmit(context);
                                                                                                          
                                                                                                          var param;
                                                                                                          if(discountStockListDate.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString() && element["createddate"] == orderStock[i]["stockData"][a]["appliedDate"].toString()).toList().length != 0) {
                                                                                                            param = jsonEncode(
                                                                                                              {
                                                                                                                "itemSyskey": "${orderStock[i]["stockData"][a]["stockSyskey"]}",
                                                                                                                "itemDesc": "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                                                "itemAmount": orderStock[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                                "itemTotalAmount": orderStock[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                                "itemQty": orderStock[i]["stockData"][a]["qty"].toInt(),
                                                                                                                "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                                "date": "${discountStockListDate.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                                                                                                              }
                                                                                                            );
                                                                                                          } else {
                                                                                                            datetime();
                                                                                                            param = jsonEncode(
                                                                                                              {
                                                                                                                "itemSyskey": "${orderStock[i]["stockData"][a]["stockSyskey"]}",
                                                                                                                "itemDesc": "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                                                "itemAmount": orderStock[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                                "itemTotalAmount": orderStock[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                                "itemQty": orderStock[i]["stockData"][a]["qty"].toInt(),
                                                                                                                "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                                "date": "$date"
                                                                                                              }
                                                                                                            );
                                                                                                          }

                                                                                                          getVolDisCalculation(param, orderStock[i]["stockData"], context, false).then((getVolDisCalculationValue) {
                                                                                                            if(getVolDisCalculationValue == "success") {
                                                                                                              setState(() {
                                                                                                                
                                                                                                                if(newStockList.length != 0) {
                                                                                                                  orderStock[i]["stockData"] = newStockList;
                                                                                                                }
                                                                                                                
                                                                                                                if(discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0.0" ||
                                                                                                                  discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0") {
                                                                                                                  var discountpercent = discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"];
                                                                                                                  orderStock[i]["stockData"][a]["totalAmount"] = (orderStock[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100)) * orderStock[i]["stockData"][a]["qty"];
                                                                                                                  orderStock[i]["stockData"][a]["price"] = orderStock[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100);
                                                                                                                  orderStock[i]["stockData"][a]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];
                                                                                                                }
                                                                                                                orderPrice = [];
                                                                                                                for (var i = 0; i < orderStock.length; i++) {
                                                                                                                  for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                                    orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                                  }
                                                                                                                }
                                                                                                                totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                                if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                                  totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                                }
                                                                                                                totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                                if(accountBoolean == true) {
                                                                                                                  cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                                } else {
                                                                                                                  cashAmount = totalAmount;
                                                                                                                }
                                                                                                                if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                                  cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                                } else if(totalAmount == 0.0) {
                                                                                                                  cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                                } else {
                                                                                                                  cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                                }
                                                                                                                if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                          for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                            if (stockByBrandDel[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                              for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                                if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                                  stockByBrandDel[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                                  stockByBrandDel[b]["stockData"][c]["price"] = orderStock[i]["stockData"][a]["price"];
                                                                                                                  stockByBrandDel[b]["stockData"][c]["promoDetailSyskey"] = orderStock[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                        } else {
                                                                                                          for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                            if (getdeliverylist[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                              for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                                if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                                  getdeliverylist[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                                  getdeliverylist[b]["stockData"][c]["price"] = orderStock[i]["stockData"][a]["price"];
                                                                                                                  getdeliverylist[b]["stockData"][c]["promoDetailSyskey"] = orderStock[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                        }

                                                                                                        
                                                                                                        orderPrice = [];
                                                                                                        for (var i = 0; i < orderStock.length; i++) {
                                                                                                          for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                            orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                          }
                                                                                                        }
                                                                                                        totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                        if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                          totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                        }
                                                                                                        totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                        if(accountBoolean == true) {
                                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                            if(totalAmount < 0) {
                                                                                                              //
                                                                                                            } else {
                                                                                                              cashAmount = totalAmount;
                                                                                                            }
                                                                                                          }
                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                        getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                                                                                                          if(invDisCalVal == "success") {
                                                                                                          orderPrice = [];
                                                                                                          for (var i = 0; i < orderStock.length; i++) {
                                                                                                            for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                              orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                            }
                                                                                                          }
                                                                                                          totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                          if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                            totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                          }
                                                                                                          totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                          if(accountBoolean == true) {
                                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                              cashAmount = totalAmount;
                                                                                                          }
                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                          if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                                            //
                                                                                                          } else {
                                                                                                            if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                              setState(() {
                                                                                                                invPromotionList = [];
                                                                                                              });
                                                                                                            } else {
                                                                                                              invPromotionList = [];
                                                                                                              for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                                invPromotionList.add({
                                                                                                                  "syskey" : '0',
	                                                                                                            "recordStatus": 1,
	                                                                                                            "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                              '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                            "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                            "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                                 '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                            "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                                     '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                            "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                            "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                                });
                                                                                                              }
                                                                                                            }
                                                                                                            setState(() {
                                                                                                              totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                                            });
                                                                                                          }

                                                                                                          for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                                            getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                                          }

                                                                                                          if(accountBoolean == true) {
                                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                              cashAmount = totalAmount;
                                                                                                          }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                          }
                                                                                                        });

                                                                                                                Navigator.pop(context);
                                                                                                              });
                                                                                                            }else if(getVolDisCalculationValue == "fail") {
                                                                                                              Navigator.pop(context);
                                                                                                              snackbarmethod("FAIL!");
                                                                                                            }else {
                                                                                                              Navigator.pop(context);
                                                                                                              // getVolDisCalculationDialog(param, getVolDisCalculationValue.toString(), orderStock[i]["stockData"][a]);
                                                                                                            }
                                                                                                          });
                                                                                                    
                                                                                                        }
                                                                                                        else{
                                                                                                          if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                          for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                            if (stockByBrandDel[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                              for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                                if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                                  stockByBrandDel[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                        } else {
                                                                                                          for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                            if (getdeliverylist[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                              for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                                if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                                  getdeliverylist[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                        }

                                                                                                        orderPrice = [];
                                                                                                        for (var i = 0; i < orderStock.length; i++) {
                                                                                                          for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                            orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                          }
                                                                                                        }
                                                                                                        totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                        if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                          totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                        }
                                                                                                        totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                        if(accountBoolean == true) {
                                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                              cashAmount = totalAmount;
                                                                                                          }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                        getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                                                                                                          if(invDisCalVal == "success") {
                                                                                                          orderPrice = [];
                                                                                                          for (var i = 0; i < orderStock.length; i++) {
                                                                                                            for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                              orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                            }
                                                                                                          }
                                                                                                          totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                          if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                            totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                          }
                                                                                                          totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                          if(accountBoolean == true) {
                                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                              cashAmount = totalAmount;
                                                                                                          }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                          if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                                            //
                                                                                                          } else {
                                                                                                            if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                              setState(() {
                                                                                                                invPromotionList = [];
                                                                                                              });
                                                                                                            } else {
                                                                                                              invPromotionList = [];
                                                                                                              for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                                invPromotionList.add({
                                                                                                                  "syskey" : '0',
	                                                                                                            "recordStatus": 1,
	                                                                                                            "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                              '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                            "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                            "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                                 '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                            "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                                     '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                            "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                            "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                                });
                                                                                                              }
                                                                                                            }
                                                                                                            setState(() {
                                                                                                              totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                                            });
                                                                                                          }

                                                                                                          for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                                            getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                                          }

                                                                                                          if(accountBoolean == true) {
                                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                              cashAmount = totalAmount;
                                                                                                          }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                          }
                                                                                                        });
                                                                                                        }
                                                                                                        
                                                                                                      });
                                                                                                      });
                                                                                                    }
                                                                                                  },
                                                                                                  child: Center(
                                                                                                      child: Icon(
                                                                                                    const IconData(0xe15b, fontFamily: 'MaterialIcons'),
                                                                                                    color: Colors.white,
                                                                                                    size: 19,
                                                                                                  )),
                                                                                                ),
                                                                                                decoration:
                                                                                                    BoxDecoration(
                                                                                                  color: Color(0xffe53935),
                                                                                                  borderRadius: BorderRadius.circular(3),
                                                                                                  border: Border(
                                                                                                    top: BorderSide(width: 0.5, color: Colors.white),
                                                                                                    bottom: BorderSide(width: 0.5, color: Colors.white),
                                                                                                    left: BorderSide(width: 0.5, color: Colors.white),
                                                                                                    right: BorderSide(width: 0.5, color: Colors.white),
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
                                                                                                  _showIntDialog(int.parse("${orderStock[i]["stockData"][a]["qty"]}".substring(0, orderStock[i]["stockData"][a]["qty"].toString().lastIndexOf(".")))).then((value) {
                                                                                                    setState(() {
                                                                                                      orderStock[i]["stockData"][a]["qty"] = value.toDouble();

                                                                                                      orderStock[i]["stockData"][a]["totalAmount"] = orderStock[i]["stockData"][a]["qty"] * orderStock[i]["stockData"][a]["normalPrice"];
                                                                                                    });

                                                                                                    orderPrice = [];
                                                                                                    for (var m = 0; m < orderStock.length; m++) {
                                                                                                      for (var n = 0; n < orderStock[m]["stockData"].length; n++) {
                                                                                                        orderPrice.add(orderStock[m]["stockData"][n]["totalAmount"]);
                                                                                                      }
                                                                                                    }

                                                                                                    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                                          getSysKey.then((val) {

                                                                                                    

                                                                                                    if(discountCheckList.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0) {
                                                                                                          _handleSubmit(context);
                                                                                                          
                                                                                                            var param;
                                                                                                          if(discountStockListDate.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString() && element["createddate"] == orderStock[i]["stockData"][a]["appliedDate"].toString()).toList().length != 0) {
                                                                                                            param = jsonEncode(
                                                                                                              {
                                                                                                                "itemSyskey": "${orderStock[i]["stockData"][a]["stockSyskey"]}",
                                                                                                                "itemDesc": "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                                                "itemAmount": orderStock[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                                "itemTotalAmount": orderStock[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                                "itemQty": orderStock[i]["stockData"][a]["qty"].toInt(),
                                                                                                                "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                                "date": "${discountStockListDate.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                                                                                                              }
                                                                                                            );
                                                                                                          } else {
                                                                                                            datetime();
                                                                                                            param = jsonEncode(
                                                                                                              {
                                                                                                                "itemSyskey": "${orderStock[i]["stockData"][a]["stockSyskey"]}",
                                                                                                                "itemDesc": "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                                                "itemAmount": orderStock[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                                "itemTotalAmount": orderStock[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                                "itemQty": orderStock[i]["stockData"][a]["qty"].toInt(),
                                                                                                                "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                                "date": "$date"
                                                                                                              }
                                                                                                            );
                                                                                                          }

                                                                                                          getVolDisCalculation(param, orderStock[i]["stockData"], context, false).then((getVolDisCalculationValue) {
                                                                                                            if(getVolDisCalculationValue == "success") {
                                                                                                              setState(() {
                                                                                                                if(newStockList.length != 0) {
                                                                                                                  orderStock[i]["stockData"] = newStockList;
                                                                                                                }
                                                                                                                
                                                                                                                if(discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0.0" ||
                                                                                                                  discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0") {
                                                                                                                  var discountpercent = discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"];
                                                                                                                  orderStock[i]["stockData"][a]["totalAmount"] = (orderStock[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100)) * orderStock[i]["stockData"][a]["qty"];
                                                                                                                  orderStock[i]["stockData"][a]["price"] = orderStock[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100);
                                                                                                                  orderStock[i]["stockData"][a]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];
                                                                                                                }

                                                                                                                orderPrice = [];
                                                                                                                for (var i = 0; i < orderStock.length; i++) {
                                                                                                                  for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                                    orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                                  }
                                                                                                                }
                                                                                                                totalCount = orderPrice.reduce((value, element) => value + element);

                                                                                                                if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                                  totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                                }

                                                                                                                if(accountBoolean == true) {
                                                                                                                  if(((totalCount - returnTotal) - specialAmount) - (abAccount + spAccount) < 0) {
                                                                                                                    //
                                                                                                                  } else {
                                                                                                                    cashAmount = ((totalCount - returnTotal) - specialAmount) - (abAccount + spAccount);
                                                                                                                  }
                                                                                                                } else {
                                                                                                                  if(((totalCount - returnTotal) - specialAmount) < 0) {
                                                                                                                    //
                                                                                                                  } else {
                                                                                                                    cashAmount = ((totalCount - returnTotal) - specialAmount);
                                                                                                                  }
                                                                                                                }

                                                                                                                if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                                  cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                                } else if(totalAmount == 0.0) {
                                                                                                                  cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                                } else {
                                                                                                                  cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                                }
                                                                                                                 if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                      for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                        if (stockByBrandDel[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                          for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                            if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                              stockByBrandDel[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                              stockByBrandDel[b]["stockData"][c]["price"] = orderStock[i]["stockData"][a]["price"];
                                                                                                              stockByBrandDel[b]["stockData"][c]["promoDetailSyskey"] = orderStock[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    } else {
                                                                                                      for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                        if (getdeliverylist[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                          for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                            if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                              getdeliverylist[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                              getdeliverylist[b]["stockData"][c]["price"] = orderStock[i]["stockData"][a]["price"];
                                                                                                              getdeliverylist[b]["stockData"][c]["promoDetailSyskey"] = orderStock[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    }

                                                                                                    orderPrice = [];
                                                                                                    for (var i = 0; i < orderStock.length; i++) {
                                                                                                      for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                        orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                      }
                                                                                                    }
                                                                                                    totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                    if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                      totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                    }
                                                                                                    totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                    if(accountBoolean == true) {
                                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                              cashAmount = totalAmount;
                                                                                                          }
                                                                                                    if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                    getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                                                                                                      if(invDisCalVal == "success") {
                                                                                                      setState(() {
                                                                                                        orderPrice = [];
                                                                                                        for (var i = 0; i < orderStock.length; i++) {
                                                                                                          for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                            orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                          }
                                                                                                        }
                                                                                                        totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                        if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                          totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                        }
                                                                                                      totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                      if(accountBoolean == true) {
                                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                              cashAmount = totalAmount;
                                                                                                          }
                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                      if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                                        //
                                                                                                      }else {
                                                                                                        if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                          setState(() {
                                                                                                            invPromotionList = [];
                                                                                                          });
                                                                                                        } else {
                                                                                                          invPromotionList = [];
                                                                                                          for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                            invPromotionList.add({
                                                                                                              "syskey" : '0',
	                                                                                                        "recordStatus": 1,
	                                                                                                        "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                          '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                        "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                        "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                             '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                        "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                                 '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                        "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                        "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                            });
                                                                                                          }
                                                                                                        }
                                                                                                        setState(() {
                                                                                                          totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                                        });
                                                                                                      }

                                                                                                      for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                                        getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                                      }

                                                                                                      if(accountBoolean == true) {
                                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                      } else {
                                                                                                          cashAmount = totalAmount;
                                                                                                      }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                      });
                                                                                                      }
                                                                                                    });
                                                                                                                Navigator.pop(context);
                                                                                                              });
                                                                                                            }else if(getVolDisCalculationValue == "fail") {
                                                                                                              Navigator.pop(context);
                                                                                                              snackbarmethod("FAIL!");
                                                                                                            }else {
                                                                                                              Navigator.pop(context);
                                                                                                              // getVolDisCalculationDialog(param, getVolDisCalculationValue.toString(), orderStock[i]["stockData"][a]);
                                                                                                            }
                                                                                                          });
                                                                                                        
                                                                                                    
                                                                                                        }
                                                                                                        else{
                                                                                                           if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                      for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                        if (stockByBrandDel[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                          for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                            if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                              stockByBrandDel[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    } else {
                                                                                                      for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                        if (getdeliverylist[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                          for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                            if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                              getdeliverylist[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    }

                                                                                                    orderPrice = [];
                                                                                                    for (var i = 0; i < orderStock.length; i++) {
                                                                                                      for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                        orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                      }
                                                                                                    }
                                                                                                    totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                    if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                      totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                    }
                                                                                                    totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                    if(accountBoolean == true) {
                                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                              cashAmount = totalAmount;
                                                                                                          }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                    getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                                                                                                      if(invDisCalVal == "success") {
                                                                                                      setState(() {
                                                                                                        orderPrice = [];
                                                                                                        for (var i = 0; i < orderStock.length; i++) {
                                                                                                          for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                            orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                          }
                                                                                                        }
                                                                                                        totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                        if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                          totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                        }
                                                                                                      totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                      if(accountBoolean == true) {
                                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                              cashAmount = totalAmount;
                                                                                                          }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                      if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                                        //
                                                                                                      }else {
                                                                                                        if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                          setState(() {
                                                                                                            invPromotionList = [];
                                                                                                          });
                                                                                                        } else {
                                                                                                          invPromotionList = [];
                                                                                                          for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                            invPromotionList.add({
                                                                                                              "syskey" : '0',
	                                                                                                        "recordStatus": 1,
	                                                                                                        "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                          '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                        "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                        "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                             '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                        "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                                 '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                        "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                        "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                            });
                                                                                                          }
                                                                                                        }

                                                                                                        setState(() {
                                                                                                          totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                                        });
                                                                                                      }

                                                                                                      for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                                        getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                                      }

                                                                                                      if(accountBoolean == true) {
                                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                              cashAmount = totalAmount;
                                                                                                          }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                      });
                                                                                                      }
                                                                                                    });
                                                                                                        }

                                                                                                   
                                                                                                  });
                                                                                                  });
                                                                                                },
                                                                                                child:
                                                                                                    Container(
                                                                                                  child: Center(child: Text("${orderStock[i]["stockData"][a]["qty"]}".substring(0, orderStock[i]["stockData"][a]["qty"].toString().lastIndexOf(".")))),
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
                                                                                                  onTap: () async {
                                                                                                    final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                                    if (orderStock[i]["stockData"][a]["qty"] == 99999 || orderStock[i]["stockData"][a]["qty"] > 99999) {
                                                                                                    } else {
                                                                                                      setState(() {
                                                                                                        orderStock[i]["stockData"][a]["qty"]++;

                                                                                                        orderStock[i]["stockData"][a]["totalAmount"] = orderStock[i]["stockData"][a]["qty"] * orderStock[i]["stockData"][a]["normalPrice"];

                                                                                                        orderPrice = [];
                                                                                                        for (var m = 0; m < orderStock.length; m++) {
                                                                                                          for (var n = 0; n < orderStock[m]["stockData"].length; n++) {
                                                                                                            orderPrice.add(orderStock[m]["stockData"][n]["totalAmount"]);
                                                                                                          }
                                                                                                        }

                                                                                                        var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                                          getSysKey.then((val) {

                                                                                                        

                                                                                                        if(discountCheckList.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0) {
                                                                                                          _handleSubmit(context);
                                                                                                          
                                                                                                            var param;
                                                                                                          if(discountStockListDate.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString() && element["createddate"] == orderStock[i]["stockData"][a]["appliedDate"].toString()).toList().length != 0) {
                                                                                                            param = jsonEncode(
                                                                                                              {
                                                                                                                "itemSyskey": "${orderStock[i]["stockData"][a]["stockSyskey"]}",
                                                                                                                "itemDesc": "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                                                "itemAmount": orderStock[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                                "itemTotalAmount": orderStock[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                                "itemQty": orderStock[i]["stockData"][a]["qty"].toInt(),
                                                                                                                "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                                "date": "${discountStockListDate.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["createddate"]}"
                                                                                                              }
                                                                                                            );
                                                                                                          } else {
                                                                                                            datetime();
                                                                                                            param = jsonEncode(
                                                                                                              {
                                                                                                                "itemSyskey": "${orderStock[i]["stockData"][a]["stockSyskey"]}",
                                                                                                                "itemDesc": "${orderStock[i]["stockData"][a]["stockName"]}",
                                                                                                                "itemAmount": orderStock[i]["stockData"][a]["normalPrice"].toInt(),
                                                                                                                "itemTotalAmount": orderStock[i]["stockData"][a]["totalAmount"].toInt(),
                                                                                                                "itemQty": orderStock[i]["stockData"][a]["qty"].toInt(),
                                                                                                                "shopSyskey": "${val[0]["shopsyskey"]}",
                                                                                                                "date": "$date"
                                                                                                              }
                                                                                                            );
                                                                                                          }

                                                                                                          getVolDisCalculation(param, orderStock[i]["stockData"], context, false).then((getVolDisCalculationValue) {
                                                                                                            if(getVolDisCalculationValue == "success") {
                                                                                                              // print(newStockList);
                                                                                                              setState(() {

                                                                                                                print(discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["afterDiscountTotal"]);
                                                                                                                
                                                                                                                if(newStockList.length != 0) {
                                                                                                                  orderStock[i]["stockData"] = newStockList;
                                                                                                                }
                                                                                                                if(discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0.0" ||
                                                                                                                discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"].toString() != "0") {
                                                                                                                  var discountpercent = discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountPercent"];
                                                                                                                  orderStock[i]["stockData"][a]["totalAmount"] = (orderStock[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100)) * orderStock[i]["stockData"][a]["qty"];
                                                                                                                  orderStock[i]["stockData"][a]["price"] = orderStock[i]["stockData"][a]["normalPrice"] * ((100 - discountpercent) / 100);
                                                                                                                  orderStock[i]["stockData"][a]["promoDetailSyskey"] = discountDataList.where((element) => element["itemSyskey"].toString() == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList()[0]["discountDetailSyskey"];
                                                                                                                }
                                                                                                                
                                                                                                                orderPrice = [];
                                                                                                                for (var i = 0; i < orderStock.length; i++) {
                                                                                                                  for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                                    orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                                  }
                                                                                                                }
                                                                                                                totalCount = orderPrice.reduce((value, element) => value + element);

                                                                                                                if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                                  totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                                }

                                                                                                                if(accountBoolean == true) {
                                                                                                                  if(((totalCount - returnTotal) - specialAmount) - (abAccount + spAccount) < 0) {
                                                                                                                    //
                                                                                                                  } else {
                                                                                                                    cashAmount = ((totalCount - returnTotal) - specialAmount) - (abAccount + spAccount);
                                                                                                                  }
                                                                                                                } else {
                                                                                                                  if(((totalCount - returnTotal) - specialAmount) < 0) {
                                                                                                                    //
                                                                                                                  } else {
                                                                                                                    cashAmount = ((totalCount - returnTotal) - specialAmount);
                                                                                                                  }
                                                                                                                }

                                                                                                                if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                                if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                                  for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                                    if (stockByBrandDel[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                                      for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                                        if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                                          stockByBrandDel[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                                          stockByBrandDel[b]["stockData"][c]["price"] = orderStock[i]["stockData"][a]["price"];
                                                                                                                          stockByBrandDel[b]["stockData"][c]["promoDetailSyskey"] = orderStock[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                                        }
                                                                                                                      }
                                                                                                                    }
                                                                                                                  }
                                                                                                                } else {
                                                                                                                  for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                                    if (getdeliverylist[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                                      for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                                        if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                                          getdeliverylist[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                                          getdeliverylist[b]["stockData"][c]["price"] = orderStock[i]["stockData"][a]["price"];
                                                                                                                          getdeliverylist[b]["stockData"][c]["promoDetailSyskey"] = orderStock[i]["stockData"][a]["promoDetailSyskey"];
                                                                                                                        }
                                                                                                                      }
                                                                                                                    }
                                                                                                                  }
                                                                                                                }

                                                                                                                orderPrice = [];
                                                                                                                for (var i = 0; i < orderStock.length; i++) {
                                                                                                                  for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                                    orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                                  }
                                                                                                                }
                                                                                                                totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                                if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                                  totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                                }
                                                                                                                totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                                if(accountBoolean == true) {
                                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                              cashAmount = totalAmount;
                                                                                                          }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                                getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                                                                                                                  if(invDisCalVal == "success") {
                                                                                                                  orderPrice = [];
                                                                                                                  for (var i = 0; i < orderStock.length; i++) {
                                                                                                                    for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                                      orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                                    }
                                                                                                                  }
                                                                                                                  totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                                  if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                                    totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                                  }
                                                                                                                  totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                                  if(accountBoolean == true) {
                                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                              cashAmount = totalAmount;
                                                                                                          }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                                  if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                                                    //
                                                                                                                  }else {
                                                                                                                    if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                                      setState(() {
                                                                                                                        invPromotionList = [];
                                                                                                                      });
                                                                                                                    } else {
                                                                                                                      invPromotionList = [];
                                                                                                                      for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                                        invPromotionList.add({
                                                                                                                          "syskey" : '0',
	                                                                                                                    "recordStatus": 1,
	                                                                                                                    "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                                      '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                                    "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                                    "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                                         '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                                    "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                                             '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                                    "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                                    "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                                        });
                                                                                                                      }
                                                                                                                    }
                                                                                                                    setState(() {
                                                                                                                      totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                                                    });
                                                                                                                    
                                                                                                                  }

                                                                                                                  for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                                                    getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                                                  }

                                                                                                                  if(accountBoolean == true) {
                                                                                                                    cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                                  } else {
                                                                                                                    cashAmount = totalAmount;
                                                                                                                  }

                                                                                                                  if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                                  }
                                                                                                                });
                                                                                                                Navigator.pop(context);
                                                                                                              });
                                                                                                            }else if(getVolDisCalculationValue == "fail") {
                                                                                                              Navigator.pop(context);
                                                                                                              snackbarmethod("FAIL!");
                                                                                                            }else {
                                                                                                              Navigator.pop(context);
                                                                                                              // getVolDisCalculationDialog(param, getVolDisCalculationValue.toString(), orderStock[i]["stockData"][a]);
                                                                                                            }
                                                                                                          });
                                                                                                        }
                                                                                                        
                                                                                                        else{
                                                                                                          if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                                          for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                                            if (stockByBrandDel[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                              for (var c = 0; c < stockByBrandDel[b]["stockData"].length; c++) {
                                                                                                                if (stockByBrandDel[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                                  stockByBrandDel[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                        } else {
                                                                                                          for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                                            if (getdeliverylist[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                                              for (var c = 0; c < getdeliverylist[b]["stockData"].length; c++) {
                                                                                                                if (getdeliverylist[b]["stockData"][c]["stockCode"] == orderStock[i]["stockData"][a]["stockCode"]) {
                                                                                                                  getdeliverylist[b]["stockData"][c]["qty"] = orderStock[i]["stockData"][a]["qty"];
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                        }

                                                                                                        orderPrice = [];
                                                                                                        for (var i = 0; i < orderStock.length; i++) {
                                                                                                          for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                            orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                          }
                                                                                                        }
                                                                                                        totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                        if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                      totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                    }
                                                                                                        totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                        if(accountBoolean == true) {
                                                                                                                    cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                                  } else {
                                                                                                                    cashAmount = totalAmount;
                                                                                                                  }

                                                                                                                  if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                        getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                                                                                                          if(invDisCalVal == "success") {
                                                                                                          orderPrice = [];
                                                                                                          for (var i = 0; i < orderStock.length; i++) {
                                                                                                            for (var a = 0; a < orderStock[i]["stockData"].length; a++) {
                                                                                                              orderPrice.add(orderStock[i]["stockData"][a]["totalAmount"]);
                                                                                                            }
                                                                                                          }
                                                                                                          totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                                          if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                      totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                    }
                                                                                                          totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                                          if(accountBoolean == true) {
                                                                                                                    cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                                  } else {
                                                                                                                    cashAmount = totalAmount;
                                                                                                                  }

                                                                                                                  if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                          if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                                            //
                                                                                                          }else {
                                                                                                            if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                              setState(() {
                                                                                                                invPromotionList = [];
                                                                                                              });
                                                                                                            } else {
                                                                                                              invPromotionList = [];
                                                                                                              for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                                invPromotionList.add({
                                                                                                                  "syskey" : '0',
	                                                                                                            "recordStatus": 1,
	                                                                                                            "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                              '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                            "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                            "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                                 '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                            "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                                     '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                            "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                            "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                                });
                                                                                                              }
                                                                                                            }
                                                                                                            setState(() {
                                                                                                              totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                                            });
                                                                                                          }

                                                                                                          for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                                            getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                                          }

                                                                                                          if(accountBoolean == true) {
                                                                                                                    cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                                  } else {
                                                                                                                    cashAmount = totalAmount;
                                                                                                                  }

                                                                                                                  if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                          } else if(totalAmount == 0.0) {
                                                                                                            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                          } else {
                                                                                                            cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                          }
                                                                                                          }
                                                                                                        });
                                                                                                        }
                                                                                                      });
                                                                                                      });
                                                                                                    }
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
                                                                                          Text("${orderStock[i]["stockData"][a]["normalPrice"].toInt()}" == "0" ? "${orderStock[i]["stockData"][a]["price"].toInt()}" : "${orderStock[i]["stockData"][a]["normalPrice"].toInt()}"),
                                                                                          Padding(
                                                                                            padding:
                                                                                                const EdgeInsets.only(right: 15),
                                                                                            child: Text(
                                                                                              orderStock[i]["stockData"][a]["totalAmount"].toString().substring(orderStock[i]["stockData"][a]["totalAmount"].toString().lastIndexOf("."), orderStock[i]["stockData"][a]["totalAmount"].toString().length).length > 3 ?
                                                                                              "${orderStock[i]["stockData"][a]["totalAmount"].toStringAsFixed(2)}" :
                                                                                              double.parse(orderStock[i]["stockData"][a]["totalAmount"].toString().substring(orderStock[i]["stockData"][a]["totalAmount"].toString().lastIndexOf("."), orderStock[i]["stockData"][a]["totalAmount"].toString().length)) == 0.0 ?
                                                                                                "${orderStock[i]["stockData"][a]["totalAmount"].toInt()}" :
                                                                                                "${orderStock[i]["stockData"][a]["totalAmount"]}"
                                                                                                ),
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
                                                                                              orderStock[i]["stockData"][a]["discountAmount"] == "" || orderStock[i]["stockData"][a]["discountAmount"].toString() == "0.0" || orderStock[i]["stockData"][a]["discountAmount"].toString() == "0" || orderStock[i]["stockData"][a]["discountPercent"] == "" || orderStock[i]["stockData"][a]["discountPercent"].toString() == "0.0" || orderStock[i]["stockData"][a]["discountPercent"].toString() == "0" ?
                                                                                              "" :
                                                                                              (orderStock[i]["stockData"][a]["discountPercent"].toString() == "0.0" || orderStock[i]["stockData"][a]["discountPercent"].toString() == "0") &&
                                                                                              (orderStock[i]["stockData"][a]["discountAmount"].toString() == "0.0" || orderStock[i]["stockData"][a]["discountAmount"].toString() == "0") ? "" : 
                                                                                              "${orderStock[i]["stockData"][a]["normalPrice"].toInt() * orderStock[i]["stockData"][a]["qty"].toInt()}",
                                                                                              style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12),),
                                                                                            orderStock[i]["stockData"][a]["discountAmount"] == "" || orderStock[i]["stockData"][a]["discountAmount"].toString() == "0.0" || orderStock[i]["stockData"][a]["discountAmount"].toString() == "0" || orderStock[i]["stockData"][a]["discountPercent"] == "" || orderStock[i]["stockData"][a]["discountPercent"].toString() == "0.0" || orderStock[i]["stockData"][a]["discountPercent"].toString() == "0" ?
                                                                                            Text("") :
                                                                                            Text(
                                                                                              orderStock[i]["stockData"][a]["discountPercent"].toString() != "0.0" || orderStock[i]["stockData"][a]["discountPercent"].toString() != "0" ?
                                                                                              "  -${orderStock[i]["stockData"][a]["discountPercent"]}%" :
                                                                                              orderStock[i]["stockData"][a]["discountAmount"].toString() != "0.0" || orderStock[i]["stockData"][a]["discountAmount"].toString() != "0" ?
                                                                                              "  -${orderStock[i]["stockData"][a]["discountAmount"].toInt()}" : ""
                                                                                              , style: TextStyle(color: Colors.red, fontSize: 12),),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  if(discountCheckList.where((element) => element["stockSyskey"] == orderStock[i]["stockData"][a]["stockSyskey"].toString()).toList().length != 0 ||
                                                                  listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderStock[i]["stockData"][a+1]["stockSyskey"].toString()).toList().length != 0)
                                                                  GestureDetector(
                                                                    onTap: () async {
                                                                      if(listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderStock[i]["stockData"][a+1]["stockSyskey"].toString()).toList().length != 0) {
                                                                          List detailList = [];
                                                                          List sameDetailList = [];
                                                                          String headerSyskey = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderStock[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["HeaderSyskey"];
                                                                          String ruleNumber = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderStock[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["RuleNumber"];
                                                                          String rulePriority = listtoCheckMultiDis.where((element) => element["PromoItemSyskey"] == orderStock[i]["stockData"][a+1]["stockSyskey"].toString()).toList()[0]["RulePriority"];
                                                                          for(var j = 0; j < multiDiscountStockList.length; j++) {
                                                                            if(multiDiscountStockList[j]["HeaderSyskey"] == headerSyskey) {
                                                                              // sameDetailList = multiDiscountStockList[j]["DetailList"].where((element) => element["PromoItemSyskey"] == orderStock[i]["stockData"][a+1]["stockSyskey"] && element["RuleNumber"] == ruleNumber && element["RulePriority"] == rulePriority).toList();
                                                                              sameDetailList = multiDiscountStockList[j]["DetailList"].where((element) => element["RuleNumber"] == ruleNumber && element["RulePriority"] == rulePriority).toList();
                                                                            }
                                                                          }
                                                                          detailList.add({
                                                                            "PromoItemSyskey" : orderStock[i]["stockData"][a+1]["stockSyskey"],
                                                                            "PromoItemDesc" : orderStock[i]["stockData"][a+1]["stockName"],
                                                                            "HeaderList" : [
                                                                              {
                                                                                "DetailList": sameDetailList,
                                                                                "ToDate" : multiDiscountStockList.where((element) => element["HeaderSyskey"] == headerSyskey).toList()[0]["ToDate"]
                                                                              }
                                                                            ]
                                                                          });
                                                                          print(detailList);
                                                                          Navigator.push(context, MaterialPageRoute(builder: (context) => DiscountDetail(detail: detailList, stockDetail: orderStock[i]["stockData"][a+1],)));
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
                                                  ],
                                                ),
                                              )
                                  ]),
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
                              style: TextStyle(color: Colors.black, fontSize: 17),
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
                                visible: returnStock[i]["stockData"].length == 0
                                    ? false
                                    : true,
                                child: Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        if (returnStock[i]["visible"] == false) {
                                          setState(() {
                                            returnStock[i]["visible"] = true;
                                          });
                                        } else if (returnStock[i]["visible"] ==
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
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 15),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    returnStock[i][
                                                                "brandOwnerName"] ==
                                                            null
                                                        ? ""
                                                        : returnStock[i]
                                                            ["brandOwnerName"],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white),
                                                  ),
                                                  Icon(
                                                    returnStock[i]["visible"]
                                                        ? Icons.keyboard_arrow_down
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
                                        //     returnStock[i]["stockData"].length,
                                        child: ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:
                                                returnStock[i]["stockData"].length,
                                            itemBuilder: (context, a) {
                                              return Container(
                                                // height: 100,
                                                child: Card(
                                                  elevation: 3,
                                                  child: Row(
                                                    children: <Widget>[
                                                      ConstrainedBox(
                                                        constraints: BoxConstraints(
                                                          maxWidth: 64,
                                                          maxHeight: 80,
                                                        ),
                                                        child: stockImage == [] ||
                                                                stockImage.length ==
                                                                    0
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              ShowImage(
                                                                                  image: Image.asset("assets/coca.png"))));
                                                                },
                                                                child: Image.asset(
                                                                    "assets/coca.png",
                                                                    fit: BoxFit
                                                                        .cover),
                                                              )
                                                            : Stack(
                                                                children: <Widget>[
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
                                                                                  returnStock[i]["stockData"][a]["stockCode"])
                                                                              .toList()
                                                                              .toString() ==
                                                                          '[]'
                                                                      ? GestureDetector(
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
                                                                        )
                                                                      : GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(builder: (context) => ShowImage(image: CachedNetworkImage(imageUrl: "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == returnStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}"))));
                                                                          },
                                                                          // child: Image.network(
                                                                          //   "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == returnStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
                                                                          //   fit: BoxFit.cover,
                                                                          // ),
                                                                          child:
                                                                              CachedNetworkImage(
                                                                            imageUrl:
                                                                                "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockImage.where((element) => element["stockCode"] == returnStock[i]["stockData"][a]["stockCode"]).toList()[0]["image"]}",
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
                                                              const EdgeInsets.only(
                                                                  right: 3,
                                                                  top: 10,
                                                                  bottom: 10,
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
                                                                children: <Widget>[
                                                                  Container(
                                                                    width: MediaQuery.of(
                                                                                context)
                                                                            .size
                                                                            .width -
                                                                        100,
                                                                    // height: 20,
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            top: 5),
                                                                    child: Text(
                                                                      "${returnStock[i]["stockData"][a]["stockName"]}",
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets.only(
                                                                        top: 5, bottom: 5),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: <
                                                                      Widget>[
                                                                    invoiceStatus ==
                                                                            "COMPLETED" || multiDiscountCheck == true
                                                                        ? Row(
                                                                            children: <
                                                                                Widget>[
                                                                              Text(
                                                                                  "Qty : "),
                                                                              Text("${returnStock[i]["stockData"][a]["qty"]}".substring(
                                                                                  0,
                                                                                  "${returnStock[i]["stockData"][a]["qty"]}".lastIndexOf("."))),
                                                                            ],
                                                                          )
                                                                        : Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: <
                                                                                Widget>[
                                                                              Container(
                                                                                child:
                                                                                    GestureDetector(
                                                                                  onTap: () async {
                                                                                    final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                    if (returnStock[i]["stockData"][a]["qty"] == 1 || returnStock[i]["stockData"][a]["qty"] < 1) {
                                                                                    } else {
                                                                                      setState(() {
                                                                                        returnStock[i]["stockData"][a]["qty"]--;

                                                                                        returnStock[i]["stockData"][a]["totalAmount"] = returnStock[i]["stockData"][a]["qty"] * returnStock[i]["stockData"][a]["normalPrice"];

                                                                                        returnPrice = [];
                                                                                        for (var i = 0; i < returnStock.length; i++) {
                                                                                          for (var a = 0; a < returnStock[i]["stockData"].length; a++) {
                                                                                            returnPrice.add(returnStock[i]["stockData"][a]["totalAmount"].toInt());
                                                                                          }
                                                                                        }

                                                                                        returnTotal = int.parse("${returnPrice.reduce((value, element) => value + element)}");
                                                                                        totalAmount =  totalCount - returnTotal;

                                                                                        if(accountBoolean == true) {
                                                                                                            cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                            cashAmount = totalAmount;
                                                                                                          }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }

                                                                                        var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                        getSysKey.then((val) {
                                                                                          getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                                                                                            if(invDisCalVal == "success") {
                                                                                            totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                            if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                  totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                }
                                                                                            totalAmount = (totalCount - returnTotal) - specialAmount;
                                                                                            if(accountBoolean == true) {
                                                                                                            cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                            cashAmount = totalAmount;
                                                                                                          }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                            if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                              //
                                                                                            } else {
                                                                                              if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                setState(() {
                                                                                                  invPromotionList = [];
                                                                                                });
                                                                                              } else {
                                                                                                invPromotionList = [];
                                                                                                for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                  invPromotionList.add({
                                                                                                    "syskey" : '0',
	                                                                                                  "recordStatus": 1,
	                                                                                                  "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                  "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                  "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                   '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                  "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                       '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                  "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                  "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                  });
                                                                                                }
                                                                                              }

                                                                                              setState(() {
                                                                                                totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                              });
                                                                                            }

                                                                                            for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                              getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                            }

                                                                                            if(accountBoolean == true) {
                                                                                                            cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                            cashAmount = totalAmount;
                                                                                                          }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                            }
                                                                                          });
                                                                                        });

                                                                                        if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                          for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                            if (stockByBrandDel[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                              for (var c = 0; c < stockByBrandDel[b]["stockReturnData"].length; c++) {
                                                                                                if (stockByBrandDel[b]["stockReturnData"][c]["stockCode"] == returnStock[i]["stockData"][a]["stockCode"]) {
                                                                                                  stockByBrandDel[b]["stockReturnData"][c]["qty"] = returnStock[i]["stockData"][a]["qty"];
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        } else {
                                                                                          for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                            if (getdeliverylist[b]["brandOwnerSyskey"] == orderStock[i]["brandOwnerSyskey"]) {
                                                                                              for (var c = 0; c < getdeliverylist[b]["stockReturnData"].length; c++) {
                                                                                                if (getdeliverylist[b]["stockReturnData"][c]["stockCode"] == returnStock[i]["stockData"][a]["stockCode"]) {
                                                                                                  getdeliverylist[b]["stockReturnData"][c]["qty"] = returnStock[i]["stockData"][a]["qty"];
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
                                                                                    const IconData(0xe15b, fontFamily: 'MaterialIcons'),
                                                                                    color: Colors.white,
                                                                                    size: 19,
                                                                                  )),
                                                                                ),
                                                                                decoration:
                                                                                    BoxDecoration(
                                                                                  color: Color(0xffe53935),
                                                                                  borderRadius: BorderRadius.circular(3),
                                                                                  border: Border(
                                                                                    top: BorderSide(width: 0.5, color: Colors.white),
                                                                                    bottom: BorderSide(width: 0.5, color: Colors.white),
                                                                                    left: BorderSide(width: 0.5, color: Colors.white),
                                                                                    right: BorderSide(width: 0.5, color: Colors.white),
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
                                                                                  _showIntDialog(int.parse("${returnStock[i]["stockData"][a]["qty"]}".substring(0, returnStock[i]["stockData"][a]["qty"].toString().lastIndexOf(".")))).then((value) {
                                                                                    setState(() {
                                                                                      returnStock[i]["stockData"][a]["qty"] = value.toDouble();

                                                                                      returnStock[i]["stockData"][a]["totalAmount"] = returnStock[i]["stockData"][a]["qty"] * returnStock[i]["stockData"][a]["normalPrice"];

                                                                                      returnPrice = [];
                                                                                      for (var i = 0; i < returnStock.length; i++) {
                                                                                        for (var a = 0; a < returnStock[i]["stockData"].length; a++) {
                                                                                          returnPrice.add(returnStock[i]["stockData"][a]["totalAmount"].toInt());
                                                                                        }
                                                                                      }

                                                                                      returnTotal = int.parse("${returnPrice.reduce((value, element) => value + element)}");
                                                                                      totalAmount = (totalCount - returnTotal) - specialAmount;

                                                                                      if(accountBoolean == true) {
                                                                                                            cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                            cashAmount = totalAmount;
                                                                                                          }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }

                                                                                      var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                        getSysKey.then((val) {
                                                                                          getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal - specialAmount)).toString()).then((invDisCalVal) {
                                                                                            if(invDisCalVal == "success") {
                                                                                            totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                            if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                                  totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                                }
                                                                                            totalAmount = (totalCount - returnTotal) - specialAmount;

                                                                                            if(accountBoolean == true) {
                                                                                                            cashAmount = totalAmount - (abAccount + spAccount);
                                                                                                          } else {
                                                                                                            cashAmount = totalAmount;
                                                                                                          }

                                                                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                            if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                              //
                                                                                            } else {
                                                                                              if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                setState(() {
                                                                                                  invPromotionList = [];
                                                                                                });
                                                                                              } else {
                                                                                                invPromotionList = [];
                                                                                                for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                  invPromotionList.add({
                                                                                                    "syskey" : '0',
	                                                                                                  "recordStatus": 1,
	                                                                                                  "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                  "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                  "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                   '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                  "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                       '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                  "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                  "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                  });
                                                                                                }
                                                                                              }
                                                                                              

                                                                                              setState(() {
                                                                                                totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                              });
                                                                                            }

                                                                                            for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                              getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                            }

                                                                                            if(accountBoolean == true) {
                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                            } else {
                                                                                              cashAmount = totalAmount;
                                                                                            }

                                                                                            if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                                      } else if(totalAmount == 0.0) {
                                                                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                                      } else {
                                                                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                                      }
                                                                                            }
                                                                                          });
                                                                                        });
                                                                                    });

                                                                                    if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                      for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                        if (stockByBrandDel[b]["brandOwnerSyskey"] == returnStock[i]["brandOwnerSyskey"]) {
                                                                                          for (var c = 0; c < stockByBrandDel[b]["stockReturnData"].length; c++) {
                                                                                            if (stockByBrandDel[b]["stockReturnData"][c]["stockCode"] == returnStock[i]["stockData"][a]["stockCode"]) {
                                                                                              stockByBrandDel[b]["stockReturnData"][c]["qty"] = returnStock[i]["stockData"][a]["qty"];
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    } else {
                                                                                      for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                        if (getdeliverylist[b]["brandOwnerSyskey"] == returnStock[i]["brandOwnerSyskey"]) {
                                                                                          for (var c = 0; c < getdeliverylist[b]["stockReturnData"].length; c++) {
                                                                                            if (getdeliverylist[b]["stockReturnData"][c]["stockCode"] == returnStock[i]["stockData"][a]["stockCode"]) {
                                                                                              getdeliverylist[b]["stockReturnData"][c]["qty"] = returnStock[i]["stockData"][a]["qty"];
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                  });
                                                                                },
                                                                                child:
                                                                                    Container(
                                                                                  child: Center(
                                                                                    child: Text("${returnStock[i]["stockData"][a]["qty"]}".substring(0, returnStock[i]["stockData"][a]["qty"].toString().lastIndexOf("."))),
                                                                                  ),
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
                                                                                  onTap: () async {
                                                                                    final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                    if (returnStock[i]["stockData"][a]["qty"] == 99999 || returnStock[i]["stockData"][a]["qty"] > 99999) {
                                                                                    } else {
                                                                                      setState(() {
                                                                                        returnStock[i]["stockData"][a]["qty"]++;

                                                                                        returnStock[i]["stockData"][a]["totalAmount"] = returnStock[i]["stockData"][a]["qty"] * returnStock[i]["stockData"][a]["normalPrice"];

                                                                                        returnPrice = [];
                                                                                        for (var i = 0; i < returnStock.length; i++) {
                                                                                          for (var a = 0; a < returnStock[i]["stockData"].length; a++) {
                                                                                            returnPrice.add(returnStock[i]["stockData"][a]["totalAmount"].toInt());
                                                                                          }
                                                                                        }

                                                                                        returnTotal = int.parse("${returnPrice.reduce((value, element) => value + element)}");
                                                                                        totalAmount = (totalCount - returnTotal) - specialAmount;

                                                                                        if(accountBoolean == true) {
                                                                                          cashAmount = totalAmount - (abAccount + spAccount);
                                                                                        } else {
                                                                                          cashAmount = totalAmount;
                                                                                        }

                                                                                        if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                          cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                        } else if(totalAmount == 0.0) {
                                                                                          cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                        } else {
                                                                                          cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                        }

                                                                                        var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                                        getSysKey.then((val) {
                                                                                          getInvDisCalculation(val[0]["shopsyskey"], ((orderPrice.reduce((value, element) => value + element) - returnTotal) - specialAmount).toString()).then((invDisCalVal) {
                                                                                            if(invDisCalVal == "success") {
                                                                                            totalCount = orderPrice.reduce((value, element) => value + element);
                                                                                            if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
                                                                                              totalCount = double.parse(totalCount.toStringAsFixed(2));
                                                                                            }
                                                                                            totalAmount = (totalCount - returnTotal) - specialAmount;

                                                                                            if(accountBoolean == true) {
                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                            } else {
                                                                                              cashAmount = totalAmount;
                                                                                            }

                                                                                            if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                            } else if(totalAmount == 0.0) {
                                                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                            } else {
                                                                                              cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                            }
                                                                                            if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
                                                                                              //
                                                                                            } else {
                                                                                              if(getInvDisCalculationList["GiftList"].length == 0) {
                                                                                                setState(() {
                                                                                                  invPromotionList = [];
                                                                                                });
                                                                                              } else {
                                                                                                invPromotionList = [];
                                                                                                for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
                                                                                                  invPromotionList.add({
                                                                                                    "syskey" : '0',
	                                                                                                  "recordStatus": 1,
	                                                                                                  "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                                                                                                                '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	                                                                                                  "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	                                                                                                  "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                                                                                                                   '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	                                                                                                  "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                                                                                                       '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	                                                                                                  "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	                                                                                                  "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
                                                                                                  });
                                                                                                }
                                                                                              }
                                                                                              setState(() {
                                                                                                totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
                                                                                              });
                                                                                            }

                                                                                            for (var v = 0; v < getdeliverylist.length; v++) {
                                                                                              getdeliverylist[v]["totalamount"] = totalAmount;
                                                                                            }

                                                                                            if(accountBoolean == true) {
                                                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                                                            } else {
                                                                                              cashAmount = totalAmount;
                                                                                            }

                                                                                            if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                                                            } else if(totalAmount == 0.0) {
                                                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                                                            } else {
                                                                                              cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                                                            }
                                                                                            }
                                                                                          });
                                                                                        });
                                                                                        if (getdeliverylist == [] || getdeliverylist == null || getdeliverylist.length == 0) {
                                                                                          for (var b = 0; b < stockByBrandDel.length; b++) {
                                                                                            if (stockByBrandDel[b]["brandOwnerSyskey"] == returnStock[i]["brandOwnerSyskey"]) {
                                                                                              for (var c = 0; c < stockByBrandDel[b]["stockReturnData"].length; c++) {
                                                                                                if (stockByBrandDel[b]["stockReturnData"][c]["stockCode"] == returnStock[i]["stockData"][a]["stockCode"]) {
                                                                                                  stockByBrandDel[b]["stockReturnData"][c]["qty"] = returnStock[i]["stockData"][a]["qty"];
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        } else {
                                                                                          for (var b = 0; b < getdeliverylist.length; b++) {
                                                                                            if (getdeliverylist[b]["brandOwnerSyskey"] == returnStock[i]["brandOwnerSyskey"]) {
                                                                                              for (var c = 0; c < getdeliverylist[b]["stockReturnData"].length; c++) {
                                                                                                if (getdeliverylist[b]["stockReturnData"][c]["stockCode"] == returnStock[i]["stockData"][a]["stockCode"]) {
                                                                                                  getdeliverylist[b]["stockReturnData"][c]["qty"] = returnStock[i]["stockData"][a]["qty"];
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      });
                                                                                    }
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
                                                                          Text("${returnStock[i]["stockData"][a]["normalPrice"].toInt()}" == "0" ? "${returnStock[i]["stockData"][a]["price"].toInt()}" : "${returnStock[i]["stockData"][a]["normalPrice"].toInt()}"),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(right: 15),
                                                                            child: Text(
                                                                              returnStock[i]["stockData"][a]["totalAmount"].toString().substring(returnStock[i]["stockData"][a]["totalAmount"].toString().lastIndexOf("."), returnStock[i]["stockData"][a]["totalAmount"].toString().length).length > 3 ?
                                                                              "${returnStock[i]["stockData"][a]["totalAmount"].toStringAsFixed(2)}" :
                                                                              double.parse(returnStock[i]["stockData"][a]["totalAmount"].toString().substring(returnStock[i]["stockData"][a]["totalAmount"].toString().lastIndexOf("."), returnStock[i]["stockData"][a]["totalAmount"].toString().length)) == 0.0 ?
                                                                                "${returnStock[i]["stockData"][a]["totalAmount"].toInt()}" :
                                                                                "${returnStock[i]["stockData"][a]["totalAmount"]}"
                                                                                ),
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
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                child: Container(
                                  child: Column(
                                    children: <Widget>[
                                      getRow(
                                          "Sub Total :",
                                          orderPrice.length == 0
                                              ? "0"
                                              : 
                                              orderPrice.reduce((value, element) => value + element).toString().substring(orderPrice.reduce((value, element) => value + element).toString().lastIndexOf("."), orderPrice.reduce((value, element) => value + element).toString().length).length > 3 ?
                                              "${orderPrice.reduce((value, element) => value + element).toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
                                              double.parse(orderPrice.reduce((value, element) => value + element).toString().substring(orderPrice.reduce((value, element) => value + element).toString().lastIndexOf("."), orderPrice.reduce((value, element) => value + element).toString().length)) == 0.0 ?
                                              "${orderPrice.reduce((value, element) => value + element).toInt()}".replaceAllMapped(reg, mathFunc) :
                                              "${orderPrice.reduce((value, element) => value + element)}".replaceAllMapped(reg, mathFunc)),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 5, left: 15, right: 15, top: 5),
                                        child: (Row(
                                          children: <Widget>[
                                            Text("Special Discount Amount :",
                                                style: TextStyle(fontSize: 15)),
                                            Spacer(),
                                            invoiceStatus == "COMPLETED" || multiDiscountCheck == true
                                                ? Text(
                                                    "${specialDisCtrl.text}".replaceAllMapped(reg, mathFunc),
                                                    style: TextStyle(
                                                        color: Color(0xffe53935),
                                                        fontSize: 17),
                                                  )
                                                : Container(
                                                    width: 110,
                                                    height: 20,
                                                    child: TextField(
                                                      textAlign: TextAlign.right,
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
                                                      controller: specialDisCtrl,
                                                      // inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                      cursorColor: Colors.red,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          value =
                                                              specialDisCtrl.text;

                                                          

                                                          if (value == "" ||
                                                              value == null) {
                                                            specialAmount = 0;
                                                          } else {
                                                            specialAmount =
                                                                double.parse(value);
                                                          }
                                                        });
                                                      },
                                                      onSubmitted: (value) {
                                                        if(value == "" || value == null) {
                                                          specialAmount = 0;
                                                        } else {
                                                          specialAmount = double.parse(value);
                                                        }

                                                        if(specialAmount.toString().substring(specialAmount.toString().lastIndexOf("."), specialAmount.toString().length).length > 3) {
                                                          specialAmount = double.parse(specialAmount.toStringAsFixed(2));
                                                        }

                                                        

                                                        totalAmount = (totalCount - returnTotal) - specialAmount;
                                                        if(accountBoolean == true) {
                                                          if(abAccBoolean == true && spAccBoolean == true) {
                                                            cashAmount = totalAmount - (abAccount + spAccount);
                                                          } else if(abAccBoolean == true && spAccBoolean == false) {
                                                            cashAmount = totalAmount - abAccount;
                                                          } else if(abAccBoolean == false && spAccBoolean == true) {
                                                            cashAmount = totalAmount - spAccount;
                                                          } else {
                                                            cashAmount = totalAmount;
                                                          }
                                                        } else {
                                                          cashAmount = totalAmount;
                                                        }

                                                        if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                          cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                        } else if(totalAmount == 0.0) {
                                                          cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                        } else {
                                                          cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                        }

                                                        invCalculation();
                                                      },
                                                    ),
                                                  )
                                          ],
                                        )),
                                      ),
                                      getRow(
                                          "Expired Amount :",
                                          "$returnTotal"
                                              .replaceAllMapped(reg, mathFunc)),
                                      getRow(
                                        getInvDisCalculationList.toString() != "" && getInvDisCalculationList.toString() != "null" ?
                                        
                                      getInvDisCalculationList["DiscountAmount"].toString() == "0" && getInvDisCalculationList["DiscountPercent"].toString() == "0" ?
                                      "Total Amount :" :
                                          "Total Amount (${getInvDisCalculationList["DiscountPercent"]}%) :" : "Total Amount :",
                                          totalAmount.toString().substring(totalAmount.toString().lastIndexOf("."), totalAmount.toString().length).length > 3 ?
                                          "${totalAmount.toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
                                          double.parse(totalAmount.toString().substring(totalAmount.toString().lastIndexOf("."), totalAmount.toString().length)) == 0.0 ?
                                          "${totalAmount.toInt()}".replaceAllMapped(reg, mathFunc) :
                                          "$totalAmount".replaceAllMapped(reg, mathFunc)),
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
                                      Visibility(
                                        visible: invoiceStatus == "COMPLETED" ? false : accountGetBalanceList.length == 0 ? false : true,
                                        child: Row(
                                          children: <Widget>[
                                            Theme(
                                              data: ThemeData(
                                                primarySwatch: Colors.blue,
                                                unselectedWidgetColor: Colors.red, // Your color
                                              ),
                                              child: Checkbox(
                                                value: accountBoolean,
                                                activeColor: Colors.red,
                                                onChanged: (newValue) { 
                                                 setState(() {
                                                    accountBoolean = newValue;
                                                    if(originalAbAccount.toString().substring(originalAbAccount.toString().lastIndexOf("."), originalAbAccount.toString().length).length > 3) {
                                                      abAccountCtrl = TextEditingController(text: "${originalAbAccount.toStringAsFixed(2)}");
                                                    } else if(double.parse(originalAbAccount.toString().substring(originalAbAccount.toString().lastIndexOf("."), originalAbAccount.toString().length)) == 0.0) {
                                                      abAccountCtrl = TextEditingController(text: "${originalAbAccount.toInt()}");
                                                    } else {
                                                      abAccountCtrl = TextEditingController(text: "$originalAbAccount");
                                                    }

                                                    if(originalSpAccount.toString().substring(originalSpAccount.toString().lastIndexOf("."), originalSpAccount.toString().length).length > 3) {
                                                      spAccountCtrl = TextEditingController(text: "${originalSpAccount.toStringAsFixed(2)}");
                                                    } else if(double.parse(originalSpAccount.toString().substring(originalSpAccount.toString().lastIndexOf("."), originalSpAccount.toString().length)) == 0.0) {
                                                      spAccountCtrl = TextEditingController(text: "${spAccount.toInt()}");
                                                    } else {
                                                      spAccountCtrl = TextEditingController(text: "$originalSpAccount");
                                                    }
                                                    abAccount = originalAbAccount;
                                                    spAccount = originalSpAccount;
                                                    if(accountBoolean == true) {
                                                      //
                                                    } else {
                                                      abAccBoolean = false;
                                                      spAccBoolean = false;
                                                      abAmtCheck = true;
                                                      spAmtCheck = true;
                                                      cashAmount = totalAmount;

                                                      if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                      } else if(totalAmount == 0.0) {
                                                        cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                      } else {
                                                        cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                      }
                                                    }
                                                 });
                                                },
                                              ),
                                            ),
                                            Text("Use Account", style: TextStyle(color: Colors.red))
                                          ],
                                        ),
                                      ),
                                      if(accountGetBalanceList.length != 0)
                                      if(accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == "0").toList().length != 0)
                                      Visibility(
                                        visible: invoiceStatus == "COMPLETED" ? true : accountBoolean,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 5, left: 15, right: 15, top: invoiceStatus == "COMPLETED" ? 15 : 5),
                                          child: Row(
                                            children: <Widget>[
                                              // ab account
                                              if(invoiceStatus != "COMPLETED")
                                              SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: Theme(
                                                  data: ThemeData(
                                                    primarySwatch: Colors.blue,
                                                    unselectedWidgetColor: Colors.red, // Your color
                                                  ),
                                                  child: Checkbox(
                                                    value: abAccBoolean,
                                                    activeColor: Colors.red,
                                                    onChanged: (newValue) {
                                                     setState(() {
                                                        abAccBoolean = newValue;
                                                        // abAccountCtrl = TextEditingController(text: "$originalAbAccount");
                                                        // abAccount = originalAbAccount;
                                                        if(abAccBoolean == true) {
                                                          if(cashAmount == 0) {
                                                            abAmtCheck = false;
                                                          }else {
                                                            abAmtCheck = true;
                                                            if(spAccBoolean == true) {
                                                              cashAmount = totalAmount - originalSpAccount;
                                                            } else {
                                                              cashAmount = totalAmount;
                                                            }

                                                            if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                            } else if(totalAmount == 0.0) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                            } else {
                                                              cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                            }
                                                            if(cashAmount < originalAbAccount) {
                                                              abAccount = cashAmount;
                                                              if(abAccount.toString().substring(abAccount.toString().lastIndexOf("."), abAccount.toString().length).length > 3) {
                                                                abAccountCtrl = TextEditingController(text: "${abAccount.toStringAsFixed(2)}");
                                                              } else if(double.parse(abAccount.toString().substring(abAccount.toString().lastIndexOf("."), abAccount.toString().length)) == 0.0) {
                                                                abAccountCtrl = TextEditingController(text: "${abAccount.toInt()}");
                                                              } else {
                                                                abAccountCtrl = TextEditingController(text: "$abAccount");
                                                              }

                                                              cashAmount = 0;
                                                            } else {
                                                              if(spAccBoolean == true) {
                                                                cashAmount = totalAmount - (originalAbAccount + originalSpAccount);
                                                              } else {
                                                                cashAmount = totalAmount - originalAbAccount;
                                                              }
                                                            }

                                                            if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                            } else if(totalAmount == 0.0) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                            } else {
                                                              cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                            }
                                                          }
                                                        } else {
                                                          if(abAmtCheck == false) {
                                                            //
                                                          } else {
                                                            if(spAccBoolean == true) {
                                                              cashAmount = totalAmount - originalAbAccount;
                                                            } else {
                                                              cashAmount = totalAmount;
                                                            }

                                                            if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                            } else if(totalAmount == 0.0) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                            } else {
                                                              cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                            }
                                                            abAccount = originalAbAccount;
                                                            if(abAccount.toString().substring(abAccount.toString().lastIndexOf("."), abAccount.toString().length).length > 3) {
                                                              abAccountCtrl = TextEditingController(text: "${abAccount.toStringAsFixed(2)}");
                                                            } else if(double.parse(abAccount.toString().substring(abAccount.toString().lastIndexOf("."), abAccount.toString().length)) == 0.0) {
                                                              abAccountCtrl = TextEditingController(text: "${abAccount.toInt()}");
                                                            } else {
                                                              abAccountCtrl = TextEditingController(text: "$abAccount");
                                                            }
                                                          }
                                                        }
                                                     });
                                                    },
                                                  ),
                                                ),
                                              ),
                                              if(invoiceStatus != "COMPLETED")
                                              SizedBox(width: 5),
                                              Text(accountGetBalanceList.length == 0 || getdeliverylist.length == 0 ? "" : "${accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == "0").toList()[0]["brandOwnerName"]} :",
                                                  style: TextStyle(fontSize: 15)),
                                              Spacer(),
                                              invoiceStatus == "COMPLETED"
                                                  ? Text(
                                                      "${abAccountCtrl.text}".replaceAllMapped(reg, mathFunc),
                                                      style: TextStyle(
                                                          color: Color(0xffe53935),
                                                          fontSize: 17),
                                                    )
                                                  : Container(
                                                      width: 110,
                                                      height: 20,
                                                      child: TextField(
                                                        textAlign: TextAlign.right,
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
                                                        controller: abAccountCtrl,
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                        cursorColor: Colors.red,
                                                        // inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                                        keyboardType:
                                                            TextInputType.number,
                                                        onSubmitted: (value) {

                                                          value = abAccountCtrl.text;

                                                          // if(int.parse(value) < 0) {
                                                          //   value = value.replaceAll("-", "");
                                                          //   abAccountCtrl.text = value.replaceAll("-", "");
                                                          // }

                                                          if(double.parse(abAccountCtrl.text) > originalAbAccount) {
                                                            Fluttertoast.showToast(
                                                              msg: "Insufficient amount",
                                                              toastLength: Toast.LENGTH_SHORT,
                                                              gravity: ToastGravity.CENTER,
                                                              timeInSecForIos: 1,
                                                              backgroundColor: Colors.red,
                                                              textColor: Colors.white,
                                                              fontSize: 16.0);
                                                            if(abAccount.toString().substring(abAccount.toString().lastIndexOf("."), abAccount.toString().length).length > 3) {
                                                              abAccountCtrl = TextEditingController(text: "${abAccount.toStringAsFixed(2)}");
                                                            } else if(double.parse(abAccount.toString().substring(abAccount.toString().lastIndexOf("."), abAccount.toString().length)) == 0.0) {
                                                              abAccountCtrl = TextEditingController(text: "${abAccount.toInt()}");
                                                            } else {
                                                              abAccountCtrl = TextEditingController(text: "$abAccount");
                                                            }
                                                          } else {
                                                            abAccount = double.parse(value);
                                                          }

                                                          if(accountBoolean == true) {
                                                            if(spAccBoolean == true) {
                                                              cashAmount = totalAmount - (abAccount + spAccount);
                                                            } else {
                                                              cashAmount = totalAmount - abAccount;
                                                            }
                                                          } else {
                                                            cashAmount = totalAmount;
                                                          }

                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                            } else if(totalAmount == 0.0) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                            } else {
                                                              cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                            }
                                                        },
                                                      ),
                                                    )
                                            ],
                                          ),
                                        ),
                                      ),
                                      if(accountGetBalanceList.length != 0)
                                      Visibility(
                                        visible: invoiceStatus == "COMPLETED" ? true : accountBoolean,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 5, left: 15, right: 15, top: 5),
                                          child: (Row(
                                            children: <Widget>[
                                              // sp account
                                              if(invoiceStatus != "COMPLETED")
                                              SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: Theme(
                                                  data: ThemeData(
                                                    primarySwatch: Colors.blue,
                                                    unselectedWidgetColor: Colors.red, // Your color
                                                  ),
                                                  child: Checkbox(
                                                    value: spAccBoolean,
                                                    activeColor: Colors.red,
                                                    onChanged: (newValue) {
                                                     setState(() {
                                                        spAccBoolean = newValue;
                                                        // spAccountCtrl = TextEditingController(text: "$originalSpAccount");
                                                        // spAccount = originalSpAccount;
                                                        if(spAccBoolean == true) {
                                                          if(cashAmount == 0) {
                                                            spAmtCheck = false;
                                                          }else {
                                                            spAmtCheck = true;
                                                            if(abAccBoolean == true) {
                                                              cashAmount = totalAmount - originalAbAccount;
                                                            } else {
                                                              cashAmount = totalAmount;
                                                            }

                                                            if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                            } else if(totalAmount == 0.0) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                            } else {
                                                              cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                            }
                                                            if(cashAmount < originalSpAccount) {
                                                              spAccount = cashAmount;
                                                              if(spAccount.toString().substring(spAccount.toString().lastIndexOf("."), spAccount.toString().length).length > 3) {
                                                                spAccountCtrl = TextEditingController(text: "${spAccount.toStringAsFixed(2)}");
                                                              } else if(double.parse(spAccount.toString().substring(spAccount.toString().lastIndexOf("."), spAccount.toString().length)) == 0.0) {
                                                                spAccountCtrl = TextEditingController(text: "${spAccount.toInt()}");
                                                              } else {
                                                                spAccountCtrl = TextEditingController(text: "$spAccount");
                                                              }
                                                              cashAmount = 0;
                                                            } else {
                                                              if(abAccBoolean == true) {
                                                                cashAmount = totalAmount - (originalAbAccount + originalSpAccount);
                                                              } else {
                                                                cashAmount = totalAmount - originalSpAccount;
                                                              }
                                                            }

                                                            if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                            } else if(totalAmount == 0.0) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                            } else {
                                                              cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                            }
                                                          }
                                                        } else {
                                                          if(spAmtCheck == false) {
                                                            //
                                                          } else {
                                                            if(abAccBoolean == true) {
                                                              cashAmount = totalAmount - originalSpAccount;
                                                            } else {
                                                              cashAmount = totalAmount;
                                                            }

                                                            if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                            } else if(totalAmount == 0.0) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                            } else {
                                                              cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                            }
                                                            spAccount = originalSpAccount;

                                                            if(spAccount.toString().substring(spAccount.toString().lastIndexOf("."), spAccount.toString().length).length > 3) {
                                                              spAccountCtrl = TextEditingController(text: "${spAccount.toStringAsFixed(2)}");
                                                            } else if(double.parse(spAccount.toString().substring(spAccount.toString().lastIndexOf("."), spAccount.toString().length)) == 0.0) {
                                                              spAccountCtrl = TextEditingController(text: "${spAccount.toInt()}");
                                                            } else {
                                                              spAccountCtrl = TextEditingController(text: "$spAccount");
                                                            }
                                                          }
                                                        }
                                                     });
                                                    },
                                                  ),
                                                ),
                                              ),
                                              if(invoiceStatus != "COMPLETED")
                                              SizedBox(width: 5),
                                              Text(accountGetBalanceList.length == 0 || getdeliverylist.length == 0 ? "SP Account :" : accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == getdeliverylist[0]["brandOwnerSyskey"].toString()).toList().length == 0 ? "" : "${accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == getdeliverylist[0]["brandOwnerSyskey"].toString()).toList()[0]["brandOwnerName"]} :",
                                                  style: TextStyle(fontSize: 15)),
                                              Spacer(),
                                              invoiceStatus == "COMPLETED" || spAccBoolean == false
                                                  ? Text(
                                                      "${spAccountCtrl.text}".replaceAllMapped(reg, mathFunc),
                                                      style: TextStyle(
                                                          color: Color(0xffe53935),
                                                          fontSize: 17),
                                                    )
                                                  : Container(
                                                      width: 110,
                                                      height: 20,
                                                      child: TextField(
                                                        textAlign: TextAlign.right,
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
                                                        controller: spAccountCtrl,
                                                        // inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                        cursorColor: Colors.red,
                                                        keyboardType:
                                                            TextInputType.number,
                                                        onSubmitted: (value) {

                                                          value = spAccountCtrl.text;

                                                          // if(int.parse(value) < 0) {
                                                          //   value = value.replaceAll("-", "");
                                                          //   spAccountCtrl.text = value.replaceAll("-", "");
                                                          // }
                                                          if(double.parse(spAccountCtrl.text) > originalSpAccount) {
                                                            Fluttertoast.showToast(
                                                              msg: "Insufficient amount",
                                                              toastLength: Toast.LENGTH_SHORT,
                                                              gravity: ToastGravity.CENTER,
                                                              timeInSecForIos: 1,
                                                              backgroundColor: Colors.red,
                                                              textColor: Colors.white,
                                                              fontSize: 16.0);

                                                            if(spAccount.toString().substring(spAccount.toString().lastIndexOf("."), spAccount.toString().length).length > 3) {
                                                              spAccountCtrl = TextEditingController(text: "${spAccount.toStringAsFixed(2)}");
                                                            } else if(double.parse(spAccount.toString().substring(spAccount.toString().lastIndexOf("."), spAccount.toString().length)) == 0.0) {
                                                              spAccountCtrl = TextEditingController(text: "${spAccount.toInt()}");
                                                            } else {
                                                              spAccountCtrl = TextEditingController(text: "$spAccount");
                                                            }
                                                          } else {
                                                            spAccount = double.parse(value);
                                                          }

                                                          if(accountBoolean == true) {
                                                            if(abAccBoolean == true) {
                                                                cashAmount = totalAmount - (abAccount + spAccount);
                                                              } else {
                                                                cashAmount = totalAmount - spAccount;
                                                              }
                                                          } else {
                                                            cashAmount = totalAmount;
                                                          }

                                                          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
                                                            } else if(totalAmount == 0.0) {
                                                              cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
                                                            } else {
                                                              cashAmtCtrl = TextEditingController(text: "$cashAmount");
                                                            }
                                                        },
                                                      ),
                                                    )
                                            ],
                                          )),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 5, left: 15, right: 15, top: accountGetBalanceList.length == 0 ? 15 : 5),
                                        child: (Row(
                                          children: <Widget>[
                                            Text("Cash Amount :",
                                                style: TextStyle(fontSize: 15)),
                                            Spacer(),
                                            invoiceStatus == "COMPLETED"
                                                ? 
                                                Text(
                                                  cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3 ?
                                                    "${cashAmount.toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) : 
                                                  double.parse(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length)) == 0.0 ?
                                                    "${cashAmount.toInt()}".replaceAllMapped(reg, mathFunc) : 
                                                    "$cashAmount".replaceAllMapped(reg, mathFunc),
                                                    style: TextStyle(
                                                        color: Color(0xffe53935),
                                                        fontSize: 17),
                                                  )
                                                : Container(
                                                    width: 110,
                                                    height: 20,
                                                    child: TextField(
                                                      textAlign: TextAlign.right,
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
                                                      controller: cashAmtCtrl,
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                      cursorColor: Colors.red,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      enabled: cashAmount < 0 ? false : true, 
                                                      onChanged: (value) {
                                                        value = cashAmtCtrl.text;
                                                        if(cashAmtCtrl.text == "" || cashAmtCtrl.text == null) {
                                                          cashAmount = 0;
                                                        } else {
                                                          cashAmount = double.parse(cashAmtCtrl.text);
                                                        }
                                                      },
                                                      onSubmitted: (value) {
                                                        // if(int.parse(value) < 0) {
                                                        //   value = value.replaceAll("-", "");
                                                        //   cashAmtCtrl.text = value.replaceAll("-", "");
                                                        //   cashAmount = int.parse(cashAmtCtrl.text);
                                                        // }

                                                        if(cashAmtCtrl.text.toString().substring(cashAmtCtrl.text.toString().lastIndexOf("."), cashAmtCtrl.text.toString().length).length > 3) {
                                                          cashAmtCtrl.text = double.parse(cashAmtCtrl.text).toStringAsFixed(2);
                                                        }else if(double.parse(cashAmtCtrl.text.toString().substring(cashAmtCtrl.text.toString().lastIndexOf("."), cashAmtCtrl.text.toString().length)) == 0.0) {
                                                          cashAmtCtrl.text = int.parse(cashAmtCtrl.text).toString();
                                                        }
                                                        
                                                        if(totalAmount - double.parse(value) < 0) {
                                                            if(accountBoolean == true) {
                                                              cashAmount = double.parse(value);
                                                              cashAmtCtrl.text = "$value";
                                                            } else {
                                                              cashAmount = totalAmount;
                                                              cashAmtCtrl.text = "$totalAmount";
                                                            }
                                                          }else {
                                                            cashAmount = double.parse(cashAmtCtrl.text);
                                                          }
                                                      },
                                                    ),
                                                  )
                                          ],
                                        )),
                                      ),
                                      invoiceStatus == "COMPLETED" ?
                                      getRow(
                                          "Credit Amount :",
                                          creditAmount < 0 ?
                                          "0" :
                                          "$creditAmount"
                                              .replaceAllMapped(reg, mathFunc))
                                      : 
                                      getRow(
                                          "Credit Amount :",
                                          accountBoolean == false ?
                                          (totalAmount - cashAmount).toString().substring((totalAmount - cashAmount).toString().lastIndexOf("."), (totalAmount - cashAmount).toString().length).length > 3 ?
                                          "${(totalAmount - cashAmount).toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
                                          (totalAmount - cashAmount) == 0.0 ? 
                                          "${(totalAmount - cashAmount).toInt()}".replaceAllMapped(reg, mathFunc) :
                                          "${(totalAmount - cashAmount)}".replaceAllMapped(reg, mathFunc) :

                                          abAccBoolean == true && spAccBoolean == true ?
                                          (totalAmount - (abAccount + spAccount +  cashAmount)).toString().substring((totalAmount - (abAccount + spAccount +  cashAmount)).toString().lastIndexOf("."), (totalAmount - (abAccount + spAccount +  cashAmount)).toString().length).length > 3 ?
                                          "${(totalAmount - (abAccount + spAccount +  cashAmount)).toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
                                          (totalAmount - (abAccount + spAccount +  cashAmount)) == 0.0 ? 
                                          "${(totalAmount - (abAccount + spAccount +  cashAmount)).toInt()}".replaceAllMapped(reg, mathFunc) :
                                          "${totalAmount - (abAccount + spAccount +  cashAmount)}"
                                              .replaceAllMapped(reg, mathFunc) :
                                          
                                          abAccBoolean == false && spAccBoolean == true ?
                                          (totalAmount - (spAccount +  cashAmount)).toString().substring((totalAmount - (spAccount +  cashAmount)).toString().lastIndexOf("."), (totalAmount - (spAccount +  cashAmount)).toString().length).length > 3 ?
                                          "${(totalAmount - (spAccount +  cashAmount)).toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
                                          (totalAmount - (spAccount +  cashAmount)) == 0.0 ? 
                                          "${(totalAmount - (spAccount +  cashAmount)).toInt()}".replaceAllMapped(reg, mathFunc) :
                                          "${totalAmount - (spAccount +  cashAmount)}"
                                              .replaceAllMapped(reg, mathFunc) :

                                          spAccBoolean == false && abAccBoolean == true ?
                                          (totalAmount - (abAccount +  cashAmount)).toString().substring((totalAmount - (abAccount +  cashAmount)).toString().lastIndexOf("."), (totalAmount - (abAccount +  cashAmount)).toString().length).length > 3 ?
                                          "${(totalAmount - (abAccount +  cashAmount)).toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
                                          (totalAmount - (abAccount +  cashAmount)) == 0.0 ? 
                                          "${(totalAmount - (abAccount +  cashAmount)).toInt()}".replaceAllMapped(reg, mathFunc) :
                                          "${totalAmount - (abAccount +  cashAmount)}"
                                              .replaceAllMapped(reg, mathFunc) :
                                          
                                          (totalAmount - cashAmount).toString().substring((totalAmount - cashAmount).toString().lastIndexOf("."), (totalAmount - cashAmount).toString().length).length > 3 ?
                                          "${(totalAmount - cashAmount).toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
                                          (totalAmount - cashAmount) == 0.0 ? 
                                          "${(totalAmount - cashAmount).toInt()}".replaceAllMapped(reg, mathFunc) :
                                          "${(totalAmount - cashAmount)}".replaceAllMapped(reg, mathFunc)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: invoiceStatus == "COMPLETED" ? false : true,
                            child: Padding(
                              padding:
                                  EdgeInsets.only(left: 5, right: 5, bottom: 15),
                              child: GestureDetector(
                                onTap: invoiceStatus == "COMPLETED"
                                    ? null
                                    : () {
                                        multiDisCalculation();
                                      },
                                child: Card(
                                  color: invoiceStatus == "COMPLETED"
                                      ? Colors.grey
                                      : Color(0xffef5350),
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
                              ),
                            ),
                          ),
                          Visibility(
                            visible: invoiceStatus != "COMPLETED" ? true : false,
                            child: Padding(
                              padding:
                                  EdgeInsets.only(left: 5, right: 5, bottom: 15),
                              child: GestureDetector(
                                onTap: invoiceStatus == "COMPLETED"
                                    ? null
                                    : () {
                                        ontapInvoice();
                                      },
                                child: Card(
                                  color: invoiceStatus == "COMPLETED"
                                      ? Colors.grey
                                      : Color(0xffef5350),
                                  child: Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    child: Center(
                                        child: Text(
                                      // invoiceComplete == "SUCCESS" ||
                                      //         invoiceStatus == "COMPLETED"
                                      //     ? "Update"
                                      //     : "Confirm",
                                      "Confirm",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ) ,
                          Visibility(
                            visible: invoiceStatus == "COMPLETED" ? true : false,
                            child: Padding(
                              padding:
                                  EdgeInsets.only(left: 5, right: 5, bottom: 15),
                              child: GestureDetector(
                                  onTap: () {
                                    ontapVoid();
                                  },
                                  child: Card(
                                    color: Color(0xffef5350),
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width,
                                      child: Center(
                                          child: Text(
                                        "Void",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  )),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5, right: 5, bottom: 15),
                            child: GestureDetector(
                              onTap: 
                              invoiceStatus == "COMPLETED"
                                  ? 
                                  () async {
                                    final SharedPreferences preferences = await SharedPreferences.getInstance();
                                    if(preferences.getString("PrintType") == "Java") {
                                      javafilePrinter();
                                    } else if(preferences.getString("PrintType") == "Thermal") {
                                      blueThermalPrinter();
                                    } else {
                                      snackbarmethod("Please select printer!");
                                    }
                                  }
                                  : null
                                  ,
                              child: Card(
                                color: invoiceStatus == "COMPLETED"
                                    ? Color(0xffef5350)
                                    : Colors.grey,
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
                          Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
                            child: GestureDetector(
                              onTap: () {
                                _showCashReceivedDialog();
                              },
                              child: Card(
                                color: Color(0xffef5350),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text("Additional Cash :", style: TextStyle(color: Colors.white, fontSize: 15),),
                                        Text("$cashReceived", style: TextStyle(color: Colors.white, fontSize: 15),)
                                      ],
                                    )
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5, right: 5, bottom: 15),
                            child: GestureDetector(
                              onTap: invoiceStatus == "COMPLETED" &&
                                      merchandizingStatus == "COMPLETED"
                                  ? () async {
                                      ontapTransactionComplete();
                                    }
                                  : null,
                              child: Card(
                                color: invoiceStatus == "COMPLETED" &&
                                        merchandizingStatus == "COMPLETED"
                                    ? Color(0xffef5350)
                                    : Colors.grey,
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                      child: Text(
                                    "Transaction Complete",
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
                      )
                    ],
                  ),
                )
              ],
            ),
            Visibility(
              visible: invDisDownloadList.length == 0 ? false : true,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => InvoiceDiscount()));
                    },
                    child: Image.asset("assets/discount.png", width: 35,))),
              ),
            )
          ],
        ),
      ),
      backgroundColor: Colors.blueGrey[50],
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

    String creditAmount = '0';
    String totalAmountPercent = '';
    List accountList = [];
    List totalCashList = [];

    if(accountBoolean == true) {
      if(accountGetBalanceList.length != 0) {
        if(accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == "0").toList().length != 0) {
          
          accountList.add({
            "AccountName" : '${accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == "0").toList()[0]["brandOwnerName"]}',
            "AccountValue" : "$abAccount".replaceAllMapped(reg, mathFunc)
          });

        }

        if(accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == getdeliverylist[0]["brandOwnerSyskey"].toString()).toList().length != 0) {
                                            
          accountList.add({
            "AccountName" : '${accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == getdeliverylist[0]["brandOwnerSyskey"].toString()).toList()[0]["brandOwnerName"]}',
            "AccountValue" : "$spAccount".replaceAllMapped(reg, mathFunc)
          });

        }
      }
    }

    if(totalAmount.toString().substring(totalAmount.toString().lastIndexOf("."), totalAmount.toString().length).length > 3) {
      totalAmount = double.parse(totalAmount.toStringAsFixed(2));
    }

    if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
      cashAmount = double.parse(cashAmount.toStringAsFixed(2));
    }

    if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
      totalCount = double.parse(totalCount.toStringAsFixed(2));
    }

    if(accountBoolean == true) {
      if(totalAmount - (abAccount + spAccount + cashAmount) < 0) {
        creditAmount = '0';
      } else {
        creditAmount = '${totalAmount - (abAccount + spAccount + cashAmount)}';
      }
    } else {
      if(totalAmount - cashAmount < 0) {
        creditAmount = '0';
      } else {
        creditAmount = '${totalAmount - cashAmount}';
      }
    }

    if(getInvDisCalculationList.toString() != "" && getInvDisCalculationList.toString() != "null") {
      if(getInvDisCalculationList["DiscountAmount"].toString() == "0" && getInvDisCalculationList["DiscountPercent"].toString() == "0") {
        totalAmountPercent = '';
      } else {
        totalAmountPercent = "(${getInvDisCalculationList["DiscountPercent"]}%)";
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
        "Sub_Total": "$totalCount".replaceAllMapped(reg, mathFunc),
        "Special_Discount_Amount": "$specialAmount".replaceAllMapped(reg, mathFunc),
        "Expired_Amount": "$returnTotal".replaceAllMapped(reg, mathFunc),
        "AccountList" : accountList,
        "Cash_Amount":"$cashAmount".replaceAllMapped(reg, mathFunc),
        "Credit_Amount":"$creditAmount".replaceAllMapped(reg, mathFunc),
        "Total_Amount": "$totalAmount".replaceAllMapped(reg, mathFunc),
        "Total_Amount_Percent" : '$totalAmountPercent'.replaceAllMapped(reg, mathFunc),
        "Additional_Cash": totalCashList,
        "Street":"${preferences.getString("address")}"
      }
    ];

    print(header);

    List detail = [];

    for (var a = 0; a < getdeliverylist.length; a++) {
      for (var b = 0; b < getdeliverylist[a]["stockData"].length; b++) {

        String printerDis = "${getdeliverylist[a]["stockData"][b]["discountPercent"]}";

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
          "stkDesc": "${getdeliverylist[a]["stockData"][b]["stockName"]}$printerDis",
          "totalqty": "${getdeliverylist[a]["stockData"][b]["qty"].toInt()}",
          
          "standardPrice": getdeliverylist[a]["stockData"][b]["normalPrice"].toString().substring(getdeliverylist[a]["stockData"][b]["normalPrice"].toString().lastIndexOf("."), getdeliverylist[a]["stockData"][b]["normalPrice"].toString().length).length > 3 ?
            "${getdeliverylist[a]["stockData"][b]["normalPrice"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
            double.parse(getdeliverylist[a]["stockData"][b]["normalPrice"].toString().substring(getdeliverylist[a]["stockData"][b]["normalPrice"].toString().lastIndexOf("."), getdeliverylist[a]["stockData"][b]["normalPrice"].toString().length)) == 0.0 ?
            "${getdeliverylist[a]["stockData"][b]["normalPrice"].toInt()}".replaceAllMapped(reg, mathFunc) :
            "${getdeliverylist[a]["stockData"][b]["normalPrice"]}".replaceAllMapped(reg, mathFunc),
          
          "sellingPrice": getdeliverylist[a]["stockData"][b]["price"].toString().substring(getdeliverylist[a]["stockData"][b]["price"].toString().lastIndexOf("."), getdeliverylist[a]["stockData"][b]["price"].toString().length).length > 3 ?
            "${getdeliverylist[a]["stockData"][b]["price"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
            double.parse(getdeliverylist[a]["stockData"][b]["price"].toString().substring(getdeliverylist[a]["stockData"][b]["price"].toString().lastIndexOf("."), getdeliverylist[a]["stockData"][b]["price"].toString().length)) == 0.0 ?
            "${getdeliverylist[a]["stockData"][b]["price"].toInt()}".replaceAllMapped(reg, mathFunc) :
            "${getdeliverylist[a]["stockData"][b]["price"]}".replaceAllMapped(reg, mathFunc),
          
          "totalAmount": getdeliverylist[a]["stockData"][b]["totalAmount"].toString().substring(getdeliverylist[a]["stockData"][b]["totalAmount"].toString().lastIndexOf("."), getdeliverylist[a]["stockData"][b]["totalAmount"].toString().length).length > 3 ?
            "${getdeliverylist[a]["stockData"][b]["totalAmount"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
            double.parse(getdeliverylist[a]["stockData"][b]["totalAmount"].toString().substring(getdeliverylist[a]["stockData"][b]["totalAmount"].toString().lastIndexOf("."), getdeliverylist[a]["stockData"][b]["totalAmount"].toString().length)) == 0.0 ?
            "${getdeliverylist[a]["stockData"][b]["totalAmount"].toInt()}".replaceAllMapped(reg, mathFunc) :
            "${getdeliverylist[a]["stockData"][b]["totalAmount"]}".replaceAllMapped(reg, mathFunc)
        });

        if(getdeliverylist[a]["stockData"][b]["promotionStockList"].length != 0) {
          for(var c = 0; c < getdeliverylist[a]["stockData"][b]["promotionStockList"].length; c++) {
            detail.add({
              "stkDesc": "${getdeliverylist[a]["stockData"][b]["promotionStockList"][c]["stockName"]}",
              "totalqty": "${getdeliverylist[a]["stockData"][b]["promotionStockList"][c]["qty"].toInt()}",
              "standardPrice": "0",
              "sellingPrice":"0",
              "totalAmount": "0"
            });
          }
        }
      }

      for (var b = 0; b < getdeliverylist[a]["stockReturnData"].length; b++) {

        String printerDis = "${getdeliverylist[a]["stockReturnData"][b]["discountPercent"]}";

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
          "stkDesc": "${getdeliverylist[a]["stockReturnData"][b]["stockName"]}$printerDis",
          "totalqty": "-${getdeliverylist[a]["stockReturnData"][b]["qty"].toInt()}",
          
          "standardPrice": getdeliverylist[a]["stockReturnData"][b]["normalPrice"].toString().substring(getdeliverylist[a]["stockReturnData"][b]["normalPrice"].toString().lastIndexOf("."), getdeliverylist[a]["stockReturnData"][b]["normalPrice"].toString().length).length > 3 ?
            "-${getdeliverylist[a]["stockReturnData"][b]["normalPrice"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
            double.parse(getdeliverylist[a]["stockReturnData"][b]["normalPrice"].toString().substring(getdeliverylist[a]["stockReturnData"][b]["normalPrice"].toString().lastIndexOf("."), getdeliverylist[a]["stockReturnData"][b]["normalPrice"].toString().length)) == 0.0 ?
            "-${getdeliverylist[a]["stockReturnData"][b]["normalPrice"].toInt()}".replaceAllMapped(reg, mathFunc) :
            "-${getdeliverylist[a]["stockReturnData"][b]["normalPrice"]}".replaceAllMapped(reg, mathFunc),
          
          "sellingPrice": getdeliverylist[a]["stockReturnData"][b]["price"].toString().substring(getdeliverylist[a]["stockReturnData"][b]["price"].toString().lastIndexOf("."), getdeliverylist[a]["stockReturnData"][b]["price"].toString().length).length > 3 ?
            "-${getdeliverylist[a]["stockReturnData"][b]["price"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
            double.parse(getdeliverylist[a]["stockReturnData"][b]["price"].toString().substring(getdeliverylist[a]["stockReturnData"][b]["price"].toString().lastIndexOf("."), getdeliverylist[a]["stockReturnData"][b]["price"].toString().length)) == 0.0 ?
            "-${getdeliverylist[a]["stockReturnData"][b]["price"].toInt()}".replaceAllMapped(reg, mathFunc) :
            "-${getdeliverylist[a]["stockReturnData"][b]["price"]}".replaceAllMapped(reg, mathFunc),

          "totalAmount": getdeliverylist[a]["stockReturnData"][b]["totalAmount"].toString().substring(getdeliverylist[a]["stockReturnData"][b]["totalAmount"].toString().lastIndexOf("."), getdeliverylist[a]["stockReturnData"][b]["totalAmount"].toString().length).length > 3 ?
            "-${getdeliverylist[a]["stockReturnData"][b]["totalAmount"].toStringAsFixed(2)}".replaceAllMapped(reg, mathFunc) :
            double.parse(getdeliverylist[a]["stockReturnData"][b]["totalAmount"].toString().substring(getdeliverylist[a]["stockReturnData"][b]["totalAmount"].toString().lastIndexOf("."), getdeliverylist[a]["stockReturnData"][b]["totalAmount"].toString().length)) == 0.0 ?
            "-${getdeliverylist[a]["stockReturnData"][b]["totalAmount"].toInt()}".replaceAllMapped(reg, mathFunc) :
            "-${getdeliverylist[a]["stockReturnData"][b]["totalAmount"]}".replaceAllMapped(reg, mathFunc)
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

    print("invoice detail 0------------- + $invDetail");

    String bName = "${getdeliverylist[0]["brandOwnerName"]}";
    var stringname = preferences.getString("printerName");
    if(stringname == "" || stringname == null) {
      // Navigator.pop(context);
      snackbarmethod("Please select printer!");
    } else {
      print("testing ------");
      // Navigator.pop(context);
      print(detail);
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

    String printerBrandOwnerName = '${getdeliverylist[0]["brandOwnerName"]}';
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

    for (var a = 0; a < getdeliverylist.length; a++) {
      for (var b = 0; b < getdeliverylist[a]["stockData"].length; b++) {
        String printerDis = "${getdeliverylist[a]["stockData"][b]["discountPercent"]}";
        print(printerDis);
        if(printerDis == "0.0") {
          // printerDis = "0";
          printerDis = "";
        } else {
          if(printerDis.substring(printerDis.lastIndexOf("."), printerDis.length).length > 3) {
            printerDis = double.parse(printerDis).toStringAsFixed(2);
          } else if(double.parse(printerDis.substring(printerDis.lastIndexOf("."), printerDis.length)).toString() == "0.0") {
            printerDis = double.parse(printerDis).toInt().toString();
          }

          printerDis = "@$printerDis%";
        }

        String printerSku = getdeliverylist[a]["stockData"][b]["stockName"] + printerDis;
        String printerPrice = "${getdeliverylist[a]["stockData"][b]["price"]}";
        if(printerPrice.substring(printerPrice.lastIndexOf("."), printerPrice.length).length > 3) {
          printerPrice = double.parse(printerPrice).toStringAsFixed(2);
        } else if(double.parse(printerPrice.substring(printerPrice.lastIndexOf("."), printerPrice.length)).toString() == "0.0") {
          printerPrice = double.parse(printerPrice).toInt().toString();
        }

        String printerNormalPrice = "${getdeliverylist[a]["stockData"][b]["normalPrice"]}";
        if(printerNormalPrice.substring(printerNormalPrice.lastIndexOf("."), printerNormalPrice.length).length > 3) {
          printerNormalPrice = double.parse(printerNormalPrice).toStringAsFixed(2);
        } else if(double.parse(printerNormalPrice.substring(printerNormalPrice.lastIndexOf("."), printerNormalPrice.length)).toString() == "0.0") {
          printerNormalPrice = double.parse(printerNormalPrice).toInt().toString();
        }

        String printerQty = "${getdeliverylist[a]["stockData"][b]["qty"].toInt()}";
        String printerAmt = "${getdeliverylist[a]["stockData"][b]["totalAmount"]}";
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

        if(getdeliverylist[a]["stockData"][b]["promotionStockList"].length != 0) {
          for(var c = 0; c < getdeliverylist[a]["stockData"][b]["promotionStockList"].length; c++) {
            String printerPromoSku = "${getdeliverylist[a]["stockData"][b]["promotionStockList"][c]["stockName"]}";
            String printerPromoQty = "${getdeliverylist[a]["stockData"][b]["promotionStockList"][c]["qty"].toInt()}";
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

      for (var b = 0; b < getdeliverylist[a]["stockReturnData"].length; b++) {
        String printerSku = getdeliverylist[a]["stockReturnData"][b]["stockName"];
        String printerPrice = "-${getdeliverylist[a]["stockReturnData"][b]["price"]}";
        if(printerPrice.substring(printerPrice.lastIndexOf("."), printerPrice.length).length > 3) {
          printerPrice = double.parse(printerPrice).toStringAsFixed(2);
        } else if(double.parse(printerPrice.substring(printerPrice.lastIndexOf("."), printerPrice.length)).toString() == "0.0") {
          printerPrice = double.parse(printerPrice).toInt().toString();
        }

        String printerNormalPrice = "-${getdeliverylist[a]["stockReturnData"][b]["normalPrice"]}";
        if(printerNormalPrice.substring(printerNormalPrice.lastIndexOf("."), printerNormalPrice.length).length > 3) {
          printerNormalPrice = double.parse(printerNormalPrice).toStringAsFixed(2);
        } else if(double.parse(printerNormalPrice.substring(printerNormalPrice.lastIndexOf("."), printerNormalPrice.length)).toString() == "0.0") {
          printerNormalPrice = double.parse(printerNormalPrice).toInt().toString();
        }
        String printerDis = "${getdeliverylist[a]["stockReturnData"][b]["discountPercent"]}";
        if(printerDis == "0.0") {
          printerDis = "0";
        }
        String printerQty = "-${getdeliverylist[a]["stockReturnData"][b]["qty"].toInt()}";
        String printerAmt = "-${getdeliverylist[a]["stockReturnData"][b]["totalAmount"]}";
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

    if(getdeliverylist[0]["orderTotalAmount"].toString().substring(getdeliverylist[0]["orderTotalAmount"].toString().lastIndexOf("."), getdeliverylist[0]["orderTotalAmount"].toString().length).length > 3) {
      printOrderTotalAmt = "${getdeliverylist[0]["orderTotalAmount"].toStringAsFixed(2)}";
    }else if(double.parse(getdeliverylist[0]["orderTotalAmount"].toString().substring(getdeliverylist[0]["orderTotalAmount"].toString().lastIndexOf("."), getdeliverylist[0]["orderTotalAmount"].toString().length)) == 0.0) {
      printOrderTotalAmt = "${getdeliverylist[0]["orderTotalAmount"].toInt()}";
    } else {
      printOrderTotalAmt = "${getdeliverylist[0]["orderTotalAmount"]}";
    }

    String printerSubTotal = "Sub Total${space * (55 - printOrderTotalAmt.length)}$printOrderTotalAmt";

    print(printerSubTotal);

    String printerSpecialDisAmt = "Special Discount Amount${space * (41- specialAmount.toString().length)}$specialAmount";

    print(printerSpecialDisAmt);

    String printerReturnTotalAmt = "0";

    if(getdeliverylist[0]["returnTotalAmount"].toString().substring(getdeliverylist[0]["returnTotalAmount"].toString().lastIndexOf("."), getdeliverylist[0]["returnTotalAmount"].toString().length).length > 3) {
      printerReturnTotalAmt = "${getdeliverylist[0]["returnTotalAmount"].toStringAsFixed(2)}";
    }else if(double.parse(getdeliverylist[0]["returnTotalAmount"].toString().substring(getdeliverylist[0]["returnTotalAmount"].toString().lastIndexOf("."), getdeliverylist[0]["returnTotalAmount"].toString().length)) == 0.0) {
      printerReturnTotalAmt = "${getdeliverylist[0]["returnTotalAmount"].toInt()}";
    } else {
      printerReturnTotalAmt = "${getdeliverylist[0]["returnTotalAmount"]}";
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

      if(accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == getdeliverylist[0]["brandOwnerSyskey"].toString()).toList().length != 0) {
                                            
        accountName = '${accountGetBalanceList.where((element) => element["brandOwnerSyskey"].toString() == getdeliverylist[0]["brandOwnerSyskey"].toString()).toList()[0]["brandOwnerName"]}';
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

    if(getdeliverylist[0]["cashamount"].toString().substring(getdeliverylist[0]["cashamount"].toString().lastIndexOf("."), getdeliverylist[0]["cashamount"].toString().length).length > 3) {
      printCashAmt = "${getdeliverylist[0]["cashamount"].toStringAsFixed(2)}";
    }else if(double.parse(getdeliverylist[0]["cashamount"].toString().substring(getdeliverylist[0]["cashamount"].toString().lastIndexOf("."), getdeliverylist[0]["cashamount"].toString().length)) == 0.0) {
      printCashAmt = "${getdeliverylist[0]["cashamount"].toInt()}";
    } else {
      printCashAmt = "${getdeliverylist[0]["cashamount"]}";
    }

    String printerCashAmt = "Cash Amount${space * (53 - printCashAmt.length)}$printCashAmt";

    print(printerCashAmt);

    String printCreditAmt = "0";

    if(getdeliverylist[0]["creditAmount"].toString().substring(getdeliverylist[0]["creditAmount"].toString().lastIndexOf("."), getdeliverylist[0]["creditAmount"].toString().length).length > 3) {
      printCreditAmt = "${getdeliverylist[0]["creditAmount"].toStringAsFixed(2)}";
    } else if(double.parse(getdeliverylist[0]["creditAmount"].toString().substring(getdeliverylist[0]["creditAmount"].toString().lastIndexOf("."), getdeliverylist[0]["creditAmount"].toString().length)) == 0.0) {
      printCreditAmt = "${getdeliverylist[0]["creditAmount"].toInt()}";
    } else {
      printCreditAmt = "${getdeliverylist[0]["creditAmount"]}";
    }

    String printerCreditAmt = "Credit Amount${space * (51 - printCreditAmt.length)}$printCreditAmt";

    print(printerCreditAmt);

    String totalAmountPercent = "";

    if(getInvDisCalculationList.toString() != "" && getInvDisCalculationList.toString() != "null") {
      if(getInvDisCalculationList["DiscountAmount"].toString() == "0" && getInvDisCalculationList["DiscountPercent"].toString() == "0") {
        totalAmountPercent = '';
      } else {
        totalAmountPercent = "(${getdeliverylist[0]["orderDiscountPercent"].toInt()}%)";
      }
    }

    String printTotalAmt = "";

    printTotalAmt = "${getdeliverylist[0]["totalamount"] - specialDiscountAmt}";
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
      // Navigator.pop(context);
      snackbarmethod("Please select printer!");
    } else {
      // Navigator.pop(context);
      tesPrint(printerBrandOwnerName, printerStoreName, printerStoreID, printerTel, printerPreseller, printerUserName, printerInvNo, printerPrintDate, printerInvDate, stockDetailList, invPromoDetail, printerSubTotal, printerSpecialDisAmt, printerExpAmt, accountDetail, printerCashAmt, printerCreditAmt, printerTotalAmt, printerAdditionalCash);
    }
  }

  Future _startScanDevices() async {
    printerManager.scanResults.listen((devices) {
      setState(() {
        _devices = devices;
      });
    });

    printerManager.startScan(Duration(seconds: 2));

    Future.delayed(Duration(seconds: 2), () {
      getList();
    });
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
      List itemInfoList = [];
      List multiListforCheck = [];

      if(listtoCheckMultiDis.length == 0) {
        setState(() {
          multiDiscountCheck = true;
          Navigator.pop(context);
        });
      } else {
      if(listtoCheckMultiDis.length != 0)
      for(var i = 0; i < orderStock.length; i++) {
        for(var a = 0; a < orderStock[i]["stockData"].length; a++) {
          var check = false;
          for(var b = 0; b < listtoCheckMultiDis.length; b++) {
            if(orderStock[i]["stockData"][a]["stockSyskey"] == listtoCheckMultiDis[b]["PromoItemSyskey"]) {
              check = true;
            }
          }

          if(check == true) {
            allMultiList.add(orderStock[i]["stockData"][a]);
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
          multiDiscountCheck = true;
          Navigator.pop(context);
        });
      } else {
        for(var a = 0; a < multiListforCheck.length; a++) {
          for(var b = 0; b < multiListforCheck[a]["StockList"].length; b++) {
            for(var c = 0; c < allMultiList.length; c++) {
              if(itemInfoList.where((element) => element["itemSyskey"] == multiListforCheck[a]["StockList"][b].toString()).toList().length == 0) {
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

                    multiDiscountCalculation(param, orderStock[0]["stockData"], context).then((value) {
                      if(value == "success") {
                        if(a == multiListforCheck.length-1) {
                          Navigator.pop(context);
                        }
                        setState(() {
                          for(var j = 0; j < orderStock.length; j++) {
                            if(orderStock[j]["brandOwnerSyskey"] == newStockList[0]["brandOwnerSyskey"]) {
                              orderStock[j]["stockData"] = newStockList;
                            }
                          }
                          multiDiscountCheck = true;
                        });
                      } else if(value == "fail") {
                        if(a == multiListforCheck.length-1) {
                          Navigator.pop(context);
                        }
                        snackbarmethod("FAIL!");
                      } else {
                        if(a == multiListforCheck.length-1) {
                          Navigator.pop(context);
                        }
                        // multiDisCalculateDialog("$value");
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

  Future<void> invCalculation() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
    getSysKey.then((val) {
      getInvDisCalculation(val[0]["shopsyskey"], totalAmount.toString()).then((invDisCalVal) {
        if(invDisCalVal == "success") {
        totalCount = orderPrice.reduce((value, element) => value + element);
        if(totalCount.toString().substring(totalCount.toString().lastIndexOf("."), totalCount.toString().length).length > 3) {
          totalCount = double.parse(totalCount.toStringAsFixed(2));
        }
        totalAmount = (totalCount - returnTotal) - specialAmount;

        if(accountBoolean == true) {
          if(abAccBoolean == true && spAccBoolean == true) {
            cashAmount = totalAmount - (abAccount + spAccount);
          } else if(abAccBoolean == true && spAccBoolean == false) {
            cashAmount = totalAmount - abAccount;
          } else if(abAccBoolean == false && spAccBoolean == true) {
            cashAmount = totalAmount - spAccount;
          } else {
            cashAmount = totalAmount;
          }
        } else {
          cashAmount = totalAmount;
        }

        if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
          cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
        } else if(totalAmount == 0.0) {
          cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
        } else {
          cashAmtCtrl = TextEditingController(text: "$cashAmount");
        }
        if(getInvDisCalculationList.toString() == "null" || getInvDisCalculationList.toString() == "") {
          //
        } else {
          if(getInvDisCalculationList["GiftList"].length == 0) {
            setState(() {
              invPromotionList = [];
            });
          } else {
            invPromotionList = [];
            for(var v = 0; v < getInvDisCalculationList["GiftList"].length; v++) {
              invPromotionList.add({
                "syskey" : '0',
	              "recordStatus": 1,
	              "stockCode": getInvDisCalculationList["GiftList"][v]["discountStockCode"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockCode"] == null ? "0" : 
                            '${getInvDisCalculationList["GiftList"][v]["discountStockCode"]}',
	              "stockName": '${getInvDisCalculationList["GiftList"][v]["GiftDesc"]}',
	              "stockSyskey": getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["discountStockSyskey"] == null ? "0" :
                               '${getInvDisCalculationList["GiftList"][v]["discountStockSyskey"]}',
	              "promoStockSyskey": getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == "" || getInvDisCalculationList["GiftList"][v]["GiftSyskey"] == null ? "0" :
                                   '${getInvDisCalculationList["GiftList"][v]["GiftSyskey"]}',
	              "qty": double.parse(getInvDisCalculationList["GiftList"][v]["GiftQty"].toString()),
	              "promoStockType": '${getInvDisCalculationList["GiftList"][v]["discountItemType"]}'
              });
            }
          }
          setState(() {
            totalAmount = double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
          });

          for (var v = 0; v < getdeliverylist.length; v++) {
            getdeliverylist[v]["totalamount"] = totalAmount;
          }

          if(accountBoolean == true) {
            if(abAccBoolean == true && spAccBoolean == true) {
              cashAmount = totalAmount- (abAccount + spAccount);
            } else if(abAccBoolean == true && spAccBoolean == false) {
              cashAmount = totalAmount- abAccount;
            } else if(abAccBoolean == false && spAccBoolean == true) {
              cashAmount = totalAmount- spAccount;
            } else {
              cashAmount = totalAmount;
            }
          } else {
            setState(() {
              cashAmount = totalAmount;
            });
          }

          if(cashAmount.toString().substring(cashAmount.toString().lastIndexOf("."), cashAmount.toString().length).length > 3) {
            cashAmtCtrl = TextEditingController(text: "${cashAmount.toStringAsFixed(2)}");
          } else if(totalAmount == 0.0) {
            cashAmtCtrl = TextEditingController(text: "${cashAmount.toInt()}");
          } else {
            cashAmtCtrl = TextEditingController(text: "$cashAmount");
          }
        }
        }
      });
    });
  }

  _showCashReceivedDialog() async {
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
                  labelText: "Additional Cash",
                  labelStyle: TextStyle(color: Colors.red),
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
                keyboardType:
                    TextInputType.number,
                controller: cashReceivedCtrl,
                onChanged: (value) {
                  value = cashReceivedCtrl.text;
                  // cashReceived = int.parse(value);
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
                if(cashReceivedCtrl.text == "" || cashReceivedCtrl.text == null) {
                  cashReceivedCtrl.text = "0";
                }
                Navigator.pop(context);
                final SharedPreferences preferences = await SharedPreferences.getInstance();

                var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                _handleSubmit(context);
                getSysKey.then((val) {
                  cashAmountSave(val[0]["shopsyskey"], double.parse(cashReceivedCtrl.text)).then((cashAmtSaveVal) {
                    if(cashAmtSaveVal == "success") {
                      accountTodayCashReceived(val[0]["shopsyskey"]).then((cashReceivedVal) {
                        if(cashReceivedVal == "success") {
                          Navigator.pop(context);
                          setState(() {
                            cashReceived = cashReceivedAmt.toInt();
                          });
                        } else if(cashReceivedVal == "fail") {
                          Navigator.pop(context);
                          snackbarmethod("FAIL!");
                        } else {
                          Navigator.pop(context);
                          snackbarmethod("$cashReceivedVal");
                        }
                      });
                    } else if(cashAmtSaveVal == "fail") {
                      Navigator.pop(context);
                      snackbarmethod("FAIL!");
                    } else {
                      Navigator.pop(context);
                      snackbarmethod("$cashAmtSaveVal");
                    }
                  });
                });
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

  Future<void> ontapVoid() async {
    _handleSubmit(context);

    voidDelivery().then((voidDeliveryValue) {
      if (voidDeliveryValue == "success") {
        voidSetTaskToServer();
      } else if (voidDeliveryValue == "fail") {
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
        snackbarmethod("$voidDeliveryValue");
      } else {
        setState(() {
          loading = false;
        });
        voidDialog(voidDeliveryValue.toString());
      }
    });

  }

  Future<void> voidSetTaskToServer() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    setTask(merchandizingStatus, "COMPLETED", "PENDING").then((setTaskValue1) {
      if (setTaskValue1 == "success") {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return NavigationBar(orgId, widget.mcdCheck, widget.userType,
              preferences.getString("DateTime"));
        }));
      } else if (setTaskValue1 == "fail") {
        voidDeliveryFailSettask(setTaskValue1);
      } else {
        voidDeliveryFailInOtherReasonSetTask(setTaskValue1);
      }
    });
  }

  void voidDeliveryFailSettask(voidDeliveryValue) {
    setTask(merchandizingStatus, "COMPLETED", "COMPLETED")
        .then((setTaskValue2) {
      if (setTaskValue2 == "success") {
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
        snackbarmethod("$voidDeliveryValue");
      } else {
        setState(() {
          loading = false;
        });
        voidDeliveryFailSettaskDialog(
            voidDeliveryValue, setTaskValue2.toString());
      }
    });
  }

  void voidDeliveryFailInOtherReasonSetTask(voidDeliveryValue) {
    setTask(merchandizingStatus, "COMPLETED", "COMPLETED")
        .then((setTaskValue3) {
      if (setTaskValue3 == "success") {
        setState(() {
          loading = false;
        });
        snackbarmethod("$voidDeliveryValue");
        voidDeliveryToServerDialog(voidDeliveryValue.toString());
      } else if (setTaskValue3 == "fail") {
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
        snackbarmethod("FAIL!");
      } else {
        setState(() {
          loading = false;
        });
        voidDeliveryFailInOtherReasonSetTaskDialog(
            voidDeliveryValue, setTaskValue3.toString());
      }
    });
  }

  Future<void> voidDeliveryFailSettaskDialog(
      voidDeliveryValue, String title) async {
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
                  voidDeliveryFailSettask(voidDeliveryValue);
                },
              ),
              SizedBox(
                width: 50,
              ),
              FlatButton(
                child:
                    Text('Cancel', style: TextStyle(color: Color(0xffe53935))),
                onPressed: () {
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

  Future<void> voidDeliveryFailInOtherReasonSetTaskDialog(
      voidDeliveryValue, String title) async {
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
                  voidDeliveryFailInOtherReasonSetTask(voidDeliveryValue);
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

  Future<void> voidDeliveryToServerDialog(String title) async {
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
                  ontapVoid();
                  // voidDeliveryToServer();
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

  Future<void> voidDialog(String title) async {
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
                  ontapVoid();
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

  Future<void> ontapInvoice() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      var getSysKey =
          helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));

      _handleSubmit(context);

      for (var v = 0; v < getdeliverylist.length; v++) {
        getdeliverylist[v]["totalamount"] = totalAmount;
        getdeliverylist[v]["discountamount"] = specialAmount.toDouble();
        getdeliverylist[v]["returnTotalAmount"] = returnTotal.toDouble();
        getdeliverylist[v]["returnDiscountPercent"] = 0.0;
        getdeliverylist[v]["orderTotalAmount"] = totalCount;
        if(getInvDisCalculationList.toString() != "" && getInvDisCalculationList.toString() != "null") {
          if(getInvDisCalculationList["AfterDiscountTotal"].toString() == "0" || getInvDisCalculationList["AfterDiscountTotal"].toString() == "0.0") {
            getdeliverylist[v]["orderDiscountAmount"] = 0.0;
            getdeliverylist[v]["orderDiscountPercent"] = 0.0;
          }else {
            getdeliverylist[v]["orderDiscountAmount"] = double.parse(getInvDisCalculationList["BeforeDiscountTotal"]) - double.parse(getInvDisCalculationList["AfterDiscountTotal"]);
            getdeliverylist[v]["orderDiscountPercent"] = double.parse(getInvDisCalculationList["DiscountPercent"]);
          }
        } else {
          getdeliverylist[v]["orderDiscountAmount"] = 0.0;
          getdeliverylist[v]["orderDiscountPercent"] = 0.0;
        }

        getdeliverylist[v]["returnDiscountAmount"] = 0.0;
        if(accountBoolean == true) {
          if(spAccBoolean == true) {
            getdeliverylist[v]["payment1"] = spAccount.toDouble();
          }
          if(abAccBoolean == true) {
            getdeliverylist[v]["payment2"] = abAccount.toDouble();
          }
          if(spAccBoolean == true && abAccBoolean == true) {
            getdeliverylist[v]["creditAmount"] = totalAmount - (abAccount.toDouble() + spAccount.toDouble() +  cashAmount);
          } else if(spAccBoolean == false && abAccBoolean == false) {
            getdeliverylist[v]["creditAmount"] = totalAmount - cashAmount;
          } else if(spAccBoolean == false) {
            getdeliverylist[v]["creditAmount"] = totalAmount - (abAccount.toDouble() +  cashAmount);
          } else if(abAccBoolean == false) {
            getdeliverylist[v]["creditAmount"] = totalAmount - (spAccount.toDouble() +  cashAmount);
          }

        } else {
          getdeliverylist[v]["payment1"] = 0.0;
          getdeliverylist[v]["payment2"] = 0.0;
          if((totalAmount - cashAmount) < 0) {
            getdeliverylist[v]["creditAmount"] = 0.0;
          } else {
            getdeliverylist[v]["creditAmount"] = totalAmount - cashAmount;
          }

        }
        
        getdeliverylist[v]["cashamount"] = double.parse(cashAmtCtrl.text);;


        // print(getdeliverylist[v]["totalamount"]);

        // if(getdeliverylist[v]["promotionList"].length != 0 && getInvDisCalculationList.toString() != "null" && getInvDisCalculationList.toString() != "") {
          // getdeliverylist[v]["promotionList"] = [];
        // } else {
          if(getInvDisCalculationList.toString() != "null" && getInvDisCalculationList.toString() != "") {
            if(getInvDisCalculationList["GiftList"].length == 0) {
              getdeliverylist[v]["promotionList"] = [];
            } else {
              getdeliverylist[v]["promotionList"] = invPromotionList;
            }
          }
        // }

        print(getdeliverylist[v]);
        for(var w = 0; w < getdeliverylist[v]["stockData"].length; w++) {
          print("StockList ==> ${getdeliverylist[v]["stockData"][w]}");
          print("StockList ==> ${getdeliverylist[v]["stockData"][w]["promotionStockList"]}");
        }

        for(var w = 0; w < getdeliverylist[v]["stockReturnData"].length; w++) {
          print("StockReturnList ==> ${getdeliverylist[v]["stockReturnData"][w]}");
        }
        print("PromotionList ==> ${getdeliverylist[v]["promotionList"]}");

        if(v == getdeliverylist.length-1) {
          getSysKey.then((val) {
            updateSaleOrderFunction(totalAmount, val);
          });
        }

      }

    } else {
      snackbarmethod("Check your connection!");
    }
  }

  void updateSaleOrderFunction(invoiceTotalamt, val) {
    updateSaleOrder(invoiceTotalamt, val[0]["shopcode"], cashAmount, specialAmount)
            .then((updateSaleOrderValue) async {
          if (updateSaleOrderValue == 'success') {
            invoiceToServer(val[0]["shopcode"], val[0]["shopname"],
                invoiceTotalamt, specialAmount, val[0]["shopsyskey"]);
          } else if (updateSaleOrderValue == "fail") {
            setState(() {
              loading = false;
            });
            snackbarmethod("FAIL!");
          } else {
            setState(() {
              loading = false;
            });
            invoiceDialog(updateSaleOrderValue.toString());
          }
        });
  }

  void updateSaleOrderfailSetTask(updateSaleOrderValue) {
    setTask(merchandizingStatus, "COMPLETED", "PENDING").then((setTaskValue4) {
      if (setTaskValue4 == "success") {
        Navigator.pop(context);
        snackbarmethod("$updateSaleOrderValue");
      } else if (setTaskValue4 == "fail") {
        Navigator.pop(context);
        snackbarmethod("$setTaskValue4");
      } else {
        Navigator.pop(context);
        updateSaleOrderfailSetTaskDialog(
            updateSaleOrderValue, setTaskValue4.toString());
      }
    });
  }

  Future<void> updateSaleOrderfailSetTaskDialog(
      updateSaleOrderValue, String title) async {
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
                  updateSaleOrderfailSetTask(updateSaleOrderValue);
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

  void updateSaleOrderfailInOtherReasonsetTask(updateSaleOrderValue) {
    setTask(merchandizingStatus, "COMPLETED", "PENDING").then((setTaskValue5) {
      if (setTaskValue5 == "success") {
        Navigator.pop(context);
        invoiceDialog(updateSaleOrderValue.toString());
      } else if (setTaskValue5 == "fail") {
        Navigator.pop(context);
        snackbarmethod("$setTaskValue5");
      } else {
        updateSaleOrderfailInOtherReasonsetTaskDialog(
            updateSaleOrderValue, setTaskValue5.toString());
      }
    });
  }

  Future<void> updateSaleOrderfailInOtherReasonsetTaskDialog(
      updateSaleOrderValue, String title) async {
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
                  updateSaleOrderfailInOtherReasonsetTask(updateSaleOrderValue);
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

  Future<void> invoiceToServer(
      shopCode, shopName, invoiceTotalamt, specialAmount, shopSyskey) async {
    inVoice(shopCode, shopName, invoiceTotalamt, specialAmount, cashAmount)
        .then((invoiceValue) async {
      if (invoiceValue == "success") {
        invoiceSetTask();
      } else if (invoiceValue == "fail") {
        setState(() {
          loading = false;
        });
        snackbarmethod("FAIL!");
      } else {
        setState(() {
          loading = false;
        });
        invoiceDialog(invoiceValue.toString());
      }
    });
  }

  void invoiceFailinOtherReason(
      invoiceValue, shopCode, shopName, invoiceTotalamt, specialAmount, shopSyskey) {
    setTask(merchandizingStatus, "COMPLETED", "PENDING").then((setTask3) {
      if (setTask3 == "success") {
        Navigator.pop(context);
        invoiceToServerDialog(
            shopCode, shopName, invoiceTotalamt, specialAmount, invoiceValue, shopSyskey);
      } else if (setTask3 == "fail") {
        Navigator.pop(context);
        snackbarmethod("$setTask3");
      } else {
        Navigator.pop(context);
        invoiceFailinOtherReasonDialog(invoiceValue, shopCode, shopName,
            invoiceTotalamt, specialAmount, setTask3.toString(), shopSyskey);
      }
    });
  }

  Future<void> invoiceFailinOtherReasonDialog(invoiceValue, shopCode, shopName,
      invoiceTotalamt, specialAmount, String title, shopSyskey) async {
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
                  invoiceFailinOtherReason(invoiceValue, shopCode, shopName,
                      invoiceTotalamt, specialAmount, shopSyskey);
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

  Future<void> invoiceSetTask() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    setTask(merchandizingStatus, "COMPLETED", "COMPLETED")
        .then((setTastValue1) async {
      if (setTastValue1 == "success") {
        if (preferences.getString("InvoiceSts") == "SUCCESS") {
          setState(() {
            invoiceComplete = "SUCCESS";
            loading = false;
          });

          Navigator.pop(context);

          snackbarmethod1("SUCCESS");
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InVoice(
                          mcdCheck: widget.mcdCheck,
                          userType: widget.userType,
                          shopName: widget.shopName,
                          shopNameMm: widget.shopNameMm,
                          address: widget.address,
                          devices: widget.devices,
                          phone: widget.phone,
                        )));
          });
        } else {
          Navigator.pop(context);
          snackbarmethod1("SUCCESS");
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InVoice(
                          mcdCheck: widget.mcdCheck,
                          userType: widget.userType,
                          shopName: widget.shopName,
                          shopNameMm: widget.shopNameMm,
                          address: widget.address,
                          devices: widget.devices,
                          phone: widget.phone,
                        )));
          });
          preferences.setString('latitude', "");
          preferences.setString('longitude', "");
          preferences.setString('date', "");
          preferences.setString('address', "");
          preferences.setString('shopname', "");
          preferences.setString("shopCode", "");
          preferences.setString("shopnamemm", "");
          preferences.setString('merchandiserSts', "");
          preferences.setString('saveImageSts', "");
          preferences.setString('phNo', "");
          preferences.setString('email', "");
          preferences.setString("subTotal", "");

          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return NavigationBar(orgId, widget.mcdCheck, widget.userType,
                preferences.getString("DateTime"));
          }));
        }
      } else if (setTastValue1 == "fail") {
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
        snackbarmethod("$setTastValue1");
      } else {
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
        invoiceSetTaskDialog(setTastValue1.toString());
      }
    });
  }

  void invoiceFailSetTask(invoiceValue) {
    setTask(merchandizingStatus, "COMPLETED", "PENDING").then((setTaskValue2) {
      if (setTaskValue2 == "success") {
        Navigator.pop(context);
        snackbarmethod("$invoiceValue");
      } else if (setTaskValue2 == "fail") {
        Navigator.pop(context);
        snackbarmethod("$setTaskValue2");
      } else {
        Navigator.pop(context);
        invoiceFailSetTaskDialog(invoiceValue, setTaskValue2.toString());
      }
    });
  }

  Future<void> invoiceFailSetTaskDialog(invoiceValue, String title) async {
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
                  invoiceFailSetTask(invoiceValue);
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

  Future<void> invoiceSetTaskDialog(String title) async {
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
                  invoiceSetTask();
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

  Future<void> invoiceToServerDialog(
      shopCode, shopName, invoiceTotalamt, specialAmount, String title, shopSyskey) async {
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
                  invoiceToServer(
                      shopCode, shopName, invoiceTotalamt, specialAmount, shopSyskey);
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

  Future<void> invoiceDialog(String title) async {
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
                  ontapInvoice();
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

  Future<void> ontapTransactionComplete() async {
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

    setTask(merchandizingStatus, "COMPLETED", "COMPLETED")
        .then((setTaskValue1) {
      if (setTaskValue1 == "success") {
        getSysKey.then((val) {
          MerchandizerDatabase()
              .updateComplete(val[0]["shopsyskey"], "McdCompleted")
              .then((databaseValue) {
            tranComCheckin(val);
          });
        });
      } else if (setTaskValue1 == "fail") {
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
        snackbarmethod("$setTaskValue1");
      } else {
        setState(() {
          loading = false;
        });
        transactionCompleteDialog(setTaskValue1.toString());
      }
    });
  }

  Future<void> tranComCheckin(val) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    checkIn(
            double.parse(preferences.getString('latitude')),
            double.parse(preferences.getString('longitude')),
            preferences.getString('shopname'),
            preferences.getString('shopCode'),
            preferences.getString("shopnamemm"),
            val[0]["address"],
            val[0]["phoneno"],
            val[0]["email"],
            val[0]["shopsyskey"],
            "CHECKOUT",
            merchandizingStatus,
            "COMPLETED",
            "COMPLETED")
        .then((checkinValue) async {
      if (checkinValue == "success") {
        setState(() {
          loading = false;
        });
        itemCode.clear();
        itemName.clear();
        itemQty.clear();
        itemTolCount.clear();
        rtnItemCode.clear();
        rtnItemName.clear();
        rtnItemQty.clear();
        rtnItemTolCount.clear();

        preferences.setString('latitude', "");
        preferences.setString('longitude', "");
        preferences.setString('date', "");
        preferences.setString('address', "");
        preferences.setString('shopname', "");
        preferences.setString("shopCode", "");
        preferences.setString("shopnamemm", "");
        preferences.setString('merchandiserSts', "");
        preferences.setString('saveImageSts', "");
        preferences.setString('InvoiceSts', "");
        preferences.setString("OrderDetailSts", "");
        preferences.setString("subTotal", "");
        preferences.setString("returnTotal", "");
        preferences.setString("orderdetailSyskey", "");

        snackbarmethod1("Transaction Completed");

        preferences.setString("invoiceCompleteStatus", "COMPLETED");
        Future.delayed(Duration(seconds: 1), () async {
          shopbyUser.deleteAllNote();
          shopbyTeam.deleteAllNote();
          McdDatabase().deleteAllNote();

          datetime();

          tranComGetShopAll();
        });
      } else if (checkinValue == "fail") {
        setState(() {
          loading = false;
        });
        tranComCheckinFailSetTask(checkinValue);
      } else {
        setState(() {
          loading = false;
        });
        tranComCheckinFailInOtherReason(checkinValue, val);
      }
    });
  }

  void tranComCheckinFailSetTask(checkinValue) {
    setTask(merchandizingStatus, "COMPLETED", "COMPLETED")
        .then((setTaskValue3) {
      if (setTaskValue3 == "success") {
        Navigator.pop(context);
        snackbarmethod("$checkinValue");
      } else if (setTaskValue3 == "fail") {
        Navigator.pop(context);
        snackbarmethod("$setTaskValue3");
      } else {
        tranComCheckinFailSetTaskDialog(checkinValue, setTaskValue3.toString());
      }
    });
  }

  Future<void> tranComCheckinFailSetTaskDialog(
      checkinValue, String title) async {
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
                  tranComCheckinFailSetTask(checkinValue);
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

  void tranComCheckinFailInOtherReason(checkinValue, val) {
    setTask(merchandizingStatus, "COMPLETED", "COMPLETED")
        .then((setTaskValue4) {
      if (setTaskValue4 == "success") {
        Navigator.pop(context);
        tranComCheckinDialog(val, checkinValue.toString());
      } else if (setTaskValue4 == "fail") {
        Navigator.pop(context);
        snackbarmethod("$setTaskValue4");
      } else {
        tranComCheckinFailInOtherReasonDialog(
            checkinValue, val, setTaskValue4.toString());
      }
    });
  }

  Future<void> tranComCheckinFailInOtherReasonDialog(
      checkinValue, val, String title) async {
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
                  tranComCheckinFailInOtherReason(checkinValue, val);
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

  Future<void> tranComGetShopAll() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var check;

    final url = '$domain' + 'shop/getshopall';
    var param = jsonEncode({
      "spsyskey": "${preferences.getString('spsyskey')}",
      "teamsyskey": "",
      "usertype": "delivery",
      "date": "$date"
    });
    print(param);
    final response = await http
        .post(Uri.encodeFull(url), body: param, headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Content-Over": '${preferences.getString("OrgId")}',
        })
        .timeout(Duration(seconds: 20))
        .catchError((error) {
          check = 'Server Fail!';
        });

    if (response != null) {
      print("1");
      if (response.statusCode == 200) {
        print("2");
        var result = json.decode(response.body);
        print(result['status']);
        print(result['data']);
        if (result['data']["shopsByUser"].toString() == "[]") {
          check = "success";

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ShopList(date: preferences.getString("DateTime"))));
        }
        for (var i = 0; i < result['data']['shopsByUser'].length; i++) {
          shopbyUser
              .insertNote(ShopByUserNote(
                  result['data']['shopsByUser'][i]['isSaleOrderLessRouteShop']
                      .toString(),
                  result['data']['shopsByUser'][i]['address'].toString(),
                  result['data']['shopsByUser'][i]['shopnamemm'].toString(),
                  result['data']['shopsByUser'][i]['shopsyskey'].toString(),
                  result['data']['shopsByUser'][i]['long'].toString(),
                  result['data']['shopsByUser'][i]['phoneno'].toString(),
                  result['data']['shopsByUser'][i]['zonecode'].toString(),
                  result['data']['shopsByUser'][i]['shopcode'].toString(),
                  result['data']['shopsByUser'][i]['shopname'].toString(),
                  result['data']['shopsByUser'][i]['teamcode'].toString(),
                  result['data']['shopsByUser'][i]['location'].toString(),
                  result['data']['shopsByUser'][i]['comment'].toString(),
                  result['data']['shopsByUser'][i]['usercode'].toString(),
                  result['data']['shopsByUser'][i]['user'].toString(),
                  result['data']['shopsByUser'][i]['lat'].toString(),
                  result['data']['shopsByUser'][i]['email'].toString(),
                  result['data']['shopsByUser'][i]['username'].toString(),
                  result['data']['shopsByUser'][i]["status"]["currentType"]))
              .then((value) {
            if (i == result['data']['shopsByUser'].length - 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ShopList(date: preferences.getString("DateTime"))));
            }
          });
        }
        check = 'success';
      } else {
        print(response.statusCode);
        check = "Server Error " + response.statusCode.toString() + " !";

        Navigator.pop(context);
        snackbarmethod("$check");
      }
    } else {
      check = 'Connection Fail!';
      tranComGetShopAllDialog(check.toString());
    }
  }

  Future<void> tranComGetShopAllDialog(String title) async {
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
                  tranComGetShopAll();
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

  Future<void> tranComCheckinDialog(val, String title) async {
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
                  tranComCheckin(val);
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

  Future<void> transactionCompleteDialog(String title) async {
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
                  ontapTransactionComplete();
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

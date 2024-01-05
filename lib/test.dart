import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

class TestPrint extends StatefulWidget {
  @override
  _TestPrintState createState() => _TestPrintState();
}

class _TestPrintState extends State<TestPrint> {
  List header = [
    {
      "Store": "Myo Myo Myat (မျိူးမျိူးမြတ်)",
      "Tel": "95979743847",
      "User_Name": "Delivery truck 2",
      "Invoice_No": "1",
      "Print_Date": "11/11/2020 08:18",
      "Invoice_Date": "11/11/2020 08:18",
      "Sub_Total": "80,000",
      "Special_Discount_Amount": "0",
      "Expired_Amount": "0",
      "spAccountName":"sp",
      "spAccount":"",
      "abAccountName":"ab",
      "abAccount":"",
      "Cash_Amount":"",
      "Credit_Amount":"",
      "Total_Amount": "80,000",
      "Total_Amount_Percent":"",
      "Additional_Cash":"",
      "Street":"၁၁, မင်းကြီးရန်နောင်လမ်း ၊ 57.58 ကြား , သင်ပန်းကုန်းရပ်ကွက်"
    }
  ];

  List detail = [
    {
      "stkDesc": "အစမ်း",
      "totalqty": "100",
      "discount":"10",
      "price": "100",
      "totalAmount": "10000"
    },
    {
      // "stkDesc": "SP_Daily_Butter Bread SP_Daily_Butter Bread SP_Daily_Butter Bread",
      "stkDesc": "12345678901234567890123456789012345678901234567890",
      "totalqty": "",
      "discount":"",
      "price": "10000",
      "totalAmount": "1000000"
    }
  ];

  String bName = "SP Bakery";
  static const platform = const MethodChannel('flutter.native/helper');

  Future<void> startScanNative(String macAddress) async {
    try {
      final String result = await platform.invokeMethod('startScan', {
        "macAddress": macAddress,
      });
      print('start scan >>$result');
    } on PlatformException catch (e) {
      print('Failed to Invoke: ${e.message}');
    }
  }

  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  String prefReadName;
  String prefReadAddress;

  @override
  void initState() {
    super.initState();
    printerManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;
      });
    });
  }

  Future<void> printMultiLang(
      List detailData, List headerData, String bName) async {
    try {
      final String result = await platform.invokeMethod('multi_lang_test',
          {"detail": detailData, "header": headerData, "bName": bName});
      print('start scan >>$result');
    } on PlatformException catch (e) {
      print('Failed to Invoke: ${e.message}');
    }
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(Duration(seconds: 4));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test"),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(
              Icons.print,
              color: Colors.white,
            ),
            onPressed: () {
              printMultiLang(detail, header, bName);
              // printMultiLang(detail, header, bName);
              // printMultiLang(jsonEncode(detail.map((e) => e.toJson()).toList()),
              //     jsonEncode(header.map((e) => e.toJson()).toList()), bName);
            }),
      ),
      body: ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                prefReadName = _devices[index].name;
                prefReadAddress = _devices[index].address;
                startScanNative(prefReadAddress);
              },
              child: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.print),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(_devices[index].name ?? ''),
                              Text(_devices[index].address),
                              Text(
                                'Click to print a test receipt',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(),
                ],
              ),
            );
          }),
      floatingActionButton: StreamBuilder<bool>(
        stream: printerManager.isScanningStream,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: _stopScanDevices,
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
              child: Icon(Icons.search),
              onPressed: _startScanDevices,
            );
          }
        },
      ),
    );
  }
}

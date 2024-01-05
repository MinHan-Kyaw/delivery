import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:delivery_2/Login.dart';

BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
List<BluetoothDevice> devices = [];

Future<void> initPlatformState(mounted) async {
  List<BluetoothDevice> _devices = [];

  try {
    _devices = await bluetooth.getBondedDevices();
  } on PlatformException {
    // ignore: todo
    // TODO - Error
    print("printer error");
  }

  print("Direct Print ==> $_devices");

  if (!mounted) return;
  devices = _devices;
}

final GlobalKey<State> _keyLoader = new GlobalKey<State>();
Future<void> _handleSubmit(BuildContext context) async {
  try {
    Dialogs.showLoadingDialog(context, _keyLoader);
  } catch (error) {
    print(error);
  }
}

Future<void> connect(context, _device) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  if (_device == null) {
    failToast("Please select printer!");
  } else {
    _handleSubmit(context);
    print(_device.name);
    bluetooth.isConnected.then((isConnected) {
      print(isConnected);
      if (!isConnected) {
        print("notconnect");
        bluetooth.connect(_device)
            //show message
            //storage
            .catchError((error) {
          Navigator.pop(context);
          print(error);
          failToast("Unable to connect");
        });

        preferences.setString("printerName", _device.name).then((value) {
          Future.delayed(Duration(milliseconds: 100), () {
            preferences.setString("PrintType", "Thermal");
            successToast("Connected!");
          });
          print("success");
          Navigator.pop(context);
        });
      } else {
        preferences.setString("printerName", _device.name).then((value) {
          print(preferences.getString('printerName'));
          Future.delayed(Duration(milliseconds: 100), () {
            preferences.setString("PrintType", "Thermal");
            successToast("Connected!");
          });
          print("connected");
          Navigator.pop(context);
        });

        // Navigator.pop(context);
      }
    });
  }
}

void tesPrint(
    String brandName,
    String storeName,
    String storeID,
    String tel,
    String preSeller,
    String userName,
    String invNo,
    String printDate,
    String invDate,
    List stockDetailList,
    List invPromoList,
    String subTotal,
    String specialDisAmt,
    String expAmt,
    List accDetail,
    String cashAmt,
    String creditAmt,
    String totalAmt,
    List additionalCash) async {
      String singleLine = "-";
  bluetooth.isConnected.then((isConnected) {
    if (isConnected) {
      for(var val = 0; val < 2; val++) {
      bluetooth.printCustom("$brandName", 1, 1);

      bluetooth.printNewLine();

      bluetooth.printCustom("$storeName", 0, 0);
      bluetooth.printCustom("$storeID", 0, 0);
      bluetooth.printCustom("$tel", 0, 0);
      bluetooth.printCustom("$preSeller", 0, 0);
      bluetooth.printCustom("$userName", 0, 0);
      bluetooth.printCustom("$invNo", 0, 0);
      bluetooth.printCustom("$printDate", 0, 0);
      bluetooth.printCustom("$invDate", 0, 0);

      bluetooth.printCustom("${singleLine * 64}", 0, 0);

      for (var i = 0; i < stockDetailList.length; i++) {
        bluetooth.printCustom(stockDetailList[i]["value"], 0, 0);
      }

      bluetooth.printNewLine();

      for (var i = 0; i < invPromoList.length; i++) {
        bluetooth.printCustom(invPromoList[i]["value"], 0, 0);
      }

      bluetooth.printCustom("${singleLine * 64}", 0, 0);

      bluetooth.printCustom("$subTotal", 0, 0);
      bluetooth.printCustom("$specialDisAmt", 0, 0);
      bluetooth.printCustom("$expAmt", 0, 0);

      for (var i = 0; i < accDetail.length; i++) {
        bluetooth.printCustom(accDetail[i]["value"], 0, 0);
      }

      bluetooth.printCustom("$cashAmt", 0, 0);
      bluetooth.printCustom("$creditAmt", 0, 0);

      bluetooth.printCustom("${singleLine * 64}", 0, 0);

      bluetooth.printCustom("$totalAmt", 0, 0);

      for (var i = 0; i < additionalCash.length; i++) {
        bluetooth.printCustom("${singleLine * 64}", 0, 0);
        bluetooth.printCustom(additionalCash[i]["value"], 0, 0);
      }
      String doubleLine = "=";
      bluetooth.printCustom("${doubleLine * 64}", 0, 0);
      bluetooth.printNewLine();

      bluetooth.printCustom('Thank you!', 1, 1);

      bluetooth.printCustom('$brandName supported by Auderbox', 1, 1);

      // bluetooth.printCustom('$brandName Hotline : 09770288882', 1, 1);

      bluetooth.printNewLine();
      bluetooth.paperCut();
      }
    }
  });
}

void successToast(String text) {
  Fluttertoast.showToast(
      msg: "$text",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0);
}

void failToast(String text) {
  Fluttertoast.showToast(
      msg: "$text",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

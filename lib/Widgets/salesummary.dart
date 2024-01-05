import 'package:flutter/material.dart';
import 'package:delivery_2/service.dart/AllService.dart';

class SaleSummary extends StatefulWidget {
  @override
  _SaleSummaryState createState() => _SaleSummaryState();
}

class _SaleSummaryState extends State<SaleSummary> {
  bool loading = true;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';

  @override
  void initState() {
    super.initState();
    delAmountSummary();
  }

  int subTotal = 0;
  int expiredAmt = 0;
  int specialDisAmt = 0;
  int total = 0;

  void delAmountSummary() {
    getDelAmountSummary().then((value) {

      if(value == "success") {
        setState(() {

        List subTotalList = [];
        List expiredAmtList = [];
        List specialDisAmtList = [];
        List totalList = [];

        for(var i = 0; i < getDelAmtSummary.length; i++) {
          if(getDelAmtSummary[i]["orderAmount"].toString().substring(getDelAmtSummary[i]["orderAmount"].toString().lastIndexOf("."), getDelAmtSummary[i]["orderAmount"].toString().length).length > 3) {
            getDelAmtSummary[i]["orderAmount"] = double.parse(getDelAmtSummary[i]["orderAmount"]..toStringAsFixed(2));
          } else if(double.parse(getDelAmtSummary[i]["orderAmount"].toString().substring(getDelAmtSummary[i]["orderAmount"].toString().lastIndexOf("."), getDelAmtSummary[i]["orderAmount"].toString().length)) == 0.0) {
            getDelAmtSummary[i]["orderAmount"] = getDelAmtSummary[i]["orderAmount"].toInt();
          }
          subTotalList.add(getDelAmtSummary[i]["orderAmount"]);

          if(getDelAmtSummary[i]["returnAmount"].toString().substring(getDelAmtSummary[i]["returnAmount"].toString().lastIndexOf("."), getDelAmtSummary[i]["returnAmount"].toString().length).length > 3) {
            getDelAmtSummary[i]["returnAmount"] = double.parse(getDelAmtSummary[i]["returnAmount"]..toStringAsFixed(2));
          } else if(double.parse(getDelAmtSummary[i]["returnAmount"].toString().substring(getDelAmtSummary[i]["returnAmount"].toString().lastIndexOf("."), getDelAmtSummary[i]["returnAmount"].toString().length)) == 0.0) {
            getDelAmtSummary[i]["returnAmount"] = getDelAmtSummary[i]["returnAmount"].toInt();
          }
          expiredAmtList.add(getDelAmtSummary[i]["returnAmount"]);

          if(getDelAmtSummary[i]["specialAmount"].toString().substring(getDelAmtSummary[i]["specialAmount"].toString().lastIndexOf("."), getDelAmtSummary[i]["specialAmount"].toString().length).length > 3) {
            getDelAmtSummary[i]["specialAmount"] = double.parse(getDelAmtSummary[i]["specialAmount"]..toStringAsFixed(2));
          } else if(double.parse(getDelAmtSummary[i]["specialAmount"].toString().substring(getDelAmtSummary[i]["specialAmount"].toString().lastIndexOf("."), getDelAmtSummary[i]["specialAmount"].toString().length)) == 0.0) {
            getDelAmtSummary[i]["specialAmount"] = getDelAmtSummary[i]["specialAmount"].toInt();
          }
          specialDisAmtList.add(getDelAmtSummary[i]["specialAmount"]);

          if(getDelAmtSummary[i]["totalAmount"].toString().substring(getDelAmtSummary[i]["totalAmount"].toString().lastIndexOf("."), getDelAmtSummary[i]["totalAmount"].toString().length).length > 3) {
            getDelAmtSummary[i]["totalAmount"] = double.parse(getDelAmtSummary[i]["totalAmount"]..toStringAsFixed(2));
          } else if(double.parse(getDelAmtSummary[i]["totalAmount"].toString().substring(getDelAmtSummary[i]["totalAmount"].toString().lastIndexOf("."), getDelAmtSummary[i]["totalAmount"].toString().length)) == 0.0) {
            getDelAmtSummary[i]["totalAmount"] = getDelAmtSummary[i]["totalAmount"].toInt();
          }
          totalList.add(getDelAmtSummary[i]["totalAmount"]);
        }

        for(var i = 0; i < subTotalList.length; i++) {
          subTotal += subTotalList[i];
        }

        for(var i = 0; i < expiredAmtList.length; i++) {
          expiredAmt += expiredAmtList[i];
        }

        for(var i = 0; i < specialDisAmtList.length; i++) {
          specialDisAmt += specialDisAmtList[i];
        }

        for(var i = 0; i < totalList.length; i++) {
          total += totalList[i];
        }

        loading = false;

      });
      }else if(value == "fail") {
        setState(() {
          loading = false;
        });
        snackbarmethod("FAIL!");
      }else {
        setState(() {
          loading = false;
        });
        snackbarmethod(value);
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


  @override
  Widget build(BuildContext context) {
    Widget body = Padding(
      padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(
          color: Colors.grey[400],
        ),
        children: [
          TableRow(children: [
            ListTile(
              leading: Text("Completed Stores",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),),
              trailing: Text("${getDelAmtSummary.length}",style: TextStyle(fontSize:16)),
            ),
          ]),
          TableRow(children: [
            ListTile(
              leading: Text("Sub Total",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold)),
              trailing: Text("$subTotal".replaceAllMapped(reg, mathFunc),style: TextStyle(fontSize:16)),
            ),
          ]),
          TableRow(children: [
            ListTile(
              leading: Text("Expired Amount",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold)),
              trailing: Text("$expiredAmt".replaceAllMapped(reg, mathFunc),style: TextStyle(fontSize:16)),
            ),
          ]),
          TableRow(children: [
            ListTile(
              leading: Text("Special Discount Amount",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold)),
              trailing: Text("$specialDisAmt".replaceAllMapped(reg, mathFunc),style: TextStyle(fontSize:16)),
            ),
          ]),
          TableRow(children: [
            ListTile(
              leading: Text("Total Amount",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),),
              trailing: Text("${(subTotal - expiredAmt) - specialDisAmt}".replaceAllMapped(reg, mathFunc),style: TextStyle(fontSize:16)),
            ),
          ]),
        ],
      ),
    );

    var loadProgress = new Container(
        child: new Stack(children: <Widget>[
      body,
      Container(
        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 0.5)),
        width: MediaQuery.of(context).size.width * 0.99,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Center(
            child: CircularProgressIndicator(
          backgroundColor: Colors.red,
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )),
      ),
    ]));


    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor:   Color(0xffe53935),
        centerTitle: true,
        title: Text("Sale Summary"),
      ),
        body: loading ? loadProgress : body);
  } 
}

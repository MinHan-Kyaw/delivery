import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_2/Login.dart';
import 'package:delivery_2/service.dart/AllService.dart';

class URL extends StatefulWidget {
  @override
  _URLState createState() => _URLState();
}

class _URLState extends State<URL> {
  @override
  void initState() {
    super.initState();
    urlCtrl.text = domain;
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

  TextEditingController urlCtrl = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  // urlCtrl = domain;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          title: Text("URL"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              TextField(
                cursorColor: Colors.red,
                controller: urlCtrl,
                decoration: InputDecoration(
                  // hintText: domain,

                  labelText: "URL",
                  labelStyle: TextStyle(color: Colors.grey, fontSize: 15.0),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffe53935)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 50.0,
                child: FlatButton(
                  onPressed: () async {
                    if (urlCtrl.text == '' || urlCtrl.text == null) {
                      snackbarmethod("Please add url!");
                    } else {
                      final SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.setString('URL', urlCtrl.text);
                      snackbarmethod1("SUCCESS");
                      Future.delayed(Duration(seconds: 1), () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      });
                    }
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  padding: EdgeInsets.all(0.0),
                  child: Ink(
                    decoration: BoxDecoration(
                        color: Color(0xffe53935),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width,
                          minHeight: 50.0),
                      alignment: Alignment.center,
                      child: Text(
                        "EDIT",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

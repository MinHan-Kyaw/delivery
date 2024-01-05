import 'package:delivery_2/Login.dart';
import 'package:delivery_2/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Delivery app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static const platform = const MethodChannel('flutter.native/helper');
 
  Future<void> responseFromNativeCode() async {
    try {
      final String result = await platform.invokeMethod('helloFromNativeCode');
      print('result>>$result');
    } on PlatformException catch (e) {
      print('Failed to Invoke: ${e.message}');
    }
  }
 
  void initState() {
    responseFromNativeCode();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Login(),
      // body: TestPrint(),
    );
  }
}


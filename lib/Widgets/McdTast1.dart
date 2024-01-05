import 'dart:convert';
import 'dart:io';
import 'package:camera_camera/page/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_2/database/McdDatabase.dart';
import 'package:delivery_2/database/MerchandizerDatabase.dart';
import 'package:delivery_2/database/MerchandizerNote.dart';
import 'package:delivery_2/database/shopByUserDatabase.dart';
import 'package:delivery_2/service.dart/AllService.dart';
import 'ShowImage.dart';

class Tast1 extends StatefulWidget {
  final List image;
  final String task;
  final String mcdCheck;
  final String userType;
  final List savedImage;
  final String tasktoDo;
  final String shopName;
  final String shopNameMm;
  final String address;
  final List merchandiserList;
  final String taskCode;
  final String mcdSyskey;
  final String phone;
  final String completeOrNot;
  final String remark;
  final String taskSyskey;
  Tast1(
      {Key key,
      this.image,
      this.task,
      this.mcdCheck,
      this.userType,
      this.savedImage,
      this.tasktoDo,
      this.shopName,
      @required this.shopNameMm,
      this.address,
      this.merchandiserList,
      this.taskCode,
      this.mcdSyskey,
      this.phone,
      @required this.completeOrNot,
      this.remark,
      @required this.taskSyskey})
      : super(key: key);
  @override
  _Tast1State createState() => _Tast1State();
}

class _Tast1State extends State<Tast1> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  File _image = File('');
  File _image1 = File('');
  List img = [];
  List imgPath = [];
  List imageList = [];
  var pathDir;
  ShopsbyUser helperShopsbyUser = ShopsbyUser();
  McdDatabase mcdDatabase = McdDatabase();
  List<FileSystemEntity> _deletedImg = [];
  TextEditingController remarkCtrl = TextEditingController();

  MerchandizerDatabase merchandizerDatabase = MerchandizerDatabase();

  bool loading = true;

  Future getImageFromGal(BuildContext context) async {
    FilePickerResult files = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: true);

    if (files == null) {
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      for (var i = 0; i < files.paths.length; i++) {
        var result = await FlutterImageCompress.compressWithFile(
          files.paths[i],
          minWidth: 500,
          minHeight: 500,
          quality: 50,
          rotate: 0,
        );

        imageList
            .add({"filename": File("${files.paths[i]}"), "compress": result});
        setState(() {
          img.add(File("${files.paths[i]}"));
        });
        if (i == files.paths.length - 1) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    }
  }


  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  void _handleSubmit(BuildContext context) {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader);
    } catch (error) {
      print(error);
    }
  }

  Future save(var sysKey, BuildContext context) async {
    List<FileSystemEntity> _images;
    setState(() {
      loading = true;
    });

    var dir = await getExternalStorageDirectory();
    List list = taskList
        .where((element) => element["syskey"] == widget.taskSyskey)
        .toList();
    for (var a = 0; a < list.length; a++) {
      pathDir = "$sysKey/$date/$campaignId/${list[a]["syskey"]}";
    }

    var knockDir =
        await new Directory('${dir.path}/$pathDir').create(recursive: true);

    print(imageList);

    // (imageList).forEach((photo) async {
    for (var i = 0; i < imageList.length; i++) {
      // _handleSubmit(context);
      var path = knockDir.path;

      var nowdate = DateTime.now();
      var newimgName = "${nowdate.year}" +
          "${nowdate.month}" +
          "${nowdate.day}" +
          "${nowdate.hour}" +
          "${nowdate.minute}" +
          "${nowdate.second}" +
          "${nowdate.millisecond}";

      // copyImage(photo, path, newimgName, context, sysKey).then((value) {
      //   Navigator.pop(context);
      //   snackbarmethod1("SUCCESS");
      // });
      File imageFile = File("");
      imageFile = await File("$path/$newimgName")
          .writeAsBytes(imageList[i]["compress"]);
      print(imageFile.toString() + " File Image");

      

      // var dir = await getExternalStorageDirectory();
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      List list = taskList
          .where((element) => element["syskey"] == widget.taskSyskey)
          .toList();
      pathDir = "$sysKey/$date/$campaignId/${list[0]["syskey"]}";

      MerchandizerDatabase()
          .updateNote(MerchandizerNote(
              preferences.getString("userId"),
              '${dir.path}/$pathDir',
              "$pathDir",
              widget.taskSyskey,
              sysKey,
              campaignId,
              brandOwnerId,
              remarkCtrl.text,
              json.encode(tasktoDo),
              "",
              ""))
          .then((value) {
        print(imageList.length);
        if (i + 1 == imageList.length) {
          Navigator.pop(context);
          snackbarmethod1("SUCCESS");
          Navigator.pop(context);
        }
      });
    }
    // });

    setState(() {
      print('successfully save');
    });

    return _images;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      remarkCtrl = TextEditingController(text: widget.remark);
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

  String merchandizingStatus;
  String orderdetailStatus;
  String invoiceStatus;

  // 09965887879

  @override
  Widget build(BuildContext context) {
    if (widget.savedImage.length != 0) {
      // setState(() {
      img = widget.savedImage;
      // });
    } else if (img == []) {
      img.add(_image == null ? _image1 : _image);
    }

    img.removeWhere((element) => element.toString() == "File: ''");

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldkey,
        // floatingActionButton: SpeedDial(
        //   animatedIcon: AnimatedIcons.add_event,
        //   animatedIconTheme: IconThemeData(size: 22.0),
        //   curve: Curves.bounceIn,
        //   overlayColor: Colors.black,
        //   overlayOpacity: 0.5,
        //   onOpen: () => print('OPENING DIAL'),
        //   onClose: () => print('DIAL CLOSED'),
        //   tooltip: 'Speed Dial',
        //   heroTag: 'speed-dial-hero-tag',
        //   backgroundColor: Colors.white,
        //   foregroundColor: Colors.black,
        //   elevation: 8.0,
        //   shape: CircleBorder(),
        //   children: [
        //     SpeedDialChild(
        //       child: Icon(Icons.camera),
        //       backgroundColor: Color(0xffe53935),
        //       onTap: () => getImageFromCam(),
        //     ),
        //     SpeedDialChild(
        //       child: Icon(Icons.image),
        //       backgroundColor: Color(0xffe53935),
        //       onTap: () => getImageFromGal(),
        //     ),
        //   ],
        // ),
        bottomNavigationBar: Visibility(
          visible:
              // widget.completeOrNot == "McdCompleted" ||
              invoiceCompleteSts == "CHECKOUT" ? false : true,
          child: Padding(
            padding: EdgeInsets.only(left: 5, right: 5, bottom: 15),
            child: GestureDetector(
              onTap: () async {
                _handleSubmit(context);
                var connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult == ConnectivityResult.mobile ||
                    connectivityResult == ConnectivityResult.wifi) {
                  List image = [];

                  image = img
                      .where((element) =>
                          element.toString().substring(0, 35) !=
                          "File: '/storage/emulated/0/Android/")
                      .toList();

                  for (var a = 0; a < img.length; a++) {
                    print(img[a]);
                  }

                  for (var a = 0; a < image.length; a++) {
                    print(image[a]);
                  }

                  if (image.length == 0 && widget.remark == remarkCtrl.text) {
                    Navigator.pop(context);
                    snackbarmethod("Please Add Image!");
                  } else {
                    final SharedPreferences preferences =
                        await SharedPreferences.getInstance();

                    var getSysKey = helperShopsbyUser
                        .getShopSyskey(preferences.getString('shopname'));

                    var imagePath;

                    getSysKey.then((val) async {
                        List list = taskList
                            .where((element) =>
                                element["syskey"] == widget.taskSyskey)
                            .toList();
                        for (var a = 0; a < list.length; a++) {
                          imagePath = "${val[0]["shopsyskey"]}/$date/$campaignId/${list[a]["syskey"]}";
                        }

                        var knockDir;
                        var dir = await getExternalStorageDirectory();
                        List<FileSystemEntity> _images = [];

                        knockDir = await new Directory("${dir.path}/$imagePath")
                            .create(recursive: true);

                        _images = knockDir.listSync(
                            recursive: true, followLinks: false);

                        for (var v = 0; v < _deletedImg.length; v++) {
                          _images.forEach((element) {
                            if (element.toString() ==
                                _deletedImg[v].toString()) {
                              element.delete(recursive: true);
                            } else {
                              Navigator.pop(context);
                              snackbarmethod("FAIL!");
                            }
                          });
                        }
                        if ((remarkCtrl.text == '' ||
                                remarkCtrl.text == null) &&
                            img.length == 0) {
                          if (widget.remark == null || widget.remark == '') {
                            Navigator.pop(context);
                            snackbarmethod("Please Add Image!");
                          } else {
                            MerchandizerDatabase()
                                .updateNote(MerchandizerNote(
                                    preferences.getString("userId"),
                                    "",
                                    "",
                                    widget.taskSyskey,
                                    val[0]["shopsyskey"],
                                    campaignId,
                                    brandOwnerId,
                                    "",
                                    json.encode(tasktoDo),
                                    "",
                                    ""))
                                .then((value) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              snackbarmethod1("SUCCESS");
                            });
                          }
                        } else if (widget.remark != remarkCtrl.text &&
                            image.length == 0) {
                          MerchandizerDatabase()
                              .updateNote(MerchandizerNote(
                                  preferences.getString("userId"),
                                  "${dir.path}/$imagePath",
                                  "$pathDir",
                                  widget.taskSyskey,
                                  val[0]["shopsyskey"],
                                  campaignId,
                                  brandOwnerId,
                                  remarkCtrl.text,
                                  json.encode(tasktoDo),
                                  "",
                                  ""))
                              .then((value) {
                            Navigator.pop(context);
                            Navigator.pop(context);

                          });
                        } else {
                          save(val[0]["shopsyskey"], context).then((value) {});
                        }
                    });
                  }
                } else {
                  snackbarmethod("Check your connection!");
                  Navigator.pop(context);
                }
              },
              child: Card(
                color: Color(0xffef5350),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Text(
                    "Upload",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  )),
                ),
              ),
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          title: Text("${widget.taskCode}"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                // print(img);
              }),
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${widget.tasktoDo}",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Container(
                child:
                    // widget.completeOrNot == "McdCompleted" ||
                    invoiceCompleteSts == "CHECKOUT"
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10, left: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text("${widget.remark}"),
                                Divider(color: Colors.grey)
                              ],
                            ),
                          )
                        : TextFormField(
                            controller: remarkCtrl,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            cursorColor: Colors.grey,
                            decoration: InputDecoration(
                                labelText: "Remark",
                                labelStyle: TextStyle(color: Colors.black),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey))),
                            onChanged: (val) async {
                              setState(() {
                                val = remarkCtrl.text;
                              });
                            },
                          ),
              ),
            ),
            Container(
              height:
                  // widget.completeOrNot == "McdCompleted" ||
                  invoiceCompleteSts == "CHECKOUT"
                      ? MediaQuery.of(context).size.height - 260
                      : MediaQuery.of(context).size.height - 320,
              child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  scrollDirection: Axis.vertical,
                  children: List.generate(img.length + 1, (index) {
                    if (index == img.length) {
                      return Visibility(
                        visible:
                            // widget.completeOrNot == "McdCompleted" ||
                            invoiceCompleteSts == "CHECKOUT" ? false : true,
                        child: GestureDetector(
                          onTap: () {
                            // if (img.length == 5 || img.length > 5) {
                            //   snackbarmethod("Maximum 5 images!");
                            // } else {
                            return showDialog<void>(
                              context: context,
                              // barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(0.0))),
                                  content: Container(
                                    height: 78,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(height: 10),
                                        GestureDetector(
                                          onTap: () {
                                            _handleSubmit(context);
                                            getImageFromGal(context);
                                            // Navigator.pop(context);
                                          },
                                          child: Container(
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.image,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(width: 20),
                                                Text("Gallery",
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Divider(
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 2),
                                        GestureDetector(
                                          onTap: () async {
                                            // getImageFromCam();

                                            _handleSubmit(context);

                                            File val;
                                            val = await showDialog(
                                                context: context,
                                                builder: (context) => Camera(
                                                      mode:
                                                          CameraMode.fullscreen,
                                                    ));

                                            if (val == null) {
                                              val = File("");
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            }

                                            var result =
                                                await FlutterImageCompress
                                                    .compressWithFile(
                                              val.absolute.path,
                                              minWidth: 500,
                                              minHeight: 500,
                                              quality: 50,
                                              rotate: 0,
                                            );
                                            imageList.add({
                                              "filename": val,
                                              "compress": result
                                            });

                                            setState(() {
                                              img.add(val);
                                            });

                                            print(result);

                                            if (result.length != 0) {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: Container(
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(width: 20),
                                                Text("Camera",
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                            // }
                          },
                          child: Container(
                            margin:
                                EdgeInsets.only(left: 10, right: 10, top: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey[300]),
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Container(
                                // height: 800.0,
                                // width: double.infinity,
                                child: Icon(
                                  Icons.add,
                                  size: 100,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return Stack(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ShowImage(
                                        image: Image.file(img[index]))));
                          },
                          child: Container(
                            margin:
                                EdgeInsets.only(left: 10, right: 10, top: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                height: 800.0,
                                width: double.infinity,
                                color: Colors.white,
                                child: Image.file(
                                  img[index],
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              // widget.completeOrNot == "McdCompleted" ||
                              invoiceCompleteSts == "CHECKOUT" ? false : true,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, right: 10),
                              child: Container(
                                  width: 25.0,
                                  height: 25.0,
                                  padding: const EdgeInsets.all(1.5),
                                  decoration: new BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: MaterialButton(
                                    onPressed: () async {
                                      final SharedPreferences preferences =
                                          await SharedPreferences.getInstance();

                                      var dir =
                                          await getExternalStorageDirectory();

                                      var imagePath;

                                      var getSysKey = helperShopsbyUser
                                          .getShopSyskey(preferences
                                              .getString('shopname'));

                                      getSysKey.then((val) async {
                                          List list = taskList
                                              .where((element) =>
                                                  element["syskey"] ==
                                                  widget.taskSyskey)
                                              .toList();
                                          for (var a = 0;
                                              a < list.length;
                                              a++) {
                                            imagePath =
                                                "${val[0]["shopsyskey"]}/$date/$campaignId/${list[a]["syskey"]}";
                                          }
                                          if (img.length == 1) {
                                            if (remarkCtrl.text == "") {
                                              MerchandizerDatabase().updateNote(
                                                  MerchandizerNote(
                                                      preferences
                                                          .getString("userId"),
                                                      "",
                                                      "",
                                                      widget.taskSyskey,
                                                      "${val[0]["shopsyskey"]}",
                                                      campaignId,
                                                      brandOwnerId,
                                                      "",
                                                      json.encode(tasktoDo),
                                                      "",
                                                      ""));
                                            } else {
                                              MerchandizerDatabase().updateNote(
                                                  MerchandizerNote(
                                                      preferences
                                                          .getString("userId"),
                                                      "${dir.path}/$imagePath",
                                                      "",
                                                      widget.taskSyskey,
                                                      "${val[0]["shopsyskey"]}",
                                                      campaignId,
                                                      brandOwnerId,
                                                      remarkCtrl.text,
                                                      json.encode(tasktoDo),
                                                      "",
                                                      ""));
                                            }
                                          }
                                          for (var a = 0;
                                              a < list.length;
                                              a++) {
                                            pathDir =
                                                "${val[0]["shopsyskey"]}/$date/$campaignId/${list[a]["syskey"]}";
                                          }
                                          var knockDir = await new Directory(
                                                  '${dir.path}/$pathDir')
                                              .create(recursive: true);

                                          List<FileSystemEntity> imgList =
                                              knockDir.listSync(
                                                  recursive: true,
                                                  followLinks: false);

                                          print(imgList);

                                          print(img[index]);

                                          imgList.forEach((element) {
                                            if (element.toString() ==
                                                img[index].toString()) {
                                              element.delete(recursive: true);
                                            } else {
                                              print(element);
                                            }
                                          });

                                          imgList.forEach((element) {
                                            if (element.path
                                                    .split('/')
                                                    .last
                                                    .toString() ==
                                                img[index]
                                                    .path
                                                    .split('/')
                                                    .last
                                                    .toString()) {
                                              element.delete(recursive: true);
                                            } else {
                                              print(element);
                                            }
                                          });

                                        imageList.removeWhere((element) =>
                                            element["filename"].toString() ==
                                            img[index].toString());

                                        img.removeWhere((element) =>
                                            element.toString() ==
                                            img[index].toString());

                                        setState(() {});
                                      });
                                    },
                                    color: Color(0xffe53935),
                                    textColor: Colors.white,
                                    child: Icon(
                                      Icons.cancel,
                                      size: 21,
                                    ),
                                    padding: EdgeInsets.all(0),
                                    shape: CircleBorder(),
                                  )),
                            ),
                          ),
                        )
                      ],
                    );
                  })),
            ),
          ],
        ),
      ),
    );
  }
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  elevation: 0,
                  key: key,
                  backgroundColor: Colors.transparent,
                  children: <Widget>[
                    Center(
                        child: CircularProgressIndicator(
                      backgroundColor: Color(0xffe53935),
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ))
                  ]));
        });
  }
}

import 'dart:io';
import 'package:flutter/material.dart';

class ShowImage extends StatefulWidget {
  var image;
  ShowImage({Key key, @required this.image}) : super(key: key);
  @override
  _ShowImageState createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.image,
    );
  }
}
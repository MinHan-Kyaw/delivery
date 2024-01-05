
import 'package:flutter/material.dart';

class GiftBanner extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    
    path.lineTo(size.width, 0);
    
    path.lineTo(0.0, size.height);

    path.lineTo(size.width, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper old) {
    return old != this;
  }
}



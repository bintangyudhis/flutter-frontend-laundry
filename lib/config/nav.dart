import 'package:flutter/material.dart';

class Nav {
  static Future<dynamic> push(BuildContext context, Widget page) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static Future<dynamic> replace(BuildContext context, Widget page) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

}
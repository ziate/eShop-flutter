import 'dart:convert';

import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

import 'Helper/Session.dart';
import 'Helper/String.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //systemNavigationBarColor: Colors.blue, // navigation bar color
    statusBarColor: primary, // status bar color
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          cursorColor: primary,
          fontFamily: 'josefin',
          textTheme: TextTheme(
              headline6: TextStyle(
            color: primary,
            fontWeight: FontWeight.w600,
          ))),
      home: Splash(),
    );
  }
}

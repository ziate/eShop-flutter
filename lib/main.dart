import 'dart:convert';
import 'package:country_code_picker/country_localizations.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //systemNavigationBarColor: Colors.blue, // navigation bar color
    statusBarColor: primary, // status bar color
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      supportedLocales: [
        Locale('en'),
        Locale('it'),
        Locale('fr'),
        Locale('es'),
      ],
      localizationsDelegates: [
        CountryLocalizations.delegate,
      ],
      title: appName,
      theme: ThemeData(
          primarySwatch: primary_app,
          cursorColor: primary,
          fontFamily: 'josefin',
          textTheme: TextTheme(
              headline6: TextStyle(
            color: primary,
            fontWeight: FontWeight.w600,
          ))),
      debugShowCheckedModeBanner: false,
      //home: Splash(),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => Splash(),
        '/home': (context) => Home(),
      },
    );
  }
}

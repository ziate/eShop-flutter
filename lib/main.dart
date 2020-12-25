import 'dart:convert';
import 'package:country_code_picker/country_localizations.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'Helper/Session.dart';
import 'Helper/String.dart';

import 'Home.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: lightWhite, // status bar color
  ));
   runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      theme: //AppTheme().lightTheme,

      ThemeData(
          primarySwatch: primary_app,
          cursorColor: primary,
          fontFamily: 'opensans',
          textTheme: TextTheme(
              headline6: TextStyle(
                color: fontColor,
                fontWeight: FontWeight.w600,
              ),
              subtitle1:
                  TextStyle(color: fontColor, fontWeight: FontWeight.bold))),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Splash(),
        '/home': (context) => Home(),
      },
    );
  }
}

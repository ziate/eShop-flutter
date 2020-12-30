
import 'package:country_code_picker/country_localizations.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Helper/PushNotificationService.dart';


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
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
    final pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();
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
      theme:

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

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop/Intro_Slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Home.dart';
import 'main.dart';


//splash screen of app
class Splash extends StatefulWidget {
  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    getJwtKey();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: back(),
            child: Center(
              child: Image.asset(
                'assets/images/splashlogo.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
          Image.asset(
            'assets/images/doodle.png',
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      ),
    );
  }

  startTime() async {
    var _duration = Duration(seconds: 2);
    return Timer(_duration, navigationPage);
  }

  Future<void> navigationPage() async {
    bool isFirstTime = await getPrefrenceBool(ISFIRSTTIME);
    if (isFirstTime) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Intro_Slider(),
          ));
    }
  }



/*  void _registerToken(String token, String uid) async {
    var parameter = {USER_ID: uid, FCM_ID: token};

    Response response =
        await post("$SET_FCM", body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

    // print('Response status: ${response.statusCode}');
    //  print('Response body: ${response.body}***$token_api**$data');

    var getdata = json.decode(response.body);

    print("set token**${response.body.toString()}");
    //var error = getdata['error'].toString();
    // if (error.compareTo('false') == 0) {}
  }*/



/*  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      navigationPage();
    } else {
      setSnackbar(internetMsg);
    }
  }*/

  setSnackbar(String msg) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: black),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> getJwtKey() async {
    Response response = await post(getJwtKeyApi, headers: headers)
        .timeout(Duration(seconds: timeOut));

    print('response***jwtkey*${response.body.toString()}');
    var getdata = json.decode(response.body);

    bool error = getdata["error"];
    String msg = getdata["message"];
    if (!error) {
      var data = getdata["data"];
      jwtKey = data;
      print("jwtkey****$jwtKey");
      startTime();
    } else {
      setSnackbar(msg);
    }
  }
}
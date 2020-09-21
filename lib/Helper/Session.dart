import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Color.dart';
import 'Constant.dart';

final String isLogin = appName + 'isLogin';

setPrefrence(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<String> getPrefrence(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

setPrefrenceBool(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

Future<bool> getPrefrenceBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
}

Future<bool> isNetworkAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

back() {
  return BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryLight2, primaryLight3],
        stops: [0, 1]),
  );
}

placeHolder(double height) {
  return Image.asset(
    'assets/images/placeholder.png',
    fit: BoxFit.fill,
    height: height,
    width: double.maxFinite,
  );
}

errorWidget(double size) {
  return Icon(
    Icons.account_circle,
    color: Colors.grey,
    size: size,
  );
}

getAppBar(String title, BuildContext context) {
  return AppBar(
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios, color: primary),
      onPressed: () => Navigator.of(context).pop(),
    ),
    title: Text(
      title,
      style: TextStyle(
        color: primary,
      ),
    ),
    backgroundColor: Colors.white,
    elevation: 5,
  );
}

imagePlaceHolder(double size) {
  return new Container(
    height: size,
    width: size,
    child: Icon(
      Icons.account_circle,
      color: Colors.grey,
      size: size,
    ),
  );
}

getProgress() {
  return Center(child: CircularProgressIndicator());
}

Widget getNoItem() {
  return Center(child: Text(noItem));
}

String getToken() {
  final key = '6b786a4d37763d7e21426f426d625f32716c414e503647323129502a61';
  final claimSet =
      new JwtClaim(issuer: 'eshop', maxAge: const Duration(minutes: 5));

  String token = issueJwtHS256(claimSet, key);
  print("token***$token");
  return token;
}

Map<String, String> get headers => {
      "Authorization": 'Bearer ' + getToken(),
    };

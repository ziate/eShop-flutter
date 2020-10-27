import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Color.dart';
import 'Constant.dart';
import 'String.dart';

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
    height: height,
    width: height,
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

Widget showCircularProgress(bool _isProgress, Color color) {
  if (_isProgress) {
    return Center(
        child: CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(color),
    ));
  }
  return Container(
    height: 0.0,
    width: 0.0,
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

Future<void> clearUserSession() async {
  final waitList = <Future<void>>[];

  SharedPreferences prefs = await SharedPreferences.getInstance();

  waitList.add(prefs.remove(ID));
  waitList.add(prefs.remove(NAME));
  waitList.add(prefs.remove(MOBILE));
  CUR_USERID = '';
}

Future<void> saveUserDetail(String userId, String name, String email,
    String mobile,String city,String area,
    String address,String pincode,String latitude,
    String longitude,String dob,String image) async {
  final waitList = <Future<void>>[];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  waitList.add(prefs.setString(ID, userId));
  waitList.add(prefs.setString(USERNAME, name));
  waitList.add(prefs.setString(EMAIL, email));
  waitList.add(prefs.setString(MOBILE, mobile));
  waitList.add(prefs.setString(CITY, city));
  waitList.add(prefs.setString(AREA, area));
  waitList.add(prefs.setString(ADDRESS, address));
  waitList.add(prefs.setString(PINCODE, pincode));
  waitList.add(prefs.setString(LATITUDE, latitude));
  waitList.add(prefs.setString(LONGITUDE, longitude));
  waitList.add(prefs.setString(DOB, dob));
  waitList.add(prefs.setString(IMAGE, image));

  await Future.wait(waitList);
}


String validateUserName(String value) {
  if(value.isEmpty)
  {
    return "Username is Required";
  }
  if(value.length<=2)
  {
    return "Username should be 2 character long";
  }
  return null;
}

String validateMob(String value) {
  if(value.isEmpty)
  {
    return "Mobile number required";
  }
  if(value.length <=9)
  {
    return "Please enter valid mobile number";
  }
  return null;
}

String validateCountryCode(String value) {
  if (value.isEmpty) {
    return "Country Code required";
  }
  if (value.length <= 0) {
    return "valid country code";
  }
  return null;
}

String validatePass(String value) {
  if (value.length == 0)
    return "Password is Required";
  else if (value.length <= 5)
    return "Your password should be  more then 6 char long";
  else
    return null;
}

String validateAltMob(String value) {
  if (value.isNotEmpty) if (value.length <= 9) {
    return "Please enter valid mobile number";
  }
  return null;
}

String validateField(String value) {
  if (value.length == 0)
    return "This Field is Required";
  else
    return null;
}

String validatePincode(String value) {
  if (value.length == 0)
    return "Pincode is Required";
  else if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(value))
    return "Please enter valid pincode";
  else
    return null;
}


String validateEmail(String value) {
  if (value.isNotEmpty) {
    if (!RegExp(
        r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)"
        r"*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+"
        r"[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
        .hasMatch(value)) {
      return 'Please enter a valid email Address';
    }
  } else {
    return null;
  }
}


Widget getProgress() {
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

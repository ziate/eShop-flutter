import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

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
        colors: [grad1Color, grad2Color],
        stops: [0, 1]),
  );
}

shadow() {
  return BoxDecoration(
    boxShadow: [
      BoxShadow(color: Color(0x1a0400ff), offset: Offset(0, 0), blurRadius: 30)
    ],
  );
}

placeHolder(double height) {
  return Image.asset(
    'assets/images/placeholder.png',
    height: height,
    width: double.maxFinite,
    fit: BoxFit.fill,
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
    leading: Builder(builder: (BuildContext context) {
      return Container(
        margin: EdgeInsets.all(10),
        decoration: shadow(),
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: InkWell(
              child: Icon(Icons.keyboard_arrow_left, color: primary),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      );
    }),
    title: Text(
      title,
      style: TextStyle(
        color: fontColor,
      ),
    ),
    backgroundColor: white,
    elevation: 5,
  );
}

noIntImage() {
  return Image.asset(
    'assets/images/no_internet.png',
    fit: BoxFit.contain,
  );
}

noIntText(BuildContext context) {
  return Container(
      child: Text(NO_INTERNET,
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(color: primary, fontWeight: FontWeight.normal)));
}

noIntDec(BuildContext context) {
  return Container(
    padding: EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
    child: Text(NO_INTERNET_DISC,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline6.copyWith(
              color: lightBlack2,
              fontWeight: FontWeight.normal,
            )),
  );
}

/*appBtn(String ttl,AnimationController btnCntrl,Animation btnSqeez,Function performFunc) {
 title=ttl;
 btnAnim=btnSqeez;
 btnFunc=performFunc;

  return
    new AnimatedBuilder(
      builder: _buildBtnAnimation,
      animation: btnCntrl,
    );
}


Widget _buildBtnAnimation(BuildContext context, Widget child) {
  return CupertinoButton(
    child: Container(
      width: btnAnim.value,
      height: 45,
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryLight2, primaryLight3],
            stops: [0, 1]),

        borderRadius: new BorderRadius.all(const Radius.circular(50.0)),
      ),
      child: btnAnim.value > 75.0
          ? Text(title,
          textAlign: TextAlign.center,
          style: Theme
              .of(context)
              .textTheme
              .headline6
              .copyWith(color: white, fontWeight: FontWeight.normal))
          : new CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(white),
      ),
    ),

    onPressed: () {
    btnFunc();
    },
  );
}*/

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
      color: white,
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
  CUR_USERNAME = "";
  await prefs.clear();
}

Future<void> saveUserDetail(
    String userId,
    String name,
    String email,
    String mobile,
    // String countrycode,
    String city,
    String area,
    String address,
    String pincode,
    String latitude,
    String longitude,
    String image) async {
  final waitList = <Future<void>>[];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  waitList.add(prefs.setString(ID, userId));
  waitList.add(prefs.setString(USERNAME, name));
  waitList.add(prefs.setString(EMAIL, email));
  waitList.add(prefs.setString(MOBILE, mobile));
  //waitList.add(prefs.setString(COUNTRY_CODE, countrycode));
  waitList.add(prefs.setString(CITY, city));
  waitList.add(prefs.setString(AREA, area));
  waitList.add(prefs.setString(ADDRESS, address));
  waitList.add(prefs.setString(PINCODE, pincode));
  waitList.add(prefs.setString(LATITUDE, latitude));
  waitList.add(prefs.setString(LONGITUDE, longitude));
  waitList.add(prefs.setString(IMAGE, image));

  await Future.wait(waitList);
}

String validateUserName(String value) {
  if (value.isEmpty) {
    return "Username is Required";
  }
  if (value.length <= 1) {
    return "Username should be 2 character long";
  }
  return null;
}

String validateMob(String value) {
  if (value.isEmpty) {
    return "Mobile number required";
  }
  if (value.length <= 9) {
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

String validatePincodeOptional(String value) {
  if (value.isNotEmpty) if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(value))
    return "Please enter valid pincode";
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
  if (value.length == 0) {
    return "Email is Required";
  } else if (!RegExp(
          r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)"
          r"*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+"
          r"[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
      .hasMatch(value)) {
    return 'Please enter a valid email Address';
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

Widget shimmer() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      child: SingleChildScrollView(
        child: Column(
          children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
              .map((_) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80.0,
                          height: 80.0,
                          color: white,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 18.0,
                                color: white,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: double.infinity,
                                height: 8.0,
                                color: white,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: 100.0,
                                height: 8.0,
                                color: white,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: 20.0,
                                height: 8.0,
                                color: white,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    ),
  );
}

String getToken() {
  final claimSet =
      new JwtClaim(issuer: 'eshop', maxAge: const Duration(minutes: 5));
  String token = issueJwtHS256(claimSet, jwtKey);
  print("token***$token");
  return token;
}

Map<String, String> get headers => {
      "Authorization": 'Bearer ' + getToken(),
    };

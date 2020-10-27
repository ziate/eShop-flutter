import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:eshop/Forget_Password.dart';
import 'package:eshop/Helper/String.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eshop/Home.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'SignUp.dart';

class Login extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  String countryName;

  bool _isLoading = false;
  bool _isClickable = true;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool visible = false;
  String password,
      mobile,
      username,
      email,
      id,
      countrycode,
      mobileno,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      dob,
      image;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        _isLoading = true;
      });
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getLoginUser();
    } else {
      setSnackbar(internetMsg);
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  setSnackbar(String msg) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: primary),
      ),
      backgroundColor: Colors.white,
      elevation: 1.0,
    ));
  }

  Future<void> getLoginUser() async {
    var data = {MOBILE: mobile, PASSWORD: password};

    Response response =
        await post(getUserLoginApi, body: data, headers: headers)
            .timeout(Duration(seconds: timeOut));

    print('response***login***${response.body.toString()}');
    var getdata = json.decode(response.body);

    bool error = getdata["error"];
    String msg = getdata["message"];

    if (!error) {
      List data = getdata["data"];

      for (var i in data) {
        id = i[ID];
        username = i[USERNAME];
        email = i[EMAIL];
        mobile = i[MOBILE];
        city = i[CITY];
        area = i[AREA];
        address = i[ADDRESS];
        pincode = i[PINCODE];
        latitude = i[LATITUDE];
        longitude = i[LONGITUDE];
        dob = i[DOB];
        image = i[IMAGE];
      }

      setSnackbar('Login successfully');
      CUR_USERID = id;
      saveUserDetail(id, username, email, mobile, city, area, address, pincode,
          latitude, longitude, dob, image);
      Future.delayed(Duration(seconds: 1)).then((_) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      });
    } else {
      setSnackbar(msg);
    }
    setState(() {
      _isLoading = false;
    });
  }

  subLogo() {
    return Container(
      padding: EdgeInsets.only(top: 150.0),
      child: Center(
        child: new Image.asset('assets/images/sublogo.png', fit: BoxFit.fill),
      ),
    );
  }

  welcomeEshopTxt() {
    return Padding(
        padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: new Text(
            WELCOME_ESHOP,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: lightblack, fontWeight: FontWeight.bold),
          ),
        ));
  }

  eCommerceforBusinessTxt() {
    return Padding(
        padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: new Text(
            ECOMMERCE_APP_FOR_ALL_BUSINESS,
            style: Theme.of(context)
                .textTheme
                .subhead
                .copyWith(color: lightblack2, fontWeight: FontWeight.normal),
          ),
        ));
  }

  setCountryCode() {

    return Padding(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
            height: 45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: darkgrey)),

            child: Stack(
              alignment: Alignment.center,
              children: [
                CountryCodePicker(
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: true,
                  showFlag: true,
                  onInit: (code) {
                    print("on init ${code.name} ${code.dialCode} ${code.name}");
                    countryName = code.name;
                    print("current name:$countryName");
                    countrycode = code.toString().replaceFirst("+", "");
                    print("New Country selected: " + code.toString());
                  },
                  onChanged: (CountryCode countryCode) {
                    countrycode = countryCode.toString().replaceFirst("+", "");
                    print("New Country selected: " + countryCode.toString());
                    countryName = countryCode.name;
                  },

                ),
                 Text(countryName == null ? countryName = "" : countryName)
              ],
            )));
  }

  setMobileNo() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: mobileController,
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        validator: validateMob,
        onSaved: (String value) {
          mobileno = value;
          mobile = countrycode + mobileno;
          print('Mobile no:$mobile');
        },
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.call),
            hintText: MOBILEHINT_LBL,
            contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
      ),
    );
  }

  setPass() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        obscureText: true,
        controller: passwordController,
        validator: validatePass,
        onSaved: (String value) {
          password = value;
        },
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock),
            hintText: PASSHINT_LBL,
            contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
      ),
    );
  }

  forgetPass() {
    return Padding(
        padding:
            EdgeInsets.only(bottom: 10.0, left: 20.0, right: 20.0, top: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                setPrefrence(ID, id);
                setPrefrence(MOBILE, mobile);
                Future.delayed(Duration(seconds: 1)).then((_) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPassWord()));
                });
              },
              child: Text(FORGOT_PASSWORD_LBL,
                  style: Theme.of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: lightblack)),
            ),
          ],
        ));
  }

  loginBtn() {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding:
          EdgeInsets.only(bottom: 10.0, left: 20.0, right: 20.0, top: 20.0),
      child: RaisedButton(
        onPressed: () {
          validateAndSubmit();
        },
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary.withOpacity(0.7), primary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30.0)),
          child: Container(
            constraints:
                BoxConstraints(maxWidth: width * 0.90, minHeight: 50.0),
            alignment: Alignment.center,
            child: Text(
              LOGIN_LBL,
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.headline6.copyWith(color: white),
            ),
          ),
        ),
      ),
    );
  }

  accSignup() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: 30.0, left: 20.0, right: 20.0, top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DONT_HAVE_AN_ACC,
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: lightblack2, fontWeight: FontWeight.normal)),
          InkWell(
              onTap: () {
                Future.delayed(Duration(seconds: 1)).then((_) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignUp()));
                });
              },
              child: Text(
                SIGN_UP_LBL,
                style: Theme.of(context).textTheme.subhead.copyWith(
                    color: primary, decoration: TextDecoration.underline),
              ))
        ],
      ),
    );
  }

  skipBtn() {
    return Padding(
        padding: EdgeInsets.only(top: 40.0, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                Future.delayed(Duration(seconds: 1)).then((_) {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => Home()));
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  SKIP,
                  style: TextStyle(
                      color: Colors.white,
                      decoration: (TextDecoration.underline)),
                ),
              ),
            ),
          ],
        ));
  }

  expandedBottomView() {
    return Expanded(
        flex: 1,
        child: Container(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      margin:
                          EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          welcomeEshopTxt(),
                          eCommerceforBusinessTxt(),
                          setCountryCode(),
                          setMobileNo(),
                          setPass(),
                          forgetPass(),
                          loginBtn(),
                          accSignup(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Form(
            key: _formkey,
            child: Container(
                decoration: back(),
                child: Center(
                    child: Column(
                  children: <Widget>[
                    skipBtn(),
                    subLogo(),
                    expandedBottomView(),
                  ],
                )))));
  }
}

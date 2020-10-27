import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:eshop/Helper/String.dart';

import 'package:eshop/Verify_Otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eshop/Home.dart';
import 'package:http/http.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Login.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpPageState createState() => new _SignUpPageState();
}

class _SignUpPageState extends State<SignUp> {
  bool _showPassword = false;
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String name, email, password, mobile, id, countrycode, mobileno,countryName;
  bool _isLoading = false;
  bool _isClickable = true;



  void validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        _isLoading = true;
      });

      setState(() {
        _isClickable = false;

        Future.delayed(Duration(seconds: 30)).then((_) {
          _isClickable = true;
        });
      });
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getVerifyUser();
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
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 1.0,
    ));
  }

  Future<void> getVerifyUser() async {
    try {
      var data = {
        MOBILE: mobile,
      };
      Response response =
      await post(getVerifyUserApi, body: data, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print('response***verifyuser**$mobile***${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        setSnackbar(msg);

        setPrefrence(NAME, name);
        setPrefrence(PASSWORD, password);
        setPrefrence(MOBILE, mobile);
        setPrefrence(EMAIL, email);

        Future.delayed(Duration(seconds: 1)).then((_) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Verify_Otp(
                    mobileNumber: mobile,
                  )));
        });
      } else {
        setSnackbar(msg);
        _isClickable = true;
      }
      setState(() {
        _isLoading = false;
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isLoading = false;
      });
    }
  }

  subLogo() {
    return Container(
      padding: EdgeInsets.only(top: 100.0),
      child: Center(
        child: new Image.asset('assets/images/sublogo.png', fit: BoxFit.fill),
      ),
    );
  }

  registerTxt() {
    return Padding(
        padding: EdgeInsets.only(top: 25.0),
        child: Center(
          child: new Text(USER_REGISTRATION,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: lightblack)),
        ));
  }

  setUserName() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: nameController,
        validator: validateUserName,
        onSaved: (String value) {
          name = value;
        },
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.person_outline),
            hintText: NAMEHINT_LBL,
            contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
      ),
    );
  }
  setCountryCode() {
    double width = MediaQuery.of(context).size.width/1.5;
    double height = MediaQuery.of(context).size.height;
    return Padding(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
        child:  Container(
            height: height*0.06,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: darkgrey)),
            alignment: Alignment.bottomCenter,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,

                children: [
                  CountryCodePicker(
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    showFlag: true,
                    onInit: (code)
                    {
                      print("on init ${code.name} ${code.dialCode} ${code.name}");
                      countryName=code.name;
                      print("current name:$countryName");
                      countrycode = code.toString().replaceFirst("+", "");
                      print("New Country selected: " + code.toString());
                    },
                    onChanged:(CountryCode countryCode)
                    {
                      countrycode = countryCode.toString().replaceFirst("+", "");
                      print("New Country selected: " + countryCode.toString());
                      countryName=countryCode.name;
                    },
                  ),
                  Text(countryName==null?countryName="":countryName,textAlign: TextAlign.center)
                ]
            ))
    );
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

  setEmail() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        controller: emailController,
        validator: validateEmail,
        onSaved: (String value) {
          email = value;
        },
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.email),
            hintText: EMAILHINT_LBL,
            contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
      ),
    );
  }

  setPass() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        obscureText: !this._showPassword,
        controller: passwordController,
        validator: validatePass,
        onSaved: (val) => password = val,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline),
            hintText: PASSHINT_LBL,
            contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
      ),
    );
  }

  showPass() {
    return Padding(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Checkbox(
              value: _showPassword,
              onChanged: (bool value) {
                setState(() {
                  _showPassword = value;
                });
              },
            ),
            Text(SHOW_PASSWORD,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: lightblack2))
          ],
        ));
  }

  verifyBtn() {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding:
      EdgeInsets.only(bottom: 10.0, left: 20.0, right: 20.0, top: 20.0),
      child: RaisedButton(
        onPressed: () {
          if (_isClickable) validateAndSubmit();
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
            child: Text(VERIFY_MOBILE_NUMBER,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: white)),
          ),
        ),
      ),
    );
  }

  loginTxt() {
    return Padding(
      padding:
      EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(ALREADY_A_CUSTOMER,
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: lightblack)),
          InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => Login(),
                ));
              },
              child: Text(
                LOG_IN_LBL,
                style: Theme.of(context).textTheme.subhead.copyWith(
                    color: primary, decoration: TextDecoration.underline),
              ))
        ],
      ),
    );
  }

  expandedBottomView() {
    double width = MediaQuery.of(context).size.width;
    return Expanded(
        flex: 1,
        child: Container(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    width: width,
                    padding: EdgeInsets.only(top: 50.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      margin: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          registerTxt(),
                          setUserName(),
                          setCountryCode(),
                          setMobileNo(),
                          setEmail(),
                          setPass(),
                          showPass(),
                          verifyBtn(),
                          loginTxt(),
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
        body: WillPopScope(
            onWillPop: () => Future.value(false),
            child: Form(
                key: _formkey,
                child: Container(
                    decoration: back(),
                    child: Center(
                        child: Column(
                          children: <Widget>[
                            subLogo(),
                            expandedBottomView(),
                          ],
                        ))))));
  }
}
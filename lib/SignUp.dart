import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:eshop/Helper/String.dart';

import 'package:eshop/Verify_Otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart';

import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Login.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpPageState createState() => new _SignUpPageState();
}

class _SignUpPageState extends State<SignUp> with TickerProviderStateMixin {
  bool _showPassword = false;
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String name, email, password, mobile, id, countrycode, countryName;

  Animation buttonSqueezeanimation;

  AnimationController buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      /* setState(() {
        _isLoading = true;
      });*/
      _playAnimation();
      checkNetwork();
    }
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getVerifyUser();
    } else {
      setSnackbar(internetMsg);
      /* setState(() {
        _isLoading = false;
      });*/
      await buttonController.reverse();
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState;
    form.save();
    if (form.validate()) {
      print("validated**********");

      return true;
    }
    print("not validated**********");
    return false;
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
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
        EMAIL:email
      };
      Response response =
          await post(getVerifyUserApi, body: data, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print('response***verifyuser**$mobile***${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      await buttonController.reverse();
      if (!error) {
        setSnackbar(msg);

        setPrefrence(NAME, name);
        setPrefrence(PASSWORD, password);
        setPrefrence(MOBILE, mobile);
        setPrefrence(EMAIL, email);
        setPrefrence(COUNTRY_CODE, countrycode);

        Future.delayed(Duration(seconds: 1)).then((_) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Verify_Otp(
                      mobileNumber: mobile, countryCode: countrycode)));
        });
      } else {
        setSnackbar(msg);
      }
      /*  setState(() {
        _isLoading = false;
      });*/
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      /* setState(() {
        _isLoading = false;
      });*/
      await buttonController.reverse();
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
      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
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
            prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(7.0))),
      ),
    );
  }

  setCountryCode() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height * 0.9;
    return Padding(
        padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
        child: Container(
          width: width,
          height: 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.0),
              border: Border.all(color: darkgrey)),
          child: CountryCodePicker(
              showCountryOnly: false,
              searchDecoration: InputDecoration(
                hintText: COUNTRY_CODE_LBL,
                fillColor: primary,
              ),
              showOnlyCountryWhenClosed: false,
              initialSelection: 'IN',
              dialogSize: Size(width, height),
              alignLeft: true,
              builder: _buildCountryPicker,
              onChanged: (CountryCode countryCode) {
                countrycode = countryCode.toString().replaceFirst("+", "");
                print("New Country selected: " + countryCode.toString());
                countryName = countryCode.name;
              },
              onInit: (code) {
                print("on init ${code.name} ${code.dialCode} ${code.name}");
                countrycode = code.toString().replaceFirst("+", "");
                print("New Country selected: " + code.toString());
              }),
        ));
  }

  Widget _buildCountryPicker(CountryCode country) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Flexible(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: new Image.asset(
                country.flagUri,
                package: 'country_code_picker',
                height: 40,
                width: 20,
              ),
            ),
          ),
          new Flexible(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: new Text(country.dialCode),
            ),
          ),
          new Flexible(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: new Text(
                country.name,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );

  setMobileNo() {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: mobileController,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: validateMob,
        onSaved: (String value) {
          // mobileno = value;
          mobile = value;
          print('Mobile no:$mobile');
        },
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.call_outlined),
            hintText: MOBILEHINT_LBL,
            prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(7.0))),
      ),
    );
  }

  setEmail() {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        controller: emailController,
        validator: validateEmail,
        onSaved: (String value) {
          email = value;
        },
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.email_outlined),
            hintText: EMAILHINT_LBL,
            prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(7.0))),
      ),
    );
  }

  setPass() {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        obscureText: !this._showPassword,
        controller: passwordController,
        validator: validatePass,
        onSaved: (val) => password = val,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline),
            hintText: PASSHINT_LBL,
            prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(7.0))),
      ),
    );
  }

  showPass() {
    return Padding(
        padding: EdgeInsets.only(
          left: 30.0,
          right: 30.0,
        ),
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
                    .bodyText1
                    .copyWith(color: lightblack2))
          ],
        ));
  }
  verifyBtn() {
    return
      new AnimatedBuilder(
        builder: _buildBtnAnimation,
        animation: buttonSqueezeanimation,
      );
  }


  Widget _buildBtnAnimation(BuildContext context, Widget child) {
    return CupertinoButton(
      child: Container(
        width: buttonSqueezeanimation.value,
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
        child: buttonSqueezeanimation.value > 75.0
            ? Text(VERIFY_MOBILE_NUMBER,
            textAlign: TextAlign.center,
            style: Theme
                .of(context)
                .textTheme
                .headline6
                .copyWith(color: white, fontWeight: FontWeight.normal))
            : new CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),

      onPressed: () {
        validateAndSubmit();
      },
    );
  }
 /* verifyBtn() {
    double width = MediaQuery.of(context).size.width;
    return Padding(
        padding:
            EdgeInsets.only(bottom: 10.0, left: 30.0, right: 30.0, top: 10.0),
        child: Center(
            child: RaisedButton(
          color: primaryLight2,
          onPressed: () {
            validateAndSubmit();
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
          padding: EdgeInsets.all(0.0),
          child: Ink(
            child: Container(
              constraints: BoxConstraints(maxWidth: width * 1.5, minHeight: 45),
              alignment: Alignment.center,
              child: Text(VERIFY_MOBILE_NUMBER,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: white, fontWeight: FontWeight.normal)),
            ),
          ),
        )));
  }*/

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
                  .bodyText1
                  .copyWith(color: lightblack)),
          InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => Login(),
                ));
              },
              child: Text(
                LOG_IN_LBL,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: primary, decoration: TextDecoration.underline),
              ))
        ],
      ),
    );
  }

  expandedBottomView() {
    double width = MediaQuery.of(context).size.width;
    return Expanded(
        child: Container(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    width: width,
                    padding: EdgeInsets.only(top: 20.0),
                    child: Form(
                      key: _formkey,
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
                            //appBtn(VERIFY_MOBILE_NUMBER, buttonController, buttonSqueezeanimation, validateAndSubmit),
                            loginTxt(),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )));
  }

  @override
  void initState() {
    super.initState();
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
            decoration: back(),
            child: Center(
                child: Column(
              children: <Widget>[
                subLogo(),
                expandedBottomView(),
              ],
            ))));
  }
}

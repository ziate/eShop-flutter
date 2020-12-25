import 'dart:async';
import 'dart:io';
import 'package:eshop/Helper/String.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart';

import 'Helper/AppBtn.dart';
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
  String name,
      email,
      password,
      mobile,
      id,
      countrycode,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude;
  FocusNode nameFocus, emailFocus, passFocus = FocusNode();
  bool _isNetworkAvail = true;
  Animation buttonSqueezeanimation;

  AnimationController buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  getUserDetails() async {
    mobile = await getPrefrence(MOBILE);
    countrycode = await getPrefrence(COUNTRY_CODE);
    setState(() {});
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getRegisterUser();
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        setState(() {
          _isNetworkAvail = false;
        });
        await buttonController.reverse();
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  setSnackbar(String msg) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: fontColor),
      ),
      backgroundColor: lightWhite,
      elevation: 1.0,
    ));
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: kToolbarHeight),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: TRY_AGAIN_INT_LBL,
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController.reverse();
                  setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  Future<void> getRegisterUser() async {
    try {
      var data = {
        MOBILE: mobile,
        NAME: name,
        EMAIL: email,
        PASSWORD: password,
        COUNTRY_CODE: countrycode
      };
      Response response =
          await post(getUserSignUpApi, body: data, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      bool error = getdata["error"];
      String msg = getdata["message"];
      await buttonController.reverse();
      if (!error) {
        setSnackbar(REGISTER_SUCCESS_MSG);
        var i = getdata["data"][0];

        id = i[ID];
        name = i[USERNAME];
        email = i[EMAIL];
        mobile = i[MOBILE];
        //countrycode=i[COUNTRY_CODE];
        CUR_USERID = id;
        CUR_USERNAME = name;
        saveUserDetail(id, name, email, mobile, city, area, address, pincode,
            latitude, longitude, "");

        Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
      } else {
        setSnackbar(msg);
      }
      setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      await buttonController.reverse();
    }
  }

  subLogo() {
    return Expanded(
      flex: 3,
      child: Center(
        child: new Image.asset('assets/images/homelogo.png'),
      ),
    );
  }

  registerTxt() {
    return Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Center(
          child: new Text(USER_REGISTRATION_DETAILS,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: fontColor, fontWeight: FontWeight.bold)),
        ));
  }

  setUserName() {
    return Padding(
      padding: EdgeInsets.only(
        top: 30.0,
        left: 25.0,
        right: 25.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
        controller: nameController,
        focusNode: nameFocus,
        textInputAction: TextInputAction.next,
        style: TextStyle(color: fontColor, fontWeight: FontWeight.normal),
        validator: validateUserName,
        onSaved: (String value) {
          name = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, nameFocus, emailFocus);
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.person_outline,
            color: fontColor,
            size: 17,
          ),
          hintText: NAMEHINT_LBL,
          hintStyle: Theme.of(this.context)
              .textTheme
              .subtitle2
              .copyWith(color: fontColor, fontWeight: FontWeight.normal),
          filled: true,
          fillColor: lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 25),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightWhite),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setEmail() {
    return Padding(
      padding: EdgeInsets.only(
        top: 10.0,
        left: 25.0,
        right: 25.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        focusNode: emailFocus,
        textInputAction: TextInputAction.next,
        controller: emailController,
        style: TextStyle(color: fontColor, fontWeight: FontWeight.normal),
        validator: validateEmail,
        onSaved: (String value) {
          email = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, emailFocus, passFocus);
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.email_outlined,
            color: fontColor,
            size: 17,
          ),
          hintText: EMAILHINT_LBL,
          hintStyle: Theme.of(this.context)
              .textTheme
              .subtitle2
              .copyWith(color: fontColor, fontWeight: FontWeight.normal),
          filled: true,
          fillColor: lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 25),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightWhite),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setPass() {
    return Padding(
        padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          obscureText: !this._showPassword,
          focusNode: passFocus,
          style: TextStyle(color: fontColor, fontWeight: FontWeight.normal),
          controller: passwordController,
          validator: validatePass,
          onSaved: (String value) {
            password = value;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock_outline,
              color: fontColor,
              size: 17,
            ),
            hintText: PASSHINT_LBL,
            hintStyle: Theme.of(this.context)
                .textTheme
                .subtitle2
                .copyWith(color: fontColor, fontWeight: FontWeight.normal),
            filled: true,
            fillColor: lightWhite,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 25),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: fontColor),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lightWhite),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ));
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
              checkColor: fontColor,
              activeColor: lightWhite,
              onChanged: (bool value) {
                setState(() {
                  _showPassword = value;
                });
              },
            ),
            Text(SHOW_PASSWORD,
                style:
                    TextStyle(color: fontColor, fontWeight: FontWeight.normal))
          ],
        ));
  }

  verifyBtn() {
    return AppBtn(
      title: VERIFY_MOBILE_NUMBER,
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        validateAndSubmit();
      },
    );
  }

  loginTxt() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: 30.0, left: 25.0, right: 25.0, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(ALREADY_A_CUSTOMER,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(color: fontColor, fontWeight: FontWeight.normal)),
          InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => Login(),
                ));
              },
              child: Text(
                LOG_IN_LBL,
                style: Theme.of(context).textTheme.caption.copyWith(
                    color: fontColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal),
              ))
        ],
      ),
    );
  }

  backBtn() {
    return Platform.isIOS
        ? Container(
            padding: EdgeInsets.only(top: 20.0, left: 10.0),
            alignment: Alignment.topLeft,
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: InkWell(
                  child: Icon(Icons.keyboard_arrow_left, color: primary),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ))
        : Container();
  }

  expandedBottomView() {

    return Expanded(
      flex: 7,
        child: Container(
      alignment: Alignment.bottomCenter,
      child: SingleChildScrollView(
       // physics: BouncingScrollPhysics(),

        child: Form(
          key: _formkey,
          child: Card(
            elevation: 0.5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                registerTxt(),
                setUserName(),
                setEmail(),
                setPass(),
                showPass(),
                verifyBtn(),
                loginTxt(),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
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
        body: _isNetworkAvail
            ? Container(
                color: lightWhite,
                padding: EdgeInsets.only(
                  bottom: 20.0,
                ),
                child: Column(
                  children: <Widget>[
                    backBtn(),
                    subLogo(),
                    expandedBottomView(),
                  ],
                ))
            : noInternet(context));
  }
}

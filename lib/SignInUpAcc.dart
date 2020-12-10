import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eshop/Home.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'SendOtp.dart';
import 'SignUp.dart';

class SignInUpAcc extends StatefulWidget {
  @override
  _SignInUpAccState createState() => new _SignInUpAccState();
}

class _SignInUpAccState extends State<SignInUpAcc>
  {


  _subLogo() {
    return Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Image.asset('assets/images/homelogo.png', fit: BoxFit.fill));
  }

  welcomeEshopTxt() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: new Text(
        WELCOME_ESHOP,
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(color: fontColor,fontWeight: FontWeight.bold),
      ),
    );
  }

  eCommerceforBusinessTxt() {
    return Padding(
      padding: EdgeInsets.only(
        top: 5.0,
      ),
      child: new Text(
        ECOMMERCE_APP_FOR_ALL_BUSINESS,
        style: Theme.of(context).textTheme.subtitle2.copyWith(color: fontColor,fontWeight: FontWeight.normal),
      ),
    );
  }

  signInyourAccTxt() {
    return Padding(
      padding: EdgeInsets.only(top: 80.0,bottom: 40),
      child: new Text(
        SIGNIN_ACC_LBL,
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(color: fontColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  signInBtn() {
    return
      CupertinoButton(
        child: Container(
            width: deviceWidth * 0.8,
            height: 45,
            alignment: FractionalOffset.center,
            decoration: new BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [grad1Color, grad2Color],
                  stops: [0, 1]),
              borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
            ),
            child: Text(SIGNIN_LBL,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: white, fontWeight: FontWeight.normal))),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => Login()));
        },
      );


  }

  createAccBtn() {

    return
      CupertinoButton(
        child: Container(
            width: deviceWidth * 0.8,
            height: 45,
            alignment: FractionalOffset.center,
            decoration: new BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [grad1Color, grad2Color],
                  stops: [0, 1]),
              borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
            ),
            child: Text(CREATE_ACC_LBL,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: white, fontWeight: FontWeight.normal))),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => SendOtp(title:SEND_OTP_TITLE,),
          ));
        },
      );

  }

  skipSignInBtn() {


     return
      CupertinoButton(
        child: Container(
            width: deviceWidth * 0.8,
            height: 45,
            alignment: FractionalOffset.center,
            decoration: new BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [grad1Color, grad2Color],
                  stops: [0, 1]),
              borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
            ),
            child: Text(SKIP_SIGNIN_LBL,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: white, fontWeight: FontWeight.normal))),
        onPressed: () {
          Navigator.pushReplacementNamed(context, "/home");
        },
      );


  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: lightWhite,
        child: Center(
            child: SingleChildScrollView(
                child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _subLogo(),
            welcomeEshopTxt(),
            eCommerceforBusinessTxt(),
            signInyourAccTxt(),
            signInBtn(),
            createAccBtn(),
            skipSignInBtn(),
          ],
        ))));
  }
}

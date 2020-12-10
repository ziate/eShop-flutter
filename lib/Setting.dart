import 'dart:async';
import 'dart:convert';

import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Privacy_Policy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Constant.dart';
import 'Helper/String.dart';
import 'NotificationLIst.dart';

class Setting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateSetting();
}

class StateSetting extends State<Setting> with TickerProviderStateMixin {
  TextEditingController curPassC, newPassC, confPassC;
  String curPass, newPass, confPass, mobile;
  bool _showPassword = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _isNetworkAvail = true;
  bool _isRight = false;
  Animation buttonSqueezeanimation;

  AnimationController buttonController;

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



  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
  }


  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      setUpdateUser();
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
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

  Future<void> setUpdateUser() async {
    var data = {
      USER_ID: CUR_USERID,OLDPASS:curPass,NEWPASS:newPass
    };

    Response response =
    await post(getUpdateUserApi, body: data, headers: headers)
        .timeout(Duration(seconds: timeOut));

    var getdata = json.decode(response.body);

    print('response***UpdateUser**$headers***${response.body.toString()}');
    bool error = getdata["error"];
    String msg = getdata["message"];
    await buttonController.reverse();
    if (!error) {
      setSnackbar(USER_UPDATE_MSG);
    } else {
      setSnackbar(msg);
    }
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

  changePass() {
    return Container(
        height: 45.0,
        margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: Card(
            elevation: 3,
            child: InkWell(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 7.0),
                      child: Text(CHANGE_PASS_LBL,
                          style: TextStyle(
                            color: lightBlack,
                            fontSize: 15,
                          ))),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: primary,
                    size: 20,
                  ),
                ],
              ),
              onTap: () {
                _showDialog();
              },
            )));
  }

  changeLangauge() {
    return Container(
        height: 45.0,
        margin: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Card(
            elevation: 3,
            child: InkWell(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 7.0),
                      child: Text(CHANGE_LANGUAUE_LBL,
                          style: TextStyle(
                            color: lightBlack,
                            fontSize: 15,
                          ))),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: primary,
                    size: 20,
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationList(),
                    ));
              },
            )));
  }

  changeTheme() {
    return Container(
        height: 45.0,
        margin: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Card(
            elevation: 3,
            child: InkWell(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 7.0),
                      child: Text(CHANGE_THEME_LBL,
                          style: TextStyle(
                            color: lightBlack,
                            fontSize: 15,
                          ))),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: primary,
                    size: 20,
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationList(),
                    ));
              },
            )));
  }

  privacyPolicy() {
    return Container(
        height: 45.0,
        margin: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Card(
            elevation: 3,
            child: InkWell(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 7.0),
                      child: Text(PRIVACY,
                          style: TextStyle(
                            color: lightBlack,
                            fontSize: 15,
                          ))),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: primary,
                    size: 20,
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Privacy_Policy(
                        title: PRIVACY,
                      ),
                    ));
              },
            )));
  }

  termCondition() {
    return Container(
        height: 45.0,
        margin: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Card(
            elevation: 3,
            child: InkWell(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 7.0),
                      child: Text(TERM,
                          style: TextStyle(
                            color: lightBlack,
                            fontSize: 15,
                          ))),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: primary,
                    size: 20,
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Privacy_Policy(
                        title: TERM,
                      ),
                    ));
              },
            )));
  }

  _showDialog() async {
    await showDialog(
        context: context,
        child: new AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          title: Center(
              child: Text(
                CHANGE_PASS_LBL,
                style: Theme.of(this.context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: fontColor),
              )),
          elevation: 2.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                  key: _formkey,
                  child: new Column(
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.text,
                        validator: validatePass,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          hintText: CUR_PASS_LBL,
                          hintStyle: Theme.of(this.context)
                              .textTheme
                              .subtitle1
                              .copyWith(
                              color: lightBlack,
                              fontWeight: FontWeight.normal),
                        ),
                        //obscureText: _showPassword,
                        controller: curPassC,
                        onChanged: (v) => setState(() {
                          curPass = v;
                        }),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        validator: validatePass,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: new InputDecoration(
                          hintText: NEW_PASS_LBL,
                          hintStyle: Theme.of(this.context)
                              .textTheme
                              .subtitle1
                              .copyWith(
                              color: lightBlack,
                              fontWeight: FontWeight.normal),
                        ),
                        controller: newPassC,
                        onChanged: (v) => setState(() {
                          newPass = v;
                        }),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value.length == 0) return CON_PASS_REQUIRED_MSG;
                          if (value != newPass) {
                            return CON_PASS_NOT_MATCH_MSG;
                          } else {
                            return null;
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: new InputDecoration(
                          hintText: CONFIRMPASSHINT_LBL,
                          hintStyle: Theme.of(this.context)
                              .textTheme
                              .subtitle1
                              .copyWith(
                              color: lightBlack,
                              fontWeight: FontWeight.normal),
                        ),
                        controller: confPassC,
                        onChanged: (v) => setState(() {
                          confPass = v;
                        }),
                      ),
                    ],
                  ))),
          actions: <Widget>[
            new FlatButton(
                child: Text(
                  CANCEL,
                  style: Theme.of(this.context)
                      .textTheme
                      .subtitle2
                      .copyWith(color: lightBlack, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            new FlatButton(
                child: Text(
                  SAVE_LBL,
                  style: Theme.of(this.context)
                      .textTheme
                      .subtitle2
                      .copyWith(color: fontColor, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  final form = _formkey.currentState;
                  if (form.validate()) {
                    form.save();
                    setState(() {
                      Navigator.pop(context);
                    });
                    checkNetwork();
                  }
                })
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: getAppBar(SETTING, context),
      body: _isNetworkAvail
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          changePass(),
          changeLangauge(),
          changeTheme(),
          privacyPolicy(),
          termCondition(),
        ],
      )
          : noInternet(context),
    );
  }
}

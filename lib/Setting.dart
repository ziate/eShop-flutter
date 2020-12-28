import 'dart:async';
import 'dart:convert';

import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Privacy_Policy.dart';

import 'package:eshop/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Constant.dart';
import 'Helper/String.dart';


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
  int selectedIndex;
  List<String> themeList = [SYSTEM_DEFAULT, LIGHT_THEME, DARK_THEME];
  List<String> languageList = [
    ENGLISH_LAN,
    CHINESE_LAN,
    SPANISH_LAN,
    HINDI_LAN,
    ARABIC_LAN,
    RUSSIAN_LAN,
    JAPANISE_LAN,
    GERMAN_LAN
  ];


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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getSavedTheme();
    });
  }

  _getSavedTheme() async {
    selectedIndex =
        themeList.indexOf(await getPrefrence(APP_THEME) ?? SYSTEM_DEFAULT);
    setState(() {});
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
    var data = {USER_ID: CUR_USERID, OLDPASS: curPass, NEWPASS: newPass};

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
        margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: Card(
            elevation: 0,
            shadowColor: lightWhite,


            child: InkWell(
              borderRadius:  BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        CHANGE_PASS_LBL,
                        style: Theme.of(this.context)
                            .textTheme
                            .subtitle2
                            .copyWith(
                            color: lightBlack, fontWeight: FontWeight.bold),
                      )),
                  Spacer(),
                  Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        color: primary,
                      )),
                ],
              ),
              onTap: () {
                _showDialog();
              },
            )));
  }

  changeLangauge() {
    return Container(
        margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 3.0),
        child: Card(
            elevation: 0,
            shadowColor: lightWhite,

            child: InkWell(
                borderRadius:  BorderRadius.circular(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          CHANGE_LANGUAUE_LBL,
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                              color: lightBlack,
                              fontWeight: FontWeight.bold),
                        )),
                    Spacer(),
                    Padding(
                        padding: EdgeInsets.only(right: 15.0),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: primary,
                        )),
                  ],
                ),
                onTap: () {
                  languageDialog();
                })));
  }

  changeTheme() {
    return Container(
        margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 3.0),
        child: Card(
            elevation: 0,
            shadowColor: lightWhite,

            child: InkWell(
                borderRadius:  BorderRadius.circular(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          CHANGE_THEME_LBL,
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                              color: lightBlack,
                              fontWeight: FontWeight.bold),
                        )),
                    Spacer(),
                    Padding(
                        padding: EdgeInsets.only(right: 15.0),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: primary,
                        )),
                  ],
                ),
                onTap: () {
                  themeDialog();
                })));
  }






  privacyPolicy() {
    return Container(
        margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 3.0),
        child: Card(
            elevation: 0,
            shadowColor: lightWhite,

            child: InkWell(
              borderRadius:  BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(PRIVACY,
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                              color: lightBlack,
                              fontWeight: FontWeight.bold))),
                  Spacer(),
                  Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        color: primary,
                      )),
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
        margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 3.0),
        child: Card(

            elevation: 0,
            shadowColor: lightWhite,

            child: InkWell(
              borderRadius:  BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(TERM,
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                              color: lightBlack,
                              fontWeight: FontWeight.bold))),
                  Spacer(),
                  Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        color: primary,
                      )),
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

  themeDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
                return AlertDialog(
                  contentPadding: const EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                          child: Text(
                            CHOOSE_THEME_LBL,
                            style: Theme.of(this.context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: fontColor),
                          )),
                      Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 0.0, 0, 2.0),
                          child: Text(
                            COMINGSOON,
                            style: Theme.of(context).textTheme.caption,
                          )),
                      Divider(color: lightBlack),
                      ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              Padding(
                                  padding:
                                  EdgeInsets.only(left: 20.0, right: 20.0),
                                  child: Divider(color: lightBlack)),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: themeList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                                padding:
                                EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {

                                      },
                                      child: Container(
                                        height: 25.0,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selectedIndex == index
                                                ? grad2Color
                                                : white,
                                            border:
                                            Border.all(color: grad2Color)),
                                        child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: selectedIndex == index
                                                ? Icon(
                                              Icons.check,
                                              size: 17.0,
                                              color: white,
                                            )
                                                : Icon(
                                              Icons
                                                  .check_box_outline_blank,
                                              size: 15.0,
                                              color: white,
                                            )),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(
                                          left: 15.0,
                                        ),
                                        child: Text(
                                          themeList[index],
                                          style: Theme.of(this.context)
                                              .textTheme
                                              .subtitle1
                                              .copyWith(color: lightBlack),
                                        ))
                                  ],
                                ));
                          }),
                      Padding(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Divider(color: lightBlack)),
                    ],
                  ),
                  actions: <Widget>[
                    new FlatButton(
                        child: Text(
                          CANCEL,
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                              color: lightBlack, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    new FlatButton(
                        child: Text(
                          OK_LBL,
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                              color: fontColor, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {

                          Navigator.pop(context);
                        })
                  ],
                );
              });
        });
  }






  languageDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
                return AlertDialog(
                  contentPadding: const EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  content: SingleChildScrollView(

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                              child: Text(
                                CHOOSE_LANGUAGE_LB,
                                style: Theme.of(this.context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(color: fontColor),
                              )),
                          Padding(
                              padding: EdgeInsets.fromLTRB(20.0, 0.0, 0, 2.0),
                              child: Text(
                                COMINGSOON,
                                style: Theme.of(context).textTheme.caption,
                              )),
                          Divider(color: lightBlack),
                    Container(

                    height: 400,child:
                          ListView.separated(
                              separatorBuilder: (BuildContext context, int index) =>
                                  Padding(
                                      padding:
                                      EdgeInsets.only(left: 20.0, right: 20.0),
                                      child: Divider(color: lightBlack)),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: languageList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                    padding:
                                    EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setStater(() {
                                              selectedIndex = index;
                                            });
                                          },
                                          child: Container(
                                            height: 25.0,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: selectedIndex == index
                                                    ? grad2Color
                                                    : white,
                                                border:
                                                Border.all(color: grad2Color)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: selectedIndex == index
                                                  ? Icon(
                                                Icons.check,
                                                size: 17.0,
                                                color: white,
                                              )
                                                  : Icon(
                                                Icons.check_box_outline_blank,
                                                size: 15.0,
                                                color: white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(
                                              left: 15.0,
                                            ),
                                            child: Text(
                                              languageList[index],
                                              style: Theme.of(this.context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(color: lightBlack),
                                            ))
                                      ],
                                    ));
                              })),
                          Padding(
                              padding: EdgeInsets.only(left: 20.0, right: 20.0),
                              child: Divider(color: lightBlack)),
                        ],
                      )),
                  actions: <Widget>[
                    new FlatButton(
                        child: Text(
                          CANCEL,
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                              color: lightBlack, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    new FlatButton(
                        child: Text(
                          OK_LBL,
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                              color: fontColor, fontWeight: FontWeight.bold),
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
                );
              });
        });
  }

  _showDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
                return AlertDialog(
                  contentPadding: const EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  content: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                                padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                                child: Text(
                                  CHANGE_PASS_LBL,
                                  style: Theme.of(this.context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(color: fontColor),
                                )),
                            Divider(color: lightBlack),
                            Form(
                                key: _formkey,
                                child: new Column(
                                  children: <Widget>[
                                    Padding(
                                        padding:
                                        EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          validator: validatePass,
                                          autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                              hintText: CUR_PASS_LBL,
                                              hintStyle: Theme.of(this.context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                  color: lightBlack,
                                                  fontWeight:
                                                  FontWeight.normal),
                                              suffixIcon: IconButton(
                                                icon: Icon(_showPassword
                                                    ? Icons.visibility
                                                    : Icons.visibility_off),
                                                iconSize: 20,
                                                color: lightBlack,
                                                onPressed: () {
                                                  setStater(() {
                                                    _showPassword = !_showPassword;
                                                  });
                                                },
                                              )),
                                          obscureText: !_showPassword,
                                          controller: curPassC,
                                          onChanged: (v) => setState(() {
                                            curPass = v;
                                          }),
                                        )),
                                    Padding(
                                        padding:
                                        EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          validator: validatePass,
                                          autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                          decoration: new InputDecoration(
                                              hintText: NEW_PASS_LBL,
                                              hintStyle: Theme.of(this.context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                  color: lightBlack,
                                                  fontWeight:
                                                  FontWeight.normal),
                                              suffixIcon: IconButton(
                                                icon: Icon(_showPassword
                                                    ? Icons.visibility
                                                    : Icons.visibility_off),
                                                iconSize: 20,
                                                color: lightBlack,
                                                onPressed: () {
                                                  setStater(() {
                                                    _showPassword = !_showPassword;
                                                  });
                                                },
                                              )),
                                          obscureText: !_showPassword,
                                          controller: newPassC,
                                          onChanged: (v) => setState(() {
                                            newPass = v;
                                          }),
                                        )),
                                    Padding(
                                        padding:
                                        EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          validator: (value) {
                                            if (value.length == 0)
                                              return CON_PASS_REQUIRED_MSG;
                                            if (value != newPass) {
                                              return CON_PASS_NOT_MATCH_MSG;
                                            } else {
                                              return null;
                                            }
                                          },
                                          autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                          decoration: new InputDecoration(
                                              hintText: CONFIRMPASSHINT_LBL,
                                              hintStyle: Theme.of(this.context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                  color: lightBlack,
                                                  fontWeight:
                                                  FontWeight.normal),
                                              suffixIcon: IconButton(
                                                icon: Icon(_showPassword
                                                    ? Icons.visibility
                                                    : Icons.visibility_off),
                                                iconSize: 20,
                                                color: lightBlack,
                                                onPressed: () {
                                                  setStater(() {
                                                    _showPassword = !_showPassword;
                                                  });
                                                },
                                              )),
                                          obscureText: !_showPassword,
                                          controller: confPassC,
                                          onChanged: (v) => setState(() {
                                            confPass = v;
                                          }),
                                        )),
                                  ],
                                ))
                          ])),
                  actions: <Widget>[
                    new FlatButton(
                        child: Text(
                          CANCEL,
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                              color: lightBlack, fontWeight: FontWeight.bold),
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
                              .copyWith(
                              color: fontColor, fontWeight: FontWeight.bold),
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
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: lightWhite,
      appBar: getAppBar(SETTING, context),
      body: _isNetworkAvail
          ? SingleChildScrollView(
            child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
            changePass(),
            changeLangauge(),
            changeTheme(),
            privacyPolicy(),
            termCondition(),
        ],
      ),
          )
          : noInternet(context),
    );
  }
}

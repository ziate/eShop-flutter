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

class _LoginPageState extends State<Login> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  String countryName;

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
      image;
  Animation buttonSqueezeanimation;

  AnimationController buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getLoginUser();
    } else {
      setSnackbar(internetMsg);
      await buttonController.reverse();
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

    print('response***login*${data.toString()}**${response.body.toString()}');
    var getdata = json.decode(response.body);

    bool error = getdata["error"];
    String msg = getdata["message"];
    await buttonController.reverse();
    if (!error) {
      var i = getdata["data"][0];

      //   for (var i in data) {
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

      image = i[IMAGE];
      //}
      setSnackbar('Login successfully');
      CUR_USERID = id;
      saveUserDetail(id, username, email, mobile, city, area, address, pincode,
          latitude, longitude, image);
      Future.delayed(Duration(seconds: 1)).then((_) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      });
    } else {
      setSnackbar(msg);
    }
    /*setState(() {
      _isLoading = false;
    });*/
  }

  _subLogo() {
    return Container(
      padding: EdgeInsets.only(top: 80.0),
      child: Center(
        child: new Image.asset('assets/images/sublogo.png', fit: BoxFit.fill),
      ),
    );
  }

  welcomeEshopTxt() {
    return Padding(
        padding: EdgeInsets.only(top: 50.0, left: 30.0, right: 30.0),
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
        padding: EdgeInsets.only(top: 10.0, left: 30.0, right: 30.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: new Text(
            ECOMMERCE_APP_FOR_ALL_BUSINESS,
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(color: lightblack2),
          ),
        ));
  }

  setCountryCode() {
    double height = MediaQuery.of(context).size.height * 0.9;
    double width = MediaQuery.of(context).size.width;
    return Padding(
        padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
              alignLeft: true,
              dialogSize: Size(width, height),
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
          child: new Text(
            country.dialCode,
            style: TextStyle(fontSize: 12),
          ),
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
          mobileno = value;
          mobile = mobileno;
          print('Mobile no:$mobile');
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.call_outlined,
            ),
            hintText: MOBILEHINT_LBL,
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
        obscureText: true,
        controller: passwordController,
        validator: validatePass,
        onSaved: (String value) {
          password = value;
        },
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

  forgetPass() {
    return Padding(
        padding:
        EdgeInsets.only(bottom: 10.0, left: 30.0, right: 30.0, top: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                setPrefrence(ID, id);
                setPrefrence(MOBILE, mobile);

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPassWord()));

              },
              child: Text(FORGOT_PASSWORD_LBL,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: lightblack)),
            ),
          ],
        ));
  }

  accSignup() {
    return Padding(
      padding:
      EdgeInsets.only(bottom: 30.0, left: 30.0, right: 30.0, top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DONT_HAVE_AN_ACC,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: lightblack2, fontWeight: FontWeight.normal)),
          InkWell(
              onTap: () {

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignUp()));

              },
              child: Text(
                SIGN_UP_LBL,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: primary, decoration: TextDecoration.underline),
              ))
        ],
      ),
    );
  }

  _skipBtn() {
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
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: white, decoration: TextDecoration.underline),
                ),
              ),
            ),
          ],
        ));
  }

  _expandedBottomView() {
    return Expanded(
        child: Container(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 10.0, bottom: 20),
                    child: Form(
                      key: _formkey,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        margin:
                        EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
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
                            //  appBtn(LOGIN_LBL, buttonController, buttonSqueezeanimation, validateAndSubmit),
                            accSignup(),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )));
  }
  loginBtn() {
    return
      new AnimatedBuilder(
        builder: _buildBtnAnimation,
        animation: buttonController,
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
            ? Text(LOGIN_LBL,
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
  void dispose() {
    buttonController.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
            height: height,
            width: width,
            decoration: back(),
            child: Center(
                child: Column(
                  children: <Widget>[
                    _skipBtn(),
                    _subLogo(),
                    _expandedBottomView(),
                  ],
                ))));
  }
}

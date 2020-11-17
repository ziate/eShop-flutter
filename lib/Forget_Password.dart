import 'dart:async';
import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:eshop/Set_Pass_By_Otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eshop/Home.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';

class ForgotPassWord extends StatefulWidget {
  @override
  _ForgetPassPageState createState() => new _ForgetPassPageState();
}

class _ForgetPassPageState extends State<ForgotPassWord> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isCodeSent = false;
  String mobile, name, email, id, otp,  countrycode, countryName;
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  //bool _isLoading = false;
  bool _isClickable = true;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;



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
  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
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
  void validateAndSubmit() async {
    if (validateAndSave()) {
     /* setState(() {
        _isLoading = true;
      });*/

      setState(() {
        _isClickable = false;

        Future.delayed(Duration(seconds: 30)).then((_) {
          _isClickable = true;
        });
      });
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
      await buttonController.reverse();
    /*  setState(() {
        _isLoading = false;
      });*/
    }
  }



  getPwdBtn() {
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
            ? Text(GET_PASSWORD,
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

  bool validateAndSave() {
    final form = _formkey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  bool resetAndClear() {
    _formkey.currentState.reset();
    mobileController.clear();
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
      print('response***verifyuser**$headers***${response.body.toString()}');
      bool error = getdata["error"];
      await buttonController.reverse();
      if (error) {
        setPrefrence(MOBILE, mobile);

          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => Set_Pass_By_Otp(
              mobileNumber: mobile,
              countrycode: countrycode,
            ),
          ));

      } else {
        setSnackbar(
            "Please first Sign Up! Your mobile number is not resgister");
        _isClickable = true;
      }
     /* setState(() {
        _isLoading = false;
      });*/
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
   /*   setState(() {
        _isLoading = false;
      });*/
      await buttonController.reverse();
    }
  }

  imageView() {
    return Container(
      padding: EdgeInsets.only(top: 200.0),
      child: Center(
        child: new Image.asset('assets/images/sublogo.png', width: 200),
      ),
    );
  }

  forgotPassTxt() {
    return Padding(
        padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Center(
          child: new Text(
            FORGOT_PASSWORDTITILE,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: lightblack, fontWeight: FontWeight.bold),
          ),
        ));
  }

  setCountryCode() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
        padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
        child: Container(
          width: width,
          height: 49,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
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
                height: 35,
                width: 30,
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
      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: mobileController,
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        validator: validateMob,
        onSaved: (String value) {
          //mobileno = value;
          mobile =  value;
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

 /* getPassBtn() {
    double width = MediaQuery.of(context).size.width;
    return Padding(
        padding:
            EdgeInsets.only(bottom: 30.0, left: 30.0, right: 30.0, top: 30.0),
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
              //decoration: back(),
              alignment: Alignment.center,
              child: Text(GET_PASSWORD,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: white, fontWeight: FontWeight.normal)),
            ),
          ),
        )));
  }*/

  expandedBottomView() {
    return Expanded(
        child: Container(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 100.0),
                    child: Form(
                      key: _formkey,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        margin: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            forgotPassTxt(),
                            setCountryCode(),
                            setMobileNo(),
                            getPwdBtn(),
                          ],
                        ),
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
        body: Container(
            decoration: back(),
            child: Center(
                child: Column(
              children: <Widget>[
                imageView(),
                expandedBottomView(),
              ],
            ))));
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:eshop/Forget_Password.dart';
import 'package:eshop/Helper/String.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eshop/Home.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Model/User.dart';
import 'SignUp.dart';

class Login extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<Login> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isClickable = true;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool visible = false;
  String password, mobile, username, email, id,countrycode,mobileno,city,area,pincode,address;



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
        id=i[ID];
        username=i[USERNAME];
        email=i[EMAIL];
        mobile=i[MOBILE];
        city=i[CITY];
        area=i[AREA];
        address=i[ADDRESS];
        pincode=i[PINCODE];
      }


      setSnackbar('Login successfully');
      CUR_USERID=id;
      saveUserDetail(id, username, email, mobile, city, area, address, pincode);

      /*setPrefrence(ID, id);
      setPrefrence(USERNAME, username);
      setPrefrence(MOBILE, mobile);
      setPrefrence(EMAIL, email);
      setPrefrence(CITY, city);
      setPrefrence(AREA, area);
      setPrefrence(ADDRESS, address);
      setPrefrence(PINCODE, pincode);*/


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

  String validateMob(String value) {
    if (value.isEmpty) {
      return "Mobile number required";
    }
    if (value.length < 10) {
      return "Please enter valid mobile number";
    }
    return null;
  }

  String validatepass(String value) {
    if (value.length == 0)
      return "Password is Required";
    else if (value.length <= 4)
      return "Your password should be more then 6 char long";
    else
      return null;
  }

  subLogo()
  {
    return Container(
      padding: EdgeInsets.only(top: 150.0),
      child: Center(
        child: new Image.asset('assets/images/sublogo.png',
            fit: BoxFit.fill),
      ),
    );
  }



  welcomeEshopTxt()
  {
    return Container(
        padding: EdgeInsets.only(top: 50.0,
            left: 20.0,
            right: 20.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: new Text(WELCOME_ESHOP,
            style:
            Theme.of(context).textTheme.headline6.copyWith(color: lightblack,fontWeight: FontWeight.bold),),
        ));
  }

  eCommerceforBusinessTxt()
  {
    return Container(
        padding: EdgeInsets.only(top: 10.0,
            left: 20.0,
            right: 20.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: new Text(
            ECOMMERCE_APP_FOR_ALL_BUSINESS,
            style:
            Theme.of(context).textTheme.subhead.copyWith(color: lightblack2,fontWeight: FontWeight.normal),),
        ));
  }

  setMobileNo()
  {
    double width = MediaQuery.of(context).size.width ;
    return Container(
      width: width,
      padding: EdgeInsets.only(left: 20.0,right: 20.0,top:30.0),
      child:Center(
        child: Row(
            children: [
              Container(
                  width: width/6,
                  child:TextFormField(
                    keyboardType: TextInputType.number,
                    controller:ccodeController,
                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                    validator:validateCountryCode,
                    onSaved: (String value) {
                      countrycode = value;
                    },
                    decoration: InputDecoration(
                        hintText: '+',
                        contentPadding:
                        EdgeInsets.only(left: 20.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)

                        )
                    ),
                  )
              ),

              Expanded(
                child:TextFormField(
                  keyboardType: TextInputType.number,
                  controller:mobileController,
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  validator:validateMob,
                  onSaved: (String value) {
                    mobileno = value;
                    mobile=countrycode+mobileno;
                    print('Mobile no:$mobile');
                  },

                  decoration: InputDecoration(
                      hintText: 'Mobile number',
                      contentPadding:
                      EdgeInsets.fromLTRB(10.0, 10.0,10.0,10.0),

                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)

                      )
                  ),
                ),
              )]
        ),
      ),
    );
  }

  setPass()
  {
    return Container(
      padding: EdgeInsets.only(left: 20.0,
          right: 20.0,
          top: 20.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        obscureText: true,
        controller: passwordController,
        validator: validatePass,
        onSaved: (String value) {
          password = value;
        },
        decoration: InputDecoration(
            hintText: 'Password',
            contentPadding:
            EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    10.0)
            )
        ),
      ),
    );
  }

  forgetPass()
  {
    return Container(
        padding: EdgeInsets.only(bottom: 10.0,
            left: 20.0,
            right: 20.0,
            top: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                setPrefrence(ID,id);
                setPrefrence(MOBILE, mobile);
                Navigator.of(context)
                    .push(MaterialPageRoute(
                  builder: (BuildContext context) => ForgotPassWord(),
                ));

              },
              child: Text(
                  FORGOT_PASSWORD,
                  style:
                  Theme.of(context).textTheme.subhead.copyWith(color: lightblack,fontWeight: FontWeight.bold)
              ),
            ),
          ],));
  }

  loginBtn()
  {
    double width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(bottom: 10.0,
          left: 20.0,
          right: 20.0,
          top: 20.0),
      child: RaisedButton(
        onPressed: () {

          validateAndSubmit();



        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary.withOpacity(0.7),primary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30.0)
          ),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: width * 0.90,
                minHeight: 50.0),
            alignment: Alignment.center,
            child: Text(
              LOGIN,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6.copyWith(color: white,fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ),
    );

  }

  accSignup()
  {
    return Container(
      padding: EdgeInsets.only(bottom: 30.0,
          left: 20.0,
          right: 20.0,
          top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              DONT_HAVE_AN_ACC,
              style: Theme.of(context).textTheme.subhead.copyWith(color: lightblack2,fontWeight: FontWeight.normal)),
          InkWell(
              onTap: () {

                Navigator.of(context)
                    .push(MaterialPageRoute(
                  builder: (BuildContext context) => SignUp(),
                ));

              },
              child: Text(
                SIGN_UP,
                style: Theme.of(context).textTheme.subhead.copyWith(color: primary,
                    fontWeight:FontWeight.bold,decoration: TextDecoration.underline),
              )
          )
        ],
      ),
    );
  }

  skipBtn()
  {
    return Container(
        padding: EdgeInsets.only(top: 40.0,right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Home()),
                );

              },
              child: Text(
                SKIP,
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
            ),
          ],));

  }

  expandedBottomView()
  {
    return Expanded(
        flex:1,
        child:Container(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      margin: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          welcomeEshopTxt(),
                          eCommerceforBusinessTxt(),
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


            )


        )
    );
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

import 'dart:async';
import 'dart:convert';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eshop/Home.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_html/style.dart';
import 'package:http/http.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Login.dart';

class Verify_Otp extends StatefulWidget {
  final String mobileNumber;

  Verify_Otp({
    Key key,
    @required this.mobileNumber,
  })  : assert(mobileNumber != null),
        super(key: key);

  @override
  _MobileOTPState createState() => new _MobileOTPState();
}

class _MobileOTPState extends State<Verify_Otp> {
  final dataKey = new GlobalKey();
  String password, mobile,username,email,id,city,area,pincode,address,mobileno,countrycode,name;
  String otp;
  bool isCodeSent = false;
  String _verificationId;
  bool _isLoading = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUserDetails();
    _onVerifyCode();
  }

  getUserDetails() async {
    mobile = await getPrefrence(MOBILE);
    name = await getPrefrence(NAME);
    email = await getPrefrence(EMAIL);
    password = await getPrefrence(PASSWORD);
    setState(() {});
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

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getRegisterUser();
    } else {
      setSnackbar(internetMsg);
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> getRegisterUser() async {
    try {


      print("data****$mobile***$name****$email***$password");
      var data = {MOBILE: mobile, NAME: name, EMAIL: email, PASSWORD: password};
      Response response =
      await post(getUserSignUpApi, body: data, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print('response***registeruser**$headers***${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        setSnackbar("User Registered Successfully");
        List data = getdata["data"];

        for (var i in data) {
          id=i[ID];
          name=i[USERNAME];
          email=i[EMAIL];
          mobile=i[MOBILE];
          city=i[CITY];
          area=i[AREA];
          address=i[ADDRESS];
          pincode=i[PINCODE];
        }
        CUR_USERID=id;
        saveUserDetail(id, name, email, mobile, city, area, address, pincode);
        /*setPrefrence(ID, id);
        setPrefrence(USERNAME, name);
        setPrefrence(MOBILE, mobile);
        setPrefrence(EMAIL, email);
        setPrefrence(CITY, city);
        setPrefrence(AREA, area);
        setPrefrence(ADDRESS, address);
        setPrefrence(PINCODE, pincode);*/
        Future.delayed(Duration(seconds: 1)).then((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Home()),
          );
        });
      } else {
        setSnackbar(msg);
      }
      setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }

  void _onVerifyCode() async {
    setState(() {
      isCodeSent = true;
    });

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _firebaseAuth
          .signInWithCredential(phoneAuthCredential)
          .then((AuthResult value) {
        if (value.user != null) {
          checkNetwork();

        } else {
          setSnackbar("Error validating OTP, try again");
        }
      }).catchError((error) {
        setSnackbar("Try again in sometime");
      });
    };
    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setSnackbar(authException.message);
      print(authException.message);
      setState(() {
        isCodeSent = false;
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+${widget.mobileNumber}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() async {
    final code = otp.trim();
    AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: code);

    _firebaseAuth
        .signInWithCredential(_authCredential)
        .then((AuthResult value) {
      if (value.user != null) {
        checkNetwork();
      } else {
        setSnackbar("Error validating OTP, try again");
      }
    }).catchError((error) {
      setSnackbar("Something went wrong");
    });
  }

  getImage() {
    return Container(
      padding: EdgeInsets.only(top: 100.0),
      child: Center(
        child: new Image.asset('assets/images/sublogo.png', width: 200),
      ),
    );
  }

  monoVarifyText() {
    return Container(
        padding: EdgeInsets.only(top: 70.0, left: 20.0, right: 20.0),
        child: Center(
          child: new Text(
              MOBILE_NUMBER_VARIFICATION,
              style: Theme.of(context).textTheme.headline6.copyWith(color: lightblack,fontWeight: FontWeight.bold)
          ),
        ));
  }

  otpText() {
    return Container(
        padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Align(
          alignment: Alignment.center,
          child: new Text(
              ENTER_YOUR_OTP_SENT_TO,
              style: Theme.of(context).textTheme.headline6.copyWith(color: lightblack,fontWeight: FontWeight.normal)
          ),
        ));
  }

  mobText() {
    return Container(
      padding:
      EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("+$mobile",
              style: Theme.of(context).textTheme.headline6.copyWith(color: lightblack,fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  otpLayout() {
    return Container(
        padding: EdgeInsets.only(left: 80.0, right: 80.0, top: 30.0),
        child: Center(
          child: PinFieldAutoFill(
              codeLength: 6,
              currentCode: otp,
              onCodeChanged: (String code) {
                otp = code;
              },
              onCodeSubmitted: (String code) {
                otp = code;

              }
          ),

        ));
  }

  verifyBtn() {
    double width = MediaQuery.of(context).size.width;

    return Container(
      padding:
      EdgeInsets.only(bottom: 10.0, left: 20.0, right: 20.0, top: 60.0),
      child: RaisedButton(
        onPressed: () {
          if (otp.length == 6) {
            _onFormSubmitted();
          } else {
            setSnackbar("Invalid OTP");
          }
        },
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlue, Colors.blue],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30.0)),
          child: Container(
            constraints:
            BoxConstraints(maxWidth: width * 0.90, minHeight: 50.0),
            alignment: Alignment.center,
            child: Text(
                VERIFY_AND_PROCEED,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6.copyWith(color: white,fontWeight: FontWeight.normal)
            ),
          ),
        ),
      ),
    );
  }

  resendText() {
    return Container(
      padding:
      EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0, top: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DIDNT_GET_THE_CODE,
            style:Theme.of(context).textTheme.subhead.copyWith(color: lightblack2,
                fontWeight: FontWeight.normal),),
          InkWell(
              onTap: () {
                _onVerifyCode();
              },
              child: Text(
                RESEND_OTP,
                style: Theme.of(context).textTheme.subhead.copyWith(color: primary,
                    fontWeight: FontWeight.bold,decoration: TextDecoration.underline),
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
                          monoVarifyText(),
                          otpText(),
                          mobText(),
                          otpLayout(),
                          verifyBtn(),
                          resendText(),
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
        body:  Container(
            decoration: back(),
            child: Center(
              child: Column(
                children: <Widget>[
                  getImage(),
                  expandedBottomView(),
                ],
              ),
            )));
  }
}
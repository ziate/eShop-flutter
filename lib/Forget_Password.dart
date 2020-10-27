import 'dart:async';
import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:eshop/Set_Pass_By_Otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class _ForgetPassPageState extends State<ForgotPassWord> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isCodeSent = false;
  String _verificationId,mobile,name,email,id,otp,mobileno,countrycode;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  bool _isLoading = false;
  bool _isClickable = true;



  void _onCountryChange(CountryCode countryCode) {
    countrycode=  countryCode.toString().replaceFirst("+", "");
    print("New Country selected: " + countryCode.toString());
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

  bool resetAndClear()
  {
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

      if (error)
      {
        setPrefrence(MOBILE, mobile);
        Future.delayed(Duration(seconds: 1)).then((_) {
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (BuildContext context) => Set_Pass_By_Otp(mobileNumber: mobile,),
          ));
        });

      } else {
        setSnackbar("Please first Sign Up! Your mobile number is not resgister");
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

  imageView()
  {
    return Container(
      padding: EdgeInsets.only(top: 150.0),
      child: Center(
        child:
        new Image.asset('assets/images/sublogo.png', width: 200),
      ),
    );
  }

  forgotPassTxt()
  {
    return Padding(
        padding: EdgeInsets.only(
            top: 70.0, left: 20.0, right: 20.0),
        child: Center(
          child: new Text(
            FORGOT_PASSWORDTITILE,
            style: Theme.of(context).textTheme.headline6.copyWith(color: lightblack,
                fontWeight: FontWeight.bold),
          ),
        ));
  }

  setMob()
  {
    return Padding(
      padding: EdgeInsets.only(left: 20.0,right: 20.0,top:15.0),
      child: Row(
            children: [
              Container(
                decoration:BoxDecoration(borderRadius:BorderRadius.circular(10.0),border:Border.all(color:darkgrey) ),
                child: CountryCodePicker(
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  onChanged: _onCountryChange,
                ),

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
                      hintText: MOBILEHINT_LBL,
                      contentPadding:
                      EdgeInsets.fromLTRB(10.0, 10.0,10.0,10.0),

                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)

                      )
                  ),
                ),
              )]
        ),
    );
  }

  getPassBtn() {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(bottom: 30.0,
          left: 20.0,
          right: 20.0,
          top: 40.0),
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
                colors: [primary.withOpacity(0.7), primary],
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
              GET_PASSWORD,

              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6.copyWith(color: white,
                  fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ),
    );
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
                          forgotPassTxt(),
                          setMob(),
                          getPassBtn(),

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
        body:Form(
            key: _formkey,
            child: Container(
                decoration: back(),
                child: Center(

                    child:Column(
                      children: <Widget>[

                        imageView(),
                        expandedBottomView(),


                      ],
                    )
                )
            )
        )
    );
  }
}




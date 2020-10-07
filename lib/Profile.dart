import 'dart:async';
import 'dart:convert';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Model/User.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateProfile();
  }
}

class StateProfile extends State<Profile> {


  String name,email,mobile,city,area,pincode,address;
  bool _isLoading = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<User> cityList = [];
  List<User> areaList = [];
  TextEditingController nameC,emailC,mobileC,pincodeC,addressC;




  @override
  void initState() {

    super.initState();
    mobileC = new TextEditingController();
    nameC = new TextEditingController();
    emailC = new TextEditingController();
    pincodeC = new TextEditingController();
    addressC=new TextEditingController();
    getUserDetails();
    callApi();
  }

  @override
  void dispose(){
    mobileC?.dispose();
    nameC?.dispose();
    emailC?.dispose();
    addressC.dispose();
    pincodeC?.dispose();
    super.dispose();
  }

  Future<void> callApi() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getCities();
      getArea();

    } else {
      setSnackbar(internetMsg);
      setState(() {
        _isLoading = false;
      });
    }
  }

  getUserDetails() async {

    CUR_USERID=await getPrefrence(ID);
    mobile = await getPrefrence(MOBILE);
    name = await getPrefrence(USERNAME);
    email = await getPrefrence(EMAIL);
    city = await getPrefrence(CITY);
    area = await getPrefrence(AREA);
    pincode = await getPrefrence(PINCODE);
    address = await getPrefrence(ADDRESS);

    mobileC.text=mobile;
    nameC.text=name;
    emailC.text=email;
    pincodeC.text=pincode;
    addressC.text=address;



    setState(() {});
  }




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
      setUpdateUser();

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
        style: TextStyle(color:primary),
      ),
      backgroundColor: Colors.white,
      elevation: 1.0,
    ));
  }

  Future<void> getCities() async {

    try {
      Response response = await post(getCitiesApi, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print('response***Cities**$headers***${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        cityList = (data as List).map((data) => new User.fromJson(data)).toList();




      } else {
        setSnackbar(msg);
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

  Future<void> getArea() async {
    print("selectedcityforarea:$city");
    try {
      var data = {
        ID: city,
      };

      Response response =
      await post(getAreaByCityApi, body: data, headers: headers)
          .timeout(Duration(seconds: timeOut));

      print('response***Area**$headers***${response.body.toString()}');
      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];


      if (!error) {
        var data = getdata["data"];

        areaList =
            (data as List).map((data) => new User.fromJson(data)).toList();
      }
      else {
        setSnackbar(msg);
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

  Future<void> setUpdateUser() async {

    try {

      var data = {
        USER_ID:CUR_USERID,USERNAME:name,MOBILE: mobile,EMAIL: email,PINCODE:pincode,CITY:city,AREA:area,ADDRESS:address
      };
      Response response =
      await post(getUpdateUserApi, body: data, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print('response***UpdateUser**$headers***${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        setSnackbar("User Update Successfully");
        print("City:$city,Area:$area");

        saveUserDetail(CUR_USERID, name, email, mobile, city, area, address, pincode);


        /*setPrefrence(ID, CUR_USERID);
        setPrefrence(USERNAME, name);
        setPrefrence(MOBILE, mobile);
        setPrefrence(EMAIL, email);
        setPrefrence(CITY, city);
        setPrefrence(AREA, area);
        setPrefrence(ADDRESS, address);
        setPrefrence(PINCODE, pincode);*/

      } else {
        setSnackbar(msg);
      }
      setState(() { _isLoading = false;});
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }


  Future<void> addAddress() async {

    try {

      var data = {
        USER_ID:CUR_USERID,USERNAME:name,MOBILE: mobile,EMAIL: email,PINCODE:pincode,CITY:city,AREA:area
      };
      Response response =
      await post(getAddAddressApi, body: data, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print('response***AddAddress**$headers***${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {

      } else {
        setSnackbar(msg);
      }
      setState(() { _isLoading = false;});
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }




  setUserName()
  {
    double width = MediaQuery.of(context).size.width ;
    return Container(
      width: width,
      padding: EdgeInsets.only(left: 20.0,right: 20.0,top: 40.0),
      child:Center(
        child: TextFormField(
          keyboardType: TextInputType.text,
          controller: nameC,
          style: Theme.of(context).textTheme.subhead.copyWith(color: darkgrey,fontWeight: FontWeight.bold),
          validator:validateUserName,
          onChanged:  (v)=>setState((){
            name=v;
          }),
          onSaved: (String value) {
            name= value;
          },
          decoration: InputDecoration(
            hintText: "First Name",
            hintStyle: Theme.of(context).textTheme.subhead.copyWith(color: darkgrey,fontWeight: FontWeight.bold),
            filled: true,
            fillColor: Colors.white,
            contentPadding:new EdgeInsets.only(right: 30.0,left: 30.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }

  setMobileNo()
  {


    double width = MediaQuery.of(context).size.width ;
    return Container(
      width: width,
      padding: EdgeInsets.only(left: 20.0,right: 20.0,top:20.0),
      child:Center(
        child: TextFormField(
          keyboardType: TextInputType.number,
          controller: mobileC,
          style: Theme.of(context).textTheme.subhead.copyWith(color: darkgrey,fontWeight: FontWeight.bold),
          onChanged:  (v)=>setState((){
            mobile=v;
          }),
          onSaved: (String value) {
            mobile= value;
          },
          decoration: InputDecoration(
            hintText: "Mobile number",
            hintStyle: Theme.of(context).textTheme.subhead.copyWith(color: darkgrey,fontWeight: FontWeight.bold),
            filled: true,
            fillColor: Colors.white,
            contentPadding:new EdgeInsets.only(right: 30.0,left: 30.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }

  setEmail()
  {

    double width = MediaQuery.of(context).size.width ;
    return Container(
      width: width,
      padding: EdgeInsets.only(left: 20.0,right: 20.0,top:20.0),
      child:Center(
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: emailC,
          style: Theme.of(context).textTheme.subhead.copyWith(color: darkgrey,fontWeight: FontWeight.bold),
          validator: validateEmail,
          onChanged:  (v)=>setState((){
            email=v;
          }),
          onSaved: (String value) {
            email= value;
          },
          decoration: InputDecoration(
            hintText: "Email Address",
            hintStyle: Theme.of(context).textTheme.subhead.copyWith(color: darkgrey,fontWeight: FontWeight.bold),
            filled: true,
            fillColor: Colors.white,
            contentPadding:new EdgeInsets.only(right: 30.0,left: 30.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }

  setCities()
  {

    double width = MediaQuery.of(context).size.width ;

    return Container(
        width: width,
        padding: EdgeInsets.only(left: 20.0,right: 20.0,top:20.0),
        child:Center(
          child:DropdownButtonFormField(
            iconSize: 40,
            iconEnabledColor: darkgrey,
            isDense: true,
            hint: new Text("Select City",style:Theme.of(context).textTheme.subhead.copyWith(color: darkgrey,fontWeight: FontWeight.bold),),
            value: city,
            onChanged: (String newValue) {
              setState(() {
                city= newValue;
              });
              print (city);
              getArea();
            },
            items: cityList.map((User user) {
              return DropdownMenuItem<String>(
                value: user.id,
                child: Text(
                  user.name,
                  style: Theme.of(context).textTheme.subhead.copyWith(color: darkgrey,fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding:new EdgeInsets.only(right: 30.0,left: 30.0),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        )
    );
  }


  setArea()
  {

    //getArea();
    double width = MediaQuery.of(context).size.width ;
    return Container(
        width: width,
        padding: EdgeInsets.only(left: 20.0,right: 20.0,top:20.0),
        child:Center(
          child:DropdownButtonFormField(
            iconSize: 40,
            iconEnabledColor: darkgrey,
            isDense: true,
            hint: new Text("Select Area",style:Theme.of(context).textTheme.subhead.copyWith(color: darkgrey,fontWeight: FontWeight.bold),),
            value: area,
            onChanged: (String newValue) {
              setState(() {
                area= newValue;
              });
              print (area);
            },
            items: areaList.map((User user) {
              return DropdownMenuItem<String>(
                value: user.id,
                child: Text(
                  user.name,
                  style: Theme.of(context).textTheme.subhead.copyWith(color: darkgrey,fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding:new EdgeInsets.only(right: 30.0,left: 30.0),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        )
    );
  }

  setAddress()
  {
    double width = MediaQuery.of(context).size.width ;
    return Container(
      width: width,
      padding: EdgeInsets.only(left: 20.0,right: 20.0,top:20.0),
      child:Center(
        child: TextFormField(
          keyboardType: TextInputType.text,
          controller: addressC,
          style: Theme.of(context).textTheme.subhead.copyWith(color: darkgrey,fontWeight: FontWeight.bold),
          onChanged:  (v)=>setState((){
            address=v;
          }),
          onSaved: (String value) {
            address= value;
          },
          decoration: InputDecoration(
            hintText: "Address",
            hintStyle: Theme.of(context).textTheme.subhead.copyWith(color: darkgrey,fontWeight: FontWeight.bold),
            filled: true,
            fillColor: Colors.white,
            contentPadding:new EdgeInsets.only(right: 30.0,left: 30.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }

  setPincode()
  {
    double width = MediaQuery.of(context).size.width ;
    return Container(
      width: width,
      padding: EdgeInsets.only(left: 20.0,right: 20.0,top:20.0,bottom: 30),
      child:Center(
        child: TextFormField(
          keyboardType: TextInputType.number,
          controller: pincodeC,
          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
          style:Theme.of(context).textTheme.subhead.copyWith(color: darkgrey,fontWeight: FontWeight.bold),
          validator: validatePincode,
          onChanged:  (v)=>setState((){
            pincode=v;
          }),
          onSaved: (String value) {
            pincode= value;
          },
          decoration: InputDecoration(
            hintText: "Pincode",
            hintStyle: Theme.of(context).textTheme.subhead.copyWith(color: darkgrey,fontWeight: FontWeight.bold),
            filled: true,
            fillColor: Colors.white,
            contentPadding:new EdgeInsets.only(right: 30.0,left: 30.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }

  profileImage()
  {
    return Container(
      padding: EdgeInsets.only(left: 20.0,right: 20.0,top:30.0),
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 50,
            child: ClipOval(child: Image.asset('assets/images/homelogo.png', fit: BoxFit.fill,),),
          ),
        ],
      ),
    );

  }


  updatebtn()
  {
    double width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(bottom: 50.0,
          left: 20.0,
          right: 20.0,
          top: 20.0),
      child: RaisedButton(
        onPressed: () {
          //setUpdateUser();
          setState(() {
            validateAndSubmit();
          });
          //getUserDetails();

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
              UPDATE_PROFILE,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6.copyWith(color: white,),
            ),
          ),
        ),
      ),
    );
  }

  profileView()
  {
    return Expanded(
        flex:1,
        child:Container(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[

                  setUserName(),
                  setEmail(),
                  setMobileNo(),
                  setCities(),
                  setArea(),
                  setAddress(),
                  setPincode(),
                  updatebtn(),

                ],
              ),


            )


        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(PROFILE, context),
        key: _scaffoldKey,
        backgroundColor: lightgrey,
        body: Form(
            key: _formkey,
            child: Column(
              children: <Widget>[
                profileImage(),
                profileView(),
              ],
            )
        ));
  }
}
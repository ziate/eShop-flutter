import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Model/User.dart';
import 'package:eshop/Map.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Constant.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateProfile();
}

String lat, long;

class StateProfile extends State<Profile> with TickerProviderStateMixin {

  String name,
      email,
      mobile,
      city,
      area,
      pincode,
      address,
      image;
  List<User> cityList = [];
  List<User> areaList = [];
  bool _isLoading = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController nameC, emailC, mobileC, pincodeC, addressC;
  bool isDateSelected = false;
  DateTime birthDate;
  bool isSelected = false;
  bool _isNetworkAvail = true;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;

  @override
  void initState() {
    super.initState();

    mobileC = new TextEditingController();
    nameC = new TextEditingController();
    emailC = new TextEditingController();
    pincodeC = new TextEditingController();
    addressC = new TextEditingController();
    getUserDetails();
    callApi();
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
    mobileC?.dispose();
    nameC?.dispose();
    addressC.dispose();
    pincodeC?.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  getUserDetails() async {
    CUR_USERID = await getPrefrence(ID);
    mobile = await getPrefrence(MOBILE);
   // countrycode = await getPrefrence(COUNTRY_CODE);
    name = await getPrefrence(USERNAME);
    email = await getPrefrence(EMAIL);
    city = await getPrefrence(CITY);
    area = await getPrefrence(AREA);
    pincode = await getPrefrence(PINCODE);
    address = await getPrefrence(ADDRESS);

    image = await getPrefrence(IMAGE);


    mobileC.text = mobile;
    nameC.text = name;
    emailC.text = email;
    pincodeC.text = pincode;
    addressC.text = address;
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
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

  Future<void> callApi() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getCities();
      if (city != null && city != "") {
        getArea();
      }
    } else {

      setState(() {
        _isNetworkAvail = false;
        _isLoading = false;
      });
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      setUpdateUser();
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {

        await buttonController.reverse();
        setState(() {
          _isNetworkAvail = false;
        });
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

  Future<void> setProfilePic(File _image) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      setState(() {
        _isLoading = true;
      });
      try {
        var request =
        http.MultipartRequest("POST", Uri.parse(getUpdateUserApi));
        request.headers.addAll(headers);
        request.fields[USER_ID] = CUR_USERID;
        var pic = await http.MultipartFile.fromPath(IMAGE, _image.path);
        request.files.add(pic);

        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);

        print("profile====$responseString*****${_image.path}");

        var getdata = json.decode(responseString);
        bool error = getdata["error"];
        String msg = getdata['message'];
        if (!error) {
          setSnackbar('Profile Picture updated successfully');
          List data = getdata["data"];
          for (var i in data) {
            image = i[IMAGE];
          }
          setPrefrence(IMAGE, image);
          print("current image:*****$image");
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
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Future<void> setUpdateUser() async {
    var data = {USER_ID: CUR_USERID, USERNAME: name, EMAIL: email};
    if (city != null && city != "") {
      data[CITY] = city;
    }
    if (area != null && area != "") {
      data[AREA] = area;
    }
    if (address != null && address != "") {
      data[ADDRESS] = address;
    }
    if (pincode != null && pincode != "") {
      data[PINCODE] = pincode;
    }

    if (lat != null && lat != "") {
      data[LATITUDE] = lat;
    }
    if (long != null && long != "") {
      data[LONGITUDE] = long;
    }

    http.Response response = await http
        .post(getUpdateUserApi, body: data, headers: headers)
        .timeout(Duration(seconds: timeOut));

    var getdata = json.decode(response.body);

    print('response***UpdateUser**$headers***${response.body.toString()}');
    bool error = getdata["error"];
    String msg = getdata["message"];
    await buttonController.reverse();
    if (!error) {
      setSnackbar("User Update Successfully");
      var i = getdata["data"][0];


      CUR_USERID = i[ID];
      name = i[USERNAME];
      email = i[EMAIL];
      mobile = i[MOBILE];
      city = i[CITY];
      area = i[AREA];
      address = i[ADDRESS];
      pincode = i[PINCODE];
      lat = i[LATITUDE];
      long = i[LONGITUDE];



      print("City:$city,Area:$area,image:$image");
      saveUserDetail(CUR_USERID, name, email, mobile,city, area,
          address, pincode, lat, long,  image);
    } else {
      setSnackbar(msg);
    }
  }

  _imgFromGallery() async {
    File image = await FilePicker.getFile(type: FileType.image);

    if(image!=null)
    {

      print('path**${image.path}');
      setState(() {
        _isLoading = true;
      });
      setProfilePic(image);
    }
  }



  Future<void> getCities() async {
    print("city:$city,area:$area");
    print("image:$image");
    try {
      var response = await http.post(getCitiesApi, headers: headers)
          .timeout(Duration(seconds: timeOut));


      var getdata = json.decode(response.body);
      print('response***Cities**$headers***${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        cityList =
            (data as List).map((data) => new User.fromJson(data)).toList();
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
    print("image:$image");
    try {
      var data = {
        ID: city,
      };

      var response =
      await http.post(getAreaByCityApi, body: data, headers: headers)
          .timeout(Duration(seconds: timeOut));

      print('response***Area****${response.body.toString()}');
      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];

      if (!error) {
        var data = getdata["data"];

        areaList =
            (data as List).map((data) => new User.fromJson(data)).toList();
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

  setSnackbar(String msg) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: primary),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  setUserName() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: nameC,
        style: Theme
            .of(this.context)
            .textTheme
            .subtitle1
            .copyWith(color: fontColor),
        validator: validateUserName,
        onChanged: (v) =>
            setState(() {
              name = v;
            }),
        onSaved: (String value) {
          name = value;
        },
        decoration: InputDecoration(
          hintText: NAMEHINT_LBL,
          hintStyle:
          Theme
              .of(this.context)
              .textTheme
              .subtitle1
              .copyWith(color: lightBlack),
          filled: true,
          fillColor: white,
          contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: white),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: white),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setMobileNo() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: Center(
        child: TextFormField(
          keyboardType: TextInputType.number,
          controller: mobileC,
          readOnly: true,
          style: Theme
              .of(this.context)
              .textTheme
              .subtitle1
              .copyWith(color: fontColor),
          decoration: InputDecoration(
            hintText: MOBILEHINT_LBL,
            hintStyle:
            Theme
                .of(this.context)
                .textTheme
                .subtitle1
                .copyWith(color: lightBlack),
            filled: true,
            fillColor: white,
            contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: white),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: white),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }

  setEmail() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: Center(
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: emailC,
          style: Theme
              .of(this.context)
              .textTheme
              .subtitle1
              .copyWith(color: fontColor),
          validator: validateEmail,
          onChanged: (v) =>
              setState(() {
                email = v;
              }),
          onSaved: (String value) {
            email = value;
          },
          decoration: InputDecoration(
            hintText: EMAILHINT_LBL,
            hintStyle:
            Theme
                .of(this.context)
                .textTheme
                .subtitle1
                .copyWith(color: lightBlack),
            filled: true,
            fillColor: white,
            contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: white),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: white),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }

  setCities() {
    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: DropdownButtonFormField(
        iconSize: 40,
        isDense: true,
        iconEnabledColor: fontColor,
        hint: new Text(
          CITYSELECT_LBL,
          style: Theme
              .of(this.context)
              .textTheme
              .subtitle1
              .copyWith(
            color: fontColor,
          ),
        ),

        value: city,
        onChanged: (newValue) {
          setState(() {
            areaList.clear();
            area = null;
            city = newValue;
          });
          print(city);
          getArea();
        },
        items: cityList.map((User user) {
          return DropdownMenuItem<String>(
            value: user.id,
            child: Text(
              user.name,
              style:
              Theme
                  .of(this.context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: fontColor),
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          filled: true,
          fillColor: white,
          contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: white),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: white),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setArea() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: DropdownButtonFormField(
        iconSize: 40,
        iconEnabledColor: fontColor,
        isDense: true,
        hint: new Text(
          AREASELECT_LBL,
          style: Theme
              .of(this.context)
              .textTheme
              .subtitle1
              .copyWith(
            color: fontColor,
          ),
        ),
        value: area,
        onChanged: (newValue) {
          setState(() {
            area = newValue;
          });
          print(area);
        },
        onSaved: (value) {
          setState(() {
            area = value;
          });
        },
        items: areaList.map((User user) {
          return DropdownMenuItem<String>(
            value: user.id,
            child: Text(
              user.name,
              style:
              Theme
                  .of(this.context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: fontColor),
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          filled: true,
          fillColor: white,
          contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: white),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: white),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setAddress() {
    return Padding(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.text,
                controller: addressC,
                style: Theme
                    .of(this.context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: fontColor),
                onChanged: (v) =>
                    setState(() {
                      address = v;
                    }),
                onSaved: (String value) {
                  address = value;
                },
                decoration: InputDecoration(
                  hintText: ADDRESS_LBL,
                  hintStyle: Theme
                      .of(this.context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: lightBlack),
                  filled: true,
                  fillColor: white,
                  contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: white),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: white),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Container(
              width: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: white),
                  color: white),
              child: IconButton(
                icon: new Icon(Icons.my_location),
                onPressed: () async {


                  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

                  Navigator.push(
                      this.context,
                      MaterialPageRoute(builder: (context) => Map(

                        latitude: lat==null?position.latitude:double.parse(lat),
                        longitude:long==null?position.longitude: double.parse(long),
                        from: PROFILE,

                      )));
                },
              ),
            )
          ],
        ));
  }

  setPincode() {
    double width = MediaQuery
        .of(this.context)
        .size
        .width;
    return Container(
      width: width,
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: Center(
        child: TextFormField(
          keyboardType: TextInputType.number,
          controller: pincodeC,
          style: Theme
              .of(this.context)
              .textTheme
              .subtitle1
              .copyWith(color: fontColor),
          validator: validatePincodeOptional,
          onChanged: (v) =>
              setState(() {
                pincode = v;
              }),
          onSaved: (String value) {
            pincode = value;
          },
          decoration: InputDecoration(
            hintText: PINCODEHINT_LBL,
            hintStyle:
            Theme
                .of(this.context)
                .textTheme
                .subtitle1
                .copyWith(color: lightBlack),
            filled: true,
            fillColor: white,
            contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: white),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: white),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }

/*
  setDob() {
    return Padding(
        padding:
        EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 30.0),
        child: TextFormField(
            controller: dobC,
            readOnly: true,
            style: Theme
                .of(this.context)
                .textTheme
                .subtitle1
                .copyWith(color: darkgrey),
            decoration: InputDecoration(
              hintText: DOB_LBL,
              hintStyle:
              Theme
                  .of(this.context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: darkgrey),
              filled: true,
              fillColor: white,
              contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: white),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: white),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onTap: () async {
              //FocusScope.of(context).requestFocus(new FocusNode());
              final datePick = await showDatePicker(
                  context: this.context,
                  initialDate: new DateTime.now(),
                  firstDate: new DateTime(1900),
                  lastDate: new DateTime.now());
              if (datePick != null && datePick != birthDate) {
                setState(() {
                  birthDate = datePick;
                  isDateSelected = true;
                  String monthStr = birthDate.month.toString();
                  String dayStr = birthDate.day.toString();
                  if (monthStr.length == 1) {
                    monthStr = "0" + monthStr;
                  }
                  if (dayStr.length == 1) {
                    dayStr = "0" + dayStr;
                  }

                });
              }
            }

        ));
  }
*/

  profileImage() {
    return Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
        child: Stack(
          children: <Widget>[
            image != null && image != "" ?
            CircleAvatar(radius: 50,
                backgroundColor: primary,
                child: ClipRRect(borderRadius: BorderRadius.circular(50),
                    child: Image.network(image, fit: BoxFit.fill,width: 100,height: 100,))) :
            CircleAvatar(
              radius: 50,
              backgroundColor: primary,
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: primary)),
                  child: Icon(Icons.person, size: 100)

              ),
            ),
            Positioned(bottom: 1, right: 1, child: Container(
              height: 30, width: 30,
              child: IconButton(icon: Icon(Icons.edit, color: primary,size: 15,),
                onPressed: () {
                  setState(() {
                    _imgFromGallery();
                    //_showPicker(context);
                  });
                },
              ),
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.all(Radius.circular(20),),
                  border: Border.all(color: primary)
              ),
            )
            ),
          ],
        ));
  }

  updateBtn() {
    return AppBtn(
      title: UPDATE_PROFILE_LBL,
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () {
        validateAndSubmit();
      },
    );
  }

  _showContent() {
    return Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _isNetworkAvail?Column(
              children: <Widget>[
                profileImage(),
                setUserName(),
                setEmail(),
                setMobileNo(),
                setCities(),
                setArea(),
                setAddress(),
                setPincode(),
                //setDob(),
                updateBtn(),
              ],
            ):noInternet(context),
          ),
        ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: getAppBar(PROFILE, context),
      body: Stack(
        children: <Widget>[
          _showContent(),
          showCircularProgress(_isLoading, primary)
        ],
      ),
    );
  }
}
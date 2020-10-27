import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Model/User.dart';
import 'package:eshop/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'Helper/Constant.dart';
import 'package:http/http.dart'as http;

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateProfile();
}

String lat,long;

class StateProfile extends State<Profile> {

  String name,
      email,
      mobile,
      city='',
      area='',
      pincode,
      address,

      dob,image;
  List<User> cityList=[];
  List<User> areaList=[];
  bool _isLoading = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController nameC, emailC, mobileC, pincodeC, addressC, dobC;
  bool isDateSelected = false;
  DateTime birthDate;
  bool isSelected=false;
  File _image,_imageFile;
  //Dio dio = new Dio();


  @override
  void initState() {
    super.initState();

    mobileC = new TextEditingController();
    nameC = new TextEditingController();
    emailC = new TextEditingController();
    pincodeC = new TextEditingController();
    addressC = new TextEditingController();
    dobC = new TextEditingController();
    getUserDetails();
    callApi();
  }

  getUserDetails() async {
    CUR_USERID = await getPrefrence(ID);
    mobile = await getPrefrence(MOBILE);
    name = await getPrefrence(USERNAME);
    email = await getPrefrence(EMAIL);
    city = await getPrefrence(CITY);
    area = await getPrefrence(AREA);
    pincode = await getPrefrence(PINCODE);
    address = await getPrefrence(ADDRESS);

    dob = await getPrefrence(DOB);
    image=await getPrefrence(IMAGE);



    mobileC.text = "+$mobile";
    nameC.text = name;
    emailC.text = email;
    pincodeC.text = pincode;
    addressC.text = address;
    dobC.text = dob;


    setState(() {});
  }

  Future<void> callApi() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getCities();
      if(city!=null && city!="")
      {
        getArea();
      }

    } else {
      setSnackbar(internetMsg);
      setState(() {
        _isLoading = false;
      });
    }
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

    if (form.validate())
    {
      form.save();
      return true;
    }

    return false;
  }

  Future<void> setProfilePic(File _image) async {
    setState(() {
      _isLoading = true;
    });
    try {
      var request = http.MultipartRequest("POST", Uri.parse(getUpdateUserApi));
      request.headers.addAll(headers);
      request.fields[USER_ID] = CUR_USERID;
      var pic = await http.MultipartFile.fromPath(IMAGE, _image.path);
      request.files.add(pic);

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var getdata = json.decode(responseString);
      bool error = getdata["error"];
      String msg = getdata['message'];
      if (!error) {
        setSnackbar('Profile Picture updated successfully');
        List data = getdata["data"];
        for(var i in data)
        {
          image=i[IMAGE];
        }
        setPrefrence(IMAGE,image);
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
  }

  Future<void> setUpdateUser() async {

    print(
        "Area:$area,City:$city,latitude:$lat,longitude:$long,dob:$dob,Id:$CUR_USERID");
    try {
      var data = {
        USER_ID:CUR_USERID,
        USERNAME:name,
        EMAIL:email
      };


      if(city!=null && city!="")
      {
        data[CITY]=city;
      }
      if(area!=null && area!="")
      {
        data[AREA]=area;
      }
      if(address!=null && address!="")
      {
        data[ADDRESS]=address;
      }
      if(pincode!=null && pincode!="")
      {
        data[PINCODE]=pincode;
      }
      if(dob!=null && dob!="")
      {
        data[DOB]=dob;
      }
      if(lat!=null && lat!="")
      {
        data[LATITUDE]=lat;
      }
      if(long!=null && long!="")
      {
        data[LONGITUDE]=long;
      }


      http.Response response =
      await http.post(getUpdateUserApi, body: data, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      print('response***UpdateUser**$headers***${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        setSnackbar("User Update Successfully");
        List data = getdata["data"];

        for (var i in data) {
          CUR_USERID= i[ID];
          name = i[USERNAME];
          email = i[EMAIL];
          mobile = i[MOBILE];
          city = i[CITY];
          area = i[AREA];
          address = i[ADDRESS];
          pincode = i[PINCODE];
          lat = i[LATITUDE];
          long = i[LONGITUDE];
          dob = i[DOB];
        }

        print("City:$city,Area:$area,image:$image");
        saveUserDetail(CUR_USERID, name, email, mobile, city, area, address,
            pincode, lat, long, dob,image);
      } else {
        setSnackbar(msg);
      }
      setState(() {
        _isLoading = false;
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }

  _imgFromGallery() async {
    final image1 = await ImagePicker.pickImage (
        source: ImageSource.gallery
    );

    if(image1!=null) {
      setState(() {
        _image = image1;
        setProfilePic(_image);
      });
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: this.context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text(GALLARY_LBL),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),

                ],
              ),
            ),
          );
        }
    );
  }




  Future<void> getCities() async {
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
      backgroundColor: Colors.white,
      elevation: 1.0,
    ));
  }

  setUserName() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: nameC,
        style: Theme.of(this.context).textTheme.subtitle1.copyWith(color: darkgrey),
        validator: validateUserName,
        onChanged: (v) => setState(() {
          name = v;
        }),
        onSaved: (String value) {
          name = value;
        },
        decoration: InputDecoration(
          hintText: NAMEHINT_LBL,
          hintStyle:
          Theme.of(this.context).textTheme.subtitle1.copyWith(color: darkgrey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
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
          style: Theme.of(this.context).textTheme.subtitle1.copyWith(color: darkgrey),
          decoration: InputDecoration(
            hintText: MOBILEHINT_LBL,
            hintStyle:
            Theme.of(this.context).textTheme.subtitle1.copyWith(color: darkgrey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
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

  setEmail() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: Center(
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: emailC,
          style: Theme.of(this.context).textTheme.subtitle1.copyWith(color: darkgrey),
          validator: validateEmail,
          onChanged: (v) => setState(() {
            email = v;
          }),
          onSaved: (String value) {
            email = value;
          },
          decoration: InputDecoration(
            hintText: EMAILHINT_LBL,
            hintStyle:
            Theme.of(this.context).textTheme.subtitle1.copyWith(color: darkgrey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
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

  setCities() {
    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: DropdownButtonFormField(
        iconSize: 40,
        isDense: true,
        iconEnabledColor: darkgrey,
        hint: new Text(
          CITYSELECT_LBL,
          style: Theme.of(this.context).textTheme.subtitle1.copyWith(
            color: darkgrey,
          ),
        ),
        value: city,
        onChanged: (newValue) {
          setState(() {
            areaList.clear();
            area=null;
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
              Theme.of(this.context).textTheme.subtitle1.copyWith(color: darkgrey),
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
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
    );
  }

  setArea() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: DropdownButtonFormField(
        iconSize: 40,
        iconEnabledColor: darkgrey,
        isDense: true,
        hint: new Text(
          AREASELECT_LBL,
          style: Theme.of(this.context).textTheme.subtitle1.copyWith(
            color: darkgrey,
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
              Theme.of(this.context).textTheme.subtitle1.copyWith(color: darkgrey),
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
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
                style: Theme.of(this.context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: darkgrey),
                onChanged: (v) => setState(() {
                  address = v;
                }),
                onSaved: (String value) {
                  address = value;
                },
                decoration: InputDecoration(
                  hintText: ADDRESS_LBL,
                  hintStyle: Theme.of(this.context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: darkgrey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
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
            SizedBox(width: 10),
            Container(
              width: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: white),
                  color: white),
              child: IconButton(
                icon: new Icon(Icons.my_location),
                onPressed: () {
                  Navigator.push(
                      this.context, MaterialPageRoute(builder: (context) => Map()));
                },
              ),
            )
          ],
        ));
  }

  setPincode() {
    double width = MediaQuery.of(this.context).size.width;
    return Container(
      width: width,
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: Center(
        child: TextFormField(
          keyboardType: TextInputType.number,
          controller: pincodeC,
          style: Theme.of(this.context).textTheme.subtitle1.copyWith(color: darkgrey),
          validator: validatePincode,
          onChanged: (v) => setState(() {
            pincode = v;
          }),
          onSaved: (String value) {
            pincode = value;
          },
          decoration: InputDecoration(
            hintText: PINCODEHINT_LBL,
            hintStyle:
            Theme.of(this.context).textTheme.subtitle1.copyWith(color: darkgrey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
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

  setDob() {
    return Padding(
        padding:
        EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 30.0),
        child: TextFormField(
            controller: dobC,
            readOnly: true,
            style: Theme.of(this.context).textTheme.subtitle1.copyWith(color: darkgrey),
            decoration: InputDecoration(
              hintText: DOB_LBL,
              hintStyle:
              Theme.of(this.context).textTheme.subtitle1.copyWith(color: darkgrey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: new EdgeInsets.only(right: 30.0, left: 30.0),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
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
                  dob = "${dayStr}/${monthStr}/${birthDate.year}";
                  print(dob);
                  dobC.text = dob;
                });
              }
            }

        ));
  }

  profileImage() {
    return Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
        child:Stack(
          children: <Widget>[
            image!=null?
            CircleAvatar(  radius: 50,
                backgroundColor: primary,child:ClipRRect(borderRadius: BorderRadius.circular(50),
                    child:Image.network(image,fit: BoxFit.fill,))):
            CircleAvatar(
              radius: 50,
              backgroundColor: primary,
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: primary)),
                  child: Icon(Icons.person,size:100)

              ),
            ),
            Positioned(bottom: 1, right:1 ,child: Container(
              height:40, width: 40,
              child: IconButton(icon:Icon(Icons.edit, color:primary,),
                onPressed:()
                {
                  setState(() {
                    _showPicker(context);
                  });
                },
              ),
              decoration: BoxDecoration(
                  color:white,
                  borderRadius: BorderRadius.all(Radius.circular(20),), border: Border.all(color: primary)
              ),
            )
            ),
          ],
        ));
  }
  updateBtn() {
    double width = MediaQuery.of(this.context).size.width;

    return Padding(
      padding:
      EdgeInsets.only(bottom: 50.0, left: 20.0, right: 20.0, top: 20.0),
      child: RaisedButton(
        onPressed: () {
          setState(() {
            validateAndSubmit();
          });
        },
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary.withOpacity(0.7), primary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30.0)),
          child: Container(
            constraints:
            BoxConstraints(maxWidth: width * 0.90, minHeight: 50.0),
            alignment: Alignment.center,
            child: Text(
              UPDATE_PROFILE_LBL,
              textAlign: TextAlign.center,
              style: Theme.of(this.context).textTheme.headline6.copyWith(
                color: white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showContent() {
    return Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: <Widget>[
                profileImage(),
                setUserName(),
                setEmail(),
                setMobileNo(),
                setCities(),
                setArea(),
                setAddress(),
                setPincode(),
                setDob(),
                updateBtn(),
              ],
            ),
          ),
        ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightgrey,
      appBar: getAppBar(PROFILE, context),
      body: Stack(
        children: <Widget>[
          _showContent(),
          showCircularProgress(_isLoading, primary),
        ],
      ),
    );
  }
}
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:core';

import 'package:eshop/CheckOut.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

import 'Helper/Color.dart';
import 'Helper/String.dart';
import 'Model/User.dart';

class AddAddress extends StatefulWidget {
  final bool update;
  final int index;

  const AddAddress({Key key, this.update, this.index}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateAddress();
  }
}

String latitude, longitude;

class StateAddress extends State<AddAddress> {
  String name,
      mobile,
      city,
      area,
      pincode,
      address,
      landmark,
      altMob,
      state,
      country,
      type = "Home",
      isDefault;
  bool checkedDefault = false;
  bool _isLoading = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<User> cityList = [];
  List<User> areaList = [];
  TextEditingController nameC,
      mobileC,
      pincodeC,
      addressC,
      landmarkC,
      stateC,
      countryC,
      altMobC;
  int selectedType = 1;

  @override
  void initState() {
    super.initState();
    callApi();

    mobileC = new TextEditingController();
    nameC = new TextEditingController();
    altMobC = new TextEditingController();
    pincodeC = new TextEditingController();
    addressC = new TextEditingController();
    stateC = new TextEditingController();
    countryC = new TextEditingController();
    landmarkC = new TextEditingController();

    if (widget.update) {
      User item = addressList[widget.index];
      mobileC.text = item.mobile;
      nameC.text = item.name;
      altMobC.text = item.alt_mob;
      landmarkC.text = item.landmark;
      pincodeC.text = item.pincode;
      addressC.text = item.address;
      stateC.text = item.state;
      countryC.text = item.country;
      stateC.text = item.state;
      latitude = item.latitude;
      longitude = item.longitude;

      type = item.type;
      city = item.cityId;
      area = item.areaId;
      if (type.toLowerCase() == HOME.toLowerCase())
        selectedType = 1;
      else if (type.toLowerCase() == OFFICE.toLowerCase())
        selectedType = 2;
      else
        selectedType = 3;

      print("isdefault**${item.isDefault}***$area**$city");
      checkedDefault = item.isDefault == "1" ? true : false;
    } else {
      getCurrentLoc();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightgrey,
      appBar: getAppBar(ADDRESS_LBL, context),
      body: Stack(
        children: <Widget>[
          _showContent(),
          showCircularProgress(_isLoading, primary),
        ],
      ),
    );
  }

  addBtn() {
    double width = MediaQuery.of(context).size.width;

    return Container(
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
              widget.update ? UPDATEADD : ADDADDRESS,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6.copyWith(
                    color: white,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        _isLoading = true;
      });
      checkNetwork();
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState;

    print("lat***$latitude***$longitude");

    form.save();
    if (form.validate()) {
      if (city == null || city.isEmpty) {
        setSnackbar(cityWarning);
      } else if (area == null || area.isEmpty) {
        setSnackbar(areaWarning);
      } else if (latitude.trim().isEmpty || longitude.trim().isEmpty) {
        setSnackbar(locationWarning);
      } else
        return true;
    }
    return false;
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      addNewAddress();
    } else {
      setSnackbar(internetMsg);
      setState(() {
        _isLoading = false;
      });
    }
  }

  setUserName() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: nameC,
        validator: validateUserName,
        onSaved: (String value) {
          name = value;
        },
        decoration: InputDecoration(
          hintText: NAME_LBL,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: mobileC,
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        validator: validateMob,
        onSaved: (String value) {
          mobile = value;
        },
        decoration: InputDecoration(
          hintText: "Mobile number",
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

  setAltMobileNo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: altMobC,
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        validator: validateAltMob,
        onSaved: (String value) {
          print(altMobC.text);
          altMob = value;
        },
        decoration: InputDecoration(
          hintText: ALT_MOB,
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

  setCities() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField(
        iconSize: 40,
        iconEnabledColor: darkgrey,
        isDense: true,
        hint: new Text(
          "Select City",
        ),
        value: city,
        onChanged: (String newValue) {
          setState(() {
            city = newValue;
          });
          // print(city);
          getArea(city, true);
        },
        items: cityList.map((User user) {
          return DropdownMenuItem<String>(
            value: user.id,
            child: Text(
              user.name,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField(
        iconSize: 40,
        iconEnabledColor: darkgrey,
        isDense: true,
        hint: new Text(
          "Select Area",
        ),
        value: area,
        onChanged: (String newValue) {
          setState(() {
            area = newValue;
          });
          print(area);
        },
        items: areaList.map((User user) {
          return DropdownMenuItem<String>(
            value: user.id,
            child: Text(
              user.name,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: addressC,
              validator: validateField,
              onSaved: (String value) {
                address = value;
              },
              decoration: InputDecoration(
                hintText: "Address",
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
          Container(
            margin: EdgeInsets.only(left: 7),
            width: 60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: white),
                color: white),
            child: IconButton(
              icon: new Icon(Icons.my_location),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Map(
                              latitude: double.parse(latitude),
                              longitude: double.parse(longitude),
                              from: ADDADDRESS,
                            )));
              },
            ),
          )
        ],
      ),
    );
  }

  setPincode() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: pincodeC,
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        validator: validatePincode,
        onSaved: (String value) {
          pincode = value;
        },
        decoration: InputDecoration(
          hintText: "Pincode",
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

  Future<void> callApi() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getCities();
      if (widget.update) {
        getArea(addressList[widget.index].cityId, false);
      }
    } else {
      setSnackbar(internetMsg);
      setState(() {
        _isLoading = false;
      });
    }
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

  Future<void> getArea(String city, bool clear) async {
    print("selectedcityforarea:$city");
    try {
      var data = {
        ID: city,
      };

      Response response =
          await post(getAreaByCityApi, body: data, headers: headers)
              .timeout(Duration(seconds: timeOut));

      print('response***Area****${response.body.toString()}');
      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];

      if (!error) {
        var data = getdata["data"];
        areaList.clear();
        if (clear) area = null;
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

  setLandmark() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: landmarkC,
        validator: validateField,
        onSaved: (String value) {
          landmark = value;
        },
        decoration: InputDecoration(
          hintText: LANDMARK,
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

  setStateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: stateC,
        validator: validateField,
        onChanged: (v) => setState(() {
          state = v;
        }),
        onSaved: (String value) {
          state = value;
        },
        decoration: InputDecoration(
          hintText: STATE_LBL,
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

  setCountry() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: countryC,
        onSaved: (String value) {
          country = value;
        },
        validator: validateField,
        decoration: InputDecoration(
          hintText: COUNTRY_LBL,
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

  Future<void> addNewAddress() async {
    try {
      var data = {
        USER_ID: CUR_USERID,
        NAME: name,
        MOBILE: mobile,
        ALT_MOBNO: altMob,
        LANDMARK: landmark,
        PINCODE: pincode,
        CITY_ID: city,
        AREA_ID: area,
        ADDRESS: address,
        STATE: state,
        COUNTRY: country,
        TYPE: type,
        ISDEFAULT: checkedDefault.toString() == "true" ? "1" : "0",
        LATITUDE: latitude,
        LONGITUDE: longitude
      };
      if (widget.update) data[ID] = addressList[widget.index].id;

      print('response******param--${data.toString()}');
      Response response = await post(
              widget.update ? updateAddressApi : getAddAddressApi,
              body: data,
              headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print('response***UpdateUser**$headers***${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        if (checkedDefault.toString() == "true") {
          for (User i in addressList) {
            i.isDefault = "0";
            print("after***before**${i.name}***${i.isDefault}");
          }
          selectedAddress = null;
          addressList[widget.index].isDefault = "1";
          selectedAddress = widget.index;
        }
        if (widget.update) {
          User value = new User.fromAddress(data[0]);
          addressList[widget.index] = value;
        } else {
          User value = new User.fromAddress(data[0]);
          addressList.add(value);
        }
        if (checkedDefault.toString() == "true") {
          for (User i in addressList) i.isDefault = "0";
        }
        Navigator.of(context).pop();
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

  @override
  void dispose() {
    mobileC?.dispose();
    nameC?.dispose();
    stateC?.dispose();
    countryC?.dispose();
    altMobC?.dispose();
    landmarkC?.dispose();
    addressC.dispose();
    pincodeC?.dispose();

    super.dispose();
  }

  typeOfAddress() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: InkWell(
              child: Row(
                children: [
                  Radio(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    groupValue: selectedType,
                    value: 1,
                    onChanged: (val) {
                      print("val***$val");
                      setState(() {
                        selectedType = val;
                        type = HOME;
                      });
                    },
                  ),
                  Text(HOME_LBL)
                ],
              ),
              onTap: () {
                setState(() {
                  selectedType = 1;
                  type = HOME;
                });
              },
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: InkWell(
              child: Row(
                children: [
                  Radio(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    groupValue: selectedType,
                    value: 2,
                    onChanged: (val) {
                      setState(() {
                        selectedType = val;
                        type = OFFICE;
                      });
                    },
                  ),
                  Text(OFFICE_LBL)
                ],
              ),
              onTap: () {
                setState(() {
                  selectedType = 2;
                  type = OFFICE;
                });
              },
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: InkWell(
              child: Row(
                children: [
                  Radio(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    groupValue: selectedType,
                    value: 3,
                    onChanged: (val) {
                      setState(() {
                        selectedType = val;
                        type = OTHER;
                      });
                    },
                  ),
                  Text(OTHER_LBL)
                ],
              ),
              onTap: () {
                setState(() {
                  selectedType = 3;
                  type = OTHER;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  defaultAdd() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: CheckboxListTile(
          value: checkedDefault,
          onChanged: (newValue) {
            setState(() {
              print("value***$newValue");
              checkedDefault = newValue;
            });
          },
          title: Text(DEFAULT_ADD),
          controlAffinity: ListTileControlAffinity.leading,
        ));
  }

  _showContent() {
    return Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: <Widget>[
                setUserName(),
                setMobileNo(),
                setAltMobileNo(),
                setAddress(),
                setLandmark(),
                setPincode(),
                setCities(),
                setArea(),
                setStateField(),
                setCountry(),
                typeOfAddress(),
                defaultAdd(),
                addBtn(),
              ],
            ),
          ),
        ));
  }

  Future<void> getCurrentLoc() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
  }
}

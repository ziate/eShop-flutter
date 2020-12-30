import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:core';

import 'package:eshop/CheckOut.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Map.dart';
import 'package:eshop/Profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

import 'Helper/AppBtn.dart';
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

String latitude, longitude, state, country, pincode;

class StateAddress extends State<AddAddress> with TickerProviderStateMixin {
  String name,
      mobile,
      city,
      area,
      address,
      landmark,
      altMob,
      type = "Home",
      isDefault;
  bool checkedDefault = false;
  bool _isProgress=false;
  //bool _isLoading = false;
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
  bool _isNetworkAvail = true;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  FocusNode nameFocus,
      monoFocus,
      almonoFocus,
      addFocus,
      landFocus,
      locationFocus = FocusNode();

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

      checkedDefault = item.isDefault == "1" ? true : false;
    } else {
      getCurrentLoc();
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: getAppBar(ADDRESS_LBL, context),
      body: _isNetworkAvail ? _showContent() : noInternet(context),
    );
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

  addBtn() {
    return AppBtn(
      title: widget.update ? UPDATEADD : ADDADDRESS,
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () {
        validateAndSubmit();
      },
    );
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {

      checkNetwork();
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState;


    form.save();
    if (form.validate()) {
      if (city == null || city.isEmpty) {
        setSnackbar(cityWarning);
      } else if (area == null || area.isEmpty) {
        setSnackbar(areaWarning);
      } else if (latitude == null || longitude == null) {
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
      Future.delayed(Duration(seconds: 2)).then((_) async {
        setState(() {
          _isNetworkAvail = false;
        });
        await buttonController.reverse();
      });
    }
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  setUserName() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: nameFocus,
      controller: nameC,
      textCapitalization: TextCapitalization.words,
      validator: validateUserName,
      onSaved: (String value) {
        name = value;
      },
      onFieldSubmitted: (v) {
        _fieldFocusChange(context, nameFocus, monoFocus);
      },
      style: Theme.of(context).textTheme.subtitle2.copyWith(color: fontColor),
      decoration: InputDecoration(
          isDense: true,
          hintText: NAME_LBL,
          hintStyle: Theme.of(context)
              .textTheme
              .subtitle2
              .copyWith(color: lightBlack)),
    );
  }

  setMobileNo() {
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: mobileC,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.next,
      focusNode: monoFocus,
      style: Theme.of(context).textTheme.subtitle2.copyWith(color: fontColor),
      validator: validateMob,
      onSaved: (String value) {
        mobile = value;
      },
      onFieldSubmitted: (v) {
        _fieldFocusChange(context, monoFocus, almonoFocus);
      },
      decoration: InputDecoration(
        hintText: MOBILEHINT_LBL,
        isDense: true,
      ),
    );
  }

  setAltMobileNo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: altMobC,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: TextInputAction.next,
        focusNode: almonoFocus,
        validator: validateAltMob,
        style: Theme.of(context).textTheme.subtitle2.copyWith(color: fontColor),
        onSaved: (String value) {
          print(altMobC.text);
          altMob = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, almonoFocus, addFocus);
        },
        decoration: InputDecoration(
          hintText: ALT_MOB,
        ),
      ),
    );
  }

  setCities() {
    return DropdownButtonFormField(
      iconEnabledColor: fontColor,
      isDense: true,
      hint: new Text(
        CITYSELECT_LBL,
      ),
      value: city,
      style: Theme.of(context).textTheme.subtitle2.copyWith(color: fontColor),
      onChanged: (String newValue) {
        setState(() {
          city = newValue;
        });
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
        isDense: true,
        contentPadding: new EdgeInsets.symmetric(vertical: 5),
      ),
    );
  }

  setArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField(
        iconEnabledColor: fontColor,
        isDense: true,
        style: Theme.of(context).textTheme.subtitle2.copyWith(color: fontColor),
        hint: new Text(
          AREASELECT_LBL,
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
          isDense: true,
          contentPadding: new EdgeInsets.symmetric(vertical: 5),
        ),
      ),
    );
  }

  setAddress() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            style: Theme.of(context)
                .textTheme
                .subtitle2
                .copyWith(color: fontColor),
            focusNode: addFocus,
            controller: addressC,
            validator: validateField,
            onSaved: (String value) {
              address = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, addFocus, locationFocus);
            },
            decoration: InputDecoration(
              hintText: ADDRESS_LBL,
              isDense: true,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 5),
          width: 40,
          child: IconButton(
            icon: new Icon(
              Icons.my_location,
              size: 20,
            ),
            focusNode: locationFocus,
            onPressed: () async {
              Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high);

              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Map(
                        latitude: latitude == null
                            ? position.latitude
                            : double.parse(latitude),
                        longitude: longitude == null
                            ? position.longitude
                            : double.parse(longitude),
                        from: ADDADDRESS,
                      )));
              setState(() {});
              List<Placemark> placemark = await placemarkFromCoordinates(
                  double.parse(latitude), double.parse(longitude));

              state = placemark[0].administrativeArea;
              country = placemark[0].country;
              pincode = placemark[0].postalCode;
              setState(() {
                countryC.text = country;
                stateC.text = state;
                pincodeC.text = pincode;
              });
            },
          ),
        )
      ],
    );
  }

  setPincode() {
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: pincodeC,
      style: Theme.of(context).textTheme.subtitle2.copyWith(color: fontColor),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onSaved: (String value) {
        pincode = value;
      },
      decoration: InputDecoration(
        hintText: PINCODEHINT_LBL,
        isDense: true,
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
      Future.delayed(Duration(seconds: 2)).then((_) async {
        setState(() {
          _isNetworkAvail = false;
        });
      });
    }
  }

  Future<void> getCities() async {
    try {
      Response response = await post(getCitiesApi, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        cityList =
            (data as List).map((data) => new User.fromJson(data)).toList();
      } else {
        setSnackbar(msg);
      }
      setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }

  Future<void> getArea(String city, bool clear) async {

    try {
      var data = {
        ID: city,
      };

      Response response =
      await post(getAreaByCityApi, body: data, headers: headers)
          .timeout(Duration(seconds: timeOut));


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
      if(mounted)
        setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
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

  setLandmark() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: landFocus,
      controller: landmarkC,
      style: Theme.of(context).textTheme.subtitle2.copyWith(color: fontColor),
      validator: validateField,
      onSaved: (String value) {
        landmark = value;
      },
      decoration: InputDecoration(
        hintText: LANDMARK,
      ),
    );
  }

  setStateField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      controller: stateC,
      style: Theme.of(context).textTheme.subtitle2.copyWith(color: fontColor),

      //validator: validateField,
      onChanged: (v) => setState(() {
        state = v;
      }),
      onSaved: (String value) {
        state = value;
      },
      decoration: InputDecoration(
        hintText: STATE_LBL,
        isDense: true,
        contentPadding: new EdgeInsets.symmetric(vertical: 10.0),
      ),
    );
  }

  setCountry() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      controller: countryC,
      style: Theme.of(context).textTheme.subtitle2.copyWith(color: fontColor),
      onSaved: (String value) {
        country = value;
      },
      validator: validateField,
      decoration: InputDecoration(
        hintText: COUNTRY_LBL,
        isDense: true,
        contentPadding: new EdgeInsets.symmetric(vertical: 10.0),
      ),
    );
  }

  Future<void> addNewAddress() async {

    setState(() {
      _isProgress=true;
    });


    try {
      var data = {
        USER_ID: CUR_USERID,
        NAME: name,
        MOBILE: mobile,
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


      Response response = await post(
          widget.update ? updateAddressApi : getAddAddressApi,
          body: data,
          headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];

      await buttonController.reverse();
      if (!error) {
        var data = getdata["data"];

        if (widget.update) {
          User value = new User.fromAddress(data[0]);
          addressList[widget.index] = value;
        } else {
          User value = new User.fromAddress(data[0]);
          addressList.add(value);

        }

        if (checkedDefault.toString() == "true") {
          for (User i in addressList) {
            i.isDefault = "0";
            print("after***before**${i.name}***${i.isDefault}");
          }
          selectedAddress = null;
          addressList[widget.index].isDefault = "1";
          selectedAddress = widget.index;
        }



        setState(() {
          _isProgress=false;
        });
        Navigator.of(context).pop();
      } else {
        setSnackbar(msg);
      }
      setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }

  @override
  void dispose() {
    buttonController.dispose();
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

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  typeOfAddress() {
    return Row(
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: InkWell(
            child: Row(
              children: [
                Radio(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  groupValue: selectedType,
                  activeColor: fontColor,
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
                  activeColor: fontColor,
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
                  activeColor: fontColor,
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
    );
  }

  defaultAdd() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: SwitchListTile(
          value: checkedDefault,
          dense: true,
          onChanged: (newValue) {
            setState(() {
              checkedDefault = newValue;
            });
          },
          title: Text(DEFAULT_ADD,style: Theme.of(context).textTheme.subtitle2.copyWith(color: lightBlack,fontWeight: FontWeight.bold),),

        ));
  }

  _showContent() {
    return Stack(
      children: [
        Form(
            key: _formkey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Card(
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  setUserName(),
                                  setMobileNo(),
                                  //setAltMobileNo(),
                                  setAddress(),
                                  // setLandmark(),
                                  setCities(),
                                  setArea(),
                                  setPincode(),
                                  setStateField(),
                                  setCountry(),
                                  typeOfAddress(),

                                  // addBtn(),
                                ],
                              ),
                            ),
                          ),
                        ),

                        defaultAdd(),

                      ],
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                      alignment: Alignment.center,
                      height: 55,
                      decoration: new BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [grad1Color, grad2Color],
                            stops: [0, 1]),
                      ),
                      child: Text(SAVE_LBL,
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: white,
                          ))),
                  onTap: () {
                    validateAndSubmit();
                  },
                )
              ],
            )),
        showCircularProgress(_isProgress, primary)
      ],
    );
  }

  Future<void> getCurrentLoc() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();

    List<Placemark> placemark = await placemarkFromCoordinates(
        double.parse(latitude), double.parse(longitude));

    state = placemark[0].administrativeArea;
    country = placemark[0].country;
    pincode = placemark[0].postalCode;
    setState(() {
      countryC.text = country;
      stateC.text = state;
      pincodeC.text = pincode;
    });
  }
}

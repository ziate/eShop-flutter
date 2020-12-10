import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_review/app_review.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Favorite.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Home.dart';
import 'package:eshop/Model/User.dart';
import 'package:eshop/Map.dart';

import 'package:eshop/NotificationLIst.dart';
import 'package:eshop/Setting.dart';
import 'package:eshop/Track_Order.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:share/share.dart';

import 'Add_Address.dart';
import 'Cart.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Constant.dart';
import 'package:http/http.dart' as http;

import 'Login.dart';
import 'Logout.dart';
import 'Privacy_Policy.dart';
import 'Profile.dart';

class MyProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateProfile();
}

class StateProfile extends State<MyProfile> with TickerProviderStateMixin {
  int curDrwSel = 0;
  String profile, email;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  getUserDetails() async {
    CUR_USERID = await getPrefrence(ID);
    CUR_USERNAME = await getPrefrence(USERNAME);
    email = await getPrefrence(EMAIL);
    profile = await getPrefrence(IMAGE);
  }

  update() {
    setState(() {});
  }

  _getHeader() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Container(
          padding: EdgeInsets.only(left: 10.0, bottom: 20),
          child: Row(
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 40, left: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CUR_USERNAME == "" || CUR_USERNAME == null
                            ? "Hello,\nguest"
                            : CUR_USERNAME,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: black),
                      ),
                      email != null
                          ? Text(
                        email,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            .copyWith(color: black),
                      )
                          : Container(),
                      CUR_USERNAME == "" || CUR_USERNAME == null
                          ? Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: InkWell(
                            child: Text(LOGIN_REGISTER_LBL,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(
                                  color: primary,
                                  decoration: TextDecoration.underline,
                                )),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Login(),
                                  ));
                            },
                          ))
                          : Padding(
                          padding: const EdgeInsets.only(
                            top: 7,
                          ),
                          child: InkWell(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(EDIT_PROFILE_LBL,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(color: primary)),
                                Icon(
                                  Icons.arrow_right_outlined,
                                  color: primary,
                                  size: 20,
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Profile(),
                                  ));
                            },
                          ))
                    ],
                  )),
              Spacer(),
              Container(
                margin: EdgeInsets.only(top: 40, right: 20),
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1.0, color: white)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: profile != null
                      ? CachedNetworkImage(
                      imageUrl: profile,
                      height: 64,
                      width: 64,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return new Container(
                          child: Icon(
                            Icons.account_circle,
                            color: white,
                            size: 64,
                          ),
                        );
                      })
                      : imagePlaceHolder(62),
                ),
              ),
            ],
          ),
        ));
  }

  _getDrawerFirst() {
    print("current==========$CUR_USERNAME===$CUR_USERID");
    return Card(
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      elevation: 3.0,
      color: white,
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          _getDrawerItem(0, MY_ORDERS_LBL, 'assets/images/pro_myorder.png'),
          _getDivider(),
          _getDrawerItem(1, NOTIFICATION, 'assets/images/pro_notification.png'),
          _getDivider(),
          _getDrawerItem(2, FAVORITE, 'assets/images/pro_favourite.png'),
          _getDivider(),
          _getDrawerItem(3, SETTING, 'assets/images/pro_setting.png'),
          _getDivider(),
          _getDrawerItem(4, MANAGE_ADD_LBL, 'assets/images/pro_address.png'),
          _getDivider(),
          _getDrawerItem(5, TRACK_ORDER, 'assets/images/pro_trackorder.png'),
        ],
      ),
    );
  }

  _getDivider() {
    return Divider(
      height: 1,
      color: black26,
    );
  }

  _getDrawerSecond() {
    print("current==========$CUR_USERNAME===$CUR_USERID");
    return Card(
      margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
      elevation: 3.0,
      color: white,
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          _getDrawerItem(
              6, CUSTOMER_SUPPORT_LBL, 'assets/images/pro_customersupport.png'),
          _getDivider(),
          _getDrawerItem(7, RATE_US, 'assets/images/pro_rateus.png'),
          _getDivider(),
          _getDrawerItem(8, SHARE_APP, 'assets/images/pro_share.png'),
          _getDivider(),
          _getDrawerItem(9, ABOUT_LBL, 'assets/images/pro_aboutus.png'),
          CUR_USERID == "" || CUR_USERID == null ? Container() : _getDivider(),
          CUR_USERID == "" || CUR_USERID == null
              ? Container()
              : _getDrawerItem(10, LOGOUT, 'assets/images/pro_logout.png'),
        ],
      ),
    );
  }

  _getDrawerItem(int index, String title, String img) {
    return ListTile(
      dense: true,
      leading: Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: new BorderRadius.all(const Radius.circular(5.0)),
              color: lightWhite),
          child: Image.asset(img,)),
      title: Text(
        title,
        style: TextStyle(color: lightBlack2, fontSize: 15),
      ),
      onTap: () {

        if (title == MY_ORDERS_LBL) {
          setState(() {
            curDrwSel = index;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrackOrder(),

              ));
        } else if (title == NOTIFICATION) {
          setState(() {
            curDrwSel = index;
          });
          CUR_USERID == null
              ? Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Login(),
              ))
              : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationList(),
              ));
        } else if (title == FAVORITE) {
          CUR_USERID == null
              ? Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Login(),
              ))
              : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Favorite(update),
              ));
        } else if (title == SETTING) {
          CUR_USERID == null
              ? Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Login(),
              ))
              : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Setting(),
              ));
        } else if (title == MANAGE_ADD_LBL) {
          CUR_USERID == null
              ? Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Login(),
              ))
              : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddAddress(
                  update: false,
                ),
              ));
        } else if (title == TRACK_ORDER) {
          CUR_USERID == null
              ? Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Login(),
              ))
              : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrackOrder(),
              ));
        } else if (title == CUSTOMER_SUPPORT_LBL) {
        } else if (title == RATE_US) {
          setState(() {
            curDrwSel = index;
          });
          AppReview.requestReview.then((onValue) {
            print("==========$onValue");
          });
        } else if (title == SHARE_APP) {
          setState(() {
            curDrwSel = index;
          });
          var str =
              "$appName\n\nYou can find our app from below url\n\nAndroid:\n$androidLink$packageName\n\n iOS:\n$iosLink$iosPackage";
          Share.share(str);
        } else if (title == ABOUT_LBL) {
          setState(() {
            curDrwSel = index;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Privacy_Policy(
                  title: ABOUT_LBL,
                ),
              ));
        } else if (title == LOGOUT) {
          setState(() {
            curDrwSel = index;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Logout(
                  title: LOGOUT,
                ),
              ));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: lightWhite,
        body: Container(
          color: lightWhite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_getHeader(), _getDrawerFirst(), _getDrawerSecond()],
            ),
          ),
        ));
  }
}

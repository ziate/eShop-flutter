

import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Home.dart';
import 'package:in_app_review/in_app_review.dart';
import 'Faqs.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eshop/Setting.dart';
import 'package:flutter/material.dart';

import 'package:share/share.dart';
import 'Manage_Address.dart';
import 'Helper/Constant.dart';
import 'Login.dart';
import 'MyOrder.dart';
import 'Privacy_Policy.dart';
import 'Profile.dart';

class MyProfile extends StatefulWidget {
  Function update;

  MyProfile(this.update);

  @override
  State<StatefulWidget> createState() => StateProfile();
}

class StateProfile extends State<MyProfile> with TickerProviderStateMixin {
  String profile, email;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final InAppReview _inAppReview = InAppReview.instance;
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
                            ? GUEST
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
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Profile(),
                                      ));

                                  getUserDetails();
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
                      ? CircleAvatar(
                         backgroundImage : NetworkImage(profile),
                        radius: 32,

                          //fit: BoxFit.cover,
                          //errorWidget: (context, url, e) => placeHolder(64),
                         // placeholder: placeHolder(64)
                  )
                          /*    (context, url) {
                            return new Container(
                              child: Icon(
                                Icons.account_circle,
                                color: white,
                                size: 64,
                              ),
                            );
                          })*/
                      : imagePlaceHolder(62),
                ),
              ),
            ],
          ),
        ));
  }

  _getDrawerFirst() {
    return Card(
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      elevation: 0,
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
    return Card(
      margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
      elevation: 0,
      color: white,
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          _getDrawerItem(7, RATE_US, 'assets/images/pro_rateus.png'),
          _getDivider(),
          _getDrawerItem(8, SHARE_APP, 'assets/images/pro_share.png'),
          _getDivider(),
          _getDrawerItem(9, ABOUT_LBL, 'assets/images/pro_aboutus.png'),
          _getDivider(),
          _getDrawerItem(10, FAQS, 'assets/images/pro_faq.png'),
          CUR_USERID == "" || CUR_USERID == null ? Container() : _getDivider(),
          CUR_USERID == "" || CUR_USERID == null
              ? Container()
              : _getDrawerItem(11, LOGOUT, 'assets/images/pro_logout.png'),
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
          child: Image.asset(
            img,
          )),
      title: Text(
        title,
        style: TextStyle(color: lightBlack2, fontSize: 15),
      ),
      onTap: ()  {
        if (title == MY_ORDERS_LBL) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyOrder(),
              ));
        } else if (title == NOTIFICATION) {
          curSelected = 2;
          final CurvedNavigationBarState navBarState =
              bottomNavigationKey.currentState;
          navBarState.setPage(2);
        } else if (title == FAVORITE) {
          curSelected = 1;
          final CurvedNavigationBarState navBarState =
              bottomNavigationKey.currentState;
          navBarState.setPage(1);
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
                    builder: (context) => ManageAddress(
                      home: true,
                    ),
                  ));
        }else if (title == CUSTOMER_SUPPORT_LBL) {
        } else if (title == RATE_US) {

          _openStoreListing();
        } else if (title == SHARE_APP) {
          var str =
              "$appName\n\n$APPFIND$androidLink$packageName\n\n $IOSLBL\n$iosLink$iosPackage";
          Share.share(str);
        } else if (title == ABOUT_LBL) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Privacy_Policy(
                  title: ABOUT_LBL,
                ),
              ));
        } else if (title == FAQS) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Faqs(
                  title: FAQS,
                ),
              ));
        } else if (title == LOGOUT) {
          logOutDailog();

        }
      },
    );
  }

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
    appStoreId: appStoreId,
    microsoftStoreId: 'microsoftStoreId',
  );

  logOutDailog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  content:
                  Text(
                    LOGOUTTXT,
                    style: Theme.of(this.context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: fontColor),
                  ),
                  actions: <Widget>[
                    new FlatButton(
                        child: Text(
                          LOGOUTNO,
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                              color: lightBlack, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        }),
                    new FlatButton(
                        child: Text(
                          LOGOUTYES,
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                              color: fontColor, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          clearUserSession();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home', (Route<dynamic> route) => false);
                        })
                  ],
                );
              });
        });
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

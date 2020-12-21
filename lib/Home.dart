import 'dart:async';
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eshop/All_Category.dart';
import 'package:eshop/Faqs.dart';
import 'package:eshop/Favorite.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/MyProfile.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:eshop/Privacy_Policy.dart';
import 'package:eshop/Product_Detail.dart';
import 'package:eshop/SectionList.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';

import 'package:eshop/ProductList.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:eshop/ProductList.dart';
import 'package:shimmer/shimmer.dart';
import 'Cart.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Login.dart';
import 'Logout.dart';
import 'Model/Model.dart';
import 'Model/Section_Model.dart';
import 'NotificationLIst.dart';
import 'Profile.dart';
import 'Search.dart';
import 'SubCat.dart';

import 'Track_Order.dart';
import 'main.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateHome();
  }
}

List<Product> catList = [];
List<Model> homeSliderList = [];
List<Section_Model> sectionList = [];
List<Model> offerImages = [];
final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
bool _isCatLoading = true;
bool _isNetworkAvail = true;
int curSelected = 0;
GlobalKey bottomNavigationKey = GlobalKey();

class StateHome extends State<Home> {
  List<Widget> fragments;

  HomePage home;
  String profile;
  int curDrwSel = 0;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    // getUserData();
    home = new HomePage(updateHome);
    fragments = [
      HomePage(updateHome),
      Favorite(updateHome),
      NotificationList(),
      MyProfile(updateHome),
    ];
    firebaseCloudMessaging_Listeners();
    firNotificationInitialize();
  }

  updateHome() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: lightWhite,
        key: scaffoldKey,
        appBar: curSelected == 3 ? null : _getAppbar(),
        // drawer: _getDrawer(),
        bottomNavigationBar: getBottomBar(),
        body: fragments[curSelected]);
  }

  setSnackbar(String msg) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: black),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  /*_getDrawer() {
    print("current==========$CUR_USERNAME===$CUR_USERID");
    return Drawer(
      child: Container(
        color: white,
        child: ListView(
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            _getHeader(),
            _getDrawerItem(0, HOME_LBL, Icons.home_outlined),

            _getDrawerItem(1, CART, Icons.shopping_cart_outlined),

            _getDrawerItem(2, TRACK_ORDER, Icons.art_track_outlined),

            _getDrawerItem(3, PROFILE, Icons.person_outline),

            _getDrawerItem(4, FAVORITE, Icons.favorite_outline),

            _getDrawerItem(5, NOTIFICATION, Icons.notifications_outlined),

            //_getDrawerItem(SETTING, Icons.settings),
            _getDivider(),
            _getDrawerItem(6, RATE_APP, Icons.star_outline),

            _getDrawerItem(7, SHARE_APP, Icons.share_outlined),

            _getDrawerItem(8, PRIVACY, Icons.lock_outline),

            _getDrawerItem(9, TERM, Icons.speaker_notes_outlined),

            _getDrawerItem(10, CONTACT_LBL, Icons.info_outline),

            CUR_USERID == "" || CUR_USERID == null
                ? Container()
                : _getDivider(),
            CUR_USERID == "" || CUR_USERID == null
                ? Container()
                : _getDrawerItem(11, LOGOUT, Icons.input),
          ],
        ),
      ),
    );
  }

  _getDivider() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Divider(
        height: 1,

      ),
    );
  }

  _getDrawerItem(int index, String title, IconData icn) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
          gradient: curDrwSel == index
              ? LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                secondary.withOpacity(0.2),
                primary.withOpacity(0.2)
              ],
              stops: [
                0,
                1
              ])
              : null,
          // color: curDrwSel == index ? primary.withOpacity(0.2) : Colors.transparent,

          borderRadius: BorderRadius.only(
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(50),
          )),
      child: ListTile(
        dense: true,
        leading: Icon(
          icn,
          color: curDrwSel == index ? primary : lightBlack2,
        ),
        title: Text(
          title,
          style: TextStyle(
              color: curDrwSel == index ? primary : lightBlack2, fontSize: 15),
        ),
        onTap: () {
          Navigator.of(context).pop();
          if (title == HOME_LBL) {
            setState(() {
              curDrwSel = index;
              _curSelected = 0;
            });
          } else if (title == CART) {
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
                  builder: (context) => Cart(this.updateHome, null),
                ));
          } else if (title == TRACK_ORDER) {
            CUR_USERID == null
                ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(),
                ))
                : setState(() {
              _curSelected = 3;
              curDrwSel = index;
            });
          } else if (title == PROFILE) {
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
                  builder: (context) => Profile(),
                ));
          } else if (title == FAVORITE) {
            setState(() {
              _curSelected = 1;
              curDrwSel = index;
            });
          } else if (title == NOTIFICATION) {
            setState(() {
              _curSelected = 2;
              curDrwSel = index;
            });
          } else if (title == SHARE_APP) {
            setState(() {
              curDrwSel = index;
            });
            var str =
                "$appName\n\nYou can find our app from below url\n\nAndroid:\n$androidLink$packageName\n\n iOS:\n$iosLink$iosPackage";
            Share.share(str);
          } else if (title == RATE_APP) {
            setState(() {
              curDrwSel = index;
            });
            AppReview.requestReview.then((onValue) {
              print("==========$onValue");
            });
          } else if (title == PRIVACY) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Privacy_Policy(
                        title: PRIVACY,
                      ),
                ));
          } else if (title == TERM) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Privacy_Policy(
                        title: TERM,
                      ),
                ));
          } else if (title == CONTACT_LBL) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Privacy_Policy(
                        title: CONTACT_LBL,
                      ),
                ));
          } else if (title == LOGOUT) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Logout(
                        title: LOGOUT,
                      ),
                ));
          }
        },
      ),
    );
  }*/

  _getAppbar() {
    double width = deviceWidth;
    double height = width / 2;
    String title = curSelected == 1 ? FAVORITE : NOTIFICATION;
    print("cart count***$CUR_CART_COUNT");
    return AppBar(
      title: curSelected == 0
          ? Image.asset('assets/images/titleicon.png')
          : Text(
              title,
              style: TextStyle(
                color: fontColor,
              ),
            ),
      iconTheme: new IconThemeData(color: primary),
      // centerTitle:_curSelected == 0? false:true,
      actions: <Widget>[
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10, right: 10),
            child: Container(
              decoration: shadow(),
              child: Card(
                elevation: 0,
                child: new Stack(children: <Widget>[
                  Center(
                    child: Image.asset(
                      'assets/images/noti_cart.png',
                      width: 30,
                    ),
                  ),
                  (CUR_CART_COUNT != null &&
                          CUR_CART_COUNT.isNotEmpty &&
                          CUR_CART_COUNT != "0")
                      ? new Positioned(
                          top: 0.0,
                          right: 5.0,
                          bottom: 10,
                          child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primary.withOpacity(0.5)),
                              child: new Center(
                                child: Padding(
                                  padding: EdgeInsets.all(3),
                                  child: new Text(
                                    CUR_CART_COUNT,
                                    style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                        )
                      : Container()
                ]),
              ),
            ),
          ),
          onTap: () async {
            CUR_USERID == null
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ))
                : goToCart();
          },
        ),
        /* InkWell(
          onTap: () {
            if (CUR_USERID != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(),
                  ));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ));
            }
          },
          child: Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10, right: 10),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Color(0x1a0400ff),
                      offset: Offset(0, 0),
                      blurRadius: 30)
                ],

              ),
              child: Card(
                elevation: 0,
                child: Image.asset(
                  'assets/images/profile.png',
                  width: 30,
                ),
              ),
            ),
          ),
        )*/
      ],
      backgroundColor: curSelected == 0 ? Colors.transparent : white,
      elevation: 0,
    );
  }

  getBottomBar() {
    return CurvedNavigationBar(
        key: bottomNavigationKey,
        backgroundColor: lightWhite,
        height: 65,
        items: <Widget>[
          curSelected == 0
              ? Image.asset(
                  "assets/images/sel_home.png",
                  height: 35,
                )
              : Image.asset(
                  "assets/images/desel_home.png",
                ),
          curSelected == 1
              ? Image.asset(
                  "assets/images/sel_fav.png",
                  height: 35,
                )
              : Image.asset(
                  "assets/images/desel_fav.png",
                ),
          curSelected == 2
              ? Image.asset(
                  "assets/images/sel_notification.png",
                  height: 35,
                )
              : Image.asset(
                  "assets/images/desel_notification.png",
                ),
          curSelected == 3
              ? Image.asset(
                  "assets/images/sel_user.png",
                  height: 35,
                )
              : Image.asset(
                  "assets/images/desel_user.png",
                )
        ],
        onTap: (int index) {
          print("current=====$index");
          setState(() {
            curSelected = index;
          });
        });

/*    return BottomAppBar(
      color: white,
      elevation: 15,
      child: Container(
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: black26, blurRadius: 10)],
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(25.0),
                topRight: const Radius.circular(25.0),
              )),
          child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              child: BottomNavigationBar(
                showSelectedLabels: false,
                showUnselectedLabels: false,
                currentIndex: _curSelected,

                type: BottomNavigationBarType.fixed,
                */ /*   onTap: (int index) {
                  print("current=====$index");
                  setState(() {
                    _curSelected = index;
                  });
                },*/ /*
                items: [
                  BottomNavigationBarItem(
                    label: '',
                    icon: LikeButton(
                      onTap: (bool isLiked) {
                        return onNavigationTap(isLiked, 0);
                      },
                      circleColor: CircleColor(
                          start: primary, end: primary.withOpacity(0.1)),
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: primary,
                        dotSecondaryColor: primary.withOpacity(0.1),
                      ),
                      likeBuilder: (bool isLiked) {
                        return Image.asset(
                          "assets/images/desel_home.png",
                        );
                      },
                    ),
                    activeIcon: LikeButton(
                      onTap: (bool isLiked) {
                        return onNavigationTap(isLiked, 0);
                      },
                      circleColor: CircleColor(
                          start: primary, end: primary.withOpacity(0.1)),
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: primary,
                        dotSecondaryColor: primary.withOpacity(0.1),
                      ),
                      likeBuilder: (bool isLiked) {
                        return Image.asset(
                          "assets/images/sel_home.png",
                        );
                      },
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: '',
                    icon: LikeButton(
                      onTap: (bool isLiked) {
                        return onNavigationTap(isLiked, 1);
                      },
                      circleColor: CircleColor(
                          start: primary, end: primary.withOpacity(0.1)),
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: primary,
                        dotSecondaryColor: primary.withOpacity(0.1),
                      ),
                      likeBuilder: (bool isLiked) {
                        return Image.asset(
                          "assets/images/desel_fav.png",
                        );
                      },
                    ),
                    activeIcon: LikeButton(
                      onTap: (bool isLiked) {
                        return onNavigationTap(isLiked, 1);
                      },
                      circleColor: CircleColor(
                          start: primary, end: primary.withOpacity(0.1)),
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: primary,
                        dotSecondaryColor: primary.withOpacity(0.1),
                      ),
                      likeBuilder: (bool isLiked) {
                        return Image.asset(
                          "assets/images/sel_fav.png",
                        );
                      },
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: '',
                    icon: LikeButton(
                      onTap: (bool isLiked) {
                        return onNavigationTap(isLiked, 2);
                      },
                      circleColor: CircleColor(
                          start: primary, end: primary.withOpacity(0.1)),
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: primary,
                        dotSecondaryColor: primary.withOpacity(0.1),
                      ),
                      likeBuilder: (bool isLiked) {
                        return Image.asset(
                          "assets/images/desel_notification.png",
                        );
                      },
                    ),
                    activeIcon: LikeButton(
                      onTap: (bool isLiked) {
                        return onNavigationTap(isLiked, 2);
                      },
                      circleColor: CircleColor(
                          start: primary, end: primary.withOpacity(0.1)),
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: primary,
                        dotSecondaryColor: primary.withOpacity(0.1),
                      ),
                      likeBuilder: (bool isLiked) {
                        return Image.asset(
                          "assets/images/sel_notification.png",
                        );
                      },
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: '',
                    icon: LikeButton(
                      onTap: (bool isLiked) {
                        return onNavigationTap(isLiked, 3);
                      },
                      circleColor: CircleColor(
                          start: primary, end: primary.withOpacity(0.1)),
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: primary,
                        dotSecondaryColor: primary.withOpacity(0.1),
                      ),
                      likeBuilder: (bool isLiked) {
                        return Image.asset(
                          "assets/images/desel_tracks.png",
                        );
                      },
                    ),
                    activeIcon: LikeButton(
                      onTap: (bool isLiked) {
                        return onNavigationTap(isLiked, 3);
                      },
                      circleColor: CircleColor(
                          start: primary, end: primary.withOpacity(0.1)),
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: primary,
                        dotSecondaryColor: primary.withOpacity(0.1),
                      ),
                      likeBuilder: (bool isLiked) {
                        return Image.asset(
                          "assets/images/sel_tracks.png",
                        );
                      },
                    ),
                  ),
                ],

                */ /*       Image.asset(
                  "assets/images/home.png",
                ),
                InkWell(
                  child: Image.asset(
                    "assets/images/fav.png",
                  ),
                  splashColor: primary.withOpacity(0.8),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Favorite(),
                        ));
                  },
                ),
                InkWell(
                  child: Image.asset(
                    "assets/images/notification.png",
                  ),
                  splashColor: primary.withOpacity(0.8),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationList(),
                        ));
                  },
                ),
                InkWell(
                  child: Image.asset(
                    "assets/images/user.png",
                  ),
                  splashColor: primary.withOpacity(0.8),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Profile(),
                        ));
                  },
                ),*/ /*
                //]         ))),,
              ))),
    );*/
  }

  Future<bool> onNavigationTap(bool isLiked, int index) async {
    setState(() {
      curSelected = index;
    });
    return !isLiked;
  }

  _getHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: InkWell(
          child: Container(
            padding: EdgeInsets.only(left: 10.0, bottom: 20),
            decoration: back(),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 55, left: 10),
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
                        errorWidget:(context, url,e) => placeHolder(64) ,
                            placeholder: (context, url) {
                              return new Container(
                                child: Icon(
                                  Icons.account_circle,
                                  color: white,
                                  size: 64,
                                ),
                              );
                            })
                        : imagePlaceHolder(64),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 55, left: 10),
                  child: Text(
                    "Hello, \n${CUR_USERNAME == "" || CUR_USERNAME == null ? "Guest" : CUR_USERNAME}",
                    style: TextStyle(color: white, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          onTap: () {
            if (CUR_USERID != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(),
                  )).then((value) async {
                debugPrint(value);
                profile = await getPrefrence(IMAGE);
                CUR_USERNAME = await getPrefrence(USERNAME);
                print('on rsume***$profile');
                setState(() {});
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            }
          }),
    );
  }

  goToCart() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Cart(updateHome, null),
        )).then((val) => home.updateHomepage());
    //  if (nav == true || nav == null) home.updateHomepage();
  }

  void firNotificationInitialize() {
    //for firebase push notification
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) {
    return showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyApp(),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    /* _firebaseMessaging.getToken().then((token) async {
      String uid = await getPrefrence(ID);
      if (uid != null && uid != "") _registerToken(token, uid);
    });*/

    _firebaseMessaging.configure(
      onMessage: (message) async {
        print('onmessage $message');
        await myBackgroundMessageHandler(message);
      },
      onResume: (message) async {
        print('onresume $message');
        await myBackgroundMessageHandler(message);
      },
      onLaunch: (message) async {
        print('onlaunch $message');
        await myBackgroundMessageHandler(message);
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      //  print("Settings registered: $settings");
    });
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    if (message.containsKey('data') || message.containsKey('notification')) {
      var data = message['data'];

      var image = data['image'].toString();
      var title = data['title'].toString();
      var msg = data['body'].toString();

      print("data******$data");
      if (image != null) {
        var largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
        var bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');
        var bigPictureStyleInformation = BigPictureStyleInformation(
            FilePathAndroidBitmap(bigPicturePath),
            hideExpandedLargeIcon: true,
            contentTitle: title,
            htmlFormatContentTitle: true,
            summaryText: msg,
            htmlFormatSummaryText: true);
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'big text channel id',
            'big text channel name',
            'big text channel description',
            largeIcon: FilePathAndroidBitmap(largeIconPath),
            styleInformation: bigPictureStyleInformation);
        var platformChannelSpecifics =
            NotificationDetails(androidPlatformChannelSpecifics, null);
        await flutterLocalNotificationsPlugin.show(
            0, title, msg, platformChannelSpecifics);
      } else {
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.Max,
            priority: Priority.High,
            ticker: 'ticker');
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin
            .show(0, title, msg, platformChannelSpecifics, payload: 'item x');
      }

      // print('on message $data');
    }
  }

  static Future<String> _downloadAndSaveImage(
      String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(url);

    // print("path***$filePath");
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}

class HomePage extends StatefulWidget {
  Function updateHome;

  HomePage(this.updateHome);

  StateHomePage statehome = new StateHomePage();

  @override
  StateHomePage createState() => StateHomePage();

  updateHomepage() {
    statehome.getSection();
  }
}

class StateHomePage extends State<HomePage> with TickerProviderStateMixin {
  final _controller = PageController();
  int _curSlider = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool useMobileLayout;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool menuOpen = false;

  @override
  void initState() {
    super.initState();
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  updateHomePage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _home();
  }

  Widget _home() {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: lightWhite,
        body: _isNetworkAvail
            ? _isCatLoading
                ? homeShimmer()
                : SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _getSearchBar(),
                        _slider(),
                        _catHeading(),
                        _catList(),
                        _section()
                      ],
                    ))
            : noInternet(context));
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
                  getSlider();
                  getCat();
                  getSection();
                  getSetting();
                  getOfferImages();
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

  Widget homeShimmer() {
    double width = deviceWidth;
    double height = width / 2;
    return Container(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[100],
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: double.infinity,
              height: height,
              color: white,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              width: double.infinity,
              height: 18.0,
              color: white,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                        .map((_) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              width: 80.0,
                              height: 80.0,
                              color: white,
                            ))
                        .toList()),
              ),
            ),
            Column(
                children: [0, 1, 2, 3, 4]
                    .map((_) => Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              width: double.infinity,
                              height: 18.0,
                              color: white,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              width: double.infinity,
                              height: 8.0,
                              color: white,
                            ),
                            GridView.count(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                childAspectRatio: 1.0,
                                physics: NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                                children: List.generate(
                                  4,
                                  (index) {
                                    return Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: white,
                                    );
                                  },
                                )),
                          ],
                        ))
                    .toList()),
          ],
        )),
      ),
    );
  }

  Widget _slider() {
    double height = deviceWidth / 2.2;

    return homeSliderList.isNotEmpty
        ? Container(
            height: height,
            width: double.infinity,
            margin: EdgeInsets.only(top: 10),
            child: PageView.builder(
              itemCount: homeSliderList.length,
              scrollDirection: Axis.horizontal,
              controller: _controller,
              reverse: false,
              onPageChanged: (index) {
                setState(() {
                  _curSlider = index;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(7.0),
                          child: CachedNetworkImage(
                            imageUrl: homeSliderList[_curSlider].image,
                            placeholder: (context, url) => Image.asset(
                              "assets/images/sliderph.png",
                              height: height,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/images/sliderph.png",
                              height: height,
                            ),
                            fit: BoxFit.fill,
                            height: height,
                            width: double.maxFinite,
                          )),
                      Positioned(
                        bottom: 0,
                        height: 40,
                        left: 0,
                        width: deviceWidth,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: map<Widget>(
                            homeSliderList,
                            (index, url) {
                              return Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _curSlider == index
                                        ? fontColor
                                        : lightBlack,
                                  ));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {},
                );
              },
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 27),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              child: Image.asset(
                'assets/images/sliderph.png',
                height: height,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  void _animateSlider() {
    Future.delayed(Duration(seconds: 30)).then((_) {
      if (mounted) {
        int nextPage = _controller.hasClients
            ? _controller.page.round() + 1
            : _controller.initialPage;

        if (nextPage == homeSliderList.length) {
          nextPage = 0;
        }
        if (_controller.hasClients)
          _controller
              .animateToPage(nextPage,
                  duration: Duration(seconds: 1), curve: Curves.easeIn)
              .then((_) => _animateSlider());
      }
    });
  }

  _getSearchBar() {
    return GestureDetector(
      child: SizedBox(
        height: 35,
        child: TextField(
          enabled: false,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
              border: new OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(50.0),
                ),
                borderSide: BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              isDense: true,
              hintText: searchHint,
              hintStyle: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: fontColor,
                  ),
              //prefixIcon: Image.asset('assets/images/search.png'),
              suffixIcon: Image.asset(
                'assets/images/search.png',
                color: primary,
              ),
              fillColor: white,
              filled: true),
        ),
      ),
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Search(
                updateHome: widget.updateHome,
                menuopen: menuOpen,
              ),
            ));
        setState(() {});
      },
    );
  }

  _catHeading() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            category,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                seeAll,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: primary),
              ),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => All_Category(
                          updateHome: widget.updateHome,
                        )),
              );
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  _catList() {
    return Container(
      height: 80,
      child: ListView.builder(
        itemCount: catList.length < 10 ? catList.length : 10,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return InkWell(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: new ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: new CachedNetworkImage(
                        imageUrl: catList[index].image,
                        height: 50.0,
                        width: 50.0,
                        fit: BoxFit.cover,
                        errorWidget:(context, url,e) => placeHolder(50) ,
                        placeholder: (context, url) => placeHolder(50),
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      catList[index].name,
                      style: Theme.of(context).textTheme.caption.copyWith(
                          color: fontColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    width: 50,
                  ),
                ],
              ),
            ),
            onTap: () async {
              if (catList[index].subList == null ||
                  catList[index].subList.length == 0) {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductList(
                          name: catList[index].name,
                          id: catList[index].id,
                          updateHome: widget.updateHome),
                    ));
                setState(() {});
              } else {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubCat(
                          title: catList[index].name,
                          subList: catList[index].subList,
                          updateHome: widget.updateHome),
                    ));
                setState(() {});
              }
            },
          );
        },
      ),
    );
  }

  _section() {
    return _isCatLoading
        ? getProgress()
        : ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: sectionList.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _singleSection(index);
            },
          );
  }

  _singleSection(int index) {
    return sectionList[index].productList.length > 0
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _getHeading(sectionList[index].title, index),
              _getSection(index),
              offerImages.length > index ? _getOfferImage() : Container(),
            ],
          )
        : Container();
  }

  _getHeading(String title, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          InkWell(
            child: Text(
              seeAll,
              style:
                  Theme.of(context).textTheme.caption.copyWith(color: primary),
            ),
            splashColor: primary.withOpacity(0.2),
            onTap: () {
              Section_Model model = sectionList[index];
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SectionList(
                      index: index,
                      section_model: model,
                      updateHome: updateHomePage,
                    ),
                  ));
            },
          ),
        ],
      ),
    );
  }

  _getOfferImage() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 5),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: offerImages.length,
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: offerImages[index].image,
          width: double.maxFinite,
          errorWidget:(context, url,e) => placeHolder(50) ,
          placeholder:(context, url) => placeHolder(50) ,
        );
      },
    );
  }

  _getSection(int i) {
    print('style=====${sectionList[i].style}');
    return sectionList[i].style == DEFAULT
        ? GridView.count(
            padding: EdgeInsets.only(top: 5),
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 0.8,
            physics: NeverScrollableScrollPhysics(),
            children: List.generate(
              sectionList[i].productList.length < 4
                  ? sectionList[i].productList.length
                  : 4,
              (index) {
                return productItem(i, index, index % 2 == 0 ? true : false);
              },
            ))
        : sectionList[i].style == STYLE1
            ? Row(
                children: [
                  Flexible(
                      flex: 3,
                      fit: FlexFit.loose,
                      child: Container(
                          height: deviceHeight * 0.4,
                          child: productItem(i, 0, true))),
                  Flexible(
                    flex: 2,
                    fit: FlexFit.loose,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            height: deviceHeight * 0.2,
                            child: productItem(i, 1, false)),
                        Container(
                            height: deviceHeight * 0.2,
                            child: productItem(i, 2, false)),
                      ],
                    ),
                  ),
                ],
              )
            : sectionList[i].style == STYLE2
                ? Row(
                    children: [
                      Flexible(
                        flex: 2,
                        fit: FlexFit.loose,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                height: deviceHeight * 0.2,
                                child: productItem(i, 0, true)),
                            Container(
                                height: deviceHeight * 0.2,
                                child: productItem(i, 1, true)),
                          ],
                        ),
                      ),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.loose,
                          child: Container(
                              height: deviceHeight * 0.4,
                              child: productItem(i, 2, false))),
                    ],
                  )
                : sectionList[i].style == STYLE3
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                              flex: 1,
                              fit: FlexFit.loose,
                              child: Container(
                                  height: deviceHeight * 0.3,
                                  child: productItem(i, 0, false))),
                          Container(
                            height: deviceHeight * 0.2,
                            child: Row(
                              children: [
                                Flexible(
                                    flex: 1,
                                    fit: FlexFit.loose,
                                    child: productItem(i, 1, true)),
                                Flexible(
                                    flex: 1,
                                    fit: FlexFit.loose,
                                    child: productItem(i, 2, true)),
                                Flexible(
                                    flex: 1,
                                    fit: FlexFit.loose,
                                    child: productItem(i, 3, false)),
                              ],
                            ),
                          ),
                        ],
                      )
                    : sectionList[i].style == STYLE4
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                  flex: 1,
                                  fit: FlexFit.loose,
                                  child: Container(
                                      height: deviceHeight * 0.3,
                                      child: productItem(i, 0, false))),
                              Container(
                                height: deviceHeight * 0.2,
                                child: Row(
                                  children: [
                                    Flexible(
                                        flex: 1,
                                        fit: FlexFit.loose,
                                        child: productItem(i, 1, true)),
                                    Flexible(
                                        flex: 1,
                                        fit: FlexFit.loose,
                                        child: productItem(i, 2, false)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : GridView.count(
                            padding: EdgeInsets.only(top: 5),
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            childAspectRatio: 1.0,
                            physics: NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 0,
                            crossAxisSpacing: 0,
                            children: List.generate(
                              sectionList[i].productList.length < 4
                                  ? sectionList[i].productList.length
                                  : 4,
                              (index) {
                                return productItem(
                                    i, index, index % 2 == 0 ? true : false);
                              },
                            ));
  }

  /*Widget productItemSmall(int secPos, int index) {
    double price = double.parse(
        sectionList[secPos].productList[index].prVarientList[0].disPrice);
    if (price == 0)
      price = double.parse(
          sectionList[secPos].productList[index].prVarientList[0].price);

    double width = deviceWidth * 0.5 - 20;
    print(
        "tag=============${sectionList[secPos].productList[index].id}${secPos}${index}========home");

    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: black12, blurRadius: 10)],
      ),
      child: Card(
        elevation: 0.0,
        child: InkWell(
          child: Container(
            height: deviceHeight * 0.2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5)),
                            child: Hero(
                              transitionOnUserGestures: true,
                              tag:
                                  "${sectionList[secPos].productList[index].id}$secPos$index",
                              child: CachedNetworkImage(
                                imageUrl: sectionList[secPos]
                                    .productList[index]
                                    .image,
                                height: double.maxFinite,
                                width: double.maxFinite,
                                //fit: BoxFit.fill,
                                placeholder: (context, url) =>
                                    placeHolder(width),
                              ),
                            )),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(1.5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 10,
                              ),
                              Text(
                                sectionList[secPos].productList[index].rating,
                                style: Theme.of(context)
                                    .textTheme
                                    .overline
                                    .copyWith(letterSpacing: 0.2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    sectionList[secPos].productList[index].name,
                    style: Theme.of(context)
                        .textTheme
                        .overline
                        .copyWith(color: black, letterSpacing: 0.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                int.parse(sectionList[secPos]
                                            .productList[index]
                                            .prVarientList[0]
                                            .disPrice) !=
                                        0
                                    ? CUR_CURRENCY +
                                        "" +
                                        sectionList[secPos]
                                            .productList[index]
                                            .prVarientList[0]
                                            .price
                                    : "",
                                style: Theme.of(context)
                                    .textTheme
                                    .overline
                                    .copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        letterSpacing: 1),
                                textAlign: TextAlign.left),
                            Text(
                              CUR_CURRENCY + " " + price.toString(),
                              style: TextStyle(color: primary),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      sectionList[secPos].productList[index].isFavLoading
                          ? Container(
                              height: 15,
                              width: 15,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 3),
                              padding: const EdgeInsets.all(3),
                              child: CircularProgressIndicator(
                                strokeWidth: 0.7,
                              ))
                          : InkWell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 3),
                                child: Icon(
                                  sectionList[secPos]
                                              .productList[index]
                                              .isFav ==
                                          "0"
                                      ? Icons.favorite_border
                                      : Icons.favorite,
                                  size: 15,
                                  color: primary,
                                ),
                              ),
                              onTap: () {
                                if (CUR_USERID != null) {
                                  sectionList[secPos]
                                              .productList[index]
                                              .isFav ==
                                          "0"
                                      ? _setFav(secPos, index)
                                      : _removeFav(secPos, index);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login()),
                                  );
                                }
                              })
                    ],
                  ),
                )
              ],
            ),
          ),
          onTap: () {
            Product model = sectionList[secPos].productList[index];
            Navigator.push(
              context,
              PageRouteBuilder(
                  transitionDuration: Duration(seconds: 1),
                  pageBuilder: (_, __, ___) => ProductDetail(
                        model: model,
                        updateParent: updateHomePage,
                        secPos: secPos,
                        index: index,
                        updateHome: widget.updateHome,
                        list: false,
                        //  title: sectionList[secPos].title,
                      )),
            );
          },
        ),
      ),
    );
  }
*/
  Widget productItem(int secPos, int index, bool pad) {
    String offPer;
    double price = double.parse(
        sectionList[secPos].productList[index].prVarientList[0].disPrice);
    if (price == 0) {
      price = double.parse(
          sectionList[secPos].productList[index].prVarientList[0].price);
    } else {
      double off = double.parse(
              sectionList[secPos].productList[index].prVarientList[0].price) -
          price;
      print("==========$off");
      offPer = ((off * 100) /
              double.parse(sectionList[secPos]
                  .productList[index]
                  .prVarientList[0]
                  .price))
          .toStringAsFixed(2);
    }

    double width = deviceWidth * 0.5;

    return Card(
      elevation: 0.2,
      margin: EdgeInsets.only(bottom: 5, right: pad ? 5 : 0),
      child: InkWell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5)),
                  child: Hero(
                    tag:
                        "${sectionList[secPos].productList[index].id}$secPos$index",
                    child: CachedNetworkImage(
                      imageUrl: sectionList[secPos].productList[index].image,
                      height: double.maxFinite,
                      width: double.maxFinite,
                      errorWidget: (context, url, e) => placeHolder(width),
                      placeholder: (context, url) => placeHolder(width),
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 5, bottom: 5),
              child: Text(
                sectionList[secPos].productList[index].name,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: lightBlack),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(" " + CUR_CURRENCY + " " + price.toString(),
                style:
                    TextStyle(color: fontColor, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, bottom: 5, top: 3),
              child: int.parse(sectionList[secPos]
                          .productList[index]
                          .prVarientList[0]
                          .disPrice) !=
                      0
                  ? Row(
                      children: <Widget>[
                        Text(
                          int.parse(sectionList[secPos]
                                      .productList[index]
                                      .prVarientList[0]
                                      .disPrice) !=
                                  0
                              ? CUR_CURRENCY +
                                  "" +
                                  sectionList[secPos]
                                      .productList[index]
                                      .prVarientList[0]
                                      .price
                              : "",
                          style: Theme.of(context).textTheme.overline.copyWith(
                              decoration: TextDecoration.lineThrough,
                              letterSpacing: 0),
                        ),
                        Text(" | " + "-$offPer%",
                            style: Theme.of(context)
                                .textTheme
                                .overline
                                .copyWith(color: primary, letterSpacing: 0)),
                      ],
                    )
                  : Container(
                      height: 5,
                    ),
            )
          ],
        ),
        onTap: () {
          Product model = sectionList[secPos].productList[index];
          Navigator.push(
            context,
            PageRouteBuilder(
                transitionDuration: Duration(seconds: 1),
                pageBuilder: (_, __, ___) => ProductDetail(
                    model: model,
                    updateParent: updateHomePage,
                    secPos: secPos,
                    index: index,
                    updateHome: widget.updateHome,
                    list: false
                    //  title: sectionList[secPos].title,
                    )),
          );
        },
      ),
    );
  }

  _setFav(int secPos, int index) async {
    try {
      setState(() {
        sectionList[secPos].productList[index].isFavLoading = true;
      });

      var parameter = {
        USER_ID: CUR_USERID,
        PRODUCT_ID: sectionList[secPos].productList[index].id
      };
      Response response =
          await post(setFavoriteApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        sectionList[secPos].productList[index].isFav = "1";
      } else {
        setSnackbar(msg);
      }

      setState(() {
        sectionList[secPos].productList[index].isFavLoading = false;
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }

  setSnackbar(String msg) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: black),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  _removeFav(int secPos, int index) async {
    try {
      setState(() {
        sectionList[secPos].productList[index].isFavLoading = true;
      });

      var parameter = {
        USER_ID: CUR_USERID,
        PRODUCT_ID: sectionList[secPos].productList[index].id
      };
      Response response =
          await post(removeFavApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        sectionList[secPos].productList[index].isFav = "0";

        favList.removeWhere((item) =>
            item.productList[0].prVarientList[0].id ==
            sectionList[secPos].productList[index].prVarientList[0].id);
      } else {
        setSnackbar(msg);
      }

      setState(() {
        sectionList[secPos].productList[index].isFavLoading = false;
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }

  Future<void> callApi() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getSlider();
      getCat();
      getSection();
      getSetting();
      getOfferImages();
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
      if (mounted)
        setState(() {
          _isCatLoading = false;
        });
    }
  }

  Future<void> getSlider() async {
    try {
      Response response = await post(getSliderApi, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        homeSliderList =
            (data as List).map((data) => new Model.fromSlider(data)).toList();
      } else {
        setSnackbar(msg);
      }
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }

  Future<void> getCat() async {
    try {
      var parameter = {
        CAT_FILTER: "false",
      };
      Response response =
          await post(getCatApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        catList =
            (data as List).map((data) => new Product.fromCat(data)).toList();
      } else {
        setSnackbar(msg);
      }
      if (mounted)
        setState(() {
          _isCatLoading = false;
        });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      if (mounted)
        setState(() {
          _isCatLoading = false;
        });
    }
  }

  Future<void> getSection() async {
    try {
      var parameter = {PRODUCT_LIMIT: "4", PRODUCT_OFFSET: "0"};

      if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
      Response response =
          await post(getSectionApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        sectionList.clear();
        sectionList = (data as List)
            .map((data) => new Section_Model.fromJson(data))
            .toList();
      } else {
        setSnackbar(msg);
      }

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted)
          setState(() {
            _isCatLoading = false;
          });
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isCatLoading = false;
      });
    }
  }

  Future<void> getSetting() async {
    try {
      CUR_USERID = await getPrefrence(ID);

      var parameter;
      if (CUR_USERID != null) parameter = {USER_ID: CUR_USERID};

      Response response = await post(getSettingApi,
              body: CUR_USERID != null ? parameter : null, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print('response***setting**cartcount***${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"]["system_settings"][0];
        CUR_CURRENCY = data["currency"];
        RETURN_DAYS = data['max_product_return_days'];
        MAX_ITEMS = data["max_items_cart"];
        print("max items*****$MAX_ITEMS");
        CUR_CART_COUNT = getdata["data"]["user_data"][0]["cart_total_items"];

        CUR_BALANCE = getdata["data"]["user_data"][0]["balance"];

        print("Cart Count*****$CUR_CART_COUNT");
        widget.updateHome();
      } else {
        setSnackbar(msg);
      }
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }

  Future<void> getOfferImages() async {
    try {
      Response response = await post(getOfferImageApi, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        offerImages.clear();
        offerImages =
            (data as List).map((data) => new Model.fromSlider(data)).toList();
      } else {
        setSnackbar(msg);
      }

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isCatLoading = false;
        });
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isCatLoading = false;
      });
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop/Intro_Slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Home.dart';
import 'main.dart';
import 'package:http/http.dart' as http;

//splash screen of app
class Splash extends StatefulWidget {
  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    firebaseCloudMessaging_Listeners();
    firNotificationInitialize();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: back(),
            child: Center(
              child: Image.asset(
                'assets/images/homelogo.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
          Image.asset(
            'assets/images/doodle.png',
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      ),
    );
  }

  startTime() async {
    var _duration = Duration(seconds: 2);
    return Timer(_duration, checkNetwork);
  }

  Future<void> navigationPage() async {
    bool isFirstTime = await getPrefrenceBool(ISFIRSTTIME);
    print("first ***$isFirstTime");
    if (isFirstTime) {


     Navigator.pushReplacementNamed(context, "/home");
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Intro_Slider(),
          ));
    }
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

/*  void _registerToken(String token, String uid) async {
    var parameter = {USER_ID: uid, FCM_ID: token};

    Response response =
        await post("$SET_FCM", body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

    // print('Response status: ${response.statusCode}');
    //  print('Response body: ${response.body}***$token_api**$data');

    var getdata = json.decode(response.body);

    print("set token**${response.body.toString()}");
    //var error = getdata['error'].toString();
    // if (error.compareTo('false') == 0) {}
  }*/

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      //  print("Settings registered: $settings");
    });
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      navigationPage();
    } else {
      setSnackbar(internetMsg);
    }
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

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }
}

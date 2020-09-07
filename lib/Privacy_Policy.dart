import 'dart:async';
import 'dart:convert';

import 'package:eshop/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart';

import 'Helper/Constant.dart';
import 'Helper/String.dart';

class Privacy_Policy extends StatefulWidget {
  final String title;

  const Privacy_Policy({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePrivacy();
  }
}

class StatePrivacy extends State<Privacy_Policy> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String privacy;

  @override
  void initState() {
    super.initState();
    getSetting();
  }

  @override
  Widget build(BuildContext context) {
    print("data****$_isLoading***$privacy");

    return _isLoading
        ? Scaffold(
            key: _scaffoldKey,
            appBar: getAppBar(widget.title, context),
            body: getProgress(),
          )
        : privacy != null
            ? WebviewScaffold(
                appBar: getAppBar(widget.title, context),
                withJavascript: true,
                appCacheEnabled: true,

                // hidden: true,
                url: new Uri.dataFromString(privacy,
                        mimeType: 'text/html', encoding: utf8)
                    .toString(),
              )
            : Scaffold(
                key: _scaffoldKey,
                appBar: getAppBar(widget.title, context),
                body: Container(),
              );
  }

  Future<void> getSetting() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      try {
        String type;
        if(widget.title==PRIVACY)
          type=PRIVACY_POLLICY;
        else if(widget.title==TERM)
          type=TERM_COND;
        else if(widget.title==CONTACT)
          type=CONTACT_US;



        var parameter = {TYPE: type};
        Response response =
            await post(getSettingApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print('response***setting**$headers***${response.body.toString()}');
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          privacy = getdata["data"].toString();
        } else {
          setSnackbar(msg);
        }
        setState(() {
          _isLoading = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
      }
    } else {
      setSnackbar(internetMsg);
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
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 1.0,
    ));
  }
}

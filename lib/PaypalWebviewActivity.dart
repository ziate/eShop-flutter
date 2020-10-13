import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';


import 'package:webview_flutter/webview_flutter.dart';


class PaypalWebviewActivity extends StatefulWidget {
  String mainurl, from, amount, detail;

  VoidCallback refresh, homeRefresh;

  PaypalWebviewActivity();

  @override
  State<StatefulWidget> createState() {
    return PayPalWebview();
  }
}

class PayPalWebview extends State<PaypalWebviewActivity> {
  String mainurl, from, amount, detail;
  String message = "";

  //PayPalWebview(this.mainurl, this.from, this.amount, this.detail);

  bool isloading = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    print("paypalurl--$mainurl");
    //mainurl = mainurl + "&hash=" + Constant.CreatesJwt("paypal");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: BlankBar(),
        body:
            //isloading ? Center(child: new CircularProgressIndicator(),) :
            Stack(
          children: <Widget>[
            WebView(
              initialUrl: 'http://sinel.kasemorgh.com/paypal_api/PaypalAPI?amount=2&id=1&title=Scan%20Order',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              javascriptChannels: <JavascriptChannel>[
                _toasterJavascriptChannel(context),
              ].toSet(),
              // ignore: missing_return
              navigationDelegate: (NavigationRequest request) {},
              onPageFinished: (String url) {
                // print('Page finished loading: $url');
              },
            ),
            isloading
                ? Center(
                    child: new CircularProgressIndicator(),
                  )
                : Container(),
            message.trim().isEmpty
                ? Container()
                : Center(
                    child: Container(

                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.all(5),
                        child: Text(
                          message,

                        )))
          ],
        ));
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }



  void FinishPage(String finishmessage) {
    setState(() {
      message = finishmessage;
    });
    Timer(Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }


}

class BlankBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);
}

/*class PayPalWebview extends State<PaypalWebviewActivity> {
  String mainurl;
  PayPalWebview(this.mainurl);
  bool isloading = false;

  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<String> _onUrlChanged;


  @override
  void initState() {
    mainurl = mainurl + "&hash=" + Constant.CreatesJwt("paypal");
    print("===mainurl==$mainurl");

    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      if (mounted) {
        print("===url===new : $url");
        if (url.startsWith(Constant.PaypalResponse)) {
          //String urlmain = url;
          flutterWebviewPlugin.stopLoading();

          setState(() {
            isloading = true;
          });
          var response = await Constant.getApiData(url, new Map<String, String>());

          final res = json.decode(response);
          Scaffold.of(context).showSnackBar(res['message']);
          if(res['error']){
            setState(() {
              isloading = false;
            });
            Navigator.pop(context);
          }else{
            Map<String, String> body = {
              Constant.USER_ID: SplashScreen.session.getData(UserSessionManager.KEY_ID),
            };
            var response = await Constant.getApiData(Constant.GET_USER_BY_ID, body);
            setState(() {
              isloading = false;
            });
            final res = json.decode(response);
            bool error = res['error'];
            if (!error) {
              SplashScreen.session.setData(UserSessionManager.KEY_COIN, res['data'][Constant.COIN]);
            }
            Navigator.pop(context);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _onUrlChanged.cancel();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isloading ? new CircularProgressIndicator() : new Container(color: ColorsRes.bgcolor,child:WebviewScaffold(
    key: scaffoldKey,
    url: mainurl,
    hidden: true,
        withJavascript: true,
        withOverviewMode: true,
        clearCache: true,
        scrollBar: true,

    ));

  }



}*/

/*@override
  void initState() {
    mainurl = mainurl + "&hash=" + Constant.CreatesJwt("paypal");
  }

  @override
  Widget build(BuildContext context) {
    return isloading ? new CircularProgressIndicator() : new Container(color: ColorsRes.bgcolor,child:InAppWebView(
      initialUrl: mainurl,
      onWebViewCreated: (InAppWebViewController controller) {
        controller = controller;
      },
      onLoadStart: (InAppWebViewController controller, String url) async {
        if(url.startsWith(Constant.PaypalResponse)) {     // Add your URL here
            controller.stopLoading();
            setState(() {
              isloading = true;
            });
            var response = await Constant.getApiData(url, new Map<String, String>());


            final res = json.decode(response);
            Scaffold.of(context).showSnackBar(res['message']);
            if(res['error']){
              setState(() {
                isloading = false;
              });
              Navigator.pop(context);
            }else{
              Map<String, String> body = {
                Constant.USER_ID: SplashScreen.session.getData(UserSessionManager.KEY_ID),
              };
              var response = await Constant.getApiData(Constant.GET_USER_BY_ID, body);
              setState(() {
                isloading = false;
              });
              final res = json.decode(response);
              bool error = res['error'];
              if (!error) {
                SplashScreen.session.setData(UserSessionManager.KEY_COIN, res['data'][Constant.COIN]);
              }
              Navigator.pop(context);
            }
        }else{
          controller.loadUrl(url: url);
        }
      },
    ));
  }*/

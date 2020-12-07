import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/String.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'Order_Success.dart';

class PaypalWebview extends StatefulWidget {
  final String url;

  const PaypalWebview({Key key, this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePayPalWebview();
  }
}

class StatePayPalWebview extends State<PaypalWebview> {
  // String mainurl, from, amount, detail;
  String message = "";

  bool isloading = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  @override
  void initState() {
    // print("paypalurl--$mainurl");
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
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              javascriptChannels: <JavascriptChannel>[
                _toasterJavascriptChannel(context),
              ].toSet(),
              navigationDelegate: (NavigationRequest request) async {
                if (request.url.startsWith(PAYPAL_RESPONSE_URL)) {
                  setState(() {
                    isloading = true;
                  });

                  String responseurl = request.url;

                  if (responseurl.contains("Failed") ||
                      responseurl.contains("failed")) {
                    setState(() {
                      isloading = false;
                      message = "Transaction Failed";
                    });
                    Timer(Duration(seconds: 1), () {
                      Navigator.pop(context);
                    });
                  } else if (responseurl.contains("Completed") ||
                      responseurl.contains("completed")) {
                    setState(() {
                      setState(() {
                        message = "Transaction Successfull";
                      });
                    });
                    List<String> testdata = responseurl.split("&");
                    for (String data in testdata) {
                      print("==id=====--${data}");
                      if (data.split("=")[0].toLowerCase() == "tx") {
                        String txid = data.split("=")[1];
                        //print("==id=********=$data===$txid");

                        /*   if (from == Constant.lblWallet) {
                          AddMoneyToWallet();
                        } else
                          SetTransactionData(txid, "Paypal");*/

                        CUR_CART_COUNT = "0";

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => OrderSuccess()),
                            ModalRoute.withName('/home'));

                        break;
                      }
                    }
                  }

                  return NavigationDecision.prevent;
                }

                print('allowing navigation to $request');
                return NavigationDecision.navigate;
              },
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
                    color: primary,
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.all(5),
                    child: Text(
                      message,
                      style: TextStyle(color: white),
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
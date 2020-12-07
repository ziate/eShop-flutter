import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:eshop/Add_Address.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Home.dart';
import 'package:eshop/Model/Model.dart';
import 'package:eshop/Model/Section_Model.dart';
import 'package:eshop/Model/User.dart';
import 'package:eshop/PaypalWebviewActivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'Helper/AppBtn.dart';
import 'Helper/SimBtn.dart';
import 'Test.dart';
import 'Cart.dart';
import 'Helper/Color.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Order_Success.dart';

class CheckOut extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateCheckout();
  }
}

List<User> addressList = [];
String latitude, longitude, selAddress, payMethod, selTime, selDate, promocode;
int selectedTime, selectedDate, selectedMethod;
bool _isTimeSlot,
    _isPromoValid = false,
    _isUseWallet = false,
    _isPayLayShow = true;
double promoAmt = 0;
double remWalBal, usedBal = 0;
String razorpayId, paystackId;

StateCheckout stateCheck;

class StateCheckout extends State<CheckOut> with TickerProviderStateMixin {
  int _curIndex = 0;
  Razorpay _razorpay;
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Widget> fragments;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true, _isProgress = false;

  @override
  void initState() {
    super.initState();
    promoAmt = 0;
    remWalBal = 0;
    usedBal = 0;
    _isPromoValid = false;
    _isUseWallet = false;
    _isPayLayShow = true;
    stateCheck = new StateCheckout();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);


    fragments = [Delivery(updateCheckout), Address(), Payment(updateCheckout)];
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
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
    _razorpay.clear();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: getAppBar(CHECKOUT, context),
      body: _isNetworkAvail
          ? Stack(
              children: <Widget>[
                Column(
                  children: [
                    stepper(),
                    Divider(),
                    Expanded(child: fragments[_curIndex]),
                  ],
                ),
                showCircularProgress(_isProgress, primary),
              ],
            )
          : noInternet(context),
      persistentFooterButtons: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                width: deviceWidth * 0.6,
                child: Text(
                  TOTAL + " : " + CUR_CURRENCY + " " + totalPrice.toString(),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Container(
                alignment: Alignment.center,
                height: 35,
                width: deviceWidth * 0.3,
                decoration: new BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [grad1Color, grad2Color],
                      stops: [0, 1]),
                  borderRadius:
                      new BorderRadius.all(const Radius.circular(10.0)),
                ),
                child: TextButton.icon(
                    icon: Icon(
                      _curIndex == 2 ? Icons.check : Icons.navigate_next,
                      color: white,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_curIndex == 0) {
                          _curIndex = _curIndex + 1;
                        } else if (_curIndex == 1) {
                          if (selAddress == null || selAddress.isEmpty)
                            setSnackbar(addressWarning);
                          else
                            _curIndex = _curIndex + 1;
                        } else if (_curIndex == 2) {
                          if (_isTimeSlot &&
                              (selDate == null || selDate.isEmpty))
                            setSnackbar(dateWarning);
                          else if (_isTimeSlot &&
                              (selTime == null || selTime.isEmpty))
                            setSnackbar(timeWarning);
                          else if (payMethod == null || payMethod.isEmpty)
                            setSnackbar(payWarning);
                          else if (payMethod == PAYPAL_LBL)
                            placeOrder('');
                          else if (payMethod == RAZORPAY_LBL)
                            razorpayPayment();
                          else if (payMethod == PAYSTACK_LBL)
                            paystackPayment(context);
                          else
                            placeOrder('');
                        }
                      });
                    },
                    label: Text(_curIndex == 2 ? PROCEED : CONTINUE,
                        style: Theme.of(context).textTheme.button.copyWith(
                            color: white, fontWeight: FontWeight.normal))))
          ],
        )
      ],
      /*  Stepper(
        type: StepperType.horizontal,
        steps: [
          Step(
            isActive: _curIndex == 0,
            title: Text(DELIVERY,
                style: TextStyle(color: _curIndex == 0 ? primary : null)),
            content: _delivery(),
          ),
          Step(
            isActive: _curIndex == 1,
            title: Text(ADDRESS_LBL,
                style: TextStyle(color: _curIndex == 1 ? primary : null)),
            content: _address(),
          ),
          Step(
            isActive: _curIndex == 2,
            title: Text(
              PAYMENT,
              style: TextStyle(color: _curIndex == 2 ? primary : null),
            ),
            content: _payment(),
          ),
        ],
        currentStep: _curIndex,
        onStepTapped: (index) {
          setState(() {
            _curIndex = index;
          });
        },
        onStepCancel: () {
          print("You are clicking the cancel button.");
        },
        onStepContinue: () {
          setState(() {
            if (_curIndex < 2) {
              _curIndex = _curIndex + 1;
            } else {
              _curIndex = 0;
            }
          });
        },
        controlsBuilder: (BuildContext context,
            {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
          return Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _curIndex == 2 // this is the last step
                  ? RaisedButton.icon(
                      icon: Icon(Icons.check),
                      onPressed: onStepContinue,
                      label: Text('CREATE'),
                      color: primary,
                    )
                  : RaisedButton.icon(
                      icon: Icon(
                        Icons.navigate_next,
                        color: white,
                      ),
                      onPressed: onStepContinue,
                      label: Text(
                        CONTINUE,
                        style: TextStyle(color: white),
                      ),
                      color: primary,
                    ),
            ),
          );
        },
      ),*/
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("SUCCESS: " + response.paymentId + "===" + response.toString());

    placeOrder(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("ERROR: " + response.code.toString() + " - " + response.message);
    setSnackbar(response.message);
    setState(() {
      _isProgress = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("EXTERNAL_WALLET: " + response.walletName);
  }

  razorpayPayment() async {
    String contact = await getPrefrence(MOBILE);
    String email = await getPrefrence(EMAIL);

    print("phone***********$contact****$email");
    double amt = totalPrice * 100;
    print("total==========$totalPrice***$amt");

    if (contact != '' && email != '') {
      var options = {
        KEY: razorpayId,
        AMOUNT: amt.toString(),
        NAME: CUR_USERNAME,
        // 'description': 'Fine T-Shirt',
        'prefill': {CONTACT: contact, EMAIL: email},
        'external': {
          'wallets': ['paytm']
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint(e);
      }
    } else {
      if (email == '')
        setSnackbar(emailWarning);
      else if (contact == '') setSnackbar(phoneWarning);
    }
  }

  paystackPayment(BuildContext context) async {
    setState(() {
      _isProgress = true;
    });

    String email = await getPrefrence(EMAIL);

    Charge charge = Charge()
      ..amount = totalPrice.toInt()
      ..reference = _getReference()
      ..email = email;

    try {
      CheckoutResponse response = await PaystackPlugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,

      );
if(response.status)
  {
    placeOrder(response.reference);
  }else{
  //print("ERROR: " + response.code.toString() + " - " + response.message);
  setSnackbar(response.message);
  setState(() {
    _isProgress = false;
  });
  }

     // setState(() => _isProgress = false);
      //_updateStatus(response.reference, '$response');
      print("response=========${response.reference}====$response");
    } catch (e) {
      setState(() => _isProgress = false);
      // _showMessage("Check console for error");
      rethrow;
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  updateCheckout() {
    setState(() {});
  }

  confirmOrder() {
    return CupertinoAlertDialog(
        title: Text(
          CONFIRM_ORDER,
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: lightBlack2,
              ),
          textAlign: TextAlign.center,
        ),
        actions: [
          CupertinoDialogAction(
              child: Text(
                CANCEL,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: primary),
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              }),
          CupertinoDialogAction(
              child: Text(
                CONFIRM,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: primary),
                textAlign: TextAlign.center,
              ),
              onPressed: () {}),
        ]);
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

  /* _delivery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                PROMOCODE,
              ),
            ),
            Spacer(),
            Icon(Icons.refresh)
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  hintText: 'Promo Code..',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primary),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: RaisedButton(
                onPressed: () {},
                child: Text(
                  'Apply',
                  style: TextStyle(color: white),
                ),
                color: primary,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0, top: 20),
          child: Text(
            ORDER_SUMMARY,
            style: Theme
                .of(context)
                .textTheme
                .headline6,
          ),
        ),
        Row(
          children: [
            Expanded(flex: 5, child: Text(PRODUCTNAME)),
            Expanded(flex: 1, child: Text(QUANTITY)),
            Expanded(flex: 2, child: Text(PRICE_LBL)),
            Expanded(flex: 2, child: Text(SUBTOTAL)),
          ],
        ),
        Divider(),
        ListView.builder(
            shrinkWrap: true,
            itemCount: cartList.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return orderItem(index);
            }),
        Padding(
          padding:
          const EdgeInsets.only(top: 28, bottom: 8.0, left: 35, right: 35),
          child: Row(
            children: <Widget>[
              Text(
                ORIGINAL_PRICE,
              ),
              Spacer(),
              Text(CUR_CURRENCY + "$oriPrice")
            ],
          ),
        ),
        Padding(
          padding:
          const EdgeInsets.only(left: 35, right: 35, top: 8, bottom: 8),
          child: Row(
            children: <Widget>[
              Text(
                DELIVERY_CHARGE,
              ),
              Spacer(),
              Text(CUR_CURRENCY + " $delCharge")
            ],
          ),
        ),
        Padding(
          padding:
          const EdgeInsets.only(left: 35, right: 35, top: 8, bottom: 8),
          child: Row(
            children: <Widget>[
              Text(
                TAXPER + "($taxPer %)",
              ),
              Spacer(),
              Text(CUR_CURRENCY + " $taxAmt")
            ],
          ),
        ),
        Divider(
          color: black,
          thickness: 1,
          indent: 20,
          endIndent: 20,
        ),
        Padding(
          padding:
          const EdgeInsets.only(top: 8.0, bottom: 8, left: 35, right: 35),
          child: Row(
            children: <Widget>[
              Text(
                Total_PRICE,
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                CUR_CURRENCY + " $totalPrice",
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ],
    );
  }
*/

  stepper() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          InkWell(
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _curIndex == 0 ? primary : Colors.grey,
                  ),
                  width: 20,
                  height: 20,
                  child: Center(
                    child: Text(
                      "1",
                      style: TextStyle(color: white),
                    ),
                  ),
                ),
                Text("  " + DELIVERY + "  ",
                    style: TextStyle(color: _curIndex == 0 ? primary : null)),
              ],
            ),
            onTap: () {
              setState(() {
                _curIndex = 0;
              });
            },
          ),
          Expanded(child: Divider()),
          InkWell(
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _curIndex == 1 ? primary : Colors.grey,
                  ),
                  width: 20,
                  height: 20,
                  child: Center(
                    child: Text(
                      "2",
                      style: TextStyle(color: white),
                    ),
                  ),
                ),
                Text("  " + ADDRESS_LBL + "  ",
                    style: TextStyle(color: _curIndex == 1 ? primary : null)),
              ],
            ),
            onTap: () {
              if (selAddress != null) {
                setState(() {
                  _curIndex = 1;
                });
              }
            },
          ),
          Expanded(child: Divider()),
          InkWell(
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _curIndex == 2 ? primary : Colors.grey,
                  ),
                  width: 20,
                  height: 20,
                  child: Center(
                    child: Text(
                      "3",
                      style: TextStyle(color: white),
                    ),
                  ),
                ),
                Text("  " + PAYMENT + "  ",
                    style: TextStyle(color: _curIndex == 2 ? primary : null)),
              ],
            ),
            onTap: () {
              if (payMethod != null) {
                setState(() {
                  _curIndex = 2;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> placeOrder(String tranId) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      String mob = await getPrefrence(MOBILE);
      String varientId, quantity;
      for (Section_Model sec in cartList) {
        varientId =
            varientId != null ? varientId + "," + sec.varientId : sec.varientId;
        quantity = quantity != null ? quantity + "," + sec.qty : sec.qty;
      }

      print("after***$varientId***$quantity");

      try {
        var parameter = {
          USER_ID: CUR_USERID,
          MOBILE: mob,
          PRODUCT_VARIENT_ID: varientId,
          QUANTITY: quantity,
          TOTAL: oriPrice.toString(),
          DELIVERY_CHARGE: delCharge.toString(),
          TAX_AMT: taxAmt.toString(),
          TAX_PER: taxPer.toString(),
          FINAL_TOTAL: totalPrice.toString(),
          /*   LATITUDE: latitude,
        LONGITUDE: longitude,*/
          PAYMENT_METHOD: payMethod,
          ADD_ID: selAddress,
          ISWALLETBALUSED: _isUseWallet ? "1" : "0",
          WALLET_BAL_USED: usedBal.toString(),
        };

        if (_isTimeSlot) {
          parameter[DELIVERY_TIME] = selTime;
          parameter[DELIVERY_DATE] = selDate;
        }
        if (_isPromoValid) {
          parameter[PROMOCODE] = promocode;
          parameter[PROMO_DIS] = promoAmt.toString();
        }

        if (payMethod == PAYPAL_LBL) {
          parameter[ACTIVE_STATUS] = WAITING;
        }

        print("param****${parameter.toString()}");
        Response response =
            await post(placeOrderApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print('response***setting****$CUR_USERID**${response.body.toString()}');
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          String orderId = getdata["order_id"].toString();
          if (payMethod == RAZORPAY_LBL) {
            AddTransaction(tranId, orderId, SUCCESS, msg);
          } else if (payMethod == PAYPAL_LBL) {
            paypalPayment(orderId);
          } else {
            CUR_CART_COUNT = "0";

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => OrderSuccess()),
                ModalRoute.withName('/home'));
          }
        } else {
          setSnackbar(msg);
        }
        setState(() {
          _isProgress = false;
        });
      } on TimeoutException catch (_) {
        setState(() {
          _isProgress = false;
        });
        //  setSnackbar(somethingMSg);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Future<void> paypalPayment(String orderId) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        ORDER_ID: orderId,
      };
      Response response =
          await post(paypalTransactionApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));
      print('response***${parameter.toString()}');

      var getdata = json.decode(response.body);

      print('response***slider**${response.body.toString()}***$headers');

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        String data = getdata["data"];
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => PaypalWebview(
                      url: data,
                    )));

        /*      CUR_CART_COUNT = "0";

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => OrderSuccess()),
            ModalRoute.withName('/home'));*/
      } else {
        setSnackbar(msg);
      }
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }

  Future<void> AddTransaction(
      String tranId, String orderID, String status, String msg) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        ORDER_ID: orderID,
        TYPE: payMethod,
        TXNID: tranId,
        AMOUNT: totalPrice.toString(),
        STATUS: status,
        MSG: msg
      };
      Response response =
          await post(addTransactionApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print('response***${parameter.toString()}');
      print('response***slider**${response.body.toString()}***$headers');

      bool error = getdata["error"];
      String msg1 = getdata["message"];
      if (!error) {
        //var data = getdata["data"];
        CUR_CART_COUNT = "0";

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => OrderSuccess()),
            ModalRoute.withName('/home'));
      } else {
        setSnackbar(msg1);
      }
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }
}

class Delivery extends StatefulWidget {
  Function update;

  Delivery(this.update);

  @override
  State<StatefulWidget> createState() {
    return StateDelivery();
  }
}

class StateDelivery extends State<Delivery> with TickerProviderStateMixin {
  TextEditingController promoC = new TextEditingController();

  // static   GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isProgress = false;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightWhite,
      body: _isNetworkAvail
          ? Stack(
              children: <Widget>[
                _deliveryContent(),
                showCircularProgress(_isProgress, primary),
              ],
            )
          : noInternet(context),
    );
  }

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

/*  static setSnackbar(String msg) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: black),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }*/

  orderItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: Text(
                cartList[index].productList[0].name,
              )),
          Expanded(
              flex: 1,
              child: Text(
                cartList[index].qty,
                textAlign: TextAlign.end,
              )),
          Expanded(
              flex: 1,
              child: Text(
                cartList[index].productList[0].tax + "%",
                textAlign: TextAlign.end,
              )),
          Expanded(
              flex: 2,
              child: Text(
                cartList[index].perItemTotal,
                textAlign: TextAlign.end,
              )),
          Expanded(
              flex: 2,
              child: Text(
                cartList[index].perItemTotal,
                textAlign: TextAlign.end,
              )),
        ],
      ),
    );
  }

  Future<void> validatePromo() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          _isProgress = true;
        });

        var parameter = {
          USER_ID: CUR_USERID,
          PROMOCODE: promoC.text,
          FINAL_TOTAL: totalPrice.toString()
        };
        Response response =
            await post(validatePromoApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print('response***promo*****${response.body.toString()}');
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"][0];

          String disType = data["discount_type"];
          String dis = data["discount"];

          promocode = data["promo_code"];
          if (disType.toLowerCase() == "percentage") {
            promoAmt = (oriPrice * double.parse(dis)) / 100;
          } else if (disType.toLowerCase() == "amount") {
            promoAmt = double.parse(dis);
          }
          totalPrice = totalPrice - promoAmt;

          _isPromoValid = true;
          stateCheck.setSnackbar(PROMO_SUCCESS);
        } else {
          stateCheck.setSnackbar(msg);
        }
        setState(() {
          _isProgress = false;
        });
      } on TimeoutException catch (_) {
        stateCheck.setSnackbar(somethingMSg);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  _deliveryContent() {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        PROMOCODE_LBL,
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      child: Icon(Icons.refresh),
                      onTap: () {
                        if (promoAmt != 0) {
                          setState(() {
                            totalPrice = totalPrice + promoAmt;
                            promoC.text = '';
                            _isPromoValid = false;
                            promoAmt = 0;
                            promocode = '';
                            widget.update();
                          });
                        }
                      },
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: promoC,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(
                            10,
                          ),
                          hintText: 'Promo Code..',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primary),
                          ),
                        ),
                      ),
                    ),
                    SimBtn(
                      title: APPLY,
                      size: deviceWidth * 0.2,
                      onBtnSelected: () async {
                        if (promoC.text.trim().isEmpty)
                          stateCheck.setSnackbar(ADD_PROMO);
                        else
                          validatePromo();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0, top: 10),
                  child: Text(
                    ORDER_SUMMARY,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Row(
                  children: [
                    Expanded(flex: 4, child: Text(PRODUCTNAME)),
                    Expanded(
                        flex: 1,
                        child: Text(
                          QUANTITY_LBL,
                          textAlign: TextAlign.end,
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          TAXPER,
                          textAlign: TextAlign.end,
                        )),
                    Expanded(
                        flex: 2,
                        child: Text(
                          PRICE_LBL,
                          textAlign: TextAlign.end,
                        )),
                    Expanded(
                        flex: 2,
                        child: Text(
                          SUBTOTAL,
                          textAlign: TextAlign.end,
                        )),
                  ],
                ),
                Divider(),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: cartList.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return orderItem(index);
                    }),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 28, bottom: 8.0, left: 35, right: 35),
                  child: Row(
                    children: <Widget>[
                      Text(
                        SUB,
                      ),
                      Spacer(),
                      Text(CUR_CURRENCY + "$oriPrice")
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 35, right: 35, top: 8, bottom: 8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        DELIVERY_CHARGE,
                      ),
                      Spacer(),
                      Text(CUR_CURRENCY + " $delCharge")
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 35, right: 35, top: 8, bottom: 8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        TAXPER + "($taxPer %)",
                      ),
                      Spacer(),
                      Text(CUR_CURRENCY + " $taxAmt")
                    ],
                  ),
                ),
                _isPromoValid
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: 35, right: 35, top: 8, bottom: 8),
                        child: Row(
                          children: <Widget>[
                            Text(
                              PROMO_LBL + " ($promocode)",
                            ),
                            Spacer(),
                            Text(CUR_CURRENCY + " $promoAmt")
                          ],
                        ),
                      )
                    : Container(),
                Divider(
                  color: black,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 8, left: 35, right: 35),
                  child: Row(
                    children: <Widget>[
                      Text(
                        TOTAL_PRICE,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Text(
                        CUR_CURRENCY + " $totalPrice",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

class Address extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateAddress();
  }
}

int selectedAddress;

class StateAddress extends State<Address> with TickerProviderStateMixin {
  bool _isLoading = true;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;

  @override
  void initState() {
    super.initState();
    addressList.clear();
    _getAddress();
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
                  _getAddress();
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

  @override
  Widget build(BuildContext context) {
    return _isNetworkAvail
        ? Column(
            children: [
              Expanded(
                child: _isLoading
                    ? getProgress()
                    : addressList.length == 0
                        ? Text(NOADDRESS)
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: addressList.length,
                            itemBuilder: (context, index) {
                              print(
                                  "default***b${addressList[index].isDefault}***${addressList[index].name}");

                              return addressItem(index);
                            }),
              ),
              Container(
                  alignment: Alignment.center,
                  height: 35,
                  width: deviceWidth * 0.4,
                  decoration: new BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [secondary, primary],
                        stops: [0, 1]),
                    borderRadius:
                        new BorderRadius.all(const Radius.circular(10.0)),
                  ),
                  child: TextButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddAddress(
                                    update: false,
                                  )),
                        );
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.add,
                        color: white,
                      ),
                      label: Text(ADDADDRESS,
                          style: Theme.of(context).textTheme.button.copyWith(
                              color: white, fontWeight: FontWeight.normal))))
            ],
          )
        : noInternet(context);
  }

  addressItem(int index) {
    print(
        "default***${addressList[index].isDefault}***${addressList[index].name}**$selectedAddress");
    if (addressList[index].isDefault == "1") {
      selectedAddress = index;
      selAddress = addressList[index].id;
    }
    return RadioListTile(
      value: (index),
      groupValue: selectedAddress,
      onChanged: (val) {
        setState(() {
          selectedAddress = val;
          selAddress = addressList[index].id;
        });
      },
      title: Row(
        children: [
          Expanded(
              child: Row(
            children: [
              Text(
                addressList[index].name + "  ",
                style: TextStyle(color: lightBlack),
              ),
              Container(
                decoration: BoxDecoration(
                    color: fontColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.all(3),
                child: Text(
                  addressList[index].type,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: fontColor),
                ),
              )
            ],
          )),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(
                Icons.edit,
                color: black54,
                size: 17,
              ),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddAddress(
                          update: true,
                          index: index,
                        )),
              );
              setState(() {});
            },
          ),
          InkWell(
            onTap: () {
              deleteAddress(index);
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(
                Icons.delete,
                color: black54,
                size: 17,
              ),
            ),
          )
        ],
      ),
      isThreeLine: true,
      subtitle: Text(addressList[index].address +
          ", " +
          addressList[index].area +
          ", " +
          addressList[index].city +
          ", " +
          addressList[index].state +
          ", " +
          addressList[index].country +
          "\n" +
          addressList[index].mobile),
    );
  }

  Future<void> deleteAddress(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ID: addressList[index].id,
        };
        Response response =
            await post(deleteAddressApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print('response***delete****$CUR_USERID**${response.body.toString()}');
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          selAddress = "";
          addressList.removeWhere((item) => item.id == addressList[index].id);
        } else {
          //  if (msg != 'Cart Is Empty !') setSnackbar(msg);
        }
        setState(() {
          _isLoading = false;
        });
        setState(() {});
      } on TimeoutException catch (_) {
        // setSnackbar(somethingMSg);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Future<void> _getAddress() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          USER_ID: CUR_USERID,
        };
        Response response =
            await post(getAddressApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print('response***setting****$CUR_USERID**${response.body.toString()}');
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          addressList =
              (data as List).map((data) => new User.fromAddress(data)).toList();
        } else {
          //if (msg != 'Cart Is Empty !') setSnackbar(msg);
        }
        setState(() {
          _isLoading = false;
        });
      } on TimeoutException catch (_) {
        //  setSnackbar(somethingMSg);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

/*  setSnackbar(String msg) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: black),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }*/

}

class Payment extends StatefulWidget {
  Function update;

  Payment(this.update);

  @override
  State<StatefulWidget> createState() {
    return StatePayment();
  }
}

class StatePayment extends State<Payment> with TickerProviderStateMixin {
  bool _isLoading = true;
  String allowDay, startingDate;
  List<Model> timeSlotList = [];
  bool cod, paypal, razorpay, paumoney, paystack, flutterwave;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<String> paymentMethodList = [
    COD_LBL,
    PAYPAL_LBL,
    PAYUMONEY_LBL,
    RAZORPAY_LBL,
    PAYSTACK_LBL,
    FLUTTERWAVE_LBL
  ];
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;

  @override
  void initState() {
    super.initState();
    _getdateTime();

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
                  _getdateTime();
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

  @override
  Widget build(BuildContext context) {
    print("cur***$CUR_BALANCE");
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      body: _isNetworkAvail
          ? _isLoading
              ? getProgress()
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Card(
                        child: CUR_BALANCE != "0" &&
                                CUR_BALANCE.isNotEmpty &&
                                CUR_BALANCE != ""
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: CheckboxListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.all(0),
                                  value: _isUseWallet,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _isUseWallet = value;

                                      if (value) {
                                        if (totalPrice <=
                                            double.parse(CUR_BALANCE)) {
                                          remWalBal =
                                              double.parse(CUR_BALANCE) -
                                                  totalPrice;

                                          usedBal = totalPrice;
                                          payMethod = "Wallet";
                                          _isPayLayShow = false;
                                        } else {
                                          remWalBal = 0;
                                          usedBal = double.parse(CUR_BALANCE);
                                          _isPayLayShow = true;
                                        }

                                        totalPrice = totalPrice - usedBal;
                                      } else {
                                        totalPrice = totalPrice + usedBal;
                                        remWalBal = double.parse(CUR_BALANCE);
                                        payMethod = null;
                                        usedBal = 0;
                                        _isPayLayShow = true;
                                      }

                                      widget.update();
                                    });
                                  },
                                  title: Text(
                                    USE_WALLET,
                                    style:
                                        TextStyle(fontSize: 15, color: primary),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      _isUseWallet
                                          ? REMAIN_BAL +
                                              " : " +
                                              CUR_CURRENCY +
                                              " " +
                                              remWalBal.toString()
                                          : TOTAL_BAL +
                                              " : " +
                                              CUR_CURRENCY +
                                              " " +
                                              CUR_BALANCE,
                                      style:
                                          TextStyle(fontSize: 15, color: black),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ),
                      _isTimeSlot
                          ? Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      PREFERED_TIME,
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ),
                                  Container(
                                    height: 90,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: int.parse(allowDay),
                                        itemBuilder: (context, index) {
                                          return dateCell(index);
                                        }),
                                  ),
                                  Divider(),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: timeSlotList.length,
                                      itemBuilder: (context, index) {
                                        return timeSlotItem(index);
                                      })
                                ],
                              ),
                            )
                          : Container(),
                      _isPayLayShow
                          ? Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      PAYMENT_METHOD_LBL,
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: 7,
                                      itemBuilder: (context, index) {
                                        if (index == 0 && cod)
                                          return paymentItem(index);
                                        else if (index == 1 && paypal)
                                          return paymentItem(index);
                                        else if (index == 2 && paumoney)
                                          return paymentItem(index);
                                        else if (index == 3 && razorpay)
                                          return paymentItem(index);
                                        else if (index == 4 && paystack)
                                          return paymentItem(index);
                                        else if (index == 5 && flutterwave)
                                          return paymentItem(index);
                                        else
                                          return Container();
                                      }),
                                ],
                              ),
                            )
                          : Container()
                    ],
                  ),
                )
          : noInternet(context),
    );
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

  dateCell(int index) {
    DateTime today = DateTime.parse(startingDate);
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selectedDate == index ? primary : null),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('EEE').format(today.add(Duration(days: index))),
              style: TextStyle(color: selectedDate == index ? white : black54),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                DateFormat('dd').format(today.add(Duration(days: index))),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selectedDate == index ? white : black54),
              ),
            ),
            Text(
              DateFormat('MMM').format(today.add(Duration(days: index))),
              style: TextStyle(color: selectedDate == index ? white : black54),
            ),
          ],
        ),
      ),
      onTap: () {
        DateTime date = today.add(Duration(days: index));

        setState(() {
          selectedDate = index;
          selDate = DateFormat('yyyy-MM-dd').format(date);
        });
      },
    );
  }

  Future<void> _getdateTime() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      timeSlotList.clear();
      try {
        var parameter = {
          TYPE: PAYMENT_METHOD,
        };
        Response response =
            await post(getSettingApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print('response***setting**${response.body.toString()}');
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          var time_slot = data["time_slot_config"];
          allowDay = time_slot["allowed_days"];
          _isTimeSlot =
              time_slot["is_time_slots_enabled"] == "1" ? true : false;
          startingDate = time_slot["starting_date"];
          var timeSlots = data["time_slots"];
          timeSlotList = (timeSlots as List)
              .map((timeSlots) => new Model.fromTimeSlot(timeSlots))
              .toList();

          var payment = data["payment_method"];
          cod = payment["cod_method"] == "1" ? true : false;
          paypal = payment["paypal_payment_method"] == "1" ? true : false;
          paumoney = payment["payumoney_payment_method"] == "1" ? true : false;
          flutterwave =
              payment["flutterwave_payment_method"] == "1" ? true : false;
          razorpay = payment["razorpay_payment_method"] == "1" ? true : false;
          paystack = payment["paystack_payment_method"] == "1" ? true : false;

          if (razorpay) razorpayId = payment["razorpay_key_id"];
          if (paystack) {
            paystackId = payment["paystack_key_id"];

            print("paystack=========$paystackId");
            PaystackPlugin.initialize(publicKey: paystackId);
          }

          print("days***$allowDay");
        } else {
          // setSnackbar(msg);
        }

        setState(() {
          _isLoading = false;
          // widget.model.isFavLoading = false;
        });
      } on TimeoutException catch (_) {
        //setSnackbar(somethingMSg);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Widget timeSlotItem(int index) {
    return RadioListTile(
      dense: true,
      value: (index),
      groupValue: selectedTime,
      onChanged: (val) {
        setState(() {
          selectedTime = val;
          selTime = timeSlotList[selectedTime].name;
        });
      },
      title: Text(
        timeSlotList[index].name,
        style: TextStyle(color: lightBlack, fontSize: 15),
      ),
    );
  }

  Widget paymentItem(int index) {
    return RadioListTile(
      dense: true,
      value: (index),
      groupValue: selectedMethod,
      onChanged: (val) {
        setState(() {
          selectedMethod = val;
          payMethod = paymentMethodList[selectedMethod];
        });
      },
      title: Text(
        paymentMethodList[index],
        style: TextStyle(color: lightBlack, fontSize: 15),
      ),
    );
  }
}

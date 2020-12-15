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
import 'Payment.dart';
import 'Test.dart';
import 'Cart.dart';
import 'Helper/Color.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Order_Success.dart';
import 'Manage_Address.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CheckOut extends StatefulWidget {
  final Function updateHome;

  CheckOut(this.updateHome);

  @override
  State<StatefulWidget> createState() {
    return StateCheckout();
  }
}

List<User> addressList = [];
String latitude,
    longitude,
    selAddress,
    payMethod = '',
    payIcon = '',
    selTime,
    selDate,
    promocode;
int selectedTime, selectedDate, selectedMethod;

double promoAmt = 0;
double remWalBal, usedBal = 0;
String razorpayId, paystackId;
int selectedAddress;
StateCheckout stateCheck;
bool isTimeSlot, isPromoValid = false, isUseWallet = false, isPayLayShow = true;

class StateCheckout extends State<CheckOut> with TickerProviderStateMixin {
  int _curIndex = 0;
  Razorpay _razorpay;
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //List<Widget> fragments;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true, _isProgress = false;
  List<TextEditingController> _controller = [];
  var items = ['1', '2', '3', '4', '5'];
  TextEditingController promoC = new TextEditingController();

  @override
  void initState() {
    super.initState();
    promoAmt = 0;
    remWalBal = 0;
    usedBal = 0;
    isPromoValid = false;
    isUseWallet = false;
    isPayLayShow = true;
    _getAddress();
    stateCheck = new StateCheckout();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    /*  fragments = [
      Delivery(updateCheckout),
      ManageAddress(),
      Payment(updateCheckout)
    ];*/
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

    for (int i = 0; i < cartList.length; i++)
      _controller.add(new TextEditingController());
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
    _razorpay.clear();
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

          isPromoValid = true;
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
          ? Column(
              children: [
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // stepper(),
                              //Divider(),
                              address(),
                              payment(),
                              cartItems(),
                              promo(),
                              orderSummary(),
                              // fragments[_curIndex]
                            ],
                          ),
                        ),
                      ),
                      showCircularProgress(_isProgress, primary),
                    ],
                  ),
                ),
                Container(
                  color: white,
                  child: Row(children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CUR_CURRENCY + " $totalPrice",
                              style: TextStyle(
                                  color: fontColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(cartList.length.toString() + " Items"),
                          ],
                        )),
                    Spacer(),
                    SimBtn(
                        size: deviceWidth * 0.4,
                        title: PLACE_ORDER,
                        onBtnSelected: () {
                          if (selAddress == null || selAddress.isEmpty)
                            setSnackbar(addressWarning);
                          else if (payMethod == null || payMethod.isEmpty)
                            setSnackbar(payWarning);
                          else if (isTimeSlot &&
                              (selDate == null || selDate.isEmpty))
                            setSnackbar(dateWarning);
                          else if (isTimeSlot &&
                              (selTime == null || selTime.isEmpty))
                            setSnackbar(timeWarning);
                          else if (payMethod == PAYPAL_LBL)
                            placeOrder('');
                          else if (payMethod == RAZORPAY_LBL)
                            razorpayPayment();
                          else if (payMethod == PAYSTACK_LBL)
                            paystackPayment(context);
                          else
                            placeOrder('');
                        }),
                  ]),
                ),
              ],
            )
          : noInternet(context),
      /* persistentFooterButtons: [
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
                width: deviceWidth * 0.35,
                padding: EdgeInsets.only(right: 6.0),
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
                          if (isTimeSlot &&
                              (selDate == null || selDate.isEmpty))
                            setSnackbar(dateWarning);
                          else if (isTimeSlot &&
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
      ],*/
    );
  }

  Widget listItem(int index) {
    //print("desc*****${productList[index].desc}");
    int selectedPos = 0;
    for (int i = 0;
        i < cartList[index].productList[0].prVarientList.length;
        i++) {
      if (cartList[index].varientId ==
          cartList[index].productList[0].prVarientList[i].id) selectedPos = i;

      print(
          "selected pos***$selectedPos***${cartList[index].productList[0].prVarientList[i].id}");
    }

    double price = double.parse(
        cartList[index].productList[0].prVarientList[selectedPos].disPrice);
    if (price == 0)
      price = double.parse(
          cartList[index].productList[0].prVarientList[selectedPos].price);

    cartList[index].perItemPrice = price.toString();
    cartList[index].perItemTotal =
        (price * double.parse(cartList[index].qty)).toString();

    print("price****$oriPrice***$price---$index");

    _controller[index].text = cartList[index].qty;

    double taxAmt = ((double.parse(cartList[index].perItemTotal) *
            double.parse(cartList[index].productList[0].tax)) /
        100);

    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Hero(
                    tag: "$index${cartList[index].productList[0].id}",
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child: CachedNetworkImage(
                          imageUrl: cartList[index].productList[0].image,
                          height: 60.0,
                          width: 60.0,
                          fit: BoxFit.fill,
                          placeholder: (context, url) => placeHolder(60),
                        ))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  cartList[index].productList[0].name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(color: lightBlack),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8, bottom: 8),
                                child: Icon(
                                  Icons.close,
                                  size: 13,
                                  color: fontColor,
                                ),
                              ),
                              onTap: () {
                                removeFromCart(index, true);
                              },
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              int.parse(cartList[index]
                                          .productList[0]
                                          .prVarientList[selectedPos]
                                          .disPrice) !=
                                      0
                                  ? CUR_CURRENCY +
                                      "" +
                                      cartList[index]
                                          .productList[0]
                                          .prVarientList[selectedPos]
                                          .price
                                  : "",
                              style: Theme.of(context)
                                  .textTheme
                                  .overline
                                  .copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      letterSpacing: 0.7),
                            ),
                            Text(
                              " " + CUR_CURRENCY + " " + price.toString(),
                              style: TextStyle(
                                  color: fontColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        cartList[index].productList[0].availability == "1" ||
                                cartList[index].productList[0].stockType ==
                                    "null"
                            ? Row(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      InkWell(
                                        child: Container(
                                          padding: EdgeInsets.all(2),
                                          margin: EdgeInsets.only(
                                              right: 8, top: 8, bottom: 8),
                                          child: Icon(
                                            Icons.remove,
                                            size: 12,
                                            color: fontColor,
                                          ),
                                          decoration: BoxDecoration(
                                              color: lightWhite,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3))),
                                        ),
                                        onTap: () {
                                          removeFromCart(index, false);
                                        },
                                      ),

                                      Container(
                                        width: 40,
                                        height: 20,
                                        child: Stack(
                                          children: [
                                            TextField(
                                              textAlign: TextAlign.center,
                                              readOnly: true,
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                              controller: _controller[index],
                                              decoration: InputDecoration(
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: fontColor,
                                                      width: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: fontColor,
                                                      width: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              ),
                                            ),
                                            PopupMenuButton<String>(
                                              tooltip: '',
                                              icon: const Icon(
                                                Icons.arrow_drop_down,
                                                size: 1,
                                              ),
                                              onSelected: (String value) {
                                                print(
                                                    'value********$value====${_controller[index].text}');

                                                addToCart(index, value);
                                              },
                                              itemBuilder:
                                                  (BuildContext context) {
                                                return items
                                                    .map<PopupMenuItem<String>>(
                                                        (String value) {
                                                  return new PopupMenuItem(
                                                      child: new Text(value),
                                                      value: value);
                                                }).toList();
                                              },
                                            ),
                                          ],
                                        ),
                                      ), // ),

                                      InkWell(
                                        child: Container(
                                          padding: EdgeInsets.all(2),
                                          margin: EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.add,
                                            size: 12,
                                            color: fontColor,
                                          ),
                                          decoration: BoxDecoration(
                                              color: lightWhite,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3))),
                                        ),
                                        onTap: () {
                                          addToCart(
                                              index,
                                              (int.parse(cartList[index].qty) +
                                                      1)
                                                  .toString());
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  SUBTOTAL,
                  style: Theme.of(context).textTheme.caption,
                ),
                Text(
                  CUR_CURRENCY + " " + price.toString(),
                  style: Theme.of(context).textTheme.caption,
                ),
                Text(
                  CUR_CURRENCY + " " + cartList[index].perItemTotal,
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TAXPER,
                  style: Theme.of(context).textTheme.caption,
                ),
                Text(
                  cartList[index].productList[0].tax + "%",
                  style: Theme.of(context).textTheme.caption,
                ),
                Text(
                  CUR_CURRENCY + " " + taxAmt.toStringAsFixed(2),
                  //+ " "+cartList[index].productList[0].taxrs,
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TOTAL_LBL,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  CUR_CURRENCY +
                      " " +
                      (double.parse(cartList[index].perItemTotal) + taxAmt)
                          .toStringAsFixed(2)
                          .toString(),
                  //+ " "+cartList[index].productList[0].taxrs,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  removeFromCart(int index, bool remove) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          _isProgress = true;
        });

        var parameter = {
          PRODUCT_VARIENT_ID: cartList[index].varientId,
          USER_ID: CUR_USERID,
          QTY: remove ? "0" : (int.parse(cartList[index].qty) - 1).toString()
        };

        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        print('response***slider**${parameter.toString()}***$headers');

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          String qty = data['total_quantity'];
          CUR_CART_COUNT = data['cart_count'];
          if (qty == "0") remove = true;

          print('total*****remove*$qty');
          if (remove) {
            oriPrice = oriPrice - double.parse(cartList[index].perItemTotal);

            cartList.removeWhere(
                (item) => item.varientId == cartList[index].varientId);
          } else {
            oriPrice = oriPrice - double.parse(cartList[index].perItemPrice);
            cartList[index].qty = qty.toString();
          }
          totalPrice = 0;
          totalPrice = delCharge + oriPrice + taxAmt;
        } else {
          setSnackbar(msg);
        }
        setState(() {
          _isProgress = false;
        });
        if (widget.updateHome != null) widget.updateHome();
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          _isProgress = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Future<void> addToCart(int index, String qty) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          _isProgress = true;
        });

        var parameter = {
          PRODUCT_VARIENT_ID: cartList[index].varientId,
          USER_ID: CUR_USERID,
          QTY: qty,
        };

        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        print('response***slider**${parameter.toString()}***$headers');

        print('response***${response.body.toString()}');
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          String qty = data['total_quantity'];
          CUR_CART_COUNT = data['cart_count'];

          print('total*****add*$qty');
          cartList[index].qty = qty;

          oriPrice = oriPrice + double.parse(cartList[index].perItemPrice);
          _controller[index].text = qty;
          totalPrice = 0;
          totalPrice = delCharge + oriPrice + taxAmt;
        } else {
          setSnackbar(msg);
        }
        setState(() {
          _isProgress = false;
        });
        widget.updateHome();
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          _isProgress = false;
        });
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

          for (int i = 0; i < addressList.length; i++) {
            if (addressList[i].isDefault == "1") {
              selectedAddress = i;
              selAddress = addressList[i].id;
            }
          }
        } else {
          //if (msg != 'Cart Is Empty !') setSnackbar(msg);
        }
        setState(() {
          //_isLoading = false;
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
      setState(() {
        _isProgress = true;
      });

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
      if (response.status) {
        placeOrder(response.reference);
      } else {
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
          ISWALLETBALUSED: isUseWallet ? "1" : "0",
          WALLET_BAL_USED: usedBal.toString(),
        };

        if (isTimeSlot) {
          parameter[DELIVERY_TIME] = selTime;
          parameter[DELIVERY_DATE] = selDate;
        }
        if (isPromoValid) {
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

  address() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on),
            addressList.length > 0
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Text(addressList[selectedAddress].name),
                          ),
                          Text(
                            addressList[selectedAddress].address +
                                ", " +
                                addressList[selectedAddress].area +
                                ", " +
                                addressList[selectedAddress].city +
                                ", " +
                                addressList[selectedAddress].state +
                                ", " +
                                addressList[selectedAddress].country +
                                "," +
                                addressList[selectedAddress].pincode,
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(color: lightBlack),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              children: [
                                Text(
                                  addressList[selectedAddress].mobile,
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(color: lightBlack),
                                ),
                                Spacer(),
                                InkWell(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: lightWhite,
                                        borderRadius: new BorderRadius.all(
                                            const Radius.circular(4.0))),
                                    child: Text(
                                      CHANGE,
                                      style: TextStyle(
                                          color: fontColor, fontSize: 10),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ManageAddress(
                                                  home: false,
                                                )));
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        child: Text(
                          ADDADDRESS,
                          style: TextStyle(
                              color: fontColor, fontWeight: FontWeight.bold),
                        ),
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddAddress(
                                      update: false,
                                  index: addressList.length,
                                    )),
                          );
                          setState(() {

                          });
                        },
                      ),
                    ),
                )
          ],
        ),
      ),
    );
  }

  payment() {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => Payment(updateCheckout)));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(Icons.payment),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  //SELECT_PAYMENT,
                  payMethod != null && payMethod != ''
                      ? payMethod
                      : SELECT_PAYMENT,
                  style:
                      TextStyle(color: fontColor, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  cartItems() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: cartList.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return listItem(index);
      },
    );
  }

  orderSummary() {
    return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ORDER_SUMMARY + " (" + cartList.length.toString() + " items)",
                style: Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(color: lightBlack, fontWeight: FontWeight.bold),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    SUBTOTAL,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    CUR_CURRENCY + " " + oriPrice.toString(),
                    style: Theme.of(context).textTheme.caption,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    TAXPER,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    CUR_CURRENCY + " " + taxAmt.toString(),
                    style: Theme.of(context).textTheme.caption,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DELIVERY_CHARGE,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    CUR_CURRENCY + " " + delCharge.toString(),
                    style: Theme.of(context).textTheme.caption,
                  )
                ],
              ),
            ],
          ),
        ));
  }

  promo() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  PROMOCODE_LBL,
                  style: Theme.of(context).textTheme.caption,
                ),
                Spacer(),
                InkWell(
                  child: Icon(
                    Icons.refresh,
                    size: 15,
                  ),
                  onTap: () {
                    if (promoAmt != 0) {
                      setState(() {
                        totalPrice = totalPrice + promoAmt;
                        promoC.text = '';
                        isPromoValid = false;
                        promoAmt = 0;
                        promocode = '';
                      });
                    }
                  },
                )
              ],
            ),
            Container(
              //  color: red,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: promoC,
                      style: Theme.of(context).textTheme.subtitle2,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(
                          5,
                        ),
                        hintText: 'Promo Code..',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: fontColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: fontColor),
                        ),
                      ),
                    ),
                  ),
                  /*        SimBtn(
                    title: APPLY,
                    size: deviceWidth * 0.2,
                    onBtnSelected: () async {
                      if (promoC.text.trim().isEmpty)
                        stateCheck.setSnackbar(ADD_PROMO);
                      else
                        validatePromo();
                    },
                  ),*/

                  CupertinoButton(
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        alignment: FractionalOffset.center,
                        decoration: BoxDecoration(
                            color: lightWhite,
                            borderRadius: new BorderRadius.all(
                                const Radius.circular(4.0))),
                        child: Text(APPLY,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.button.copyWith(
                                  color: fontColor,
                                ))),
                    onPressed: () {
                      if (promoC.text.trim().isEmpty)
                        stateCheck.setSnackbar(ADD_PROMO);
                      else
                        validatePromo();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                //_deliveryContent(),
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

/*_deliveryContent() {
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
                            isPromoValid = false;
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
                isPromoValid
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
  }*/
}

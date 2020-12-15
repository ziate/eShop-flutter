import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'Helper/Constant.dart';
import 'Cart.dart';
import 'CheckOut.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Model/Model.dart';
import 'CheckOut.dart';
import 'Helper/PaymentRadio.dart';

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
  List<RadioModel> timeModel = new List<RadioModel>();
  List<RadioModel> payModel = new List<RadioModel>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<String> paymentMethodList = [
    COD_LBL,
    PAYPAL_LBL,
    PAYUMONEY_LBL,
    RAZORPAY_LBL,
    PAYSTACK_LBL,
    FLUTTERWAVE_LBL
  ];
  List<String> paymentIconList = [
    'assets/images/cod.png',
    'assets/images/paypal.png',
    'assets/images/payu.png',
    'assets/images/rozerpay.png',
    'assets/images/paystack.png',
    'assets/images/flutterwave.png'
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
      appBar: getAppBar(PAYMENT_METHOD_LBL, context),
      backgroundColor: lightWhite,
      body: _isNetworkAvail
          ? _isLoading
              ? getProgress()
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Card(
                          elevation: 0,
                          child: CUR_BALANCE != "0" &&
                                  CUR_BALANCE.isNotEmpty &&
                                  CUR_BALANCE != ""
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: CheckboxListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.all(0),
                                    value: isUseWallet,
                                    onChanged: (bool value) {
                                      setState(() {
                                        isUseWallet = value;

                                        if (value) {
                                          if (totalPrice <=
                                              double.parse(CUR_BALANCE)) {
                                            remWalBal =
                                                double.parse(CUR_BALANCE) -
                                                    totalPrice;

                                            usedBal = totalPrice;
                                            payMethod = "Wallet";

                                            isPayLayShow = false;
                                          } else {
                                            remWalBal = 0;
                                            usedBal = double.parse(CUR_BALANCE);
                                            isPayLayShow = true;
                                          }

                                          totalPrice = totalPrice - usedBal;
                                        } else {
                                          totalPrice = totalPrice + usedBal;
                                          remWalBal = double.parse(CUR_BALANCE);
                                          payMethod = null;
                                          usedBal = 0;
                                          isPayLayShow = true;
                                        }

                                        widget.update();
                                      });
                                    },
                                    title: Text(
                                      USE_WALLET,
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Text(
                                        isUseWallet
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
                                        style: TextStyle(
                                            fontSize: 15, color: black),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                        ),
                        isTimeSlot
                            ? Card(
                                elevation: 0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        PREFERED_TIME,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    ),
                                    Divider(),
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
                        isPayLayShow
                            ? Card(
                                elevation: 0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        SELECT_PAYMENT,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    ),
                                    Divider(),
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
          isTimeSlot = time_slot["is_time_slots_enabled"] == "1" ? true : false;
          startingDate = time_slot["starting_date"];
          var timeSlots = data["time_slots"];
          timeSlotList = (timeSlots as List)
              .map((timeSlots) => new Model.fromTimeSlot(timeSlots))
              .toList();

          if (timeSlotList.length > 0) {
            for (int i = 0; i < timeSlotList.length; i++) {
              timeModel.add(new RadioModel(
                  isSelected: i == selectedTime ? true : false, name: timeSlotList[i].name, img: ''));
            }
          }

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

          for (int i = 0; i < paymentMethodList.length; i++) {
            String img = '';

          /*  if (i == 0) {
              if (cod &&
                  paymentMethodList[i].toString().toLowerCase() ==
                      "cash on delivery")
                img = paymentIconList[i];
            }
            else if (i == 1){
              if (paypal &&
                paymentMethodList[i].toString().toLowerCase() == "paypal")
              img = 'assets/images/paypal.png';}
            else if (i == 3) {
              if (razorpay &&
                  paymentMethodList[i].toString().toLowerCase() == "razorpay")
                img = 'assets/images/rozerpay.png';
            }
            else if (i == 4) {
              if (paystack &&
                  paymentMethodList[i].toString().toLowerCase() == "paystack")
                img = 'assets/images/paystack.png';
            }
            print("img*********$img****$i****$paypal***$paystack***$razorpay");*/

            payModel.add(RadioModel(
                isSelected: i == selectedMethod ? true : false, name: paymentMethodList[i], img:  paymentIconList[i]));
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
    return new InkWell(
      onTap: () {
        setState(() {
          selectedTime = index;
          selTime = timeSlotList[selectedTime].name;
          timeModel.forEach((element) => element.isSelected = false);
          timeModel[index].isSelected = true;
        });
      },
      child: new RadioItem(timeModel[index]),
    );

/*    return RadioListTile(
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
        style: TextStyle(color: lightBlack, ),
      ),
    );*/
  }

  Widget paymentItem(int index) {

    return new InkWell(
      onTap: () {
        setState(() {
          selectedMethod = index;
          payMethod = paymentMethodList[selectedMethod];
          payIcon=paymentIconList[selectedMethod];
          payModel.forEach((element) => element.isSelected = false);
          payModel[index].isSelected = true;
        });
      },
      child: new RadioItem(payModel[index]),
    );


  /*  return RadioListTile(
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
    );*/
  }
}

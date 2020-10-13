import 'dart:async';
import 'dart:convert';

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

import 'Cart.dart';
import 'Helper/Color.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';

class CheckOut extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateCheckout();
  }
}

List<User> addressList = [];
String latitude="200", longitude="2424", selAddress, payMethod, selTime, selDate;
int selectedTime, selectedDate, selectedMethod;
bool _isTimeSlot;

class StateCheckout extends State<CheckOut> {
  int _curIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Widget> fragments;

  @override
  void initState() {
    super.initState();

    fragments = [Delivery(), Address(), Payment()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBar(CHECKOUT, context),
      body: Column(
        children: [
          stepper(),
          Divider(),
          Expanded(child: fragments[_curIndex]),
        ],
      ),
      persistentFooterButtons: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Flexible(
                fit: FlexFit.loose,
                child: Text(
                  TOTAL + " : " + CUR_CURRENCY + " " + totalPrice.toString(),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            RaisedButton.icon(
              icon: Icon(
                _curIndex == 2 ? Icons.check : Icons.navigate_next,
                color: Colors.white,
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
                    if (selDate == null || selDate.isEmpty)
                      setSnackbar(dateWarning);
                    else if (_isTimeSlot &&
                        (selTime == null || selTime.isEmpty))
                      setSnackbar(timeWarning);
                    else if (payMethod == null || payMethod.isEmpty)
                      setSnackbar(payWarning);
                    else
                      placeOrder();
                  }
                });

                /*  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaypalWebviewActivity()),
                );*/
              },
              label: Text(
                _curIndex == 2 ? PROCEED : CONTINUE,
                style: TextStyle(color: Colors.white),
              ),
              color: primary,
            ),
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
                        color: Colors.white,
                      ),
                      onPressed: onStepContinue,
                      label: Text(
                        CONTINUE,
                        style: TextStyle(color: Colors.white),
                      ),
                      color: primary,
                    ),
            ),
          );
        },
      ),*/
    );
  }


  confirmOrder(){

   return CupertinoAlertDialog(
        title: Text(
          CONFIRM_ORDER,
          style: Theme.of(context).textTheme.headline6.copyWith(
            color: lightblack,
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
              onPressed: () {

              }),
        ]);

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
                  style: TextStyle(color: Colors.white),
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
          color: Colors.black,
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
                      style: TextStyle(color: Colors.white),
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
                      style: TextStyle(color: Colors.white),
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
                      style: TextStyle(color: Colors.white),
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

  Future<void> placeOrder() async {
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
        LATITUDE: latitude,
        LONGITUDE: longitude,
        PAYMENT_METHOD: payMethod,
        ADDRESS: selAddress,
        DELIVERY_DATE: selDate,
      };

      if (_isTimeSlot) parameter[DELIVERY_TIME] = selTime;
print("param****${parameter.toString()}");
      Response response =
          await post(placeOrderApi, body: parameter, headers: headers)
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
        // _isLoading = false;
      });
    } on TimeoutException catch (_) {
      //  setSnackbar(somethingMSg);
    }
  }
}

class Delivery extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateDelivery();
  }
}

class StateDelivery extends State<Delivery> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
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
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
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
                      style: TextStyle(color: Colors.white),
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
                style: Theme.of(context).textTheme.headline6,
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
              padding: const EdgeInsets.only(
                  top: 28, bottom: 8.0, left: 35, right: 35),
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
              color: Colors.black,
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
                    Total_PRICE,
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
        ));
  }

  orderItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text(cartList[index].productList[0].name)),
          Expanded(flex: 1, child: Text(cartList[index].qty)),
          Expanded(flex: 2, child: Text(cartList[index].perItemTotal)),
          Expanded(flex: 2, child: Text(cartList[index].perItemTotal)),
        ],
      ),
    );
  }
}

class Address extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateAddress();
  }
}

class StateAddress extends State<Address> {
  bool _isLoading = true;
  int selectedAddress;

  @override
  void initState() {
    super.initState();
    addressList.clear();
    _getAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              _isLoading
                  ? getProgress()
                  : addressList.length == 0
                      ? Text(NOADDRESS)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount: addressList.length,
                          itemBuilder: (context, index) {
                            return addressItem(index);
                          }),
            ],
          ),
        ),
        RaisedButton.icon(
            color: primary,
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
              color: Colors.white,
            ),
            label: Text(
              ADDADDRESS,
              style: TextStyle(color: Colors.white),
            ))
      ],
    );
  }

  addressItem(int index) {
    print("default***${addressList[index].isDefault}");
    if (addressList[index].isDefault == "1") {
      selectedAddress = index;
      selAddress = addressList[index].address +
          ", " +
          addressList[index].area +
          ", " +
          addressList[index].city +
          ", " +
          addressList[index].state +
          ", " +
          addressList[index].country;
    }
    return RadioListTile(
      value: (index),
      groupValue: selectedAddress,
      onChanged: (val) {
        setState(() {
          selectedAddress = val;
          selAddress = addressList[index].address +
              ", " +
              addressList[index].area +
              ", " +
              addressList[index].city +
              ", " +
              addressList[index].state +
              ", " +
              addressList[index].country;
        });
      },
      title: Row(
        children: [
          Expanded(
              child: Row(
            children: [
              Text(
                addressList[index].name + "  ",
                style: TextStyle(color: Colors.black),
              ),
              Container(
                decoration: BoxDecoration(
                    color: lightgrey, borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.all(3),
                child: Text(
                  addressList[index].type,
                ),
              )
            ],
          )),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(
                Icons.edit,
                color: Colors.black54,
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
                color: Colors.black54,
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
  }

  Future<void> _getAddress() async {
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
  }

/*  setSnackbar(String msg) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 1.0,
    ));
  }*/

}

class Payment extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StatePayment();
  }
}

class StatePayment extends State<Payment> {
  bool _isLoading = true;
  String allowDay, startingDate;
  List<Model> timeSlotList = [];
  bool cod, paypal, razorpay, paumoney, paystack, flutterwave;
  List<String> paymentMethodList = [
    COD_LBL,
    PAYPAL_LBL,
    PAYUMONEY_LBL,
    RAZORPAY_LBL,
    PAYSTACK_LBL,
    FLUTTERWAVE_LBL
  ];

  @override
  void initState() {
    super.initState();
    _getdateTime();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? getProgress()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            PREFERED_TIME,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        Container(
                          height: 70,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: int.parse(allowDay),
                              itemBuilder: (context, index) {
                                return dateCell(index);
                              }),
                        ),
                        Divider(),
                        _isTimeSlot
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: timeSlotList.length,
                                itemBuilder: (context, index) {
                                  return timeSlotItem(index);
                                })
                            : Container()
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            PAYMENT_METHOD_LBL,
                            style: Theme.of(context).textTheme.headline6,
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
                ],
              ),
            ),
          );
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
              style: TextStyle(
                  color: selectedDate == index ? Colors.white : Colors.black54),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                DateFormat('dd').format(today.add(Duration(days: index))),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        selectedDate == index ? Colors.white : Colors.black54),
              ),
            ),
            Text(
              DateFormat('MMM').format(today.add(Duration(days: index))),
              style: TextStyle(
                  color: selectedDate == index ? Colors.white : Colors.black54),
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
        _isTimeSlot = time_slot["is_time_slots_enabled"] == "1" ? true : false;
        startingDate = time_slot["starting_date"];
        var timeSlots = data["time_slots"];
        timeSlotList = (timeSlots as List)
            .map((timeSlots) => new Model.fromTimeSlot(timeSlots))
            .toList();

        var payment = data["payment_methods"];
        cod = payment["cod_method"] == "1" ? true : false;
        paypal = payment["paypal_payment_method"] == "1" ? true : false;
        paumoney = payment["payumoney_payment_method"] == "1" ? true : false;
        flutterwave =
            payment["flutterwave_payment_method"] == "1" ? true : false;
        razorpay = payment["razorpay_payment_method"] == "1" ? true : false;
        paystack = payment["paystack_payment_method"] == "1" ? true : false;

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
        style: TextStyle(color: Colors.black, fontSize: 15),
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
        style: TextStyle(color: Colors.black, fontSize: 15),
      ),
    );
  }
}

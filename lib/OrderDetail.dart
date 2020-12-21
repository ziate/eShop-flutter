import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Model/Order_Model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/String.dart';

class OrderDetail extends StatefulWidget {
  final Order_Model model;

  const OrderDetail({Key key, this.model}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateOrder();
  }
}

class StateOrder extends State<OrderDetail> with TickerProviderStateMixin{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;


  bool _isCancleable, _isReturnable;
  bool _isProgress = false;

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

  @override
  Widget build(BuildContext context) {
    Order_Model model = widget.model;
    String pDate, prDate, sDate, dDate, cDate, rDate;

    if (model.listStatus.contains(PLACED)) {
      pDate = model.listDate[model.listStatus.indexOf(PLACED)];

      if (pDate != null) {
        List d = pDate.split(" ");
        pDate = d[0] + "\n" + d[1] ;
      }
    }
    if (model.listStatus.contains(PROCESSED)) {
      prDate = model.listDate[model.listStatus.indexOf(PROCESSED)];
      if (prDate != null) {
        List d = prDate.split(" ");
        prDate = d[0] + "\n" + d[1] ;
      }
    }
    if (model.listStatus.contains(SHIPED)) {
      sDate = model.listDate[model.listStatus.indexOf(SHIPED)];
      if (sDate != null) {
        List d = sDate.split(" ");
        sDate = d[0] + "\n" + d[1] ;
      }
    }
    if (model.listStatus.contains(DELIVERD)) {
      dDate = model.listDate[model.listStatus.indexOf(DELIVERD)];
      if (dDate != null) {
        List d = dDate.split(" ");
        dDate = d[0] + "\n" + d[1] ;
      }
    }
    if (model.listStatus.contains(CANCLED)) {
      cDate = model.listDate[model.listStatus.indexOf(CANCLED)];
      if (cDate != null) {
        List d = cDate.split(" ");
        cDate = d[0] + "\n" + d[1] ;
      }
    }
    if (model.listStatus.contains(RETURNED)) {
      rDate = model.listDate[model.listStatus.indexOf(RETURNED)];
      if (rDate != null) {
        List d = rDate.split(" ");
        rDate = d[0] + "\n" + d[1] ;
      }
    }

    _isCancleable = model.isCancleable == "1" ? true : false;
    _isReturnable = model.isReturnable == "1" ? true : false;

    print("is cancle********$_isCancleable***$_isReturnable");

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: getAppBar(ORDER_DETAIL, context),
      body:_isNetworkAvail?  Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ORDER_ID_LBL + " : " + model.id),
                        Text(ORDER_DATE + " : " + model.orderDate),
                        Divider(),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: model.itemList.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, i) {
                            OrderItem orderItem = model.itemList[i];
                            return productItem(orderItem, model);
                          },
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(PRICE_DETAIL,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(color: fontColor)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(PRICE_LBL),
                              Text("+ " + CUR_CURRENCY + " " + model.subTotal)
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DELIVERY_CHARGE),
                              Text("+ " + CUR_CURRENCY + " " + model.delCharge)
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(TAXPER + " (" + model.taxPer + ")"),
                              Text("+ " + CUR_CURRENCY + " " + model.taxAmt)
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(PROMO_CODE_DIS_LBL),
                              Text("- " + CUR_CURRENCY + " " + model.promoDis)
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(WALLET_BAL),
                              Text("- " + CUR_CURRENCY + " " + model.walBal)
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                TOTAL_PRICE,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                CUR_CURRENCY + " " + model.total,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('OTHER_DETAIL',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(color: fontColor)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(NAME_LBL + " : " + model.name),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(MOB_LBL + " : " + model.mobile),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(ADDRESS_LBL + " : " + model.address),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            ORDER_STATUS,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: fontColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              getPlaced(pDate),
                              getProcessed(prDate, cDate),
                              getShipped(sDate, cDate),
                              getDelivered(dDate, cDate),
                              getCanceled(cDate),
                              getReturned(rDate, model),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              /*      _isReturnable || _isCancleable
                  ? Row(
                      children: [
                        _isReturnable ? returnable() : Container(),
                        _isCancleable ? cancelable() : Container()
                      ],
                    )
                  : Container(),*/

              (!model.listStatus.contains(DELIVERD) &&
                  (!model.listStatus.contains(RETURNED)) &&
                  _isCancleable &&
                  model.isAlrCancelled == "0")
                  ? cancelable()
                  :

              (model.listStatus.contains(DELIVERD) &&
                  _isReturnable &&
                  model.isAlrReturned == "0")?
              /* ?model.rtnReqSubmitted=="0"? returnable(true,RETURN_ORDER)
                  :model.rtnReqSubmitted=="2"?returnable(false, text)*/
              returnable():

              Container(),
            ],
          ),
          showCircularProgress(_isProgress, primary),
        ],
      ):noInternet(context),

    );
  }

  returnable() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [grad1Color, grad2Color],
            stops: [0, 1]),
        boxShadow: [BoxShadow(color: black26, blurRadius: 10)],
      ),
      width: deviceWidth,
      child: InkWell(
        onTap: () {
          cancelOrder(RETURNED, updateOrderApi, widget.model.id);
        },
        child: Center(
            child: Text(
              RETURN_ORDER,
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(fontWeight: FontWeight.bold, color: white),
            )),
      ),
    );
  }

  cancelable() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [grad1Color, grad2Color],
            stops: [0, 1]),
        boxShadow: [BoxShadow(color: black26, blurRadius: 10)],
      ),
      width:  deviceWidth,
      child: InkWell(
        onTap: () {
          cancelOrder(CANCLED, updateOrderApi, widget.model.id);
        },
        child: Center(
            child: Text(
              CANCEL_ORDER,
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(fontWeight: FontWeight.bold, color: white),
            )),
      ),
    );
  }

  productItem(OrderItem orderItem, Order_Model model) {
    String pDate, prDate, sDate, dDate, cDate, rDate;

    if (orderItem.listStatus.contains(PLACED)) {
      pDate = orderItem.listDate[orderItem.listStatus.indexOf(PLACED)];

      if (pDate != null) {
        List d = pDate.split(" ");
        pDate = d[0] + "\n" + d[1];
      }
    }
    if (orderItem.listStatus.contains(PROCESSED)) {
      prDate = orderItem.listDate[orderItem.listStatus.indexOf(PROCESSED)];
      if (prDate != null) {
        List d = prDate.split(" ");
        prDate = d[0] + "\n" + d[1];
      }
    }
    if (orderItem.listStatus.contains(SHIPED)) {
      sDate = orderItem.listDate[orderItem.listStatus.indexOf(SHIPED)];
      if (sDate != null) {
        List d = sDate.split(" ");
        sDate = d[0] + "\n" + d[1] ;
      }
    }
    if (orderItem.listStatus.contains(DELIVERD)) {
      dDate = orderItem.listDate[orderItem.listStatus.indexOf(DELIVERD)];
      if (dDate != null) {
        List d = dDate.split(" ");
        dDate = d[0] + "\n" + d[1] ;
      }
    }
    if (orderItem.listStatus.contains(CANCLED)) {
      cDate = orderItem.listDate[orderItem.listStatus.indexOf(CANCLED)];
      if (cDate != null) {
        List d = cDate.split(" ");
        cDate = d[0] + "\n" + d[1] ;
      }
    }
    if (orderItem.listStatus.contains(RETURNED)) {
      rDate = orderItem.listDate[orderItem.listStatus.indexOf(RETURNED)];
      if (rDate != null) {
        List d = rDate.split(" ");
        rDate = d[0] + "\n" + d[1] ;
      }
    }
   // print("length=========${orderItem.image}");
    return Column(
      children: [
        Row(
          children: [
            CachedNetworkImage(
              imageUrl: orderItem.image,
              height: 100.0,
              width: 100.0,
              errorWidget:(context, url,e) => placeHolder(100) ,
              placeholder: (context, url) => placeHolder(100),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(orderItem.name),
                    Text(PAYMENT_METHOD_LBL + " : " + model.payMethod),
                    Text(QUANTITY_LBL + " : " + orderItem.qty),
                    Text(CUR_CURRENCY + " " + orderItem.price),

                    //  Text(orderItem.status)
                  ],
                ),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              getPlaced(pDate),
              getProcessed(prDate, cDate),
              getShipped(sDate, cDate),
              getDelivered(dDate, cDate),
              getCanceled(cDate),
              getReturned(rDate, model),
            ],
          ),
        ),
/*        model.itemList.length > 1
            ? ButtonTheme(
                child: ButtonBar(
                  children: <Widget>[
            *//*        orderItem.isReturn == "1"
                        ? FlatButton(
                            child: Text(ITEM_RETURN),
                            onPressed: () {
                              cancelOrder(
                                  RETURNED, updateOrderItemApi, orderItem.id);
                            },
                          )
                        : Container(),
                    orderItem.isCancle == "1"
                        ? FlatButton(
                            child: const Text(ITEM_CANCEL),
                            onPressed: () {
                              cancelOrder(
                                  CANCLED, updateOrderItemApi, orderItem.id);
                            },
                          )
                        : Container(),*//*


                    (!orderItem.listStatus.contains(DELIVERD) &&
                        (!orderItem.listStatus.contains(RETURNED)) &&
                        orderItem.isCancle=="1" &&
                        orderItem.isAlrCancelled == "0")
                        ? FlatButton(
                      child: const Text(ITEM_CANCEL),
                      onPressed: () {
                        cancelOrder(
                            CANCLED, updateOrderItemApi, orderItem.id);
                      },
                    )
                        :

                    (orderItem.listStatus.contains(DELIVERD) &&
                        orderItem.isReturn=="1" &&
                        orderItem.isAlrReturned == "0")?
                    *//* ?model.rtnReqSubmitted=="0"? returnable(true,RETURN_ORDER)
                  :model.rtnReqSubmitted=="2"?returnable(false, text)*//*
                    FlatButton(
                      child: Text(ITEM_RETURN),
                      onPressed: () {
                        cancelOrder(
                            RETURNED, updateOrderItemApi, orderItem.id);
                      },
                    ):

                    Container(),


                  ],
                ),
              )
            : Container(),*/
      ],
    );
  }

  getPlaced(String pDate) {
    return Column(
      children: [
        Text(
          ORDER_NPLACED,
          style: TextStyle(fontSize: 8),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Icon(
            Icons.check_circle,
            color: primary,
          ),
        ),
        Text(
          pDate,
          style: TextStyle(fontSize: 8),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  getProcessed(String prDate, String cDate) {
    return cDate == null
        ? Flexible(
      flex: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              flex: 1,
              child: Divider(
                thickness: 2,
                color: prDate == null ? Colors.grey : primary,
              )),
          Column(
            children: [
              Text(
                ORDER_PROCESSED,
                style: TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Icon(
                  prDate == null
                      ? Icons.stop_circle : Icons.check_circle,
                  color: prDate == null ? Colors.grey : primary,
                ),
              ),
              Text(
                prDate ?? "\n",
                style: TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    )
        : prDate == null
        ? Container()
        : Flexible(
      flex: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              flex: 1,
              child: Divider(
                thickness: 2,
                color: primary,
              )),
          Column(
            children: [
              Text(
                ORDER_PROCESSED,
                style: TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
              Icon(
                Icons.check_circle,
                color: primary,
              ),
              Text(
                prDate ?? "\n\n",
                style: TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  getShipped(String sDate, String cDate) {
    return cDate == null
        ? Flexible(
      flex: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
              flex: 1,
              child: Divider(
                thickness: 2,
                color: sDate == null ? Colors.grey : primary,
              )),
          Column(
            children: [
              Text(
                ORDER_SHIPPED,
                style: TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Icon(
                  sDate == null?
                  Icons.stop_circle : Icons.check_circle,
                  color: sDate == null ? Colors.grey : primary,
                ),
              ),
              Text(
                sDate ?? "\n",
                style: TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    )
        : sDate == null
        ? Container()
        : Flexible(
      flex: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              flex: 1,
              child: Divider(
                thickness: 2,
              )),
          Column(
            children: [
              Text(
                ORDER_SHIPPED,
                style: TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
              Icon(
                Icons.check_circle,
                color: primary,
              ),
              Text(
                sDate ?? "\n",
                style: TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  getDelivered(String dDate, String cDate) {
    return cDate == null
        ? Flexible(
      flex: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              child: Divider(
                thickness: 2,
                color: dDate == null ? Colors.grey : primary,
              )),
          Column(
            children: [
              Text(
                ORDER_DELIVERED,
                style: TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Icon(
                  dDate == null?
                  Icons.stop_circle : Icons.check_circle,
                  color: dDate == null ? Colors.grey : primary,
                ),
              ),
              Text(
                dDate ?? "\n",
                style: TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    )
        : Container();
  }

  getCanceled(String cDate) {
    return cDate != null
        ? Flexible(
      flex: 1,
      child: Row(
        children: [
          Flexible(
              flex: 1,
              child: Divider(
                thickness: 2,
                color: Colors.red,
              )),
          Column(
            children: [
              Text(
                ORDER_CANCLED,
                style: TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Icon(
                  Icons.cancel_rounded,
                  color: Colors.red,
                ),
              ),
              Text(
                cDate ?? "",
                style: TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    )
        : Container();
  }

  getReturned(
      String rDate,
      Order_Model model,
      ) {
    return model.listStatus.contains(RETURNED)
        ? Flexible(
      flex: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              flex: 1,
              child: Divider(
                thickness: 2,
                color: Colors.red,
              )),
          Column(
            children: [
              Text(
                ORDER_RETURNED,
                style: TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Icon(
                  Icons.cancel_rounded,
                  color: Colors.red,
                ),
              ),
              Text(
                rDate ?? "",
                style: TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    )
        : Container();
  }

  Future<void> cancelOrder(String status, String api, String id) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {

      try {
        setState(() {
          _isProgress = true;
        });

        var parameter = {ORDERID: id, STATUS: status};
        Response response = await post(api, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print('param========$parameter');
        print('response***setting**${response.body.toString()}');
        bool error = getdata["error"];
        String msg = getdata["message"];
        setSnackbar(msg);
        if (!error) {

          Future.delayed(Duration(seconds: 1)).then((_) async {
            Navigator.pop(context);
          });
        } else {}

        setState(() {
          _isProgress = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
      } }
    else
    {
      setState(() {
        _isNetworkAvail=false;
      });
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
}
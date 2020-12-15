import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Model/Order_Model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Login.dart';
import 'OrderDetail.dart';
import 'Helper/SimBtn.dart';

class TrackOrder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateTrack();
  }
}

bool _isLoading = true;
List<Order_Model> orderList = [];
List<Order_Model> deliveredList = [];
List<Order_Model> orderProgressList = [];

//int offset = 0;
//int total = 0, _curIndex = 0;
//bool isLoadingmore = true;

class StateTrack extends State<TrackOrder> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //List<Order_Model> tempList = [];

  // ScrollController controller = new ScrollController();
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;

  @override
  void initState() {
    getOrder();

    getDeliveredOrder();
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
    super.initState();
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
                  getOrder();
                  getDeliveredOrder();
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
      // appBar: getAppBar(TRACK_ORDER, context),
      body: _isNetworkAvail
          ? _isLoading
              ? shimmer()
              : orderList.length == 0 && deliveredList.length == 0
                  ? Center(child: Text(noItem))
                  : SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            orderList.length != 0
                                ? Text(
                                    "Your Orders",
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  )
                                : Container(),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: orderList.length,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                //  print("load more****$offset***$total***${favList.length}***$isLoadingmore**$index");
                                return orderItem(index);
                              },
                            ),
                            deliveredList.length != 0
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Text(
                                      "Completed Orders",
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  )
                                : Container(),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: deliveredList.length,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                //  print("load more****$offset***$total***${favList.length}***$isLoadingmore**$index");
                                return deliveredOrderItem(index);
                              },
                            ),
                          ],
                        ),
                      ),
                    )
          : noInternet(context),
    );
  }

  Future<void> getOrder() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (CUR_USERID != null) {
          String status="$PLACED, $SHIPED, $PROCESSED, $CANCLED, $RETURNED";
          var parameter = {
            USER_ID: CUR_USERID,
            ACTIVE_STATUS: status
          };
          Response response =
              await post(getOrderApi, body: parameter, headers: headers)
                  .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);
          print('response***fav****par***${parameter.toString()}');
          print('response***fav****${response.body.toString()}');
          bool error = getdata["error"];
          String msg = getdata["message"];
          orderList.clear();
          print('section get***favorite get');
          if (!error) {
            var data = getdata["data"];
            orderList = (data as List)
                .map((data) => new Order_Model.fromJson(data))
                .toList();
          }

          setState(() {
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            //msg = goToLogin;
          });

          Future.delayed(Duration(seconds: 1)).then((_) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          });
        }
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  Future<void> getDeliveredOrder() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (CUR_USERID != null) {
          var parameter = {USER_ID: CUR_USERID, ACTIVE_STATUS: DELIVERD};
          Response response =
              await post(getOrderApi, body: parameter, headers: headers)
                  .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);
          print('response***fav****par***${parameter.toString()}');
          print('response***fav****${response.body.toString()}');
          bool error = getdata["error"];
          String msg = getdata["message"];

          print('section get***favorite get');
          if (!error) {
            var data = getdata["data"];
            deliveredList.clear();
            deliveredList = (data as List)
                .map((data) => new Order_Model.fromJson(data))
                .toList();
          }
          setState(() {
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            //msg = goToLogin;
          });
        }
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
      if (mounted)
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
        style: TextStyle(color: black),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  orderItem(int index) {
    String pDate, prDate, sDate, dDate, cDate, rDate;

    if (orderList[index].listStatus.contains(PLACED)) {
      pDate = orderList[index]
          .listDate[orderList[index].listStatus.indexOf(PLACED)];

      if (pDate != null) {
        List d = pDate.split(" ");
        pDate = d[0] + "\n" + d[1];
      }
    }
    if (orderList[index].listStatus.contains(PROCESSED)) {
      prDate = orderList[index]
          .listDate[orderList[index].listStatus.indexOf(PROCESSED)];
      if (prDate != null) {
        List d = prDate.split(" ");
        prDate = d[0] + "\n" + d[1];
      }
    }
    if (orderList[index].listStatus.contains(SHIPED)) {
      sDate = orderList[index]
          .listDate[orderList[index].listStatus.indexOf(SHIPED)];
      if (sDate != null) {
        List d = sDate.split(" ");
        sDate = d[0] + "\n" + d[1];
      }
    }
    if (orderList[index].listStatus.contains(DELIVERD)) {
      dDate = orderList[index]
          .listDate[orderList[index].listStatus.indexOf(DELIVERD)];
      if (dDate != null) {
        List d = dDate.split(" ");
        dDate = d[0] + "\n" + d[1];
      }
    }
    if (orderList[index].listStatus.contains(CANCLED)) {
      cDate = orderList[index]
          .listDate[orderList[index].listStatus.indexOf(CANCLED)];
      if (cDate != null) {
        List d = cDate.split(" ");
        cDate = d[0] + "\n" + d[1];
      }
    }
    if (orderList[index].listStatus.contains(RETURNED)) {
      rDate = orderList[index]
          .listDate[orderList[index].listStatus.indexOf(RETURNED)];
      if (rDate != null) {
        List d = rDate.split(" ");
        rDate = d[0] + "\n" + d[1];
      }
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ORDER_ID_LBL + " : " + orderList[index].id,
                  style: Theme.of(context).textTheme.subtitle2.copyWith(
                      color: fontColor, fontWeight: FontWeight.bold),
                ),
                Text(ORDER_DATE + " : " + orderList[index].orderDate),
                orderList[index].otp!="0"?Text(ORDER_OTP + " : " + orderList[index].otp):Container(),
                Text(orderList[index].itemList[0].name +
                    "${orderList[index].itemList.length > 1 ? " and more items" : ""} "),
              ],
            ),
            /*  Divider(),
            ListView.builder(
              shrinkWrap: true,
              itemCount: orderList[index].itemList.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                OrderItem orderItem = orderList[index].itemList[i];
                return productItem(index, orderItem);
              },
            ),
            Divider(),*/
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
                  getReturned(rDate, index),
                ],
              ),
            ),
            SimBtn(
              title: MORE_DETAIL,
              size: deviceWidth * 0.4,
              onBtnSelected: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrderDetail(
                            model: orderList[index],
                          )),
                );
                setState(() {
                  _isLoading = true;
                });

                getOrder();
              },
            ),
          ],
        ),
      ),
    );
  }

  deliveredOrderItem(int index) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ORDER_ID_LBL + " : " + deliveredList[index].id,
                        style: Theme.of(context).textTheme.subtitle2.copyWith(
                            color: fontColor, fontWeight: FontWeight.bold),
                      ),
                      Text(ORDER_DATE + " : " + deliveredList[index].orderDate),
                      Text(deliveredList[index].itemList[0].name +
                          "${deliveredList[index].itemList.length > 1 ? " and more items" : ""} "),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: primary,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(DELIVERED_LBL),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_right,
                      color: black,
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderDetail(
                                  model: deliveredList[index],
                                )),
                      );

                      setState(() {
                        _isLoading = true;
                      });

                      getDeliveredOrder();
                    })
              ],
            ),
          ],
        ),
      ),
    );
  }

/*  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          print("load more****limit *****$offset****$total");
          if (offset < total) getOrder();
        });
      }
    }
  }*/

  productItem(int index, OrderItem orderItem) {
    //print("detail=========${orderItem.image}*********${orderItem.name}");

    return Row(
      children: [
        CachedNetworkImage(
          imageUrl: orderItem.image,
          height: 100.0,
          width: 100.0,
          placeholder: (context, url) => placeHolder(100),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(orderItem.name),
              Text(QUANTITY_LBL + ": " + orderItem.qty),
              Text(CUR_CURRENCY + " " + orderItem.price),
              //  Text(orderItem.status)
            ],
          ),
        )
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
                        prDate == null ? Icons.stop_circle : Icons.check_circle,
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
                        sDate == null ? Icons.stop_circle : Icons.check_circle,
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
                        dDate == null
                            ? Icons.stop_circle
                            : Icons.check_circle,
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

  getReturned(String rDate, int index) {
    return orderList[index].listStatus.contains(RETURNED)
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
}

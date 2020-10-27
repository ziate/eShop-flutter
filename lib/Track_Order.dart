import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Model/Order_Model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Login.dart';
import 'OrderDetail.dart';

class TrackOrder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateTrack();
  }
}

class StateTrack extends State<TrackOrder> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Order_Model> orderList = [];
  List<Order_Model> tempList = [];
  int offset = 0;
  int total = 0, _curIndex = 0;
  bool isLoadingmore = true;
  ScrollController controller = new ScrollController();

  @override
  void initState() {
    getOrder();
    controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBar(TRACK_ORDER, context),
      body: _isLoading
          ? Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight),
              child: getProgress())
          : orderList.length == 0
              ? Padding(
                  padding: const EdgeInsets.only(top: kToolbarHeight),
                  child: Center(child: Text(noItem)),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  controller: controller,
                  itemCount: (offset < total)
                      ? orderList.length + 1
                      : orderList.length,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    //  print("load more****$offset***$total***${favList.length}***$isLoadingmore**$index");
                    return (index == orderList.length && isLoadingmore)
                        ? Center(child: CircularProgressIndicator())
                        : orderItem(index);
                  },
                ),
    );
  }

  Future<void> getOrder() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      try {
        if (CUR_USERID != null) {
          var parameter = {
            USER_ID: CUR_USERID,
            LIMIT: perPage.toString(),
            OFFSET: offset.toString(),
          };
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
            total = int.parse(getdata["total"]);

            if ((offset) < total) {
              tempList.clear();
              var data = getdata["data"];
              tempList = (data as List)
                  .map((data) => new Order_Model.fromJson(data))
                  .toList();
              if (offset == 0) orderList.clear();
              orderList.addAll(tempList);

              offset = offset + perPage;
            }
          } else {
          //  if (msg != 'No Favourite(s) Product Are Added')
              setSnackbar(msg);
            isLoadingmore = false;
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
          isLoadingmore = false;
        });
      }
    } else {
      setSnackbar(internetMsg);
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
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
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
        pDate = d[0] + "\n" + d[1] + d[2];
      }
    }
    if (orderList[index].listStatus.contains(PROCESSED)) {
      prDate = orderList[index]
          .listDate[orderList[index].listStatus.indexOf(PROCESSED)];
      if (prDate != null) {
        List d = prDate.split(" ");
        prDate = d[0] + "\n" + d[1] + d[2];
      }
    }
    if (orderList[index].listStatus.contains(SHIPED)) {
      sDate = orderList[index]
          .listDate[orderList[index].listStatus.indexOf(SHIPED)];
      if (sDate != null) {
        List d = sDate.split(" ");
        sDate = d[0] + "\n" + d[1] + d[2];
      }
    }
    if (orderList[index].listStatus.contains(DELIVERD)) {
      dDate = orderList[index]
          .listDate[orderList[index].listStatus.indexOf(DELIVERD)];
      if (dDate != null) {
        List d = dDate.split(" ");
        dDate = d[0] + "\n" + d[1] + d[2];
      }
    }
    if (orderList[index].listStatus.contains(CANCLED)) {
      cDate = orderList[index]
          .listDate[orderList[index].listStatus.indexOf(CANCLED)];
      if (cDate != null) {
        List d = cDate.split(" ");
        cDate = d[0] + "\n" + d[1] + d[2];
      }
    }
    if (orderList[index].listStatus.contains(RETURNED)) {
      rDate = orderList[index]
          .listDate[orderList[index].listStatus.indexOf(RETURNED)];
      if (rDate != null) {
        List d = rDate.split(" ");
        rDate = d[0] + "\n" + d[1] + "\n" + d[2];
      }
    }

    return Card(
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
                      Text(ORDER_ID + " : " + orderList[index].id),
                      Text(ORDER_DATE + " : " + orderList[index].orderDate),
                      Text(TOTAL_PRICE +
                          ":" +
                          CUR_CURRENCY +
                          " " +
                          orderList[index].total),
                    ],
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderDetail(model: orderList[index],)),
                      );
                    })
              ],
            ),
            Divider(),
            ListView.builder(
              shrinkWrap: true,
              itemCount: orderList[index].itemList.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                OrderItem orderItem = orderList[index].itemList[i];
                return productItem(index, orderItem);
              },
            ),
            Divider(),
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
            )
          ],
        ),
      ),
    );
  }

  _scrollListener() {
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
  }

  productItem(int index, OrderItem orderItem) {
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
            Icons.radio_button_checked,
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
                            ? Icons.radio_button_unchecked
                            : Icons.radio_button_checked,
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
                          Icons.radio_button_checked,
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
                        sDate == null
                            ? Icons.radio_button_unchecked
                            : Icons.radio_button_checked,
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
                          Icons.radio_button_checked,
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
                            ? Icons.radio_button_unchecked
                            : Icons.radio_button_checked,
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
                        Icons.radio_button_checked,
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
                        Icons.radio_button_checked,
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

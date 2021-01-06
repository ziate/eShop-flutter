import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:eshop/Cart.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Model/Order_Model.dart';
import 'package:ext_storage/ext_storage.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';

import 'package:permission_handler/permission_handler.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/String.dart';
import 'Model/User.dart';

import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';

class OrderDetail extends StatefulWidget {
  final Order_Model model;
  final Function updateHome;

  const OrderDetail({Key key, this.model, this.updateHome}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateOrder();
  }
}

class StateOrder extends State<OrderDetail> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController controller = new ScrollController();
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;
  List<User> tempList = [];
  bool _isCancleable, _isReturnable, _isLoading = true;
  bool _isProgress = false;
  int offset = 0;
  int total = 0;
  List<User> reviewList = [];
  bool isLoadingmore = true;
  double initialRate = 0;
  String proId, image;
  TextEditingController _commentC = new TextEditingController();
  List<File> files = [];
  double curRating = 0.0;

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

  updateDetail() {
    setState(() {});
  }

  _getAppbar() {
    double width = deviceWidth;
    double height = width / 2;
    return AppBar(
      title: Text(
        ORDER_DETAIL,
        style: TextStyle(
          color: fontColor,
        ),
      ),
      iconTheme: new IconThemeData(color: primary),
      backgroundColor: white,
      // elevation: 5,
      leading: Builder(builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.all(10),
          decoration: shadow(),
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: InkWell(
                child: Icon(Icons.keyboard_arrow_left, color: primary),
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        );
      }),
      actions: <Widget>[
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
            child: Container(
              decoration: shadow(),
              child: Card(
                elevation: 0,
                child: new Stack(children: <Widget>[
                  Center(
                    child: Image.asset(
                      'assets/images/noti_cart.png',
                      width: 30,
                    ),
                  ),
                  (CUR_CART_COUNT != null &&
                          CUR_CART_COUNT.isNotEmpty &&
                          CUR_CART_COUNT != "0")
                      ? new Positioned(
                          top: 0.0,
                          right: 5.0,
                          bottom: 10,
                          child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primary.withOpacity(0.5)),
                              child: new Center(
                                child: Padding(
                                  padding: EdgeInsets.all(3),
                                  child: new Text(
                                    CUR_CART_COUNT,
                                    style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                        )
                      : Container()
                ]),
              ),
            ),
          ),
          onTap: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Cart(widget.updateHome, updateDetail),
                ));
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    Order_Model model = widget.model;
    String pDate, prDate, sDate, dDate, cDate, rDate;

    if (model.listStatus.contains(PLACED)) {
      pDate = model.listDate[model.listStatus.indexOf(PLACED)];

      if (pDate != null) {
        List d = pDate.split(" ");
        pDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus.contains(PROCESSED)) {
      prDate = model.listDate[model.listStatus.indexOf(PROCESSED)];
      if (prDate != null) {
        List d = prDate.split(" ");
        prDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus.contains(SHIPED)) {
      sDate = model.listDate[model.listStatus.indexOf(SHIPED)];
      if (sDate != null) {
        List d = sDate.split(" ");
        sDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus.contains(DELIVERD)) {
      dDate = model.listDate[model.listStatus.indexOf(DELIVERD)];
      if (dDate != null) {
        List d = dDate.split(" ");
        dDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus.contains(CANCLED)) {
      cDate = model.listDate[model.listStatus.indexOf(CANCLED)];
      if (cDate != null) {
        List d = cDate.split(" ");
        cDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus.contains(RETURNED)) {
      rDate = model.listDate[model.listStatus.indexOf(RETURNED)];
      if (rDate != null) {
        List d = rDate.split(" ");
        rDate = d[0] + "\n" + d[1];
      }
    }

    _isCancleable = model.isCancleable == "1" ? true : false;
    _isReturnable = model.isReturnable == "1" ? true : false;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: _getAppbar(),
      body: _isNetworkAvail
          ? Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                  height: 50,
                                  width: deviceWidth,
                                  child: Card(
                                      elevation: 0,
                                      child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            ORDER_ID_LBL + " - " + model.id,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2
                                                .copyWith(color: lightBlack2),
                                          )))),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: model.itemList.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, i) {
                                  OrderItem orderItem = model.itemList[i];
                                  proId = orderItem.id;
                                  return productItem(orderItem, model);
                                },
                              ),
                              _writeReview(),
                              DwnInvoice(),
                              shippingDetails(),
                              priceDetails(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    (!widget.model.itemList[0].listStatus.contains(DELIVERD) &&
                            (!widget.model.itemList[0].listStatus
                                .contains(RETURNED)) &&
                            _isCancleable &&
                            widget.model.itemList[0].isAlrCancelled == "0")
                        ? cancelable()
                        : (widget.model.itemList[0].listStatus
                                    .contains(DELIVERD) &&
                                _isReturnable &&
                                widget.model.itemList[0].isAlrReturned == "0")
                            ? returnable()
                            : Container(),
                  ],
                ),
                showCircularProgress(_isProgress, primary),
              ],
            )
          : noInternet(context),
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
      width: deviceWidth,
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

  priceDetails() {
    return Card(
        elevation: 0,
        child: Padding(
            padding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(PRICE_DETAIL,
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: fontColor, fontWeight: FontWeight.bold))),
              Divider(
                color: lightBlack,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(PRICE_LBL + " " + ":",
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: lightBlack2)),
                    Text(CUR_CURRENCY + " " + widget.model.subTotal,
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: lightBlack2))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DELIVERY_CHARGE + " " + ":",
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: lightBlack2)),
                    Text("+ " + CUR_CURRENCY + " " + widget.model.delCharge,
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: lightBlack2))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(TAXPER + " (" + widget.model.taxPer + ")" + " " + ":",
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: lightBlack2)),
                    Text("+ " + CUR_CURRENCY + " " + widget.model.taxAmt,
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: lightBlack2))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(PROMO_CODE_DIS_LBL + " " + ":",
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: lightBlack2)),
                    Text("- " + CUR_CURRENCY + " " + widget.model.promoDis,
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: lightBlack2))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(WALLET_BAL + " " + ":",
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: lightBlack2)),
                    Text("- " + CUR_CURRENCY + " " + widget.model.walBal,
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: lightBlack2))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(TOTAL_PRICE + " " + ":",
                        style: Theme.of(context).textTheme.button.copyWith(
                            color: lightBlack, fontWeight: FontWeight.bold)),
                    Text(CUR_CURRENCY + " " + widget.model.total,
                        style: Theme.of(context).textTheme.button.copyWith(
                            color: lightBlack, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ])));
  }

  shippingDetails() {
    return Card(
        elevation: 0,
        child: Padding(
            padding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(SHIPPING_DETAIL,
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: fontColor, fontWeight: FontWeight.bold))),
              Divider(
                color: lightBlack,
              ),
              Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    widget.model.name + ",",
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(widget.model.address,
                      style: TextStyle(color: lightBlack2))),
              Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(widget.model.mobile,
                      style: TextStyle(
                        color: lightBlack2,
                      ))),
            ])));
  }

  _writeReview() {
    return widget.model.itemList[0].listStatus.contains(DELIVERD)
        ? Card(
            elevation: 0,
            child: Padding(
                padding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        WRITE_REVIEW_LBL,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: fontColor),
                      ),
                      _rating(),
                      Padding(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: TextField(
                            controller: _commentC,
                            style: Theme.of(context).textTheme.subtitle2,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: REVIEW_HINT_LBL,
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                      color: lightBlack2.withOpacity(0.7)),
                            ),
                          )),
                      Container(
                        padding:
                            EdgeInsets.only(left: 20.0, right: 20.0, top: 5),
                        height: files != null && files.length > 0 ? 80 : 50,
                        child: Row(
                          children: [
                            Expanded(
                                child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: files.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, i) {
                                return InkWell(
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Image.file(
                                        files[i],
                                        width: 80,
                                        height: 80,
                                      ),
                                      Container(
                                          color: Colors.black26,
                                          child: Icon(
                                            Icons.clear,
                                            size: 15,
                                          ))
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      files.removeAt(i);
                                    });
                                  },
                                );
                              },
                            )),
                            IconButton(
                                icon: Icon(
                                  Icons.add_photo_alternate,
                                  color: primary,
                                  size: 25.0,
                                ),
                                onPressed: () {
                                  _imgFromGallery();
                                })
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          child: Container(
                            margin: EdgeInsets.only(left: 8, right: 20),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                                color: lightWhite,
                                borderRadius: new BorderRadius.all(
                                    const Radius.circular(4.0))),
                            child: Text(
                              SUBMIT_LBL,
                              style: TextStyle(color: fontColor, fontSize: 10),
                            ),
                          ),
                          onTap: () {
                            if (curRating != 0 ||
                                _commentC.text != '' ||
                                (files != null && files.length > 0))
                              setRating(curRating, _commentC.text, files);
                            else
                              setSnackbar(REVIEW_W);
                          },
                        ),
                      ),
                    ])))
        : Container();
  }

  _rating() {
    return Padding(
      padding: EdgeInsets.only(top: 7.0, bottom: 7.0),
      child: RatingBar.builder(
        initialRating: 0,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemSize: 32,
        itemPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: primary,
        ),
        onRatingUpdate: (rating) {
          curRating = rating;
        },
      ),
    );
  }

  productItem(OrderItem orderItem, Order_Model model) {
    String pDate, prDate, sDate, dDate, cDate, rDate;

    if (orderItem.listStatus.contains(PLACED)) {
      pDate = orderItem.listDate[orderItem.listStatus.indexOf(PLACED)];
    }
    if (orderItem.listStatus.contains(PROCESSED)) {
      prDate = orderItem.listDate[orderItem.listStatus.indexOf(PROCESSED)];
    }
    if (orderItem.listStatus.contains(SHIPED)) {
      sDate = orderItem.listDate[orderItem.listStatus.indexOf(SHIPED)];
    }
    if (orderItem.listStatus.contains(DELIVERD)) {
      dDate = orderItem.listDate[orderItem.listStatus.indexOf(DELIVERD)];
    }
    if (orderItem.listStatus.contains(CANCLED)) {
      cDate = orderItem.listDate[orderItem.listStatus.indexOf(CANCLED)];
    }
    if (orderItem.listStatus.contains(RETURNED)) {
      rDate = orderItem.listDate[orderItem.listStatus.indexOf(RETURNED)];
    }
    List att, val;
    if (orderItem.attr_name.isNotEmpty) {
      att = orderItem.attr_name.split(',');
      val = orderItem.varient_values.split(',');
    }
    return Card(
        elevation: 0,
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: FadeInImage(
                          fadeInDuration: Duration(milliseconds: 150),
                          image: NetworkImage(orderItem.image),
                          height: 90.0,
                          width: 90.0,
                          placeholder: placeHolder(90),
                        )),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderItem.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                      color: lightBlack,
                                      fontWeight: FontWeight.normal),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            orderItem.attr_name.isNotEmpty
                                ? ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: att.length,
                                    itemBuilder: (context, index) {
                                      return Row(children: [
                                        Flexible(
                                          child: Text(
                                            att[index].trim() + ":",
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2
                                                .copyWith(color: lightBlack2),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 5.0),
                                          child: Text(
                                            val[index],
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2
                                                .copyWith(color: lightBlack),
                                          ),
                                        )
                                      ]);
                                    })
                                : Container(),

                            Row(children: [
                              Text(
                                QUANTITY_LBL + ":",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(color: lightBlack2),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 5.0),
                                child: Text(
                                  orderItem.qty,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(color: lightBlack),
                                ),
                              )
                            ]),
                            Text(
                              CUR_CURRENCY + " " + orderItem.price,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(color: fontColor),
                            ),

                            //  Text(orderItem.status)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Divider(
                  color: lightBlack,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      getPlaced(pDate),
                      getProcessed(prDate, cDate),
                      getShipped(sDate, cDate),
                      getDelivered(dDate, cDate),
                      getCanceled(cDate),
                      getReturned(orderItem, rDate, model),
                    ],
                  ),
                ),
                model.itemList.length > 1
                    ? (!orderItem.listStatus.contains(DELIVERD) &&
                            (!orderItem.listStatus.contains(RETURNED)) &&
                            orderItem.isCancle == "1" &&
                            orderItem.isAlrCancelled == "0")
                        ? Column(
                            children: [
                              Divider(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: lightWhite,
                                          borderRadius: new BorderRadius.all(
                                              const Radius.circular(4.0))),
                                      child: Text(ITEM_CANCEL,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .button
                                              .copyWith(
                                                color: fontColor,
                                              ))),
                                  onPressed: () {
                                    cancelOrder(CANCLED, updateOrderItemApi,
                                        orderItem.id);
                                  },
                                ),
                              ),
                            ],
                          )
                        : (orderItem.listStatus.contains(DELIVERD) &&
                                orderItem.isReturn == "1" &&
                                orderItem.isAlrReturned == "0")
                            ? Column(
                                children: [
                                  Divider(),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          decoration: BoxDecoration(
                                              color: lightWhite,
                                              borderRadius: new BorderRadius
                                                      .all(
                                                  const Radius.circular(4.0))),
                                          child: Text(ITEM_RETURN,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .button
                                                  .copyWith(
                                                    color: fontColor,
                                                  ))),
                                      onPressed: () {
                                        cancelOrder(RETURNED,
                                            updateOrderItemApi, orderItem.id);
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Container()
                    : Container(),
              ],
            )));
  }

  getPlaced(String pDate) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          color: primary,
          size: 15,
        ),
        Container(
          margin: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ORDER_NPLACED,
                style: TextStyle(fontSize: 8),
              ),
              Text(
                pDate,
                style: TextStyle(fontSize: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  getProcessed(String prDate, String cDate) {
    return cDate == null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Container(
                      height: 30,
                      child: VerticalDivider(
                        thickness: 2,
                        color: prDate == null ? Colors.grey : primary,
                      )),
                  Icon(
                    Icons.circle,
                    color: prDate == null ? Colors.grey : primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ORDER_PROCESSED,
                      style: TextStyle(fontSize: 8),
                    ),
                    Text(
                      prDate ?? " ",
                      style: TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          )
        : prDate == null
            ? Container()
            : Column(
                children: [
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 2,
                      color: primary,
                    ),
                  ),
                  Text(
                    ORDER_PROCESSED,
                    style: TextStyle(fontSize: 8),
                  ),
                  Icon(
                    Icons.circle,
                    color: primary,
                    size: 15,
                  ),
                ],
              );
  }

  getShipped(String sDate, String cDate) {
    return cDate == null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 2,
                      color: sDate == null ? Colors.grey : primary,
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    color: sDate == null ? Colors.grey : primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ORDER_SHIPPED,
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      sDate ?? " ",
                      style: TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          )
        : sDate == null
            ? Container()
            : Column(
                children: [
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 2,
                    ),
                  ),
                  Text(
                    ORDER_SHIPPED,
                    style: TextStyle(fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                  Icon(
                    Icons.circle,
                    color: primary,
                    size: 15,
                  ),
                ],
              );
  }

  getDelivered(String dDate, String cDate) {
    return cDate == null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 2,
                      color: dDate == null ? Colors.grey : primary,
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    color: dDate == null ? Colors.grey : primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ORDER_DELIVERED,
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      dDate ?? " ",
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          )
        : Container();
  }

  getCanceled(String cDate) {
    return cDate != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 2,
                      color: primary,
                    ),
                  ),
                  Icon(
                    Icons.cancel_rounded,
                    color: primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ORDER_CANCLED,
                      style: TextStyle(fontSize: 8),
                    ),
                    Text(
                      cDate ?? "",
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          )
        : Container();
  }

  getReturned(OrderItem item, String rDate, Order_Model model) {
    return item.listStatus.contains(RETURNED)
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 2,
                      color: primary,
                    ),
                  ),
                  Icon(
                    Icons.cancel_rounded,
                    color: primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ORDER_RETURNED,
                        style: TextStyle(fontSize: 8),
                      ),
                      Text(
                        rDate ?? " ",
                        style: TextStyle(fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )),
            ],
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
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  _imgFromGallery() async {
    files = await FilePicker.getMultiFile(type: FileType.image);
    if (files != null) {
      setState(() {});
    }

    ///for ios uncomment below code and update file picker library version in pubspec.yaml
    /*  FilePickerResult result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if(result != null) {
      files= result.paths.map((path) => File(path)).toList();
    } else {
      // User canceled the picker
    }*/
  }

  Future<void> setRating(
      double rating, String comment, List<File> files) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          _isProgress = true;
        });
        var request = http.MultipartRequest("POST", Uri.parse(setRatingApi));
        request.headers.addAll(headers);
        request.fields[USER_ID] = CUR_USERID;
        request.fields[PRODUCT_ID] = widget.model.itemList[0].productId;

        if (files != null) {
          for (int i = 0; i < files.length; i++) {
            var pic = await http.MultipartFile.fromPath(IMGS, files[i].path);
            request.files.add(pic);
          }
        }

        if (comment != "") request.fields[COMMENT] = comment;
        if (rating != 0) request.fields[RATING] = rating.toString();
        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);
        bool error = getdata["error"];
        String msg = getdata['message'];
        if (!error) {
          setSnackbar(msg);
        } else {
          setSnackbar(msg);
          initialRate = 0;
        }

        _commentC.text = "";
        files.clear();
        setState(() {
          _isProgress = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
      }
    } else
      setState(() {
        _isNetworkAvail = false;
      });
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

  DwnInvoice() {
    return Card(
      elevation: 0,
      child: InkWell(
          child: ListTile(
            dense: true,
            trailing: Icon(
              Icons.keyboard_arrow_right,
              color: primary,
            ),
            leading: Icon(
              Icons.receipt,
              color: primary,
            ),
            title: Text(
              DWNLD_INVOICE,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(color: lightBlack),
            ),
          ),
          onTap: () async {
            final status = await Permission.storage.request();

            if (status == PermissionStatus.granted) {
              setState(() {
                _isProgress = true;
              });
              var targetPath;

              if (Platform.isIOS) {
                Directory target = await getApplicationDocumentsDirectory();
                targetPath = target.path.toString();
              } else
                targetPath = await ExtStorage.getExternalStoragePublicDirectory(
                    ExtStorage.DIRECTORY_DOWNLOADS);

              var targetFileName = "Invoice_${widget.model.id}";


              var generatedPdfFile =
                  await FlutterHtmlToPdf.convertFromHtmlContent(
                      widget.model.invoice, targetPath, targetFileName);

               _scaffoldKey.currentState.showSnackBar(new SnackBar(
                content: new Text(
                  "$INVOICE_PATH $targetFileName",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: black),
                ),
            /*    action: SnackBarAction(label: VIEW, onPressed: () async {
                final result = await OpenFile.open(generatedPdfFile.path);
                  setState(() {
                    //_openResult = "type=${result.type}  message=${result.message}";
                  });
                }),*/
                backgroundColor: white,
                elevation: 1.0,
              ));
              setState(() {
                _isProgress = false;
              });
            }
          }),
    );
  }
}

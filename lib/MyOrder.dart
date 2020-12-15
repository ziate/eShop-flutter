import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

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
import 'OrderDetail1.dart';

class MyOrder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateMyOrder();
  }
}

bool _isLoading = true;
List<Order_Model> orderList = [];
List<Order_Model> searchList = [];
List<Order_Model> deliveredList = [];
List<Order_Model> orderProgressList = [];
int pos = 0;

class StateMyOrder extends State<MyOrder> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String searchText;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    getOrder();
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

/*  onSearchTextChanged(String text) async {
    searchList.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    for (int i = 0, l = searchList.length; i < l; i++) {
      searchList[i].itemList.forEach((userDetail) {
        if (userDetail.id.contains(text) || userDetail.name.contains(text))
          searchList.add(userDetail);
      });
    }

    setState(() {});
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: getAppBar(MY_ORDERS_LBL, context),
      body: _isNetworkAvail
          ? _isLoading
              ? shimmer()
              : searchList.length == 0 && deliveredList.length == 0
                  ? Center(child: Text(noItem))
                  : SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                height: 45,
                                padding: EdgeInsets.only(left: 5.0, right: 5.0),
                                decoration: shadow(),
                                child: TextField(
                                  controller: _controller,
                                 // onChanged: onSearchTextChanged,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: white,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(15.0, 9.0, 0, 9.0),
                                    prefixIcon: Image.asset(
                                      'assets/images/search.png',
                                      color: primary,
                                    ),
                                    hintText: FIND_ORDER_ITEMS_LBL,
                                    hintStyle: TextStyle(
                                        color: fontColor.withOpacity(0.3),
                                        fontWeight: FontWeight.normal),
                                    border: new OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(10.0),
                                      ),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                  ),
                                )),
                            ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.only(top: 5.0),
                              itemCount: searchList.length,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                //  print("load more****$offset***$total***${favList.length}***$isLoadingmore**$index");
                                return orderItem(index);
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
         // String status = "$PLACED, $SHIPED, $PROCESSED, $CANCLED, $RETURNED";
          var parameter = {USER_ID: CUR_USERID};
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

            searchList.addAll(orderList);


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

  getSearch(String searchText) {
    print("hello");
    searchList.clear();
    print("searchList*****$searchList");
    for (int i = 0, l = searchList.length; i < l; i++) {
      //for (int j = 0, l = searchList[i].itemList.length; j < l; j++) {
      Order_Model map = searchList[i];
      if (map.id.toLowerCase().startsWith(searchText))
        searchList.add(map);
      else if (map.name.toLowerCase().startsWith(searchText))
        searchList.add(map);
    }
    //}
    print("searchList*****$searchList");
    setState(() {});
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
    return ListView.builder(
      shrinkWrap: true,
      itemCount: searchList[index].itemList.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        OrderItem orderItem = searchList[index].itemList[i];
        return productItem(index, orderItem);
      },
    );
  }

  productItem(int index, OrderItem orderItem) {
    print("detail=========${orderItem.image}*********${orderItem.name}");

    String sDate = orderItem.listDate.join(',');
    String proStatus = orderItem.listStatus.join(',');

    return Card(
      elevation: 0,
      margin: EdgeInsets.all(5.0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: InkWell(
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(children: <Widget>[
              Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Hero(
                    tag: "$index${orderItem.id}",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        imageUrl: orderItem.image,
                        height: 90.0,
                        width: 90.0,
                        placeholder: (context, url) => placeHolder(90),
                      ),
                    )),
                Expanded(
                    flex: 9,
                    child: Padding(
                        padding: EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "$proStatus on $sDate",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(color: lightBlack),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    orderItem.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        .copyWith(
                                            color: lightBlack2,
                                            fontWeight: FontWeight.normal),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ]))),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: primary,
                  size: 15,
                )
              ]),
            ])),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderDetail1(model: searchList[index])),
          );
          setState(() {
            _isLoading = true;
          });

          getOrder();
        },
      ),
    );
  }
}

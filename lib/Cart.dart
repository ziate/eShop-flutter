import 'dart:async';
import 'dart:convert';
import 'dart:ui';


import 'Helper/SimBtn.dart';

import 'package:eshop/CheckOut.dart';
import 'package:eshop/Helper/Constant.dart';

import 'package:eshop/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/String.dart';
import 'Model/Section_Model.dart';
import 'Product_Detail.dart';
import 'Home.dart';

class Cart extends StatefulWidget {
  final Function updateHome, updateParent;

  Cart(this.updateHome, this.updateParent);

  @override
  State<StatefulWidget> createState() => StateCart();
}

List<Section_Model> cartList = [];
double totalPrice = 0, oriPrice = 0, delCharge = 0, taxAmt = 0, taxPer = 0;

class StateCart extends State<Cart> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isProgress = false, _isLoading = true;
  HomePage home;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;
  bool _value = false;
  List<TextEditingController> _controller = [];
  var items;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  List<Section_Model> saveLaterList = [];

  @override
  void initState() {
    super.initState();
    totalPrice = 0;
    oriPrice = 0;
    taxAmt = 0;
    taxPer = 0;
    delCharge = 0;
    cartList.clear();
    _getCart("0");
    _getSaveLater("1");
    home = new HomePage(widget.updateHome);
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


  Future<Null> _refresh() {
    setState(() {
      _isLoading = true;
    });
    totalPrice = 0;
    oriPrice = 0;
    taxAmt = 0;
    taxPer = 0;
    delCharge = 0;
    cartList.clear();
    _getCart("0");
    return _getSaveLater("1");


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
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: lightWhite,
        appBar: getAppBar(CART, context),
        body: _isNetworkAvail
            ? Stack(
                children: <Widget>[
                  _showContent(),
                  showCircularProgress(_isProgress, primary),
                ],
              )
            : noInternet(context));
  }

  Future<bool> getSection() async {
    try {
      var parameter = {PRODUCT_LIMIT: "4", PRODUCT_OFFSET: "0"};

      if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
      Response response =
          await post(getSectionApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      print('section get***');
      print('response***sec**$headers***${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        sectionList.clear();
        sectionList = (data as List)
            .map((data) => new Section_Model.fromJson(data))
            .toList();
      } else {
        setSnackbar(msg);
      }
    } catch (Exception) {}
    Navigator.of(context).pop(true);
    return true;
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


    items = new List<String>.generate(
        int.parse(cartList[index].productList[0].totalAllow), (i) => (i+1).toString());



    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            /*     GestureDetector(
          child: */
            Row(
          children: <Widget>[
            Hero(
                tag: "$index${cartList[index].productList[0].id}",
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(7.0),
                    child: FadeInImage(
                      image:NetworkImage(cartList[index].productList[0].image),
                      height: 60.0,
                      width: 60.0,
                     // errorWidget:(context, url,e) => placeHolder(60) ,
                      placeholder:placeHolder(60),
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
                    /*  Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 12,
                            ),
                            Text(
                              " " + cartList[index].productList[0].rating,
                              style: Theme.of(context).textTheme.overline,
                            ),
                            Text(
                              " (" +
                                  cartList[index].productList[0].noOfRating +
                                  ")",
                              style: Theme.of(context).textTheme.overline,
                            )
                          ],
                        ),
                      ),*/
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
                          style: Theme.of(context).textTheme.overline.copyWith(
                              decoration: TextDecoration.lineThrough,
                              letterSpacing: 0.7),
                        ),
                        Text(
                          " " + CUR_CURRENCY + " " + price.toString(),
                          style: TextStyle(
                              color: fontColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    cartList[index].productList[0].availability == "1" ||
                            cartList[index].productList[0].stockType == "null"
                        ? Row(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  GestureDetector(
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
                                  /*        Text(
                                      cartList[index].qty,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .copyWith(color: fontColor),*/
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
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: fontColor, width: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: fontColor, width: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
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
                                          itemBuilder: (BuildContext context) {
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

                                  GestureDetector(
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
                                          (int.parse(cartList[index].qty) + 1)
                                              .toString());
                                    },
                                  )
                                ],
                              ),
                              GestureDetector(
                                child: Container(
                                  margin: EdgeInsets.only(left: 8),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: lightWhite,
                                      borderRadius: new BorderRadius.all(
                                          const Radius.circular(4.0))),
                                  child: Text(
                                    SAVEFORLATER_BTN,
                                    style: TextStyle(
                                        color: fontColor, fontSize: 10),
                                  ),
                                ),
                                onTap: () {
                                  saveForLater(
                                      cartList[index].varientId,
                                      "1",
                                      cartList[index].qty,
                                      double.parse(
                                          cartList[index].perItemTotal),
                                      cartList[index]);
                                },
                              ),
                              /* Text(
                                    " " +
                                        CUR_CURRENCY +
                                        " " +
                                        cartList[index].perItemTotal.toString(),
                                    style: Theme.of(context).textTheme.headline6)*/
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            )
          ],
        ),
/*          onTap: () async {
*/ /*            Product model = cartList[index].productList[0];
            await Navigator.push(
              context,
              PageRouteBuilder(
                  transitionDuration: Duration(seconds: 1),
                  pageBuilder: (_, __, ___) => ProductDetail(
                        model: model,
                        updateParent: updateCart,
                        updateHome: widget.updateHome,
                        secPos: 0,
                        index: index,
                        list: true,
                        //  title: productList[index].name,
                      )),
            );

            totalPrice = 0;
            oriPrice = 0;
            taxAmt = 0;
            taxPer = 0;
            delCharge = 0;
            cartList.clear();
            _getCart();*/ /*
          },*/
        //),
      ),
    );
  }

  Widget saveLaterItem(int index) {
    //print("desc*****${productList[index].desc}");
    int selectedPos = 0;
    for (int i = 0;
        i < saveLaterList[index].productList[0].prVarientList.length;
        i++) {
      if (saveLaterList[index].varientId ==
          saveLaterList[index].productList[0].prVarientList[i].id)
        selectedPos = i;
    }

    double price = double.parse(saveLaterList[index]
        .productList[0]
        .prVarientList[selectedPos]
        .disPrice);
    if (price == 0)
      price = double.parse(
          saveLaterList[index].productList[0].prVarientList[selectedPos].price);

    saveLaterList[index].perItemPrice = price.toString();
    saveLaterList[index].perItemTotal =
        (price * double.parse(saveLaterList[index].qty)).toString();

    print("price****$oriPrice***$price---$index");

    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            /*     GestureDetector(
          child: */
            Row(
          children: <Widget>[
            Hero(
                tag: "$index${saveLaterList[index].productList[0].id}",
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(7.0),
                    child: FadeInImage(
                      image: NetworkImage(saveLaterList[index].productList[0].image),
                      height: 60.0,
                      width: 60.0,

                      //errorWidget:(context, url,e) => placeHolder(60) ,
                      placeholder:placeHolder(60),
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
                              saveLaterList[index].productList[0].name,
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
                          int.parse(saveLaterList[index]
                                      .productList[0]
                                      .prVarientList[selectedPos]
                                      .disPrice) !=
                                  0
                              ? CUR_CURRENCY +
                                  "" +
                                  saveLaterList[index]
                                      .productList[0]
                                      .prVarientList[selectedPos]
                                      .price
                              : "",
                          style: Theme.of(context).textTheme.overline.copyWith(
                              decoration: TextDecoration.lineThrough,
                              letterSpacing: 0.7),
                        ),
                        Text(
                          " " + CUR_CURRENCY + " " + price.toString(),
                          style: TextStyle(
                              color: fontColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    saveLaterList[index].productList[0].availability == "1" ||
                            saveLaterList[index].productList[0].stockType ==
                                "null"
                        ? Row(
                            children: <Widget>[
                              GestureDetector(
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: lightWhite,
                                      borderRadius: new BorderRadius.all(
                                          const Radius.circular(4.0))),
                                  child: Text(
                                    MOVE_TO_CART,
                                    style: TextStyle(
                                        color: fontColor, fontSize: 10),
                                  ),
                                ),
                                onTap: () {
                                  saveForLater(
                                      saveLaterList[index].varientId,
                                      "0",
                                      saveLaterList[index].qty,
                                      double.parse(
                                          saveLaterList[index].perItemTotal),
                                      saveLaterList[index]);
                                },
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
      ),
    );
  }

  updateCart() {
    setState(() {});
  }

  Future<void> _getCart(String save) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};
        Response response =
            await post(getCartApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print(
            'response***setting**${parameter.toString()}****${response.body.toString()}');
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          delCharge = double.parse(getdata[DEL_CHARGE]);
          oriPrice = double.parse(getdata[SUB_TOTAL]);
          taxAmt = double.parse(getdata[TAX_AMT]);
          taxPer = double.parse(getdata[TAX_PER]);
          totalPrice = delCharge + oriPrice + taxAmt;
          // print('cart data**********$data');
          cartList = (data as List)
              .map((data) => new Section_Model.fromCart(data))
              .toList();

          for (int i = 0; i < cartList.length; i++)
            _controller.add(new TextEditingController());
        } else {
          if (msg != 'Cart Is Empty !') setSnackbar(msg);
        }
        setState(() {
          _isLoading = false;
        });
        setState(() {});
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Future<Null> _getSaveLater(String save) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};
        Response response =
            await post(getCartApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print(
            'response***setting**${parameter.toString()}****${response.body.toString()}');
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          saveLaterList = (data as List)
              .map((data) => new Section_Model.fromCart(data))
              .toList();

          for (int i = 0; i < cartList.length; i++)
            _controller.add(new TextEditingController());
        } else {
          if (msg != 'Cart Is Empty !') setSnackbar(msg);
        }
        setState(() {
          _isLoading = false;
        });
        setState(() {});
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }

    return null;
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
          taxAmt = double.parse(data[TAX_AMT]);
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

  saveForLater(String id, String save, String qty, double price,
      Section_Model curItem) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          _isProgress = true;
        });

        var parameter = {
          PRODUCT_VARIENT_ID: id,
          USER_ID: CUR_USERID,
          QTY: qty,
          SAVE_LATER: save
        };

        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        print(
            'response***manage**${parameter.toString()}***${response.body.toString()}');

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          String qty = data['total_quantity'];
          CUR_CART_COUNT = data['cart_count'];

          if (save == "1") {
            saveLaterList.add(curItem);
            cartList.removeWhere((item) => item.varientId == id);
            oriPrice = oriPrice - price;

            totalPrice = 0;
            totalPrice = delCharge + oriPrice + taxAmt;
          } else {
            cartList.add(curItem);
            saveLaterList.removeWhere((item) => item.varientId == id);
            oriPrice = oriPrice + price;

            totalPrice = 0;
            totalPrice = delCharge + oriPrice + taxAmt;
          }
        } else {
          setSnackbar(msg);
        }
        setState(() {
          _isProgress = false;
        });
        if (widget.updateHome != null) widget.updateHome();
        if (widget.updateParent != null) widget.updateParent();
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

        print('response***slider**${parameter.toString()}***$getdata');

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
          taxAmt= double.parse(data[TAX_AMT]);
          totalPrice = 0;
          totalPrice = delCharge + oriPrice + taxAmt;
        } else {
          setSnackbar(msg);
        }
        setState(() {
          _isProgress = false;
        });
        if (widget.updateHome != null) widget.updateHome();
        if (widget.updateParent != null) widget.updateParent();
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

  _showContent() {
    return _isLoading
        ? shimmer()
        : cartList.length == 0 && saveLaterList.length == 0
            ? cartEmpty()
            : Column(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child:

                        RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _refresh,
                        child:
                        SingleChildScrollView(
                          physics: const  AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: cartList.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return listItem(index);
                                },
                              ),
                              saveLaterList.length > 0
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        SAVEFORLATER_BTN,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    )
                                  : Container(),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: saveLaterList.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return saveLaterItem(index);
                                },
                              ),
                            ],
                          ),
                        ))),
                  ),

                  /*   Padding(
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
*/
                  Container(
                    color: white,
                    child: Row(children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                CUR_CURRENCY + " $oriPrice",
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
                          title: PROCEED_CHECKOUT,
                          onBtnSelected: () async{
                            if (oriPrice > 0) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CheckOut(widget.updateHome),
                                ),
                              );
                              setState(() {
                              });
                            }
                            else
                              setSnackbar(ADD_ITEM);
                          }),
                    ]),
                  ),
                ],
              );
  }

  cartEmpty() {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noCartImage(context),
          noCartText(context),
          noCartDec(context),
          shopNow()
        ]),
      ),
    );
  }

  noCartImage(BuildContext context) {
    return Image.asset(
      'assets/images/empty_cart.png',
      fit: BoxFit.contain,
    );
  }

  noCartText(BuildContext context) {
    return Container(
        child: Text(NO_CART,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: primary, fontWeight: FontWeight.normal)));
  }

  noCartDec(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
      child: Text(CART_DESC,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              )),
    );
  }

  shopNow() {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0),
      child: CupertinoButton(
        child: Container(
            width: deviceWidth * 0.7,
            height: 45,
            alignment: FractionalOffset.center,
            decoration: new BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [grad1Color, grad2Color],
                  stops: [0, 1]),
              borderRadius: new BorderRadius.all(const Radius.circular(50.0)),
            ),
            child: Text(SHOP_NOW,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: white, fontWeight: FontWeight.normal))),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (BuildContext context) => Home()),
              ModalRoute.withName('/'));
        },
      ),
    );
  }
}

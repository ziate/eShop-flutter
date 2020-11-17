import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/CheckOut.dart';
import 'package:eshop/Helper/Constant.dart';

import 'package:eshop/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';

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

class StateCart extends State<Cart> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isProgress = false, _isLoading = true;
  HomePage home;

  @override
  void initState() {
    super.initState();
    totalPrice = 0;
    oriPrice = 0;
    taxAmt = 0;
    taxPer = 0;
    delCharge = 0;
    cartList.clear();
    _getCart();
    home = new HomePage(widget.updateHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: getAppBar(CART, context),
        body: Stack(
          children: <Widget>[
            _showContent(),
            showCircularProgress(_isProgress, primary),
          ],
        ));
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
    return Card(
      elevation: 0.1,
      child: InkWell(
        child: Row(
          children: <Widget>[
            Hero(
                tag: "$index${cartList[index].productList[0].id}",
                child: CachedNetworkImage(
                  imageUrl: cartList[index].productList[0].image,
                  height: 90.0,
                  width: 90.0,
                  placeholder: (context, url) => placeHolder(90),
                )),
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
                                  .subtitle1
                                  .copyWith(color: Colors.black),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8, bottom: 8),
                            child: Icon(
                              Icons.close,
                              size: 13,
                            ),
                          ),
                          onTap: () {
                            removeFromCart(index, true);
                          },
                        )
                      ],
                    ),
                    Padding(
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
                          style: Theme.of(context).textTheme.overline.copyWith(
                              decoration: TextDecoration.lineThrough,
                              letterSpacing: 0.7),
                        ),
                        Text(
                          " " + CUR_CURRENCY + " " + price.toString(),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            InkWell(
                              child: Container(
                                margin: EdgeInsets.only(
                                    right: 8, top: 8, bottom: 8),
                                child: Icon(
                                  Icons.remove,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                              onTap: () {
                                removeFromCart(index, false);
                              },
                            ),
                            Text(
                              cartList[index].qty,
                              style: Theme.of(context).textTheme.caption,
                            ),
                            InkWell(
                              child: Container(
                                margin: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.add,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                              onTap: () {
                                addToCart(index);
                              },
                            )
                          ],
                        ),
                        Spacer(),
                        Text(
                            " " +
                                CUR_CURRENCY +
                                " " +
                                cartList[index].perItemTotal.toString(),
                            style: Theme.of(context).textTheme.headline6)
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        splashColor: primary.withOpacity(0.2),
        onTap: () async {
          Product model = cartList[index].productList[0];
        await  Navigator.push(
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
          _getCart();
        },
      ),
    );
  }

  updateCart() {
    setState(() {});
  }

  Future<void> _getCart() async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
      };
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

        totalPrice = delCharge + oriPrice + taxAmt;
        // print('cart data**********$data');
        cartList = (data as List)
            .map((data) => new Section_Model.fromCart(data))
            .toList();
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
  }

  Future<void> addToCart(int index) async {
    try {
      setState(() {
        _isProgress = true;
      });
      var parameter = {
        PRODUCT_VARIENT_ID: cartList[index].varientId,
        USER_ID: CUR_USERID,
        QTY: (int.parse(cartList[index].qty) + 1).toString(),
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
  }

  removeFromCart(int index, bool remove) async {
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
      if (widget.updateParent != null) widget.updateParent();
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isProgress = false;
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

  _showContent() {
    return _isLoading
        ? shimmer()
        : cartList.length == 0
            ? cartEmpty()
            : Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: cartList.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return listItem(index);
                      },
                    ),
                  ),
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
                  InkWell(
                    splashColor: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckOut(),
                        ),
                      );
                    },
                    child: Container(
                      height: 55,
                      decoration: back(),
                      width: double.infinity,
                      child: Center(
                          child: Text(
                        PROCEED_CHECKOUT,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: Colors.white),
                      )),
                    ),
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
                color: lightblack,
                fontWeight: FontWeight.normal,
              )),
    );
  }

  shopNow() {
    return Padding(
      padding: const EdgeInsets.only(top:28.0),
      child: CupertinoButton(
        child: Container(
            width: deviceWidth * 0.7,
            height: 45,
            alignment: FractionalOffset.center,
            decoration: new BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryLight2, primaryLight3],
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
              MaterialPageRoute(
                  builder: (BuildContext context) => Home()),
              ModalRoute.withName('/'));
        },
      ),
    );
  }
}

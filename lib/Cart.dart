import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
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

class Cart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateCart();
}

class StateCart extends State<Cart> {
  List<Section_Model> productList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isProgress = false, _isLoading = true;
  double totalPrice = 0, oriPrice = 0, delCharge = 0, taxAmt = 0, taxPer = 0;

  @override
  void initState() {
    super.initState();
    totalPrice = 0;
    oriPrice = 0;

    delCharge = 0;
    _getCart();
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

  Widget listItem(int index) {
    //print("desc*****${productList[index].desc}");
    int selectedPos = 0;
    for (int i = 0;
        i < productList[index].productList[0].prVarientList.length;
        i++) {
      if (productList[index].varientId ==
          productList[index].productList[0].prVarientList[i].id)
        selectedPos = i;

      print("selected pos***$selectedPos***${productList[index].productList[0].prVarientList[i].id}");
    }

    double price = double.parse(
        productList[index].productList[0].prVarientList[selectedPos].disPrice);
    if (price == 0)
      price = double.parse(
          productList[index].productList[0].prVarientList[selectedPos].price);

    print("price****$oriPrice***$price---$index");
    return Card(
      elevation: 0.1,
      child: InkWell(
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: productList[index].productList[0].image,
              height: 90.0,
              width: 90.0,
              placeholder: (context, url) => placeHolder(90),
            ),
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
                              productList[index].productList[0].name,
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
                            " " + productList[index].productList[0].rating,
                            style: Theme.of(context).textTheme.overline,
                          ),
                          Text(
                            " (" +
                                productList[index].productList[0].noOfRating +
                                ")",
                            style: Theme.of(context).textTheme.overline,
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          int.parse(productList[index]
                                      .productList[0]
                                      .prVarientList[selectedPos]
                                      .disPrice) !=
                                  0
                              ? CUR_CURRENCY +
                                  "" +
                                  productList[index]
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
                              productList[index].qty,
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
                                productList[index].perItemTotal.toString(),
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
        onTap: () {
          Product model = productList[index].productList[0];
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Product_Detail(
                      model: model,
                      //  title: productList[index].name,
                    )),
          );
        },
      ),
    );
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


       // print('cart data**********$data');
        productList = (data as List)
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
        PRODUCT_VARIENT_ID: productList[index].varientId,
        USER_ID: CUR_USERID,
        QTY: (int.parse(productList[index].qty) + 1).toString(),
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

        int qty = data['total_quantity'];

        print('total*****add*$qty');
        productList[index].qty = qty.toString();
      } else {
        setSnackbar(msg);
      }
      setState(() {
        _isProgress = false;
      });
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
        PRODUCT_VARIENT_ID: productList[index].varientId,
        USER_ID: CUR_USERID,
        QTY: remove ? "0" : (int.parse(productList[index].qty) - 1).toString()
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

        int qty = data['total_quantity'];

        print('total*****remove*$qty');
        if (remove)
          productList.removeWhere(
              (item) => item.varientId == productList[index].varientId);
        else {
          productList[index].qty = qty.toString();
        }
      } else {
        setSnackbar(msg);
      }
      setState(() {
        _isProgress = false;
      });
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
        ? getProgress()
        : productList.length == 0
            ? Center(child: Text('Cart is empty'))
            : Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: productList.length,
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
                          CUR_CURRENCY,
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
                      /* Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Cart(),
                        ),
                      );*/
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
}

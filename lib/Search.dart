import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:eshop/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

import 'package:http/http.dart';

import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/String.dart';
import 'Login.dart';
import 'Model/Section_Model.dart';
import 'Product_Detail.dart';

class Search extends StatefulWidget {
  Function updateHome;

  Search(this.updateHome);

  @override
  _StateSearch createState() => _StateSearch();
}

class _StateSearch extends State<Search> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isProgress = false;
  List<Product> productList = [];
  List<Product> tempList = [];

  int offset = 0, offsetSending = 0;
  int total = 0;
  bool isLoadingmore = true;
  ScrollController controller = new ScrollController();

  @override
  void initState() {
    super.initState();
    productList.clear();
    controller.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: primary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.white,
          title: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              prefixIcon: Icon(Icons.search, color: primary),
              hintText: 'Search',
              hintStyle: TextStyle(color: primary.withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            onChanged: (string) {
              setState(() {
                _isProgress = true;
              });
              print("onchange****$string");
              getProduct(string, true);
            },
          ),
        ),
        body: Stack(
          children: <Widget>[
            _showContent(),
            showCircularProgress(_isProgress, primary),
          ],
        ));
  }

  Widget listItem(int index) {

    double price = double.parse(
        productList[index].prVarientList[0].disPrice);
    if (price == 0)
      price = double.parse(
          productList[index].prVarientList[0].price);

    return Card(
      child: InkWell(
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: productList[index].image,
              height: 90.0,
              width: 90.0,
              placeholder: (context, url) => placeHolder(90),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      productList[index].name,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                            " " + productList[index].rating,
                            style: Theme.of(context).textTheme.overline,
                          ),
                          Text(
                            " (" + productList[index].noOfRating + ")",
                            style: Theme.of(context).textTheme.overline,
                          )
                        ],
                      ),
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
                                if (CUR_USERID != null) {
                                  if (int.parse(productList[index]
                                      .prVarientList[0]
                                      .cartCount) >
                                      0) removeFromCart(index);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login()),
                                  );
                                }
                              },
                            ),
                            Text(
                              productList[index]

                                  .prVarientList[0]
                                  .cartCount,
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
                                if (CUR_USERID == null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login()),
                                  );
                                } else
                                  addToCart(index);
                              },
                            ),
                          ],
                        ),
                        Spacer(),
                        Row(
                          children: <Widget>[
                            Text(
                              int.parse(productList[index]
                                  .prVarientList[0]
                                  .disPrice) !=
                                  0
                                  ? CUR_CURRENCY +
                                  "" +
                                  productList[index]
                                      .prVarientList[0]
                                      .price
                                  : "",
                              style: Theme.of(context)
                                  .textTheme
                                  .overline
                                  .copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  letterSpacing: 0.7),
                            ),
                            Text(" " + CUR_CURRENCY + " " + price.toString(),
                                style: Theme.of(context).textTheme.headline6),
                          ],
                        )
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
          FocusScope.of(context).requestFocus(new FocusNode());
          Product model = productList[index];

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Product_Detail(
                  model: model,
                  updateParent: updateSearch,
                  updateHome: widget.updateHome,
                )),
          );
        },
      ),
    );
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          print("load more****limit *****$offsetSending****$total");
          if (offsetSending < total) getProduct(_controller.text, false);
        });
      }
    }
  }

  updateSearch() {
    setState(() {});
  }

  Future<void> addToCart(int index) async {
    try {
      setState(() {
        _isProgress = true;
      });
      var parameter = {
        USER_ID: CUR_USERID,
        PRODUCT_VARIENT_ID: productList[index].prVarientList[0].id,
        QTY: (int.parse(productList[index].prVarientList[0].cartCount) + 1)
            .toString(),
      };
      Response response =
      await post(manageCartApi, body: parameter, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print('response***${parameter.toString()}');
      print('response***slider**${response.body.toString()}***$headers');

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        String qty = data['total_quantity'];
        CUR_CART_COUNT = data['cart_count'];

        productList[index].prVarientList[0].cartCount = qty.toString();
      } else {
        setSnackbar(msg);
      }
      setState(() {
        _isProgress = false;
      });
     // widget.updateHome();

    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isProgress = false;
      });
    }
  }

  Future<void> removeFromCart(int index) async {
    try {
      setState(() {
        _isProgress = true;
      });
      var parameter = {
        PRODUCT_VARIENT_ID: productList[index].prVarientList[0].id,
        USER_ID: CUR_USERID,
        QTY: (int.parse(productList[index].prVarientList[0].cartCount) - 1)
            .toString()
      };

      Response response =
      await post(manageCartApi, body: parameter, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      print('response***slider**${response.body.toString()}***$headers');

      bool error = getdata["error"];
      String msg = getdata["message"];

      if (!error) {
        var data = getdata["data"];
        String qty = data["total_quantity"];
        CUR_CART_COUNT = getdata['cart_count'];


        productList[index].prVarientList[0].cartCount = qty.toString();
      } else {
        setSnackbar(msg);
      }
      setState(() {
        _isProgress = false;
      });


     // widget.updateHome();

    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isProgress = false;
      });
    }
  }

/*
  Future<void> searchOperation(String searchText) async {
    searchresult.clear();

    for (var i = 0; i < productList.length; i++) {
      Product data = productList[i];

      if (data.name.toLowerCase().contains(searchText.toLowerCase()) ||
          data.desc.toLowerCase().contains(searchText.toLowerCase())) {
        searchresult.add(data);

        print("search result***${data.name}");
      }
    }
    if (!mounted) return;
    setState(() {});
  }*/

  Future<void> getProduct(String searchText, bool clear) async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      try {
        if (clear) {
          offset = 0;
          total = 0;
          offsetSending = 0;
        }
        offsetSending=offset;
        var parameter = {
          SEARCH: searchText,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
        };

        if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        Response response =
        await post(getProductApi, headers: headers, body: parameter)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          total = int.parse(getdata["total"]);
          print(
              'response***product**$parameter**$total**$offset***${productList.length}***$offsetSending');
          if ((offsetSending) < total) {
            var data = getdata["data"];
            tempList.clear();
            print("list added********************${tempList.length}");
            tempList = (data as List)
                .map((data) => new Product.fromJson(data))
                .toList();
            print("list added*******${productList.length}");
            if (clear) productList.clear();
            productList.addAll(tempList);

            offset = offset + perPage;
          }
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg);
          isLoadingmore = false;
        }
        setState(() {
          _isProgress = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          isLoadingmore = false;
        });
      }
    } else
      setSnackbar(internetMsg);
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
    return (productList.isNotEmpty || _controller.text.isNotEmpty)
        ? ListView.builder(
        shrinkWrap: true,
        controller: controller,
        physics: BouncingScrollPhysics(),
        itemCount:
        (offset < total) ? productList.length + 1 : productList.length,
        itemBuilder: (context, i) {
            return (i == productList.length && isLoadingmore)
              ? Center(child: CircularProgressIndicator())
              : listItem(i);
        })
        : Container();
  }
}

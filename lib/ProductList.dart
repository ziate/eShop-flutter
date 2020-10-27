import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:http/http.dart';

import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Login.dart';
import 'Model/Section_Model.dart';
import 'Product_Detail.dart';
import 'Search.dart';

class ProductList extends StatefulWidget {
  final String name, id;
  final Function updateHome;

  const ProductList({Key key, this.id, this.name, this.updateHome})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StateProduct();
}

class StateProduct extends State<ProductList> {
  bool _isLoading = true, _isProgress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Product> productList = [];
  List<Product> tempList = [];
  String sortBy = 'p.id', orderBy = "DESC";
  int offset = 0;
  int total = 0;
  bool isLoadingmore = true;
  ScrollController controller = new ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
    getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppbar(),
        key: _scaffoldKey,
        body: _isLoading
            ? getProgress()
            : productList.length == 0
                ? getNoItem()
                : Stack(
                    children: <Widget>[
                      _showForm(),
                      showCircularProgress(_isProgress, primary),
                    ],
                  ));
  }

  @override
  void dispose() {
    controller.removeListener(() {});
    super.dispose();
  }

  Widget listItem(int index) {
    print("desc*****${productList[index].desc}");

    double price = double.parse(productList[index].prVarientList[0].disPrice);
    if (price == 0)
      price = double.parse(productList[index].prVarientList[0].price);

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      productList[index].name,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Colors.black),
                      maxLines: 2,
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
                    /*   Html(
                      data: '${productList[index].desc}',

                      */ /*style: {
                        "p": Style(
                            margin: EdgeInsets.all(0),
                            color: Colors.grey,
                            fontSize: FontSize.small),
                      },*/ /*
                      //maxLines: 2,
                      //  overflow: TextOverflow.ellipsis,
                    ),*/
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
                              productList[index].prVarientList[0].cartCount,
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
                                }),
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
                                      productList[index].prVarientList[0].price
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
          Product model = productList[index];
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Product_Detail(
                      model: model,
                      updateParent: updateProductList,
                      updateHome: widget.updateHome,
                      //  title: productList[index].name,
                    )),
          );
        },
      ),
    );
  }

  updateProductList() {
    setState(() {});
  }

  Future<void> getProduct() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      try {
        print("product****${widget.id}");

        var parameter = {
          CATID: widget.id,
          SORT: sortBy,
          ORDER: orderBy,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
        };

        if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        Response response =
            await post(getProductApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));

        print('response***product*$parameter');
        print('response***product*${response.body.toString()}');

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];

        if (!error) {
          total = int.parse(getdata["total"]);
          print('limit *****$offset****$total');
          if ((offset) < total) {
            tempList.clear();

            var data = getdata["data"];
            tempList = (data as List)
                .map((data) => new Product.fromJson(data))
                .toList();

            productList.addAll(tempList);

            offset = offset + perPage;
          }
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg);
          isLoadingmore = false;
        }
        setState(() {
          _isLoading = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          _isLoading = false;
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

  getAppbar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: primary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        widget.name,
        style: TextStyle(
          color: primary,
        ),
      ),
      backgroundColor: Colors.white,
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.search,
              color: primary,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Search(widget
                    .updateHome),
                  ));
            }),
        IconButton(
            icon: Icon(
              Icons.tune,
              color: primary,
            ),
            onPressed: () {
              filterDialog();
            }),
        IconButton(
            icon: Icon(
              Icons.filter_list,
              color: primary,
            ),
            onPressed: () {
              sortDialog();
            })
      ],
    );
  }

  void sortDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new CupertinoAlertDialog(
            title: new Text(
              SORT_BY,
              style: Theme.of(context).textTheme.headline6,
            ),
            actions: [
              CupertinoActionSheetAction(
                  child: new Text(
                    F_NEWEST,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  onPressed: () {
                    sortBy = 'p.date_added';
                    orderBy = 'DESC';
                    setState(() {
                      _isLoading = true;
                      total = 0;
                      offset = 0;
                      productList.clear();
                    });
                    getProduct();
                    Navigator.pop(context, 'option 1');
                  }),
              CupertinoActionSheetAction(
                  child: new Text(
                    F_OLDEST,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  onPressed: () {
                    sortBy = 'p.date_added';
                    orderBy = 'ASC';
                    setState(() {
                      _isLoading = true;
                      total = 0;
                      offset = 0;
                      productList.clear();
                    });
                    getProduct();
                    Navigator.pop(context, 'option 2');
                  }),
              CupertinoActionSheetAction(
                  child: new Text(
                    F_LOW,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  onPressed: () {
                    sortBy = 'pv.price';
                    orderBy = 'ASC';
                    setState(() {
                      _isLoading = true;
                      total = 0;
                      offset = 0;
                      productList.clear();
                    });
                    getProduct();
                    Navigator.pop(context, 'option 3');
                  }),
              CupertinoActionSheetAction(
                  child: new Text(
                    F_HIGH,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  onPressed: () {
                    sortBy = 'pv.price';
                    orderBy = 'DESC';
                    setState(() {
                      _isLoading = true;
                      total = 0;
                      offset = 0;
                      productList.clear();
                    });
                    getProduct();
                    Navigator.pop(context, 'option 4');
                  }),
            ],
          );
        });
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          print("limit *****$offset****$total");
          if (offset < total) getProduct();
        });
      }
    }
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
      widget.updateHome();

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
        CUR_CART_COUNT = data['cart_count'];
        productList[index].prVarientList[0].cartCount = qty.toString();
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

  _showForm() {
    return ListView.builder(
      controller: controller,
      itemCount: (offset < total) ? productList.length + 1 : productList.length,
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        print(
            "loading***$isLoadingmore**$_isLoading***${productList.length}***$offset***$total");

        return (index == productList.length && isLoadingmore)
            ? Center(child: CircularProgressIndicator())
            : listItem(index);
      },
    );
  }

  void filterDialog() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Filter By'),
                Row(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: 2,
                            itemBuilder: (context, index) {
                              return Text('title');
                            })),
                  ],
                ),
              ],
            );
          });
        });
  }
}

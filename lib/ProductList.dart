import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eshop/Helper/AppBtn.dart';
import 'package:eshop/Helper/SimBtn.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:http/http.dart';
import 'package:shimmer/shimmer.dart';

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

class StateProduct extends State<ProductList> with TickerProviderStateMixin {
  bool _isLoading = true, _isProgress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Product> productList = [];
  List<Product> tempList = [];
  String sortBy = 'p.id', orderBy = "DESC";
  int offset = 0;
  int total = 0;
  String totalProduct;
  bool isLoadingmore = true;
  ScrollController controller = new ScrollController();
  var filterList;
  List<String> attnameList;
  List<String> attsubList;
  List<String> attListId;
  bool _isNetworkAvail = true;
  List<String> selectedId = [];
  bool _isFirstLoad = true;
  String filter = "";
  String selId = "";
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  Animation buttonSqueezeanimation;
  AnimationController buttonController;

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
    getProduct("0");

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
    controller.removeListener(() {});
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppbar(),
        backgroundColor: lightWhite,
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? _isLoading
                ? shimmer()
                : productList.length == 0
                    ? getNoItem()
                    : Stack(
                        children: <Widget>[
                          _showForm(),
                          showCircularProgress(_isProgress, primary),
                        ],
                      )
            : noInternet(context));
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
                  offset = 0;
                  total = 0;
                  getProduct("0");
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

  noIntBtn(BuildContext context) {
    double width = deviceWidth;

    return Container(
        padding: EdgeInsets.only(bottom: 10.0, top: 50.0),
        child: Center(
            child: RaisedButton(
          color: primary,
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => super.widget));
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
          child: Ink(
            child: Container(
              constraints: BoxConstraints(maxWidth: width / 1.2, minHeight: 45),
              alignment: Alignment.center,
              child: Text(TRY_AGAIN_INT_LBL,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: white, fontWeight: FontWeight.normal)),
            ),
          ),
        )));
  }

  Widget listItem(int index) {
    totalProduct = productList[index].total;

    double price = double.parse(productList[index].prVarientList[0].disPrice);
    if (price == 0)
      price = double.parse(productList[index].prVarientList[0].price);

    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius:  BorderRadius.circular(4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          productList[index].availability == "0"
              ? Text(OUT_OF_STOCK_LBL,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.red))
              : Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.start,

              children: <Widget>[
                Hero(
                  tag: "$index${productList[index].id}",
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0),
                      child: FadeInImage(
                        image: NetworkImage(productList[index].image),
                        height: 80.0,
                        width: 80.0,
                        //errorWidget:(context, url,e) => placeHolder(80) ,
                        placeholder: placeHolder(80),
                      )),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          productList[index].name,
                          style: TextStyle(
                              color: lightBlack, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
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
                                      letterSpacing: 0),
                            ),
                            Text(" " + CUR_CURRENCY + " " + price.toString(),
                                style: Theme.of(context).textTheme.subtitle1),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ]),
        onTap: () {
          Product model = productList[index];
          Navigator.push(
            context,
            PageRouteBuilder(
               // transitionDuration: Duration(seconds: 1),
                pageBuilder: (_, __, ___) => ProductDetail(
                      model: model,
                      updateParent: updateProductList,
                      index: index,
                      secPos: 0,
                      updateHome: widget.updateHome,
                      list: true,
                    )),
          );
        },
      ),
    );
  }

  updateProductList() {
    setState(() {});
  }

  Future<Null> getProduct(String top) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          CATID: widget.id,
          SORT: sortBy,
          ORDER: orderBy,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          TOP_RETAED:top
        };
        if (selId != null && selId != "") {
          parameter[ATTRIBUTE_VALUE_ID] = selId;
        }
        if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;



        Response response =
            await post(getProductApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          total = int.parse(getdata["total"]);

          if (_isFirstLoad) {
            filterList = getdata["filters"];
            _isFirstLoad = false;
          }

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
        if (mounted)
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
    } else {
      {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }

    return null;
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

  getAppbar() {
    return AppBar(
      title: Text(
        widget.name,
        style: TextStyle(
          color: fontColor,
        ),
      ),
      backgroundColor: white,
      elevation: 5,
      leading: Builder(builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.all(10),
          decoration: shadow(),
          child: Card(
            elevation: 0,
            child: InkWell(
              borderRadius:  BorderRadius.circular(4),
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Icon(Icons.keyboard_arrow_left, color: primary),
              ),
            ),
          ),
        );
      }),
      actions: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: shadow(),
          child: Card(
            elevation: 0,
            child: InkWell(
              borderRadius:  BorderRadius.circular(4),
              onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Search(
                            updateHome: widget.updateHome, menuopen: false),
                      ));
                },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                    Icons.search,
                    color: primary,
                    size: 22,
                  ),
              ),
            ),
          ),
        ),
        filterList != null && filterList.length > 0
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: shadow(),
                child: Card(
                    elevation: 0,
                    child: InkWell(
                      borderRadius:  BorderRadius.circular(4),
                      onTap: () {
                            if (filterList.length != 0) return filterDialog();
                          },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                              Icons.tune,
                              color: primary,
                              size: 22,
                            ),
                      ),
                    )))
            : Container(),
        Container(
            margin: EdgeInsets.only(top: 10, bottom: 10, right: 10),
            decoration: shadow(),
            child: Card(
                elevation: 0,
                child: InkWell(
                  borderRadius:  BorderRadius.circular(4),
                  onTap: () {
                        if (productList.length != 0) return sortDialog();
                      },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                          Icons.filter_list,
                          color: primary,
                          size: 22,
                        ),
                  ),
                )))
      ],
    );
  }

  /* void sortDialog() {
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
  }*/
  void sortDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ButtonBarTheme(
            data: ButtonBarThemeData(
              alignment: MainAxisAlignment.center,
            ),
            child: new AlertDialog(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                contentPadding: const EdgeInsets.all(0.0),
                content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                        padding: EdgeInsets.only(top: 19.0, bottom: 16.0),
                        child: Text(
                          SORT_BY,
                          style: Theme.of(context).textTheme.headline6,
                        )),
                    Divider(color: lightBlack),
                    TextButton(
                        child: Text(TOP_RATED,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: lightBlack)),
                        onPressed: () {
                          sortBy = '';
                          orderBy = 'DESC';
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                          getProduct("1");
                          Navigator.pop(context, 'option 1');
                        }),
                    Divider(color: lightBlack),
                    TextButton(
                        child: Text(F_NEWEST,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: lightBlack)),
                        onPressed: () {
                          sortBy = 'p.date_added';
                          orderBy = 'DESC';
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                          getProduct("0");
                          Navigator.pop(context, 'option 1');
                        }),
                    Divider(color: lightBlack),
                    TextButton(
                        child: Text(
                          F_OLDEST,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: lightBlack),
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
                          getProduct("0");
                          Navigator.pop(context, 'option 2');
                        }),
                    Divider(color: lightBlack),
                    TextButton(
                        child: new Text(
                          F_LOW,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: lightBlack),
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
                          getProduct("0");
                          Navigator.pop(context, 'option 3');
                        }),
                    Divider(color: lightBlack),
                    Padding(
                        padding: EdgeInsets.only(bottom: 5.0),
                        child: TextButton(
                            child: new Text(
                              F_HIGH,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(color: lightBlack),
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
                              getProduct("0");
                              Navigator.pop(context, 'option 4');
                            })),
                  ]),
                )),
          );
        });
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          if (offset < total) getProduct("0");
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

  Future<Null> _refresh() {
    setState(() {
      _isLoading = true;
      isLoadingmore = true;
      offset=0;
      total=0;
      productList.clear();
    });
    return getProduct("0");
  }

  _showForm() {
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: ListView.builder(
          controller: controller,
          itemCount:
              (offset < total) ? productList.length + 1 : productList.length,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return (index == productList.length && isLoadingmore)
                ? Center(child: CircularProgressIndicator())
                : listItem(index);
          },
        ));
  }

  void filterDialog() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: AppBar(
                  title: Text(
                    FILTER,
                    style: TextStyle(
                      color: fontColor,
                    ),
                  ),
                  backgroundColor: white,
                  elevation: 5,
                  leading: Builder(builder: (BuildContext context) {
                    return Container(
                      margin: EdgeInsets.all(10),
                      decoration: shadow(),
                      child: Card(
                        elevation: 0,
                        child: InkWell(
                          borderRadius:  BorderRadius.circular(4),
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child:
                                Icon(Icons.keyboard_arrow_left, color: primary),
                          ),
                        ),
                      ),
                    );
                  }),
                  actions: [
                    Container(
                      margin: EdgeInsets.only(right: 10.0),
                      alignment: Alignment.center,
                      child: InkWell(
                          child: Text(FILTER_CLEAR_LBL,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                      fontWeight: FontWeight.normal,
                                      color: fontColor)),
                          onTap: () {
                            setState(() {
                              selectedId.clear();
                            });
                          }),
                    ),
                  ],
                )),
            Expanded(
                child: Container(
                    color: lightWhite,
                    padding: EdgeInsets.only(left: 7.0, right: 7.0, top: 7.0),
                    child: Card(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          Expanded(
                              flex: 2,
                              child: Container(
                                  color: lightWhite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    padding: EdgeInsets.only(top: 10.0),
                                    itemCount: filterList.length,
                                    itemBuilder: (context, index) {
                                      attsubList = filterList[index]
                                              ['attribute_values']
                                          .split(',');

                                      attListId = filterList[index]
                                              ['attribute_values_id']
                                          .split(',');

                                      if (filter == "") {
                                        filter = filterList[0]["name"];
                                      }

                                      return InkWell(
                                          onTap: () {
                                            setState(() {
                                              filter =
                                                  filterList[index]['name'];
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                left: 20,
                                                top: 10.0,
                                                bottom: 10.0),
                                            decoration: BoxDecoration(
                                                color: filter ==
                                                        filterList[index]
                                                            ['name']
                                                    ? white
                                                    : lightWhite,
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(7),
                                                    bottomLeft:
                                                        Radius.circular(7))),
                                            alignment: Alignment.centerLeft,
                                            child: new Text(
                                              filterList[index]['name'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                      color: filter ==
                                                              filterList[index]
                                                                  ['name']
                                                          ? fontColor
                                                          : lightBlack,
                                                      fontWeight:
                                                          FontWeight.normal),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ));
                                    },
                                  ))),
                          Expanded(
                              flex: 3,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.only(top: 10.0),
                                  scrollDirection: Axis.vertical,
                                  itemCount: filterList.length,
                                  itemBuilder: (context, index) {
                                    if (filter == filterList[index]["name"]) {
                                      attsubList = filterList[index]
                                              ['attribute_values']
                                          .split(',');

                                      attListId = filterList[index]
                                              ['attribute_values_id']
                                          .split(',');
                                      return Container(
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: attListId.length,
                                              itemBuilder: (context, i) {
                                                return CheckboxListTile(
                                                  dense: true,
                                                  title: Text(attsubList[i],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle1
                                                          .copyWith(
                                                              color: lightBlack,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                  value: selectedId
                                                      .contains(attListId[i]),
                                                  activeColor: primary,
                                                  controlAffinity:
                                                      ListTileControlAffinity
                                                          .leading,
                                                  onChanged: (bool val) {
                                                    setState(() {
                                                      if (val == true) {
                                                        selectedId
                                                            .add(attListId[i]);
                                                      } else {
                                                        selectedId.remove(
                                                            attListId[i]);
                                                      }
                                                    });
                                                  },
                                                );
                                              }));
                                    } else {
                                      return Container();
                                    }
                                  })),
                        ])))),
            Container(
              color: white,
              child: Row(children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(total.toString()),
                        Text(PRODUCTS_FOUND_LBL),
                      ],
                    )),
                Spacer(),
                SimBtn(
                    size:  0.4,
                    title: APPLY,
                    onBtnSelected: () {
                      if (selectedId != null) {
                        selId = selectedId.join(',');
                      }

                      setState(() {
                        _isLoading = true;
                        total = 0;
                        offset = 0;
                        productList.clear();
                      });
                      getProduct("0");
                      Navigator.pop(context, 'Product Filter');
                    }),
              ]),
            )
          ]);
        });
      },
    );
  }
}

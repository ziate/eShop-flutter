import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Helper/AppBtn.dart';

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

  Animation buttonSqueezeanimation;
  AnimationController buttonController;

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
    getProduct();

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
          noIntImage(context),
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
                  getProduct();
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
    double width = MediaQuery.of(context).size.width;

    return Container(
        padding: EdgeInsets.only(bottom: 10.0, top: 50.0),
        child: Center(
            child: RaisedButton(
          color: primaryLight2,
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
    print("desc*****${productList[index].desc}");

    double price = double.parse(productList[index].prVarientList[0].disPrice);
    if (price == 0)
      price = double.parse(productList[index].prVarientList[0].price);

    return Card(
      child: InkWell(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          productList[index].availability == "0"
              ? Text(OUT_OF_STOCK_LBL,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.red))
              : Container(),
          Row(
            children: <Widget>[
              Hero(
                tag: "$index${productList[index].id}",
                child: CachedNetworkImage(
                  imageUrl: productList[index].image,
                  height: 90.0,
                  width: 90.0,
                  placeholder: (context, url) => placeHolder(90),
                ),
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
                   Row(
                        children: <Widget>[
                          productList[index].availability == "1"?   Row(
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
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
                          ):Container(),
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
          )
        ]),
        splashColor: primary.withOpacity(0.2),
        onTap: () {
          Product model = productList[index];
          Navigator.push(
            context,
            PageRouteBuilder(
                transitionDuration: Duration(seconds: 1),
                pageBuilder: (_, __, ___) => ProductDetail(
                      model: model,
                      updateParent: updateProductList,
                      index: index,
                      secPos: 0,
                      updateHome: widget.updateHome,
                      list: true,
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
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        print("product****${widget.id}");

        var parameter = {
          CATID: widget.id,
          SORT: sortBy,
          ORDER: orderBy,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
        };
        if (selId != null && selId != "") {
          parameter[ATTRIBUTE_VALUE_ID] = selId;
        }
        if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        Response response =
            await post(getProductApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));

        print('response***product*$parameter');
        print('response***product*${response.body.toString()}');

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        //  filterList = getdata["filters"];
        // print("filterlist*****${filterList.toString()}");
        if (!error) {
          total = int.parse(getdata["total"]);

          if (_isFirstLoad) {
            filterList = getdata["filters"];
            _isFirstLoad = false;
          }

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
    } else {
      {
        setState(() {
          _isNetworkAvail = false;
        });
      }
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
                    builder: (context) => Search(widget.updateHome),
                  ));
            }),
        IconButton(
            icon: Icon(
              Icons.tune,
              color: primary,
            ),
            onPressed: () {
              if (filterList.length != 0) return filterDialog();
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
                padding: const EdgeInsets.only(top: 40.0, bottom: 10.0),
                child: Text(
                  FILTER,
                  style: Theme.of(context).textTheme.headline6,
                )),
            Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                          color: lightgrey,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            padding: EdgeInsets.only(top: 15.0),
                            itemCount: filterList.length,
                            itemBuilder: (context, index) {
                              print(
                                  "Attttt_name::::${filterList[index]['name']}");
                              attsubList = filterList[index]['attribute_values']
                                  .split(',');

                              attListId = filterList[index]
                                      ['attribute_values_id']
                                  .split(',');
                              print("Attsublist ****** $attsubList");
                              print("AttsublistId ****** $attListId");

                              if (filter == "") {
                                filter = filterList[0]["name"];
                              }

                              return Padding(
                                  padding: EdgeInsets.all(
                                    8.0,
                                  ),
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          filter = filterList[index]['name'];
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 20.0, right: 20.0),
                                        alignment: Alignment.centerLeft,
                                        height: 30.0,
                                        color:
                                            filter == filterList[index]['name']
                                                ? white
                                                : lightgrey,
                                        child: Text(
                                          filterList[index]['name'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                      )));
                            },
                          ))),
                  Expanded(
                      flex: 2,
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: filterList.length,
                          itemBuilder: (context, index) {
                            print(
                                "filter******$filter******${filterList[index]["name"]}");

                            if (filter == filterList[index]["name"]) {
                              attsubList = filterList[index]['attribute_values']
                                  .split(',');

                              attListId = filterList[index]
                                      ['attribute_values_id']
                                  .split(',');
                              print("Attsublist ****** $attsubList");
                              print("AttsublistId ****** $attListId");
                              return Container(
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: attListId.length,
                                      itemBuilder: (context, i) {
                                        print(
                                            "selold111111*******************${selectedId.contains(attListId[i])}");
                                        return CheckboxListTile(
                                          title: Text(attsubList[i]),
                                          value:
                                              selectedId.contains(attListId[i]),
                                          activeColor: primary,
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          onChanged: (bool val) {
                                            setState(() {
                                              if (val == true) {
                                                selectedId.add(attListId[i]);
                                                print(
                                                    "addListIDadd******${attListId[i]}");
                                                print(
                                                    "selectId******$selectedId");
                                              } else {
                                                selectedId.remove(attListId[i]);
                                                print(
                                                    "addListIDremove******${attListId[i]}");
                                              }
                                            });
                                          },
                                        );
                                      }));
                            } else {
                              return Container();
                            }
                          })),
                ])),
            Padding(
              padding: const EdgeInsets.only(right: 18.0, bottom: 8),
              child: Align(
                alignment: Alignment.bottomRight,
                child: RaisedButton(
                  color: primary,
                  onPressed: () {
                    if (selectedId != null) {
                      print("seletIDDDDD****${selectedId.toString()}");
                      String sId = selectedId.toString();
                      selId = sId.substring(1, sId.length - 1);
                      print("selIdnew****$selId");
                      setState(() {
                        _isLoading = true;
                        total = 0;
                        offset = 0;
                        productList.clear();
                      });
                      getProduct();
                      Navigator.pop(context, 'Product Filter');
                    }
                  },
                  child: Text(
                    'Apply',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ]);
        });
      },
    );
  }
}

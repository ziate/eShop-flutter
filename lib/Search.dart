import 'dart:async';
import 'dart:convert';



import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

import 'package:http/http.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/String.dart';
import 'Helper/arrow_clipper.dart';
import 'Login.dart';
import 'Model/Model.dart';
import 'Model/Section_Model.dart';
import 'Product_Detail.dart';

class Search extends StatefulWidget {
  final Function updateHome;
  final bool menuopen;

  Search({this.updateHome, this.menuopen});

  @override
  _StateSearch createState() => _StateSearch();
}

class _StateSearch extends State<Search> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int pos = 0;
  bool _isProgress = false;
  List<Product> productList = [];

  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;

  bool _isSearching;
  String _searchText = "", _lastsearch = "";
  int notificationoffset = 0;
  ScrollController notificationcontroller;
  bool notificationisloadmore = true,
      notificationisgettingdata = false,
      notificationisnodata = false;
  // List<Model> categList = [];

  //GlobalKey _key;
  //bool isMenuOpen=false;

  //Offset buttonPosition;
  //Size buttonSize;
  //OverlayEntry _overlayEntry;

  // BorderRadius _borderRadius;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    productList.clear();
    //  categList.clear();

    //  this.categList = List.from(catList);

    // Model m = Model.setAllCat("0", "All Category");
    // categList.insert(0, m);
    notificationoffset = 0;
    _isSearching = false;
    notificationcontroller = ScrollController(keepScrollOffset: true);
    notificationcontroller.addListener(_transactionscrollListener);

    _controller.addListener(() {
      //closeMenu();
      if (_controller.text.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchText = "";
        });
      } else {
        setState(() {
          _isSearching = true;
          _searchText = _controller.text;
        });
      }

      if (_lastsearch != _searchText) {
        _lastsearch = _searchText;
        notificationisloadmore = true;
        notificationoffset = 0;
        getProduct();
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    //_borderRadius = widget.borderRadius ?? BorderRadius.circular(4);
    //_key = LabeledGlobalKey("button_icon");

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

  _transactionscrollListener() {
    if (notificationcontroller.offset >=
        notificationcontroller.position.maxScrollExtent &&
        !notificationcontroller.position.outOfRange) {
      setState(() {
        print("load4");
        getProduct();
      });
    }
  }

  @override
  void dispose() {
    buttonController.dispose();
    notificationcontroller.dispose();
    _animationController.dispose();
    //closeMenu();
    super.dispose();
  }

/*  findButton() {
    RenderBox renderBox = _key.currentContext.findRenderObject();
    buttonSize = renderBox.size;
    buttonPosition = renderBox.localToGlobal(Offset.zero);
  }

  void closeMenu() {
    _overlayEntry.remove();
    _animationController.reverse();
    isMenuOpen = !isMenuOpen;
  }

  void openMenu() {
    findButton();
    _animationController.forward();
    _overlayEntry = _overlayEntryBuilder();
    Overlay.of(context).insert(_overlayEntry);
    isMenuOpen = !isMenuOpen;
  }*/

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

/*  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          top: buttonPosition.dy + buttonSize.height,
          left: buttonPosition.dx,
          width: buttonSize.width,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: ClipPath(
                    clipper: ArrowClipper(),
                    child: Container(
                      width: 17,
                      height: 17,
                      color: primary ?? Color(0xFFF),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Container(
                    // height: widget.icons.length * buttonSize.height,
                    decoration: BoxDecoration(
                      color: primary,
                      //borderRadius: _borderRadius,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(categList.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            //widget.onChange(index);
                            setState(() {
                              print("pos=======$index");
                              pos = index;
                            });
                            closeMenu();
                          },
                          child: Container(
                              width: double.maxFinite,
                              color: pos == index ? white : primary,
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              child: Text(categList[index].name)),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }*/

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
        appBar: AppBar(
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
          backgroundColor: white,
          title: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
              prefixIcon: Icon(Icons.search, color: primary, size: 17),
              hintText: 'Search',
              hintStyle: TextStyle(color: primary.withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: white),
              ),
            ),
          ),
          titleSpacing: 0,
          /*  actions: [
            Stack(
              alignment: Alignment.centerRight,
              children: [
                Container(
                  key: _key,
                  width: deviceWidth * 0.3,
                ),
                Container(
                    width: 40,
                    margin: EdgeInsets.all(
                      7,
                    ),
                    decoration: shadow(),
                    child: Card(
                        elevation: 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.tune,
                            color: primary,
                            size: 17,
                          ),
                          color: primary,
                          onPressed: () {
                            if (isMenuOpen) {
                              closeMenu();
                            } else {
                              openMenu();
                            }
                          },
                        ))),
              ],
            ),
          ],*/
        ),
        body: _isNetworkAvail
            ? Stack(
          children: <Widget>[
            _showContent(),
            showCircularProgress(_isProgress, primary),
          ],
        )
            : noInternet(context));
  }

  Widget listItem(int index) {
    double price = double.parse(productList[index].prVarientList[0].disPrice);
    if (price == 0)
      price = double.parse(productList[index].prVarientList[0].price);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              productList[index].availability == "0"
                  ? Text(OUT_OF_STOCK_LBL,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.red))
                  : Container(),
              Row( mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Hero(
                      tag: "$index${productList[index].id}",
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(7.0),
                          child: FadeInImage(
                            image: NetworkImage(productList[index].image),
                            height: 80.0,
                            width:80.0,
                            //errorWidget:(context, url,e) => placeHolder(80) ,
                            placeholder:  placeHolder(80),
                          ))),
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
                                  .subtitle2
                                  .copyWith(
                                  color: lightBlack,
                                  fontWeight: FontWeight.bold),
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
                                      productList[index]
                                          .prVarientList[0]
                                          .price
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
                        )),
                  )
                ],
              ),
            ],
          ),
          splashColor: primary.withOpacity(0.2),
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            Product model = productList[index];
            Navigator.push(
              context,
              PageRouteBuilder(
                 // transitionDuration: Duration(seconds: 1),
                  pageBuilder: (_, __, ___) => ProductDetail(
                    model: model,
                    updateParent: updateSearch,
                    updateHome: widget.updateHome,
                    secPos: 0,
                    index: index,
                    list: true,
                  )),
            );
          },
        ),
      ),
    );
  }

/*  Widget listItem(int index) {
    double price = double.parse(productList[index].prVarientList[0].disPrice);
    if (price == 0)
      price = double.parse(productList[index].prVarientList[0].price);

    return Card(
      child: InkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    )),
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
                              .copyWith(color: black),
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
                            productList[index].availability == "1" ||
                                    productList[index].stockType == "null"
                                ? Row(
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
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5))),
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
                                                  builder: (context) =>
                                                      Login()),
                                            );
                                          }
                                        },
                                      ),
                                      Text(
                                        productList[index]
                                            .prVarientList[0]
                                            .cartCount,
                                        style:
                                            Theme.of(context).textTheme.caption,
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
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5))),
                                        ),
                                        onTap: () {
                                          if (CUR_USERID == null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Login()),
                                            );
                                          } else
                                            addToCart(index);
                                        },
                                      ),
                                    ],
                                  )
                                : Container(),
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
                                          decoration:
                                              TextDecoration.lineThrough,
                                          letterSpacing: 0.7),
                                ),
                                Text(
                                    " " + CUR_CURRENCY + " " + price.toString(),
                                    style:
                                        Theme.of(context).textTheme.headline6),
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
          ],
        ),
        splashColor: primary.withOpacity(0.2),
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          Product model = productList[index];

          Navigator.push(
            context,
            PageRouteBuilder(
                transitionDuration: Duration(seconds: 1),
                pageBuilder: (_, __, ___) => ProductDetail(
                      model: model,
                      updateParent: updateSearch,
                      updateHome: widget.updateHome,
                      secPos: 0,
                      index: index,
                      list: true,
                    )),
          );
        },
      ),
    );
  }*/

/*  _scrollListener() {
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
  }*/

  updateSearch() {
    setState(() {});
  }

  Future<void> addToCart(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
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
          widget.updateHome();
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
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Future<void> removeFromCart(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
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
    } else {
      setState(() {
        _isNetworkAvail = false;
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

  Future getProduct() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (notificationisloadmore) {
          setState(() {
            notificationisloadmore = false;
            notificationisgettingdata = true;
            if (notificationoffset == 0) {
              productList = new List<Product>();
            }
          });

          var parameter = {
            SEARCH: _searchText.trim(),
            LIMIT: perPage.toString(),
            OFFSET: notificationoffset.toString(),
          };
          /*  if (pos != null && pos != 0) {
            parameter[CATID] = categList[pos].id;
          }*/

          print("title=======$parameter");
          if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;

          Response response =
          await post(getProductApi, headers: headers, body: parameter)
              .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String msg = getdata["message"];

          notificationisgettingdata = false;
          if (notificationoffset == 0) notificationisnodata = error;

          if (!error) {
            if (mounted) {
              new Future.delayed(
                  Duration.zero,
                      () => setState(() {
                    List mainlist = getdata['data'];

                    if (mainlist.length != 0) {
                      List<Product> items = new List<Product>();
                      List<Product> allitems = new List<Product>();

                      items.addAll(mainlist
                          .map((data) => new Product.fromJson(data))
                          .toList());

                      allitems.addAll(items);

                      for (Product item in items) {
                        productList
                            .where((i) => i.id == item.id)
                            .map((obj) {
                          //print("==item--${item.id}==${obj.id}");
                          allitems.remove(item);
                          return obj;
                        }).toList();
                      }
                      productList.addAll(allitems);
                      notificationisloadmore = true;
                      notificationoffset = notificationoffset + perPage;
                    } else {
                      notificationisloadmore = false;
                    }
                  }));
            }
          } else {
            notificationisloadmore = false;
            setState(() {});
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          notificationisloadmore = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

/*  Future<void> getProduct(String searchText, bool clear) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (clear) {
          offset = 0;
          total = 0;
          offsetSending = 0;
        }
        offsetSending = offset;
        var parameter = {
        SEARCH: _searchText.trim();,
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
    } else {
    setState(() {
    _isNetworkAvail = false;
    });
    }
  }*/

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
    return notificationisnodata
        ? getNoItem()
        : NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {},
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                padding: EdgeInsetsDirectional.only(
                    bottom: 5, start: 10, end: 10, top: 12),
                controller: notificationcontroller,
                physics: BouncingScrollPhysics(),
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  Product item;
                  try {
                    item =
                    productList.isEmpty ? null : productList[index];
                    if (notificationisloadmore &&
                        index == (productList.length - 1) &&
                        notificationcontroller.position.pixels <= 0) {
                      print("load5");
                      getProduct();
                    }
                  } on Exception catch (_) {}

                  return item == null ? Container() : listItem(index);
                }),
          ),
          notificationisgettingdata
              ? Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: CircularProgressIndicator(),
          )
              : Container(),
        ],
      ),
    );
  }
}

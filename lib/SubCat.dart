import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Model/Section_Model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/SimBtn.dart';
import 'Helper/String.dart';
import 'Login.dart';
import 'Model/Model.dart';
import 'Helper/Session.dart';
import 'ProductList.dart';
import 'Product_Detail.dart';
import 'Search.dart';

class SubCat extends StatefulWidget {
  String title;
  List<Model> subList = [];
  final Function updateHome;

  SubCat({this.subList, this.title, this.updateHome});

  @override
  _SubCatState createState() => _SubCatState(subList: subList);
}

class _SubCatState extends State<SubCat> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController _tc;
  ScrollController controller = new ScrollController();
  List<Map<String, dynamic>> _tabs = [];
  List<Widget> _views = [];
  List<Model> subList = [];
  List<Product> productList = [];
  List<Product> tempList = [];
  String sortBy = 'p.id', orderBy = "DESC";
  bool _isLoading = true, _isProgress = false;
  int offset = 0;
  int total = 0;
  bool isLoadingmore = true;
  bool _isNetworkAvail = true;
  bool _isFirstLoad = true;
  String filter = "";
  String selId = "";
  String totalProduct;
  var filterList;
  List<String> attnameList;
  List<String> attsubList;
  List<String> attListId;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  String curTabId;
  List<String> selectedId = [];

  _SubCatState({this.subList});

  // @override
  // bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
    if (subList != null) {
      if (subList[0].subList == null || subList[0].subList.isEmpty) {
        curTabId = subList[0].id;
        getProduct(curTabId, 0);
      }

      this._addInitailTab();
    }
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

  TabController _makeNewTabController(int pos) => TabController(
        vsync: this,
        length: _tabs.length,
        initialIndex: pos,
      );

  void _addTab(List<Model> subItem, int index) {
    print('add****${subItem[index].name}');

    setState(() {
      _tabs.add({
        // 'text': "Tab ${_tabs.length + 1}",
        'text': subItem[index].name,
      });
      _views.add(createTabContent(index, subItem));
      _tc = _makeNewTabController(_tabs.length - 1)
        ..addListener(() {
          curTabId = subList[_tc.index].id;
          filterList.clear();
          selectedId.clear();
          selId = null;
          setState(() {
            if (subList[_tc.index].subList == null ||
                subList[_tc.index].subList.isEmpty) {
              clearList();
            }
          });
        });
    });
  }

  void _addInitailTab() {
    setState(() {
      for (int i = 0; i < subList.length; i++) {
        _tabs.add({
          'text': subList[i].name,
        });
        _views.add(createTabContent(i, subList));
      }
      _tc = _makeNewTabController(0)
        ..addListener(() {
          setState(() {
            if (subList[_tc.index].subList == null ||
                subList[_tc.index].subList.isEmpty) {
              _isLoading = true;
              _views[_tc.index] = createTabContent(_tc.index, subList);
            }
          });
          filterList.clear();
          selectedId.clear();
          selId = null;
          curTabId = subList[_tc.index].id;

          if (subList[_tc.index].subList == null ||
              subList[_tc.index].subList.isEmpty) {
            clearList();
          }
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context); //
    return Scaffold(
      backgroundColor: lightWhite,
      appBar: AppBar(
        title: Text(
          widget.title,
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
        bottom: TabBar(
          controller: _tc,
          isScrollable: true,
          tabs: _tabs
              .map((tab) => Tab(
                    text: tab['text'],
                  ))
              .toList(),
        ),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: shadow(),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: InkWell(
                    child: Icon(
                      Icons.search,
                      color: primary,
                      size: 22,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Search(
                              updateHome: widget.updateHome,
                              menuopen: false,
                            ),
                          ));
                    }),
              ),
            ),
          ),
          filterList != null && filterList.length > 0
              ? Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: shadow(),
                  child: Card(
                      elevation: 0,
                      child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InkWell(
                              child: Icon(
                                Icons.tune,
                                color: primary,
                                size: 22,
                              ),
                              onTap: () {
                                if (filterList.length != 0)
                                  return filterDialog();
                              }))))
              : Container(),
          productList != null && productList.length > 0
              ? Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                  decoration: shadow(),
                  child: Card(
                      elevation: 0,
                      child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InkWell(
                              child: Icon(
                                Icons.filter_list,
                                color: primary,
                                size: 22,
                              ),
                              onTap: () {
                                if (productList.length != 0)
                                  return sortDialog();
                              }))))
              : Container()
        ],
      ),
      body: TabBarView(
        controller: _tc,
        key: Key(Random().nextDouble().toString()),
        children: _views.map((view) => view).toList(),
      ),
    );
  }

  Widget createTabContent(int i, List<Model> subList) {
    List<Model> subItem = subList[i].subList;

    print("product list==========${productList.length}");
    return subItem == null || subItem.length == 0
        ? SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CachedNetworkImage(
                  imageUrl: subList[i].banner,
                  height: 150,
                  width: double.maxFinite,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Image.asset(
                    "assets/images/sliderph.png",
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                ),
                _isLoading
                    ? shimmer()
                    : productList.length == 0
                        ? Flexible(flex: 1, child: getNoItem())
                        : ListView.builder(
                            shrinkWrap: true,
                            controller: controller,
                            itemCount: (offset < total)
                                ? productList.length + 1
                                : productList.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              print(
                                  "loading***$isLoadingmore**$index***${productList.length}***$offset***$total");

                              return (index == productList.length &&
                                      isLoadingmore)
                                  ? Center(child: CircularProgressIndicator())
                                  : productListItem(index);
                            },
                          )
              ],
            ),
          )
        : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: subList[i].banner,
                  height: 150,
                  width: double.maxFinite,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Image.asset(
                    "assets/images/sliderph.png",
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                ),
                GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(
                      subItem.length,
                      (index) {
                        return listItem(index, subItem);
                      },
                    ))
              ],
            ),
          );
  }

  Widget productListItem(int index) {
    print("desc*****${productList[index].desc}");

    double price = double.parse(productList[index].prVarientList[0].disPrice);
    if (price == 0)
      price = double.parse(productList[index].prVarientList[0].price);

    return productList.length >= index
        ? Card(
            child: InkWell(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  productList[index].name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(color: black),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: 12,
                                      ),
                                      Text(
                                        " " + productList[index].rating,
                                        style: Theme.of(context)
                                            .textTheme
                                            .overline,
                                      ),
                                      Text(
                                        " (" +
                                            productList[index].noOfRating +
                                            ")",
                                        style: Theme.of(context)
                                            .textTheme
                                            .overline,
                                      )
                                    ],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    productList[index].availability == "1" ||
                                            productList[index].stockType ==
                                                "null"
                                        ? Row(
                                            children: <Widget>[
                                              InkWell(
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      right: 8,
                                                      top: 8,
                                                      bottom: 8),
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 12,
                                                    color: Colors.grey,
                                                  ),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5))),
                                                ),
                                                onTap: () {
                                                  if (CUR_USERID != null) {
                                                    if (int.parse(productList[
                                                                index]
                                                            .prVarientList[0]
                                                            .cartCount) >
                                                        0)
                                                      removeFromCart(index);
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
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption,
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
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5))),
                                                  ),
                                                  onTap: () {
                                                    if (CUR_USERID == null) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Login()),
                                                      );
                                                    } else
                                                      addToCart(index);
                                                  }),
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
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  letterSpacing: 0.7),
                                        ),
                                        Text(
                                            " " +
                                                CUR_CURRENCY +
                                                " " +
                                                price.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6),
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
          )
        : Container();
  }

  Widget listItem(int index, List<Model> subItem) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: new ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: new CachedNetworkImage(
                    imageUrl: subItem[index].image,
                    height: double.maxFinite,
                    width: double.maxFinite,
                    placeholder: (context, url) => placeHolder(100),
                  ),
                ),
              ),
            ),
            Container(
              child: Text(
                subItem[index].name,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              width: 100,
            ),
          ],
        ),
      ),
      onTap: () {
        if (subItem[index].subList != null)
          _addTab(subItem, index);
        else
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductList(
                  name: subItem[index].name,
                  id: subItem[index].id,
                  updateHome: widget.updateHome,
                ),
              ));
      },
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
                    clearList();
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
                    clearList();
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
                    clearList();
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
                    clearList();
                    Navigator.pop(context, 'option 4');
                  }),
            ],
          );
        });
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
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10)
                        ],
                      ),
                      child: Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: InkWell(
                            child:
                                Icon(Icons.keyboard_arrow_left, color: primary),
                            onTap: () => Navigator.of(context).pop(),
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
                                  .subtitle1
                                  .copyWith(fontWeight: FontWeight.normal)),
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
                                  color: lightWhite2,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    padding: EdgeInsets.only(top: 10.0),
                                    itemCount: filterList.length,
                                    itemBuilder: (context, index) {
                                      print(
                                          "Attttt_name::::${filterList[index]['name']}");
                                      attsubList = filterList[index]
                                              ['attribute_values']
                                          .split(',');

                                      attListId = filterList[index]
                                              ['attribute_values_id']
                                          .split(',');
                                      print("Attsublist ****** $attsubList");
                                      print("AttsublistId ****** $attListId");

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
                                                top: 7.0,
                                                bottom: 7.0),
                                            decoration: BoxDecoration(
                                                color: filter ==
                                                        filterList[index]
                                                            ['name']
                                                    ? white
                                                    : lightWhite2,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
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
                                                          : lightBlack),
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
                                  scrollDirection: Axis.vertical,
                                  itemCount: filterList.length,
                                  itemBuilder: (context, index) {
                                    print(
                                        "filter******$filter******${filterList[index]["name"]}");

                                    if (filter == filterList[index]["name"]) {
                                      attsubList = filterList[index]
                                              ['attribute_values']
                                          .split(',');

                                      attListId = filterList[index]
                                              ['attribute_values_id']
                                          .split(',');
                                      print("Attsublist ****** $attsubList");
                                      print("AttsublistId ****** $attListId");
                                      return Container(
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: attListId.length,
                                              itemBuilder: (context, i) {
                                                print(
                                                    "selold111111*******************${selectedId.contains(attListId[i])}");
                                                return CheckboxListTile(
                                                  title: Text(attsubList[i],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle1
                                                          .copyWith(
                                                              color:
                                                                  lightBlack)),
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
                                                        print(
                                                            "addListIDadd******${attListId[i]}");
                                                        print(
                                                            "selectId******$selectedId");
                                                      } else {
                                                        selectedId.remove(
                                                            attListId[i]);
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
                  size: deviceWidth * 0.2,
                  title: APPLY,
                  onBtnSelected: () {
                    if (selectedId != null) {
                      print("seletIDDDDD****${selectedId.toString()}");
                      selId = selectedId.join(',');
                      print("selIdnew****$selId");
                      clearList();
                      Navigator.pop(context, 'Product Filter');
                    }
                  },
                ),
              ]),
            )
          ]);
        });
      },
    );
  }

  Future<void> getProduct(String id, int cur) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        // for (int i = 0; i < subList.length; i++) {
        print("product****${id}*****${subList.length}");
        var parameter = {
          CATID: id,
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
        if (!error) {
          total = int.parse(getdata["total"]);

          // if (_isFirstLoad) {
          if (filterList == null || filterList.length == 0)
            filterList = getdata["filters"];
          // _isFirstLoad = false;
          //}

          print('limit *****$offset****$total');
          if ((offset) < total) {
            tempList.clear();

            var data = getdata["data"];
            tempList = (data as List)
                .map((data) => new Product.fromJson(data))
                .toList();
            if (offset == 0) productList.clear();
            productList.addAll(tempList);

            offset = offset + perPage;
          }
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg);
          isLoadingmore = false;
        }

        _isLoading = false;

        /*  for (int i = 0; i < subList.length; i++) {
          _views[i] = createTabContent(i, subList);
        }*/
        _views[cur] = createTabContent(cur, subList);
        setState(() {});
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          _isLoading = false;
          isLoadingmore = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
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

  clearList() {
    setState(() {
      _isLoading = true;
      total = 0;
      offset = 0;

      _views[_tc.index] = createTabContent(_tc.index, subList);
      getProduct(curTabId, _tc.index);
    });
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

  /* _showForm() {
    return ListView.builder(
      controller: controller,
      itemCount: (offset < total) ? productList.length + 1 : productList.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        print(
            "loading***$isLoadingmore**$_isLoading***${productList.length}***$offset***$total");

        return (index == productList.length && isLoadingmore)
            ? Center(child: CircularProgressIndicator())
            : listItemProduct(index);
      },
    );
  }*/

  Widget listItemProduct(int index, List<Model> subItem) {
    print("desc*****${productList[index].desc}");

    double price = double.parse(productList[index].prVarientList[0].disPrice);
    if (price == 0)
      price = double.parse(productList[index].prVarientList[0].price);

    return Card(
      child: InkWell(
        child: Column(children: <Widget>[
          Row(
            children: <Widget>[
              productList[index].availability == "0"
                  ? Text(OUT_OF_STOCK_LBL,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Colors.red))
                  : Container()
            ],
          ),
          Row(
            children: <Widget>[
              Hero(
                tag: "${productList[index].id}",
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

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          print("limit *****$offset****$total");
          if (offset < total) getProduct(curTabId, _tc.index);
        });
      }
    }
  }
}

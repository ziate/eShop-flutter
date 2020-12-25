import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

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
  List<Product> subList = [];
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
  List<Product> subList = [];

  //List<Product> productList = [];
  List<Product> tempList = [];
  String sortBy = 'p.id', orderBy = "DESC";
  bool _isLoading = false, _isProgress = false;
  int offset = 0;
  int total = 0;
  bool isLoadingmore = true;
  bool _isNetworkAvail = true;
  bool _isFirstLoad = true;
  String filter = "";
  String selId = "";
  String totalProduct;
  //var filterList;
  List<String> attnameList;
  List<String> attsubList;
  List<String> attListId;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  String curTabId;

  bool _initialized = true;

  _SubCatState({this.subList});

  //@override
  // bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    this._addInitailTab();
    controller.addListener(_scrollListener);
    if (subList != null) {

      if (subList[0].subList == null || subList[0].subList.isEmpty) {
         curTabId = subList[0].id;
        _isLoading = true;
        getProduct(curTabId, 0);

      }

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

  void _addTab(List<Product> subItem, int index) {

    setState(() {
      _tabs.add({
        'text': subItem[index].name,
      });
      _views.add(createTabContent(index, subItem));
      _tc = _makeNewTabController(_tabs.length - 1)
        ..addListener(() {
          curTabId = subList[_tc.index].id;
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
        if (subList[i].subList == null || subList[i].subList.isEmpty) {
          _isLoading=true;
          isLoadingmore = true;

        }
        _views.add(createTabContent(i, subList));
      }

      _tc = _makeNewTabController(0)
        ..addListener(() {


          setState(() {
            if (subList[_tc.index].subList == null ||
                subList[_tc.index].subList.isEmpty) {

              clearList();
            }else{

            }
          });


          selId = null;
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
              child: InkWell(
                borderRadius:  BorderRadius.circular(4),
                onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Search(
                            updateHome: widget.updateHome,
                            menuopen: false,
                          ),
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
          subList[_tc.index].isFromProd &&   subList[_tc.index].filterList != null && subList[_tc.index].filterList.length > 0
              ? Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: shadow(),
              child: Card(
                  elevation: 0,
                  child: InkWell(
                    borderRadius:  BorderRadius.circular(4),
                    onTap: () {
                          return filterDialog();
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
          subList[_tc.index].isFromProd &&
              subList[_tc.index].subList != null &&
              subList[_tc.index].subList.length > 0
              ? Container(
              margin: EdgeInsets.only(top: 10, bottom: 10, right: 10),
              decoration: shadow(),
              child: Card(
                  elevation: 0,
                  child: InkWell(
                    borderRadius:  BorderRadius.circular(4),
                    onTap: () {
                          return sortDialog();
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
              : Container()
        ],
      ),
      body: TabBarView(
        controller: _tc,
        children: _views.map((view) => view).toList(),
      ),
    );
  }

  Widget createTabContent(int i, List<Product> subList) {
    List<Product> subItem = subList[i].subList;

     return !subList[i].isFromProd && (subItem != null)
        ? SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          FadeInImage(
            fadeInDuration: Duration(milliseconds: 150),
            image: NetworkImage(subList[i].banner),
            height: 150,
            width: double.maxFinite,
            fit: BoxFit.fill,
            placeholder: AssetImage(
              "assets/images/sliderph.png",
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
    )
        : SingleChildScrollView(
      controller: controller,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeInImage(
            fadeInDuration: Duration(milliseconds: 150),
            image: NetworkImage(subList[i].banner),
            height: 150,
            width: double.maxFinite,
            fit: BoxFit.fill,
            placeholder:AssetImage(
              "assets/images/sliderph.png",
            ),
          ),
          _isLoading
              ? shimmer()
              : subItem.length == 0
              ? Flexible(flex: 1, child: getNoItem())
              : ListView.builder(
            shrinkWrap: true,
            itemCount:
            (subList[i].offset < subList[i].totalItem)
                ? subItem.length + 1
                : subItem.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {

              return (index == subItem.length && isLoadingmore)
                  ? Center(child: CircularProgressIndicator())
                  : productListItem(index, subItem);
            },
          )
        ],
      ),
    );
  }

  Widget productListItem(int index, List<Product> subItem) {

    double price = double.parse(subItem[index].prVarientList[0].disPrice);
    if (price == 0) price = double.parse(subItem[index].prVarientList[0].price);

    return subItem.length >= index
        ? Card(
      elevation: 0,
      child: InkWell(
        borderRadius:  BorderRadius.circular(4),
        onTap: () {
          Product model = subItem[index];
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
                  //  title: productList[index].name,
                )),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                subItem[index].availability == "0"
                    ? Text(OUT_OF_STOCK_LBL,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: Colors.red))
                    : Container(),
                Row(
                  children: <Widget>[
                    Hero(
                      tag: "$index${subItem[index].id}",
                      child: FadeInImage(
                        fadeInDuration: Duration(milliseconds: 150),
                        image: NetworkImage(subItem[index].image),
                        height: 80.0,
                        width: 80.0,
                        placeholder: placeHolder(80),
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
                              subItem[index].name,
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
                                  " " + subItem[index].rating,
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline,
                                ),
                                Text(
                                  " (" + subItem[index].noOfRating + ")",
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline,
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      int.parse(subItem[index]
                                          .prVarientList[0]
                                          .disPrice) !=
                                          0
                                          ? CUR_CURRENCY +
                                          "" +
                                          subItem[index]
                                              .prVarientList[0]
                                              .price
                                          : "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .overline
                                          .copyWith(
                                          decoration: TextDecoration
                                              .lineThrough,
                                          letterSpacing: 0),
                                    ),
                                    Text(
                                        " " +
                                            CUR_CURRENCY +
                                            " " +
                                            price.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1),
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
        ),
      ),
    )
        : Container();
  }

  Widget listItem(int index, List<Product> subItem) {
    return GestureDetector(
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
                  child: new FadeInImage(
                    fadeInDuration: Duration(milliseconds: 150),
                    image: NetworkImage(subItem[index].image),
                    height: double.maxFinite,
                    width: double.maxFinite,
                    placeholder: placeHolder(100),
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

/*  void sortDialog() {
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
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                      padding: EdgeInsets.only(top: 19.0, bottom: 16.0),
                      child: Text(
                        SORT_BY,
                        style: Theme.of(context).textTheme.headline6,
                      )),
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

                        clearList();
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

                        clearList();
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

                        clearList();
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

                            clearList();
                            Navigator.pop(context, 'option 4');
                          })),
                ])),
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
                                  subList[_tc.index].selectedId.clear();
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
                                            itemCount: subList[_tc.index].filterList.length,
                                            itemBuilder: (context, index) {

                                              attsubList = subList[_tc.index].filterList[index]
                                                  .attributeValues
                                                  .split(',');

                                              attListId = subList[_tc.index].filterList[index]
                                                  .attributeValId
                                                  .split(',');

                                              if (filter == "") {
                                                filter = subList[_tc.index].filterList[0].name;
                                              }

                                              return InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      filter =
                                                          subList[_tc.index].filterList[index].name;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        left: 20,
                                                        top: 10.0,
                                                        bottom: 10.0),
                                                    decoration: BoxDecoration(
                                                        color: filter ==
                                                            subList[_tc.index].filterList[index].name

                                                            ? white
                                                            : lightWhite,
                                                        borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(7),
                                                            bottomLeft:
                                                            Radius.circular(7))),
                                                    alignment: Alignment.centerLeft,
                                                    child: new Text(
                                                      subList[_tc.index].filterList[index].name,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle1
                                                          .copyWith(
                                                          color: filter ==
                                                              subList[_tc.index].filterList[index].name
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
                                          itemCount: subList[_tc.index].filterList.length,
                                          itemBuilder: (context, index) {
                                            //  print("filter******$filter******${filterList[index]["name"]}");

                                            if (filter == subList[_tc.index].filterList[index].name) {
                                              attsubList = subList[_tc.index].filterList[index].attributeValues
                                                  .split(',');

                                              attListId = subList[_tc.index].filterList[index].attributeValId
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
                                                          value: subList[_tc.index].selectedId
                                                              .contains(attListId[i]),
                                                          activeColor: primary,
                                                          controlAffinity:
                                                          ListTileControlAffinity
                                                              .leading,
                                                          onChanged: (bool val) {
                                                            setState(() {
                                                              if (val == true) {
                                                                subList[_tc.index].selectedId
                                                                    .add(attListId[i]);
                                                               } else {
                                                                subList[_tc.index].selectedId.remove(attListId[i]);
                                                                // print("addListIDremove******${attListId[i]}");
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
                            Text(subList[_tc.index].totalItem.toString()),
                            Text(PRODUCTS_FOUND_LBL),
                          ],
                        )),
                    Spacer(),
                    SimBtn(
                      size: deviceWidth * 0.4,
                      title: APPLY,
                      onBtnSelected: () {
                        if (subList[_tc.index].selectedId != null) {
                              selId = subList[_tc.index].selectedId.join(',');
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

  /*Future<void> getmoreProduct(String id, int cur) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        // for (int i = 0; i < subList.length; i++) {
        print("product list=========**********${id}*****${subList.length}");
        var parameter = {
          CATID: id,
          SORT: sortBy,
          ORDER: orderBy,
          LIMIT: perPage.toString(),
          OFFSET: subList[cur].subList==null?'0':subList[cur].subList.length.toString(),
        };
        if (selId != null && selId != "") {
          parameter[ATTRIBUTE_VALUE_ID] = selId;
        }
        if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;


        print('response***product*$parameter');
        Response response =
        await post(getProductApi, headers: headers, body: parameter)
            .timeout(Duration(seconds: timeOut));


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
            if (offset == 0) subList[cur].subList = [];
            // subList[cur].subList.clear();
            //productList.clear();
            //productList.addAll(tempList);
            subList[cur].subList.addAll(tempList);
            offset = offset + perPage;
            subList[cur].isFromProd = true;


          }
        } else {
          if (offset == 0) subList[cur].subList = [];
          if (msg != "Products Not Found !") setSnackbar(msg);
          isLoadingmore = false;
        }

        _isLoading = false;

        */ /*  for (int i = 0; i < subList.length; i++) {
          _views[i] = createTabContent(i, subList);
        }*/ /*
        //_views[cur] = createTabContent(cur, subList);
        */ /* controller.animateTo(
          controller.position.maxScrollExtent,
          duration: Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
        );*/ /*
        setState(() {

        });

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
  }*/

  Future<void> getProduct(String id, int cur) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
          var parameter = {
          CATID: id,
          SORT: sortBy,
          ORDER: orderBy,
          LIMIT: perPage.toString(),
          OFFSET: subList[cur].subList == null
              ? '0'
              : subList[cur].subList.length.toString(),
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
          offset =
          subList[cur].subList == null ? 0 : subList[cur].subList.length;

          if ( subList[cur].filterList == null ||  subList[cur].filterList.length == 0) {

            subList[cur].filterList =(getdata["filters"] as List)
                .map((data) => new Filter.fromJson(data))
                .toList();
            subList[cur].selectedId=[];
          }


          if (offset < total) {
            tempList.clear();

            var data = getdata["data"];
            tempList = (data as List)
                .map((data) => new Product.fromJson(data))
                .toList();
            if (offset == 0) subList[cur].subList = [];
            // subList[cur].subList.clear();
            //productList.clear();
            //productList.addAll(tempList);
            subList[cur].subList.addAll(tempList);
            offset = subList[cur].offset + perPage;

            subList[cur].offset = offset;
            subList[cur].totalItem = total;
                }
        } else {
          if (offset == 0) subList[cur].subList = [];
          if (msg != "Products Not Found !") setSnackbar(msg);
          isLoadingmore = false;
        }

        _isLoading = false;

        /*  for (int i = 0; i < subList.length; i++) {
          _views[i] = createTabContent(i, subList);
        }*/
        subList[cur].isFromProd = true;
        _views[cur] = createTabContent(cur, subList);
        /* controller.animateTo(
          controller.position.maxScrollExtent,
          duration: Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
        );*/
        setState(() {});
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
    }
  }

/*  Future<void> addToCart(int index) async {
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
  }*/

  clearList() {
    setState(() {
      _isLoading = true;
      _views[_tc.index] = createTabContent(_tc.index, subList);
      total = 0;
      offset = 0;
      subList[_tc.index].totalItem = 0;
      subList[_tc.index].offset = 0;
      subList[_tc.index].subList=[];
      //subList[_tc.index].selectedId=[];
      curTabId = subList[_tc.index].id;

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

/*
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
*/

  updateProductList() {
    setState(() {});
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {

        if (subList[_tc.index].offset < subList[_tc.index].totalItem) {
          // setState(() {
          isLoadingmore = true;
          // });
          curTabId = subList[_tc.index].id;
          _views[_tc.index] = createTabContent(_tc.index, subList);
          getProduct(curTabId, _tc.index);
        }
      }
    }
  }
}

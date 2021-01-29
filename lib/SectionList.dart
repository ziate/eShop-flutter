import 'dart:async';
import 'dart:convert';

import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'Favorite.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/SimBtn.dart';
import 'Login.dart';
import 'Model/Section_Model.dart';
import 'Helper/String.dart';
import 'Product_Detail.dart';
import 'Search.dart';

class SectionList extends StatefulWidget {
  final int index;
  Section_Model section_model;
  final Function updateHome;

  SectionList({Key key, this.index, this.section_model, this.updateHome})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StateSection();
}

class StateSection extends State<SectionList> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isLoadingmore = true;
  bool _isLoading = true;
  ScrollController controller = new ScrollController();
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  String sortBy = 'p.id', orderBy = "DESC";
  List<String> attnameList;
  List<String> attsubList;
  List<String> attListId;
  String filter = "";
  String selId = "";
  int offset;
  bool listType = false;
  int total = 0;

  @override
  void initState() {
    super.initState();
    widget.section_model.offset = widget.section_model.productList.length;

    widget.section_model.selectedId = [];

    widget.section_model.productList.clear();
    getSection("0");
    controller.addListener(_scrollListener);
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
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
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

  Future<Null> _refresh() {
    setState(() {
      _isLoading = true;
      isLoadingmore = true;
      widget.section_model.offset = 0;
      widget.section_model.totalItem = 0;
      widget.section_model.selectedId = [];
      selId = '';
    });

    total = 0;
    offset = 0;
    widget.section_model.productList.clear();
    return getSection("0");
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,

      appBar: AppBar(
        leading: Builder(builder: (BuildContext context) {
          return Container(
            margin: EdgeInsets.all(10),
            decoration: shadow(),
            child: Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => Navigator.of(context).pop(),
                child: Center(
                  child: Icon(
                    Icons.keyboard_arrow_left,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          );
        }),
        title: Text(
          sectionList[widget.index].title,
          style: TextStyle(
            color: colors.fontColor,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: shadow(),
            child: Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
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
                    color: colors.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: shadow(),
              child: Card(
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      return filterDialog();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.tune,
                        color: colors.primary,
                        size: 22,
                      ),
                    ),
                  ))),
          Container(
              margin: EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              decoration: shadow(),
              child: Card(
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      return sortDialog();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.filter_list,
                        color: colors.primary,
                        size: 22,
                      ),
                    ),
                  ))),
          Container(
              margin: EdgeInsets.only(top: 10, bottom: 10, right: 10),
              decoration: shadow(),
              child: Card(
                  elevation: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            listType ? Icons.grid_view : Icons.list,
                            color: colors.primary,
                            size: 22,
                          ),
                        ),
                        onTap: () {
                          widget.section_model.productList.length != 0
                              ? setState(() {
                            listType = !listType;
                          })
                              : null;
                        }),
                  ))),
        ],
      ),
      body: _isNetworkAvail
          ? RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: _isLoading
              ? shimmer()
              : listType
              ? ListView.builder(
            controller: controller,
            itemCount: (widget.section_model.offset <
                widget.section_model.totalItem)
                ? widget.section_model.productList.length + 1
                : widget.section_model.productList.length,
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return (index ==
                  widget
                      .section_model.productList.length &&
                  isLoadingmore)
                  ? Center(child: CircularProgressIndicator())
                  : listItem(index);
            },
          )
              : GridView.count(
              padding: EdgeInsets.only(top: 5, left: 10, right: 10),
              crossAxisCount: 2,
              childAspectRatio: 1,
              physics: AlwaysScrollableScrollPhysics(),
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              controller: controller,
              children: List.generate(
                (widget.section_model.offset <
                    widget.section_model.totalItem)
                    ? widget.section_model.productList.length + 1
                    : widget.section_model.productList.length,
                    (index) {
                  return (index ==
                      widget.section_model.productList
                          .length &&
                      isLoadingmore)
                      ? Center(child: CircularProgressIndicator())
                      : productItem(index);
                },
              )))
          : noInternet(context),
    );
  }

  Widget listItem(int index) {
    double price = double.parse(
        widget.section_model.productList[index].prVarientList[0].disPrice);
    if (price == 0)
      price = double.parse(
          widget.section_model.productList[index].prVarientList[0].price);

    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          widget.section_model.productList[index].availability == "0"
              ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL'),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: Colors.red))
              : Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Hero(
                  tag: "$index${widget.section_model.productList[index].id}",
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0),
                      child: FadeInImage(
                        image: NetworkImage(
                            widget.section_model.productList[index].image),
                        height: 80.0,
                        width: 80.0,
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
                          widget.section_model.productList[index].name,
                          style: TextStyle(
                              color: colors.lightBlack,
                              fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: colors.primary,
                              size: 12,
                            ),
                            Text(
                              " " +
                                  widget
                                      .section_model.productList[index].rating,
                              style: Theme.of(context).textTheme.overline,
                            ),
                            Text(
                              " (" +
                                  widget.section_model.productList[index]
                                      .noOfRating +
                                  ")",
                              style: Theme.of(context).textTheme.overline,
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              double.parse(widget.section_model.productList[index]
                                  .prVarientList[0].disPrice) !=
                                  0
                                  ? CUR_CURRENCY +
                                  "" +
                                  widget.section_model.productList[index]
                                      .prVarientList[0].price
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
                            Spacer(),
                            widget.section_model.productList[index].isFavLoading
                                ? Container(
                                height: 15,
                                width: 15,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 3),
                                padding: const EdgeInsets.all(3),
                                child: CircularProgressIndicator(
                                  strokeWidth: 0.7,
                                ))
                                : InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 3),
                                  child: Icon(
                                    widget.section_model.productList[index]
                                        .isFav ==
                                        "0"
                                        ? Icons.favorite_border
                                        : Icons.favorite,
                                    size: 15,
                                    color: colors.primary,
                                  ),
                                ),
                                onTap: () {
                                  if (CUR_USERID != null) {
                                    widget.section_model.productList[index]
                                        .isFav ==
                                        "0"
                                        ? _setFav(index)
                                        : _removeFav(index);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()),
                                    );
                                  }
                                })
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
          Product model = widget.section_model.productList[index];
          Navigator.push(
            context,
            PageRouteBuilder(
              // transitionDuration: Duration(seconds: 1),
                pageBuilder: (_, __, ___) => ProductDetail(
                  model: model,
                  updateParent: updateSectionList,
                  updateHome: widget.updateHome,
                  secPos: widget.index,
                  index: index,
                  list: false,
                )),
          );
        },
      ),
    );
  }

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
                        getTranslated(context, 'SORT_BY'),
                        style: Theme.of(context).textTheme.headline6,
                      )),
                  Divider(color: colors.lightBlack),
                  TextButton(
                      child: Text(getTranslated(context,'TOP_RATED'),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: colors.lightBlack)),
                      onPressed: () {
                        sortBy = '';
                        orderBy = 'DESC';

                        clearList("1");
                        Navigator.pop(context, 'option 1');
                      }),
                  Divider(color: colors.lightBlack),
                  TextButton(
                      child: Text(getTranslated(context, 'F_NEWEST'),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: colors.lightBlack)),
                      onPressed: () {
                        sortBy = 'p.date_added';
                        orderBy = 'DESC';

                        clearList("0");
                        Navigator.pop(context, 'option 1');
                      }),
                  Divider(color: colors.lightBlack),
                  TextButton(
                      child: Text(
                        getTranslated(context, 'F_OLDEST'),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: colors.lightBlack),
                      ),
                      onPressed: () {
                        sortBy = 'p.date_added';
                        orderBy = 'ASC';

                        clearList("0");
                        Navigator.pop(context, 'option 2');
                      }),
                  Divider(color: colors.lightBlack),
                  TextButton(
                      child: new Text(
                        getTranslated(context, 'F_LOW'),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: colors.lightBlack),
                      ),
                      onPressed: () {
                        sortBy = 'pv.price';
                        orderBy = 'ASC';

                        clearList("0");
                        Navigator.pop(context, 'option 3');
                      }),
                  Divider(color: colors.lightBlack),
                  Padding(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: TextButton(
                          child: new Text(
                            getTranslated(context, 'F_HIGH'),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: colors.lightBlack),
                          ),
                          onPressed: () {
                            sortBy = 'pv.price';
                            orderBy = 'DESC';

                            clearList("0");
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
                        getTranslated(context, 'FILTER'),
                        style: TextStyle(
                          color: colors.fontColor,
                        ),
                      ),
                      elevation: 5,
                      leading: Builder(builder: (BuildContext context) {
                        return Container(
                          margin: EdgeInsets.all(10),
                          decoration: shadow(),
                          child: Card(
                            elevation: 0,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(4),
                              onTap: () => Navigator.of(context).pop(),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Icon(Icons.keyboard_arrow_left,
                                    color: colors.primary),
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
                              child: Text(getTranslated(context, 'FILTER_CLEAR_LBL'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(
                                      fontWeight: FontWeight.normal,
                                      color: colors.fontColor)),
                              onTap: () {
                                setState(() {
                                  widget.section_model.selectedId.clear();
                                });
                              }),
                        ),
                      ],
                    )),
                Expanded(
                    child: Container(
                        color: colors.lightWhite,
                        padding: EdgeInsets.only(left: 7.0, right: 7.0, top: 7.0),
                        child: Card(
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Container(
                                          color: colors.lightWhite,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            padding: EdgeInsets.only(top: 10.0),
                                            itemCount:
                                            widget.section_model.filterList.length,
                                            itemBuilder: (context, index) {
                                              attsubList = widget.section_model
                                                  .filterList[index].attributeValues
                                                  .split(',');

                                              attListId = widget.section_model
                                                  .filterList[index].attributeValId
                                                  .split(',');

                                              if (filter == "") {
                                                filter = widget
                                                    .section_model.filterList[0].name;
                                              }

                                              return InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      filter = widget.section_model
                                                          .filterList[index].name;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        left: 20,
                                                        top: 10.0,
                                                        bottom: 10.0),
                                                    decoration: BoxDecoration(
                                                        color: filter ==
                                                            widget
                                                                .section_model
                                                                .filterList[index]
                                                                .name
                                                            ? colors.white
                                                            : colors.lightWhite,
                                                        borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(7),
                                                            bottomLeft:
                                                            Radius.circular(7))),
                                                    alignment: Alignment.centerLeft,
                                                    child: new Text(
                                                      widget.section_model
                                                          .filterList[index].name,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle1
                                                          .copyWith(
                                                          color: filter ==
                                                              widget
                                                                  .section_model
                                                                  .filterList[
                                                              index]
                                                                  .name
                                                              ? colors.fontColor
                                                              : colors.lightBlack,
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
                                          itemCount:
                                          widget.section_model.filterList.length,
                                          itemBuilder: (context, index) {
                                            if (filter ==
                                                widget.section_model.filterList[index]
                                                    .name) {
                                              attsubList = widget.section_model
                                                  .filterList[index].attributeValues
                                                  .split(',');

                                              attListId = widget.section_model
                                                  .filterList[index].attributeValId
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
                                                                  color: colors
                                                                      .lightBlack,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                          value: widget
                                                              .section_model.selectedId
                                                              .contains(attListId[i]),
                                                          activeColor: colors.primary,
                                                          controlAffinity:
                                                          ListTileControlAffinity
                                                              .leading,
                                                          onChanged: (bool val) {
                                                            setState(() {
                                                              if (val == true) {
                                                                widget.section_model
                                                                    .selectedId
                                                                    .add(attListId[i]);
                                                              } else {
                                                                widget.section_model
                                                                    .selectedId
                                                                    .remove(
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
                  color: colors.white,
                  child: Row(children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.section_model.totalItem.toString()),
                            Text(getTranslated(context, 'PRODUCTS_FOUND_LBL')),
                          ],
                        )),
                    Spacer(),
                    SimBtn(
                      size: 0.4,
                      title: getTranslated(context,'APPLY'),
                      onBtnSelected: () {
                        if (widget.section_model.selectedId != null) {
                          selId = widget.section_model.selectedId.join(',');
                          clearList("0");
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

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          if (widget.section_model.offset < widget.section_model.totalItem)
            getSection("0");
        });
      }
    }
  }

  clearList(String top) {
    setState(() {
      _isLoading = true;
      total = 0;
      offset = 0;
      widget.section_model.totalItem = 0;
      widget.section_model.offset = 0;
      widget.section_model.productList = [];

      getSection(top);
    });
  }

  productItem(int index) {
    double width = deviceWidth * 0.5 - 20;
    double price = double.parse(
        widget.section_model.productList[index].prVarientList[0].disPrice);
    if (price == 0)
      price = double.parse(
          widget.section_model.productList[index].prVarientList[0].price);
    return Card(
      elevation: 0,
      child: InkWell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Hero(
                      tag:
                      "${sectionList[widget.index].productList[index].id}${widget.index}${index}",
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5)),
                        child: FadeInImage(
                          image: NetworkImage(
                              widget.section_model.productList[index].image),
                          height: double.maxFinite,
                          width: double.maxFinite,
                          //errorWidget:(context, url,e) => placeHolder(width) ,
                          placeholder: placeHolder(width),
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: colors.primary,
                              size: 10,
                            ),
                            Text(
                              widget.section_model.productList[index].rating,
                              style: Theme.of(context)
                                  .textTheme
                                  .overline
                                  .copyWith(letterSpacing: 0.2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.section_model.productList[index].name,
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  widget.section_model.productList[index].isFavLoading
                      ? Container(
                      height: 15,
                      width: 15,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3),
                      padding: const EdgeInsets.all(3),
                      child: CircularProgressIndicator(
                        strokeWidth: 0.7,
                      ))
                      : InkWell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 3),
                        child: Icon(
                          widget.section_model.productList[index].isFav ==
                              "0"
                              ? Icons.favorite_border
                              : Icons.favorite,
                          size: 15,
                          color: colors.primary,
                        ),
                      ),
                      onTap: () {
                        if (CUR_USERID != null) {
                          widget.section_model.productList[index].isFav ==
                              "0"
                              ? _setFav(index)
                              : _removeFav(index);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Login()),
                          );
                        }
                      })
                  // IconButton(icon: Icon(Icons.favorite_border,),iconSize: 10, onPressed: null)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, bottom: 5),
              child: Row(
                children: <Widget>[
                  Text(
                    double.parse(widget.section_model.productList[index]
                        .prVarientList[0].disPrice) !=
                        0
                        ? CUR_CURRENCY +
                        "" +
                        widget.section_model.productList[index]
                            .prVarientList[0].price
                        : "",
                    style: Theme.of(context).textTheme.overline.copyWith(
                        decoration: TextDecoration.lineThrough,
                        letterSpacing: 1),
                  ),
                  Text(" " + CUR_CURRENCY + " " + price.toString(),
                      style: TextStyle(color: colors.primary)),
                ],
              ),
            )
          ],
        ),
        onTap: () {
          Product model = widget.section_model.productList[index];
          Navigator.push(
            context,
            PageRouteBuilder(
              // transitionDuration: Duration(seconds: 1),
                pageBuilder: (_, __, ___) => ProductDetail(
                  model: model,
                  updateParent: updateSectionList,
                  updateHome: widget.updateHome,
                  secPos: widget.index,
                  index: index,
                  list: false,
                )),
          );
        },
      ),
    );
  }

  updateSectionList() {
    setState(() {});
  }

  Future<Null> getSection(String top) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_LIMIT: perPage.toString(),
          PRODUCT_OFFSET: widget.section_model.productList.length.toString(),
          SEC_ID: widget.section_model.id,
          TOP_RETAED: top,
          PSORT: sortBy,
          PORDER: orderBy,
        };
        if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        if (selId != null && selId != "") {
          parameter[ATTRIBUTE_VALUE_ID] = selId;
        }

        Response response =
        await post(getSectionApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          offset = widget.section_model.productList.length;

          total = int.parse(data[0]["total"]);

          if (offset < total) {
            List<Section_Model> temp = (data as List)
                .map((data) => new Section_Model.fromJson(data))
                .toList();

            sectionList[widget.index].productList.addAll(temp[0].productList);
            //temp[0];

            offset = widget.section_model.offset + perPage;

            widget.section_model.offset = offset;
            widget.section_model.totalItem = total;
          }
        } else {
          isLoadingmore = false;
          setSnackbar(msg);
        }

        setState(() {
          _isLoading = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar( getTranslated(context,'somethingMSg'));
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }

    return null;
  }

  _setFav(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          widget.section_model.productList[index].isFavLoading = true;
        });

        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_ID: widget.section_model.productList[index].id
        };
        Response response =
        await post(setFavoriteApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          widget.section_model.productList[index].isFav = "1";
          widget.updateHome();
        } else {
          setSnackbar(msg);
        }

        setState(() {
          widget.section_model.productList[index].isFavLoading = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar( getTranslated(context,'somethingMSg'));
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  setSnackbar(String msg) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.black),
      ),
      backgroundColor: colors.white,
      elevation: 1.0,
    ));
  }

  _removeFav(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          widget.section_model.productList[index].isFavLoading = true;
        });

        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_ID: widget.section_model.productList[index].id
        };
        Response response =
        await post(removeFavApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          widget.section_model.productList[index].isFav = "0";

          favList.removeWhere((item) =>
          item.productList[0].prVarientList[0].id ==
              widget.section_model.productList[index].prVarientList[0].id);

          widget.updateHome();
        } else {
          setSnackbar(msg);
        }

        setState(() {
          widget.section_model.productList[index].isFavLoading = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar( getTranslated(context,'somethingMSg'));
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Cart.dart';
import 'package:eshop/Rating_Review.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';

import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Home.dart';
import 'Login.dart';
import 'Model/Section_Model.dart';
import 'Model/User.dart';
import 'Product_Preview.dart';
import 'Favorite.dart';

class ProductDetail extends StatefulWidget {
  final Product model;

  final Function updateHome;
  final Function updateParent;
  final int secPos, index;
  final bool list;

  const ProductDetail(
      {Key key,
      this.model,
      this.updateParent,
      this.updateHome,
      this.secPos,
      this.index,
      this.list})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StateItem();
}

List<String> sliderList = [];
List<User> reviewList = [];
int offset = 0;
int total = 0;

class StateItem extends State<ProductDetail> with TickerProviderStateMixin {
  int _curSlider = 0;
  final _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<int> _selectedIndex = [];
  ChoiceChip choiceChip;
  int _selVarient = 0, _oldSelVarient = 0;
  bool _isProgress = false, _isLoading = true;

  bool _isCommentEnable = false, _showComment = false;
  TextEditingController _commentC = new TextEditingController();
  double initialRate = 0;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;
  String availVariant = '';

  @override
  void initState() {
    super.initState();
    sliderList.clear();
    sliderList.add(widget.model.image);
    sliderList.addAll(widget.model.otherImage);

    getAvailVarient();
    reviewList.clear();
    offset = 0;
    total = 0;
    getReview();

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
      body: _isNetworkAvail
          ? SafeArea(
              child: Stack(
                children: <Widget>[
                  _showContent(),
                  showCircularProgress(_isProgress, primary),
                ],
              ),
            )
          : noInternet(context),
    );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Widget _slider() {
    double height = MediaQuery.of(context).size.height * .38;

    print("height========$deviceHeight");
    return InkWell(
      splashColor: primary.withOpacity(0.2),
      onTap: () {
        Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration(seconds: 1),
              pageBuilder: (_, __, ___) => ProductPreview(
                  pos: _curSlider,
                  secPos: widget.secPos,
                  index: widget.index,
                  id: widget.model.id,
                  list: widget.list),
            ));
      },
      child: Stack(
        children: <Widget>[
          Hero(
              tag: widget.list
                  ? "${widget.index}${widget.model.id}"
                  : "${sectionList[widget.secPos].productList[widget.index].id}${widget.secPos}${widget.index}",
              child: Container(
                height: height,
                width: double.infinity,
                //padding: EdgeInsets.all(8.0),
                child: PageView.builder(
                  itemCount: sliderList.length,
                  scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  reverse: false,
                  onPageChanged: (index) {
                    setState(() {
                      _curSlider = index;
                    });
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: <Widget>[
                        CachedNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: sliderList[_curSlider],
                          placeholder: (context, url) => Image.asset(
                            "assets/images/sliderph.png",
                            fit: BoxFit.fill,
                            height: height,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            "assets/images/sliderph.png",
                            height: height,
                          ),
                          height: height,
                          width: double.maxFinite,
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text(
                                "${_curSlider + 1}/${sliderList.length}",
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(color: primary),
                              ),
                              decoration: BoxDecoration(
                                  color: lightWhite,
                                  borderRadius: BorderRadius.circular(5)),
                              padding: EdgeInsets.symmetric(horizontal: 5),
                            )),

                        indicatorImage(),
                        // )
                      ],
                    );
                  },
                ),
              )),
          Container(
            color: white30,
            width: deviceWidth,
            height: kToolbarHeight,
          ),
          Material(
            color: Colors.transparent,
            child: Container(
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
            ),
          ),
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 10.0, bottom: 10, right: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        decoration: shadow(),
                        child: Card(
                            elevation: 0.2,
                            shadowColor: lightBlack,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(
                                      Icons.share_outlined,
                                      color: primary,
                                      size: 20,
                                    ),
                                  ),
                                  onTap: () async {
                                    var str =
                                        "${widget.model.name}\n\n$appName\n\nYou can find our app from below url\n\nAndroid:\n"
                                        "$androidLink$packageName\n\n iOS:\n$iosLink$iosPackage";
                                    // Share.shareFiles([sliderList[0]],text:str);

                                    final response = await get(sliderList[0]);

                                    final Directory temp =
                                        await getTemporaryDirectory();
                                    final File imageFile =
                                        File('${temp.path}/tempImage');
                                    imageFile
                                        .writeAsBytesSync(response.bodyBytes);
                                    Share.shareFiles(
                                      ['${temp.path}/tempImage'],
                                      text: str,
                                    );
                                  }),
                            ))),
                    Container(
                        decoration: shadow(),
                        child: Card(
                            elevation: 0.2,
                            shadowColor: lightBlack,
                            child: widget.model.isFavLoading
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        height: 10,
                                        width: 10,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 0.7,
                                        )),
                                  )
                                : Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Icon(
                                            widget.model.isFav == "0"
                                                ? Icons.favorite_border
                                                : Icons.favorite,
                                            color: primary,
                                            size: 20,
                                          ),
                                        ),
                                        onTap: () {
                                          if (CUR_USERID != null) {
                                            widget.model.isFav == "0"
                                                ? _setFav()
                                                : _removeFav();
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Login()),
                                            );
                                          }
                                        }),
                                  ))),
                    Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: shadow(),
                        child: InkWell(
                          child: Card(
                            elevation: 0.2,
                            shadowColor: lightBlack,
                            child: new Stack(children: <Widget>[
                              Center(
                                child: Image.asset(
                                  'assets/images/noti_cart.png',
                                  width: 30,
                                ),
                              ),
                              (CUR_CART_COUNT != null &&
                                      CUR_CART_COUNT.isNotEmpty &&
                                      CUR_CART_COUNT != "0")
                                  ? new Positioned(
                                      top: 0.0,
                                      right: 5.0,
                                      bottom: 10,
                                      child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: primary.withOpacity(0.5)),
                                          child: new Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(3),
                                              child: new Text(
                                                CUR_CART_COUNT,
                                                style: TextStyle(
                                                    fontSize: 7,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          )),
                                    )
                                  : Container()
                            ]),
                          ),
                          onTap: () async {
                            CUR_USERID == null
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Login(),
                                    ))
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Cart(widget.updateHome, updateDetail),
                                    ));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  indicatorImage() {
    String indicator = widget.model.indicator;
    print("Indicator:::::$indicator");

    if (indicator == "1") {
      return Align(
          alignment: Alignment.bottomRight,
          child: Image.asset("assets/images/vag.png"));
    } else if (indicator == "2") {
      return Align(
          alignment: Alignment.bottomRight,
          child: Image.asset("assets/images/nonvag.png"));
    } else {
      return Container();
    }
  }

  updateDetail() {
    setState(() {});
  }

  _smallImage() {
    double width = deviceWidth * .15;

    print(
        "length************${widget.model.prVarientList[_selVarient].images.length}");

    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: width,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: widget.model.prVarientList[_selVarient].images.length,
        itemBuilder: (context, index) {
          return InkWell(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: CachedNetworkImage(
                    imageUrl: sliderList[index],
                    fit: BoxFit.fill,
                    placeholder: (context, url) => Image.asset(
                      "assets/images/placeholder.png",
                      height: width,
                      fit: BoxFit.fill,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      "assets/images/placeholder.png",
                      fit: BoxFit.fill,
                      height: width,
                      width: width,
                    ),
                    height: width,
                    width: width,
                  )),
            ),
            onTap: () {
              _pageController.jumpToPage(index);
            },
          );
        },
      ),
    );
  }

  _rate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RatingBarIndicator(
            rating: double.parse(widget.model.rating),
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 12.0,
            direction: Axis.horizontal,
          ),
          Text(
            " " + widget.model.rating,
            style: Theme.of(context).textTheme.caption,
          ),
          Text(
            " | " + widget.model.noOfRating + " Ratings",
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
    );
  }

  _price(pos) {
    double price = double.parse(widget.model.prVarientList[pos].disPrice);
    if (price == 0) price = double.parse(widget.model.prVarientList[pos].price);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Text(CUR_CURRENCY + " " + price.toString(),
          style: Theme.of(context).textTheme.headline6),
    );
  }

  _offPrice(pos) {
    double price = double.parse(widget.model.prVarientList[pos].disPrice);

    if (price != 0) {
      double off = (int.parse(widget.model.prVarientList[pos].price) -
              int.parse(widget.model.prVarientList[pos].disPrice))
          .toDouble();
      off = off * 100 / int.parse(widget.model.prVarientList[pos].price);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: <Widget>[
            Text(
              CUR_CURRENCY + " " + widget.model.prVarientList[0].price,
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                  decoration: TextDecoration.lineThrough, letterSpacing: 0),
            ),
            Text(" | " + off.toStringAsFixed(2) + "% off",
                style: Theme.of(context)
                    .textTheme
                    .overline
                    .copyWith(color: primary, letterSpacing: 0)),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  _title() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Text(
        widget.model.name,
        style:
            Theme.of(context).textTheme.subtitle1.copyWith(color: lightBlack),
      ),
    );
  }

  _desc() {
    print("detail===${widget.model.desc}");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Html(data: widget.model.desc),
    );
    //Html(data:widget.model.productList[widget.proPos].desc);
  }

  Future<void> setRating(double rating, String comment) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        // print("product****${widget.id}");

        setState(() {
          _isLoading = true;
        });
        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_ID: widget.model.id,
          COMMENT: comment,
        };

        if (rating != 0) parameter[RATING] = rating.toString();
        Response response =
            await post(setRatingApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));

        print('response***product**$parameter***${response.body.toString()}');

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        if (!error) {
          _showComment = true;
          reviewList.clear();
          offset = 0;

          var data = getdata["data"]["product_rating"];
          widget.model.noOfRating = getdata["data"]["no_of_rating"];

          reviewList =
              (data as List).map((data) => new User.forReview(data)).toList();

          offset = offset + perPage;
        } else {
          initialRate = 0;
        }
        _isCommentEnable = false;
        _commentC.text = "";
        setState(() {
          _isLoading = false;
        });

        //  WidgetsBinding.instance.addPostFrameCallback(_onLayoutDone);
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
      }
    } else
      setState(() {
        _isNetworkAvail = false;
      });
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

  _selectVarientTitle() {
    print("varient****${widget.model.type}");

    if (widget.model.type == "variable_product") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(
          selectVarient,
          style: Theme.of(context).textTheme.subtitle1.copyWith(color: primary),
        ),
      );
    } else {
      return Container();
    }
  }

  _getVarient(int pos) {
    if (widget.model.type == "variable_product") {
      List<String> attr_name =
          widget.model.prVarientList[pos].attr_name.split(',');
      List<String> attr_value =
          widget.model.prVarientList[pos].varient_value.split(',');
      String val = '';

      print("===========********${attr_value.toString()}****$attr_name");

      for (int i = 0; i < attr_name.length; i++) {
        print(
            '===========$attr_value****$attr_name*****${attr_value.length}====${attr_name[i]}');
        val = val + attr_value[i].length.toString() + " " + attr_name[i];
      }

      return Column(
        children: [
          ListTile(
            dense: true,
            title: Text(
              widget.model.prVarientList[pos].attr_name,
              style: TextStyle(color: lightBlack),
            ),
            trailing: IconButton(
              icon: Icon(Icons.keyboard_arrow_right),
              onPressed: _chooseVarient,
            ),
          ),
          widget.model.prVarientList[_selVarient].images.length > 0
              ? _smallImage()
              : Container(),
        ],
      );

/*
      return InkWell(
          child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: attr_name.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  title: Text(
                    attr_name[index] + " : " + attr_value[index],
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right),
                );
              }),
          onTap: _chooseVarient);*/
    } else {
      return Container();
    }
  }

  void _extraDetail() {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _desc(),
                widget.model.desc.isNotEmpty?Divider():Container(),
                _madeIn(),
                _otherDetail(_selVarient),
                _cancleable(),
              ],
            );
          });
        });
  }

  void _chooseVarient() {
    bool available = true;
    //selList--selected list
    //sinList---single list

    List<String> selList =
        widget.model.prVarientList[_selVarient].attribute_value_ids.split(",");

    for (int i = 0; i < widget.model.attributeList.length; i++) {
      List<String> sinList = widget.model.attributeList[i].id.split(',');

      print("$selList**$sinList");

      for (int j = 0; j < sinList.length; j++) {
        if (selList.contains(sinList[j])) {
          print("pos***$i**$j*${selList.toString()}=====${sinList[j]}");
          _selectedIndex.insert(i, j);
        }
      }
      if (_selectedIndex.length == i) _selectedIndex.insert(i, null);

      print("selected***${_selectedIndex.toString()}");
    }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    selectVarient,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Divider(),
                _title(),
                _price(_oldSelVarient),
                _offPrice(_oldSelVarient),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.model.attributeList.length,
                  itemBuilder: (context, index) {
                    List<Widget> chips = new List();
                    List<String> att =
                        widget.model.attributeList[index].value.split(',');
                    List<String> attId =
                        widget.model.attributeList[index].id.split(',');
                    int varSelected;

                    List<String> wholeAtt = widget.model.attrIds.split(',');

                    for (int i = 0; i < att.length; i++) {
                      //  print("whole===$wholeAtt===${attId[i]}");
                      if (wholeAtt.contains(attId[i])) {
                        choiceChip = ChoiceChip(
                          //  key: ValueKey<String>(att[i]),
                          selected: _selectedIndex.length > index
                              ? _selectedIndex[index] == i
                              : false,
                          label: Text(att[i], style: TextStyle(color: white)),
                          backgroundColor: primary.withOpacity(0.45),
                          selectedColor: primary,
                          disabledColor: primary.withOpacity(0.5),
                          onSelected: att.length == 1
                              ? null
                              : (bool selected) {
                                  setState(() {
                                    available = false;
                                    _selectedIndex[index] = selected ? i : null;
                                    List<int> selectedId =
                                        []; //list where user choosen item id is stored
                                    List<bool> check = [];
                                    for (int i = 0;
                                        i < widget.model.attributeList.length;
                                        i++) {
                                      List<String> attId = widget
                                          .model.attributeList[i].id
                                          .split(',');

                                      //print("valuae***$i**${_selectedIndex.toString()}***${attId.toString()}**${selectedId.toString()}**}");

                                      // print("${attId[_selectedIndex[i]]}");

                                      if (_selectedIndex[i] != null)
                                        selectedId.add(int.parse(
                                            attId[_selectedIndex[i]]));
                                    }
                                    check.clear();
                                    List<String> sinId;
                                    findMatch:
                                    for (int i = 0;
                                        i < widget.model.prVarientList.length;
                                        i++) {
                                      sinId = widget.model.prVarientList[i]
                                          .attribute_value_ids
                                          .split(",");

                                      print(
                                          'match****before****${selectedId.toString()}**${sinId.toString()}**${selectedId.length}***${sinId.length}');
                                      for (int j = 0;
                                          j < selectedId.length;
                                          j++) {
                                        if (sinId.contains(
                                            selectedId[j].toString())) {
                                          print(
                                              'match****${sinId.toString()}****${selectedId[j].toString()}');
                                          check.add(true);

                                          if (selectedId.length ==
                                                  sinId.length &&
                                              check.length ==
                                                  selectedId.length) {
                                            varSelected = i;
                                            break findMatch;
                                          }
                                        } else {
                                          print(
                                              'match****not match==braek**$j');
                                          break;
                                        }
                                      }
                                    }

                                    print(
                                        'match******size***${selectedId.length}***${sinId.length}***${check.length}');
                                    if (selectedId.length == sinId.length &&
                                        check.length == selectedId.length) {
                                      if (widget.model.stockType == "0" ||
                                          widget.model.stockType == "1") {
                                        if (widget.model.availability == "1") {
                                          available = true;

                                          print(
                                              "current varient selected==$varSelected");
                                          _oldSelVarient = varSelected;
                                        } else {
                                          available = false;
                                        }
                                      } else if (widget.model.stockType ==
                                          "null") {
                                        available = true;

                                        print(
                                            "current varient selected==$varSelected");
                                        _oldSelVarient = varSelected;
                                      } else if (widget.model.stockType ==
                                          "2") {
                                        print(
                                            "************${widget.model.name}*****${widget.model.prVarientList[varSelected].availability}*********${widget.model.availability}");
                                        if (widget
                                                .model
                                                .prVarientList[varSelected]
                                                .availability ==
                                            "1") {
                                          available = true;

                                          print(
                                              "current varient selected==$varSelected");
                                          _oldSelVarient = varSelected;
                                        } else {
                                          available = false;
                                        }
                                      }
                                    } else {
                                      available = false;
                                    }
                                  });
                                },
                        );

                        chips.add(Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: choiceChip));
                      }
                    }

                    return Column(
                      children: <Widget>[
                        chips.length > 0
                            ? Text(widget.model.attributeList[index].name)
                            : Container(),
                        new Wrap(
                          children: chips.map<Widget>((Widget chip) {
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: chip,
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
                available == false
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          "This varient doesn't available.",
                          style: TextStyle(color: Colors.red),
                        ),
                      ))
                    : Container(),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(right: 18.0, bottom: 8),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: RaisedButton(
                      color: primary,
                      onPressed: available ? applyVarient : null,
                      child: Text(
                        'Apply',
                        style: TextStyle(color: white),
                      ),
                    ),
                  ),
                )
              ],
            );
          });
        });
  }

  applyVarient() {
    Navigator.of(context).pop();
    setState(() {
      _selVarient = _oldSelVarient;
    });
  }

  Future<void> addToCart(bool intent) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        try {
          setState(() {
            _isProgress = true;
          });

          var parameter = {
            USER_ID: CUR_USERID,
            PRODUCT_VARIENT_ID: widget.model.prVarientList[_selVarient].id,
            QTY: (int.parse(widget.model.prVarientList[_selVarient].cartCount) +
                    1)
                .toString(),
          };

          print(
              'varient added***${widget.model.prVarientList[_selVarient].id}');
          Response response =
              await post(manageCartApi, body: parameter, headers: headers)
                  .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          print('response***cartadd**${response.body.toString()}***$headers');

          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];
            CUR_CART_COUNT = data['cart_count'];
            if (intent)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Cart(widget.updateHome, updateDetail),
                ),
              );
          } else {
            setSnackbar(msg);
          }
          setState(() {
            _isProgress = false;
          });

          widget.updateParent();
          widget.updateHome();
        } on TimeoutException catch (_) {
          setSnackbar(somethingMSg);
          setState(() {
            _isProgress = false;
          });
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  _ratingReview() {
    print("buy=======${widget.model.isPurchased}");
    return (widget.model.isPurchased == "true" || reviewList.length > 0)
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
            child: Text(
              'Ratings & Reviews',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: primary),
            ),
          )
        : Container();
  }

  _rating() {
    print("purchase==========${widget.model.isPurchased}");
    return widget.model.isPurchased == "true"
        ? Center(
            child: RatingBar.builder(
              initialRating: initialRate,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 32,
              itemPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                //print(rating);
                setRating(rating, "");
              },
            ),
          )
        : Container();
  }

  Future<void> getReview() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_ID: widget.model.id,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
        };

        Response response =
            await post(getRatingApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        print(
            'response***review**${widget.model.id}**${response.body.toString()}');

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          total = int.parse(getdata["total"]);

          if ((offset) < total) {
            var data = getdata["data"];
            reviewList =
                (data as List).map((data) => new User.forReview(data)).toList();

            offset = offset + perPage;
          }
        } else {
          if (msg != "No ratings found !") setSnackbar(msg);
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
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  _setFav() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          widget.model.isFavLoading = true;
        });

        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: widget.model.id};
        Response response =
            await post(setFavoriteApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print('response***setting**${response.body.toString()}');
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          widget.model.isFav = "1";
          widget.updateParent();

          //  home.updateHomepage();
        } else {
          setSnackbar(msg);
        }

        setState(() {
          widget.model.isFavLoading = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  _removeFav() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          widget.model.isFavLoading = true;
        });

        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: widget.model.id};
        Response response =
            await post(removeFavApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print('response***setting**${response.body.toString()}');
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          widget.model.isFav = "0";
          widget.updateParent();

          favList.removeWhere((item) =>
              item.productList[0].prVarientList[0].id ==
              widget.model.prVarientList[0].id);

          // home.updateHomepage();
        } else {
          setSnackbar(msg);
        }

        setState(() {
          widget.model.isFavLoading = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  _showContent() {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  elevation: 0,
                  margin: EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _slider(),
                      _title(),
                      _rate(),
                      _price(_selVarient),
                      _offPrice(_selVarient),
                      widget.model.type == "variable_product"
                          ? Divider()
                          : Container(),
                      _getVarient(_selVarient),
                      Divider(),
                      _specification(),
                      Divider(),
                      _discountCoupon(),
                    ],
                  ),
                ),

                reviewList.length > 0
                    ? Card(
                        elevation: 0,
                        margin:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _reviewTitle(),
                            //  _ratingReview(),

                            // _rating(),
                            _review(),
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  VIEW_ALL,
                                  style: TextStyle(color: primary),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RatingReview(id: widget.model.id)),
                                );
                              },
                            )
                          ],
                        ),
                      )
                    : Container(),

                // _writeReview()
              ],
            ),
          ),
        ),
        widget.model.availability == "1" || widget.model.stockType == "null"
            ? Row(
                children: [
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: white,
                      boxShadow: [BoxShadow(color: black26, blurRadius: 10)],
                    ),
                    width: deviceWidth * 0.5,
                    child: InkWell(
                      onTap: () {
                        addToCart(false);
                      },
                      child: Center(
                          child: Text(
                        ADD_CART,
                        style: Theme.of(context).textTheme.button.copyWith(
                            fontWeight: FontWeight.bold, color: primary),
                      )),
                    ),
                  ),
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [grad1Color, grad2Color],
                          stops: [0, 1]),
                      boxShadow: [BoxShadow(color: black26, blurRadius: 10)],
                    ),
                    width: deviceWidth * 0.5,
                    child: InkWell(
                      onTap: () {
                        addToCart(true);
                      },
                      child: Center(
                          child: Text(
                        BUYNOW,
                        style: Theme.of(context).textTheme.button.copyWith(
                            fontWeight: FontWeight.bold, color: white),
                      )),
                    ),
                  ),
                ],
              )
            : Container(
                height: 55,
                decoration: BoxDecoration(
                  color: white,
                  boxShadow: [BoxShadow(color: black26, blurRadius: 10)],
                ),
                child: Center(
                    child: Text(
                  OUT_OF_STOCK_LBL,
                  style: Theme.of(context)
                      .textTheme
                      .button
                      .copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                )),
              ),
      ],
    );
  }

  _madeIn() {
    String madeIn = widget.model.madein;
    return madeIn != null
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ListTile(
              trailing: Text(madeIn),
              dense: true,
              title: Text(
                'Made In',
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          )
        : Container();
  }

  Widget _review() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            itemCount: reviewList.length > 2 ? 2 : reviewList.length,
            physics: BouncingScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (context, index) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        reviewList[index].username,
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      Spacer(),
                      Text(
                        reviewList[index].date,
                        style: TextStyle(color: lightBlack, fontSize: 11),
                      )
                    ],
                  ),
                  RatingBarIndicator(
                    rating: double.parse(reviewList[index].rating),
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 12.0,
                    direction: Axis.horizontal,
                  ),
                  reviewList[index].comment != null
                      ? Text(reviewList[index].comment ?? '')
                      : Container(),
                ],
              );
            });
  }

  _writeReview() {
    return widget.model.isPurchased == "true" && _showComment
        ? Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentC,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onChanged: (String val) {
                    if (_commentC.text.trim().isNotEmpty) {
                      setState(() {
                        _isCommentEnable = true;
                      });
                    } else {
                      setState(() {
                        _isCommentEnable = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    prefixIcon: Icon(Icons.rate_review, color: primary),
                    hintText: 'Write your review..',
                    hintStyle: TextStyle(color: primary.withOpacity(0.5)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: white),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
                child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _isCommentEnable ? primary : Colors.transparent,
                    ),
                    onPressed: () => _isCommentEnable == true
                        ? setRating(0, _commentC.text)
                        : null),
              )
            ],
          )
        : Container();
  }

  _otherDetailsTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
      child: Text(
        'Other Details',
        style: Theme.of(context).textTheme.subtitle1.copyWith(color: primary),
      ),
    );
  }

  _otherDetail(int pos) {
    String returnable = widget.model.isReturnable;
    if (returnable == "1")
      returnable = RETURN_DAYS+" Days";
    else
      returnable = "No";
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        trailing: Text(returnable),
        dense: true,
        title: Text(
          'Returnable',
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ),
    );
  }

  _cancleable() {
    String cancleable = widget.model.isCancelable;
    if (cancleable == "1")
      cancleable ="Till "+ widget.model.cancleTill;
    else
      cancleable = "No";
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        trailing: Text(cancleable),
        dense: true,
        title: Text(
          'Cancellable',
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ),
    );
  }

/*  void _onLayoutDone(Duration timeStamp) {
    controller.animateTo(
      controller.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }*/

  void getAvailVarient() {
    if (widget.model.stockType == "2") {
      print("length***********$availVariant");
      for (int i = 0; i < widget.model.prVarientList.length; i++) {
        if (widget.model.prVarientList[i].availability == "1") {
          _selVarient = i;
          _oldSelVarient = i;
          break;
        }
      }
      setState(() {});
    }
  }

  _specification() {
    return ListTile(
      dense: true,
      title: Text(
        SPECIFICATION,
        style: TextStyle(color: lightBlack),
      ),
      trailing: IconButton(
        icon: Icon(Icons.keyboard_arrow_right),
        onPressed: _extraDetail,
      ),
    );
  }

  _discountCoupon() {
    return ListTile(
      dense: true,
      title: Text(
        DISCOUPON,
        style: TextStyle(color: lightBlack),
      ),
      trailing: IconButton(
        icon: Icon(Icons.keyboard_arrow_right),
        onPressed: () {},
      ),
      subtitle: Text(
        COMINGSOON,
        style: TextStyle(color: primary),
      ),
    );
  }

  _reviewTitle() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: Row(
          children: [
            Text(
              CUSTOMER_REVIEW_LBL + " ($total)",
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(color: lightBlack, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Text(
              widget.model.rating + "/5 ",
              style: Theme.of(context).textTheme.caption,
            ),
            RatingBarIndicator(
              rating: double.parse(widget.model.rating),
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 12.0,
              direction: Axis.horizontal,
            ),
          ],
        ));
  }
}

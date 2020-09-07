import 'dart:async';
import 'dart:convert';

import 'package:app_review/app_review.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/All_Category.dart';
import 'package:eshop/Favorite.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Model.dart';
import 'package:eshop/Helper/Section_Model.dart';
import 'package:eshop/Privacy_Policy.dart';
import 'package:eshop/Product_Detail.dart';
import 'package:eshop/SectionList.dart';
import 'package:eshop/Sub_Category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:share/share.dart';

import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'NotificationLIst.dart';
import 'Profile.dart';
import 'Search.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateHome();
  }
}

List<Model> catList = [];

class StateHome extends State<Home> {
  bool _isSliderLoading = true, _isCatLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Model> sliderList = [];

  List<Section_Model> sectionList = [];
  final _controller = PageController();
  int _curSlider = 0;
  String _profile;

  @override
  void initState() {
    super.initState();
    callApi();
    WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = width / 2;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
        extendBodyBehindAppBar: true,
        key: _scaffoldKey,
        appBar: _getAppbar(),
        drawer: _getDrawer(),
        bottomNavigationBar: getBottomBar(),
        body: Stack(
          children: <Widget>[
            Image.asset('assets/images/topimage.png'),
            Container(
              margin: EdgeInsets.only(
                  left: 20.0, right: 20, top: kToolbarHeight + statusBarHeight),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _getSearchBar(height),
                    _slider(),
                    _catHeading(),
                    _catList(),
                    _section()
                  ],
                ),
              ),
            )
          ],
        ));
  }

  _slider() {
    double width = MediaQuery.of(context).size.width;
    double height = width / 2;

    return sliderList.isNotEmpty
        ? Container(
            height: height,
            width: double.infinity,
            padding: EdgeInsets.only(bottom: 5, top: 10),
            child: PageView.builder(
              itemCount: sliderList.length,
              scrollDirection: Axis.horizontal,
              controller: _controller,
              reverse: false,
              onPageChanged: (index) {
                setState(() {
                  _curSlider = index;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: CachedNetworkImage(
                            imageUrl: sliderList[_curSlider].image,
                            placeholder: (context, url) => Image.asset(
                              "assets/images/sliderph.png",
                              height: height,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/images/sliderph.png",
                              height: height,
                            ),
                            fit: BoxFit.fill,
                            height: height,
                            width: double.maxFinite,
                          )),
                      Positioned(
                        bottom: 0,
                        height: 40,
                        left: 0,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: map<Widget>(
                            sliderList,
                            (index, url) {
                              return Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _curSlider == index
                                        ? primary
                                        : primary.withOpacity((0.2)),
                                  ));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {},
                );
              },
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 27),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              child: Image.asset(
                'assets/images/sliderph.png',
                height: height,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  void _animateSlider() {
    Future.delayed(Duration(seconds: 10)).then((_) {
      int nextPage = _controller.page.round() + 1;

      if (nextPage == sliderList.length) {
        nextPage = 0;
      }

      _controller
          .animateToPage(nextPage,
              duration: Duration(seconds: 1), curve: Curves.easeIn)
          .then((_) => _animateSlider());
    });
  }

  Future<void> getSlider() async {
    try {
      Response response = await post(getSliderApi, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print('response***slider**${response.body.toString()}***$headers');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        sliderList =
            (data as List).map((data) => new Model.fromJson(data)).toList();
      } else {
        setSnackbar(msg);
      }
      setState(() {
        _isSliderLoading = false;
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isSliderLoading = false;
      });
    }
  }

  Future<void> getCat() async {
    try {
      Response response = await post(getCatApi, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print('response***cat**$headers****${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        catList = (data as List).map((data) => new Model.fromCat(data)).toList();


      } else {
        setSnackbar(msg);
      }
      setState(() {
        _isCatLoading = false;
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isCatLoading = false;
      });
    }
  }

  Future<void> getSection() async {
    try {
      Response response = await post(getSectionApi, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print('response***sec**$headers***${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        sectionList = (data as List)
            .map((data) => new Section_Model.fromJson(data))
            .toList();
      } else {
        setSnackbar(msg);
      }
      setState(() {
        _isCatLoading = false;
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isCatLoading = false;
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

  Future<void> callApi() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getSlider();
      getCat();
      getSection();
      getSetting();
    } else {
      setSnackbar(internetMsg);
      setState(() {
        _isCatLoading = false;
      });
    }
  }

  _getDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0),
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          _getHeader(),
          _getDrawerItem(RATE_APP, Icons.star),
          _getDivider(),
          _getDrawerItem(SHARE_APP, Icons.share),
          _getDivider(),
          _getDrawerItem(PRIVACY, Icons.lock),
          _getDivider(),
          _getDrawerItem(TERM, Icons.speaker_notes),
          _getDivider(),
          _getDrawerItem(CONTACT, Icons.info),
        ],
      ),
    );
  }

  _getDivider() {
    return Divider(
      color: Colors.grey,
      height: 1,
    );
  }

  _getDrawerItem(String title, IconData icn) {
    return ListTile(
      leading: Icon(
        icn,
        color: primary,
      ),
      title: Text(
        title,
        style: TextStyle(color: primary),
      ),
      trailing: Icon(
        Icons.keyboard_arrow_right,
        color: primary,
      ),
      onTap: () {
        if (title == SHARE_APP) {
          var str =
              "$appName\n\nYou can find our app from below url\n\nAndroid:\n$androidLink$packageName\n\n iOS:\n$iosLink$iosPackage";
          Share.share(str);
        } else if (title == RATE_APP) {
          AppReview.requestReview.then((onValue) {});
        } else if (title == PRIVACY) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Privacy_Policy(
                  title: PRIVACY,
                ),
              ));
        }
        else if (title == TERM) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Privacy_Policy(
                  title: TERM,
                ),
              ));
        }
        else if (title == CONTACT) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Privacy_Policy(
                  title: CONTACT,
                ),
              ));
        }
      },
    );
  }

  _getAppbar() {
    double width = MediaQuery.of(context).size.width;
    double height = width / 2;
    return AppBar(
      title: Image.asset('assets/images/titleicon.png'),
      centerTitle: true,
      actions: <Widget>[
        Image.asset(
          'assets/images/noti_cart.png',
          width: 40,
        ),
        Image.asset(
          'assets/images/profile.png',
          width: 40,
        )
      ],
      /* flexibleSpace: Image(
        image: AssetImage('assets/images/topimage.png'),
        fit: BoxFit.cover,
      ),*/
      backgroundColor: Colors.transparent,
      elevation: 0,
      /* bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0 + height),
          //child:_getSearchBar(height)
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              _getSearchBar(height),
              _slider(),
            ],
          )),*/
    );
  }

  _getSearchBar(double height) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return InkWell(
      child: SizedBox(
          height: 35, // set this
          child: TextField(
            enabled: false,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(5.0),
                  ),
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                isDense: true,
                hintText: searchHint,
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Colors.white70),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                fillColor: Colors.white30,
                filled: true),
          )),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Search(),
            ));
      },
    );
  }

  _catHeading() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            category,
            style: Theme.of(context).textTheme.headline6,
          ),
          InkWell(
            child: Text(
              seeAll,
              style: Theme.of(context).textTheme.caption,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => All_Category()),
              );
            },
          ),
        ],
      ),
    );
  }

  _catList() {
    return Container(
      height: 90,
      child: ListView.builder(
        itemCount: catList.length < 10 ? catList.length : 10,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: new ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: new CachedNetworkImage(
                        imageUrl: catList[index].image,
                        height: 50.0,
                        width: 50.0,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => placeHolder(50),
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      catList[index].name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    width: 50,
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Sub_Category(
                      title: catList[index].name,
                      id: catList[index].id,
                    ),
                  ));
            },
          );
        },
      ),
    );
  }

  _section() {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: sectionList.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _singleSection(index);
      },
    );
  }

  _singleSection(int index) {
    return sectionList[index].productList.length > 0
        ? Stack(
            children: <Widget>[
              _getHeading(sectionList[index].title, index),
              _getSection(index),
            ],
          )
        : Container();
  }

  _getHeading(String title, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.headline6,
          ),
          InkWell(
            child: Text(
              seeAll,
              style: Theme.of(context).textTheme.caption,
            ),
            splashColor: primary.withOpacity(0.2),
            onTap: () {
              Section_Model model = sectionList[index];
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SectionList(
                      title: title,
                      section_model: model,
                    ),
                  ));
            },
          )
        ],
      ),
    );
  }

  _getSection(int i) {
    return GridView.count(
        padding: EdgeInsets.only(top: 50),
        crossAxisCount: 2,
        shrinkWrap: true,
        childAspectRatio: 1.25,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 5,
        children: List.generate(
          sectionList[i].productList.length < 4
              ? sectionList[i].productList.length
              : 4,
          (index) {
            return productItem(i, index);
          },
        ));
  }

  productItem(int secPos, int index) {
    double width = MediaQuery.of(context).size.width * 0.5 - 20;
    //double height = MediaQuery.of(context).size.width * 0.5 - 20;
    // print("length****${sectionList[secPos].productList[index].name}***${sectionList[secPos].productList[index].prVarientList.length}");
    return Card(
      child: InkWell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: sectionList[secPos].productList[index].image,
                    height: double.maxFinite,
                    width: double.maxFinite,
                    fit: BoxFit.fill,
                    placeholder: (context, url) => placeHolder(width),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      sectionList[secPos].productList[index].name,
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.favorite_border,
                    size: 15,
                  )
                  // IconButton(icon: Icon(Icons.favorite_border,),iconSize: 10, onPressed: null)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, bottom: 5),
              child: Row(
                children: <Widget>[
                  Text(
                    CUR_CURRENCY +
                        "" +
                        sectionList[secPos]
                            .productList[index]
                            .prVarientList[0]
                            .price,
                    style: Theme.of(context).textTheme.overline.copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                  ),
                  Text(
                      " " +
                          CUR_CURRENCY +
                          "" +
                          sectionList[secPos]
                              .productList[index]
                              .prVarientList[0]
                              .disPrice,
                      style: TextStyle(color: primary)),
                ],
              ),
            )
          ],
        ),
        onTap: () {
          Product model = sectionList[secPos].productList[index];
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Product_Detail(
                      model: model,
                      title: sectionList[secPos].title,
                    )),
          );
        },
      ),
    );
  }

  Future<void> getSetting() async {
    try {
      var parameter = {TYPE: CURRENCY};
      Response response =
          await post(getSettingApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print('response***setting**$headers***${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        CUR_CURRENCY = data;
        /*  sectionList = (data as List)
            .map((data) => new Section_Model.fromJson(data))
            .toList();*/
      } else {
        setSnackbar(msg);
      }
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }

  getBottomBar() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 15,
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(25.0),
              topRight: const Radius.circular(25.0),
            )),
        child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            child: BottomAppBar(
                child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image.asset(
                  "assets/images/home.png",
                ),
                InkWell(
                  child: Image.asset(
                    "assets/images/fav.png",
                  ),
                  splashColor: primary.withOpacity(0.8),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Favorite(),
                        ));
                  },
                ),
                InkWell(
                  child: Image.asset(
                    "assets/images/notification.png",
                  ),
                  splashColor: primary.withOpacity(0.8),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationList(),
                        ));
                  },
                ),
                InkWell(
                  child: Image.asset(
                    "assets/images/user.png",
                  ),
                  splashColor: primary.withOpacity(0.8),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Profile(),
                        ));
                  },
                ),
              ],
            ))),
      ),
    );
  }

  _getHeader() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/dra_back.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: InkWell(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            margin: EdgeInsets.all(25),
            height: 64,
            width: 64,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1.0, color: Colors.white)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: _profile != null
                  ? CachedNetworkImage(
                      imageUrl: _profile,
                      height: 64,
                      width: 64,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return new Container(
                          child: Icon(
                            Icons.account_circle,
                            color: Colors.grey,
                            size: 64,
                          ),
                        );
                      })
                  : imagePlaceHolder(64),
            ),
          ),
        ),
        onTap: () {
          /*                  Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profile(),
            )).then((value) async {
          debugPrint(value);
          _profile = await getPrefrence(PROFILE);
          print('on rsume***$_profile');
          setState(()  {

          });
        });*/
        },
      ),
    );
  }
}

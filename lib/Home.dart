import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math' as math;
import 'package:app_review/app_review.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/All_Category.dart';
import 'package:eshop/Favorite.dart';
import 'package:eshop/Helper/Color.dart';

import 'package:eshop/Privacy_Policy.dart';
import 'package:eshop/Product_Detail.dart';
import 'package:eshop/SectionList.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:like_button/like_button.dart';
import 'package:share/share.dart';
import 'package:eshop/ProductList.dart';
import 'Cart.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Login.dart';
import 'Logout.dart';
import 'Model/Model.dart';
import 'Model/Section_Model.dart';
import 'NotificationLIst.dart';
import 'Profile.dart';
import 'Search.dart';
import 'SubCat.dart';
import 'Track_Order.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateHome();
  }
}

List<Model> catList = [];
List<Model> sliderList = [];
List<Section_Model> sectionList = [];
final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
bool _isCatLoading = true;

class StateHome extends State<Home> {
  List<Widget> fragments;
  int _curSelected = 0;
  HomePage home;

  @override
  void initState() {
    super.initState();

    getUserData();
    home = new HomePage(updateHome);
    fragments = [
      HomePage(updateHome),
      Favorite(updateHome),
      NotificationList(),
      NotificationList()
    ];
  }

  updateHome() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: _getAppbar(),
        drawer: _getDrawer(),
        extendBodyBehindAppBar: true,
        bottomNavigationBar: getBottomBar(),
        body: fragments[_curSelected]);
  }

  Future<void> getUserData() async {
    CUR_USERID = await getPrefrence(ID);
    if (CUR_USERID != null)
      try {
        var parameter = {TYPE: USERDATA, USER_ID: CUR_USERID};
        Response response =
            await post(getSettingApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print('response***setting**$headers***${response.body.toString()}');
        bool error = getdata["error"];
        if (!error) {
          var data = getdata["data"][0];
          setState(() {
            print("cart count******$data");
            CUR_CART_COUNT = (data['cart_total_items']).toString();
            CUR_BALANCE = data["balance"];
          });
        }
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
      }
  }

  setSnackbar(String msg) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 1.0,
    ));
  }

  _getDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0),
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          _getHeader(),
          _getDrawerItem(HOME_LBL, Icons.home),
          _getDivider(),
          _getDrawerItem(CART, Icons.add_shopping_cart),
          _getDivider(),
          _getDrawerItem(TRACK_ORDER, Icons.shopping_cart),
          _getDivider(),
          _getDrawerItem(PROFILE, Icons.person),
          _getDivider(),
          _getDrawerItem(FAVORITE, Icons.favorite),
          _getDivider(),
          _getDrawerItem(NOTIFICATION, Icons.notifications),
          _getDivider(),
          _getDrawerItem(SETTING, Icons.settings),
          _getDivider(),
          _getDrawerItem(RATE_APP, Icons.star),
          _getDivider(),
          _getDrawerItem(SHARE_APP, Icons.share),
          _getDivider(),
          _getDrawerItem(PRIVACY, Icons.lock),
          _getDivider(),
          _getDrawerItem(TERM, Icons.speaker_notes),
          _getDivider(),
          _getDrawerItem(CONTACT, Icons.info),
          _getDivider(),
          _getDrawerItem(LOGOUT, Icons.input),
          _getDivider(),
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
        Navigator.of(context).pop();
        if (title == HOME_LBL) {
          setState(() {
            _curSelected = 0;
          });
        } else if (title == CART) {
          CUR_USERID == null
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ))
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cart(this.updateHome),
                  ));
        } else if (title == TRACK_ORDER) {
          CUR_USERID == null
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ))
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackOrder(),
                  ));
        } else if (title == PROFILE) {
          CUR_USERID == null
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ))
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(),
                  ));
        } else if (title == FAVORITE) {
          setState(() {
            _curSelected = 1;
          });
        } else if (title == NOTIFICATION) {
          setState(() {
            _curSelected = 2;
          });
        } else if (title == SHARE_APP) {
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
        } else if (title == TERM) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Privacy_Policy(
                  title: TERM,
                ),
              ));
        } else if (title == CONTACT) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Privacy_Policy(
                  title: TERM,
                ),
              ));
        } else if (title == LOGOUT) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Logout(
                  title: LOGOUT,
                ),
              ));
        }
      },
    );
  }

  _getAppbar() {
    double width = MediaQuery.of(context).size.width;
    double height = width / 2;

    print("cart count***$CUR_CART_COUNT");
    return AppBar(
      title: Image.asset('assets/images/titleicon.png'),
      centerTitle: true,
      actions: <Widget>[
        InkWell(
          child: new Stack(children: <Widget>[
            Center(
              child: Image.asset(
                'assets/images/noti_cart.png',
                width: 40,
              ),
            ),
            (CUR_CART_COUNT != null &&
                    CUR_CART_COUNT.isNotEmpty &&
                    CUR_CART_COUNT != "0")
                ? new Positioned(
                    top: 0.0,
                    right: 5.0,
                    bottom: 15,
                    child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.red),
                        child: new Center(
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child: new Text(
                              CUR_CART_COUNT,
                              style: TextStyle(fontSize: 8),
                            ),
                          ),
                        )),
                  )
                : Container()
          ]),
          onTap: () async {
            CUR_USERID == null
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ))
                : goToCart();
          },
        ),
        InkWell(
          child: Image.asset(
            'assets/images/profile.png',
            width: 40,
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(),
                ));
          },
        )
      ],
      backgroundColor: Colors.transparent,
      flexibleSpace: _curSelected != 0
          ? Image(
              image: AssetImage('assets/images/halftopimage.png'),
              fit: BoxFit.cover,
            )
          : Container(),
      elevation: 0,
    );
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
              child: BottomNavigationBar(
                showSelectedLabels: false,
                showUnselectedLabels: false,
                currentIndex: _curSelected,

                type: BottomNavigationBarType.fixed,
                onTap: (int index) {
                  print("current=====$index");
                  setState(() {
                    _curSelected = index;
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    label: '',
                    icon: Image.asset(
                      "assets/images/desel_home.png",
                    ),
                    activeIcon: Image.asset(
                      "assets/images/sel_home.png",
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: '',
                    icon: Image.asset(
                      "assets/images/desel_fav.png",
                    ),
                    activeIcon: Image.asset(
                      "assets/images/sel_fav.png",
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: '',
                    icon: Image.asset(
                      "assets/images/desel_notification.png",
                    ),
                    activeIcon: Image.asset(
                      "assets/images/sel_notification.png",
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: '',
                    icon: Image.asset(
                      "assets/images/desel_user.png",
                    ),
                    activeIcon: Image.asset(
                      "assets/images/sel_user.png",
                    ),
                  ),
                ],

                /*       Image.asset(
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
                ),*/
                //]         ))),,
              ))),
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
      padding: EdgeInsets.only(top: 24),
      child: InkWell(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            margin: EdgeInsets.all(35),
            child: Image.asset('assets/images/titleicon.png'),
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

  goToCart() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Cart(updateHome),
        )).then((val) => home.updateHomepage());
    //  if (nav == true || nav == null) home.updateHomepage();
  }
}

class HomePage extends StatefulWidget {
  Function updateHome;

  HomePage(this.updateHome);

  StateHomePage statehome = new StateHomePage();

  @override
  StateHomePage createState() => StateHomePage();

  updateHomepage() {
    statehome.getSection();
  }
}

class StateHomePage extends State<HomePage> {
  final _controller = PageController();
  int _curSlider = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool useMobileLayout;

  @override
  void initState() {
    super.initState();
    callApi();
    WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
  }

  updateHomePage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    useMobileLayout = shortestSide < 600;
    return _home();
  }

  Widget _home() {
    double width = MediaQuery.of(context).size.width;
    double height = width / 2;
    double appBarHeight = height + 50;

    return Scaffold(
        key: _scaffoldKey,
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                expandedHeight: appBarHeight,
                floating: false,
                collapsedHeight: kToolbarHeight + 1,
                actionsIconTheme: IconThemeData(opacity: 0.0),
                flexibleSpace: Stack(
                  children: <Widget>[
                    Image.asset(
                      'assets/images/topimage.png',
                      width: width,
                      fit: BoxFit.fitWidth,
                    ),
                    _getSearchBar(),
                    _slider(),
                  ],
                )),

            /*     LayoutBuilder(builder: (context, constraints) {
                  final expandRatio = _calculateExpandRatio(constraints,minHeight,appBarHeight);
                  final animation = AlwaysStoppedAnimation(expandRatio);

                  return Stack(
                    children: <Widget>[
                      Image.asset(
                        'assets/images/topimage.png',
                        width: width,
                        fit: BoxFit.fitWidth,
                      ),
                      Align(
                          alignment: AlignmentTween(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.bottomLeft)
                              .evaluate(animation),
                          child: Column(
                            children: [
                              _getSearchBar(),
                              _slider(),
                            ],
                          )),
                    ],
                  );
                })),*/
            SliverList(
                delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: <Widget>[
                    _isCatLoading
                        ? Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: getProgress(),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [_catHeading(), _catList(), _section()],
                          ),
                  ],
                ),
              )
            ]))
          ],
        ));
  }

  double _calculateExpandRatio(
      BoxConstraints constraints, double minHeight, double maxHeight) {
    var expandRatio =
        (constraints.maxHeight - minHeight) / (maxHeight - minHeight);
    if (expandRatio > 1.0) expandRatio = 1.0;
    if (expandRatio < 0.0) expandRatio = 0.0;
    return expandRatio;
  }

  Widget _slider() {
    double width = MediaQuery.of(context).size.width;
    double height = width / 2;

    return sliderList.isNotEmpty
        ? Container(
            height: height,
            width: double.infinity,
            margin: EdgeInsets.only(
                bottom: 5, top: kToolbarHeight * 1.7 + 50, right: 20, left: 20),
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
    Future.delayed(Duration(seconds: 30)).then((_) {
      if (mounted) {
        int nextPage = _controller.hasClients
            ? _controller.page.round() + 1
            : _controller.initialPage;

        if (nextPage == sliderList.length) {
          nextPage = 0;
        }
        if (_controller.hasClients)
          _controller
              .animateToPage(nextPage,
                  duration: Duration(seconds: 1), curve: Curves.easeIn)
              .then((_) => _animateSlider());
      }
    });
  }

  _getSearchBar() {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(
            top: kToolbarHeight * 1.7, right: 20, left: 20),
        child: SizedBox(
          height: 35,
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
          ),
        ),
      ),
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Search(widget.updateHome),
            ));
        setState(() {});
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                seeAll,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => All_Category(
                          updateHome: widget.updateHome,
                        )),
              );
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  _catList() {
    return Container(
      height: 100,
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
            onTap: () async {
              if (catList[index].subList == null ||
                  catList[index].subList.length == 0) {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductList(
                          name: catList[index].name,
                          id: catList[index].id,
                          updateHome: widget.updateHome),
                    ));
                setState(() {});
              } else {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubCat(
                          title: catList[index].name,
                          subList: catList[index].subList,
                          updateHome: widget.updateHome),
                    ));
                setState(() {});
              }
            },
          );
        },
      ),
    );
  }

  _section() {
    return _isCatLoading
        ? getProgress()
        : ListView.builder(
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
        ? Column(
            mainAxisSize: MainAxisSize.min,
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
                      index: index,
                      section_model: model,
                      updateHome: updateHomePage,
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
        padding: EdgeInsets.only(top: 5),
        crossAxisCount: 2,
        shrinkWrap: true,
        childAspectRatio: 1.1,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 7,
        crossAxisSpacing: 1,
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
    double price = double.parse(
        sectionList[secPos].productList[index].prVarientList[0].disPrice);
    if (price == 0)
      price = double.parse(
          sectionList[secPos].productList[index].prVarientList[0].price);

    double width = MediaQuery.of(context).size.width * 0.5 - 20;


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
                  ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      child: Hero(
                        transitionOnUserGestures: true,
                        tag: "homeSection-$secPos$index",
                        child: CachedNetworkImage(
                          imageUrl:
                              sectionList[secPos].productList[index].image,
                          height: double.maxFinite,
                          width: double.maxFinite,
                          //fit: BoxFit.fill,
                          placeholder: (context, url) => placeHolder(width),
                        ),
                      )),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 10,
                          ),
                          Text(
                            sectionList[secPos].productList[index].rating,
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
                          .overline
                          .copyWith(color: Colors.black, letterSpacing: 0.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  sectionList[secPos].productList[index].isFavLoading
                      ? Container(
                          height: 10,
                          width: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 0.7,
                          ))
                      : InkWell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 3),
                            child: Icon(
                              sectionList[secPos].productList[index].isFav ==
                                      "0"
                                  ? Icons.favorite_border
                                  : Icons.favorite,
                              size: 15,
                              color: primary,
                            ),
                          ),
                          onTap: () {
                            if (CUR_USERID != null) {
                              sectionList[secPos].productList[index].isFav ==
                                      "0"
                                  ? _setFav(secPos, index)
                                  : _removeFav(secPos, index);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                              );
                            }
                          })
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, bottom: 5),
              child: Row(
                children: <Widget>[
                  Text(
                    int.parse(sectionList[secPos]
                                .productList[index]
                                .prVarientList[0]
                                .disPrice) !=
                            0
                        ? CUR_CURRENCY +
                            "" +
                            sectionList[secPos]
                                .productList[index]
                                .prVarientList[0]
                                .price
                        : "",
                    style: Theme.of(context).textTheme.overline.copyWith(
                        decoration: TextDecoration.lineThrough,
                        letterSpacing: 1),
                  ),
                  Text(" " + CUR_CURRENCY + " " + price.toString(),
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
            PageRouteBuilder(
                transitionDuration: Duration(seconds: 1),
                pageBuilder: (_, __, ___) => Product_Detail(
                      model: model,
                      updateParent: updateHomePage,
                      secPos: secPos,
                      index: index,
                      updateHome: widget.updateHome,
                      //  title: sectionList[secPos].title,
                    )),
          );
        },
      ),
    );
  }

  _setFav(int secPos, int index) async {
    try {
      setState(() {
        sectionList[secPos].productList[index].isFavLoading = true;
      });

      var parameter = {
        USER_ID: CUR_USERID,
        PRODUCT_ID: sectionList[secPos].productList[index].id
      };
      Response response =
          await post(setFavoriteApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));


      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        sectionList[secPos].productList[index].isFav = "1";
      } else {
        setSnackbar(msg);
      }

      setState(() {
        sectionList[secPos].productList[index].isFavLoading = false;
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
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

  _removeFav(int secPos, int index) async {
    try {
      setState(() {
        sectionList[secPos].productList[index].isFavLoading = true;
      });

      var parameter = {
        USER_ID: CUR_USERID,
        PRODUCT_ID: sectionList[secPos].productList[index].id
      };
      Response response =
          await post(removeFavApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        sectionList[secPos].productList[index].isFav = "0";

        favList.removeWhere((item) =>
            item.productList[0].prVarientList[0].id ==
            sectionList[secPos].productList[index].prVarientList[0].id);
      } else {
        setSnackbar(msg);
      }

      setState(() {
        sectionList[secPos].productList[index].isFavLoading = false;
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
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
      if (mounted)
        setState(() {
          _isCatLoading = false;
        });
    }
  }

  Future<void> getSlider() async {
    try {
      Response response = await post(getSliderApi, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);


      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        sliderList =
            (data as List).map((data) => new Model.fromJson(data)).toList();
      } else {
        setSnackbar(msg);
      }
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }

  Future<void> getCat() async {
    try {
      var parameter = {
        CAT_FILTER: "false",
      };
      Response response =
          await post(getCatApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        catList =
            (data as List).map((data) => new Model.fromCat(data)).toList();
      } else {
        setSnackbar(msg);
      }
      if (mounted)
        setState(() {
          _isCatLoading = false;
        });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      if (mounted)
        setState(() {
          _isCatLoading = false;
        });
    }
  }

  Future<void> getSection() async {
    try {
      var parameter = {PRODUCT_LIMIT: "4", PRODUCT_OFFSET: "0"};

      if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
      Response response =
          await post(getSectionApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);


      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        sectionList.clear();
        sectionList = (data as List)
            .map((data) => new Section_Model.fromJson(data))
            .toList();
      } else {
        setSnackbar(msg);
      }

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isCatLoading = false;
        });
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isCatLoading = false;
      });
    }
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
      } else {
        setSnackbar(msg);
      }
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }
}

class Header extends StatelessWidget {
  final double maxHeight;
  final double minHeight;

  const Header({Key key, this.maxHeight, this.minHeight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),
            //  _buildGradient(animation),
            //  _buildTitle(animation),
          ],
        );
      },
    );
  }

  Image _buildImage() {
    return Image.network(
      "https://www.rollingstone.com/wp-content/uploads/2020/02/TheWeeknd.jpg",
      fit: BoxFit.cover,
    );
  }
}

class _MyAppSpace extends StatelessWidget {
  const _MyAppSpace({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
        final deltaExtent = settings.maxExtent - settings.minExtent;
        final t =
            (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
                .clamp(0.0, 1.0) as double;
        final fadeStart = math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
        const fadeEnd = 1.0;
        final opacity = 1.0 - Interval(fadeStart, fadeEnd).transform(t);

        return Stack(
          children: [
            Image.asset(
              'assets/images/topimage.png',
              fit: BoxFit.fitWidth,
            ),
            Center(
              child: Opacity(
                  opacity: 1 - opacity,
                  child: Text(
                    'Collapsed Title',
                  )),
            ),
            Opacity(
              opacity: opacity,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  _getSearchBar(context),
                  Text(
                    'expanded Title',
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _getSearchBar(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(
            top: kToolbarHeight * 1.5, right: 20, left: 20),
        child: SizedBox(
          height: 35,
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
          ),
        ),
      ),
      onTap: () async {
        /*     await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Search(widget.updateHome),
            ));
        setState(() {});*/
      },
    );
  }
}

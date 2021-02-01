import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eshop/All_Category.dart';
import 'package:eshop/Favorite.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/PushNotificationService.dart';
import 'package:eshop/MyProfile.dart';
import 'package:eshop/ProductList.dart';
import 'package:eshop/Product_Detail.dart';
import 'package:eshop/SectionList.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:shimmer/shimmer.dart';

import 'Cart.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Login.dart';
import 'Model/Model.dart';
import 'Model/Section_Model.dart';
import 'NotificationLIst.dart';
import 'Search.dart';
import 'SubCat.dart';
import 'main.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateHome();
  }
}

List<Product> catList = [];
List<Model> homeSliderList = [];
List<Section_Model> sectionList = [];
List<Model> offerImages = [];
List<Widget> pages = [];
bool _isCatLoading = true;
bool _isNetworkAvail = true;
int curSelected = 0;
GlobalKey bottomNavigationKey = GlobalKey();

class StateHome extends State<Home> {
  List<Widget> fragments;
  DateTime currentBackPressTime;
  HomePage home;
  String profile;
  int curDrwSel = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  var isDarkTheme;

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
    home = new HomePage(updateHome);
    fragments = [
      HomePage(updateHome),
      Favorite(updateHome),
      NotificationList(),
      MyProfile(updateHome),
    ];

    firNotificationInitialize();
  }

  updateHome() {
     if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
            key: scaffoldKey,
            appBar: curSelected == 3 ? null : _getAppbar(),
            // drawer: _getDrawer(),
            bottomNavigationBar: getBottomBar(),
            body: fragments[curSelected]));
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (curSelected != 0) {
      curSelected = 0;
      final CurvedNavigationBarState navBarState =
          bottomNavigationKey.currentState;
      navBarState.setPage(0);

      return Future.value(false);
    } else if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      setSnackbar(getTranslated(context, 'EXIT_WR'));

      return Future.value(false);
    }
    return Future.value(true);
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

  _getAppbar() {
    String title = curSelected == 1
        ? getTranslated(context, 'FAVORITE')
        : getTranslated(context, 'NOTIFICATION');

    return AppBar(
      title: curSelected == 0
          ? Image.asset('assets/images/titleicon.png')
          : Text(
              title,
              style: TextStyle(
                color: colors.fontColor,
              ),
            ),
      iconTheme: new IconThemeData(color: colors.primary),
      // centerTitle:_curSelected == 0? false:true,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 10, end: 10),
          child: Container(
            decoration: shadow(),
            child: Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  CUR_USERID == null
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ))
                      : goToCart();
                },
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
                                  color: colors.primary.withOpacity(0.5)),
                              child: new Center(
                                child: Padding(
                                  padding: EdgeInsets.all(3),
                                  child: new Text(
                                    CUR_CART_COUNT,
                                    style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                        )
                      : Container()
                ]),
              ),
            ),
          ),
        ),
      ],
      backgroundColor: curSelected == 0 ? Colors.transparent : colors.white,
      elevation: 0,
    );
  }

  getBottomBar() {
    isDarkTheme = Theme.of(context).brightness == Brightness.dark;
     return CurvedNavigationBar(
        key: bottomNavigationKey,
        backgroundColor: isDarkTheme ? colors.darkColor : colors.lightWhite,
        color: isDarkTheme ? colors.darkColor2 : colors.white,
        height: 65,
        items: <Widget>[
          curSelected == 0
              ? Image.asset(
                  "assets/images/sel_home.png",
                  height: 35,
                )
              : Image.asset(
                  "assets/images/desel_home.png",
                ),
          curSelected == 1
              ? Image.asset(
                  "assets/images/sel_fav.png",
                  height: 35,
                )
              : Image.asset(
                  "assets/images/desel_fav.png",
                ),
          curSelected == 2
              ? Image.asset(
                  "assets/images/sel_notification.png",
                  height: 35,
                )
              : Image.asset(
                  "assets/images/desel_notification.png",
                ),
          curSelected == 3
              ? Image.asset(
                  "assets/images/sel_user.png",
                  height: 35,
                )
              : Image.asset(
                  "assets/images/desel_user.png",
                )
        ],
        onTap: (int index) {
           if (mounted) setState(() {
            curSelected = index;
          });
        });
  }

  goToCart() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Cart(updateHome, null),
        )).then((val) => home.updateHomepage());
  }

  void firNotificationInitialize() {
    //for firebase push notification
    FlutterLocalNotificationsPlugin();
// initialise the plugin. ic_launcher needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);

    PushNotificationService.flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) {
    return showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyApp(),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Future onSelectNotification(String payload) {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }

    List<String> pay=payload.split(",");
    if (pay[0] == "products") {
      getProduct(pay[1], 0, 0, true);
    }
    else if(pay[0]=="categories")
      {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AllCategory()),
        );
      }
    else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    }
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        if (deepLink.queryParameters.length > 0) {
          int index = int.parse(deepLink.queryParameters['index']);

          int secPos = int.parse(deepLink.queryParameters['secPos']);

          String id = deepLink.queryParameters['id'];

          String list = deepLink.queryParameters['list'];

          getProduct(id, index, secPos, list == "true" ? true : false);
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  Future<void> getProduct(String id, int index, int secPos, bool list) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {


        var parameter = {
          ID: id,
        };

        // if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        Response response =
            await post(getProductApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));


        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          List<Product> items = new List<Product>();

          items =
              (data as List).map((data) => new Product.fromJson(data)).toList();

          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProductDetail(
                    index: list ? int.parse(id) : index,
                    updateHome: updateHome,
                    updateParent: updateParent,
                    model: list
                        ? items[0]
                        : sectionList[secPos].productList[index],
                    secPos: secPos,
                    list: list,
                  )));
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'));
      }
    } else {
      {
         if (mounted) setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  updateParent() {
     if (mounted) setState(() {});
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

class StateHomePage extends State<HomePage> with TickerProviderStateMixin {
  final _controller = PageController();
  int _curSlider = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool useMobileLayout;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool menuOpen = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  var isDarkTheme;

  @override
  void initState() {
    super.initState();
    callApi();
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
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

  updateHomePage() {
     if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return _home();
  }

  Widget _home() {
    return Scaffold(
        key: _scaffoldKey,
        //  backgroundColor: colors.lightWhite,
        body: _isNetworkAvail
            ? _isCatLoading
                ? homeShimmer()
                : RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _getSearchBar(),
                            _slider(),
                            _catHeading(),
                            _catList(),
                            _section()
                          ],
                        )))
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
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  getSlider();
                  getCat();
                  getSection();
                  getSetting();
                  getOfferImages();
                } else {
                  await buttonController.reverse();
                   if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  Widget homeShimmer() {
    double width = deviceWidth;
    double height = width / 2;
    return Container(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[100],
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: double.infinity,
              height: height,
              color: colors.white,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              width: double.infinity,
              height: 18.0,
              color: colors.white,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                        .map((_) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              width: 50.0,
                              height: 50.0,
                              color: colors.white,
                            ))
                        .toList()),
              ),
            ),
            Column(
                children: [0, 1, 2, 3, 4]
                    .map((_) => Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              width: double.infinity,
                              height: 18.0,
                              color: colors.white,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              width: double.infinity,
                              height: 8.0,
                              color: colors.white,
                            ),
                            GridView.count(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                childAspectRatio: 1.0,
                                physics: NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                                children: List.generate(
                                  4,
                                  (index) {
                                    return Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: colors.white,
                                    );
                                  },
                                )),
                          ],
                        ))
                    .toList()),
          ],
        )),
      ),
    );
  }

  Widget _slider() {
    double height = deviceWidth / 2.2;

    return homeSliderList.isNotEmpty
        ? Stack(
            children: [
              Container(
                height: height,
                width: double.infinity,
                margin: EdgeInsetsDirectional.only(top: 10),
                child: PageView.builder(
                  itemCount: homeSliderList.length,
                  scrollDirection: Axis.horizontal,
                  controller: _controller,
                  physics: AlwaysScrollableScrollPhysics(),
                  onPageChanged: (index) {
                     if (mounted) setState(() {
                      _curSlider = index;
                    });
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return pages[index];
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                height: 40,
                left: 0,
                width: deviceWidth,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: map<Widget>(
                    homeSliderList,
                    (index, url) {
                      return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _curSlider == index
                                ? colors.fontColor
                                : colors.lightBlack,
                          ));
                    },
                  ),
                ),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 27),
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

        if (nextPage == homeSliderList.length) {
          nextPage = 0;
        }
        if (_controller.hasClients)
          _controller
              .animateToPage(nextPage,
                  duration: Duration(milliseconds: 200), curve: Curves.linear)
              .then((_) => _animateSlider());
      }
    });
  }

  _getSearchBar() {
    isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      child: SizedBox(
        height: 35,
        child: TextField(
          enabled: false,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
              border: new OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(50.0),
                ),
                borderSide: BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              isDense: true,
              hintText: getTranslated(context, 'searchHint'),
              hintStyle: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: colors.fontColor,
                  ),
              //prefixIcon: Image.asset('assets/images/search.png'),
              suffixIcon: Image.asset(
                'assets/images/search.png',
                color: isDarkTheme ? colors.secondary : colors.primary,
              ),
              fillColor: colors.white,
              filled: true),
        ),
      ),
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Search(
                updateHome: widget.updateHome,
                menuopen: menuOpen,
              ),
            ));
         if (mounted) setState(() {});
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
            getTranslated(context, 'category'),
            style: Theme.of(context).textTheme.subtitle1,
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                getTranslated(context, 'seeAll'),
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: colors.primary),
              ),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AllCategory(
                          updateHome: widget.updateHome,
                        )),
              );
               if (mounted) setState(() {});
            },
          ),
        ],
      ),
    );
  }

  _catList() {
    return Container(
      height: 80,
      child: ListView.builder(
        itemCount: catList.length < 10 ? catList.length : 10,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: GestureDetector(
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
                   if (mounted) setState(() {});
                } else {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubCat(
                            title: catList[index].name,
                            subList: catList[index].subList,
                            updateHome: widget.updateHome),
                      ));
                   if (mounted) setState(() {});
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 5.0),
                    child: new ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: new FadeInImage(
                        fadeInDuration: Duration(milliseconds: 150),
                        image: NetworkImage(
                          catList[index].image,
                        ),
                        height: 50.0,
                        width: 50.0,
                        fit: BoxFit.cover,
                        //  errorWidget: (context, url, e) => placeHolder(50),
                        placeholder: placeHolder(50),
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      catList[index].name,
                      style: Theme.of(context).textTheme.caption.copyWith(
                          color: colors.fontColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    width: 50,
                  ),
                ],
              ),
            ),
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

  Future<Null> _refresh() {
     if (mounted) setState(() {
      _isCatLoading = true;
    });
    return callApi();
  }

  _singleSection(int index) {
    return sectionList[index].productList.length > 0
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _getHeading(sectionList[index].title, index),
              _getSection(index),
              offerImages.length > index ? _getOfferImage(index) : Container(),
            ],
          )
        : Container();
  }

  _getHeading(String title, int index) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                getTranslated(context, 'seeAll'),
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: colors.primary),
              ),
            ),
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
          ),
        ],
      ),
    );
  }

  _getOfferImage(index) {
    return FadeInImage(
        fadeInDuration: Duration(milliseconds: 150),
        image: NetworkImage(offerImages[index].image),
        width: double.maxFinite,
        // errorWidget: (context, url, e) => placeHolder(50),
        placeholder: AssetImage(
          "assets/images/sliderph.png",
        ));
  }

  _getSection(int i) {
    var orient = MediaQuery.of(context).orientation;

    return sectionList[i].style == DEFAULT
        ? GridView.count(
            padding: EdgeInsetsDirectional.only(top: 5),
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 0.8,
            physics: NeverScrollableScrollPhysics(),
            children: List.generate(
              sectionList[i].productList.length < 4
                  ? sectionList[i].productList.length
                  : 4,
              (index) {
                return productItem(i, index, index % 2 == 0 ? true : false);
              },
            ))
        : sectionList[i].style == STYLE1
            ? sectionList[i].productList.length > 0
                ? Row(
                    children: [
                      Flexible(
                          flex: 3,
                          fit: FlexFit.loose,
                          child: Container(
                              height: orient == Orientation.portrait
                                  ? MediaQuery.of(context).size.height * 0.4
                                  : MediaQuery.of(context).size.height,
                              child: productItem(i, 0, true))),
                      Flexible(
                        flex: 2,
                        fit: FlexFit.loose,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                height: orient == Orientation.portrait
                                    ? deviceHeight * 0.2
                                    : deviceHeight * 0.5,
                                child: productItem(i, 1, false)),
                            Container(
                                height: orient == Orientation.portrait
                                    ? deviceHeight * 0.2
                                    : deviceHeight * 0.5,
                                child: productItem(i, 2, false)),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container()
            : sectionList[i].style == STYLE2
                ? Row(
                    children: [
                      Flexible(
                        flex: 2,
                        fit: FlexFit.loose,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                height: orient == Orientation.portrait
                                    ? deviceHeight * 0.2
                                    : deviceHeight * 0.5,
                                child: productItem(i, 0, true)),
                            Container(
                                height: orient == Orientation.portrait
                                    ? deviceHeight * 0.2
                                    : deviceHeight * 0.5,
                                child: productItem(i, 1, true)),
                          ],
                        ),
                      ),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.loose,
                          child: Container(
                              height: orient == Orientation.portrait
                                  ? deviceHeight * 0.4
                                  : deviceHeight,
                              child: productItem(i, 2, false))),
                    ],
                  )
                : sectionList[i].style == STYLE3
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                              flex: 1,
                              fit: FlexFit.loose,
                              child: Container(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight * 0.3
                                      : deviceHeight * 0.6,
                                  child: productItem(i, 0, false))),
                          Container(
                            height: orient == Orientation.portrait
                                ? deviceHeight * 0.2
                                : deviceHeight * 0.5,
                            child: Row(
                              children: [
                                Flexible(
                                    flex: 1,
                                    fit: FlexFit.loose,
                                    child: productItem(i, 1, true)),
                                Flexible(
                                    flex: 1,
                                    fit: FlexFit.loose,
                                    child: productItem(i, 2, true)),
                                Flexible(
                                    flex: 1,
                                    fit: FlexFit.loose,
                                    child: productItem(i, 3, false)),
                              ],
                            ),
                          ),
                        ],
                      )
                    : sectionList[i].style == STYLE4
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                  flex: 1,
                                  fit: FlexFit.loose,
                                  child: Container(
                                      height: orient == Orientation.portrait
                                          ? deviceHeight * 0.3
                                          : deviceHeight * 0.6,
                                      child: productItem(i, 0, false))),
                              Container(
                                height: orient == Orientation.portrait
                                    ? deviceHeight * 0.2
                                    : deviceHeight * 0.5,
                                child: Row(
                                  children: [
                                    Flexible(
                                        flex: 1,
                                        fit: FlexFit.loose,
                                        child: productItem(i, 1, true)),
                                    Flexible(
                                        flex: 1,
                                        fit: FlexFit.loose,
                                        child: productItem(i, 2, false)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : GridView.count(
                            padding: EdgeInsetsDirectional.only(top: 5),
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            childAspectRatio: 1.0,
                            physics: NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 0,
                            crossAxisSpacing: 0,
                            children: List.generate(
                              sectionList[i].productList.length < 4
                                  ? sectionList[i].productList.length
                                  : 4,
                              (index) {
                                return productItem(
                                    i, index, index % 2 == 0 ? true : false);
                              },
                            ));
  }

  Widget productItem(int secPos, int index, bool pad) {
    if (sectionList[secPos].productList.length > index) {
      String offPer;
      double price = double.parse(
          sectionList[secPos].productList[index].prVarientList[0].disPrice);
      if (price == 0) {
        price = double.parse(
            sectionList[secPos].productList[index].prVarientList[0].price);
      } else {
        double off = double.parse(
                sectionList[secPos].productList[index].prVarientList[0].price) -
            price;
        offPer = ((off * 100) /
                double.parse(sectionList[secPos]
                    .productList[index]
                    .prVarientList[0]
                    .price))
            .toStringAsFixed(2);
      }

      double width = deviceWidth * 0.5;

      return Card(
        elevation: 0.2,
        margin:   EdgeInsetsDirectional.only(bottom: 5, end: pad ? 5 : 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5)),
                    child: Hero(
                      tag:
                          "${sectionList[secPos].productList[index].id}$secPos$index",
                      child: FadeInImage(
                        fadeInDuration: Duration(milliseconds: 150),
                        image: NetworkImage(
                            sectionList[secPos].productList[index].image),
                        height: double.maxFinite,
                        width: double.maxFinite,
                        // errorWidget: (context, url, e) => placeHolder(width),
                        placeholder: placeHolder(width),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 5.0, top: 5, bottom: 5),
                child: Text(
                  sectionList[secPos].productList[index].name,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: colors.lightBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(" " + CUR_CURRENCY + " " + price.toString(),
                  style: TextStyle(
                      color: colors.fontColor, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 5.0, bottom: 5, top: 3),
                child: double.parse(sectionList[secPos]
                            .productList[index]
                            .prVarientList[0]
                            .disPrice) !=
                        0
                    ? Row(
                        children: <Widget>[
                          Text(
                            double.parse(sectionList[secPos]
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
                            style: Theme.of(context)
                                .textTheme
                                .overline
                                .copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    letterSpacing: 0),
                          ),
                          Text(" | " + "-$offPer%",
                              style: Theme.of(context)
                                  .textTheme
                                  .overline
                                  .copyWith(
                                      color: colors.primary, letterSpacing: 0)),
                        ],
                      )
                    : Container(
                        height: 5,
                      ),
              )
            ],
          ),
          onTap: () {
            Product model = sectionList[secPos].productList[index];
            Navigator.push(
              context,
              PageRouteBuilder(
                  // transitionDuration: Duration(milliseconds: 150),
                  pageBuilder: (_, __, ___) => ProductDetail(
                      model: model,
                      updateParent: updateHomePage,
                      secPos: secPos,
                      index: index,
                      updateHome: widget.updateHome,
                      list: false
                      //  title: sectionList[secPos].title,
                      )),
            );
          },
        ),
      );
    } else
      return Container();
  }

  _setFav(int secPos, int index) async {
    try {
       if (mounted) setState(() {
        sectionList[secPos].productList[index].isFavLoading = true;
      });

      var parameter = {
        USER_ID: CUR_USERID,
        PRODUCT_ID: sectionList[secPos].productList[index].id
      };
      Response response =
          await post(setFavoriteApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          sectionList[secPos].productList[index].isFav = "1";
        } else {
          setSnackbar(msg);
        }

         if (mounted) setState(() {
          sectionList[secPos].productList[index].isFavLoading = false;
        });
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
    }
  }

  setSnackbar(String msg) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.black),
      ),
      backgroundColor: colors.white,
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
      getOfferImages();
    } else {
       if (mounted) setState(() {
        _isNetworkAvail = false;
      });
      if (mounted)
         if (mounted) setState(() {
          _isCatLoading = false;
        });
    }
  }

  Future<Null> getSlider() async {
    try {
      Response response = await post(getSliderApi, headers: headers)
          .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          homeSliderList =
              (data as List).map((data) => new Model.fromSlider(data)).toList();

          pages = homeSliderList.map((slider) {
            return _buildImagePageItem(slider);
          }).toList();
        } else {
          setSnackbar(msg);
        }
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
    }
    return null;
  }

  Future<void> getCat() async {
    try {
      var parameter = {
        CAT_FILTER: "false",
      };
      Response response =
          await post(getCatApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          catList =
              (data as List).map((data) => new Product.fromCat(data)).toList();
        } else {
          setSnackbar(msg);
        }
      }
      if (mounted)
         if (mounted) setState(() {
          _isCatLoading = false;
        });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
      if (mounted)
         if (mounted) setState(() {
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
      if (response.statusCode == 200) {
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
      }
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted)
           if (mounted) setState(() {
            _isCatLoading = false;
          });
      });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
       if (mounted) setState(() {
        _isCatLoading = false;
      });
    }
  }

  Future<void> getSetting() async {
    try {
      CUR_USERID = await getPrefrence(ID);

      var parameter;
      if (CUR_USERID != null) parameter = {USER_ID: CUR_USERID};

      Response response = await post(getSettingApi,
              body: CUR_USERID != null ? parameter : null, headers: headers)
          .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"]["system_settings"][0];
          CUR_CURRENCY = data["currency"];
          RETURN_DAYS = data['max_product_return_days'];
          MAX_ITEMS = data["max_items_cart"];
          String del = data["area_wise_delivery_charge"];
          if (del == "0")
            ISFLAT_DEL = true;
          else
            ISFLAT_DEL = false;
          if (CUR_USERID != null) {
            CUR_CART_COUNT =
                getdata["data"]["user_data"][0]["cart_total_items"].toString();

            CUR_BALANCE = getdata["data"]["user_data"][0]["balance"];
          }
          widget.updateHome();
        } else {
          setSnackbar(msg);
        }
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
    }
  }

  Future<Null> getOfferImages() async {
    try {
      Response response = await post(getOfferImageApi, headers: headers)
          .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          offerImages.clear();
          offerImages =
              (data as List).map((data) => new Model.fromSlider(data)).toList();
        } else {
          setSnackbar(msg);
        }
      }
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted)
           if (mounted) setState(() {
            _isCatLoading = false;
          });
      });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
       if (mounted) setState(() {
        _isCatLoading = false;
      });
    }
    return null;
  }

  Widget _buildImagePageItem(Model slider) {
    double height = deviceWidth / 2.2;

    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7.0),
        child: CachedNetworkImage(
          imageUrl: (slider.image),
          height: height,
          width: double.maxFinite,
          fit: BoxFit.fill,
          placeholder: (context, url) => Image.asset(
            "assets/images/sliderph.png",
            fit: BoxFit.fill,
            height: height,
          ),
        ),
      ),
      onTap: () async {
        if (homeSliderList[_curSlider].type == "products") {
          Product item = homeSliderList[_curSlider].list;

          Navigator.push(
            context,
            PageRouteBuilder(
                //transitionDuration: Duration(seconds: 1),
                pageBuilder: (_, __, ___) => ProductDetail(
                    model: item,
                    updateParent: updateHomePage,
                    secPos: 0,
                    index: 0,
                    updateHome: widget.updateHome,
                    list: true
                    //  title: sectionList[secPos].title,
                    )),
          );
        } else if (homeSliderList[_curSlider].type == "categories") {
          Product item = homeSliderList[_curSlider].list;
          if (item.subList == null || item.subList.length == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductList(
                      name: item.name,
                      id: item.id,
                      updateHome: widget.updateHome),
                ));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCat(
                      title: item.name,
                      subList: item.subList,
                      updateHome: widget.updateHome),
                ));
          }
        }
      },
    );
  }
}

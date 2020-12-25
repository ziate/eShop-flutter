import 'dart:async';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Product_Detail.dart';
import 'package:eshop/SignInUpAcc.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Home.dart';
import 'Login.dart';

class Intro_Slider extends StatefulWidget {
  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<Intro_Slider>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  Animation buttonSqueezeanimation;
  AnimationController buttonController;

  @override
  void initState() {
    super.initState();

    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth * 0.9,
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
    super.dispose();
    _pageController.dispose();
    buttonController.dispose();

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  final slideList = [
    Slide(
      imageUrl: 'assets/images/introimage_a.png',
      title: TITLE1_LBL,
      description: DISCRIPTION1,
    ),
    Slide(
      imageUrl: 'assets/images/introimage_b.png',
      title: TITLE2_LBL,
      description: DISCRIPTION2,
    ),
    Slide(
      imageUrl: 'assets/images/introimage_c.png',
      title: TITLE3_LBL,
      description: DISCRIPTION3,
    ),
  ];

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Widget _slider() {
    return Expanded(
      child: PageView.builder(
        itemCount: slideList.length,
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (BuildContext context, int index) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * .5,
                  child: Image.asset(
                    slideList[index].imageUrl,
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text(slideList[index].title,
                        style: Theme.of(context).textTheme.headline5.copyWith(
                            color: fontColor, fontWeight: FontWeight.bold))),
                Container(
                  padding: EdgeInsets.only(top: 30.0, left: 15.0, right: 15.0),
                  child: Text(slideList[index].description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: fontColor, fontWeight: FontWeight.normal)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _btn() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: map<Widget>(
            slideList,
                (index, url) {
              return Container(
                  width: 10.0,
                  height: 10.0,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? fontColor
                        : fontColor.withOpacity((0.5)),
                  ));
            },
          ),
        ),
        Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom:18.0),
              child: AppBtn(
                  title: _currentPage == 0 || _currentPage == 1
                      ? NEXT_LBL
                      : GET_STARTED,
                  btnAnim: buttonSqueezeanimation,
                  btnCntrl: buttonController,
                  onBtnSelected: () {
                    if (_currentPage == 2) {
                      setPrefrenceBool(ISFIRSTTIME, true);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignInUpAcc()),
                      );
                    } else {
                      _currentPage = _currentPage + 1;
                      _pageController.animateToPage(_currentPage,
                          curve: Curves.decelerate,
                          duration: Duration(milliseconds: 300));
                    }
                  }),
            )),
      ],
    );
  }

  skipBtn() {
    return _currentPage == 0 || _currentPage == 1
        ? Padding(
        padding: EdgeInsets.only(top: 20.0, right: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                setPrefrenceBool(ISFIRSTTIME, true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInUpAcc()),
                );
              },
              child: Row(children: [
                Text(SKIP,
                    style: Theme.of(context).textTheme.caption.copyWith(
                      color: fontColor,
                    )),
                Icon(
                  Icons.arrow_forward_ios,
                  color: fontColor,
                  size: 12.0,
                ),
              ]),
            ),
          ],
        ))
        : Container(
      margin: EdgeInsets.only(top: 50.0),
      height: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            skipBtn(),
            _slider(),
            _btn(),
          ],
        ));
  }
}

class Slide {
  final String imageUrl;
  final String title;
  final String description;

  Slide({
    @required this.imageUrl,
    @required this.title,
    @required this.description,
  });
}

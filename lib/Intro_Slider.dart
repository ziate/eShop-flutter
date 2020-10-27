import 'dart:async';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';

import 'package:flutter/material.dart';
import 'Helper/Color.dart';
import 'Login.dart';

class Intro_Slider extends StatefulWidget {
  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<Intro_Slider> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
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
        reverse: false,
        onPageChanged: _onPageChanged,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Image.asset(
                  slideList[index].imageUrl,
                ),
              ),
              Container(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Text(
                    slideList[index].title,
                    style: TextStyle(
                      fontSize: 35,
                      color: primary,
                    ),
                  )),
              Container(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  slideList[index].description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.black54),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 40, top: 20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: map<Widget>(
                    slideList,
                        (index, url) {
                      return Container(
                          width: 10.0,
                          height: 10.0,
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? primary
                                : primary.withOpacity((0.2)),
                          ));
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  _btn() {
    double width = MediaQuery.of(context).size.width;
    return Container(
        padding: EdgeInsets.only(bottom: 20.0, left: 50.0, right: 50.0),
        child: Center(
            child: RaisedButton(
              onPressed: () {
                setPrefrenceBool(ISFIRSTTIME, true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
              padding: EdgeInsets.all(0.0),
              child: Ink(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary.withOpacity(0.7), primary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.0)),
                child: Container(
                  constraints:
                  BoxConstraints(maxWidth: width * 0.90, minHeight: 50.0),
                  //decoration: back(),
                  alignment: Alignment.center,
                  child: Text(
                    GET_STARTED,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SafeArea(
            child: Container(
                width: width,
                height: height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _slider(),
                    _btn(),
                  ],
                ))));
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

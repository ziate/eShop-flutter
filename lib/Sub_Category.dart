import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'Helper/Constant.dart';
import 'Model/Model.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'ProductList.dart';
import 'SubCat.dart';

class SubCategory extends StatefulWidget {
  final String title;

  //const Sub_Category({Key key, this.id, this.title}) : super(key: key);

  final List<Model> subList;

  SubCategory({this.subList, this.title});

  @override
  State<StatefulWidget> createState() => StateSub(subList: subList);
}

class StateSub extends State<SubCategory> {
  // bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Model> subList = [];

  StateSub({this.subList});

  @override
  void initState() {
    //_getSubCat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(widget.title, context),
        body: subList == null || subList.length == 0
            ? getNoItem()
            : GridView.count(
                crossAxisCount: 3,
                childAspectRatio: .8,
                physics: BouncingScrollPhysics(),
                children: List.generate(
                  subList.length,
                  (index) {
                    return listItem(index);
                  },
                )));
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

  Widget listItem(int index) {
    return Column(
      children: <Widget>[
        InkWell(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: new ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: new CachedNetworkImage(
                      imageUrl: subList[index].image,
                      height: 100.0,
                      width: 100.0,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => placeHolder(100),
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    subList[index].name,
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
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCat(
                    subList: subList,
                    title:widget.title
                  ),
                ));
          },
        ),
      ],
    );
  }
}

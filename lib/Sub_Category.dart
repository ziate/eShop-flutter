import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'Helper/Constant.dart';
import 'Helper/Model.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'ProductList.dart';

class Sub_Category extends StatefulWidget {
  final String id, title;

  const Sub_Category({Key key, this.id, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => State_Sub();
}

class State_Sub extends State<Sub_Category> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Model> subList = [];

  @override
  void initState() {
    _getSubCat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(widget.title, context),
        body: _isLoading
            ? getProgress()
            : subList.length == 0
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

  Future<void> _getSubCat() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      try {
        var parameter = {ID: widget.id};

        Response response =
            await post(getSubcatApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print('response***subcat**${response.body.toString()}');
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          subList =
              (data as List).map((data) => new Model.fromSubCat(data)).toList();
        } else {
          setSnackbar(msg);
        }
        setState(() {
          _isLoading = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          _isLoading = false;
        });
      }
    } else
      setSnackbar(internetMsg);
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
                  builder: (context) => ProductList(
                    name: subList[index].name,
                    id: subList[index].id,
                  ),
                ));
          },
        ),
      ],
    );
  }
}

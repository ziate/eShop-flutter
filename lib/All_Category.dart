import 'dart:async';
import 'dart:convert';

import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Home.dart';
import 'ProductList.dart';
import 'SubCat.dart';
import 'Model/Model.dart';
import 'Model/Section_Model.dart';

class AllCategory extends StatefulWidget {
  final Function updateHome;

  const AllCategory({Key key, this.updateHome}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateCat();
  }
}

class StateCat extends State<AllCategory> {
  int offset = perPage;
  int total = 0;
  bool isLoadingmore = true, _isCatLoading = false;
  ScrollController controller = new ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Product> tempList = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: lightWhite,
        appBar: getAppBar(ALL_CAT, context),
        body: GridView.count(
            controller: controller,
            padding: EdgeInsets.all(20),
            crossAxisCount: 4,
            shrinkWrap: true,
            childAspectRatio: .8,
            children: List.generate(
              (offset < total) ? catList.length + 1 : catList.length,
              (index) {
                return (index == catList.length && isLoadingmore)
                    ? Center(child: CircularProgressIndicator())
                    : catItem(index, context);
              },
            )));
  }

  Future<void> getCat() async {
    try {
      var parameter = {
        CAT_FILTER: "false",
        LIMIT: perPage.toString(),
        OFFSET: offset.toString()
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

          if (!error) {
            total = int.parse(getdata["total"]);

            if ((offset) < total) {
              tempList.clear();
              var data = getdata["data"];
              tempList = (data as List)
                  .map((data) => new Product.fromCat(data))
                  .toList();
              catList.addAll(tempList);

              offset = offset + perPage;
            }
          }
        } else {
          isLoadingmore = false;
          setSnackbar(msg);
        }
        setState(() {
          _isCatLoading = false;
        });
      }
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isCatLoading = false;
        isLoadingmore = false;
      });
    }
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

  Widget catItem(int index, BuildContext context) {
    return GestureDetector(
      child: Column(
        children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: FadeInImage(
                image: NetworkImage(catList[index].image),
                fadeInDuration: Duration(milliseconds: 150),
                height: 50,
                width: 50,
                fit: BoxFit.fill,
                placeholder: placeHolder(50),
              )),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              catList[index].name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(color: fontColor),
            ),
          )
        ],
      ),
      onTap: () {
        if (catList[index].subList == null ||
            catList[index].subList.length == 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductList(
                  name: catList[index].name,
                  id: catList[index].id,
                ),
              ));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubCat(
                  title: catList[index].name,
                  subList: catList[index].subList,
                  updateHome: widget.updateHome,
                ),
              ));
        }
      },
    );
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          if (offset < total) getCat();
        });
      }
    }
  }
}

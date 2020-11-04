import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'Favorite.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Login.dart';
import 'Model/Section_Model.dart';
import 'Helper/String.dart';
import 'Product_Detail.dart';

class SectionList extends StatefulWidget {
  final int index;
  final Section_Model section_model;
  final Function updateHome;

  SectionList({Key key, this.index, this.section_model, this.updateHome})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StateSection();
}

int offset = 4;
int total = 0;

class StateSection extends State<SectionList> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isLoadingmore = true;
  bool _isLoading = true;
  ScrollController controller = new ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getSection();
    controller.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: getAppBar(sectionList[widget.index].title, context),
      body: GridView.count(
          padding: EdgeInsets.only(top: 5),
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: 1.1,
          physics: BouncingScrollPhysics(),
          mainAxisSpacing: 5,
          crossAxisSpacing: 2,
          controller: controller,
          children: List.generate(
            (offset < total)
                ? widget.section_model.productList.length + 1
                : widget.section_model.productList.length,
            (index) {
              print(
                  "length***$index**${widget.section_model.productList.length}***$isLoadingmore***$offset**$total");
              return (index == widget.section_model.productList.length &&
                      isLoadingmore)
                  ? Center(child: CircularProgressIndicator())
                  : productItem(index);
            },
          )),
    );
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          print("load more****limit *****$offset****$total");
          if (offset < total) getSection();
        });
      }
    }
  }

  productItem(int index) {
    double width = MediaQuery.of(context).size.width * 0.5 - 20;
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
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5)),
                  child: CachedNetworkImage(
                    imageUrl: widget.section_model.productList[index].image,
                    height: double.maxFinite,
                    width: double.maxFinite,
                    placeholder: (context, url) => placeHolder(width),
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
                          color: Colors.yellow,
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
                          .copyWith(color: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  widget.section_model.productList[index].isFavLoading
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
                              widget.section_model.productList[index].isFav ==
                                      "0"
                                  ? Icons.favorite_border
                                  : Icons.favorite,
                              size: 15,
                              color: primary,
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
                    int.parse(widget.section_model.productList[index]
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
                      style: TextStyle(color: primary)),
                ],
              ),
            )
          ],
        ),
        onTap: () {
          Product model = widget.section_model.productList[index];
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Product_Detail(
                      model: model,
                      updateParent: updateSectionList,
                      updateHome: widget.updateHome,
                    )),
          );
        },
      ),
    );
  }

  updateSectionList() {
    setState(() {});
  }

  Future<void> getSection() async {
    try {
      var parameter = {
        PRODUCT_LIMIT: perPage.toString(),
        PRODUCT_OFFSET: offset.toString(),
        SEC_ID: widget.section_model.id
      };
      print("section para**${parameter.toString()}");
      if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
      Response response =
          await post(getSectionApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      print('section get***');
      print('response***sec**$headers***${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        total = int.parse(data[0]["total"]);
        if (offset < total) {
          List<Section_Model> temp = (data as List)
              .map((data) => new Section_Model.fromJson(data))
              .toList();

          print("temp***${temp.length}");

          sectionList[widget.index].productList.addAll(temp[0].productList);
          //temp[0];
          offset = offset + perPage;
        }
      } else {
        isLoadingmore = false;
        setSnackbar(msg);
      }

      setState(() {
        _isLoading = false;
        isLoadingmore = false;
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isLoading = false;
      });
    }
  }

  _setFav(int index) async {
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

      print("set fav***${parameter.toString()}");
      var getdata = json.decode(response.body);
      print('response***setting**${response.body.toString()}');
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

  _removeFav(int index) async {
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
      print('response***setting**${response.body.toString()}');
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
      setSnackbar(somethingMSg);
    }
  }
}

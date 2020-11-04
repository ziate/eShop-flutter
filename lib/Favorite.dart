import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shimmer/shimmer.dart';

import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Login.dart';
import 'Model/Section_Model.dart';
import 'Product_Detail.dart';

class Favorite extends StatefulWidget {
  Function update;

  Favorite(this.update);

  @override
  State<StatefulWidget> createState() => StateFav();
}

bool _isProgress = false, _isFavLoading = true;
int offset = 0;
int total = 0;
bool isLoadingmore = true;
List<Section_Model> favList = [];

class StateFav extends State<Favorite> {
  ScrollController controller = new ScrollController();
  List<Section_Model> tempList = [];
  String msg = noFav;

  @override
  void initState() {
    super.initState();

    offset = 0;
    total = 0;

    _getFav();
    controller.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        _showContent(),
        showCircularProgress(_isProgress, primary),
      ],
    ));
  }

  Widget listItem(int index) {
    //print("desc*****${productList[index].desc}");
    int selectedPos = 0;
    for (int i = 0;
        i < favList[index].productList[0].prVarientList.length;
        i++) {
      if (favList[index].varientId ==
          favList[index].productList[0].prVarientList[i].id) selectedPos = i;

      print(
          "selected pos***$selectedPos***${favList[index].productList[0].prVarientList[i].id}");
    }

    double price = double.parse(
        favList[index].productList[0].prVarientList[selectedPos].disPrice);
    if (price == 0)
      price = double.parse(
          favList[index].productList[0].prVarientList[selectedPos].price);

    return Card(
      elevation: 0.1,
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: favList[index].productList[0].image,
              height: 90.0,
              width: 90.0,
              placeholder: (context, url) => placeHolder(90),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              favList[index].productList[0].name,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(color: Colors.black),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8, bottom: 8),
                            child: Icon(
                              Icons.close,
                              size: 13,
                            ),
                          ),
                          onTap: () {
                            _removeFav(index);
                          },
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 12,
                          ),
                          Text(
                            " " + favList[index].productList[0].rating,
                            style: Theme.of(context).textTheme.overline,
                          ),
                          Text(
                            " (" +
                                favList[index].productList[0].noOfRating +
                                ")",
                            style: Theme.of(context).textTheme.overline,
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            InkWell(
                              child: Container(
                                margin: EdgeInsets.only(
                                    right: 8, top: 8, bottom: 8),
                                child: Icon(
                                  Icons.remove,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                              onTap: () {
                                removeFromCart(index, false);
                              },
                            ),
                            Text(
                              favList[index]
                                  .productList[0]
                                  .prVarientList[0]
                                  .cartCount,
                              style: Theme.of(context).textTheme.caption,
                            ),
                            InkWell(
                              child: Container(
                                margin: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.add,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                              onTap: () {
                                addToCart(index);
                              },
                            )
                          ],
                        ),
                        Spacer(),
                        Row(
                          children: <Widget>[
                            Text(
                              int.parse(favList[index]
                                          .productList[0]
                                          .prVarientList[selectedPos]
                                          .disPrice) !=
                                      0
                                  ? CUR_CURRENCY +
                                      "" +
                                      favList[index]
                                          .productList[0]
                                          .prVarientList[selectedPos]
                                          .price
                                  : "",
                              style: Theme.of(context)
                                  .textTheme
                                  .overline
                                  .copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      letterSpacing: 0.7),
                            ),
                            Text(" " + CUR_CURRENCY + " " + price.toString(),
                                style: Theme.of(context).textTheme.headline6),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        splashColor: primary.withOpacity(0.2),
        onTap: () {
          Product model = favList[index].productList[0];
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Product_Detail(
                      model: model,
                      updateParent: updateFav,
                      updateHome: widget.update,
                      //  title: productList[index].name,
                    )),
          );
        },
      ),
    );
  }

  updateFav() {
    setState(() {});
  }

  Future<void> _getFav() async {
    try {
      if (CUR_USERID != null) {
        var parameter = {
          USER_ID: CUR_USERID,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
        };
        Response response =
            await post(getFavApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print('response***fav****par***${parameter.toString()}');
        print('response***fav****${response.body.toString()}');
        bool error = getdata["error"];
        String msg = getdata["message"];

        print('section get***favorite get');
        if (!error) {
          total = int.parse(getdata["total"]);

          if ((offset) < total) {
            tempList.clear();
            var data = getdata["data"];
            tempList = (data as List)
                .map((data) => new Section_Model.fromFav(data))
                .toList();
            if (offset == 0) favList.clear();
            favList.addAll(tempList);

            offset = offset + perPage;
          }
        } else {
          if (msg != 'No Favourite(s) Product Are Added') setSnackbar(msg);
          isLoadingmore = false;
        }
        setState(() {
          _isFavLoading = false;
        });
      } else {
        setState(() {
          _isFavLoading = false;
          msg = goToLogin;
        });

        Future.delayed(Duration(seconds: 1)).then((_) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        });
      }
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isFavLoading = false;
        isLoadingmore = false;
      });
    }
  }

  Future<void> addToCart(int index) async {
    try {
      setState(() {
        _isProgress = true;
      });
      var parameter = {
        PRODUCT_VARIENT_ID: favList[index].productList[0].prVarientList[0].id,
        USER_ID: CUR_USERID,
        QTY: (int.parse(
                    favList[index].productList[0].prVarientList[0].cartCount) +
                1)
            .toString(),
      };

      print('param****${parameter.toString()}');

      Response response =
          await post(manageCartApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      print(
          'response***slider**${favList[index].varientId}*${response.body.toString()}***$headers');

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        String qty = data['total_quantity'];
        CUR_CART_COUNT = data['cart_count'];
        favList[index].productList[0].prVarientList[0].cartCount =
            qty.toString();

        widget.update();
      } else {
        setSnackbar(msg);
      }
      setState(() {
        _isProgress = false;
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isProgress = false;
      });
    }
  }

  setSnackbar(String msg) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 1.0,
    ));
  }

  removeFromCart(int index, bool remove) async {
    try {
      setState(() {
        _isProgress = true;
      });

      var parameter = {
        USER_ID: CUR_USERID,
        QTY: remove
            ? "0"
            : (int.parse(favList[index]
                        .productList[0]
                        .prVarientList[0]
                        .cartCount) -
                    1)
                .toString(),
        PRODUCT_VARIENT_ID: favList[index].productList[0].prVarientList[0].id
      };

      Response response =
          await post(manageCartApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      print('response***slider**${response.body.toString()}***$headers');

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        String qty = data['total_quantity'];
        CUR_CART_COUNT = data['cart_count'];

        if (remove)
          favList.removeWhere(
              (item) => item.varientId == favList[index].varientId);
        else {
          favList[index].productList[0].prVarientList[0].cartCount =
              qty.toString();
        }

        widget.update();
      } else {
        setSnackbar(msg);
      }
      setState(() {
        _isProgress = false;
      });
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      setState(() {
        _isProgress = false;
      });
    }
  }

  _removeFav(int index) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        PRODUCT_ID: favList[index].productId,
      };
      Response response =
          await post(removeFavApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      print('response***fav****par***${parameter.toString()}');
      print('response***fav****remove${response.body.toString()}');
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        favList.removeWhere((item) =>
            item.productList[0].prVarientList[0].id ==
            favList[index].productList[0].prVarientList[0].id);
      } else {
        setSnackbar(msg);
      }

      setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          print("load more****limit *****$offset****$total");
          if (offset < total) _getFav();
        });
      }
    }
  }

  _showContent() {
    return _isFavLoading
        ? Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child: shimmer())
        : favList.length == 0
            ? Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight),
                child: Center(child: Text(msg)),
              )
            : ListView.builder(
                shrinkWrap: true,
                controller: controller,
                itemCount:
                    (offset < total) ? favList.length + 1 : favList.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  print(
                      "load more****$offset***$total***${favList.length}***$isLoadingmore**$index");
                  return (index == favList.length && isLoadingmore)
                      ? Center(child: CircularProgressIndicator())
                      : listItem(index);
                },
              );
  }

  Widget shimmer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[100],
        child: Column(
          children: [0, 1, 2, 3, 4, 5]
              .map((_) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child:
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80.0,
                      height: 80.0,
                      color: Colors.white,
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 18.0,
                            color: Colors.white,
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 5.0),
                          ),
                          Container(
                            width: double.infinity,
                            height: 8.0,
                            color: Colors.white,
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 5.0),
                          ),
                          Container(
                            width: 100.0,
                            height: 8.0,
                            color: Colors.white,
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 5.0),
                          ),
                          Container(
                            width: 20.0,
                            height: 8.0,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ))
              .toList(),
        ),

      ),
    );
  }
}

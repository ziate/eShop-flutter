import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Helper/Model.dart';
import 'package:eshop/Helper/Section_Model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:http/http.dart';

import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Product_Detail.dart';
import 'Search.dart';

class ProductList extends StatefulWidget {
  final String name, id;

  const ProductList({Key key, this.id, this.name}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateProduct();
}

class StateProduct extends State<ProductList> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Product>  productList = [];
  List<Product> tempList = [];
  String sortBy = 'p.id', orderBy = "DESC";
  int offset = 0;
  int total = 0;
  bool isLoadingmore = true;
  ScrollController controller=new ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
    getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppbar(),
        key: _scaffoldKey,
        body: _isLoading
            ? getProgress()
            : productList.length == 0
                ? getNoItem()
                : ListView.builder(
                    controller: controller,
                    itemCount: (offset < total)
                        ? productList.length + 1
                        : productList.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return (index == productList.length && isLoadingmore)
                          ? Center(child: CircularProgressIndicator())
                          : listItem(index);
                    },
                  ));
  }

  @override
  void dispose() {
    controller.removeListener(() {});
    super.dispose();
  }

  Widget listItem(int index) {
    //print("desc*****${productList[index].desc}");
    return Card(
      child: InkWell(
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: productList[index].image,
              height: 90.0,
              width: 90.0,
              fit: BoxFit.fill,
              placeholder: (context, url) => placeHolder(90),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      productList[index].name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(color: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Html(
                      data: '<p>${productList[index].desc}</p>',

                      /*style: {
                        "p": Style(
                            margin: EdgeInsets.all(0),
                            color: Colors.grey,
                            fontSize: FontSize.small),
                      },*/
                      //maxLines: 2,
                      //  overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            InkWell(
                              child: Container(
                                margin: EdgeInsets.only(right: 8),
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
                              splashColor: primary.withOpacity(0.2),
                              onTap: () {},
                            ),
                            Text(
                              "00",
                              style: Theme.of(context).textTheme.caption,
                            ),
                            InkWell(
                              child: Container(
                                margin: EdgeInsets.only(left: 8),
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
                              splashColor: primary.withOpacity(0.2),
                              onTap: () {},
                            ),
                          ],
                        ),
                        Spacer(),
                        Row(
                          children: <Widget>[
                            Text(
                              CUR_CURRENCY +
                                  "" +
                                  productList[index].prVarientList[0].price,
                              style:
                                  Theme.of(context).textTheme.overline.copyWith(
                                        decoration: TextDecoration.lineThrough,
                                      ),
                            ),
                            Text(
                                " " +
                                    CUR_CURRENCY +
                                    " " +
                                    productList[index]
                                        .prVarientList[0]
                                        .disPrice,
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
          Product model = productList[index];
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Product_Detail(
                      model: model,
                    //  title: productList[index].name,
                    )),
          );
        },
      ),
    );
  }

  Future<void> getProduct() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      try {
        var parameter = {
          SUB_ID: widget.id,
          SORT: sortBy,
          ORDER: orderBy,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString()
        };

        Response response =
            await post(getProductApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));


        print('response***product**$parameter****$headers***${response.body.toString()}');

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        total = int.parse(getdata["total"]);

        print('limit *****$offset****$total');

        if (!error) {

          if ((offset) < total) {

            tempList.clear();
            var data = getdata["data"];
            tempList = (data as List).map((data) => new Product.fromJson(data)).toList();

            productList.addAll(tempList);

            offset = offset + perPage;
          }

        } else {
          if (msg != "Products Not Found !") setSnackbar(msg);

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

  getAppbar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: primary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        widget.name,
        style: TextStyle(
          color: primary,
        ),
      ),
      backgroundColor: Colors.white,
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.search,
              color: primary,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Search(),
                  ));
            }),
        IconButton(
            icon: Icon(
              Icons.tune,
              color: primary,
            ),
            onPressed: () {
              sortDialog();
            })
      ],
    );
  }

  void sortDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new CupertinoAlertDialog(
            title: new Text(
              FILTER,
              style: Theme.of(context).textTheme.headline6,
            ),
            actions: [
              CupertinoActionSheetAction(
                  child: new Text(
                    F_NEWEST,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  onPressed: () {
                    sortBy = 'p.date_added';
                    orderBy = 'DESC';
                    setState(() {
                      _isLoading=true;
                      total=0;
                      offset=0;
                      productList.clear();
                    });
                    getProduct();
                    Navigator.pop(context, 'option 1');
                  }),
              CupertinoActionSheetAction(
                  child: new Text(
                    F_OLDEST,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  onPressed: () {
                    sortBy = 'p.date_added';
                    orderBy = 'ASC';
                    setState(() {
                      _isLoading=true;
                      total=0;
                      offset=0;
                      productList.clear();
                    });
                    getProduct();
                    Navigator.pop(context, 'option 2');
                  }),
              CupertinoActionSheetAction(
                  child: new Text(
                    F_LOW,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  onPressed: () {
                    sortBy = 'pv.price';
                    orderBy = 'ASC';
                    setState(() {
                      _isLoading=true;
                      total=0;
                      offset=0;
                      productList.clear();
                    });
                    getProduct();
                    Navigator.pop(context, 'option 3');
                  }),
              CupertinoActionSheetAction(
                  child: new Text(
                    F_HIGH,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  onPressed: () {
                    sortBy = 'pv.price';
                    orderBy = 'DESC';
                    setState(() {
                      _isLoading=true;
                      total=0;
                      offset=0;
                      productList.clear();
                    });
                    getProduct();
                    Navigator.pop(context, 'option 4');
                  }),
            ],
          );
        });
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          print("limit *****$offset****$total");
          if (offset < total) getProduct();
        });
      }
    }
  }
}

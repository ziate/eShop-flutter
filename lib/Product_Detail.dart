import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Cart.dart';
import 'package:eshop/Helper/Section_Model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Model.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Product_Preview.dart';

class Product_Detail extends StatefulWidget {
  final Product model;
  //final String title;

  const Product_Detail({Key key, this.model}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateItem();
}

List<String> sliderList = [];

class StateItem extends State<Product_Detail> {
  int _curSlider = 0;

  @override
  void initState() {
    super.initState();
    sliderList.clear();
    sliderList.add(widget.model.image);
    sliderList.addAll(widget.model.otherImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _slider(),
                    _smallImage(),
                    _rate(),
                    _price(),
                    _offPrice(),
                    _title(),
                    _desc(),
                  ],
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cart(),
                  ),
                );
              },
              child: Container(
                height: 55,
                decoration: back(),
                width: double.infinity,
                child: Center(
                    child: Text(
                  ADD_CART,
                  style: Theme.of(context).textTheme.button.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                )),
              ),
            ),
          ],
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

  _slider() {
    double height = MediaQuery.of(context).size.height * .41;

    return InkWell(
      child: Stack(
        children: <Widget>[
          Container(
            height: height,
            width: double.infinity,
            child: PageView.builder(
              itemCount: sliderList.length,
              scrollDirection: Axis.horizontal,
              // controller: _controller,
              reverse: false,
              onPageChanged: (index) {
                setState(() {
                  _curSlider = index;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  children: <Widget>[
                    ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: CachedNetworkImage(
                          imageUrl: sliderList[_curSlider],
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
                    // )
                  ],
                );
              },
            ),
          ),
          IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: primary,
              ),
              onPressed: () => Navigator.of(context).pop()),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  color: primary,
                ),
                onPressed: null),
          )
        ],
      ),
      splashColor: primary.withOpacity(0.2),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Product_Preview(
                pos: _curSlider,
              ),
            ));
      },
    );
  }

  _smallImage() {
    double width = MediaQuery.of(context).size.width * .20;
    return Container(
      margin: EdgeInsets.all(12),
      height: width,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: sliderList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: CachedNetworkImage(
                  imageUrl: sliderList[index],
                  placeholder: (context, url) => Image.asset(
                    "assets/images/placeholder.png",
                    height: width,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    "assets/images/placeholder.png",
                    height: width,
                    width: width,
                  ),
                  fit: BoxFit.fill,
                  height: width,
                  width: width,
                )),
          );
        },
      ),
    );
  }

  _rate() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: RatingBar(
        initialRating: 1,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemSize: 18,
        //itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {
          print(rating);
        },
      ),
    );
  }

  _price() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
      child: Text(CUR_CURRENCY + " " + widget.model.prVarientList[0].disPrice,
          style: Theme.of(context).textTheme.headline6),
    );
  }

  _offPrice() {
    double off = (int.parse(widget.model.prVarientList[0].price) -
            int.parse(widget.model.prVarientList[0].disPrice))
        .toDouble();
    off = off * 100 / int.parse(widget.model.prVarientList[0].price);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: <Widget>[
          Text(
            CUR_CURRENCY + " " + widget.model.prVarientList[0].price,
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  decoration: TextDecoration.lineThrough,
                ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            padding: EdgeInsets.all(4),
            child: Text(off.toStringAsFixed(2) + "% off",
                style: Theme.of(context)
                    .textTheme
                    .overline
                    .copyWith(color: primary,letterSpacing: 0.5)),
            decoration: new BoxDecoration(
                color: primary.withOpacity(0.2),
                borderRadius: new BorderRadius.circular(4.0)),
          ),
        ],
      ),
    );
  }

  _title() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Text(
        widget.model.name,
        style:
            Theme.of(context).textTheme.headline6.copyWith(color: Colors.black),
      ),
    );
  }

  _desc() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Html(data: widget.model.desc),
    );
    //Html(data:widget.model.productList[widget.proPos].desc);
  }
}

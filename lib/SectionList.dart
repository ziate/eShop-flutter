import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Helper/Color.dart';
import 'Model/Section_Model.dart';
import 'Helper/String.dart';
import 'Product_Detail.dart';

class SectionList extends StatefulWidget {
  final String title;
  final Section_Model section_model;

  const SectionList({Key key, this.title, this.section_model})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StateSection();
}

class StateSection extends State<SectionList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(widget.title, context),
      body: GridView.count(
          padding: EdgeInsets.only(top: 5),
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: 1.1,
          physics: BouncingScrollPhysics(),
          mainAxisSpacing: 5,
          crossAxisSpacing: 2,
          children: List.generate(
            widget.section_model.productList.length,
            (index) {
              return productItem(index);
            },
          )),
    );
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
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3),
                      child: Icon(
                        Icons.favorite_border,
                        size: 15,
                      ),
                    ),
                    onTap: () {},
                  )
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
                    )),
          );
        },
      ),
    );
  }
}

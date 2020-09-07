import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Helper/Color.dart';
import 'Helper/Section_Model.dart';
import 'Helper/String.dart';
import 'Product_Detail.dart';

class SectionList extends StatefulWidget {

  final String title;
  final Section_Model section_model;

  const SectionList({Key key, this.title, this.section_model}) : super(key: key);


  @override
  State<StatefulWidget> createState() => StateSection();
}

class StateSection extends State<SectionList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(widget.title, context),
      body: GridView.count(
          padding: EdgeInsets.only(top: 50),
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: 1.25,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 5,
          children: List.generate(
            widget.section_model.productList.length < 4
                ? widget.section_model.productList.length
                : 4,
            (index) {
              return productItem( index);
            },
          )),
    );
  }

  productItem( int index) {
    double width = MediaQuery.of(context).size.width * 0.5 - 20;
    //double height = MediaQuery.of(context).size.width * 0.5 - 20;
    // print("length****${sectionList[secPos].productList[index].name}***${sectionList[secPos].productList[index].prVarientList.length}");
    return Card(
      child: InkWell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: widget.section_model.productList[index].image,
                    height: double.maxFinite,
                    width: double.maxFinite,
                    fit: BoxFit.fill,
                    placeholder: (context, url) => placeHolder(width),
                  )
                ],
              ),
            ),
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
                  Icon(
                    Icons.favorite_border,
                    size: 15,
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
                    CUR_CURRENCY +
                        "" +
                       widget.section_model
                            .productList[index]
                            .prVarientList[0]
                            .price,
                    style: Theme.of(context).textTheme.overline.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                      " " +
                          CUR_CURRENCY +
                          "" +
                         widget.section_model
                              .productList[index]
                              .prVarientList[0]
                              .disPrice,
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
                  title: widget.section_model.title,
                )),
          );
        },
      ),
    );
  }
}

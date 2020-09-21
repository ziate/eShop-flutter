import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/Section_Model.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'Helper/Color.dart';
import 'Helper/String.dart';
import 'Product_Detail.dart';

class Cart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateCart();
}

class StateCart extends State<Cart> {
  List<Product>productList=[];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(CART, context),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: productList.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return listItem(index);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(ORIGINAL_PRICE,),
                Text(CUR_CURRENCY)
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(OFFER_PRICE,),
                Text(CUR_CURRENCY)
              ],
            ),
          ),
          Divider(color: Colors.black,thickness: 1,indent: 20,endIndent: 20,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(Total_PRICE,style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),),
                Text(CUR_CURRENCY,style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),)
              ],
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
                PROCEED_CHECKOUT,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith( color: Colors.white),
              )),
            ),
          ),
        ],
      ),
    );
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
                  //title: productList[index].name,
                )),
          );
        },
      ),
    );
  }
}

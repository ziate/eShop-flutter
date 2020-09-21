import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Helper/Session.dart';
import 'Home.dart';
import 'SubCat.dart';
import 'Sub_Category.dart';

class All_Category extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(ALL_CAT, context),
        body: GridView.count(
            padding: EdgeInsets.all(20),
            crossAxisCount: 4,
            shrinkWrap: true,
            childAspectRatio: .8,
            physics: BouncingScrollPhysics(),
            // mainAxisSpacing: 6,
            // crossAxisSpacing: 3,
            children: List.generate(
              catList.length,
              (index) {
                return catItem(index, context);
              },
            )));
  }

  Widget catItem(int index, BuildContext context) {
    return InkWell(
      child: Column(
        children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: CachedNetworkImage(
                imageUrl: catList[index].image,
                height: 50,
                width: 50,
                fit: BoxFit.fill,
                placeholder: (context, url) => placeHolder(50),
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
                  .copyWith(color: Colors.black),
            ),
          )
        ],
      ),
      onTap: (){
  /*      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubCategory(
                title:catList[index].name,
               subList: catList[index].subList,
              ),
            ));
*/
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubCat(
                title:catList[index].name,
                subList: catList[index].subList,
              ),
            ));


      },
    );
  }
}

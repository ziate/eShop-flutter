import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'Model/Model.dart';
import 'Helper/Session.dart';
import 'ProductList.dart';
import 'Product_Detail.dart';

class SubCat extends StatefulWidget {
  String title;
  List<Model> subList = [];
  final Function updateHome;

  SubCat({this.subList, this.title, this.updateHome});

  @override
  _SubCatState createState() => _SubCatState(subList: subList);
}

class _SubCatState extends State<SubCat> with TickerProviderStateMixin {
  TabController _tc;
  List<Map<String, dynamic>> _tabs = [];
  List<Widget> _views = [];
  List<Model> subList = [];

  _SubCatState({this.subList});

  @override
  void initState() {
    super.initState();
    if (subList != null) this._addInitailTab();
  }

  TabController _makeNewTabController(int pos) => TabController(
        vsync: this,
        length: _tabs.length,
        initialIndex: pos,
      );

  void _addTab(List<Model> subItem, int index) {

    print('add****${subItem[index].name}');


    setState(() {
      _tabs.add({
        // 'text': "Tab ${_tabs.length + 1}",
        'text': subItem[index].name,
      });
      _views.add(createTabContent(index, subItem));
      _tc = _makeNewTabController(_tabs.length - 1);
    });
  }

  void _addInitailTab() {
    setState(() {
      for (int i = 0; i < subList.length; i++) {
        _tabs.add({
          'text': subList[i].name,
        });
        _views.add(createTabContent(i, subList));
      }
      _tc = _makeNewTabController(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tc,
          isScrollable: true,
          tabs: _tabs
              .map((tab) => Tab(
                    text: tab['text'],
                  ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tc,
        key: Key(Random().nextDouble().toString()),
        children: _views.map((view) => view).toList(),
      ),
    );
  }

  Widget createTabContent(int i, List<Model> subList) {
    List<Model> subItem = subList[i].subList;

    return subItem == null || subItem.length == 0
        ? Column(
            children: [
              CachedNetworkImage(
                imageUrl: subList[i].banner,
                height: 150,
                width: double.maxFinite,
                fit: BoxFit.fill,
                placeholder: (context, url) => Image.asset(
                  "assets/images/sliderph.png",
                  height: 150,
                  fit: BoxFit.fill,
                ),
              ),
              Expanded(
                  child:getNoItem())
            ],
          )
        : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: subList[i].banner,
                  height: 150,
                  width: double.maxFinite,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Image.asset(
                    "assets/images/sliderph.png",
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                ),
                GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(
                      subItem.length,
                      (index) {
                        return listItem(index, subItem);
                      },
                    ))
              ],
            ),
          );
  }

  Widget listItem(int index, List<Model> subItem) {

    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: new ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: new CachedNetworkImage(
                    imageUrl: subItem[index].image,
                    height:double.maxFinite,
                    width: double.maxFinite,
                    placeholder: (context, url) => placeHolder(100),
                  ),
                ),
              ),
            ),
            Container(
              child: Text(
                subItem[index].name,
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
        if (subItem[index].subList != null)
          _addTab(subItem, index);
        else
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductList(
                  name: subItem[index].name,
                  id: subItem[index].id,
                  updateHome: widget.updateHome,
                ),
              ));
      },
    );
  }
}

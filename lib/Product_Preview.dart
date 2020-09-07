import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Product_Detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class Product_Preview extends StatefulWidget {
  final int pos;

  const Product_Preview({Key key, this.pos}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StatePreview();
}

class StatePreview extends State<Product_Preview> {
  int curPos;

  @override
  void initState() {
    super.initState();

    curPos = widget.pos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // extendBodyBehindAppBar: true,
        //appBar: getAppBar("", context),
        body: Stack(
      children: <Widget>[
        PageView.builder(
            itemCount: sliderList.length,
            controller: PageController(initialPage: curPos),
            onPageChanged: (index) {
              setState(() {
                curPos = index;
              });
            },
            itemBuilder: (BuildContext context, int index) {
              return PhotoView(
                  backgroundDecoration: BoxDecoration(color: Colors.white),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                  imageProvider:
                      CachedNetworkImageProvider(sliderList[curPos]));
            }),
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: new IconButton(
            icon: new Icon(
              Icons.arrow_back_ios,
              color: primary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Positioned(
            bottom: 10.0,
            left: 25.0,
            right: 25.0,
            child: SelectedPhoto(
              numberOfDots: sliderList.length,
              photoIndex: curPos,
            )),
      ],
    ));
  }
}

class SelectedPhoto extends StatelessWidget {
  final int numberOfDots;
  final int photoIndex;

  SelectedPhoto({this.numberOfDots, this.photoIndex});

  Widget _inactivePhoto() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 3.0, right: 3.0),
        child: Container(
          height: 8.0,
          width: 8.0,
          decoration: BoxDecoration(
              color: primary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4.0)),
        ),
      ),
    );
  }

  Widget _activePhoto() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 5.0, right: 5.0),
        child: Container(
          height: 10.0,
          width: 10.0,
          decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey, spreadRadius: 0.0, blurRadius: 2.0)
              ]),
        ),
      ),
    );
  }

  List<Widget> _buildDots() {
    List<Widget> dots = [];
    for (int i = 0; i < numberOfDots; i++) {
      dots.add(i == photoIndex ? _activePhoto() : _inactivePhoto());
    }
    return dots;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildDots(),
      ),
    );
  }
}

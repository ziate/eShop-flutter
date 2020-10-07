import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Model/Notification_Model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';

class NotificationList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateNoti();
}

List<Notification_Model> notiList = [];
int offset = 0;
int total = 0;
bool isLoadingmore = true;
bool _isLoading = true;

class StateNoti extends State<NotificationList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ScrollController controller = new ScrollController();

  List<Notification_Model> tempList = [];

  @override
  void initState() {
    getNotification();
    controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: _isLoading
            ? Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight),
                child: getProgress())
            : notiList.length == 0
                ? Padding(
                    padding: const EdgeInsets.only(top: kToolbarHeight),
                    child: Center(child: Text(noNoti)))
                : ListView.builder(
                    shrinkWrap: true,
                    controller: controller,
                    itemCount: (offset < total)
                        ? notiList.length + 1
                        : notiList.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      print(
                          "load more****$offset***$total***${notiList.length}***$isLoadingmore**$index");
                      return (index == notiList.length && isLoadingmore)
                          ? Center(child: CircularProgressIndicator())
                          : listItem(index);
                    },
                  ));
  }

  Widget listItem(int index) {
    Notification_Model model = notiList[index];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    model.date,
                    style: TextStyle(color: primary),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      model.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(model.desc)
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(3.0),
                  child: model.img != null
                      ? CachedNetworkImage(
                          imageUrl: model.img,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => placeHolder(50))
                      : Container(
                          height: 0,
                        )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getNotification() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      try {
        // print("product****${widget.id}");

        var parameter = {
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
        };

        Response response =
            await post(getNotificationApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));

        print('response***product*$parameter');
        print('response***product*${response.body.toString()}');

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];

        if (!error) {
          total = int.parse(getdata["total"]);
          print('limit *****$offset****$total');
          if ((offset) < total) {
            tempList.clear();
            var data = getdata["data"];
            tempList = (data as List)
                .map((data) => new Notification_Model.fromJson(data))
                .toList();

            notiList.addAll(tempList);

            offset = offset + perPage;
          }
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg);
          isLoadingmore = false;
        }
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          _isLoading = false;
          isLoadingmore = false;
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

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          print("load more****limit *****$offset****$total");
          if (offset < total) getNotification();
        });
      }
    }
  }
}

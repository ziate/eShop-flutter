import 'package:eshop/Model/User.dart';
import 'package:eshop/Verify_Otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Constant.dart';
import 'Color.dart';

class RadioItem extends StatelessWidget {
  final RadioModel _item;

  RadioItem(this._item);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: new Row(
        children: <Widget>[
          Container(
            height: 20.0,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _item.isSelected ? primary : white,
                border: Border.all(color: grad2Color)),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: _item.isSelected
                  ? Icon(
                      Icons.check,
                      size: 15.0,
                      color: white,
                    )
                  : Icon(
                      Icons.circle,
                      size: 15.0,
                      color: white,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left:15.0),
            child: new Text(_item.name),
          ),
          Spacer(),
          _item.img != "" ? Image.asset(_item.img) : Container()
        ],
      ),
    );
  }
}

class RadioModel {
  bool isSelected;
  final String img;
  final String name;

  RadioModel({this.isSelected, this.name, this.img});
}

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
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _item.addItem.isDefault == "1"
                ? Container(
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: lightWhite,
                  borderRadius: new BorderRadius.only(
                      bottomRight: Radius.circular(10.0))),
              child: Text(
                DEFAULT_LBL,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: fontColor),
              ),
            )
                : Container(),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: new Row(
                children: <Widget>[
                  _item.show
                      ? Container(
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
                  )
                      : Container(),
                  Expanded(
                    child: new Container(
                      margin: new EdgeInsets.only(left: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text(_item.name),
                          new Text(_item.add),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                InkWell(
                                  child: Text(
                                    EDIT,
                                    style: TextStyle(
                                        color: fontColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () {
                                    _item.onEditSelected();
                                  },
                                ),
                                _item.addItem.isDefault == "0"
                                    ? Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: InkWell(
                                        onTap: () {
                                      _item.onSetDefault();
                                  },
                                        child: Container(

                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: lightWhite,
                                          borderRadius: new BorderRadius.all(
                                              const Radius.circular(4.0))),
                                      child: Text(
                                        SET_DEFAULT,
                                        style: TextStyle(
                                            color: fontColor, fontSize: 10),
                                      ),
                                    ),
                                      ),
                                    )
                                    : Container(),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () {
              _item.onDeleteSelected();
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(
                Icons.delete,
                color: black54,
                size: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RadioModel {
  bool isSelected;
  final String add;
  final String name;
  final User addItem;
  final VoidCallback onEditSelected;
  final VoidCallback onDeleteSelected;
  final VoidCallback onSetDefault;
  final show;

  RadioModel({
    this.isSelected,
    this.name,
    this.add,
    this.addItem,
    this.onEditSelected,
    this.onSetDefault,
    this.show,
    this.onDeleteSelected,
  });
}

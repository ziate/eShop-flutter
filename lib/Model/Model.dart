import 'package:flutter/cupertino.dart';

import '../Helper/String.dart';

class Model {
  String id, type, typeId, image;

  String name,   banner;



  Model(
      {this.id,
      this.type,
      this.typeId,
      this.image,
      this.name,

      this.banner,
     });

  factory Model.fromSlider(Map<String, dynamic> parsedJson) {
    return new Model(
        id: parsedJson[ID],
        image: parsedJson[IMAGE],
        type: parsedJson[TYPE],
        typeId: parsedJson[TYPE_ID]);
  }

  factory Model.fromTimeSlot(Map<String, dynamic> parsedJson) {
    return new Model(id: parsedJson[ID], name: parsedJson[TITLE]);
  }

  factory Model.setAllCat(String id, String name) {
    return new Model(
      id: id,
      name: name,
    );
  }


}

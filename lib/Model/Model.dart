import 'package:flutter/cupertino.dart';

import '../Helper/String.dart';

class Model {
  String id, type, typeId, image;

  String name, subtitle, slug, tax, banner;

  List<Model> subList;

  Model(
      {this.id,
      this.type,
      this.typeId,
      this.image,
      this.name,
      this.subtitle,
      this.slug,
      this.tax,
      this.banner,
      this.subList});

  factory Model.fromJson(Map<String, dynamic> parsedJson) {
    return new Model(
        id: parsedJson[ID],
        image: parsedJson[IMAGE],
        type: parsedJson[TYPE],
        typeId: parsedJson[TYPE_ID]);
  }

  factory Model.fromTimeSlot(Map<String, dynamic> parsedJson) {
    return new Model(
      id: parsedJson[ID],
      name: parsedJson[TITLE]
    );
  }

  factory Model.fromCat(Map<String, dynamic> parsedJson) {
    print('getting cat****${parsedJson[NAME]}');

    return new Model(
      id: parsedJson[ID],
      name: parsedJson[NAME],
      subtitle: parsedJson[SUBTITLE],
      image: parsedJson[IMAGE],
      slug: parsedJson[SLUG],
      banner: parsedJson[BANNER],
      tax: parsedJson[TAX],
      subList: createSubList(parsedJson["children"]),
    );
  }

  static List<Model> createSubList(List parsedJson) {
    if (parsedJson == null || parsedJson.isEmpty) return null;

    return parsedJson.map((data) => new Model.fromCat(data)).toList();
  }
}

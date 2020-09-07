import 'package:flutter/cupertino.dart';

import 'String.dart';

class Model {
  String id, type, typeId, image;

  String name, subtitle, slug, tax, banner;

  Model children;

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
      this.children});

  factory Model.fromJson(Map<String, dynamic> parsedJson) {
    return new Model(
        id: parsedJson[ID],
        image: parsedJson[IMAGE],
        type: parsedJson[TYPE],
        typeId: parsedJson[TYPE_ID]);
  }

  factory Model.fromCat(Map<String, dynamic> parsedJson) {
    var data = parsedJson["children"];

    return new Model(
        id: parsedJson[ID],
        name: parsedJson[NAME],
        subtitle: parsedJson[SUBTITLE],
        image: parsedJson[IMAGE],
        slug: parsedJson[SLUG],
        banner: parsedJson[BANNER],
        tax: parsedJson[TAX],
        children: new Model.fromCat(data));
  }

  factory Model.fromSubCat(Map<String, dynamic> parsedJson) {
    return new Model(
      id: parsedJson[ID],
      name: parsedJson[NAME],
      subtitle: parsedJson[SUBTITLE],
      image: parsedJson[IMAGE],
      slug: parsedJson[SLUG],
    );
  }
}

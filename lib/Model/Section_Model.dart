import 'package:eshop/Helper/String.dart';
import 'package:flutter/widgets.dart';

class Section_Model {
  String id,
      title,
      varientId,
      qty,
      productId,
      perItemTotal,
      perItemPrice,
      style,
      short_desc;
  List<Product> productList;

  Section_Model(
      {this.id,
      this.title,
      this.productList,
      this.varientId,
      this.qty,
      this.productId,
      this.perItemTotal,
      this.perItemPrice,
      this.style,
      this.short_desc});

  factory Section_Model.fromJson(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => new Product.fromJson(data))
        .toList();

    return Section_Model(
        id: parsedJson[ID],
        title: parsedJson[TITLE],
        style: parsedJson[STYLE],
        short_desc: parsedJson[SHORT_DESC],
        productList: productList);
  }

  factory Section_Model.fromCart(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => new Product.fromJson(data))
        .toList();

    return Section_Model(
        id: parsedJson[ID],
        varientId: parsedJson[PRODUCT_VARIENT_ID],
        qty: parsedJson[QTY],
        perItemTotal: "0",
        perItemPrice: "0",
        productList: productList);
  }

  factory Section_Model.fromFav(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => new Product.fromJson(data))
        .toList();

    return Section_Model(
        id: parsedJson[ID],
        productId: parsedJson[PRODUCT_ID],
        productList: productList);
  }
}

class Product {
  String id, name, desc, image, catName, type, rating, noOfRating, attrIds;
  List<String> otherImage;
  List<Product_Varient> prVarientList;
  List<Attribute> attributeList;
  String isFav, isReturnable, isCancelable, isPurchased, availability,madein,indicator;
  bool isFavLoading = false;

  // String cartCount;

  Product(
      {this.id,
      this.name,
      this.desc,
      this.image,
      this.catName,
      this.type,
      this.otherImage,
      this.prVarientList,
      this.attributeList,
      this.isFav,
      this.isCancelable,
      this.isReturnable,
      this.isPurchased,
      this.availability,
      this.noOfRating,
      this.attrIds,
      // this.cartCount,
      this.rating,
      this.isFavLoading,
      this.indicator,
      this.madein});

  factory Product.fromJson(Map<String, dynamic> json) {
    List<Product_Varient> varientList = (json[PRODUCT_VARIENT] as List)
        .map((data) => new Product_Varient.fromJson(data))
        .toList();

    List<Attribute> attList = (json[ATTRIBUTES] as List)
        .map((data) => new Attribute.fromJson(data))
        .toList();

    List<String> other_image = List<String>.from(json[OTHER_IMAGE]);

    return new Product(
        id: json[ID],
        name: json[NAME],
        desc: json[DESC],
        image: json[IMAGE],
        catName: json[CAT_NAME],
        rating: json[RATING],
        noOfRating: json[NO_OF_RATE],
        type: json[TYPE],
        isFav: json[FAV].toString(),
        isCancelable: json[ISCANCLEABLE],
        availability: json[AVAILABILITY].toString(),
        isPurchased: json[ISPURCHASED].toString(),
        isReturnable: json[ISRETURNABLE],
        otherImage: other_image,
        prVarientList: varientList,
        attributeList: attList,
        isFavLoading: false,
        attrIds: json[ATTR_VALUE],
        madein: json[MADEIN],
        indicator: json[INDICATOR].toString(),
        // cartCount: json[CART_COUNT]
        );
  }
}

class Product_Varient {
  String id,
      productId,
      attribute_value_ids,
      price,
      disPrice,
      type,
      attr_name,
      varient_value,
availability,
      cartCount;

  Product_Varient(
      {this.id,
      this.productId,
      this.attr_name,
      this.varient_value,
      this.price,
      this.disPrice,
      this.attribute_value_ids,
        this.availability,
      this.cartCount});

  factory Product_Varient.fromJson(Map<String, dynamic> json) {
    return new Product_Varient(
        id: json[ID],
        attribute_value_ids: json[ATTRIBUTE_VALUE_ID],
        productId: json[PRODUCT_ID],
        attr_name: json[ATTR_NAME],
        varient_value: json[VARIENT_VALUE],
        disPrice: json[DIS_PRICE],
        price: json[PRICE],
        availability: json[AVAILABILITY].toString(),
        cartCount: json[CART_COUNT]);
  }
}

class Attribute {
  String id, value, name;

  Attribute({this.id, this.value, this.name});

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return new Attribute(
      id: json[IDS],
      name: json[NAME],
      value: json[VALUE],
    );
  }
}

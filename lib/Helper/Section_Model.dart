import 'package:eshop/Helper/String.dart';

class Section_Model {
  String id, title;
  List<Product> productList;

  Section_Model({this.id, this.title, this.productList});

  factory Section_Model.
  fromJson(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => new Product.fromJson(data))
        .toList();

    return Section_Model(
        id: parsedJson[ID], title: parsedJson[TITLE], productList: productList);
  }
}

class Product {
  String id, name, desc, catId, image, catName;
  List<String> otherImage;
  List<Product_Varient> prVarientList;

  Product(
      {this.id,
      this.name,
      this.desc,
      this.catId,
      this.image,
      this.catName,
      this.otherImage,
      this.prVarientList});

  factory Product.fromJson(Map<String, dynamic> json) {
    List<Product_Varient> varientList = (json[PRODUCT_VARIENT] as List)
        .map((data) => new Product_Varient.fromJson(data))
        .toList();

    List<String> other_image= List<String>.from(json[OTHER_IMAGE]);
        //.cast<String>();
   // List<int> ints = List<int>.from(source);

    return new Product(
        id: json[ID],
        name: json[NAME],
        desc: json[DESC],
        catId: json[CATID],
        image: json[IMAGE],
        catName: json[CAT_NAME],
        otherImage:other_image,
        prVarientList: varientList);
  }
}

class Product_Varient {
  String id,
      productId,
      type,
      measurement,
      measUnitId,
      price,
      disPrice,
      servedFor,
      stock,
      stockUnitId,
      name,
      shortCode;

  Product_Varient(
      {this.id,
      this.productId,
      this.type,
      this.measurement,
      this.measUnitId,
      this.price,
      this.disPrice,
      this.servedFor,
      this.shortCode,
      this.name,
      this.stock,
      this.stockUnitId});

  factory Product_Varient.fromJson(Map<String, dynamic> json) {
    return new Product_Varient(
      id: json[ID],
      name: json[NAME],
      productId: json[PRODUCT_ID],
      type: json[TYPE],
      disPrice: json[DIS_PRICE],
      price: json[PRICE],
      measUnitId: json[MEAS_UNIT_ID],
      measurement: json[MEASUREMENT],
      servedFor: json[SERVE_FOR],
      shortCode: json[SHORT_CODE],
      stock: json[STOCK],
      stockUnitId: json[STOCK_UNIT_ID],
    );
  }
}

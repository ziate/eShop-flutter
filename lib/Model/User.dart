import 'package:eshop/Helper/String.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class User {
  String username,
      email,
      mobile,
      address,
      dob,
      city,
      area,
      street,
      password,
      pincode,
      fcm_id,
      latitude,
      longitude,
      user_id,
      name;

  String id, date, comment, rating;

  User(
      {this.id,
      this.username,
      this.date,
      this.rating,
      this.comment,
      this.email,
      this.mobile,
      this.address,
      this.dob,
      this.city,
      this.area,
      this.street,
      this.password,
      this.pincode,
      this.fcm_id,
      this.latitude,
      this.longitude,
        this.user_id,
        this.name});

  factory User.forReview(Map<String, dynamic> parsedJson) {
    String date = parsedJson['data_added'];



    date = DateFormat('dd-MM-yyyy')
        .format(DateTime.parse(date));
    print('date***$date');
    return new User(
      id: parsedJson[ID],
      date: date,
      rating: parsedJson[RATING],
      comment: parsedJson[COMMENT],
      username: parsedJson[USER_NAME],
    );
  }

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return new User(
      id: parsedJson[ID],
      username: parsedJson[USERNAME],
      email: parsedJson[EMAIL],
      mobile: parsedJson[MOBILE],
      address: parsedJson[ADDRESS],
      dob: parsedJson[DOB],
      city: parsedJson[CITY],
      area: parsedJson[AREA],
      street: parsedJson[STREET],
      password: parsedJson[PASSWORD],
      pincode: parsedJson[PINCODE],
      fcm_id: parsedJson[FCM_ID],
      latitude: parsedJson[LATITUDE],
      longitude: parsedJson[LONGITUDE],
      user_id: parsedJson[USER_ID],
      name: parsedJson[NAME],
    );
  }
}

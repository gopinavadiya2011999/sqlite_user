import 'dart:convert';

import 'package:sqlite_user/database_helper.dart';

class UserModel{
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? userId;

  String? age;

  UserModel({this.userId,this.firstName,this.lastName,this.email, this.password, this.age});

factory  UserModel.fromMap(Map<String, dynamic> map) {
   return UserModel( userId : map['userId'],
       firstName : map['firstName'],
       lastName : map['lastName'],
       email : map['email'],
       password : map['password'],
       age :map['age']);

  }

 static Map<String, dynamic> toMap(UserModel userModel) {
    return {
      DatabaseHelper.userId:userModel. userId,
      DatabaseHelper.firstName: userModel.firstName,
      DatabaseHelper.lastName: userModel.lastName,
      DatabaseHelper.email:userModel. email,
      DatabaseHelper.password: userModel.password,
      DatabaseHelper.age: userModel.age
    };
  }
  static String encode(List<UserModel> userModel) =>
      json.encode(
        userModel
            .map<Map<String, dynamic>>((user) => UserModel.toMap(user))
            .toList(),
      );

  static List<UserModel> decode(String users) =>
      (json.decode(users) as List<dynamic>)
          .map<UserModel>((item) => UserModel.fromMap(item))
          .toList();
}

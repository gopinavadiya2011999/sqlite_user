import 'package:sqlite_user/database_helper.dart';

class UserModel{
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? userId;

  String? age;

  UserModel({this.userId,this.firstName,this.lastName,this.email, this.password, this.age});

  UserModel.fromMap(Map<String, dynamic> map) {
    userId = map['userId'];
    firstName = map['firstName'];
    lastName = map['lastName'];
    email = map['email'];
    password = map['password'];
    age = map['age'];

  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.userId: userId,
      DatabaseHelper.firstName: firstName,
      DatabaseHelper.lastName: lastName,
      DatabaseHelper.email: email,
      DatabaseHelper.password: password,
      DatabaseHelper.age: age
    };
  }
}

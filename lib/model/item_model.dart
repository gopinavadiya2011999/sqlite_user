
import 'package:flutter/cupertino.dart';

class ItemModel {
  String? text;
  bool isSelected=false;
  IconData? icon;

  ItemModel({this.text, this.isSelected=false, this.icon});
}
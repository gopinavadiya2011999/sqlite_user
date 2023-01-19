import 'package:fluttertoast/fluttertoast.dart';

//Long bottom toast
void showBottomLongToast(String value) {
  Fluttertoast.showToast(
      msg: value,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1);
}

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sqlite_user/dashoard/login_view.dart';
import 'package:sqlite_user/home_view.dart';

Future<void> main() async {
  await GetStorage.init();
  runApp(const MyApp());
}
final box = GetStorage();

Future<void> dismissKeyboard(BuildContext context) async =>
    FocusScope.of(context).unfocus();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home:box.read('login')==true?const HomeView(): const LoginView(),
    );
  }
}


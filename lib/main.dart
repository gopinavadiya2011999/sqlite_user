import 'package:flutter/material.dart';
import 'package:sqlite_user/dashoard/register_view.dart';

void main() {
  runApp(const MyApp());
}

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
      home: RegisterView(),
    );
  }
}


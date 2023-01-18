import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_user/constant/text_style_constant.dart';
import 'package:sqlite_user/dashoard/register_view.dart';

import '../constant/color_constant.dart';
import '../main.dart';
import '../model/user_model.dart';
import '../widgets/custom_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String invalidEmail = '';
  String invalidPwd = '';
  bool isValidForm = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();

    clearController();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text("SIGN IN",
                      style: TextStyleConstant.titleStyle
                          .copyWith(color: ColorConstant.orange)),
                  const SizedBox(height: 20),
                  customTextField(
                      errorText: invalidEmail,
                      keyboardType: TextInputType.emailAddress,
                      // validator: (email) => emailValidation(email: email),
                      controller: emailController,
                      hintText: 'Please enter email',
                      labelText: 'Email'),
                  const SizedBox(height: 10),
                  customTextField(
                      obscure: true,
                      keyboardType: TextInputType.text,
                      //validator: (pwd) => validatePassword(pwd),
                      controller: pwdController,
                      errorText: invalidPwd,
                      hintText: 'Please enter password',
                      labelText: 'Password'),
                  const SizedBox(height: 50),
                  InkWell(
                      onTap: () {
                        _checkValidation();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: ColorConstant.orange),
                        child: Text(
                          'sign in'.toUpperCase(),
                          style: TextStyleConstant.skipStyle
                              .merge(TextStyle(color: ColorConstant.white)),
                        ),
                      )),
                  Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: "Sign in to your account",
                              style: TextStyleConstant.skipStyle
                                  .copyWith(color: ColorConstant.grey88)),
                          TextSpan(
                            text: ' Sign Up',
                            style: TextStyleConstant.skipStyle,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                clearController();

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterView(),
                                    ));
                              },
                          )
                        ]),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<UserModel> userModel = [];

  getAllUsers() async {
    final allRows = await dbHelper.getAllUser();

    setState(() {
      userModel.clear();
      for (var element in allRows) {
        userModel.add(UserModel.fromMap(element));
      }
    });
    print('Query done ::${allRows.map((e) => e).toList()}');
  }

  void clearController() {
    invalidPwd = '';
    invalidEmail = '';
    pwdController.clear();
    emailController.clear();
  }

  Future<void> _checkValidation() async {
    if (_formKey.currentState!.validate()) {
      dismissKeyboard(context);
      setState(() {
        isValidForm = true;
      });
      UserModel userData = userModel
          .where((element) =>
              element.email == emailController.text &&
              element.password == pwdController.text)
          .first;
      print("login success");
      // Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
    } else {
      setState(() {
        isValidForm = false;
      });
    }
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_user/constant/text_style_constant.dart';
import 'package:sqlite_user/dashoard/register_view.dart';
import 'package:sqlite_user/utils/toast.dart';

import '../constant/color_constant.dart';
import '../home_view.dart';
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
    super.initState();
    clearController();

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
                      validator: (email) {
                        invalidEmail = '';
                        if (email!.isEmpty) {
                          invalidEmail = 'Please enter email';
                          return;
                        } else if (!RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(email)) {
                          invalidEmail = 'Please enter valid email';
                        }
                        setState(() {});
                        return null;
                      },
                      controller: emailController,
                      hintText: 'Please enter email',
                      labelText: 'Email'),
                  const SizedBox(height: 10),
                  customTextField(
                      obscure: true,
                      keyboardType: TextInputType.text,
                      validator: (pwd) {
                        invalidPwd = '';
                        if (pwd!.isEmpty) {
                          invalidPwd = 'Please enter password';
                          return;
                        }
                        return null;
                      },
                      controller: pwdController,
                      errorText: invalidPwd,
                      hintText: 'Please enter password',
                      labelText: 'Password'),
                  const SizedBox(height: 50),
                  logInButton(),
                  _richText()
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

  _checkValidation() {
    if (_formKey.currentState!.validate() &&
        emailController.text.trim().isNotEmpty &&
        pwdController.text.trim().isNotEmpty) {
      dismissKeyboard(context);
      setState(() {
        isValidForm = true;
      });
      if (userModel.isNotEmpty) {
        login();
      } else {
        showBottomLongToast('Credential do not match to our records');
      }
    } else {
      setState(() {
        isValidForm = false;
      });
    }
  }

  logInButton() {
    return InkWell(
        onTap: () {
          print("user Modcel :: ${userModel.map((e) => e.password)}");
          print("user Modcel :: ${userModel.map((e) => e.email)}");
          _checkValidation();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ColorConstant.orange),
          child: Text(
            'sign in'.toUpperCase(),
            style: TextStyleConstant.skipStyle
                .merge(TextStyle(color: ColorConstant.white)),
          ),
        ));
  }

  _richText() {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: "Don't have an account?",
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
                        builder: (context) => const RegisterView(),
                      ));
                },
            )
          ]),
        ));
  }

  void login() {
    UserModel? userData = userModel
            .where((element) =>
                element.email == emailController.text.trim() &&
                element.password == pwdController.text.trim())
            .toList()
            .isNotEmpty
        ? userModel
            .where((element) =>
                element.email == emailController.text.trim() &&
                element.password == pwdController.text.trim())
            .toList()
            .first
        : null;

    if (userData != null) {
      String encodeData = UserModel.encode([
        UserModel(
          age: userData.age,
          password: userData.password,
          firstName: userData.firstName,
          lastName: userData.lastName,
          userId: userData.userId,
          email: userData.email,
        )
      ]);
      box.write('save', encodeData);
      box.write('login', true);
      showBottomLongToast("Login successfully");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
          (route) => false);
    } else {
      showBottomLongToast("Credential do not match to our records");
    }
  }
}

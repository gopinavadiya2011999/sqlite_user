import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_user/constant/color_constant.dart';
import 'package:sqlite_user/constant/common_constant.dart';
import 'package:sqlite_user/database_helper.dart';
import 'package:sqlite_user/home_view.dart';
import 'package:sqlite_user/model/user_model.dart';
import 'package:sqlite_user/utils/date_util.dart';
import 'package:sqlite_user/utils/toast.dart';
import 'package:uuid/uuid.dart';

import '../constant/text_style_constant.dart';
import '../main.dart';
import '../widgets/custom_text_field.dart';
import 'login_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

final dbHelper = DatabaseHelper.instance;

class _RegisterViewState extends State<RegisterView> {
  String initValue = "Select your Birth Date";
  bool isDateSelected = false;
  DateTime? birthDate; // instance of DateTime
  String invalidEmail = '';
  String invalidPwd = '';
  String invalidFN = '';
  String invalidLN = '';
  String invalidAge = '';
  AgeDuration? ageDuration;

  bool isValidForm = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();

    clearController();
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
                  Text("SIGN UP",
                      style: TextStyleConstant.titleStyle
                          .copyWith(color: ColorConstant.orange)),
                  const SizedBox(height: 20),
                  customTextField(
                      errorText: invalidFN,
                      keyboardType: TextInputType.text,
                      validator: (fName) {
                        invalidFN = '';
                        if (fName!.isEmpty) {
                          invalidFN = 'Please enter first name';
                          return;
                        }
                        return null;
                      },
                      controller: fNameController,
                      hintText: 'Please enter first name',
                      labelText: 'First Name'),
                  const SizedBox(height: 10),
                  customTextField(
                      errorText: invalidLN,
                      keyboardType: TextInputType.text,
                      validator: (lName) {
                        invalidLN = '';
                        if (lName.isEmpty) {
                          invalidLN = 'Please enter last name';
                          return;
                        }
                        return null;
                      },
                      controller: lNameController,
                      hintText: 'Please enter last name',
                      labelText: 'Last Name'),
                  const SizedBox(height: 10),
                  customTextField(
                      errorText: invalidEmail,
                      keyboardType: TextInputType.emailAddress,
                      validator: (email) => emailValidation(email: email),
                      controller: emailController,
                      hintText: 'Please enter email',
                      labelText: 'Email'),
                  const SizedBox(height: 10),
                  customTextField(
                      obscure: true,
                      keyboardType: TextInputType.text,
                      validator: (pwd) => validatePassword(pwd),
                      controller: pwdController,
                      errorText: invalidPwd,
                      hintText: 'Please enter password',
                      labelText: 'Password'),
                  const SizedBox(height: 10),
                  _dobField(),
                  const SizedBox(height: 50),
                  _signUpButton(),
                  _richText()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  emailValidation({required email}) {
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
  }

  validatePassword(String value) {
    invalidPwd = '';
    RegExp regex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (value.isEmpty) {
      invalidPwd = 'Please enter password';
    } else if (value.length <= 8) {
      invalidPwd = 'Please enter at list 8 characters';
    } else {
      if (!regex.hasMatch(value)) {
        invalidPwd =
            'Enter strong password must contain \nMinimum 1 Upper case \nMinimum 1 lowercase \nMinimum 1 Numeric Number \nMinimum 1 \nSpecial Character Common Allow Character ( ! @ # \$ & * ~ )';
      } else {
        return null;
      }
    }
  }

  void clearController() {
    invalidFN = '';
    invalidPwd = '';
    invalidAge = '';
    invalidEmail = '';
    invalidLN = '';
    pwdController.clear();
    lNameController.clear();
    fNameController.clear();
    emailController.clear();
    ageController.clear();
  }

  Future<void> _checkValidation() async {
    if (_formKey.currentState!.validate() &&
        invalidAge.isEmpty &&
        pwdController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        fNameController.text.trim().isNotEmpty &&
        ageController.text.trim().isNotEmpty &&
        lNameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty) {
      dismissKeyboard(context);
      setState(() {
        isValidForm = true;
      });
      await registerUser();
    } else {
      setState(() {
        isValidForm = false;
      });

      if (invalidAge.contains('You should be 13 years old to register')) {
        showBottomLongToast('You should be 13 years old to register');
      }
    }
  }

  _dobField() {
    return customTextField(
        onTap: () async {
          final datePick = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(DateTime.now().year - 110),
              lastDate: DateTime.now());
          if (datePick != null && datePick != birthDate) {
            setState(() {
              birthDate = datePick;
              ageDuration = getAge(
                  month: birthDate!.month,
                  day: birthDate!.day,
                  year: birthDate!.year);
              print("(((${ageDuration!.years}");
              isDateSelected = true;
              if (ageDuration!.years < 13) {
                invalidAge = "You should be 13 years old to register";
              } else {
                invalidAge =
                    "You are ${ageDuration!.years} years ${ageDuration!.months} months ${ageDuration!.days.toString()} days old";
              }
              ageController.text =
                  "${birthDate!.month}/${birthDate!.day}/${birthDate!.year}";
            });
          }
        },
        readOnly: true,
        errorText: invalidAge,
        keyboardType: TextInputType.none,
        validator: (age) {
          invalidAge = '';
          if (age.isEmpty) {
            invalidAge = 'Please select birthdate';
            return;
          }
          if (ageDuration!.years < 13) {
            invalidAge = "You should be 13 years old to register";
            return;
          }
          return null;
        },
        controller: ageController,
        prefixIcon: InkWell(
            child: Container(
                margin: const EdgeInsets.only(left: 5, right: 5),
                child: const Icon(Icons.calendar_month_rounded))),
        hintText: 'Please select birthdate',
        labelText: 'Select Birthdate');
  }

  _signUpButton() {
    return InkWell(
        onTap: () {
          _checkValidation();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ColorConstant.orange),
          child: Text(
            'sign up'.toUpperCase(),
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
                text: "Sign in to your account",
                style: TextStyleConstant.skipStyle
                    .copyWith(color: ColorConstant.grey88)),
            TextSpan(
              text: ' Sign In',
              style: TextStyleConstant.skipStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  clearController();

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginView(),
                      ));
                },
            )
          ]),
        ));
  }

  Future<void> registerUser() async {
    var uuid = const Uuid();
    Map<String, dynamic> row = {
      DatabaseHelper.userId: uuid.v1(),
      DatabaseHelper.age: ageController.text.trim(),
      DatabaseHelper.password: pwdController.text.trim(),
      DatabaseHelper.firstName: fNameController.text.trim(),
      DatabaseHelper.lastName: lNameController.text.trim(),
      DatabaseHelper.email: emailController.text.trim(),
    };

    UserModel userModel = UserModel.fromMap(row);
    await dbHelper.registerUser(userModel);
    String encodeData = UserModel.encode([
      UserModel(
        age: userModel.age,
        password: userModel.password,
        firstName: userModel.firstName,
        lastName: userModel.lastName,
        userId: userModel.userId,
        email: userModel.email,
      )
    ]);
    box.write('save', encodeData);
    box.write('login', true);
    showBottomLongToast("Account created successfully");
    setState(() {});
    clearController();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => HomeView()), (route) => false);
  }
}

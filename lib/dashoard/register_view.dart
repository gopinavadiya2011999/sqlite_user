import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_user/constant/color_constant.dart';
import 'package:sqlite_user/database_helper.dart';
import 'package:sqlite_user/model/user_model.dart';
import 'package:sqlite_user/utils/date_util.dart';
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
                  customTextField(
                      onTap: () async {
                        final datePick = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100));
                        if (datePick != null && datePick != birthDate) {
                          setState(() {
                            birthDate = datePick;
                            AgeDuration ageDuration = getAge(
                                month: birthDate!.month,
                                day: birthDate!.day,
                                year: birthDate!.year);
                            isDateSelected = true;
                            invalidAge = "You are ${ageDuration.years} years ${ageDuration.months} months ${ageDuration
                                .days.toString()} days old";
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
                          invalidAge = 'Please select age';
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
                      labelText: 'Select Birthdate'),
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
                          'sign up'.toUpperCase(),
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
                      ))
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

  List<UserModel> userModel=[];
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
  validatePassword(String value) {
    /*
    Minimum 1 Upper case
Minimum 1 lowercase
Minimum 1 Numeric Number
Minimum 1 Special Character
Common Allow Character ( ! @ # $ & * ~ )
*/
    invalidPwd = '';
    RegExp regex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (value.isEmpty) {
      invalidPwd = 'Please enter password';
    } else {
      if (!regex.hasMatch(value)) {
        invalidPwd = 'Enter valid password';
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

  getAge({required int year, required int day, required int month}) {
    DateTime birthday = DateTime(year, day, month);
    DateTime today = DateTime.now(); //2020/1/24

    AgeDuration? age;
    // Find out your age
    age = Age.dateDifference(
        fromDate: birthday, toDate: today, includeToDate: false);

    print('Your age is $age'); // Your age is Years: 30, Months: 0, Days: 4
    return age;
    // Find out when your next birthday will be.
    // DateTime tempDate = DateTime(today.year, birthday.month, birthday.day);
    // DateTime nextBirthdayDate = tempDate.isBefore(today)
    //     ? Age.add(date: tempDate, duration: AgeDuration(years: 1))
    //     : tempDate;
    // AgeDuration nextBirthdayDuration =
    // Age.dateDifference(fromDate: today, toDate: nextBirthdayDate);
    //
    // print('You next birthday will be on $nextBirthdayDate or in $nextBirthdayDuration');
  }

  Future<void> _checkValidation() async {
    if (_formKey.currentState!.validate()) {
      dismissKeyboard(context);
      setState(() {
        isValidForm = true;
      });
      var uuid = const Uuid();
      Map<String, dynamic> row = {
        DatabaseHelper.userId: uuid.v1(),
        DatabaseHelper.age: ageController.text,
        DatabaseHelper.password: pwdController.text,
        DatabaseHelper.firstName:fNameController.text,
        DatabaseHelper.lastName: lNameController.text,
        DatabaseHelper.email: emailController.text,
      };
      UserModel userModel = UserModel.fromMap(row);
      await dbHelper.registerUser(userModel);
      setState(() {});

      print("signup success");
      // Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
    } else {
      setState(() {
        isValidForm = false;
      });
    }
  }
}

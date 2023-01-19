import 'package:flutter/material.dart';
import 'package:sqlite_user/constant/color_constant.dart';
import 'package:sqlite_user/constant/common_constant.dart';
import 'package:sqlite_user/constant/text_style_constant.dart';
import 'package:sqlite_user/dashoard/register_view.dart';
import 'package:sqlite_user/main.dart';
import 'package:sqlite_user/model/user_model.dart';
import 'package:sqlite_user/utils/date_util.dart';
import 'package:sqlite_user/utils/toast.dart';
import 'utils/cusotm_pop_up.dart';
import 'widgets/logout.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<UserModel> prefUser = [];

  List<UserModel> userModel = [];

  getAllUsers() async {
    final allRows = await dbHelper.getAllUser();

    setState(() {
      userModel.clear();
      for (var element in allRows) {
        userModel.add(UserModel.fromMap(element));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getAllUsers();
    final String decodeData = box.read('save');
    prefUser = UserModel.decode(decodeData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                'Hii, ${prefUser.first.firstName!} ${prefUser.first.lastName!}'),
            _popUpButton()
          ],
        ),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: userModel.length,
          itemBuilder: (context, index) {
            AgeDuration age = getAge(
                month: int.parse(userModel[index].age!.split('/').first),
                year: int.parse(userModel[index].age!.split('/').last),
                day: int.parse(userModel[index].age!.split('/')[1]));
            return _listData(age: age, userData: userModel[index]);
          }),
    );
  }

  _popUpButton() {
    return CustomPopupMenu(
      showArrow: false,
      horizontalMargin: 10,
      barrierColor: Colors.transparent,
      onTap: ({String? item}) {
        if (item == 'Logout') {
          logOutDialog(context);
        } else if (item == 'Filter by name') {
          userModel.sort((a, b) => (a.firstName!.toLowerCase())
              .compareTo(b.firstName!.toLowerCase()));
          showBottomLongToast("Users filtered by name");

          setState(() {});
        } else {
          userModel.sort((a, b) => getAge(
                  month: int.parse(b.age!.split('/').first),
                  year: int.parse(b.age!.split('/').last),
                  day: int.parse(b.age!.split('/')[1]))
              .toString()
              .compareTo(getAge(
                      month: int.parse(a.age!.split('/').first),
                      year: int.parse(a.age!.split('/').last),
                      day: int.parse(a.age!.split('/')[1]))
                  .toString()));
          showBottomLongToast("Users filtered by age");

          setState(() {});
        }
      },
      pressType: PressType.singleClick,
      position: PreferredPosition.bottom,
      child: Icon(Icons.more_vert_outlined, color: ColorConstant.white),
    );
  }

  Widget _listData({required AgeDuration age, required UserModel userData}) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            color: ColorConstant.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  color: ColorConstant.grey.withOpacity(0.3),
                  offset: const Offset(0, 3),
                  spreadRadius: 1,
                  blurRadius: 10)
            ]),
        child: Column(
          children: [
            _firstRow(userData: userData),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Your age =>", style: TextStyleConstant.grey12.copyWith(fontSize: 14)),
                Text('Year: ${age.years}', style: TextStyleConstant.grey12.copyWith(fontSize: 14)),
                Text('Months: ${age.months}',
                    style: TextStyleConstant.grey12.copyWith(fontSize: 14)),
                Text('Days: ${age.days}', style:TextStyleConstant.grey12.copyWith(fontSize: 14))
              ],
            )
          ],
        ));
  }

  _firstRow({required UserModel userData}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${userData.firstName!} ${userData.lastName!}",
              style: TextStyleConstant.black12.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(userData.email!,
                style: TextStyleConstant.grey12.copyWith(fontSize: 14)),
          ],
        ),
        Text(userData.age!,
            style: TextStyleConstant.grey12.copyWith(fontSize: 14)),
      ],
    );
  }
}

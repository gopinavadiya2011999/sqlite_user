import 'package:flutter/material.dart';
import 'package:sqlite_user/constant/color_constant.dart';
import 'package:sqlite_user/constant/text_style_constant.dart';
import 'package:sqlite_user/dashoard/login_view.dart';
import 'package:sqlite_user/utils/toast.dart';

logOutDialog(context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        actionsPadding: EdgeInsets.zero,
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              customDivider(
                  color: ColorConstant.grey88.withOpacity(.3),
                  context: context,
                  width: double.infinity),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    logOutAlertButton(
                        buttonText: 'Cancel',
                        onTap: () => Navigator.pop(context)),
                    Container(
                        width: 1, color: ColorConstant.grey88.withOpacity(.5)),
                    logOutAlertButton(
                        buttonText: 'Logout',
                        onTap: () {
                          showBottomLongToast("User logged out");
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginView(),
                              ),
                              (route) => false);
                        }),
                  ],
                ),
              )
            ],
          )
        ],
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Logout", style: TextStyleConstant.titleStyle.copyWith(color: ColorConstant.orange)),
            const SizedBox(height: 24),
            Text("Are you sure do you want to logout?",
                style: TextStyleConstant.grey18)
          ],
        ),
      );
    },
  );
}

customDivider(
    {Color? color,
    required BuildContext context,
    EdgeInsetsGeometry? margin,
    double? width}) {
  return Container(
    margin: margin ?? EdgeInsets.zero,
    height: 1,
    color: color ?? ColorConstant.grey88,
  );
}

logOutAlertButton(
    {required GestureTapCallback onTap, required String buttonText}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style:
              TextStyleConstant.grey18.copyWith(color: ColorConstant.black22),
        ),
      ),
    ),
  );
}

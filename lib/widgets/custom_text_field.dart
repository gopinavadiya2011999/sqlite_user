import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqlite_user/constant/color_constant.dart';

import '../constant/text_style_constant.dart';

customTextField(
    {required String hintText,
    required String labelText,
    String? suffixIcon,
    String? errorText,
      bool readOnly=false,
    FormFieldValidator? validator,
    bool obscure = false,
    double? maxWidth,

      GestureTapCallback ?onTap,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    required TextEditingController controller}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(labelText),
      const SizedBox(height: 9),
      Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: ColorConstant.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
              spreadRadius: 1)
        ], color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: TextFormField(
          onTap: onTap,


readOnly: readOnly,
          inputFormatters: inputFormatters,
          obscureText: obscure ? true : false,
          validator: validator,
          keyboardType: keyboardType ?? TextInputType.text,
          style: TextStyleConstant.skipStyle
              .merge(TextStyle(color: ColorConstant.black22)),
//          showCursor: true,
          controller: controller,
          cursorColor: ColorConstant.orange,
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
            prefixIconConstraints:
                BoxConstraints(maxWidth: maxWidth ?? 43, maxHeight: 42),
            suffixIconConstraints:
                const BoxConstraints(maxWidth: 45, maxHeight: 45),
            prefixIcon: prefixIcon ?? const SizedBox(width: 15),
            suffixIcon: suffixIcon != null
                ? Container(
                    margin: const EdgeInsets.only(right: 15, left: 10),
                    child: Image.asset(suffixIcon))
                : SizedBox(),
            hintText: hintText,
            hintStyle: TextStyleConstant.descStyle,
            border: InputBorder.none,
          ),
        ),
      ),
      if (errorText != null && errorText.isNotEmpty)
        Align(
          alignment: AlignmentDirectional.topStart,
          child: Container(
            margin: const EdgeInsets.only(top: 8,bottom: 8),
            child: Text(
              errorText,
              textAlign: TextAlign.start,
              style: TextStyle(color: ColorConstant.errorColor),
            ),
          ),
        )
    ],
  );
}

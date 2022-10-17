import 'package:flutter/material.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';

Widget textField(TextEditingController controller, String hintText,
      Widget iconS, bool isPass,{bool isObscure=true,Function? fun}) {
    return SizedBox(
      height: 50,
        child: TextFormField(
            controller: controller,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyles.blue18SemiBoldIt,
            obscureText: isPass ? isObscure : false,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyles.blue18SemiBoldIt,
              filled: true,
              fillColor: ColorsJunghanns.whiteJ,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              prefixIcon: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: iconS),
              suffixIcon: isPass
                  ? IconButton(onPressed: ()=>fun!=null?fun():(){}, icon: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            color: ColorsJunghanns.blueJ2,
          ))
                  : const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10)),
            )));
  }
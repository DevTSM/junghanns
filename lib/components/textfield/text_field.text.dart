import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';

Widget textField(TextEditingController controller, String hintText,
      Widget iconS, bool isPass,{bool isObscure=true,Function? fun,int max=20}) {
    return SizedBox(
      height: 50,
        child: TextFormField(
            controller: controller,
            maxLength: max,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyles.blue18SemiBoldIt,
            obscureText: isPass ? isObscure : false,
            decoration: InputDecoration(
               counterText: "",
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
  Widget textField2(Function fun,TextEditingController controller, String hintText,{Function? ontap,int max=3,TextInputType type=TextInputType.text,TextStyle? style}) {
    return SizedBox(
      height: 50,
        child: TextFormField(
            controller: controller,
            maxLength: max,
            keyboardType: type,
            onTap: ontap!=null?()=>ontap():(){},
            onChanged: (value)=>fun(value),
            textAlignVertical: TextAlignVertical.center,
            style: style??TextStyles.greenJ30Bold,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              counterStyle: style??TextStyles.greenJ30Bold,
               counterText: "",
              hintText: hintText,
              hintStyle: TextStyles.blue18SemiBoldIt,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,),
            ));
  }
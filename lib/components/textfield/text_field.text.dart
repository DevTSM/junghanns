import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';

Widget textField(
  TextEditingController controller, 
  String hintText,
  Widget iconS, 
  bool isPass,
  {bool isObscure=true,
    Function? fun,
    int max=20,
    BoxDecoration decoration=const BoxDecoration()
  }
) {
    return Container(
      decoration: decoration,
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
  Widget textField2(
    Function fun,
    TextEditingController controller, 
    String hintText,
    {Function? ontap,
      int max=3,
      TextInputType type=TextInputType.text,
      TextStyle? style
    }
  ) {
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
  Widget textFieldLabel(
    TextEditingController controller,
    String title,
    String hint,
    String err,
    { int numLines = 1,
      bool isRequired = false, 
      bool isNumber = false,
      bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 15, bottom: 2, left: 10),
          child: isRequired
            ? RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: title,style: JunnyText.semiBoldBlueA1(15)),
                  TextSpan(text: "*",style: JunnyText.red5c(18))
                ]
              )
            )
            : Text(
            title,
            style: JunnyText.semiBoldBlueA1(15),
          ),
        ),
        //Field
        TextFormField(
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyles.blueJ15SemiBold,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: numLines,
          maxLength: numLines == 5 ? 60 : null,
          inputFormatters: isPhone ? [MaskedInputFormatter("###  ###  ####")] : [],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyles.grey15Itw,
            filled: true,
            fillColor: ColorsJunghanns.white,
            contentPadding: const EdgeInsets.only(left: 12, top: 10),
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderSide: err != ""
                ? const BorderSide(width: 1, color: Colors.red)
                : const BorderSide(width: 1, color: ColorsJunghanns.lighGrey),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 1, color: ColorsJunghanns.blueJ),
              borderRadius: BorderRadius.circular(10),
            ),
          )
        ),
        err.isNotEmpty
          ? Container(
            padding: const EdgeInsets.only(top: 4, left: 15),
            child: Text(
              err,
              style: TextStyles.redJ13N,
            )
          )
          : const SizedBox.shrink()
      ],
    );
  }
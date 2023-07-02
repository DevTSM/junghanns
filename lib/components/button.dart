//import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';

class ButtonJunghanns extends StatelessWidget {
  Widget? icon;
  BoxDecoration decoration;
  BoxDecoration decorationInactive;
  Function fun;
  TextStyle style;
  TextStyle styleInactive;
  String label;
  bool isIcon;
  bool isActive;
  ButtonJunghanns(
      {Key? key,
      this.icon,
      required this.fun,
      required this.decoration,
      required this.style,
      required this.label,
      this.decorationInactive=Decorations.lighGreyBorder30,
      this.styleInactive=TextStyles.grey14_7,
      this.isIcon = false,
      this.isActive=true})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: isActive?() => fun():(){},
        child: Container(
          decoration: isActive?decoration:decorationInactive,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: 10,
                  )),
              isIcon ? icon! : Container(),
              const Expanded(
                  flex: 2,
                  child: SizedBox(
                    width: 10,
                  )),
              Text(
                label,
                style: isActive?style:styleInactive,
              ),
              const Expanded(
                  flex: 3,
                  child: SizedBox(
                    width: 10,
                  )),
            ],
          ),
        ));
  }
}

class ButtonJunghannsLabel extends StatelessWidget {
  BoxDecoration decoration;
  Function fun;
  TextStyle style;
  String label;
  double width;
  ButtonJunghannsLabel(
      {Key? key,
      required this.fun,
      required this.decoration,
      required this.style,
      required this.label,
      required this.width})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => fun(),
        child: Container(
          alignment: Alignment.center,
          width: width,
          decoration: decoration,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            label,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ));
  }
}

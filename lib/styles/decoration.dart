import 'package:flutter/material.dart';
import 'package:junghanns/styles/color.dart';

class Decorations {
  static const BoxDecoration orangeBorder5 = BoxDecoration(
    color: ColorsJunghanns.orange,
    borderRadius: BorderRadius.all(Radius.circular(5))
  );
  static const BoxDecoration blueBorder12 = BoxDecoration(
    color: ColorsJunghanns.blue,
    borderRadius: BorderRadius.all(Radius.circular(12))
  );
  static const BoxDecoration whiteBorder12 = BoxDecoration(
    color: ColorsJunghanns.white,
    borderRadius: BorderRadius.all(Radius.circular(12))
  );
  static BoxDecoration junghannsWater = const BoxDecoration(
    
    image: DecorationImage(image: AssetImage("assets/images/junghannsWater2.png"),fit: BoxFit.cover,colorFilter: ColorFilter.mode(ColorsJunghanns.white, BlendMode.dstATop),)
  );
}
import 'package:flutter/material.dart';
import 'package:junghanns/styles/color_styles.dart';

abstract class TextStyles {
  static TextStyle blue18SemiBoldIt = const TextStyle(
      fontSize: 18,
      fontFamily: 'MyriadPro-SemiBoldit',
      color: ColorStyles.blueJ2);

  static TextStyle blue13It = const TextStyle(
      fontSize: 13, fontFamily: 'MyriadPro-it', color: ColorStyles.blueJ2);

  static TextStyle white16SemiBoldIt = const TextStyle(
      fontSize: 16, fontFamily: 'MyriadPro-SemiBoldit', color: Colors.white);

  static TextStyle blue17SemiBoldUnderline = const TextStyle(
      fontSize: 17,
      fontFamily: 'MyriadPro-SemiBold',
      color: ColorStyles.blueJ2,
      decoration: TextDecoration.underline,
      decorationThickness: 2);

  static TextStyle blue15SemiBold = const TextStyle(
      fontSize: 15,
      fontFamily: 'MyriadPro-SemiBold',
      color: ColorStyles.blueJ2);
}

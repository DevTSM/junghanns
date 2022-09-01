import 'package:flutter/material.dart';
import 'package:junghanns/styles/color.dart';

class Decorations {
  static BoxDecoration whiteBorder5Grey = BoxDecoration(
      color: ColorsJunghanns.white,
      border: Border.all(color: ColorsJunghanns.grey),
      borderRadius: const BorderRadius.all(Radius.circular(5)));
  static const BoxDecoration orangeBorder5 = BoxDecoration(
      color: ColorsJunghanns.orange,
      borderRadius: BorderRadius.all(Radius.circular(5)));
  static const BoxDecoration greenBorder5 = BoxDecoration(
      color: ColorsJunghanns.green,
      borderRadius: BorderRadius.all(Radius.circular(5)));
  static BoxDecoration whiteBorder5Red = BoxDecoration(
      color: ColorsJunghanns.white,
      border: Border.all(color: ColorsJunghanns.red),
      borderRadius: const BorderRadius.all(Radius.circular(5)));

  static BoxDecoration whiteBorder10Red = BoxDecoration(
      color: ColorsJunghanns.white,
      border: Border.all(color: ColorsJunghanns.red),
      borderRadius: const BorderRadius.all(Radius.circular(10)));

  static const BoxDecoration lightBlueBorder5 = BoxDecoration(
      color: ColorsJunghanns.lightBlue,
      borderRadius: BorderRadius.all(Radius.circular(5)));
  static const BoxDecoration blueBorder12 = BoxDecoration(
      color: ColorsJunghanns.blue,
      borderRadius: BorderRadius.all(Radius.circular(12)));

  static const BoxDecoration blueBorder30 = BoxDecoration(
      color: ColorsJunghanns.blue,
      borderRadius: BorderRadius.all(Radius.circular(30)));

  static const BoxDecoration whiteBorder12 = BoxDecoration(
      color: ColorsJunghanns.white,
      borderRadius: BorderRadius.all(Radius.circular(12)));
  static BoxDecoration junghannsWater = const BoxDecoration(
      image: DecorationImage(
    image: AssetImage("assets/images/junghannsWater2.png"),
    fit: BoxFit.cover,
    colorFilter: ColorFilter.mode(ColorsJunghanns.white, BlendMode.dstATop),
  ));

  static BoxDecoration whiteCard = const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
      boxShadow: [
        BoxShadow(
          color: ColorsJunghanns.lighGrey,
          blurRadius: 4.0,
        )
      ]);

  static BoxDecoration whiteS1Card = const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
      boxShadow: [
        BoxShadow(
          color: ColorsJunghanns.lighGrey,
          blurRadius: 1.0,
        )
      ]);

  static BoxDecoration whiteSblackCard = const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 1.0,
        )
      ]);

  static BoxDecoration white2Card = const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  );

  static BoxDecoration blueCard = const BoxDecoration(
      color: ColorsJunghanns.blueJ3,
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
      boxShadow: [
        BoxShadow(
          color: ColorsJunghanns.lighGrey,
          blurRadius: 3.0,
        )
      ]);

  static BoxDecoration whiteJCard = const BoxDecoration(
      color: ColorsJunghanns.whiteJ,
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
      boxShadow: [
        BoxShadow(
          color: ColorsJunghanns.lighGrey,
          blurRadius: 3.0,
        )
      ]);

  static BoxDecoration blueJ2Card = const BoxDecoration(
    color: ColorsJunghanns.blueJ2,
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  );

  static BoxDecoration redCard = const BoxDecoration(
    color: ColorsJunghanns.red,
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  );

  static BoxDecoration redCardB30 = const BoxDecoration(
    color: ColorsJunghanns.red,
    borderRadius: BorderRadius.all(
      Radius.circular(30),
    ),
  );

  static BoxDecoration greenJCard = const BoxDecoration(
    color: ColorsJunghanns.greenJ,
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  );

  static BoxDecoration greenJCardB30 = const BoxDecoration(
    color: ColorsJunghanns.greenJ,
    borderRadius: BorderRadius.all(
      Radius.circular(30),
    ),
  );

  static BoxDecoration lightBlueS1Card = const BoxDecoration(
      color: ColorsJunghanns.lightBlue,
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
      boxShadow: [
        BoxShadow(
          color: ColorsJunghanns.lighGrey,
          blurRadius: 1.0,
        )
      ]);

  static BoxDecoration whiteS2Card = const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black,
          blurRadius: 1.0,
        )
      ]);
}

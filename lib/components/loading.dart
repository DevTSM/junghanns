import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:junghanns/styles/color.dart';

class LoadingJunghanns extends StatelessWidget{
  const LoadingJunghanns({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 30),
        decoration: const BoxDecoration(
          color: ColorsJunghanns.blue,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        height: MediaQuery.of(context).size.width * .30,
        width: MediaQuery.of(context).size.width * .30,
        child: const SpinKitFadingCircle(
          color: ColorsJunghanns.green,
        ),
      );
  }

}
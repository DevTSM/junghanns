import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:provider/provider.dart';

class LoadingJunghanns extends StatelessWidget {
  const LoadingJunghanns({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    ProviderJunghanns provider = Provider.of<ProviderJunghanns>(context);
    return Material(
        color: Colors.transparent,
        child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.black.withOpacity(.4),
            padding: const EdgeInsets.all(90),
            child: const SpinKitCircle(color: ColorsJunghanns.blue,size: 100,)));
  }
}

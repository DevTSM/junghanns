import 'package:flutter/material.dart';

class LoadingJunghanns extends StatelessWidget{
  const LoadingJunghanns({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.black.withOpacity(.4),
        padding: const EdgeInsets.all(90),
        child: Image.asset("assets/loading.gif",fit: BoxFit.contain,)
      );
  }

}
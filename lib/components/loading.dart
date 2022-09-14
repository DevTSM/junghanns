import 'package:flutter/material.dart';
import 'package:flutter_speedtest/flutter_speedtest.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:provider/provider.dart';

class LoadingJunghanns extends StatelessWidget{
  const LoadingJunghanns({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    ProviderJunghanns provider= Provider.of<ProviderJunghanns>(context);
  //   final _speedtest = FlutterSpeedtest(
  //   baseUrl: 'http://speedtest.jaosing.com:8080', // your server url
  //   pathDownload: '/download', 
  //   pathUpload: '/upload',
  //   pathResponseTime: '/ping',
  // );
  // _speedtest.getDataspeedtest(
  //   downloadOnProgress: ((percent, transferRate) {
  //     provider.downloadRate=transferRate;
  //   }),
  //   uploadOnProgress: ((percent, transferRate) {
  //    //TODO: in ui
  //   }),
  //   progressResponse: ((responseTime, jitter) {
  //     //TODO: in ui
  //   }),
  //   onError: ((errorMessage) {
  //     //TODO: in ui
  //   }),
  // );
    return Material(
      color: Colors.transparent,
      child:Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.black.withOpacity(.4),
        padding: const EdgeInsets.all(90),
        child: Column(
          children: [
            Image.asset("assets/loading.gif",fit: BoxFit.contain,),
            Text(provider.downloadRate.toString())
          ],
        )
    )
      );
  }

}
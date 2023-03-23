import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/database/async.dart';
import 'package:junghanns/pages/auth/get_branch.dart';
import 'package:junghanns/pages/home/home_principal.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class OpeningAsync extends StatefulWidget {
  bool isLogin;
  OpeningAsync({Key? key,this.isLogin=false}) : super(key: key);

  @override
  State<OpeningAsync> createState() => _OpeningAsyncState();
}

class _OpeningAsyncState extends State<OpeningAsync> {
  late ProviderJunghanns provider;
  late bool isAsync;

  @override
  void initState() {
    super.initState();
    isAsync = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<ProviderJunghanns>(context);
    return Scaffold(
        body: Stack(
      children: [
        Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [
              Color.fromARGB(255, 244, 252, 253),
              Color.fromARGB(255, 206, 240, 255)
            ],
                    stops: [
              0.2,
              0.8
            ],
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter))),
        Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset("assets/images/junghannsLogo.png"),
            Visibility(
                visible: isAsync,
                child: const SizedBox(
                  height: 10,
                )),
            Visibility(
                visible: isAsync,
                child:Text(provider.labelAsync)),
            const SizedBox(height: 10,),
                Padding(
                    padding: const EdgeInsets.only(left: 40,right: 40),
                    child:LinearProgressBar(
                      minHeight: 7,
      maxSteps: provider.totalAsync,
      progressType: LinearProgressBar.progressTypeLinear, // Use Linear progress
      currentStep: provider.currentAsync,
      progressColor: ColorsJunghanns.green,
      backgroundColor: ColorsJunghanns.grey,
    ))
          ]),
        ),
      ],
    ));
  }
}

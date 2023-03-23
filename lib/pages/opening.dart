import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/database/async.dart';
import 'package:junghanns/pages/async/openingAsync.dart';
import 'package:junghanns/pages/auth/get_branch.dart';
import 'package:junghanns/pages/home/home_principal.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/util/connection.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'auth/login.dart';

class Opening extends StatefulWidget {
  bool isLogin;
  Opening({Key? key,this.isLogin=false}) : super(key: key);

  @override
  State<Opening> createState() => _OpeningState();
}

class _OpeningState extends State<Opening> {
  late ProviderJunghanns provider;
  late Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late bool isAsync;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    isAsync = false;
    
    log("token de acceso =====> ${prefs.token}");
    if (prefs.version != version ) {
      String urlBaseSafe=prefs.urlBase;
      prefs.prefs!.clear();
      prefs.version = version;
      prefs.urlBase=urlBaseSafe;
      log("limpiando cache =====>");
    }
    initConnectivity();
  }

  asyncDB() async {
    //validamos si ya se hizo la sincronizacion
    Timer(const Duration(milliseconds: 2000), () async {
      if (prefs.isLogged) {
        DateTime dateLast=DateTime.parse(prefs.asyncLast != ""
                    ? prefs.asyncLast
                    : DateTime(2017, 9, 7, 17, 30).toString());
       //if (DateTime.now().day!=dateLast.day||DateTime.now().month!=dateLast.month|| prefs.isAsyncCurrent) {
        if (true) {
          setState(() {
            isAsync = true;
          });
          prefs.asyncLast = DateTime.now().toString();
          log("/sincronizando base de datos");
          Async asyncDB = Async(provider: provider);
          await asyncDB.init().then((value) {
            if (value) {
              Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute<void>(
                    builder: (BuildContext context) => HomePrincipal()),
              );
            } else {
              Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute<void>(
                    builder: (BuildContext context) => const Login()),
              );
            }
          });
        } else {
          Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => HomePrincipal()),
          );
        }
      } else {
        Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => const Login()),
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    provider.connectionStatus = result.index;
    provider.path=await getDatabasesPath();
    log("url base: ${prefs.urlBase}");
    
    if(prefs.urlBase!=""){
    if (result.index < 4) {
      asyncDB();
    }else{
      if(prefs.isLogged){
        Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute<void>(
                    builder: (BuildContext context) => HomePrincipal()),
              );
      }else{
        Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute<void>(
                    builder: (BuildContext context) => const Login()),
              );
      }
    }
  }else{
    Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute<void>(
                    builder: (BuildContext context) => const GetBranch()),
              );
  }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    provider.connectionStatus = result.index;
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<ProviderJunghanns>(context);
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
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
                Visibility(
                  visible: isAsync,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40,right: 40),
                    child:LinearProgressBar(
                      minHeight: 7,
      maxSteps: provider.totalAsync,
      progressType: LinearProgressBar.progressTypeLinear, // Use Linear progress
      currentStep: provider.currentAsync,
      progressColor: ColorsJunghanns.green,
      backgroundColor: ColorsJunghanns.grey,
    )))
          ]),
        ),
      ],
    ));
  }
}

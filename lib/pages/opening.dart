import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/database/async.dart';
import 'package:junghanns/pages/home/home_principal.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:provider/provider.dart';

import 'auth/login.dart';

class Opening extends StatefulWidget {
  const Opening({Key? key}) : super(key: key);

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
    isAsync=false;
    log("token de acceso =====> ${prefs.token}");
    if (prefs.version != version || urlBase != prefs.ipUrl) {
      prefs.prefs!.clear();
      prefs.version = version;
      prefs.ipUrl = urlBase;
      log("limpiando cache =====>");
    }
    initConnectivity();
  }

  asyncDB() async {
    //validamos si ya se hizo la sincronizacion
    Timer(const Duration(milliseconds: 2000), () async {
      
      if (prefs.isLogged ) {
        log("--------------------------------2");
        if(DateTime.now().difference(DateTime.parse(prefs.asyncLast!=""?prefs.asyncLast:DateTime(2017, 9, 7, 17, 30).toString())).inDays>1){
          setState(() {
            isAsync=true;
          });
          prefs.asyncLast=DateTime.now().toString();
        log("/sincronizando la base de datos");
        Async asyncDB = Async();
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
      }else {
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
    if(result.index<4){
      log("--------------------------------");
      asyncDB();
    }
  }

  setDataStops(Map<String, dynamic> data) async {
    await setStop(data).then((answer) {
      if (answer.error) {
        log("Parada asignada 2");
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        //
        log("Parada asignada");
        //
      }
    });
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    provider.connectionStatus = result.index;
    if (result.index != 4 && prefs.dataStop) {
      // List<Map<String, dynamic>> dataNStops = [];
      // List<Map<String, dynamic>> dataList =
      //     await provider.handler.retrieveStopOff();
      // List.generate(dataList.length, (i) {
      //   dataNStops.add(dataList[i]);
      // });
      // dataNStops.map((e) => log(e.toString())).toList();
    }
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Image.asset("assets/images/junghannsLogo.png"),
              Visibility(
                visible: isAsync,
                child: const SizedBox(height: 10,)),
              Visibility(
                visible: isAsync,
                child: const SpinKitFadingCircle(
          color: ColorsJunghanns.blue,
        )),
              Visibility(
                visible: isAsync,
                child: const Text("Sincronizando datos, ya falta poquito"))
              ]),
        ),
      ],
    ));
  }
}

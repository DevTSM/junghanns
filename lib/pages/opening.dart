import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/pages/home/home_principal.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/store.dart';
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

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    log("token de acceso =====> ${prefs.token}");
    initConnectivity();
    reedireccion();
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  void reedireccion() async {
    Timer(const Duration(milliseconds: 2000), () async {
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                prefs.isLogged ? HomePrincipal() : const Login()),
      );
    });
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
      // Fluttertoast.showToast(
      //     msg: "Sincronizando paradas",
      //     timeInSecForIosWeb: 16,
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.TOP,
      //     webShowClose: true,
      //   );
      List<Map<String, dynamic>> dataNStops = [];
      List<Map<String, dynamic>> dataList =
          await provider.handler.retrieveStopOff();
      List.generate(dataList.length, (i) {
        dataNStops.add(dataList[i]);
      });
      dataNStops.map((e) => log(e.toString())).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<ProviderJunghanns>(context);
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    provider.init();
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
          child: Image.asset("assets/images/junghannsLogo.png"),
        ),
      ],
    ));
  }
}

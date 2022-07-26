import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:junghanns/pages/home/home_principal.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
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
    
        initConnectivity();
        
    reedireccion();
  }
  @override
  void dispose(){
    super.dispose();
    _connectivitySubscription.cancel();
  }

  void reedireccion() async {
    Timer(const Duration(milliseconds: 2000), () async {
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => prefs.isLogged?const HomePrincipal():const Login()),
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
    provider.connectionStatus=result.index;
  }
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    provider.connectionStatus=result.index;
  }
  @override
  Widget build(BuildContext context) {
    provider= Provider.of<ProviderJunghanns>(context);
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

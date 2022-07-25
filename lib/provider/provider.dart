// ignore_for_file: unnecessary_getters_setters

import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:junghanns/database/database.dart';

class ProviderJunghanns with ChangeNotifier {
  DataBase handler=DataBase();
    
  int _connectionStatus = 100;

  init(){
    handler.initializeDB();
  }
  int get connectionStatus=> _connectionStatus;
  set connectionStatus(int connectionCurrent){
    _connectionStatus=connectionCurrent;
    log("Conexion ------> $_connectionStatus");
    notifyListeners();
  }
  setConnectionStatus(ConnectivityResult connectionCurrent){
    _connectionStatus=connectionCurrent.index;
    log("Conexion ------> $_connectionStatus");
    notifyListeners();
  }
}

// ignore_for_file: unnecessary_getters_setters

import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:junghanns/database/database.dart';
import 'package:junghanns/models/customer.dart';

class ProviderJunghanns with ChangeNotifier {
  DataBase handler=DataBase();
    
  int _connectionStatus = 100;
  List<CustomerModel> _customerList=[];

  init(){
    handler.initializeDB();
  }
  int get connectionStatus=> _connectionStatus;
  set connectionStatus(int connectionCurrent){
    _connectionStatus=connectionCurrent;
    notifyListeners();
  }
  List<CustomerModel> get customerList => _customerList;
  set customerList(List<CustomerModel> customerList){
    _customerList=customerList;
    notifyListeners();
  }
}

// ignore_for_file: unnecessary_getters_setters

import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:junghanns/database/database.dart';
import 'package:junghanns/models/customer.dart';

class ProviderJunghanns with ChangeNotifier {
  
  List<CustomerModel> _customerList=[];
  String _labelAsync="Sincronizando datos, no cierres la app";
  int _connectionStatus = 100;
  bool get permission=> _permission;
  bool _permission=true;
  
  set permission(bool permissionCurrent){
    _permission=permissionCurrent;
    notifyListeners();
  }
  int get connectionStatus=> _connectionStatus;
  set connectionStatus(int connectionCurrent){
    _connectionStatus=connectionCurrent;
    notifyListeners();
  }
  String get labelAsync=> _labelAsync;
  set labelAsync(String labelAsync){
    _labelAsync=labelAsync;
    notifyListeners();
  }
  List<CustomerModel> get customerList => _customerList;
  set customerList(List<CustomerModel> customerList){
    _customerList=customerList;
    notifyListeners();
  }
}

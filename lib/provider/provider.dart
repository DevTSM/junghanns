// ignore_for_file: unnecessary_getters_setters

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/shopping_basket.dart';
import 'package:junghanns/util/connection.dart';

class ProviderJunghanns extends ChangeNotifier {
  //VARIABLES
  final Stream _myStream =
      Stream.periodic(const Duration(seconds: 20), (int count) => count);
  late StreamSubscription _sub;
  Connection connecction=Connection();
  BasketModel basketCurrent = BasketModel.fromState();
  List<CustomerModel> _customerList = [];
  String _path = "";
  String _labelAsync = "Sincronizando datos, no cierres la app";
  int _connectionStatus = 100;
  double _downloadRate = 0;
  int _totalAsync = 1;
  int _currentAsync = 0;
  bool get permission => _permission;
  bool _permission = true;
  bool _asyncProcess = false;
  bool _isStatusloading = false;

  //GETS
  bool get isStatusloading => _isStatusloading;
  bool get asyncProcess => _asyncProcess;
  int get totalAsync => _totalAsync;
  int get currentAsync => _currentAsync;
  int get connectionStatus => _connectionStatus;
  double get downloadRate => _downloadRate;
  String get labelAsync => _labelAsync;
  String get path => _path;
  List<CustomerModel> get customerList => _customerList;
  //SETS
  set isStatusloading(bool isStatusloading) {
    _isStatusloading = isStatusloading;
    notifyListeners();
  }

  set permission(bool permissionCurrent) {
    _permission = permissionCurrent;
    notifyListeners();
  }

  set asyncProcess(bool asyncProcess) {
    _asyncProcess = asyncProcess;
    notifyListeners();
  }

  set totalAsync(int totalAsync) {
    _totalAsync = totalAsync;
    notifyListeners();
  }

  set currentAsync(int currentAsync) {
    _currentAsync = currentAsync;
    notifyListeners();
  }

  set connectionStatus(int connectionCurrent) {
    _connectionStatus = connectionCurrent;
    notifyListeners();
  }

  set downloadRate(double downloadRate) {
    _downloadRate = downloadRate;
    notifyListeners();
  }

  set path(String path) {
    _path = path;
    notifyListeners();
  }

  set labelAsync(String labelAsync) {
    _labelAsync = labelAsync;
    notifyListeners();
  }

  set customerList(List<CustomerModel> customerList) {
    _customerList = customerList;
    notifyListeners();
  }

  //FUNCTIONS
  initShopping(CustomerModel customerCurrent) {
    basketCurrent = BasketModel.fromInit(customerCurrent);
  }

  updateProductShopping(ProductModel productCurrent, bool isAdd) {
    //TODO: verificacion de Autorizacion
    var exits = basketCurrent.sales
        .where((element) => element.idProduct == productCurrent.idProduct);
    if (exits.isNotEmpty) {
      if (isAdd) {
        exits.first.number += 1;
      } else {
        if (exits.first.number == 1) {
          exits.first.number = 0;
          basketCurrent.sales.removeWhere(
              (element) => element.idProduct == productCurrent.idProduct);
        } else {
          exits.first.number -= 1;
        }
      }
    } else {
      if (isAdd) {
        productCurrent.number = 1;
        basketCurrent.sales.add(productCurrent);
      }
    }
    basketCurrent.totalPrice = 0;
    for (var e in basketCurrent.sales) {
      basketCurrent.totalPrice += (e.price * e.number);
    }
    notifyListeners();
  }
}

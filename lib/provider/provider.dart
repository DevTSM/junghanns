// ignore_for_file: unnecessary_getters_setters

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/shopping_basket.dart';

class ProviderJunghanns with ChangeNotifier {
  BasketModel basketCurrent=BasketModel.fromState();
  List<CustomerModel> _customerList=[];
  String _labelAsync="Sincronizando datos, no cierres la app";
  int _connectionStatus = 100;
  double _downloadRate = 0;
  bool get permission=> _permission;
  bool _permission=true;
  initShopping(CustomerModel customerCurrent){
    basketCurrent=BasketModel.fromInit(customerCurrent);
  }
  updateProductShopping(ProductModel productCurrent,bool isAdd){
    //TODO: verificacion de Autorizacion
    var exits=basketCurrent.sales.where((element) => element.idProduct==productCurrent.idProduct);
    if(exits.isNotEmpty){
      if(isAdd){
      exits.first.number+=1;
      }else{
        if(exits.first.number==1){
          exits.first.number=0;
          basketCurrent.sales.removeWhere((element) => element.idProduct==productCurrent.idProduct);
        }else{
          exits.first.number-=1;
        }
      }
    }else{
      
      if(isAdd){
        productCurrent.number=1;
        basketCurrent.sales.add(productCurrent);
      }
    }
    basketCurrent.totalPrice=0;
    for(var e in basketCurrent.sales){
      basketCurrent.totalPrice+=(e.price*e.number);
    }
    notifyListeners();
  }
  set permission(bool permissionCurrent){
    _permission=permissionCurrent;
    notifyListeners();
  }
  int get connectionStatus=> _connectionStatus;

  set downloadRate(double downloadRate){
    _downloadRate=downloadRate;
    notifyListeners();
  }
  double get downloadRate=> _downloadRate;

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

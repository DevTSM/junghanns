// ignore_for_file: unnecessary_getters_setters

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/method_payment.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/shopping_basket.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/util/push_notifications_provider.dart';

class ProviderJunghanns extends ChangeNotifier {
  ProviderJunghanns(){
    messaging.subscribeToTopic("messaging");
    requestPermissions();
    notificationService.init();
    listen();
  }
  //VARIABLES
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin= FlutterLocalNotificationsPlugin();
  NotificationService notificationService=NotificationService();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  Function _updateComodato=(){};
  BasketModel basketCurrent = BasketModel.fromState();
  String _path = "";
  String _labelAsync = "Sincronizando datos, no cierres la app";
  double _downloadRate = 0;
  int _connectionStatus = 100;
  int _totalAsync = 1;
  int _currentAsync = 0;
  bool _permission = true;
  bool _asyncProcess = false;
  bool _isStatusloading = false;
  bool _isNeedAsync=false;
  bool _isProcessValidate=false;

  //GETS
  bool get isProcessValidate=>_isProcessValidate;
  bool get isNeedAsync=>_isNeedAsync;
  bool get permission => _permission;
  bool get isStatusloading => _isStatusloading;
  bool get asyncProcess => _asyncProcess;
  int get totalAsync => _totalAsync;
  int get currentAsync => _currentAsync;
  int get connectionStatus => _connectionStatus;
  double get downloadRate => _downloadRate;
  String get labelAsync => _labelAsync;
  String get path => _path;
  Map<String,dynamic> get brand=> basketCurrent.brandJug;
  Function get updateComodato =>_updateComodato;
  //SETS
  set isProcessValidate(bool isProcess){
    _isProcessValidate=isProcess;
    notifyListeners();
  }

  set isNeedAsync(bool isNeedAsync){
    _isNeedAsync=isNeedAsync;
    notifyListeners();
  }
  
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
  set brand(Map<String,dynamic> data){
    basketCurrent.brandJug=data;
    notifyListeners();
  }
  set updateComodato(Function update){
    _updateComodato=update;
    notifyListeners();
  }

  //FUNCTIONS
  void requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
  listen(){
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      log("message recieved\n${event.notification!.body}\n${event.data.values}");
      NotificationModel notification=NotificationModel.fromEvent(event);
      handler.insertNotification(notification.getMap);
      if(event.data.isNotEmpty){
        isProcessValidate=true;
        Timer(const Duration(seconds: 1), () {_updateComodato(); });
      }
      NotificationService _notificationService = NotificationService();
      _notificationService.showNotifications(
          "${event.notification!.title}", "${event.notification!.body}");
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('Message clicked!');
    });
  }
  initShopping(CustomerModel customerCurrent,{AuthorizationModel? auth}) {
    basketCurrent = BasketModel.fromInit(customerCurrent,auth);
    notifyListeners();
  }
  updateProductShopping(ProductModel productCurrent, int isAdd) {
    //TODO: verificacion de Autorizacion
    var exits = basketCurrent.sales
        .where((element) => element.idProduct == productCurrent.idProduct);
    if (exits.isNotEmpty) {
      if (isAdd==1) {
        exits.first.number += 1;
      } else {
        if(isAdd==0){
        if (exits.first.number == 1) {
          exits.first.number = 0;
          basketCurrent.sales.removeWhere(
              (element) => element.idProduct == productCurrent.idProduct);
        } else {
          exits.first.number -= 1;
        }
        }//aqui no importa ya que se le asigno el numero
      }
    } else {
      if (isAdd==1) {
        productCurrent.number = 1;
        basketCurrent.sales.add(productCurrent);
      }else{
        if(isAdd==2){
          basketCurrent.sales.add(productCurrent);
        }
      }
    }
    basketCurrent.totalPrice = basketCurrent.addPrice;
    for (var e in basketCurrent.sales) {
      basketCurrent.totalPrice += (e.price * e.number);
    }
    
    notifyListeners();
  }
  getIsNeedAsync() async {
    List<Map<String,dynamic>> salesPen= await handler.retrieveSales();
    List<Map<String,dynamic>> stopPen=await handler.retrieveStopOffUpdate();
    _isNeedAsync=salesPen.isNotEmpty||stopPen.isNotEmpty;
    notifyListeners();
  }  
}

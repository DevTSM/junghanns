// ignore_for_file: unnecessary_getters_setters

import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/message.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/shopping_basket.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/util/push_notifications_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ProviderJunghanns extends ChangeNotifier {
  ProviderJunghanns(){
    messaging.subscribeToTopic("messaging");
    requestPermissions();
    requestAllPermissions();
    notificationService.init();
    listen();
    getPendingNotification();
    getMessages();
  }
  //VARIABLES
  List<MessageChat> _messagesChat = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin= FlutterLocalNotificationsPlugin();
  NotificationService notificationService=NotificationService();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  ScrollController _scrollController = ScrollController();
  TextEditingController _messageChat = TextEditingController();
  Function _updateComodato = (){};
  BasketModel basketCurrent = BasketModel.fromState();
  String _path = "";
  String _labelAsync = "Sincronizando datos, no cierres la app";
  double _downloadRate = 0;
  int _connectionStatus = 100;
  int _totalAsync = 1;
  int _currentAsync = 0;
  int _totalNotificationPending=0;
  bool _permission = true;
  bool _asyncProcess = false;
  bool _isStatusloading = false;
  bool _isNeedAsync=false;
  bool _isProcessValidate=false;
  bool _isNotificationPending=false;

  //GETS
  bool get isNotificationPending=>_isNotificationPending;
  bool get isProcessValidate=>_isProcessValidate;
  bool get isNeedAsync=>_isNeedAsync;
  bool get permission => _permission;
  bool get isStatusloading => _isStatusloading;
  bool get asyncProcess => _asyncProcess;
  int get totalAsync => _totalAsync;
  int get totalNotificationPending => _totalNotificationPending;
  int get currentAsync => _currentAsync;
  int get connectionStatus => _connectionStatus;
  double get downloadRate => _downloadRate;
  String get labelAsync => _labelAsync;
  String get path => _path;
  Map<String,dynamic> get brand=> basketCurrent.brandJug;
  TextEditingController get messageChat => _messageChat;
  Function get updateComodato =>_updateComodato;
  ScrollController get scrollController => _scrollController;
  List<MessageChat> get messagesChat => _messagesChat;
  //SETS
  set isNotificationPending(bool current){
    _isNotificationPending=current;
    notifyListeners();
  }
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
  set totalNotificationPending(int current) {
    _totalNotificationPending = current;
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
  Future<void> requestAllPermissions() async {
    Timer(const Duration(seconds: 6), () async { 
      Map<Permission, PermissionStatus> status = await [
        Permission.locationWhenInUse,
        Permission.location,
        Permission.notification
      ].request();

        // Verifica el estado de los permisos
      if (status[Permission.locationWhenInUse] == PermissionStatus.denied){
        log("Solicitando 1 ====================>");
        await Permission.locationWhenInUse.request();
      }
      if (status[Permission.location] == PermissionStatus.denied){
        log("Solicitando 2 ====================>");
        await Permission.location.request();
      }
      if (status[Permission.notification] == PermissionStatus.denied){
        log("Solicitando 3 ====================>");
        await Permission.notification.request();
      }
    });
  }
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
      log("message recieved 1\n${event.notification!.body}\n${event.data.values}");
      NotificationModel notification=NotificationModel.fromEvent(event,status: 0);
      handler.insertNotification(notification.getMap);
      if(event.data.isNotEmpty){
        isProcessValidate=true;
        Timer(const Duration(seconds: 1), () {_updateComodato(); });
      }
      getPendingNotification();
      NotificationService _notificationService = NotificationService();
      _notificationService.showNotifications(
          "${event.notification!.title}", "${event.notification!.body}");
    });
  }
  initShopping(CustomerModel customerCurrent,{AuthorizationModel? auth}) {
    basketCurrent = BasketModel.fromInit(customerCurrent,auth);
    notifyListeners();
  }
  getMessages() async {
    _messagesChat = List.from((await handler.retrieveMessages()).map((e) => 
      MessageChat.fromDB(data: e)).toList());
    _messagesChat = [
      MessageChat.fromState(),
      MessageChat.fromState(emisor: 'operaciones')
    ];
    notifyListeners();
  }
  updateProductShopping(ProductModel productCurrent, int isAdd) {
    //TODO: verificacion de Autorizacion
    var exits = basketCurrent.sales
        .where((element) => element.idProduct == productCurrent.idProduct);
    if (exits.isNotEmpty) {
      if (isAdd == 1) {
        exits.first.number += 1;
      } else {
        if(isAdd == 0){
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
      if (isAdd == 1) {
        productCurrent.number = 1;
        basketCurrent.sales.add(productCurrent);
      }else{
        if(isAdd == 2){
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
  getPendingNotification() async {
    List<NotificationModel> list= await handler.retrieveNotification();
    var exits= list.where((element) =>element.status==0);
    isNotificationPending=exits.isNotEmpty;
    totalNotificationPending=exits.length;
  }
  cleanPendingNotifications() async {
    List<NotificationModel> notificationsGet = await handler.retrieveNotification();
    List<NotificationModel> notificationsPending = 
      notificationsGet.where((element) => element.status==0).toList();
    notificationsPending.map((e){
      e.status=1;
      handler.updateNotification(e);
    }).toList();
    isNotificationPending=false;
  }
  getIsNeedAsync() async {
    List<Map<String,dynamic>> salesPen= await handler.retrieveSales();
    List<Map<String,dynamic>> stopPen=await handler.retrieveStopOffUpdate();
    _isNeedAsync=salesPen.isNotEmpty||stopPen.isNotEmpty;
    notifyListeners();
  }  
  addMessage() async {
    MessageChat current = MessageChat.fromMessage(message: _messageChat.text);
    _messageChat.clear();
    _messagesChat.add(current);
    await handler.insertMessage(current);
    _scrollController.jumpTo(1);
    notifyListeners();
  }
}

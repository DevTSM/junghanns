// ignore_for_file: unnecessary_getters_setters

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/components/modal/activate_permission.dart';
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/deliver_products.dart';
import 'package:junghanns/models/delivery.dart';
import 'package:junghanns/models/message.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/product_catalog.dart';
import 'package:junghanns/models/shopping_basket.dart';
import 'package:junghanns/models/validation_product.dart';
import 'package:junghanns/pages/home/home.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/util/navigator.dart';
import 'package:junghanns/util/push_notifications_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/async.dart';
import '../models/produc_receiption.dart';
import '../pages/home/home_principal.dart';
import '../services/store.dart';
import '../widgets/modal/evidence.dart';
import '../widgets/modal/informative.dart';

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
  String _labelPermission = "Se han denegado los permisos de ubicación para esta aplicación. Es necesario que los actives para poder realizar el registro de tu actividad de forma correcta";
  double _downloadRate = 0;
  int _connectionStatus = 100;
  int _totalAsync = 1;
  int _currentAsync = 0;
  int _totalNotificationPending=0;
  bool _permission = false;
  bool _asyncProcess = false;
  bool _isStatusloading = false;
  bool _isNeedAsync=false;
  bool _isProcessValidate=false;
  bool _isNotificationPending=false;
  ProductCatalogModel? _accesoryCurrent;
  ProductModel? _productCurrent;
  ProductModel? get productCurrent => _productCurrent;
  ProductCatalogModel? get accesoryCurrent => _accesoryCurrent;
  List<ValidationProductModel> _validationList = [];
  List<DeliverProductsModel> _stockAccesories = [];
  List<ProductCatalogModel> _productsCatalog = [];
  List<ProductCatalogModel> _accesories = [];
  List<ProductCatalogModel> additionalProducts = [];
  List<ProductModel> missingProducts = [];
  List<ProductModel> _stockProducts = [];
  List<DeliverProductsModel> originalAccessoriesWithStock = [];
  List<DeliverProductsModel> accessoriesWithStock = [];
  List<DeliverProductsModel> othersAccesoriosOrigin = [];
  List<DeliverProductsModel> othersAccesoriosOriginSecun = [];
  List<DeliverProductsModel> returnsWithStock = [];
  List<DeliverProductsModel> returnsAccesoriosOrigin = [];
  List<DeliverProductsModel> returnsAccesoriosOriginSecun = [];
  List<DeliverProductsModel> carboyAccesories = [];
  List<DeliverProductsModel> carboyAccesoriosOrigin = [];
  List<DeliverProductsModel> carboyAccesoriosOriginSecun = [];
  List<ValidationProductModel> _validationDeliveryList = [];


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
  String get labelPermission => _labelPermission;
  String get path => _path;
  Map<String,dynamic> get brand=> basketCurrent.brandJug;
  TextEditingController get messageChat => _messageChat;
  Function get updateComodato =>_updateComodato;
  ScrollController get scrollController => _scrollController;
  List<MessageChat> get messagesChat => _messagesChat;
  List<ValidationProductModel> get validationList => _validationList;
  List<DeliverProductsModel> get stockAccesories => _stockAccesories;
  List<ProductCatalogModel> get productsCatalog => _productsCatalog;
  List<ProductCatalogModel> get accesories => _accesories;
  List<ProductModel> get stockProducts => _stockProducts;
  List<ValidationProductModel> get validationDeliveryList => _validationDeliveryList;



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
  set labelPermission(String labelPermission) {
    _labelPermission = labelPermission;
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
  set validationList(List<ValidationProductModel> current) {
    _validationList = current;
    notifyListeners();
  }
  set validationDeliveryList(List<ValidationProductModel> current) {
    _validationDeliveryList = current;
    notifyListeners();
  }
  set stockAccesories(List<DeliverProductsModel> current){
    _stockAccesories = current;
    notifyListeners();
  }
  set productsCatalog(List<ProductCatalogModel> current){
    _productsCatalog = current;
    notifyListeners();
  }
  set accesoryCurrent(ProductCatalogModel? current) {
    _accesoryCurrent = current;
    notifyListeners();
  }
  set productCurrent(ProductModel? current) {
    _productCurrent = current;
    notifyListeners();
  }
  set accesories(List<ProductCatalogModel> current){
    _accesories = current;
    notifyListeners();
  }
  set stockProducts(List<ProductModel> current){
    _stockProducts = current;
    notifyListeners();
  }

  //FUNCTIONS
  Future<void> requestAllPermissions() async {
    log("Solicitando permisos");
      prefs.isRequest = true;
    // Timer(const Duration(seconds: 6), () async { 
      Map<Permission, PermissionStatus> status = await [
        Permission.location,
        Permission.notification
      ].request();
      if (status.values.where((permission) => 
          permission != PermissionStatus.granted).isNotEmpty
      ){
        getLabelPermission(
          permission: status.keys.where((permission) => 
            status[permission] != PermissionStatus.granted).toList()
        );
        Timer(const Duration(seconds: 1), () async{ 
          await showActivatePermission(
            context: navigatorKey.currentContext!,
            permission: status.keys.where((permission) => 
              status[permission] != PermissionStatus.granted).toList()
          ).then((value){
            prefs.isRequest = false;
          });
        });
      }else{
        log("con permiso");
        permission = true;
      }
  }
  Future<void> requestAllPermissionsResumed() async {
    log("Solicitando permisos");
    if(!prefs.isRequest){
      prefs.isRequest = true;
    // Timer(const Duration(seconds: 6), () async { 
      Map<Permission, PermissionStatus> status = await [
        Permission.location,
        Permission.notification
      ].request();
      if (status.values.where((permission) => 
          permission != PermissionStatus.granted).isNotEmpty
      ){
        getLabelPermission(
          permission: status.keys.where((permission) => 
            status[permission] != PermissionStatus.granted).toList()
        );
        Timer(const Duration(seconds: 1), () async{ 
          await showActivatePermission(
            context: navigatorKey.currentContext!,
            permission: status.keys.where((permission) => 
              status[permission] != PermissionStatus.granted).toList()
          ).then((value){
            prefs.isRequest = false;
          });
        });
      }else{
        log("con permiso");
        permission = true;
      }
    }
  }
  getLabelPermission({required List<Permission> permission}){
    if(permission.length == 1 ){
      switch (permission.first.toString()){
        case 'Permission.location': 
          labelPermission = "Se han denegado los permisos de ubicación para esta aplicación. Es necesario que los actives para poder realizar el registro de tu actividad de forma correcta";
          break;
        case 'Permission.notification':
          labelPermission = "Se han denegado los permisos de notificación para esta aplicación. Es necesario que estés comunicado en todo momento.";
          break;
        default:
          labelPermission = "Se han denegado los permisos  para esta aplicación. Es necesario que los actives para poder realizar el registro de tu actividad de forma correcta";
          break;
      }
    }else{
      labelPermission = "Se han denegado los permisos de ubicación y notificaciones para esta aplicación. Es necesario que los actives para poder realizar el registro de tu actividad de forma correcta";
    }
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

  void updateProductShopping(BuildContext context, ProductModel productCurrent, int isAdd, {AuthorizationModel? authData}) {
    // 0 restar, 1 = sumar, 2 para input
    var exits = basketCurrent.sales
        .where((element) => element.idProduct == productCurrent.idProduct);

    if (exits.isNotEmpty) {
      if (isAdd == 1) {
        exits.first.number += 1;
      } else {
        if (isAdd == 0) {
          if (exits.first.number == 1) {
            exits.first.number = 0;
            basketCurrent.sales.removeWhere(
                    (element) => element.idProduct == productCurrent.idProduct);
          } else {
            exits.first.number -= 1;
          }
        } // Aquí no importa ya que se le asignó el número
      }
    } else {
      if (isAdd == 1) {
        productCurrent.number = 1;
        basketCurrent.sales.add(productCurrent);
      } else {
        if (isAdd == 2) {
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

  fetchStockValidation() async {

    await getValidationList(idR: prefs.idRouteD).then((answer) {

      if (answer.error) {
        print('Error al obtener la lista: ${answer.message}');
      } else {
        if (answer.body is List) {
          validationList = (answer.body as List)
              .map((item) => ValidationProductModel.fromJson(item))
              .toList();
        } else if (answer.body is Map) {
          final validation = ValidationProductModel.fromJson(answer.body);
          validationList = [validation];
        }


        print("Lista de validaciones obtenida: ${validationList.length} items.");
        // Imprimir cada validación para depuración
        for (var validation in validationList) {
          print(validation);
        }
        print("---Llamando--");
      }
    });
    notifyListeners();
  }
  //Funcionalidad de la recepción
  receiptionProducts({required int idValidacion, required double lat, required double lng, required String status, String? comment,}) async {
    notifyListeners();
    // Llamada al servicio postValidated
    await putValidated(
      action: "upestatus",
      idV: idValidacion,
      lat: lat,
      lng: lng,
      status: status,
      comment: status == 'R' ? comment : null,
    ).then((answer) {
      /*loading = false;*/
      if (answer.error) {
        // Redirigir a la vista de Home
        print('Error: ${answer.message}');
        CustomModal.show(
          context: navigatorKey.currentContext!,
          icon: Icons.cancel_outlined,
          title: "ERROR",
          message: "${answer.message}",
          iconColor: ColorsJunghanns.red,
        );
      } else {
        if (status == 'A') {
          //Navegación de vistas
          Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(builder: (context) => HomePrincipal()),
          );

          CustomModal.show(
              context: navigatorKey.currentContext!,
              icon: Icons.check_circle,
              title: "RECEPCIÓN ACEPTADA",
              message: "Se aceptaron correctamente los productos enviados por el almacén.",
              iconColor: ColorsJunghanns.greenJ,
          );
          fetchStockValidation();
        } else {
          CustomModal.show(
            context: navigatorKey.currentContext!,
            icon: Icons.check_circle,
            title: "RECEPCIÓN RECHAZADA",
            message: "Proceso realizado correctamente, la solicitud fue rechazada.",
            iconColor: ColorsJunghanns.red,
          );
          fetchStockValidation();
        }
        notifyListeners();
      }
    });
  }
  fetchStockDelivery() async {
    bool hasStock = false;
    await getStockDeliveryList(idR: prefs.idRouteD).then((answer) {
      if (answer.error) {
        print('Error al obtener la lista: ${answer.message}');
      } else {
        if (answer.body is Map) {
          DeliverProductsModel stockModel = DeliverProductsModel.fromJson(answer.body);
          stockAccesories = [stockModel];
          print('Stock Accesorios: $stockAccesories');
        } else {
          print('Error: La respuesta no es un mapa válido');
        }
        print("---Llamando--Stock--Entrega--");
      }
      hasStock = stockAccesories.isNotEmpty;
    });
    notifyListeners();
  }
  // Funcionalidad de lista de productos faltantes
  Future<void> removeMissingProduct(ProductModel product, int count) async {
    final existingProduct = missingProducts.firstWhere(
          (p) => p.idProduct == product.idProduct,
      orElse: () => ProductModel.empty(),
    );

    if (existingProduct.idProduct != 0) {
      int currentCount = int.tryParse(existingProduct.count) ?? 0;
      currentCount -= count;

      // Actualiza los carboys directamente según el id del producto
      if (product.idProduct == 22) {
        // Lógica para carboys llenos
        _updateStock(product.idProduct, -count); // Aquí se aumenta el stock de carboys llenos
      } else if (product.idProduct == 21) {
        // Lógica para carboys vacíos
        _updateStock(product.idProduct, -count); // Aquí se aumenta el stock de carboys vacíos
      } else {
        // Para otros productos, se elimina directamente el stock
        _updateStock(product.idProduct, count); // Restamos el stock normal
      }

      // Eliminar el producto si su cuenta es menor o igual a cero
      if (currentCount <= 0) {
        missingProducts.removeWhere((p) => p.idProduct == product.idProduct);
      } else {
        existingProduct.count = currentCount.toString();
      }
    }
    await saveLists();
    await saveMissingProducts(); // Guardar la lista actualizada
    notifyListeners();
  }

  updateStock() async {
    final uiProvider = Provider.of<ProviderJunghanns>(navigatorKey.currentContext!, listen: false);

    fetchStockDelivery();
    final productWithStockWithoutSerial = uiProvider.stockAccesories;
    saveLists();
    print('Cargado de la lista despues de saveLists: $carboyAccesories');
    // Limpia la lista de productos faltantes si es necesario


    carboyAccesoriosOrigin = productWithStockWithoutSerial
        .where((a) => a.carboys != null)
        .map((a) => a.copy()) // Crear copias de cada elemento
        .toList();

    carboyAccesoriosOrigin.clear();

    carboyAccesoriosOrigin = productWithStockWithoutSerial
        .where((a) => a.carboys != null)
        .map((a) => a.copy()) // Crear copias de cada elemento
        .toList();

    if (carboyAccesories.isEmpty || carboyAccesoriosOriginSecun.isEmpty) {

      carboyAccesoriosOriginSecun = productWithStockWithoutSerial
          .where((a) => a.carboys != null)
          .map((a) => a.copy())
          .toList();

      carboyAccesories = productWithStockWithoutSerial
          .where((a) => a.carboys != null)
          .map((a) => a.copy())
          .toList();
    }
    // Comparación de las listas para carboys
    // Solo comparamos el contenido de carboys de cada lista
    final carboyAccesoriesCarboys = carboyAccesories.map((a) => a.carboys).toList();
    final carboyAccesoriosOriginCarboys = carboyAccesoriosOrigin.map((a) => a.carboys).toList();
    final carboyAccesoriesSecunCarboys = carboyAccesoriosOriginSecun.map((a) => a.carboys).toList();

    if (carboyAccesoriosOriginCarboys.toString() != carboyAccesoriesSecunCarboys.toString()) {
      //Verificar esto antes de todo
      missingProducts.removeWhere((product) => product.idProduct == 22 || product.idProduct == 21);
      carboyAccesoriosOriginSecun.clear();
      carboyAccesories.clear();
    }

    // Otros productos
    othersAccesoriosOrigin = productWithStockWithoutSerial
        .where((a) => a.others.isNotEmpty)
        .map((a) => a.copyOthers())
        .toList();

    // Actualizar accesorios con stock
    if (accessoriesWithStock.isEmpty || othersAccesoriosOriginSecun.isEmpty) {
      othersAccesoriosOriginSecun = productWithStockWithoutSerial
          .where((a) => a.others.isNotEmpty)
          .map((a) => a.copyOthers())
          .toList();

      accessoriesWithStock = productWithStockWithoutSerial
          .where((accessory) => accessory.others.isNotEmpty)
          .map((a) => a.copyOthers())
          .toList();

      originalAccessoriesWithStock = List.from(accessoriesWithStock);
    }

    List<Map<String, dynamic>> simplifyProducts(List<ProductReceiptionModel> products) {
      return products.map((product) {
        return {
          'id': product.id,
          'producto': product.product,
          'cantidad': product.count,
        };
      }).toList();
    }
    // Comparación de las listas para carboys
    // Solo comparamos el contenido de others de cada lista
    final othersAccesoriesOthers = accessoriesWithStock.map((a) => simplifyProducts(a.others)).toList();
    final othersAccesoriosOriginOthers = othersAccesoriosOrigin.map((a) => simplifyProducts(a.others)).toList();
    final othersAccesoriesSecunOthers = othersAccesoriosOriginSecun.map((a) => simplifyProducts(a.others)).toList();


    if (othersAccesoriosOriginOthers.toString() != othersAccesoriesSecunOthers.toString()) {
      missingProducts.removeWhere((product) => product.idProduct != 22 && product.idProduct != 21);
      othersAccesoriosOriginSecun.clear();
      accessoriesWithStock.clear();
    }
   // Devoluciones
    returnsAccesoriosOrigin = productWithStockWithoutSerial
        .where((a) => a.returns.isNotEmpty)
        .map((a) => a.copyOthers())
        .toList();

    if(returnsWithStock.isEmpty || returnsAccesoriosOriginSecun.isEmpty){
      returnsAccesoriosOriginSecun = productWithStockWithoutSerial
          .where((a) => a.returns.isNotEmpty)
          .map((a) => a.copyOthers())
          .toList();
      // Actualizar devoluciones con stock
      returnsWithStock = productWithStockWithoutSerial
          .where((accessory) => accessory.returns.isNotEmpty)
          .toList();
    }
    // Solo comparamos el contenido de carboys de cada lista
    final returnsAccesoriesReturns = returnsWithStock.map((a) => simplifyProducts(a.returns)).toList();
    final returnsAccesoriosOriginReturns = returnsAccesoriosOrigin.map((a) => simplifyProducts(a.returns)).toList();
    final returnsAccesoriesSecunReturns = returnsAccesoriosOriginSecun.map((a) => simplifyProducts(a.returns)).toList();

    if (returnsAccesoriosOriginReturns.toString() != returnsAccesoriesSecunReturns.toString()) {
      returnsAccesoriosOriginSecun.clear();
      returnsWithStock.clear();
    }

    notifyListeners();
    await saveLists();
  }


  Future<void> saveLists() async {
    final prefs = await SharedPreferences.getInstance();

    // Obtén el token de sesión actual al momento de guardar las listas
    String sessionToken = await prefs.getString('token') ?? '';

    // Guarda el token de sesión actual para referencia futura
    await prefs.setString('savedSessionToken', sessionToken);

    // Convierte tus listas a JSON
    String carboyJson = jsonEncode(carboyAccesories.map((a) => a.toJson()).toList());
    String othersJson = jsonEncode(accessoriesWithStock.map((a) => a.toJson()).toList());
    String returnsJson = jsonEncode(returnsWithStock.map((a) => a.toJson()).toList());

    // Guarda las listas en SharedPreferences
    await prefs.setString('carboyAccesories', carboyJson);
    await prefs.setString('othersAccesories', othersJson);
    await prefs.setString('returnsAccesories', returnsJson);

    // Imprimir las listas guardadas para depuración
    print('Guardado Carboy Accessories: $carboyJson');
    print('Guardado Accessories with Stock: $othersJson');
    print('Guardado Returns with Stock: $returnsJson');
  }
  Future<void> refreshList(String currentSessionToken) async {
    final prefs = await SharedPreferences.getInstance();
    String? savedSessionToken = prefs.getString('savedSessionToken');

    print("Token de sesión guardado: $savedSessionToken");
    print("Token de sesión actual: $currentSessionToken");

    try {
      // Verifica si el token actual de la sesión es diferente al guardado
      if (currentSessionToken != savedSessionToken) {
        carboyAccesories.clear();
        print("carboyAccesories después de clear: $carboyAccesories");
        accessoriesWithStock.clear();
        print("accessoriesWithStock después de clear: $accessoriesWithStock");
        returnsWithStock.clear();
        print("returnsWithStock después de clear: $returnsWithStock");
        missingProducts.clear();
        print("missingProducts después de clear: $missingProducts");
        additionalProducts.clear();
        print("additionalProducts después de clear: $additionalProducts");


        await prefs.remove('carboyAccesories');
        await prefs.remove('othersAccesories');
        await prefs.remove('returnsAccesories');
        await prefs.remove('missingProducts');
        await prefs.remove('additionalProducts');
        await prefs.remove('savedSessionToken');

        bool missingProductsExists = prefs.containsKey('missingProducts');
        print("missingProducts eliminado: ${!missingProductsExists}");

        await prefs.setString('savedSessionToken', currentSessionToken);
        print("Token de sesión cambiado, listas no cargadas y datos eliminados.");
      }
    } catch (e) {
      print("Error en refreshList: $e");
    }
    notifyListeners();
  }

  synchronizeListDelivery() async {
    final prefs = await SharedPreferences.getInstance();

    print("Entra a la sincronizacion de las listas");
    carboyAccesories.clear();
    print("carboyAccesories después de clear: $carboyAccesories");
    accessoriesWithStock.clear();
    print("accessoriesWithStock después de clear: $accessoriesWithStock");
    returnsWithStock.clear();
    print("returnsWithStock después de clear: $returnsWithStock");
    missingProducts.clear();
    print("missingProducts después de clear: $missingProducts");
    additionalProducts.clear();
    print("additionalProducts después de clear: $additionalProducts");

    await prefs.remove('carboyAccesories');
    await prefs.remove('othersAccesories');
    await prefs.remove('returnsAccesories');
    await prefs.remove('missingProducts');
    await prefs.remove('additionalProducts');

    bool missingProductsExists = prefs.containsKey('missingProducts');
    print("missingProducts eliminado: ${!missingProductsExists}");
  }

  Future<void> loadLists(String currentSessionToken) async {
    final prefs = await SharedPreferences.getInstance();

      // Recupera y asigna las listas desde el almacenamiento local
      carboyAccesories = (jsonDecode(prefs.getString('carboyAccesories') ?? '[]') as List)
          .map((e) => DeliverProductsModel.fromJson(e))
          .toList();

      // Imprimir la lista de accesorios carboy
      print('Carboy Accessories: $carboyAccesories');

      accessoriesWithStock = (jsonDecode(prefs.getString('othersAccesories') ?? '[]') as List)
          .map((e) => DeliverProductsModel.fromJson(e))
          .toList();

      // Imprimir la lista de accesorios con stock
      print('Accessories with Stock: $accessoriesWithStock');

      returnsWithStock = (jsonDecode(prefs.getString('returnsAccesories') ?? '[]') as List)
          .map((e) => DeliverProductsModel.fromJson(e))
          .toList();

      // Imprimir la lista de devoluciones con stock
      print('Returns with Stock: $returnsWithStock');

  }

  void updateMissingProduct(ProductModel product, int change) {
    final accessoryWithStock = accessoriesWithStock.firstWhere(
          (p) => p.others.first.id == product.idProduct,
      orElse: () => DeliverProductsModel.empty(),
    );

    if (accessoryWithStock.others.first.id == 0) return;
    if (change > 0 && accessoryWithStock.others.first.count < change) return;

    final existingProduct = missingProducts.firstWhere(
          (p) => p.idProduct == product.idProduct,
      orElse: () => ProductModel.empty(),
    );

    if (existingProduct.idProduct != 0) {
      existingProduct.count = (int.parse(existingProduct.count) + change).toString();

      if (int.parse(existingProduct.count) <= 0) {
        missingProducts.removeWhere((p) => p.idProduct == product.idProduct);
      }
    } else if (change > 0) {
      missingProducts.add(product.copyWith(count: change.toString(), label: "Faltante"));
    }
    _updateStock(product.idProduct, -change);
    notifyListeners();
  }

  void _updateStock(int productId, int countChange) {
    // Primero, actualizamos la lista de accesorios con stock
    final product = accessoriesWithStock.firstWhere(
          (p) => p.others.isNotEmpty && p.others.first.id == productId,
      orElse: () => DeliverProductsModel.empty(),
    );
    print('CountChange: $countChange');

    if (product.others.isNotEmpty && product.others.first.id != 0) {
      product.others.first.count += countChange;

      if (product.others.first.count < 0) {
        product.others.first.count = 0;
      }

      int index = accessoriesWithStock.indexWhere((p) => p.others.isNotEmpty && p.others.first.id == productId);
      if (index != -1) {
        accessoriesWithStock[index] = product;
      }
    } else {
      print('Producto no encontrado en accessoriesWithStock: ID ${productId}');
    }

    // Manejo específico para carboys (id == 22)
    if (productId == 22) {
      // Aquí puedes agregar la lógica adicional si es necesario para carboys
      _updateCarboyAccesories(countChange, true);
    }

    // Manejo específico para carboys vacíos (id == 21)
    if (productId == 21) {
      // Aquí puedes agregar la lógica adicional si es necesario para carboys vacíos
      _updateCarboyAccesories(countChange, false);
    }
    saveLists();
    notifyListeners();
  }

  void _updateCarboyAccesories(int countChange, bool isFull) {
    if (carboyAccesories.isNotEmpty) {
      final carboys = carboyAccesories.first.carboys;
      print('CountChange: $countChange');
      if (isFull == true) {
        if (carboys.full >= countChange) {
          carboys.full -= countChange;  // Descontar de carboys llenos
          carboys.empty += countChange;  // Aumentar en carboys vacíos
          print('Carboys llenos disminuidos: ${carboys.full}, Carboys vacíos aumentados: ${carboys.empty}');

        } else {
          print('No hay suficientes carboys llenos disponibles para descontar. Disponibles: ${carboys.full}');
        }
      } else {
        if (carboys.empty >= countChange) {
          carboys.empty -= countChange; // Descontar de carboys vacíos
        } else {
          print('No hay suficientes carboys vacíos disponibles para descontar. Disponibles: ${carboys.empty}');
        }
      }

      // Asegurar que el cambio persista en la lista
      int carboyIndex = carboyAccesories.indexWhere((a) => a.carboys == carboys);
      if (carboyIndex != -1) {
        carboyAccesories[carboyIndex].carboys = carboys;
      }

      print('Actualización de carboys: Full: ${carboys.full}, Empty: ${carboys.empty}');
      notifyListeners();
    }
  }

  Future<void> addMissingProduct(ProductModel product, int count) async {
    final existingProduct = missingProducts.firstWhere(
          (p) => p.idProduct == product.idProduct,
      orElse: () => ProductModel.empty(),
    );

    // Manejo del producto faltante
    if (existingProduct.idProduct != 0) {
      // Si ya existe, se actualiza la cantidad
      existingProduct.count = (int.parse(existingProduct.count) + count).toString();
    } else {
      // Si no existe, se agrega a la lista
      missingProducts.add(product.copyWith(count: count.toString(), label: "Faltante"));
    }

    // Determina si se debe pasar count o -count
    int countChange;
    if (product.idProduct == 22 || product.idProduct == 21) {
      countChange = count; // Para id 22 o 21, usar count positivo
    } else {
      countChange = -count; // Para otros productos, usar -count
    }

    // Actualiza el stock basado en el id del producto
    await saveLists();
    await saveMissingProducts(); // Guardar la lista actualizada
    notifyListeners();
    _updateStock(product.idProduct, countChange);
  }

  Future<void> saveMissingProducts() async {
    final prefs = await SharedPreferences.getInstance();

    // Convierte los productos faltantes a JSON
    String jsonString = jsonEncode(missingProducts.map((p) => p.toJsonMissing()).toList());

    print('Guardando productos faltantes: $jsonString');

    // Guarda la cadena JSON en SharedPreferences
    await prefs.setString('missingProducts', jsonString);
  }

  Future<void> loadMissingProducts(String currentSessionToken) async {
    final prefs = await SharedPreferences.getInstance();
    final missingProductsString = prefs.getString('missingProducts');

    print('Contenido de SharedPreferences: $missingProductsString');

    if (missingProductsString != null && missingProductsString.isNotEmpty) {
        // Decodifica la cadena JSON y convierte a la lista de ProductModel
        missingProducts = (jsonDecode(missingProductsString) as List)
            .map((json) => ProductModel.fromProductInventary(json))
            .toList();

        // Imprimir productos cargados
        for (var product in missingProducts) {
          print('Producto cargado: ${product.description}, count: ${product.count}');
        }
      } else {
        print('No se encontraron productos faltantes.');
      }
  }

  // Funcionalidad de lista de productos adicionales
  addAdditionalProduct(ProductCatalogModel accesory) async {
    accesory.label = "Adicional";
    additionalProducts.add(accesory);
    await saveAdditionalProducts();
    notifyListeners();
  }
  removeAdditionalProduct(ProductCatalogModel accessory) async {
    additionalProducts.removeWhere((item) => item.products == accessory.products);
    await saveAdditionalProducts();
    notifyListeners();
  }

  Future<void> saveAdditionalProducts() async {
    final prefs = await SharedPreferences.getInstance();
    // Convierte la lista a JSON y guárdala
    final additionalProductsJson = additionalProducts.map((a) => a.toJson()).toList();
    prefs.setString('additionalProducts', jsonEncode(additionalProductsJson));
  }

  Future<void> loadAdditionalProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final additionalProductsString = prefs.getString('additionalProducts');

    if (additionalProductsString != null) {
      // Decodifica la lista JSON y asigna los objetos deserializados a la lista
      additionalProducts = (jsonDecode(additionalProductsString) as List)
          .map((json) => ProductCatalogModel.fromJson(json))
          .toList();
    }
  }


  //Obtener lista de productos con stock
  fetchProductsStock() async {
    await getStockList(prefs.idRouteD).then((
        answer){
      // loading = false;
      if (answer.error) {
        print('Error al obtener la lista: ${answer.message}');
      } else {
        stockProducts = List<ProductModel>.from(
            answer.body.map((item) => ProductModel.fromProductInventary(item)));
        /*print('Productos en stock -- getStckList: $stockProducts');
        print("---Llamando--Productos--Con---Stock");*/
      }
    });
    notifyListeners();
  }
  //Obtener lista de productos del catalago
  fetchProducts() async {
    /*loading = true;*/
    bool hasStock = false;
    await getProducts().then((
        answer){
      // loading = false;
      if (answer.error) {
        print('Error al obtener la lista: ${answer.message}');
      } else {
        accesories = [];
        productsCatalog = List<ProductCatalogModel>.from(
            answer.body.map((item) => ProductCatalogModel.fromJson(item)));
        // Agregar los productos del catálogo a accesories
        accesories.addAll(productsCatalog);
        print('Productos en catálago: $productsCatalog');
        print('Accesorios después de agregar: $accesories');
        print("---Llamando--Productos--");
      }
      hasStock = stockAccesories.isNotEmpty;
    });
    notifyListeners();
  }
  // Post de entrega
  Future<void> deliverProducts({
    required int idRuta,
    required double lat,
    required double lng,
    required String team,
    required Map<String, dynamic> delivery,
    required ProviderJunghanns provider,
  }) async {

    // Preparar las listas de productos
    List<Map<String, dynamic>> returnedProducts = accessoriesWithStock.map((product) {
      final productMap = {
        "id_producto": product.others.first.id,
        "cantidad": product.others.first.count,
      };
      return productMap;
    }).toList();

    List<Map<String, dynamic>> missingProductsList = missingProducts.map((product) {
      final productMap = {
        "id_producto": product.idProduct,
        "cantidad": product.count,
      };
      return productMap;
    }).toList();

    List<Map<String, dynamic>> additionalProductsList = additionalProducts.map((product) {
      final productMap = {
        "id_producto": product.products,
        "cantidad": product.count,
      };
      return productMap;
    }).toList();

    // Estructura de entrega
    final Map<String, dynamic> deliveryData = {
      "garrafon": {
        "vacios": delivery["garrafon"]["vacios"],
        "llenos": delivery["garrafon"]["llenos"],
        "sucios_cte": delivery["garrafon"]["sucios_cte"],
        "rotos_cte": delivery["garrafon"]["rotos_cte"],
        "sucios_ruta": delivery["garrafon"]["sucios_ruta"],
        "rotos_ruta": delivery["garrafon"]["rotos_ruta"],
        "a_la_par": delivery["garrafon"]["a_la_par"],
        "comodato": delivery["garrafon"]["comodato"],
        "prestamo": delivery["garrafon"]["prestamo"]
      },
      "faltantes": missingProductsList,
      "otros": returnedProducts,
      "adicionales": additionalProductsList,
    };

    await postDelivery(
      idR: idRuta,
      lat: lat,
      lon: lng,
      equipo: team,
      entrega: deliveryData,
    ).then((answer) async {
      if (answer.error) {
        // Mostrar mensaje de error
        CustomModal.show(
          context: navigatorKey.currentContext!,
          icon: Icons.cancel_outlined,
          title: "ENTREGA FALLIDA",
          message: "${answer.message}",
          iconColor: ColorsJunghanns.red,
        );
      } else {
        // Limpiar las listas de faltantes y adicionales
        /*missingProducts.clear();
        additionalProducts.clear();*/
        // Mostrar mensaje de éxito
        print('Iniciando getStock');
        await Async(provider: provider).getStock();
        print('Iniciando terminando');
        CustomModal.show(
          context: navigatorKey.currentContext!,
          icon: Icons.check_circle,
          title: "ENTREGA CORRECTA",
          message: "El registro de entrega fue exitoso.",
          iconColor: ColorsJunghanns.greenJ,
        );
        fetchStockValidation();
      }
      notifyListeners();
    });
  }
  //Funcion para el enviar la evidencia
  Future<void> submitDirtyBroken({
    required String idRuta,
    required String idCliente,
    required String tipo,
    required String cantidad,
    required double lat,
    required double lon,
    required int idAutorization,
    required File archivo,
  }) async {
    notifyListeners();

      await postDirtyBroken(
        idRuta: idRuta,
        idCliente: idCliente,
        tipo: tipo,
        cantidad: cantidad,
        lat: lat,
        lon: lon,
        idAutorization: idAutorization,
        archivo: archivo,
      ). then((answer){
        if (answer.error) {
          // Mostrar mensaje de error
          /*CustomModal.show(
            context: navigatorKey.currentContext!,
            icon: Icons.cancel_outlined,
            title: "ERROR",
            message: "${answer.message}",
            iconColor: ColorsJunghanns.red,
          );*/
          Fluttertoast.showToast(
            msg: "${answer.message}",
            timeInSecForIosWeb: 16,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            webShowClose: true,
          );
        } else {
          // Mostrar mensaje de éxito
          /*CustomModal.show(
            context: navigatorKey.currentContext!,
            icon: Icons.check_circle,
            title: "EVIDENCIA ENVIADA",
            message: "La evidencia fue enviada correctamente.",
            iconColor: ColorsJunghanns.greenJ,
          );*/
          Fluttertoast.showToast(
            msg: "Evidencia enviada",
            timeInSecForIosWeb: 16,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            webShowClose: true,
          );
        }
      });
  }

  validationDelivery() async {
    bool hasData = false;

    await getValidationList(idR: prefs.idRouteD).then((answer) {
      if (answer.error) {
        print('Error al obtener la lista: ${answer.message}');
      } else {
        if (answer.body is List) {
          validationDeliveryList = (answer.body as List)
              .map((item) => ValidationProductModel.fromJson(item))
              .toList();
        } else if (answer.body is Map) {
          final validation = ValidationProductModel.fromJson(answer.body);
          validationDeliveryList = [validation];
        }

        hasData = validationDeliveryList.isNotEmpty;
        print("Lista de validaciones obtenida: ${validationDeliveryList.length} items.");

        // Recorre cada validación y verifica el estatus
        for (var validation in validationDeliveryList) {
          if (validation.status == "P" && validation.valid == 'Planta') {
            CustomModal.show(
                context: navigatorKey.currentContext!,
                icon: FontAwesomeIcons.clock,
                title: "VALIDACIÓN PENDIENTE",
                message: "Validación pendiente, esperando....",
                iconColor: ColorsJunghanns.blueJ
            );
          } else if (validation.status == "A" && validation.valid == 'Planta') {
            //Pendiente por revisar si carboy la limpeamos
            carboyAccesories.clear();
            accessoriesWithStock.clear();
            returnsWithStock.clear();
            missingProducts.clear();
            additionalProducts.clear();

            Navigator.pushReplacement(
              navigatorKey.currentContext!,
              MaterialPageRoute(builder: (context) => HomePrincipal()),
            );
            // Mostrar mensaje de éxito
            CustomModal.show(
              context: navigatorKey.currentContext!,
              icon: Icons.check_circle,
              title: "VALIDACIÓN CORRECTA",
              message: "El registro de la validación fue exitoso.",
              iconColor: ColorsJunghanns.greenJ,
            );
            print("Validación aceptada.");
            // Aquí puedes llamar a tu función para redirigir al home
           /* home();*/
          } else if (validation.status == "R" && validation.valid == 'Planta') {
            CustomModal.show(
                context: navigatorKey.currentContext!,
                icon: Icons.cancel,
                title: "VALIDACIÓN RECHAZADA",
                message: "La validación fue rechazada por el almacén, verifiqué sus datos enviados.",
                iconColor: ColorsJunghanns.red
            );
          }
        }
      }
    });

    notifyListeners();
    return hasData;
  }
  // Ver el estatus de la lista
  /*fetchValidation() async {
    bool hasData = false;
    await getValidationList(idR: prefs.idRouteD).then((answer) {

      if (answer.error) {
        print('Error al obtener la lista: ${answer.message}');
      } else {
        if (answer.body is List) {
          // Mapear la lista obtenida a objetos ValidationProductModel
          validationList = (answer.body as List)
              .map((item) => ValidationProductModel.fromJson(item))
              .toList();
        } else if (answer.body is Map) {
          // Si es un solo elemento, convertirlo en una lista
          final validation = ValidationProductModel.fromJson(answer.body);
          validationList = [validation];
        }

        // Filtrar la lista por estatus 'P' y valid 'Planta'
        validationList = validationList
            .where((validation) => validation.status == 'P' && validation.valid == 'Planta')
            .toList();

        hasData = validationList.isNotEmpty;
        print("Lista de validaciones filtrada: ${validationList.length} items.");
        // Imprimir cada validación para depuración
        for (var validation in validationList) {
          print(validation);
        }
        print("---Llamando------------------Validacion--");
      }
    });
    notifyListeners();
    return hasData;
  }*/


}

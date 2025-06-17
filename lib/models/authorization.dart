import 'dart:developer';

import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/product.dart';

class AuthorizationModel {
  int idAuth;
  int idClient;
  int idCatAuth;
  String authText;
  String observation;
  String type;
  int idReasonAuth;
  String reason;
  ProductModel product;
  CustomerModel client;
  DateTime date;
  dynamic evidence;
  //String comment;

  AuthorizationModel(
      {required this.idAuth,
      required this.idClient,
      required this.idCatAuth,
      required this.authText,
      required this.type,
      required this.observation,
      required this.idReasonAuth,
      required this.reason,
      required this.product,
      required this.client,
      required this.date});

  factory AuthorizationModel.fromState() {
    return AuthorizationModel(
        idAuth: 0,
        product: ProductModel.fromState(0),
        idClient: 0,
        idCatAuth: 0,
        authText: "TEST",
        type: "0",
        observation: "",
        idReasonAuth: 0,
        reason: "TEST",
        client: CustomerModel.fromState(),
        date: DateTime.now());
  }

  factory AuthorizationModel.fromService(Map<String, dynamic> data) {
    return AuthorizationModel(
        idAuth: data["id"],
        product: ProductModel.fromServiceProduct(data),
        idClient: data["idCliente"] ?? 0,
        type: data["tipo"] ?? "",
        idCatAuth: data["idCatAutorizacion"] ?? 0,
        authText: data["autorizacion"] ?? "",
        observation: data["observacion"] ?? "",
        idReasonAuth: data["idMotivoAutorizacion"] ?? 0,
        reason: data["Motivo"] ?? "",
        client: CustomerModel.fromState(),
        date: DateTime.parse(data["fecha_creado"]!=null&&data["hora_creado"]!=null?"${data["fecha_creado"]} ${data["hora_creado"]}":DateTime.now().toString()));
  }
  factory AuthorizationModel.fromDataBase(Map<String, dynamic> data) {
    return AuthorizationModel(
        idAuth: data["id"],
        product: ProductModel.fromServiceProduct(data["product"]),
        idClient: data["idCliente"] ?? 0,
        type: data["tipo"] ?? "",
        idCatAuth: data["idCatAutorizacion"] ?? 0,
        authText: data["autorizacion"] ?? "",
        observation: data["observacion"] ?? "",
        idReasonAuth: data["idMotivoAutorizacion"] ?? 0,
        reason: data["Motivo"] ?? "",
        client: CustomerModel.fromState(),
        date: DateTime.parse(data["date"]!=null?"${data["date"]}":DateTime.now().toString()));
  }
  getMap() {
    Map<String, dynamic> map = {
      "id": idAuth,
      "product": product.getMap(),
      "idCliente": idClient,
      "tipo": type,
      "idCatAutorizacion": idCatAuth,
      "autorizacion": authText,
      "observacion": observation,
      "date": date.toString()
    };

    // Agrega idMotivoAutorizacion y Motivo solo si tienen valores específicos
    if (idReasonAuth != 0) {
      map["idMotivoAutorizacion"] = idReasonAuth;
    }
    if (reason.isNotEmpty) {
      map["Motivo"] = reason;
    }

    return map;
  }
  bool isEmpty() {
    return idAuth == 0;
  }

set setClient(CustomerModel client){
  this.client=client;
}

  // ProductModel getProduct() {
  //   return ProductModel(
  //       idProduct: idProduct,
  //       description: description,
  //       price: price,
  //       stock: number,
  //       img: img,
  //       type: 1,
  //       number: 1,
  //       isSelect: false,
  //       rank: "");
  // }
}

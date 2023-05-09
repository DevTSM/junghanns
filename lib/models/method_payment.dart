import 'dart:developer';

import 'package:junghanns/models/shopping_basket.dart';

class MethodPayment {
  String wayToPay;
  String typeWayToPay;
  String type;
  int idProductService;
  int idAuth;
  String description;
  int number;

  MethodPayment(
      {required this.wayToPay,
      required this.typeWayToPay,
      required this.type,
      required this.idProductService,
      required this.description,
      this.idAuth=0,
      required this.number});

  factory MethodPayment.fromState() {
    return MethodPayment(
        wayToPay: "Contado",
        typeWayToPay: "E",
        type: "Atributo",
        idProductService: -1,
        description: "",
        number: -1);
  }
  factory MethodPayment.fromWhitOutConnection(){
    return MethodPayment(
      wayToPay: "Efectivo", typeWayToPay: "E", type: "Atributo", idProductService: -1, description: "", number: -1);
  } 
  factory MethodPayment.fromService(Map<String, dynamic> data) {
    return MethodPayment(
        wayToPay: data["formaPago"] ?? "",
        typeWayToPay: data["tipoFormaPago"],
        type: data["type"],
        idProductService: data["idProductoServicio"] ?? -1,
        idAuth: data["idAutorizacion"]??-1,
        description: data["descripcion"] ?? "",
        number: int.parse((data["cantidad"]??-1).toString()));
  }
  getMap(){
    return {
      "formaPago":wayToPay,
      "tipoFormaPago":typeWayToPay,
      "type":type,
      "idProductoServicio":idProductService,
      "idAutorizacion":idAuth,
      "descripcion":description,
      "cantidad":number
    };
  }
  bool getIsFolio(){
  switch(wayToPay){
    case 'Credito':
    return true;
    case 'Prestamo':
    return true;
    default: 
    return false;
  }
  }
}

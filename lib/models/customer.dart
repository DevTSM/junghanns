import 'dart:convert';

import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/config.dart';
import 'package:junghanns/models/method_payment.dart';
import 'package:junghanns/models/sale.dart';

class CustomerModel {
  bool invoice;
  int id;
  int orden;
  int idClient;
  int idRoute;
  double lat;
  double lng;
  double priceLiquid;
  double byCollect;
  double purse;
  String name;
  String address;
  String nameRoute;
  String typeVisit;
  String category;
  String days;
  String img;
  String observation;
  List<MethodPayment> payment;
  List<SaleModel> history;
  List<AuthorizationModel> auth;
  CustomerModel(
      {required this.auth,
      required this.payment,
        required this.invoice,
      required this.id,
      required this.orden,
      required this.idClient,
      required this.idRoute,
      required this.lat,
      required this.lng,
      required this.priceLiquid,
      required this.byCollect,
      required this.purse,
      required this.name,
      required this.address,
      required this.nameRoute,
      required this.typeVisit,
      required this.category,
      required this.days,
      required this.img,
      required this.observation,
      required this.history});
  factory CustomerModel.fromState() {
    return CustomerModel(
      auth: [],
      payment:[],
        invoice: true,
        id: 0,
        orden: 0,
        idClient: 0,
        idRoute: 0,
        lat: 0,
        lng: 0,
        priceLiquid: 0.0,
        byCollect: 0.0,
        purse: 0.0,
        name: "",
        address: "",
        nameRoute: "",
        typeVisit: "",
        category: "",
        days: "",
        img: "",
        observation: "",
        history: []);
  }
  factory CustomerModel.fromList(Map<String, dynamic> data, int idRoute) {
    return CustomerModel(
        invoice: false,
        id: data["id"],
        orden: data["orden"] ?? 0,
        idClient: data["idCliente"],
        idRoute: idRoute,
        lat: 0,
        lng: 0,
        priceLiquid: 0,
        byCollect: 0,
        purse: 0,
        name: data["nombre"],
        address: data["direccion"],
        nameRoute: "",
        typeVisit: data["tipoVisita"],
        category: (data["categoria"] ?? "C") == "C" ? "Cliente" : "Empresa",
        days: "",
        img: "",
        observation: "",
        history: [],
        auth: [],
        payment: []);
  }
  factory CustomerModel.fromService(Map<String, dynamic> data, int id) {
    return CustomerModel(
        invoice: false,
        id: id,
        orden: data["orden"] ?? 0,
        idClient: data["idCliente"] ?? 0,
        idRoute: data["idRuta"] ?? 0,
        lat: double.parse(data["latitud"] ?? "0"),
        lng: double.parse(data["longitud"] ?? "0"),
        priceLiquid: double.parse((data["precioLiquido"] ?? "0").toString()),
        byCollect: double.parse((data["porCobrar"] ?? 0).toString()),
        purse: double.parse((data["monedero"] ?? 0).toString()),
        name: data["nombre"] ?? "",
        address: data["domicilio"] ?? "",
        nameRoute: data["ruta"] ?? "",
        typeVisit: data["tipoVisita"] ?? "",
        category: (data["categoria"] ?? "C") == "C" ? "Cliente" : "Empresa",
        days: data["diasVisita"] ?? "",
        img: data["url"] ?? "",
        observation: (data["observacion"] ?? "") == ""
            ? "Sin observaciones"
            : data["observacion"] ?? "",
        history: [],
        auth: [],
        payment: []);
  }
  factory CustomerModel.fromDataBase(Map<String, dynamic> data) {
    return CustomerModel(
        invoice: false,
        id: data["id"],
        orden: data["orden"] ?? 0,
        idClient: data["idCustomer"] ?? 0,
        idRoute: data["idRuta"] ?? 0,
        lat: data["lat"],
        lng: data["lng"],
        priceLiquid: data["priceLiquid"] ?? 0,
        byCollect: data["byCollet"] ?? 0,
        purse: data["purse"] ?? 0,
        name: data["name"] ?? "",
        address: data["address"] ?? "",
        nameRoute: data["nameRoute"] ?? "",
        typeVisit: data["typeVisit"] ?? "",
        category: (data["category"] ?? "C") == "C" ? "Cliente" : "Empresa",
        days: data["days"] ?? "",
        img: data["img"] ?? "",
        observation: (data["observacion"] ?? "") == ""
            ? "Sin observaciones"
            : data["observacion"] ?? "",
        history: [],
        auth: [],
        payment: []);
  }
  Map<String, dynamic> getMap() {
    return {
      'id': id,
      'orden': orden,
      'idCustomer': idClient,
      'idRoute': idRoute,
      'lat': lat,
      'lng': lng,
      'priceLiquid': priceLiquid,
      'byCollet': byCollect,
      'purse': purse,
      'name': name,
      'address': address,
      'nameRoute': nameRoute,
      'typeVisit': typeVisit,
      'category': category,
      'days': days,
      'img': img,
      'observacion': observation
    };
  }

  setHistory(Map<String, dynamic> data) {
    history = data["historial"] != null
        ? List.from(
            data["historial"].map((e) => SaleModel.fromService(e)).toList())
        : [];
  }

  setMoney(double purse) {
    this.purse = purse;
  }

  setPayment(Map<String, dynamic> data ){}
  setAuth(List<AuthorizationModel> auth){
    this.auth=auth;
  }
}

String checkDate(DateTime time) {
  String date = "";
  switch (time.weekday) {
    case 1:
      date += "Lunes";
      break;
    case 2:
      date += "Martes";
      break;
    case 3:
      date += "Miercoles";
      break;
    case 4:
      date += "Jueves";
      break;
    case 5:
      date += "Viernes";
      break;
    case 6:
      date += "Sabado";
      break;
    case 7:
      date += "Domingo";
      break;
    default:
  }
  date += ", ${time.day} ";
  switch (time.month) {
    case 1:
      date += "Enero";
      break;
    case 2:
      date += "Febrero";
      break;
    case 3:
      date += "Marzo";
      break;
    case 4:
      date += "Abril";
      break;
    case 5:
      date += "Mayo";
      break;
    case 6:
      date += "Junio";
      break;
    case 7:
      date += "Julio";
      break;
    case 8:
      date += "Agosto";
      break;
    case 9:
      date += "Septiembre";
      break;
    case 10:
      date += "Octubre";
      break;
    case 11:
      date += "Noviembre";
      break;
    case 12:
      date += "Diciembre";
      break;
    default:
  }
  return date;
}

List<String> getNameRouteRich(String name) {
  int index = name.lastIndexOf(" ");
  if (index > -1) {
    return [name.substring(0, index), name.substring(index, name.length)];
  } else {
    return [name, ""];
  }
}

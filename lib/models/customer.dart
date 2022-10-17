import 'dart:convert';
import 'dart:developer' as prefix;
import 'dart:math';

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
  int type;
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
  List<ConfigModel> configList;
  String referenceAddress;
  String color;
  //
  String descServiceS;
  int numberS;
  int idProdServS;
  String descriptionS;
  double priceS;
  String notifS;

  CustomerModel(
      {required this.auth,
      required this.configList,
      required this.payment,
      required this.invoice,
      required this.id,
      required this.orden,
      required this.idClient,
      required this.idRoute,
      required this.type,
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
      required this.history,
      //
      required this.referenceAddress,
      required this.color,
      //
      required this.descServiceS,
      required this.numberS,
      required this.idProdServS,
      required this.descriptionS,
      required this.priceS,
      required this.notifS});

  factory CustomerModel.fromState() {
    return CustomerModel(
        auth: [],
        payment: [],
        configList: [],
        invoice: true,
        id: 0,
        orden: 0,
        idClient: 0,
        idRoute: 0,
        type: 0,
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
        history: [],
        //
        referenceAddress: "",
        color: "FF000000",
        //
        descServiceS: "",
        numberS: 0,
        idProdServS: 0,
        descriptionS: "",
        priceS: 0,
        notifS: "");
  }

  factory CustomerModel.fromList(
      Map<String, dynamic> data, int idRoute, int type) {
    return CustomerModel(
        invoice: false,
        id: data["id"],
        orden: data["orden"] ?? 0,
        idClient: data["idCliente"],
        idRoute: idRoute,
        type: type,
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
        configList: [],
        payment: [],
        referenceAddress: "",
        color: data["color"] ?? "FF000000",
        //
        descServiceS: "",
        numberS: 0,
        idProdServS: 0,
        descriptionS: "",
        priceS: 0,
        notifS: "");
  }
  factory CustomerModel.fromService(
      Map<String, dynamic> data, int id, int type) {
    return CustomerModel(
        invoice: false,
        id: id,
        orden: data["orden"] ?? 0,
        idClient: data["idCliente"] ?? 0,
        idRoute: data["idRuta"] ?? 0,
        type: type,
        lat: double.parse((data["latitud"]??"0") != "" ? (data["latitud"]??"0").replaceAll(",", "") : "0"),
        lng: double.parse((data["longitud"]??"0") != "" ? (data["longitud"]??"0").replaceAll(",", ""):"0"),
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
        configList: [],
        payment: [],
        referenceAddress: data["referenciaDomicilio"] ?? "",
        color: data["color"] ?? "FF000000",
        //
        descServiceS: data["descServicio"] ?? "",
        numberS: data["cargosFijos"] != null
            ? int.parse((data["cargosFijos"]["cantidad"] ?? 0).toString())
            : 0,
        idProdServS: data["cargosFijos"] != null
            ? int.parse(
                (data["cargosFijos"]["idProductoServicio"] ?? 0).toString())
            : 0,
        descriptionS: data["cargosFijos"] != null
            ? data["cargosFijos"]["descripcion"] ?? ""
            : "",
        priceS: data["cargosFijos"] != null
            ? double.parse(
                (data["cargosFijos"]["precioUnitario"] ?? 10).toString())
            : 0,
        notifS: data["notificacion"] ?? "");
  }
  factory CustomerModel.fromDataBase(Map<String, dynamic> data) {
    return CustomerModel(
        invoice: false,
        id: data["id"],
        orden: data["orden"] ?? 0,
        idClient: data["idCustomer"] ?? 0,
        idRoute: data["idRuta"] ?? 0,
        type: data["type"] ?? 0,
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
        configList: [ConfigModel.fromDatabase(data["config"]??0)],
        payment: [],
        referenceAddress: data["referenceAddress"] ?? "",
        color: data["color"] ?? "000000",
        //
        descServiceS: "",
        numberS: 0,
        idProdServS: 0,
        descriptionS: "",
        priceS: 0,
        notifS: "",);
  }
  Map<String, dynamic> getMap() {
    return {
      'id': id,
      'orden': orden,
      'idCustomer': idClient,
      'idRoute': idRoute,
      'type': type,
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
      'observacion': observation,
      'auth': "",
      'payment': "",
      'color': color,
      'config':configList.isNotEmpty?configList.first.valor:0
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

  setPayment(List<MethodPayment> payment) {
    this.payment=payment;
  }
  setAuth(List<AuthorizationModel> auth) {
    this.auth = auth;
  }
  setConfig(List<ConfigModel> configList){
    this.configList=configList;
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

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

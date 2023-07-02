import 'dart:convert';
import 'dart:developer';
import 'dart:math' as prefix;

import 'package:flutter/material.dart';
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/billing.dart';
import 'package:junghanns/models/config.dart';
import 'package:junghanns/models/method_payment.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/preferences/global_variables.dart';

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
  List<String> phones;
  List<MethodPayment> payment;
  List<SaleModel> history;
  List<AuthorizationModel> auth;
  List<ConfigModel> configList;
  List<BillingModel> billing;
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
      {required this.phones,
        required this.auth,
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
      required this.billing,
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
      phones: [],
        auth: [],
        payment: [],
        configList: [],
        invoice: true,
        id: 0,
        orden: 0,
        idClient: 0,
        idRoute: 0,
        type: 0,
        lat: 37.4220,
        lng: -122.0840,
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
        billing: [],
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
      phones: [],
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
        billing: [],
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
        List<BillingModel> billing=[];
        if(data["billing"]!=null){
      data["billing"].map((e)=>billing.add(BillingModel.fromService(e))).toList();
    }
    return CustomerModel(
      phones: [],
      billing: billing,
        invoice: billing.isNotEmpty,
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
    int cantidad=0;
    int idProductoServicio=0;
    double precioU=0;
    String descripcion="";
    String not="";
    String desc="";
    List<BillingModel> billing=[];
    if(data["cargoAdicional"]!=null&&data["cargoAdicional"]!=""){
    Map<String,dynamic> data2=jsonDecode(data["cargoAdicional"]);
      cantidad=data2["cargosFijos"]!=null?int.parse((data2["cargosFijos"]["cantidad"]??0).toString()):0;
      idProductoServicio=data2["cargosFijos"]!=null?int.parse((data2["cargosFijos"]["idProductoServicio"]??0).toString()):0;
      descripcion=data2["cargosFijos"]!=null?data2["cargosFijos"]["descripcion"]??"":"";
      precioU=data2["cargosFijos"]!=null?double.parse((data2["cargosFijos"]["precioUnitario"]??0).toString()):0;
      not=data2["notificacion"]??"";
      desc=data2["descServicio"]??"";
    }
    if(data["billing"]!=null){
      jsonDecode(data["billing"]).map((e)=>billing.add(BillingModel.fromService(e))).toList();
    }
    return CustomerModel(
      phones: [],
        invoice: billing.isNotEmpty,
        billing: billing,
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
        auth: data["auth"]!=""?List.from(jsonDecode(data["auth"]).map((e)=>AuthorizationModel.fromDataBase(e)).toList()):[],
        //auth: [],
        configList: [ConfigModel.fromDatabase(data["config"]??0)],
        payment: data["payment"]!=""?List.from(jsonDecode(data["payment"]).map((e)=>MethodPayment.fromService(e)).toList()):[],
        //payment: [],
        referenceAddress: data["referenciaDomicilio"] ?? "",
        color: data["color"] ?? "000000",
        //
        descServiceS: desc,
        numberS: cantidad,
        idProdServS: idProductoServicio,
        descriptionS: descripcion,
        priceS: precioU,
        notifS: not,);
  }
  factory CustomerModel.fromPayload(Map<String,dynamic>data,{bool isAtendido=false}){
    int cantidad=0;
    int idProductoServicio=0;
    double precioU=0;
    String descripcion="";
    String not="";
    String desc="";
    List<BillingModel> billing=[];
    if((data["clue"]??"CR")=="ES"){
      cantidad=data["cargoAdicional"]!=null?data["cargoAdicional"]["cargosFijos"]!=null?int.parse((data["cargoAdicional"]["cargosFijos"]["cantidad"]??0).toString()):0:0;
      idProductoServicio=data["cargoAdicional"]!=null?data["cargoAdicional"]["cargosFijos"]!=null?int.parse((data["cargoAdicional"]["cargosFijos"]["idProductoServicio"]??0).toString()):0:0;
      descripcion=data["cargoAdicional"]!=null?data["cargoAdicional"]["cargosFijos"]!=null?data["cargoAdicional"]["cargosFijos"]["descripcion"]??"":"":"";
      precioU=data["cargoAdicional"]!=null?data["cargoAdicional"]["cargosFijos"]!=null?double.parse((data["cargoAdicional"]["cargosFijos"]["precioUnitario"]??0).toString()):0:0;
      not=data["cargoAdicional"]!=null?data["cargoAdicional"]["notificacion"]??"":"";
      desc=data["cargoAdicional"]!=null?data["cargoAdicional"]["descServicio"]??"":"";
    }
    if(data["billing"]!=null){
      data["billing"].map((e)=>billing.add(BillingModel.fromService(e))).toList();
    }
    return CustomerModel(
      phones: [],
      auth: List.from(data["auth"]).map((e)=>AuthorizationModel.fromService(e)).toList(), 
      configList: [ConfigModel.fromService(data["config"]??0)], 
      payment: data["payment"]!=""?List.from(data["payment"]).map((e)=>MethodPayment.fromService(e)).toList():[], 
      invoice: billing.isNotEmpty,
      billing: billing, 
      id: data["id"], 
      orden: data["orden"] ?? 0, 
      idClient:  data["id_client"] ?? 0, 
      idRoute: int.parse((data["id_route"] ?? 0).toString()), 
      type: isAtendido?7:getType(data["clue"]??"CR"), 
      lat:  double.parse((data["lat"]??0).toString()), 
      lng:  double.parse((data["lon"]??0).toString()), 
      priceLiquid: double.parse((data["price"]??0).toString()), 
      byCollect:  double.parse((data["por_cobrar"]??0).toString()), 
      purse:  double.parse((data["purse"]??0).toString()), 
      name: data["name"]??"", 
      address: data["address"]??"", 
      nameRoute: data["nameRoute"]??"", 
      typeVisit: data["typeVisit"]??"", 
      category: data["category"]??"", 
      days: data["days"]??"", 
      img: data["img"]??"",
      observation: (data["observacion"] ?? "") == ""
            ? "Sin observaciones"
            : data["observacion"] ?? "",
      history: [], 
      referenceAddress: data["referenciaDomicilio"] ?? "",
      color: data["color"] ?? "FF000000", 
      numberS: cantidad, 
      idProdServS: idProductoServicio, 
      descriptionS: descripcion, 
      priceS: precioU,
      notifS: not, 
      descServiceS: desc);
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
      'auth': auth.isNotEmpty?jsonEncode(auth.map((e) => e.getMap()).toList()):"",
      'payment': payment.isNotEmpty?jsonEncode(payment.map((e) => e.getMap()).toList()):"",
      'color': color,
      'config':configList.isNotEmpty?configList.last.valor:0,
      'history':history.isNotEmpty?jsonEncode(history.map((e) => e.getMap).toList()):"",
      'cargoAdicional':jsonEncode({"notificacion":notifS,"descServicio":descServiceS,"cargosFijos":{"cantidad":numberS,"idProductoServicio":idProdServS,"descripcion":descriptionS,"precioUnitario":priceS}}),
      'referenciaDomicilio':referenceAddress,
      'billing':jsonEncode(List.from(billing.map((e) => e.getMap).toList()))
    };
  }
  delete(int id){
    auth.removeWhere((element) => element.idAuth==id);
  }
  setHistory(Map<String, dynamic> data) {
    history = data["historial"] != null
        ? List.from(
            data["historial"].map((e) => SaleModel.fromService(e)).toList())
        : [];
  }
  addHistory(Map<String, dynamic> data) {
    history.insert(0,SaleModel.fromService(data));
  }

  setMoney(double purse,{bool isOffline=false,int type=0}) async {
    this.purse = purse;
    if(isOffline){
      this.type=type;
      await handler.updateUser(this);
    }
  }
  setType(int type) async {
    this.type=type;
     await handler.updateUser(this);
  }
  setPayment(List<MethodPayment> payment) {
    this.payment=payment;
  }
  setPaymentAdd(MethodPayment payment){
    this.payment.add(payment);
  }
  setAuth(List<AuthorizationModel> auth) {
    this.auth = auth;
  }
  setConfig(List<ConfigModel> configList){
    this.configList=configList;
  }
  setPhones(List<String> phones){
    this.phones=phones;
  }
  set setData(Map<String,dynamic> data){
        invoice= false;
        lat= double.parse((data["latitud"]??"0") != "" ? (data["latitud"]??"0").replaceAll(",", "") : "0");
        lng= double.parse((data["longitud"]??"0") != "" ? (data["longitud"]??"0").replaceAll(",", ""):"0");
        priceLiquid= double.parse((data["precioLiquido"] ?? "0").toString());
        byCollect= double.parse((data["porCobrar"] ?? 0).toString());
        purse= double.parse((data["monedero"] ?? 0).toString());
        name= data["nombre"] ?? "";
        address= data["domicilio"] ?? "";
        typeVisit= data["tipoVisita"] ?? "";
        category= (data["categoria"] ?? "C") == "C" ? "Cliente" : "Empresa";
        days= data["diasVisita"] ?? "";
        img= data["url"] ?? "";
        observation= (data["observacion"] ?? "") == ""
            ? "Sin observaciones"
            : data["observacion"] ?? "";
        referenceAddress= data["referenciaDomicilio"] ?? "";
        color= data["color"] ?? "FF000000";
        //
        descServiceS= data["descServicio"] ?? "";
        numberS= data["cargosFijos"] != null
            ? int.parse((data["cargosFijos"]["cantidad"] ?? 0).toString())
            : 0;
        idProdServS= data["cargosFijos"] != null
            ? int.parse(
                (data["cargosFijos"]["idProductoServicio"] ?? 0).toString())
            : 0;
        descriptionS= data["cargosFijos"] != null
            ? data["cargosFijos"]["descripcion"] ?? ""
            : "";
        priceS= data["cargosFijos"] != null
            ? double.parse(
                (data["cargosFijos"]["precioUnitario"] ?? 10).toString())
            : 0;
        notifS= data["notificacion"] ?? "";
  }
  
}
int getType(type){
  switch (type) {
    case "ES":
      return 2;
    case "SV":
    return 3;
    case "LC":
    return 4;
    case "ET":
    return 5;
    case "CL":
    return 6;
    default: 
    return 1;
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
      prefix.cos((lat2 - lat1) * p) / 2 +
      prefix.cos(lat1 * p) * prefix.cos(lat2 * p) * (1 - prefix.cos((lon2 - lon1) * p)) / 2;
  return 12742 * prefix.asin(prefix.sqrt(a));
}

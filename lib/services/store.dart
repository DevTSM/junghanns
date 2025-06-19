// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:junghanns/models/answer.dart';

import '../preferences/global_variables.dart';
Future<Answer> getDataQr() async {
  log("/StoreServices <getDataQr>");
  try {
    var response = await http.get(
        Uri.parse("${prefs.urlBase}ruta?idRuta=${prefs.idRouteD}&fecha=${(DateFormat('yyyyMMdd').format(DateTime.now()))}&q=roll"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }).timeout(Duration(seconds:timerDuration));
    log("${response.statusCode}");
    return Answer.fromService(response,200);
  } catch (e) {
    log("/StoreServices <getDataQr> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> postSale(Map<String, dynamic> data) async {
  log("/StoreServices <PostSale>");
  try {
    var response = await http.post(Uri.parse("${prefs.urlBase}venta"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        },
        body: jsonEncode(data)).timeout(Duration(seconds: timerDuration));
        return Answer.fromService(response,201);
  } catch (e) {
    print("/StoreServices <setSale> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> getStopsList() async {
  final url = "${prefs.urlBase}paradas";
  log("/StoreServices <getStopsList>");
  print("Request URL: $url"); // Imprime la URL antes de hacer la petición

  try {
    var body = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    }).timeout(Duration(seconds: timerDuration));

    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');

    return Answer.fromService(body, body.statusCode);
  } catch (e) {
    log("/StoreServices <getStopsList> Catch ${e.toString()}");
    return Answer(
        body: e.toString(),
        message: "Conexión inestable con el back",
        status: 1002,
        error: true);
  }
}

/*Future<Answer> getStopsList() async {
  log("/StoreServices <getStopsList>");
  try {
    var body = await http.get(Uri.parse("${prefs.urlBase}paradas"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    }).timeout(Duration(seconds: timerDuration));
    print('imprimeindo body ${body}');
    return Answer.fromService(body,200);
  } catch (e) {
    log("/StoreServices <getStopsList> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}*/
Future<Answer> postStop(Map<String, dynamic> data) async {
  log("/StoreServices <PostStop>");
  try {
    var response = await http.post(Uri.parse("${prefs.urlBase}paradas"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}"
        },
        body: jsonEncode(data)).timeout(Duration(seconds: timerDuration));
        return Answer.fromService(response,201);
  } catch (e) {
    log("/StoreServices <SetStop> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> getDashboarRuta(int idR, DateTime date) async {
  log("/StoreServices <getDashboardRuta>");
  try {
    var response = await http.get(
        Uri.parse(
            "${prefs.urlBase}dashboardruta?idRuta=$idR&date=${(DateFormat('yyyyMMdd').format(date))}"),
        headers: {
          HttpHeaders.contentTypeHeader: "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }).timeout(Duration(seconds:timerDuration));
    log("${response.body} -----");
    return Answer.fromService(response,200);
  } catch (e) {
    log("/CustomerServices <getDashboardRuta> Catch ${e.toString()}");
    return Answer(
        body: {"error": e.toString()},
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> postResendCode(Map<String, dynamic> data) async {
  log("/StoreServices <PostResendCode>");
  try {
    var response = await http.post(Uri.parse("${prefs.urlBase}otp"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}"
        },
        body: jsonEncode(data));
        return Answer.fromService(response,201,message: "Error inesperado");
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> setComodato(AndroidDeviceInfo build, int id, double lat,
    double lng, int idProduct,int cantidad,int idAuth,String phone) async {
  log("/StoreServices <setComodato> $cantidad");
  try {
    var response = await http.post(Uri.parse("${prefs.urlBase}rutasolicitud"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        },
        body: jsonEncode({
          "tipo": "FC",
          "phone": phone,
          "lat": lat.toString(),
          "lon": lng.toString(),
          "id_cliente": id,
          "id_producto":idProduct,
          "cantidad":cantidad,
          "id_autorizacion":idAuth,
          "emisor": {
            "FingerPrint": build.fingerprint,
            "Modelo": build.model,
            "Marca": build.manufacturer,
            "VersionSO": build.version.securityPatch,
            "SerialNumber": build.id,
            "Imac": build.board
          }
        }));
    log("/StoreServices <setComodato>");
    return Answer.fromService(response,201);
  } catch (e) {
    log("/StoreServices <setComodato> Catch");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}
Future<Answer> getStatusComodato(int id) async {
  log("/StoreServices <getStatusComodato>");
  try {
    var response = await http
        .get(Uri.parse("${prefs.urlBase}rutasolicitud?id=$id"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    });
    log("/StoreServices <getStatusComodato> ${response.body}");
    return Answer.fromService(response,200);
  } catch (e) {
    log("/StoreServices <getStatusComodato> Catch");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}
Future<Answer> getCustomers({int idLast = 0}) async {
  log("/StoreServices <getCustomers>");
  try {
    var response = await http.get(
        Uri.parse(
            "${prefs.urlBase}payload?idRuta=${prefs.idRouteD}&date=${DateFormat('yyyyMMdd').format(DateTime.now())}${idLast == 0 ? '' : '&sync=$idLast'}"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }).timeout(Duration(seconds: timerDuration));
    return Answer.fromService(response,200, message: "error al obtener los datos");
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> getCustomersAtendidos() async {
  log("/StoreServices <getCustomers>");
  try {
    var response = await http.get(
        Uri.parse(
            "${prefs.urlBase}payload?idRuta=${prefs.idRouteD}&date=${DateFormat('yyyyMMdd').format(DateTime.now())}&filter=atn"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        });
    return Answer.fromService(response,200);
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}
Future<Answer> getFolios() async {
  log("/StoreServices <getFolios>");
  try {
    var response = await http.get(
        Uri.parse(
            "${prefs.urlBase}validate?q=folios&id_ruta=${prefs.idRouteD}"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }).timeout(Duration(seconds: timerDuration));
    return Answer.fromService(response,200, message: "error al obtener los datos");
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}
Future<Answer> getBrands() async {
  log("/StoreServices <getBrands>");
  try {
    var body = await http.get(Uri.parse("${prefs.urlBase}marcasgarrafon"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    }).timeout(Duration(seconds: timerDuration));
    return Answer.fromService(body,200,message: "Error inesperado");
  } catch (e) {
    log("/StoreServices <getBrands> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> getTransfer({String type="E"}) async {
  log("/StoreServices <getTransfer>");
  try {
    var body = await http.get(Uri.parse("${prefs.urlBase}transferalmacen?idRuta=${prefs.idRouteD}&tipo=$type"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    }).timeout(Duration(seconds: timerDuration));
    return Answer.fromService(body,200,message: "Error inesperado");
  } catch (e) {
    log("/StoreServices <getTransfer> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> getRoutes() async {
  log("/StoreServices <getRoutes>");
  try {
    var body = await http.get(Uri.parse("${prefs.urlBase}rutas"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    }).timeout(Duration(seconds: timerDuration));
    return Answer.fromService(body,200,message: "Error inesperado");
  } catch (e) {
    log("/StoreServices <getRoutes> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> getProducts() async {
  log("/StoreServices <getProducts>");
  try {
    var body = await http.get(Uri.parse("${prefs.urlBase}productos"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    }).timeout(Duration(seconds: timerDuration));
    return Answer.fromService(body,200,message: "Error inesperado");
  } catch (e) {
    log("/StoreServices <getProducts> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> setTransferNew(Map<String,dynamic> data) async {
  log("/StoreServices <setTransferNew>");
  try {
    var body = await http.post(Uri.parse("${prefs.urlBase}transferalmacen"), headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    },body: jsonEncode(data)).timeout(Duration(seconds: timerDuration));
    return Answer.fromService(body,201,message: "Error inesperado");
  } catch (e) {
    log("/StoreServices <setTransferNew> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> setStatusTransfer(Map<String,dynamic> data) async {
  log("/StoreServices <setStatusTransfer>");
  try {
    var body = await http.put(Uri.parse("${prefs.urlBase}transferalmacen"), headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    },body: jsonEncode(data)).timeout(Duration(seconds: timerDuration));
    return Answer.fromService(body,200,message: "Error inesperado");
  } catch (e) {
    log("/StoreServices <setStatusTransfer> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> postNewCustomer(Map<String, dynamic> data) async {
  log("/StoreServices <PostNewCustomer>");
  try {
    var response = await http.post(Uri.parse("${prefs.urlBase}cliente"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}"
        },
        body: jsonEncode(data));
        return Answer.fromService(response,201);
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> getStatusRecordNewCustomer(int idR) async {
  log("/StoreServices <getStatusRecordNewCustomer>");
  try {
    var response = await http.get(
        Uri.parse("${prefs.urlBase}cliente?q=lead_estatus&id_ruta=$idR&u=${prefs.nameUserD}"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        });
    return Answer.fromService(response,200);
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}
/////////////////////////////////////////////
Future<Answer> getStockList(int idR) async {
  log("/StoreServices <getStockList>");
  try {
    var response = await http.get(
        Uri.parse("${prefs.urlBase}almacenmovil?q=stock&id_ruta=$idR"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }).timeout(Duration(seconds: timerDuration));
    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);
      log("Response Body: $decodedBody");
      log("/StoreServices <getStockList> Successfull");
      return Answer(body: jsonDecode(response.body), message: "",status:response.statusCode, error: false);
    } else {
      log("/StoreServices <getStockList> Fail");
      var decodedBody = jsonDecode(response.body);
      log("/StoreServices <getStockList> Fail");
      log("Response Body: $decodedBody");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",status:response.statusCode,
          error: true);
    }
  } catch (e) {
    log("/StoreServices <getStockList> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}

Future<Answer> setInitRoute(double lat, double lng,
    {String status = "inicio"}) async {
  log("/StoreServices <setInitRoute>");
  try {
    Map<String, dynamic> data = {
      "tipo": status,
      "latitud": lat.toString(),
      "longitud": lng.toString()
    };
    var response = await http.post(Uri.parse("${prefs.urlBase}ruta"),
        headers: {
          //"Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        },
        body: data);
    log("Estatus code ${response.statusCode} body ${response.body}");
    if (response.statusCode == 201) {
      log("/StoreServices <setInitRoute> Successfull, ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "",status: response.statusCode, error: false);
    } else {
      log("/StoreServices <setInitRoute> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          status: response.statusCode,
          error: true);
    }
  } catch (e) {
    log("/StoreServices <setInitRoute> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}

Future<Answer> getRefillList(int idR) async {
  log("/StoreServices <getRefillList>");
  try {
    var response = await http.get(
        Uri.parse("${prefs.urlBase}almacenmovil?q=recarga&id_ruta=$idR"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }).timeout(Duration(seconds: timerDuration));
    if (response.statusCode == 200) {
      log("/StoreServices <getRefillList> Successfull");
      return Answer(body: jsonDecode(response.body), message: "",status: response.statusCode, error: false);
    } else {
      log("/StoreServices <getRefillList> Failed with status: ${response.statusCode}, body: ${response.body}");
      log("/StoreServices <getRefillList> Failed with status: ${response.statusCode}, body: ${response.body}");

      log("/StoreServices <getRefillList> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",status: response.statusCode,
          error: true);
    }
  } catch (e) {
    log("/StoreServices <getRefillList> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}

Future<Answer> getPaymentMethods(int idClient, int idR) async {
  log("/StoreServices <getPaymentMethods>");
  try {
    var response = await http.get(
        Uri.parse(
            "${prefs.urlBase}cliente?q=pay&idRuta=$idR&idCliente=$idClient"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        });
    if (response.statusCode == 200) {
      log("/StoreServices <getPaymentMethods> Successfull ${response.body} ");
      return Answer(body: jsonDecode(response.body), message: "",status: response.statusCode, error: false);
    } else {
      log("/StoreServices <getPaymentMethods> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",status: response.statusCode,
          error: true);
    }
  } catch (e) {
    log("/StoreServices <getPaymentMethods> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}

Future<Answer> getAuthorization(int idClient, int idR) async {
  log("/StoreServices <getAuthorization>");
  try {
    var response = await http.get(
        Uri.parse(
            "${prefs.urlBase}cliente?q=aut&idRuta=$idR&idCliente=$idClient&tipo=contado"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }).timeout(Duration(seconds: timerDuration));
    if (response.statusCode == 200) {
      log("/StoreServices <getAuthorization> Successfull, ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "",status: response.statusCode, error: false);
    } else {
      log("/StoreServices <getAuthorization> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",status: response.statusCode,
          error: true);
    }
  } catch (e) {
    log("/StoreServices <getAuthorization> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}

Future<dynamic> updateAvatar(dynamic image, String id, String cedis) async {
  log("/StoreServices <updateAvatar> ");
  try {
    var uri = Uri.parse("${prefs.urlBase}cliente");
    final response = new http.MultipartRequest("POST", uri);
    response.headers["Content-Type"] = 'application/json; charset=UTF-8';
    response.headers["x-api-key"] = apiKey;
    response.headers["client_secret"] = prefs.clientSecret;
    response.headers["Authorization"] = "Bearer ${prefs.token}";
    // var multipartFile = http.MultipartFile('image', stream, length,
    //     filename: basename(image.path));

    response.files.add(image);
    response.fields
        .addAll({"action": "updimg", "id_cliente": id, "cedis": cedis});
    var value1;
    var respo = await response.send();
    respo.stream.transform(utf8.decoder).listen((value) {
      log("<------Fin User services <updateAvatar> ------->");

      value1 = value;
      log(value.toString());
      return value1;
    });
    return value1;
  } catch (e) {
    log("/StoreServices <updateAvatar> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}

Future<Answer> getTypesOfStreets() async {
  log("/StoreServices <getTypesOfStreets>");
  try {
    var response =
        await http.get(Uri.parse("${prefs.urlBase}vialidades"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    });
    if (response.statusCode == 200) {
      log("/StoreServices <getTypesOfStreets> Successfull");
      return Answer(body: jsonDecode(response.body), message: "",status: response.statusCode, error: false);
    } else {
      log("/StoreServices <getTypresOfStreets> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          status: response.statusCode,
          error: true);
    }
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}

Future<Answer> getTypesOfSalesC() async {
  log("/StoreServices <getTypesOfSalesC>");
  try {
    var response =
        await http.get(Uri.parse("${prefs.urlBase}tipovtacambaceo"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    });
    log("${response.statusCode}");
    if (response.statusCode == 200) {
      log("/StoreServices <getTypesOfSalesC> Successfull");
      return Answer(body: jsonDecode(response.body), message: "",status: response.statusCode, error: false);
    } else {
      log("/StoreServices <getTypresOfSalesC> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          status: response.statusCode,
          error: true);
    }
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Conexión inestable con el back",
        status: 1002,
        error: true);
  }
}

Future<Answer> getEmployees() async {
  log("/StoreServices <getEmployees>");
  try {
    var response =
        await http.get(Uri.parse("${prefs.urlBase}empleados"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    });
    log("${response.statusCode}");
    if (response.statusCode == 200) {
      log("/StoreServices <getEmployees> Successfull");
      return Answer(body: jsonDecode(response.body), message: "",status: response.statusCode, error: false);
    } else {
      log("/StoreServices <getEmployees> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          status: response.statusCode,
          error: true);
    }
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Conexión inestable con el back",
        status: 1002,
        error: true);
  }
}



Future<Answer> putValidateOTP(Map<String, dynamic> data) async {
  log("/StoreServices <PutValidateOTP>");
  try {
    var response = await http.put(Uri.parse("${prefs.urlBase}otp"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}"
        },
        body: jsonEncode(data));
    var dataOTP = jsonDecode(response.body);
    if (response.statusCode == 200) {
      String check = dataOTP["message"] ?? "";
      if (check == "") {
        log("/StoreServices <PutValidateOTP> Successfull ${response.body}");
        return Answer(
            body: jsonDecode(response.body), message: "",status: response.statusCode, error: false);
      } else {
        log("/StoreServices <PutValidateOTP> Fail ${response.body}");
        return Answer(body: dataOTP, message: dataOTP["message"],status: response.statusCode, error: true);
      }
    } else {
      log("/StoreServices <PutValidateOTP> Fail ${response.body}");
      return Answer(body: dataOTP, message: response.body,status: response.statusCode, error: true);
    }
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Conexión inestable con el back",
        status: 1002,
        error: true);
  }
}

Future<Answer> putCancelOTP(Map<String, dynamic> data) async {
  log("/StoreServices <PutCancelOTP>");
  try {
    var response = await http.put(Uri.parse("${prefs.urlBase}cliente"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}"
        },
        body: jsonEncode(data));
    var dataOTP = jsonDecode(response.body);
    if (response.statusCode == 200) {
      String check = dataOTP["status"] ?? "";
      if (check == "Rechazado") {
        log("/StoreServices <PutCancelOTP> Successfull");
        return Answer(
            body: jsonDecode(response.body), message: "Cancelacion exitosa",status: response.statusCode, error: false);
      } else {
        log("/StoreServices <PutCancelOTP> 1-Fail");
        return Answer(body: dataOTP, message: dataOTP["message"]??"Error inesperado",status: response.statusCode, error: true);
      }
    } else {
      log("/StoreServices <PutCancelOTP> 2-Fail");
      return Answer(body: dataOTP, message: dataOTP["message"]??"Error inesperado",status: response.statusCode, error: true);
    }
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Conexión inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> getCancelAuth(Map<String, dynamic> data) async {
  log("/StoreServices <getCancelAuth> $data");
  try {
    var response = await http.delete(Uri.parse("${prefs.urlBase}clienteautorizacion"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}"
        },
        body: jsonEncode(data)).timeout(Duration(seconds: timerDuration+5));
        return Answer.fromService(response, 202);
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Conexión inestable con el back",
        status: 1002,
        error: true);
  }
}
////////////////////////////////////////////
Future<Answer> getStockDeliveryList({required int idR}) async {
  log("/StoreServices <getStockReturnList>");
  Map<String, dynamic> body = {
    "id_ruta": idR,
  };
  log("Request: $body");
  try {
    var response = await http.get(
      //Verificar la URL del stock
        Uri.parse("${prefs.urlBase}almacenmovil?q=StockDevolverRuta&id_ruta=$idR"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }).timeout(Duration(seconds: timerDuration));
    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);
      log("/StoreServices <getStockReturnList> Successfull");
      log("Response Body: $decodedBody");
      return Answer(body: jsonDecode(response.body), message: "",status:response.statusCode, error: false);
    } else {
      var decodedBody = jsonDecode(response.body);
      log("/StoreServices <getStockReturnList> Fail");
      log("Response Body: $decodedBody");
      return Answer(
          body: response,
          message: "No se pudieron obtener los datos actualizados de la planta. Revisa tu conexión a internet.",
          status:response.statusCode,
          error: true);
    }
  } catch (e) {
    log("/StoreServices <getStockList> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexión inestable con el back",
        status: 1002,
        error: true);
  }
}
// Future<Answer> getValidationList({required int idR} String? type) async {
//   log("/StoreServices <getValidationList>");
//   /*// Imprimir el request
//   log("Request URL: ${prefs.urlBase}almacenmovil?q=EstatusValidacion&id_ruta=$idR");
// */
//   try {
//     var response = await http.get(
//         Uri.parse("${prefs.urlBase}almacenmovil?q=EstatusValidacion&id_ruta=$idR"),
//         headers: {
//           "Content-Type": "aplication/json",
//           "x-api-key": apiKey,
//           "client_secret": prefs.clientSecret,
//           "Authorization": "Bearer ${prefs.token}",
//         }).timeout(Duration(seconds: timerDuration));
//     if (response.statusCode == 200) {
//       var decodedBody = jsonDecode(response.body);
//       log("/StoreServices <getValidationList> Successfull");
//       log("Response Body: $decodedBody");
//       return Answer(body: jsonDecode(response.body), message: "",status:response.statusCode, error: false);
//     } else {
//       var decodedBody = jsonDecode(response.body);
//       log("/StoreServices <getValidationList> Fail");
//       log("Response Body: $decodedBody");
//       return Answer(
//           body: jsonDecode(response.body),
//           message: "Algo salio mal, intentalo mas tarde.",status:response.statusCode,
//           error: true);
//     }
//   } catch (e) {
//     log("/StoreServices <getValidationList> Catch ${e.toString()}");
//     return Answer(
//         body: e,
//         message: "Conexión inestable con el back",
//         status: 1002,
//         error: true);
//   }
// }
Future<Answer> getValidationList({
  required int idR,
  String? type,
}) async {
  log("/StoreServices <getValidationList>");

  // Construir la URL base
  String url = "${prefs.urlBase}almacenmovil?q=EstatusValidacion&id_ruta=$idR";

  // Si 'type' no es null, agregar el parámetro tipo_validacion
  if (type != null) {
    url += "&tipo_validacion=$type";
  }

  try {
    var response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }).timeout(Duration(seconds: timerDuration));

    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);
      log("/StoreServices <getValidationList> Successfull");
      log("Response Body: $decodedBody");
      return Answer(
          body: decodedBody,
          message: "",
          status: response.statusCode,
          error: false
      );
    } else {
      var decodedBody = jsonDecode(response.body);
      log("/StoreServices <getValidationList> Fail");
      log("Response Body: $decodedBody");
      return Answer(
          body: decodedBody,
          message: "Algo salió mal, intentalo más tarde.",
          status: response.statusCode,
          error: true
      );
    }
  } catch (e) {
    log("/StoreServices <getValidationList> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexión inestable con el back",
        status: 1002,
        error: true
    );
  }
}

Future<Answer> putValidated({required String action, required int idV, required double lat, required double lng, required String status, String ?comment}) async {
  log("/StoreServices <postValidated> ¡");
  try {
    Map<String, dynamic> body = {
      "action": action,
      "id_validacion": idV,
      "lat": lat.toString(),
      "lon": lng.toString(),
      "estatus": status,
    };

    // Si la acción es 'R' y el comentario no es nulo ni vacío, agregarlo al cuerpo
    if (status == 'R' && comment != null && comment.isNotEmpty) {
      body["comentario"] = comment;
    }
    // Imprimir el cuerpo antes de enviarlo
    log("Body enviado: ${jsonEncode(body)}");

    var response = await http.put(Uri.parse("${prefs.urlBase}almacenmovil"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        },
        // Verificar lso datos
        body: jsonEncode(body) );
    log("/StoreServices <postValidated>");
    return Answer.fromService(response,201);
  } catch (e) {
    log("/StoreServices <postValidated> Catch");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexión a internet.",
        status: 1002,
        error: true);
  }
}
Future<Answer> postDelivery({
  required int idR,
  required double lat,
  required double lon,
  required String equipo,
  required String marca,
  required String modelo,
  int ? idDestination,
  required Map<String, dynamic> entrega,
}) async {
  log("/StoreServices <postDelivery> ¡");

  try {
    // Construir el cuerpo de la petición
    Map<String, dynamic> body = {
      "id_ruta": idR,
      "lat": lat.toString(), // Convertir los doubles a String
      "lon": lon.toString(),
      "equipo": equipo,
      'marca': marca,
      'modelo': modelo,
      "entrega": entrega, // Pasar directamente el Map de la entrega
    };

    if (idDestination != null || idDestination != 0) {
      body["id_ruta_destino"] = idDestination;
    }

    // Imprimir el cuerpo antes de enviarlo
    log("Body enviado: ${jsonEncode(body)}");

    // Realizar la petición POST
    var response = await http.post(
      Uri.parse("${prefs.urlBase}almacenmovil"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        "x-api-key": apiKey,
        "client_secret": prefs.clientSecret,
        "Authorization": "Bearer ${prefs.token}",
      },
      body: jsonEncode(body),
    );

    log("/StoreServices <postDelivery>");
    var dataOTP = jsonDecode(response.body);
    log("Estatus code ${response.statusCode} body ${response.body}");
    if (response.statusCode == 201) {
      log("/StoreServices <postDelivery> Successfull, ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "",status: response.statusCode, error: false);
    } else {
      log("/StoreServices <postDelivery> Fail");
      return Answer(
        body: response.body,
        message: dataOTP['message'],
        status: response.statusCode,
        error: true,
      );
    }
  } catch (e) {
    log("/StoreServices <postDelivery> Catch");
    return Answer(
      body: e.toString(),
      message: "Algo salió mal, revisa tu conexión a internet.",
      status: 1002,
      error: true,
    );
  }
}
Future<Answer> deleteReceiption({required int idV, String? comment, required double lat, required double lng}) async {
  log("/StoreServices <deleteValidated> ¡");
  try {
    Map<String, dynamic> body = {
      "id_validacion": idV,
      "comentario": comment,
      "lat": lat.toString(),
      "lon": lng.toString(),
    };

    // Imprimir el cuerpo antes de enviarlo
    log("Body enviado: ${jsonEncode(body)}");

    var response = await http.delete(Uri.parse("${prefs.urlBase}almacenmovil"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        },
        // Verificar lso datos
        body: jsonEncode(body) );
    log("/StoreServices <deleteValidated>");
    return Answer.fromService(response,201);
  } catch (e) {
    log("/StoreServices <deleteValidated> Catch");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}

Future<Answer> postDirtyBroken({
  required String idRuta,
  required String idCliente,
  required String tipo,
  required String cantidad,
  required double lat,
  required double lon,
  required File archivo,
  required String fechaRegistro,
  required int idAutorization,
  required String idTransaccion,
}) async {
  log("/StoreServices <postDirtyBroken> ¡");

  try {
    // Validación del tipo
    if (tipo != "S" && tipo != "R" && tipo != "MS") {
      throw Exception("Tipo inválido. Solo se acepta 'S' o 'R' o 'MS'.");
    }

    // Prepara la URI
    var uri = Uri.parse("${prefs.urlBase}mermaruta");

    // Crea la solicitud MultipartRequest
    var request = http.MultipartRequest("POST", uri);

    // Agrega los encabezados
    request.headers.addAll({
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    });

    // Imprimir encabezados para depuración
    log("Headers: ${request.headers}");

    // Agrega los campos al body
    request.fields['id_ruta'] = idRuta;
    request.fields['id_cliente'] = idCliente;
    request.fields['tipo'] = tipo;
    request.fields['cantidad'] = cantidad;
    request.fields['lat'] = lat.toString();
    request.fields['lon'] = lon.toString();
    request.fields['id_autorizacion'] = idAutorization.toString();
    request.fields['fecha_registro'] = fechaRegistro;
    request.fields['id_transaccion'] = idTransaccion;

    // Validar archivo antes de agregarlo
    if (!archivo.existsSync()) {
      throw Exception("El archivo no existe.");
    }

    // Archivo de imagen (usando el tipo MIME explícito)
    request.files.add(
      await http.MultipartFile.fromPath(
        'archivo', // Nombre del campo
        archivo.path,
        contentType: MediaType('archivo', 'jpg'), // MIME tipo explícito
      ),
    );

    // Imprimir detalles de los campos para depuración
    log("Request fields: ${request.fields}");
    log("Archivo a subir: ${archivo.path}");

    // Envía la solicitud
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    log("Response status: ${response.statusCode}");
    log("Response body: ${response.body}");

    // Verifica el estado de la respuesta
    if (response.statusCode == 201) {
      return Answer.fromService(response, 201);
    } else {
      return Answer(
          body: response.body,
          message: "Error en la solicitud.",
          status: response.statusCode,
          error: true);
    }
  } catch (e) {
    log("/StoreServices <postDirtyBroken> Catch - Error: $e");
    return Answer(
        body: e.toString(),
        message: "Algo salió mal, revisa tu conexión a internet.",
        status: 1002,
        error: true);
  }
}
Future<Answer> getDistance({required int idR}) async {
  log("/StoreServices <getDistance>");
  Map<String, dynamic> body = {
    "id_ruta": idR,
  };
  log("Request: $body");
  try {
    var response = await http.get(
      //Verificar la URL del stock
        Uri.parse("${prefs.urlBase}almacenmovil?q=distancia_ruta_almacen&id_ruta=$idR"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }).timeout(Duration(seconds: timerDuration));
    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);
      log("/StoreServices <getDistance> Successfull");
      log("Response Body: $decodedBody");
      return Answer(body: jsonDecode(response.body), message: "",status:response.statusCode, error: false);
    } else {
      var decodedBody = jsonDecode(response.body);
      log("/StoreServices <getDistance> Fail");
      log("Response Body: $decodedBody");
      return Answer(
          body: response,
          message: "No se pudieron obtener los datos actualizados de la planta. Revisa tu conexión a internet.",
          status:response.statusCode,
          error: true);
    }
  } catch (e) {
    log("/StoreServices <getDistance> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexión inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> deleteValidated({required int idV, required double lat, required double lng, required String comment}) async {
  log("/StoreServices <deleteValidated> ¡");
  try {
    Map<String, dynamic> body = {
      "id_validacion": idV,
      "comentario": comment,
      "lat": lat.toString(),
      "lon": lng.toString(),
    };

    // Imprimir el cuerpo antes de enviarlo
    log("Body enviado: ${jsonEncode(body)}");

    var response = await http.delete(Uri.parse("${prefs.urlBase}almacenmovil"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        },
        body: jsonEncode(body) );
    log("/StoreServices <postValidated>");
    return Answer.fromService(response,201);
  } catch (e) {
    log("/StoreServices <postValidated> Catch");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexión a internet.",
        status: 1002,
        error: true);
  }
}
Future<Answer> getMailbox({required String userR, required String serial, required String model}) async {
  log("/StoreServices <getMailbox>");
  try {
    var response = await http.get(
      Uri.parse("${prefs.urlBase}notificacionmovil?q=all&user=$userR&serial=$serial&model=$model"),
      headers: {
        "Content-Type": "application/json",
        "x-api-key": apiKey,
        "client_secret": prefs.clientSecret,
        "Authorization": "Bearer ${prefs.token}",
      },
    ).timeout(Duration(seconds: timerDuration));

    if (response.statusCode == 200) {
      if (response.body.trim().isNotEmpty) {
        var decodedBody = jsonDecode(response.body);
        log("/StoreServices <getMailbox> Successfull");
        log("Response Body: $decodedBody");
        return Answer(body: decodedBody, message: "", status: response.statusCode, error: false);
      } else {
        log("/StoreServices <getMailbox> Respuesta vacía");
        Fluttertoast.showToast(
          msg: 'No se encontraron registros',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 12.0,
        );
        return Answer(
          body: [],
          message: "No se encontraron registros",
          status: response.statusCode,
          error: true,
        );
      }
    } else {
      log("/StoreServices <getMailbox> Error status: ${response.statusCode}");
      String? bodyText = response.body.trim().isNotEmpty ? response.body : '{"error":"sin cuerpo"}';
      var decodedBody = jsonDecode(bodyText);
      log("Response Body: $decodedBody");
      return Answer(
        body: decodedBody,
        message: "No se pudieron obtener los datos actualizados de la planta. Revisa tu conexión a internet.",
        status: response.statusCode,
        error: true,
      );
    }
  } catch (e) {
    log("/StoreServices <getMailbox> Catch ${e.toString()}");
    return Answer(
      body: e,
      message: "Conexión inestable con el back",
      status: 1002,
      error: true,
    );
  }
}

Future<Answer> putReadAndReceived({required String id, required String delivered, required String readed}) async {
  log("/StoreServices <postValidated> ¡");
  try {
    Map<String, dynamic> body = {
      "id": id,
      "delivered": delivered,
      "readed": readed,
    };

    // Imprimir el cuerpo antes de enviarlo
    log("Body enviado: ${jsonEncode(body)}");

    var response = await http.put(Uri.parse("${prefs.urlBase}notificacionmovil"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        },
        body: jsonEncode(body) );
    log("/StoreServices <postValidated>");
    return Answer.fromService(response,201);
  } catch (e) {
    log("/StoreServices <postValidated> Catch");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexión a internet.",
        status: 1002,
        error: true);
  }
}
Future<Answer> getCancelAuth2(Map<String, dynamic> data) async {
  log("/StoreServices <getCancelAuth> $data");
  try {
    var response = await http.delete(Uri.parse("${prefs.urlBase}clienteautorizacion"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}"
        },
        body: jsonEncode(data)).timeout(Duration(seconds: timerDuration+5));
    return Answer.fromService(response, 201);
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Conexión inestable con el back",
        status: 1002,
        error: true);
  }
}

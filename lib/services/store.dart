// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:junghanns/models/answer.dart';
import 'package:http/http.dart' as http;

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
    log("/StoreServices <getStockList> Catch ${e.toString()}");
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
    log("/StoreServices <setSale> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
Future<Answer> getStopsList() async {
  log("/StoreServices <getStopsList>");
  try {
    var body = await http.get(Uri.parse("${prefs.urlBase}paradas"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    }).timeout(Duration(seconds: timerDuration));
    return Answer.fromService(body,200);
  } catch (e) {
    log("/StoreServices <getStopsList> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
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
            "Marca": build.brand,
            "VersionSO": build.version.securityPatch,
            "SerialNumber": build.version.release,
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
        Uri.parse("${prefs.urlBase}almacenmovil?q=stock&idRuta=$idR"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }).timeout(Duration(seconds: timerDuration));
    if (response.statusCode == 200) {
      log("/StoreServices <getStockList> Successfull");
      return Answer(body: jsonDecode(response.body), message: "",status:response.statusCode, error: false);
    } else {
      log("/StoreServices <getStockList> Fail");
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
        Uri.parse("${prefs.urlBase}almacenmovil?q=recarga&idRuta=$idR"),
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
        message: "Conexion inestable con el back",
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
        message: "Conexion inestable con el back",
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
        message: "Conexion inestable con el back",
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
        message: "Conexion inestable con el back",
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
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}


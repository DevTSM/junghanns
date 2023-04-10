// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:junghanns/models/answer.dart';
import 'package:http/http.dart' as http;

import '../preferences/global_variables.dart';

Future<Answer> getProductList() async {
  log("/StoreServices <getProductList>");
  try {
    var response = jsonDecode((await http.get(
            Uri.parse("${prefs.urlBase}almacenmovil?q=service&idRuta=21"),
            headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }))
        .body);
    if (response != null) {
      log("/StoreServices <getProductList> Successfull");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/StoreServices <getProductList> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/StoreServices <getProductList> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        error: true);
  }
}

//
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
        });
    log("${response.statusCode}");
    if (response.statusCode == 200) {
      log("/StoreServices <getStockList> Successfull, ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/StoreServices <getStockList> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/StoreServices <getStockList> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        error: true);
  }
}

Future<Answer> setInitRoute(double lat, double lng,{String status="inicio"}) async {
  log("/StoreServices <setInitRoute>");
  try {
    Map<String,dynamic> data={"tipo": status, "latitud": lat.toString(), "longitud": lng.toString()};
    log("${prefs.urlBase}    $lat    $lng $data   ${prefs.clientSecret}");
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
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/StoreServices <setInitRoute> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/StoreServices <setInitRoute> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        error: true);
  }
}

//
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
        });
    log("${response.statusCode}");
    if (response.statusCode == 200) {
      log("/StoreServices <getRefillList> Successfull, ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/StoreServices <getRefillList> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/StoreServices <getRefillList> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
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
      log("/StoreServices <getPaymentMethods> Successfull, ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/StoreServices <getPaymentMethods> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/StoreServices <getPaymentMethods> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
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
        });
    log("${response.statusCode} ${response.body}");
    if (response.statusCode == 200) {
      log("/StoreServices <getAuthorization> Successfull, ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/StoreServices <getAuthorization> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/StoreServices <getAuthorization> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        error: true);
  }
}

Future<Answer> setSale(Map<String, dynamic> data) async {
  log("/StoreServices <setSale>");
  try {
    var response =
        jsonDecode((await http.post(Uri.parse("${prefs.urlBase}venta"),
                headers: {
                  HttpHeaders.contentTypeHeader:
                      'application/json; charset=UTF-8',
                  "x-api-key": apiKey,
                  "client_secret": prefs.clientSecret,
                  "Authorization": "Bearer ${prefs.token}",
                },
                body: jsonEncode(data)))
            .body);
    if (response != null) {
      log("/StoreServices <setSale> Successfull");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/StoreServices <setSale> Fail ${response.toString()}");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/StoreServices <setSale> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
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
        body: jsonEncode(data));
    log("${response.statusCode}");
    if (response.statusCode == 201) {
      log("/StoreServices <PostSale> Successfull, ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/StoreServices <PostSale> Fail ${response.body}");
      return Answer(
          body: response,
          message: response.body,
          //"Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/StoreServices <setSale> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
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
    });
    return Answer.fromService(body); 
    // var response =jsonDecode(body.body);
    // if (response != null) {
    //   log("/StoreServices <getStopsList> Successfull ${response.toString()}");
    //   return Answer(body: response, message: "", error: false);
    // } else {
    //   log("/StoreServices <getStopsList> Fail");
    //   return Answer(
    //       body: response,
    //       message: "Algo salio mal, intentalo mas tarde.",
    //       error: true);
    // }
  } catch (e) {
    log("/StoreServices <getStopsList> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        error: true);
  }
}

Future<dynamic> updateAvatar(dynamic image, String id, String cedis) async {
  log("/StoreServices <updateAvatar> ");
  try {
    // var stream =
    //     // ignore: deprecated_member_use, unnecessary_new
    //     new http.ByteStream(DelegatingStream.typed(image.openRead()));

    // var length = await image.length();

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
        error: true);
  }
}

Future<Answer> setStop(Map<String, dynamic> data) async {
  log("/StoreServices <SetStop>");
  try {
    var response =
        jsonDecode((await http.post(Uri.parse("${prefs.urlBase}paradas"),
                headers: {
                  HttpHeaders.contentTypeHeader:
                      'application/json; charset=UTF-8',
                  "x-api-key": apiKey,
                  "client_secret": prefs.clientSecret,
                  "Authorization": "Bearer ${prefs.token}"
                },
                body: jsonEncode(data)))
            .body);
    if (response != null) {
      log("/StoreServices <SetStop> Successfull ${response.toString()}");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/StoreServices <SetStop> Fail ${response.toString()}");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/StoreServices <SetStop> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
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
        body: jsonEncode(data));
    log("${response.statusCode}");
    if (response.statusCode == 201) {
      log("/StoreServices <PostStop> Successfull ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/StoreServices <PostStop> Fail ${response.body}");
      return Answer(
          body: response,
          message: response.body,
          //"Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/StoreServices <SetStop> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
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
        });
    log("${response.body} -----");
    return Answer.fromService(response);
  } catch (e) {
    log("/CustomerServices <getListCustomer> Catch ${e.toString()}");
    return Answer(
        body: {"error": e.toString()},
        message: "Algo salio mal, revisa tu conexion a internet.",
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
    log("${response.statusCode}");
    if (response.statusCode == 200) {
      log("/StoreServices <getTypesOfStreets> Successfull, ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/StoreServices <getTypresOfStreets> Fail, ${response.body}");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Algo salio mal, revisa tu conexion a internet.",
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
      log("/StoreServices <getTypesOfSalesC> Successfull, ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/StoreServices <getTypresOfSalesC> Fail, ${response.body}");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Algo salio mal, revisa tu conexion a internet.",
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
      log("/StoreServices <getEmployees> Successfull, ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/StoreServices <getEmployees> Fail, ${response.body}");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Algo salio mal, revisa tu conexion a internet.",
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
    log("${response.statusCode}");
    if (response.statusCode == 201) {
      log("/StoreServices <PostNewCustomer> Successfull ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/StoreServices <PostNewCustomer> Fail ${response.body}");
      return Answer(
          body: response,
          message: response.body,
          //"Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Algo salio mal, revisa tu conexion a internet.",
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
    log("${response.statusCode}");
    var dataOTP = jsonDecode(response.body);
    if (response.statusCode == 200) {
      String check = dataOTP["message"] ?? "";
      if (check == "") {
        log("/StoreServices <PutValidateOTP> Successfull ${response.body}");
        return Answer(
            body: jsonDecode(response.body), message: "", error: false);
      } else {
        log("/StoreServices <PutValidateOTP> Fail ${response.body}");
        return Answer(body: dataOTP, message: dataOTP["message"], error: true);
      }
    } else {
      log("/StoreServices <PutValidateOTP> Fail ${response.body}");
      return Answer(body: dataOTP, message: response.body, error: true);
    }
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Algo salio mal, revisa tu conexion a internet.",
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
    log("${response.statusCode}");
    if (response.statusCode == 201) {
      log("/StoreServices <PostResendCode> Successfull ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/StoreServices <PostResendCode> Fail ${response.body}");
      return Answer(
          body: response,
          message: response.body,
          //"Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Algo salio mal, revisa tu conexion a internet.",
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
    log("${response.statusCode}");
    var dataOTP = jsonDecode(response.body);
    if (response.statusCode == 200) {
      String check = dataOTP["status"] ?? "";
      if (check == "Rechazado") {
        log("/StoreServices <PutCancelOTP> Successfull ${response.body}");
        return Answer(
            body: jsonDecode(response.body), message: "", error: false);
      } else {
        log("/StoreServices <PutCancelOTP> 1-Fail ${response.body}");
        return Answer(body: dataOTP, message: response.body, error: true);
      }
    } else {
      log("/StoreServices <PutCancelOTP> 2-Fail ${response.body}");
      return Answer(body: dataOTP, message: response.body, error: true);
    }
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Algo salio mal, revisa tu conexion a internet.",
        error: true);
  }
}

Future<Answer> getStatusRecordNewCustomer(int idR) async {
  log("/StoreServices <getStatusRecordNewCustomer>");
  try {
    var response = await http.get(
        Uri.parse("${prefs.urlBase}cliente?q=lead_estatus&id_ruta=$idR"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        });
    log("${response.statusCode}");
    if (response.statusCode == 200) {
      log("/StoreServices <getStatusRecordNewCustomer> Successfull, ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/StoreServices <getStatusRecordNewCustomer> Fail, ${response.body}");
      return Answer(body: response, message: response.body, error: true);
    }
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Algo salio mal, revisa tu conexion a internet.",
        error: true);
  }
}
Future<Answer> setComodato(int id,double lat, double lng,String phone) async {
  log("/StoreServices <setComodato>");
  try {
    var response = await http.post(
        Uri.parse("${prefs.urlBase}rutasolicitud"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        },body: jsonEncode({"tipo":"FC","phone":phone,"lat":lat,"lon":lng,"id_cliente":id}));
    log("/StoreServices <setComodato> ${response.body}");
    return Answer.fromService(response);
  } catch (e) {
    log("/StoreServices <setComodato> Catch");
    return Answer(body: e, message:"Algo salio mal, revisa tu conexion a internet.", error: true);
  }
}
Future<Answer> getStatusComodato(int id) async {
  log("/StoreServices <getStatusComodato>");
  try {
    var response = await http.get(
        Uri.parse("${prefs.urlBase}rutasolicitud?id=$id"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        });
    log("/StoreServices <getStatusComodato> ${response.body}");
    return Answer.fromService(response);
  } catch (e) {
    log("/StoreServices <getStatusComodato> Catch");
    return Answer(body: e, message:"Algo salio mal, revisa tu conexion a internet.", error: true);
  }
}
Future<Answer> getCustomers({int idLast=0}) async {
  log("/StoreServices <getCustomers>");
  try{
    var response = await http.get(
        Uri.parse("${prefs.urlBase}payload?idRuta=${prefs.idRouteD}&date=${DateFormat('yyyyMMdd').format(DateTime.now())}${idLast==0?'':'&sync=$idLast'}"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        });
      return Answer.fromService(response, message: "error al obtener los datos");
  }catch(e){
    return Answer(
        body: {"error": e},
        message: "Algo salio mal, revisa tu conexion a internet.",
        error: true);
  }
}
Future<Answer> getFolios() async {
  log("/StoreServices <getFolios>");
  try{
    var response = await http.get(
        Uri.parse("${prefs.urlBase}validate?q=folios&id_ruta=${prefs.idRouteD}"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        });
      return Answer.fromService(response, message: "error al obtener los datos");
  }catch(e){
    return Answer(
        body: {"error": e},
        message: "Algo salio mal, revisa tu conexion a internet.",
        error: true);
  }
}

// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:junghanns/models/answer.dart';
import 'package:http/http.dart' as http;

import '../preferences/global_variables.dart';

Future<Answer> getProductList() async {
  log("/StoreServices <getProductList>");
  try {
    var response = jsonDecode((await http.get(
            Uri.parse("$urlBase/index.php/almacenmovil?q=service&idRuta=21"),
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
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

//
Future<Answer> getStockList(int idR) async {
  log("/StoreServices <getStockList>");
  //try {
  var response = await http.get(
      Uri.parse("$urlBase/index.php/almacenmovil?q=stock&idRuta=$idR"),
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
  /*} catch (e) {
    log("/StoreServices <getStockList> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }*/
}

//
Future<Answer> getRefillList(int idR) async {
  log("/StoreServices <getRefillList>");
  //try {
  var response = await http.get(
      Uri.parse("$urlBase/index.php/almacenmovil?q=recarga&idRuta=$idR"),
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
  /*} catch (e) {
    log("/StoreServices <getRefillList> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }*/
}

Future<Answer> getPaymentMethods(int idClient, int idR) async {
  log("/StoreServices <getPaymentMethods>");
  //try {
  var response = await http.get(
      Uri.parse(
          "$urlBase/index.php/cliente?q=pay&idRuta=$idR&idCliente=$idClient"),
      headers: {
        "Content-Type": "aplication/json",
        "x-api-key": apiKey,
        "client_secret": prefs.clientSecret,
        "Authorization": "Bearer ${prefs.token}",
      });
  log("${response.statusCode}");
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
  /*} catch (e) {
    log("/StoreServices <getPaymentMethods> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }*/
}

Future<Answer> getAuthorization(int idClient, int idR) async {
  log("/StoreServices <getAuthorization>");
  // try {
  var response = await http.get(
      Uri.parse(
          "$urlBase/cliente?q=aut&idRuta=$idR&idCliente=$idClient&tipo=contado"),
      headers: {
        "Content-Type": "aplication/json",
        "x-api-key": apiKey,
        "client_secret": prefs.clientSecret,
        "Authorization": "Bearer ${prefs.token}",
      });
  log("${response.statusCode}");
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
  // } catch (e) {
  //   log("/StoreServices <getAuthorization> Catch ${e.toString()}");
  //   return Answer(
  //       body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  // }
}

Future<Answer> getFolio(String num) async {
  log("/StoreServices <getFolio>");
  try {
    var response = jsonDecode((await http.get(
            Uri.parse("$urlBase/index.php/validate?q=folio&num=$num"),
            headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": clientSecret,
          "Authorization":
              "Bearer " + "caf048dc9e6560d05fe75f8d00ee4c48db607654",
        }))
        .body);
    if (response != null) {
      log("/StoreServices <getFolio> Successfull");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/StoreServices <getFolio> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/StoreServices <getFolio> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

Future<Answer> setSale(Map<String, dynamic> data) async {
  log("/StoreServices <setSale>");
  try {
    var response =
        jsonDecode((await http.post(Uri.parse("$urlBase/index.php/venta"),
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
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

Future<Answer> postSale(Map<String, dynamic> data) async {
  log("/StoreServices <PostSale>");
  //try {
  var response = await http.post(Uri.parse("$urlBase/index.php/venta"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
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
  /*} catch (e) {
    log("/StoreServices <setSale> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }*/
}

Future<Answer> getStopsList() async {
  log("/StoreServices <getStopsList>");
  try {
    var response = jsonDecode(
        (await http.get(Uri.parse("$urlBase/index.php/paradas"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    }))
            .body);
    if (response != null) {
      log("/StoreServices <getStopsList> Successfull ${response.toString()}");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/StoreServices <getStopsList> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/StoreServices <getStopsList> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

Future<dynamic> updateAvatar(dynamic image, String id, String cedis) async {
  log("/StoreServices <updateAvatar> ");
  try {
    // var stream =
    //     // ignore: deprecated_member_use, unnecessary_new
    //     new http.ByteStream(DelegatingStream.typed(image.openRead()));

    // var length = await image.length();

    var uri = Uri.parse("$urlBase/cliente");
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
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

Future<Answer> setStop(Map<String, dynamic> data) async {
  log("/StoreServices <SetStop>");
  try {
    var response =
        jsonDecode((await http.post(Uri.parse("$urlBase/index.php/paradas"),
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
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

Future<Answer> postStop(Map<String, dynamic> data) async {
  log("/StoreServices <PostStop>");
  //try {
  var response = await http.post(Uri.parse("$urlBase/index.php/paradas"),
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
  /*} catch (e) {
    log("/StoreServices <SetStop> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }*/
}

Future<Answer> getDashboarRuta(int idR, String date) async {
  log("/StoreServices <getDashboardRuta>");
  //try {
  var response = await http.get(
      Uri.parse("$urlBase/index.php/dashboardruta?idRuta=$idR&date=$date"),
      headers: {
        "Content-Type": "aplication/json",
        "x-api-key": apiKey,
        "client_secret": prefs.clientSecret,
        "Authorization": "Bearer ${prefs.token}",
      });
  log("${response.statusCode}");
  if (response.statusCode == 200) {
    log("/StoreServices <getDashboarRuta> Successfull, ${response.body}");
    return Answer(body: jsonDecode(response.body), message: "", error: false);
  } else {
    log("/StoreServices <getDashboardRuta> Fail, ${response.body}");
    return Answer(
        body: response,
        message: "Algo salio mal, intentalo mas tarde.",
        error: true);
  }
  /*} catch (e) {
    log("/CustomerServices <getListCustomer> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }*/
}

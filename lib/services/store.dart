import 'dart:convert';
import 'dart:developer';

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
          "client_secret": clientSecret,
          "Authorization":
              "Bearer " + "caf048dc9e6560d05fe75f8d00ee4c48db607654",
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

Future<Answer> getRefillList() async {
  log("/StoreServices <getRefillList>");
  try {
    var response = jsonDecode((await http.get(
            Uri.parse("$urlBase/index.php/almacenmovil?q=recarga&idRuta=1"),
            headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": clientSecret,
          "Authorization":
              "Bearer " + "caf048dc9e6560d05fe75f8d00ee4c48db607654",
        }))
        .body);
    if (response != null) {
      log("/StoreServices <getRefillList> Successfull ${response.toString()}");
      return Answer(body: response, message: "", error: false);
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
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

Future<Answer> getPaymentMethods(int idClient) async {
  log("/StoreServices <getPaymentMethods>");
  try {
    var response = jsonDecode((await http.get(
            Uri.parse(
                "$urlBase/index.php/cliente?q=pay&idRuta=22&idCliente=$idClient"),
            headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": clientSecret,
          "Authorization":
              "Bearer " + "caf048dc9e6560d05fe75f8d00ee4c48db607654",
        }))
        .body);
    if (response != null) {
      log("/StoreServices <getPaymentMethods> Successfull ${response.toString()}");
      return Answer(body: response, message: "", error: false);
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
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

Future<Answer> getAuthorization(int idClient) async {
  log("/StoreServices <getAuthorization>");
  try {
    var response = jsonDecode((await http.get(
            Uri.parse(
                "$urlBase/index.php/cliente?q=aut&idRuta=21&idCliente=$idClient"),
            headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": clientSecret,
          "Authorization":
              "Bearer " + "caf048dc9e6560d05fe75f8d00ee4c48db607654",
        }))
        .body);
    if (response != null) {
      log("/StoreServices <getAuthorization> Successfull ${response.toString()}");
      return Answer(body: response, message: "", error: false);
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
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
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
      log("/StoreServices <getFolio> Successfull ${response.toString()}");
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
        jsonDecode((await http.post(Uri.parse("$urlBase/index.php/cliente"),
                headers: {
                  "Content-Type": "aplication/json",
                  "x-api-key": apiKey,
                  "client_secret": clientSecret,
                  "Authorization":
                      "Bearer " + "caf048dc9e6560d05fe75f8d00ee4c48db607654",
                },
                body: jsonEncode(data)))
            .body);
    if (response != null) {
      log("/StoreServices <setSale> Successfull ${response.toString()}");
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

Future<Answer> getStopsList() async {
  log("/StoreServices <getStopsList>");
  try {
    var response = jsonDecode(
        (await http.get(Uri.parse("$urlBase/index.php/paradas"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": clientSecret,
      "Authorization": "Bearer " + "caf048dc9e6560d05fe75f8d00ee4c48db607654",
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

Future<Answer> setLogin(Map<String, dynamic> data) async {
  log("/StoreServices <setLogin>");
  try {
    var response =
        jsonDecode((await http.post(Uri.parse("$urlBase/index.php/loginruta"),
                headers: {
                  "Content-Type": "aplication/json",
                  "x-api-key": apiKey,
                  "client_secret": clientSecret,
                },
                body: jsonEncode(data)))
            .body);
    if (response != null) {
      log("/StoreServices <setLogin> Successfull ${response.toString()}");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/StoreServices <setLogin> Fail ${response.toString()}");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/StoreServices <setLogin> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

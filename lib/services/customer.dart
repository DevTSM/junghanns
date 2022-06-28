import 'dart:convert';
import 'dart:developer';

import 'package:junghanns/models/answer.dart';
import 'package:http/http.dart' as http;
import 'package:junghanns/preferences/global_variables.dart';

Future<Answer> getListCustomer() async {
  log("/CustomerServices <getListCustomer>");
  try {
    var response = jsonDecode((await http.get(
            Uri.parse(
                "$urlBase/index.php/visita?idRuta=10&date=20220617&tipo=R"),
            headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": clientSecret,
          "Authorization":
              "Bearer " + "caf048dc9e6560d05fe75f8d00ee4c48db607654",
        }))
        .body);
    if (response != null) {
      log("/CustomerServices <getListCustomer> Successfull ");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/CustomerServices <getListCustomer> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/CustomerServices <getListCustomer> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

Future<Answer> getDetailsCustomer(int id) async {
  log("/CustomerServices <getDetailsCustomer>");
  try {
    var response = jsonDecode((await http.get(
            Uri.parse("$urlBase/index.php/cliente?q=dashboard&tipo=R&id=$id"),
            headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": clientSecret,
          "Authorization":
              "Bearer " + "caf048dc9e6560d05fe75f8d00ee4c48db607654",
        }))
        .body);
    if (response != null) {
      log("/CustomerServices <getDetailsCustomer> Successfull");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/CustomerServices <getDetailsCustomer> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/CustomerServices <getDetailsCustomer> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

Future<Answer> getListProductsAndRefill() async {
  log("/CustomerServices <getListProducts>");
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
      log("/CustomerServices <getListProducts> Successfull ");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/CustomerServices <getListProducts> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/CustomerServices <getListProducts> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:junghanns/models/answer.dart';
import 'package:http/http.dart' as http;
import 'package:junghanns/preferences/global_variables.dart';

Future<Answer> getListCustomer(int idR, String date, String type) async {
  log("/CustomerServices <getListCustomer>");
  //try {
  var response = await http
      .get(Uri.parse("$urlBase/visita?idRuta=$idR&date=$date&tipo=$type"),
          //Uri.parse("$urlBase/visita?idRuta=10&date=20220617&tipo=$type"),
          headers: {
        "Content-Type": "aplication/json",
        "x-api-key": apiKey,
        "client_secret": prefs.clientSecret,
        "Authorization": "Bearer ${prefs.token}",
      });
  log("${response.statusCode}");
  if (response.statusCode == 200) {
    log("/CustomerServices <getListCustomer> Successfull, ${response.body}");
    return Answer(body: jsonDecode(response.body), message: "", error: false);
  } else {
    log("/CustomerServices <getListCustomer> Fail");
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

Future<Answer> getDetailsCustomer(int id, String type) async {
  log("/CustomerServices <getDetailsCustomer>");
  //try {
  var response = await http.get(
      Uri.parse("$urlBase/index.php/cliente?q=dashboard&tipo=$type&id=$id"),
      headers: {
        "Content-Type": "aplication/json",
        "x-api-key": apiKey,
        "client_secret": prefs.clientSecret,
        "Authorization": "Bearer ${prefs.token}",
      });
  log("${response.statusCode}");
  if (response.statusCode == 200) {
    log("/CustomerServices <getDetailsCustomer> Successfull ${response.body}");
    return Answer(body: jsonDecode(response.body), message: "", error: false);
  } else {
    log("/CustomerServices <getDetailsCustomer> Fail");
    return Answer(
        body: response,
        message: "Algo salio mal, intentalo mas tarde.",
        error: true);
  }
  /*} catch (e) {
    log("/CustomerServices <getDetailsCustomer> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }*/
}

Future<Answer> getHistoryCustomer(int id) async {
  log("/CustomerServices <getHistoryCustomer>");
  try {
    var response = await http
        .get(Uri.parse("$urlBase/cliente?q=history&id=$id"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    });
    if (response.statusCode == 200) {
      log("/CustomerServices <getHistoryCustomer> Successfull ${jsonDecode(response.body)}");
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/CustomerServices <getHistoryCustomer> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal con el historial, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/CustomerServices <getHistoryCustomer> Catch");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

Future<Answer> getMoneyCustomer(int id) async {
  log("/CustomerServices <getMoneyCustomer>");
  try {
    var response =
        await http.get(Uri.parse("$urlBase/cliente?q=money&id=$id"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    });
    if (response.statusCode == 200) {
      log("/CustomerServices <getMoneyCustomer> Successfull ${jsonDecode(response.body)}");
      return Answer(body: jsonDecode(response.body), message: "", error: false);
    } else {
      log("/CustomerServices <getMoneyCustomer> Fail");
      return Answer(
          body: response,
          message: "No fue posible obtener el saldo, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/CustomerServices <getMoneyCustomer> Catch");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

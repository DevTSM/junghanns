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
                "$urlBase/visita?idRuta=10&date=20220617&tipo=R"),
            headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization":
              "Bearer ${prefs.token}",
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
    var responseEncode = await http.get(
            Uri.parse("$urlBase/index.php/cliente?q=dashboard&tipo=R&id=$id"),
            headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization":
              "Bearer ${prefs.token}",
        });
      var response=jsonDecode(responseEncode.body);
    if (response["idCliente"] != null) {
      log("/CustomerServices <getDetailsCustomer> Successfull");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/CustomerServices <getDetailsCustomer> Fail");
      return Answer(
          body: response,
          message: response["message"]??"Alo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/CustomerServices <getDetailsCustomer> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}
